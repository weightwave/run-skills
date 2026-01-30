import { Hono } from 'hono';
import { describeRoute, resolver, validator } from 'hono-openapi';
import type { OutputRequest } from '../types.js';
import {
  OutputRequestSchema,
  OutputResponseSchema,
  StreamParamsSchema,
} from '../types.js';
import { appendChunk, markComplete, getBuffer } from '../services/buffer.js';
import { internalAuth } from '../middleware/internal.js';

const output = new Hono();

output.post(
  '/api/output/:streamId',
  internalAuth,
  describeRoute({
    tags: ['Internal'],
    summary: 'Receive output from skill container',
    description:
      'Internal endpoint called by the container wrapper to push stdout/stderr chunks and signal completion.',
    responses: {
      200: {
        description: 'Chunk accepted',
        content: {
          'application/json': { schema: resolver(OutputResponseSchema) },
        },
      },
      403: { description: 'Forbidden - invalid internal secret' },
      404: { description: 'Stream not found' },
    },
  }),
  validator('param', StreamParamsSchema),
  validator('json', OutputRequestSchema),
  async (c) => {
    const { streamId } = c.req.valid('param');
    const body = c.req.valid('json');

    const buffer = getBuffer(streamId);
    if (!buffer) {
      return c.json({ ok: false }, 404);
    }

    if (body.type === 'chunk') {
      appendChunk(streamId, {
        type: body.stream,
        data: body.data,
        timestamp: Date.now(),
      });
    } else if (body.type === 'done') {
      markComplete(streamId, body.exitCode);
    }

    return c.json({ ok: true }, 200);
  },
);

export default output;
