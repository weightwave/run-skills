import type { SkillConfig } from '../types.js';

const SKILLS: Record<string, SkillConfig> = {
  'ascii-image-converter': {
    image: 'registry.fly.io/run-skills-ascii-image-converter:latest',
    description: 'Convert images to ASCII art',
    timeout_seconds: 120,
    cpu_kind: 'shared',
    cpus: 1,
    memory_mb: 256,
  },
  ffmpeg: {
    image: 'registry.fly.io/run-skills-ffmpeg:latest',
    description: 'FFmpeg media processing',
    timeout_seconds: 600,
    cpu_kind: 'shared',
    cpus: 2,
    memory_mb: 512,
  },
  imagemagick: {
    image: 'registry.fly.io/run-skills-imagemagick:latest',
    description: 'ImageMagick image processing',
    timeout_seconds: 300,
    cpu_kind: 'shared',
    cpus: 1,
    memory_mb: 512,
  },
};

export function getSkillConfig(command: string): SkillConfig | undefined {
  return SKILLS[command];
}

export function listSkills(): Array<{ name: string; config: SkillConfig }> {
  return Object.entries(SKILLS).map(([name, config]) => ({ name, config }));
}

export function isValidSkill(command: string): boolean {
  return command in SKILLS;
}
