#!/bin/bash

# =======================================================================
# Classic SIEM - Normalizer Module
# Версия: 0.2.0
# Назначение: приведение собранных логов к единому формату (JSON) с максимальной скоростью
# Автор: Денис Алексеев / Classic SIEM
# Лицензия: GNU GPL v3.0
# =======================================================================

clear

# --- ПЕРЕМЕННЫЕ ---
INPUT_DIR="./logs"
OUTPUT_DIR="./normalized"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_FILE="$OUTPUT_DIR/normalized_$TIMESTAMP.json"

# --- ФУНКЦИИ ---

# 1. Создание выходной директории
create_output_dir() {
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
        echo "[INFO]: Создана директория: $OUTPUT_DIR"
    fi
}

# 2. Поиск последнего собранного лог-файла
find_latest_log() {
    LATEST_LOG=$(ls -t "$INPUT_DIR"/collected_logs_*.log 2>/dev/null | head -n1)
    if [ -z "$LATEST_LOG" ]; then
        echo "[ERROR]: Нет собранных логов."
        exit 1
    fi
    echo "[INFO]: Обработка файла: $LATEST_LOG"
}

# 3. Парсинг через AWK (максимальная скорость!)
parse_logs_with_awk() {
    local input_file="$1"
    local output_file="$2"

    local tmp_file=$(mktemp)

    echo "[" > "$tmp_file"

    awk '
    BEGIN { first = 1 }
    /sshd/ {
        if ($0 ~ /^#/) next

        # Извлекаем timestamp (первые 3 поля)
        timestamp = $1 " " $2 " " $3

        # Извлекаем PID
        pid = $0
        gsub(/.*sshd\[/, "", pid)
        gsub(/\].*/, "", pid)
        if (pid == "") pid = "unknown"

        # Извлекаем имя пользователя
        user = $0
        gsub(/.*for /, "", user)
        gsub(/ .*/, "", user)
        if (user == "") user = "unknown"

        # Извлекаем IP-адрес источника
        src_ip = $0
        gsub(/.*from /, "", src_ip)
        gsub(/ .*/, "", src_ip)
        if (src_ip == "") src_ip = "unknown"

        # Извлекаем порт
        port = $0
        gsub(/.*port /, "", port)
        gsub(/ .*/, "", port)
        if (port == "") port = "unknown"

        # Формируем JSON-объект
        if (!first) {
            print "," >> "'"$tmp_file"'"
        }
        first = 0

        print "  \"event\": {" >> "'"$tmp_file"'"
        print "    \"timestamp\": \"" timestamp "\"," >> "'"$tmp_file"'"
        print "    \"service\": \"sshd\"," >> "'"$tmp_file"'"
        print "    \"pid\": " pid "," >> "'"$tmp_file"'"
        print "    \"event_type\": \"" $0 "\"," >> "'"$tmp_file"'"
        print "    \"user\": \"" user "\"," >> "'"$tmp_file"'"
        print "    \"src_ip\": \"" src_ip "\"," >> "'"$tmp_file"'"
        print "    \"port\": " port >> "'"$tmp_file"'"
        print "  }" >> "'"$tmp_file"'"
    }
    ' "$input_file"

    echo "]" >> "$tmp_file"
    mv "$tmp_file" "$output_file"
}

# 4. Основная функция нормализации (управляет процессом)
normalize_logs() {
    local start_time=$(date +%s%N)

    echo "[INFO]: Начинаю обработку..."

    # Получаем общее количество строк
    local total_lines=$(wc -l < "$LATEST_LOG")
    echo "[INFO]: Всего строк в файле: $total_lines"

    # Запускаем парсер
    parse_logs_with_awk "$LATEST_LOG" "$OUTPUT_FILE"
    local event_count=$(grep -c '"event"' "$OUTPUT_FILE")

    local end_time=$(date +%s%N)
    local elapsed_ns=$((end_time - start_time))
    local elapsed_sec=$((elapsed_ns / 1000000000))
    local elapsed_ms=$(( (elapsed_ns / 1000000) % 1000 ))

    echo ""
    echo "[SUCCESS]: Нормализованные логи сохранены в: $OUTPUT_FILE"
    echo "[STATS]: Всего обработано строк: $total_lines"
    echo "[STATS]: Найдено событий: $event_count"
    echo "[STATS]: Время обработки: $(format_time $elapsed_sec $elapsed_ms)"
}

# 5. Форматирование времени
format_time() {
    local seconds=$1
    local millis=$2
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    printf "%02d:%02d:%02d:%03d" "$hours" "$minutes" "$secs" "$millis"
}

# --- ОСНОВНАЯ ЛОГИКА ---

echo "================================"
echo " Classic SIEM Normalizer v0.2.0"
echo "================================"

create_output_dir
find_latest_log
normalize_logs

echo "================================"
