# Timelapse Video from Camera Images

## Overview
This project consists of two Bash scripts that periodically capture images from a camera and compile them into a timelapse video. The scripts run as cron jobs.

### Features:
- **Image Capture Script (`get_image.sh`)**: Fetches an image from a camera URL at regular intervals and saves it with a timestamp.
- **Video Update Script (`update_video.sh`)**: Compiles new images into a temporary video and appends it to the existing video, then deletes used images.
- Uses `ffmpeg` for video processing.

---

## Installation & Setup

### 1. Install Required Packages
Ensure you have `curl` and `ffmpeg` installed:

```bash
sudo apt update && sudo apt install curl ffmpeg -y
```

### 2. Configure & Install Scripts

#### **Image Capture Script (`get_image.sh`):**
This script downloads an image from a camera URL and stores it in a specified directory.

**Create the script:**

```bash
nano /path/to/get_image.sh
```

**Paste the following:**

```bash
#!/bin/bash

URL="http://your_camera_ip_or_url"
OUTPUT_DIR="/path/to/images"

mkdir -p "$OUTPUT_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="$OUTPUT_DIR/image_$TIMESTAMP.jpg"

curl -s -o "$FILENAME" "$URL"

echo "Saved: $FILENAME"
```

**Make it executable:**
```bash
chmod +x /path/to/get_image.sh
```

#### **Video Update Script (`update_video.sh`):**
This script processes new images into a video and appends it to an existing timelapse video.

**Create the script:**

```bash
nano /path/to/update_video.sh
```

**Paste the following:**

```bash
#!/bin/bash

INPUT_DIR="/path/to/images"
TEMP_VIDEO="/path/to/temp.mp4"
OUTPUT_VIDEO="/path/to/output.mp4"
FRAME_RATE=30

IMAGES=($(ls "$INPUT_DIR"/*.jpg 2>/dev/null))
if [ ${#IMAGES[@]} -eq 0 ]; then
  echo "No new images."
  exit 0
fi

ffmpeg -framerate $FRAME_RATE -pattern_type glob -i "$INPUT_DIR/*.jpg" -c:v libx264 -pix_fmt yuv420p "$TEMP_VIDEO"

if [ ! -f "$OUTPUT_VIDEO" ]; then
  mv "$TEMP_VIDEO" "$OUTPUT_VIDEO"
  echo "Created new video: $OUTPUT_VIDEO"
else
  CONCAT_LIST="/tmp/video_list.txt"
  echo "file '$OUTPUT_VIDEO'" > "$CONCAT_LIST"
  echo "file '$TEMP_VIDEO'" >> "$CONCAT_LIST"
  
  ffmpeg -f concat -safe 0 -i "$CONCAT_LIST" -c copy "${OUTPUT_VIDEO}.tmp"
  mv "${OUTPUT_VIDEO}.tmp" "$OUTPUT_VIDEO"
  rm "$TEMP_VIDEO"
  echo "Updated video: $OUTPUT_VIDEO"
fi

rm "$INPUT_DIR"/*.jpg
```

**Make it executable:**
```bash
chmod +x /path/to/update_video.sh
```

---

## Running the Scripts with Cron

### **1. Capture Images Periodically**
Run the `get_image.sh` script every minute:
```bash
crontab -e
```
Add:
```bash
* * * * * /bin/bash /path/to/get_image.sh
```

### **2. Append Images to Video**
Run the `update_video.sh` script every 4 hours:
```bash
crontab -e
```
Add:
```bash
0 */4 * * * /bin/bash /path/to/update_video.sh
```

---

## Notes
- Adjust `FRAME_RATE` in `update_video.sh` if needed (e.g., `24` instead of `30`).
- Change cron timing to match your recording preferences.
- Ensure enough storage space for images and video output.

---

## License
MIT License

