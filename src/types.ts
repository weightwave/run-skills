import { z } from '@hono/zod-openapi';

// ─── Skill Registry ───

export const SkillNameSchema = z.string().min(1).max(64).regex(/^[a-z0-9-]+$/);

export const SkillConfigSchema = z.object({
  image: z.string(),
  description: z.string(),
  timeout_seconds: z.number().int().positive().default(300),
  cpu_kind: z.enum(['shared', 'performance']).default('shared'),
  cpus: z.number().int().positive().default(1),
  memory_mb: z.number().int().positive().default(256),
});

export type SkillConfig = z.infer<typeof SkillConfigSchema>;

// ─── POST /api/start ───

export const StartRequestSchema = z.object({
  command: SkillNameSchema.openapi({ example: 'ascii-image-converter' }),
  args: z.array(z.string()).default([]).openapi({ example: ['image.png', '--color'] }),
  userId: z.string().min(1).max(128).openapi({ example: 'user_abc123' }),
});

export type StartRequest = z.infer<typeof StartRequestSchema>;

export const StartResponseSchema = z
  .object({
    streamId: z.string().uuid().openapi({ example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890' }),
    status: z.enum(['starting', 'error']).openapi({ example: 'starting' }),
    machineId: z.string().optional().openapi({ example: 'd8901234abcd' }),
  })
  .openapi('StartResponse');

export type StartResponse = z.infer<typeof StartResponseSchema>;

// ─── GET /api/stream/:streamId ───

export const StreamParamsSchema = z.object({
  streamId: z.string().uuid().openapi({
    param: { name: 'streamId', in: 'path' },
    example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  }),
});

// ─── SSE Events ───

export const SSEEventSchema = z.discriminatedUnion('type', [
  z.object({
    type: z.literal('stdout'),
    data: z.string(),
    timestamp: z.number(),
  }),
  z.object({
    type: z.literal('stderr'),
    data: z.string(),
    timestamp: z.number(),
  }),
  z.object({
    type: z.literal('done'),
    exitCode: z.number().int(),
    timestamp: z.number(),
  }),
  z.object({
    type: z.literal('error'),
    message: z.string(),
    timestamp: z.number(),
  }),
]);

export type SSEEvent = z.infer<typeof SSEEventSchema>;

// ─── POST /api/output/:streamId (internal callback) ───

export const OutputRequestSchema = z.discriminatedUnion('type', [
  z.object({
    type: z.literal('chunk'),
    stream: z.enum(['stdout', 'stderr']),
    data: z.string(),
  }),
  z.object({
    type: z.literal('done'),
    exitCode: z.number().int(),
  }),
]);

export type OutputRequest = z.infer<typeof OutputRequestSchema>;

export const OutputResponseSchema = z
  .object({
    ok: z.boolean(),
  })
  .openapi('OutputResponse');

// ─── Buffer ───

export interface OutputBuffer {
  streamId: string;
  userId: string;
  machineId: string | null;
  command: string;
  createdAt: number;
  chunks: SSEEvent[];
  completed: boolean;
  exitCode: number | null;
  waiters: Set<() => void>;
}
