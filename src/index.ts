import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import { Scalar } from '@scalar/hono-api-reference';
import { openAPIRouteHandler } from 'hono-openapi';
import { errorHandler } from './lib/errors.js';
import { env } from './env.js';
import { startCleanupInterval } from './services/buffer.js';

import start from './routes/start.js';
import stream from './routes/stream.js';
import output from './routes/output.js';

const app = new Hono();

// Global error handler
app.onError(errorHandler);

// Mount route modules
app.route('/', start);
app.route('/', stream);
app.route('/', output);

// Health check
app.get('/health', (c) => c.json({ status: 'ok', timestamp: Date.now() }));

// API documentation
app.get('/scalar', Scalar({ url: '/openapi' }));
app.get(
  '/openapi',
  openAPIRouteHandler(app, {
    documentation: {
      info: {
        title: 'Run-Skills API',
        version: '1.0.0',
        description:
          'API for executing skills via ephemeral Fly Machines with real-time output streaming.',
      },
      servers: [
        { url: 'http://localhost:3000', description: 'Local Server' },
        { url: 'https://run-skills.fly.dev', description: 'Production' },
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: 'http',
            scheme: 'bearer',
            description: 'API Bearer Token',
          },
        },
      },
    },
  }),
);

// Start buffer cleanup
const cleanupTimer = startCleanupInterval();

serve(
  {
    fetch: app.fetch,
    port: env.PORT,
  },
  (info) => {
    console.log(`Run-Skills API running on http://localhost:${info.port}`);
  },
);

// Graceful shutdown
process.on('SIGTERM', () => {
  clearInterval(cleanupTimer);
  process.exit(0);
});
