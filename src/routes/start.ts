import { Hono } from 'hono';
import { describeRoute, resolver, validator } from 'hono-openapi';
import type { StartRequest } from '../types.js';
import { StartRequestSchema, StartResponseSchema } from '../types.js';
import { getSkillConfig } from '../services/registry.js';
import { createBuffer, appendChunk, getBuffer } from '../services/buffer.js';
import { createSkillMachine } from '../services/machines.js';
import { SkillNotFoundError } from '../lib/errors.js';
import { bearerAuth } from '../middleware/auth.js';

const start = new Hono();

start.post(
  '/api/start',
  bearerAuth,
  describeRoute({
    tags: ['Skills'],
    summary: 'Start a skill execution',
    description:
      'Launches a Fly Machine to execute the specified skill command. Returns a streamId for streaming output.',
    responses: {
      200: {
        description: 'Skill machine created successfully',
        content: {
          'application/json': { schema: resolver(StartResponseSchema) },
        },
      },
      401: { description: 'Unauthorized' },
      404: { description: 'Unknown skill command' },
      502: { description: 'Failed to create machine' },
    },
  }),
  validator('json', StartRequestSchema),
  async (c) => {
    const { command, args, userId } = c.req.valid('json' as never) as StartRequest;

    // Look up skill config
    const skillConfig = getSkillConfig(command);
    if (!skillConfig) {
      throw new SkillNotFoundError(command);
    }

    // Create output buffer
    const streamId = createBuffer({
      userId,
      command,
      machineId: null,
    });

    // Create Fly Machine
    try {
      const machine = await createSkillMachine({
        command,
        args,
        userId,
        streamId,
        skillConfig,
      });

      // Update buffer with machineId
      const buffer = getBuffer(streamId);
      if (buffer) buffer.machineId = machine.id;

      return c.json(
        {
          streamId,
          status: 'starting' as const,
          machineId: machine.id,
        },
        200,
      );
    } catch (err) {
      appendChunk(streamId, {
        type: 'error',
        message:
          err instanceof Error
            ? err.message
            : 'Unknown error creating machine',
        timestamp: Date.now(),
      });

      throw err;
    }
  },
);

export default start;
