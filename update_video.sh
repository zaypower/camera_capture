#!/bin/bash

# Параметры
INPUT_DIR="/path/to/images"       # Каталог с изображениями
TEMP_VIDEO="/path/to/temp.mp4"    # Временный видеофайл
OUTPUT_VIDEO="/path/to/output.mp4" # Итоговый видеофайл
FRAME_RATE=30                      # Частота кадров (fps)

# Проверяем, есть ли новые изображения
IMAGES=($(ls "$INPUT_DIR"/*.jpg 2>/dev/null))

if [ ${#IMAGES[@]} -eq 0 ]; then
  echo "Нет новых изображений для добавления."
  exit 0
fi

# Создаём временное видео из новых изображений
ffmpeg -framerate $FRAME_RATE -pattern_type glob -i "$INPUT_DIR/*.jpg" -c:v libx264 -pix_fmt yuv420p "$TEMP_VIDEO"

# Если основного видео еще нет, просто переименовываем временный файл
if [ ! -f "$OUTPUT_VIDEO" ]; then
  mv "$TEMP_VIDEO" "$OUTPUT_VIDEO"
  echo "Создан новый видеофайл: $OUTPUT_VIDEO"
else
  # Объединяем существующее видео с новым
  CONCAT_LIST="/tmp/video_list.txt"
  echo "file '$OUTPUT_VIDEO'" > "$CONCAT_LIST"
  echo "file '$TEMP_VIDEO'" >> "$CONCAT_LIST"

  ffmpeg -f concat -safe 0 -i "$CONCAT_LIST" -c copy "${OUTPUT_VIDEO}.tmp"
  
  # Заменяем старый файл новым
  mv "${OUTPUT_VIDEO}.tmp" "$OUTPUT_VIDEO"
  rm "$TEMP_VIDEO"
  echo "Обновлено видео: $OUTPUT_VIDEO"
fi

# Удаляем использованные изображения
rm "$INPUT_DIR"/*.jpg
echo "Удалены обработанные изображения."
