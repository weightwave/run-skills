import { Hono } from 'hono';
import { streamSSE } from 'hono/streaming';
import { describeRoute, validator } from 'hono-openapi';
import { StreamParamsSchema } from '../types.js';
import {
  getBuffer,
  addWaiter,
  removeWaiter,
} from '../services/buffer.js';
import { StreamNotFoundError } from '../lib/errors.js';
import { bearerAuth } from '../middleware/auth.js';

const stream = new Hono();

stream.get(
  '/api/stream/:streamId',
  bearerAuth,
  describeRoute({
    tags: ['Skills'],
    summary: 'Stream skill output via SSE',
    description:
      'Server-Sent Events stream of stdout/stderr from a running skill. Connect immediately after /api/start.',
    responses: {
      200: {
        description: 'SSE stream of output events',
        content: {
          'text/event-stream': {},
        },
      },
      401: { description: 'Unauthorized' },
      404: { description: 'Stream not found' },
    },
  }),
  validator('param', StreamParamsSchema),
  async (c) => {
    const { streamId } = c.req.valid('param' as never) as { streamId: string };
    const buffer = getBuffer(streamId);

    if (!buffer) {
      throw new StreamNotFoundError(streamId);
    }

    return streamSSE(c, async (sseStream) => {
      let cursor = 0;

      // Replay buffered chunks
      while (cursor < buffer.chunks.length) {
        const event = buffer.chunks[cursor]!;
        await sseStream.writeSSE({
          event: event.type,
          data: JSON.stringify(event),
          id: String(cursor),
        });
        cursor++;
      }

      if (buffer.completed) {
        return;
      }

      // Wait for new chunks
      while (!buffer.completed) {
        await new Promise<void>((resolve) => {
          const wake = () => {
            removeWaiter(streamId, wake);
            resolve();
          };
          addWaiter(streamId, wake);

          // Safety timeout: re-check every 30s
          setTimeout(() => {
            removeWaiter(streamId, wake);
            resolve();
          }, 30_000);
        });

        // Drain new chunks
        while (cursor < buffer.chunks.length) {
          const event = buffer.chunks[cursor]!;
          await sseStream.writeSSE({
            event: event.type,
            data: JSON.stringify(event),
            id: String(cursor),
          });
          cursor++;
        }
      }
    });
  },
);

export default stream;
