# Run-Skills Agent Instructions

## Available Commands

When you need to run a non-unix standard tool, prefix the command with `runskills`.

### Usage

```
runskills <skill-name> [arguments...]
```

### Examples

```bash
runskills ascii-image-converter image.png --color
runskills ffmpeg -i input.mp4 -vf scale=720:-1 output.mp4
runskills imagemagick convert photo.jpg -resize 50% thumbnail.jpg
```

### File Access

- All files are available at `/vol/{userId}/`
- Input files should be placed there before running skills
- Output files will be written there by the skill

### How It Works

1. `runskills` sends your command to the API
2. A dedicated container spins up to execute it
3. Output streams back in real-time
4. The container auto-destroys after completion
5. Exit code reflects the command's success/failure

### Available Skills

| Skill | Description |
|-------|-------------|
| `ascii-image-converter` | Convert images to ASCII art |
| `ffmpeg` | Media processing and conversion |
| `imagemagick` | Image manipulation and conversion |
