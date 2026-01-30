import type { OutputBuffer, SSEEvent } from '../types.js';
import { randomUUID } from 'node:crypto';

const buffers = new Map<string, OutputBuffer>();

const BUFFER_TTL_MS = 10 * 60 * 1000;

export function createBuffer(opts: {
  userId: string;
  command: string;
  machineId: string | null;
}): string {
  const streamId = randomUUID();
  const buffer: OutputBuffer = {
    streamId,
    userId: opts.userId,
    machineId: opts.machineId,
    command: opts.command,
    createdAt: Date.now(),
    chunks: [],
    completed: false,
    exitCode: null,
    waiters: new Set(),
  };
  buffers.set(streamId, buffer);
  return streamId;
}

export function getBuffer(streamId: string): OutputBuffer | undefined {
  return buffers.get(streamId);
}

export function appendChunk(streamId: string, event: SSEEvent): boolean {
  const buffer = buffers.get(streamId);
  if (!buffer) return false;

  buffer.chunks.push(event);

  for (const wake of buffer.waiters) {
    wake();
  }

  return true;
}

export function markComplete(streamId: string, exitCode: number): boolean {
  const buffer = buffers.get(streamId);
  if (!buffer) return false;

  buffer.completed = true;
  buffer.exitCode = exitCode;
  buffer.chunks.push({
    type: 'done',
    exitCode,
    timestamp: Date.now(),
  });

  for (const wake of buffer.waiters) {
    wake();
  }

  return true;
}

export function addWaiter(streamId: string, wake: () => void): boolean {
  const buffer = buffers.get(streamId);
  if (!buffer) return false;
  buffer.waiters.add(wake);
  return true;
}

export function removeWaiter(streamId: string, wake: () => void): void {
  const buffer = buffers.get(streamId);
  if (buffer) {
    buffer.waiters.delete(wake);
  }
}

export function deleteBuffer(streamId: string): void {
  buffers.delete(streamId);
}

export function startCleanupInterval(): NodeJS.Timeout {
  return setInterval(() => {
    const now = Date.now();
    for (const [id, buffer] of buffers) {
      if (now - buffer.createdAt > BUFFER_TTL_MS) {
        buffers.delete(id);
      }
    }
  }, 60_000);
}

export function getBufferCount(): number {
  return buffers.size;
}
