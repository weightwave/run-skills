import { env } from '../env.js';
import { MachineCreationError } from '../lib/errors.js';
import type { SkillConfig } from '../types.js';

const MACHINES_BASE = 'https://api.machines.dev/v1';

interface CreateMachineParams {
  command: string;
  args: string[];
  userId: string;
  streamId: string;
  skillConfig: SkillConfig;
}

interface MachineResponse {
  id: string;
  name: string;
  state: string;
  instance_id: string;
}

function headers(): HeadersInit {
  return {
    Authorization: `Bearer ${env.FLY_API_TOKEN}`,
    'Content-Type': 'application/json',
  };
}

export async function createSkillMachine(
  params: CreateMachineParams,
): Promise<MachineResponse> {
  const { command, args, userId, streamId, skillConfig } = params;

  const callbackUrl = `http://${env.FLY_API_APP_NAME}.internal:${env.PORT}/api/output/${streamId}`;

  const body = {
    config: {
      image: skillConfig.image,
      auto_destroy: true,
      env: {
        STREAM_ID: streamId,
        COMMAND: command,
        ARGS: args.join('\x00'),
        USER_ID: userId,
        CALLBACK_URL: callbackUrl,
        INTERNAL_SECRET: env.INTERNAL_SECRET,
      },
      guest: {
        cpu_kind: skillConfig.cpu_kind,
        cpus: skillConfig.cpus,
        memory_mb: skillConfig.memory_mb,
      },
      mounts: [
        {
          volume: `vol_${userId}`,
          path: `/vol/${userId}`,
        },
      ],
      init: {
        entrypoint: ['/bin/sh'],
        cmd: ['/wrapper.sh'],
      },
      restart: {
        policy: 'no',
      },
      metadata: {
        stream_id: streamId,
        user_id: userId,
        skill: command,
      },
    },
    region: env.FLY_REGION,
  };

  const res = await fetch(
    `${MACHINES_BASE}/apps/${env.FLY_APP_NAME}/machines`,
    {
      method: 'POST',
      headers: headers(),
      body: JSON.stringify(body),
    },
  );

  if (!res.ok) {
    const errorText = await res.text();
    throw new MachineCreationError(
      `Fly Machines API error ${res.status}: ${errorText}`,
      502,
    );
  }

  return (await res.json()) as MachineResponse;
}

export async function waitForMachineState(
  machineId: string,
  state: 'started' | 'stopped' | 'destroyed' = 'started',
  timeout: number = 30,
): Promise<void> {
  const res = await fetch(
    `${MACHINES_BASE}/apps/${env.FLY_APP_NAME}/machines/${machineId}/wait?state=${state}&timeout=${timeout}`,
    { headers: headers() },
  );

  if (!res.ok) {
    const errorText = await res.text();
    throw new MachineCreationError(
      `Wait for machine ${machineId} failed: ${errorText}`,
      502,
    );
  }
}
