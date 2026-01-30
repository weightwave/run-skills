import { z } from '@hono/zod-openapi';

const envSchema = z.object({
  FLY_API_TOKEN: z.string().min(1),
  FLY_APP_NAME: z.string().min(1),
  FLY_API_APP_NAME: z.string().min(1),
  API_BEARER_TOKEN: z.string().min(1),
  INTERNAL_SECRET: z.string().min(1),
  PORT: z.coerce.number().default(3000),
  FLY_REGION: z.string().transform((v) => v || undefined).optional(),
});

export type Env = z.infer<typeof envSchema>;

export const env: Env = envSchema.parse(process.env);
