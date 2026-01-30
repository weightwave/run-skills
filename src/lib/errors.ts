import type { ErrorHandler } from 'hono';
import type { ContentfulStatusCode } from 'hono/utils/http-status';

export class AppError extends Error {
  constructor(
    message: string,
    public statusCode: ContentfulStatusCode = 500,
    public code: string = 'INTERNAL_ERROR',
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class SkillNotFoundError extends AppError {
  constructor(command: string) {
    super(`Unknown skill: ${command}`, 404, 'SKILL_NOT_FOUND');
  }
}

export class StreamNotFoundError extends AppError {
  constructor(streamId: string) {
    super(`Stream not found: ${streamId}`, 404, 'STREAM_NOT_FOUND');
  }
}

export class MachineCreationError extends AppError {
  constructor(message: string, statusCode: ContentfulStatusCode = 502) {
    super(message, statusCode, 'MACHINE_ERROR');
  }
}

export const errorHandler: ErrorHandler = (err, c) => {
  console.error(`[ERROR] ${err.message}`, err.stack);

  if (err instanceof AppError) {
    return c.json(
      { error: err.message, code: err.code },
      { status: err.statusCode },
    );
  }

  return c.json(
    { error: 'Internal server error', code: 'INTERNAL_ERROR' },
    { status: 500 },
  );
};
