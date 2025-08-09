#!/bin/bash
# --- CONFIG ---
API_KEY="<API_KEY>"
OUTPUT_FILE="assets.txt"
MAX_JOBS=4

touch $OUTPUT_FILE

# --- UPLOAD FUNCTION ---
# Uploads a single file, checks for errors
# Saves result to $OUTPUT_FILE
# Arguments:
#   $1: The path to the song file (e.g., ./songs/song1.mp3)
uploadAsset() {
        local songname=$1
        local response=$(curl -s https://api.1min.ai/api/assets -H "API-KEY: $API_KEY" -F "asset=@$songname")

        local key=$(echo $response | jq -r .asset.key)
        if [[ -z "$key" || "$key" == "null" ]]; then
                echo "[ERROR] Could not find 'asset.key' in API response for '$songname'. Response: $response"
                return 1
        fi


        jq -n --arg k $key --arg s "${songname##*/}" '{key: $k, songname: $s}' >> $OUTPUT_FILE

        echo "[SUCCESS] Processed: $songname"
}


# --- MAIN EXECUTION ---
echo "[INFO] Finding all .mp3 files and starting upload process..."
find . -type f -name "*.mp3" -print0 | while IFS= read -r -d '' songname; do
        if (( $(jobs -p | wc -l) >= MAX_JOBS )); then
                wait -n
        fi
        echo "Processing file: $songname"
        uploadAsset $songname &
done

echo "[INFO] All uploads started. Waiting for completion."

wait
sleep 1s
echo "[DONE] Script finished. Output saved to $OUTPUT_FILE."
