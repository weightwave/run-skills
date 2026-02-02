import type { SkillConfig } from '../types.js';

const regUrl = '471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:'

const SKILLS: Record<string, SkillConfig> = {
  'ascii-image-converter': {
    image: regUrl + 'ascii-image-converter-latest',
    description: 'Convert images to ASCII art',
    timeout_seconds: 120,
    cpu_kind: 'shared',
    cpus: 1,
    memory_mb: 256,
  },
  ffmpeg: {
    image: regUrl + 'ffmpeg-latest',
    description: 'FFmpeg media processing',
    timeout_seconds: 600,
    cpu_kind: 'shared',
    cpus: 2,
    memory_mb: 512,
  },
  imagemagick: {
    image: regUrl + 'imagemagick-latest',
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
