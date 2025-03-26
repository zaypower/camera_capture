#!/bin/bash

# Параметры
URL="http://your_camera_ip_or_url"  # URL камеры для получения изображения
OUTPUT_DIR="/path/to/images"        # Каталог для сохранения изображений

# Создание каталога, если он не существует
mkdir -p "$OUTPUT_DIR"

# Формирование имени файла с временной меткой
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="$OUTPUT_DIR/image_$TIMESTAMP.jpg"

# Скачиваем изображение
curl -s -o "$FILENAME" "$URL"

if [ $? -eq 0 ]; then
  echo "Изображение сохранено: $FILENAME"
else
  echo "Ошибка при получении изображения."
fi
