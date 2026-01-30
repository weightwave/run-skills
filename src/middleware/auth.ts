import type { MiddlewareHandler } from 'hono';
import { env } from '../env.js';

export const bearerAuth: MiddlewareHandler = async (c, next) => {
  const authHeader = c.req.header('Authorization');
  if (!authHeader) {
    return c.json({ error: 'Missing Authorization header' }, 401);
  }

  const [scheme, token] = authHeader.split(' ');
  if (scheme !== 'Bearer' || token !== env.API_BEARER_TOKEN) {
    return c.json({ error: 'Invalid bearer token' }, 401);
  }

  await next();
};
