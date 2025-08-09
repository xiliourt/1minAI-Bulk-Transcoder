#!/bin/bash

# --- Configuration ---
# Your API Key
API_KEY=<API_KEY>
# JSON file containing the list of assets
ASSETS_FILE="assets.txt"
# Number of parallel jobs to run. Start with a low number like 4.
MAX_PARALLEL_JOBS=4


# --- Main Function ---
# This function processes a single song. It is designed to be called by xargs.
# $1: The audio key/URL
# $2: The original songname (for naming the output file)
thread() {
  local audio_url="$1"
  local songname="$2"
  local output_file="${songname%.*}.txt"
  echo "[INFO] Starting transcription for: $songname"

  # 1. Safely create the JSON payload using jq
  local temp_json
  temp_json='{ "type": "SPEECH_TO_TEXT", "model": "whisper-1", "promptObject": { "audioUrl": "'"$(echo $audio_url)"'", "response_format": "text" }}'
  # 2. Call the API and capture the HTTP status code and response
  local http_code
  local response
  response=$(curl --silent --show-error \
    -w "%{http_code}" \
    -X POST "https://api.1min.ai/api/features" \
    -H "API-KEY: $API_KEY" \
    -H "Content-Type: application/json" \
    --data "$temp_json")

  # Extract the status code from the end of the response
  http_code=${response: -3}
  response=${response:0:${#response}-3}

  # 3. Add error handling
  if [[ "$http_code" -ne 200 ]]; then
    echo "[ERROR] Failed '$songname'. HTTP Status: $http_code. Response: $response"
    return 1
  fi

  # 4. Safely parse the response and save to a file
  local result
  result=$(echo "$response" | jq -r '.aiRecord.aiRecordDetail.resultObject')

  if [[ -z "$result" || "$result" == "null" ]]; then
    echo "[ERROR] Failed to parse transcription for '$songname'. API Response: $response"
    return 1
  fi

  echo "$result" > "$output_file"
  echo "[SUCCESS] Finished transcription for: $songname. Saved to $output_file"
}

# Export the function and API_KEY so xargs can access them
export -f transcribe_song
export API_KEY

# --- Execution ---
# Use jq to feed songname and key to xargs.
# xargs controls the concurrency to avoid overwhelming the API.
echo "Starting transcription process with up to $MAX_PARALLEL_JOBS parallel jobs..."

jq -r '.assets[] | "\(.songname)\t\(.key)"' assets.txt | while IFS=$'\t' read -r songname key; do
  echo "Processing Song: $songname"
  echo "File Key: $key"
  echo "---"
  thread "$key" "$songname" &
done
echo "All jobs completed."
