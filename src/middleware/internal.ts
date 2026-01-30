import type { MiddlewareHandler } from 'hono';
import { env } from '../env.js';

export const internalAuth: MiddlewareHandler = async (c, next) => {
  const secret = c.req.header('X-Internal-Secret');
  if (secret !== env.INTERNAL_SECRET) {
    return c.json({ error: 'Forbidden' }, 403);
  }

  await next();
};
