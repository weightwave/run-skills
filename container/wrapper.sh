#!/usr/bin/env bash
set -uo pipefail

# ─── Environment (set by Fly Machine config) ───
: "${CALLBACK_URL:?CALLBACK_URL is required}"
: "${INTERNAL_SECRET:?INTERNAL_SECRET is required}"
: "${COMMAND:?COMMAND is required}"
: "${ARGS:=""}"
: "${USER_ID:?USER_ID is required}"

# Working directory is the user's volume
cd "/vol/${USER_ID}" 2>/dev/null || true

# ─── Helper: send a chunk to the API ───
send_chunk() {
  local stream_type="$1"
  local data="$2"

  local json_data
  json_data=$(printf '%s' "$data" | jq -Rs .)

  curl -sf \
    -X POST \
    -H "X-Internal-Secret: ${INTERNAL_SECRET}" \
    -H "Content-Type: application/json" \
    -d "{\"type\":\"chunk\",\"stream\":\"${stream_type}\",\"data\":${json_data}}" \
    "${CALLBACK_URL}" >/dev/null 2>&1 || true
}

# ─── Helper: send done signal ───
send_done() {
  local exit_code="$1"
  curl -sf \
    -X POST \
    -H "X-Internal-Secret: ${INTERNAL_SECRET}" \
    -H "Content-Type: application/json" \
    -d "{\"type\":\"done\",\"exitCode\":${exit_code}}" \
    "${CALLBACK_URL}" >/dev/null 2>&1 || true
}

# ─── Parse ARGS (null-byte separated) ───
PARSED_ARGS=()
if [ -n "$ARGS" ]; then
  while IFS= read -r -d $'\0' arg; do
    PARSED_ARGS+=("$arg")
  done <<< "$ARGS"
fi

# ─── Create named pipes for capturing stdout/stderr separately ───
STDOUT_PIPE=$(mktemp -u)
STDERR_PIPE=$(mktemp -u)
mkfifo "$STDOUT_PIPE"
mkfifo "$STDERR_PIPE"

# ─── Background readers that send chunks ───
(
  while IFS= read -r line; do
    send_chunk "stdout" "$line"
  done < "$STDOUT_PIPE"
) &
STDOUT_READER_PID=$!

(
  while IFS= read -r line; do
    send_chunk "stderr" "$line"
  done < "$STDERR_PIPE"
) &
STDERR_READER_PID=$!

# ─── Execute the command ───
"$COMMAND" "${PARSED_ARGS[@]}" >"$STDOUT_PIPE" 2>"$STDERR_PIPE"
CMD_EXIT_CODE=$?

# Wait for pipe readers to finish draining
wait "$STDOUT_READER_PID" 2>/dev/null || true
wait "$STDERR_READER_PID" 2>/dev/null || true

# Clean up pipes
rm -f "$STDOUT_PIPE" "$STDERR_PIPE"

# ─── Signal completion ───
send_done "$CMD_EXIT_CODE"

exit "$CMD_EXIT_CODE"
