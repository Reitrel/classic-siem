#!/bin/bash

# =======================================================================
# Classic SIEM - Normalizer Module
# Версия: 0.2.1
# Назначение: приведение собранных логов к единому формату (JSON)
# Автор: Денис Алексеев / Classic SIEM
# Лицензия: GNU GPL v3.0
# =======================================================================

clear

# --- ПЕРЕМЕННЫЕ ---
INPUT_DIR="./logs"                              # Директория с собранными логами
OUTPUT_DIR="./normalized"                       # Директория для нормализованных JSON
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")          # Метка времени
OUTPUT_FILE="$OUTPUT_DIR/normalized_$TIMESTAMP.json"
PROCESSED_MARKER="./processed_marker.txt"       # Файл для отслеживания обработанных логов

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

# 3. Проверка, что файл ещё не обработан (с проверкой наличия JSON)
check_if_processed() {
    if [ -f "$PROCESSED_MARKER" ] && grep -q "^$LATEST_LOG$" "$PROCESSED_MARKER"; then
        local json_file=$(ls -t "$OUTPUT_DIR"/normalized_*.json 2>/dev/null | head -n1)
        if [ -f "$json_file" ]; then
            echo "[WARN]: Файл $LATEST_LOG уже был обработан ранее."
            echo "[INFO]: JSON-файл существует: $json_file"
            echo "[INFO]: Пропускаем."
            exit 0
        else
            echo "[WARN]: Файл $LATEST_LOG отмечен как обработанный, но JSON не найден."
            echo "[INFO]: Удаляем метку и обрабатываем заново."
            sed -i "\|^$LATEST_LOG$|d" "$PROCESSED_MARKER"
        fi
    fi
}

# 4. Проверка, есть ли события sshd в логах
check_has_events() {
    if ! grep -q "sshd" "$LATEST_LOG"; then
        echo "[WARN]: В логах нет событий sshd."
        echo "[INFO]: JSON не создан."
        exit 0
    fi
}

# 5. Парсинг через AWK (исправленная версия)
parse_logs_with_awk() {
    local input_file="$1"

    awk '
    BEGIN {
        first = 1
        count = 0
    }
    /sshd/ {
        if ($0 ~ /^#/) next

        # timestamp — это первое поле (уже ISO-дата)
        timestamp = $1

        # PID — ищем [цифры]
        pid = "unknown"
        if (match($0, /\[[0-9]+\]/)) {
            tmp = substr($0, RSTART + 1, RLENGTH - 2)
            if (tmp ~ /^[0-9]+$/) pid = tmp
        }

        # IP — ищем IP-адрес или rhost=
        ip = "0.0.0.0"
        if (match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)) {
            ip = substr($0, RSTART, RLENGTH)
        } else if (match($0, /rhost=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)) {
            ip = substr($0, RSTART + 6, RLENGTH - 6)
        }

        # port — ищем "port " или "port="
        port = "0"
        if (match($0, /port [0-9]+/)) {
            port = substr($0, RSTART + 5, RLENGTH - 5)
        } else if (match($0, /port=[0-9]+/)) {
            port = substr($0, RSTART + 5, RLENGTH - 5)
        }

        # event_type — по ключевым словам
        event_type = "unknown"
        if (index($0, "Connection closed by") > 0) {
            event_type = "connection_closed"
        } else if (index($0, "Failed password") > 0) {
            event_type = "failed_password"
        } else if (index($0, "Accepted password") > 0) {
            event_type = "accepted_password"
        } else if (index($0, "authentication failure") > 0) {
            event_type = "authentication_failure"
        } else if (index($0, "session opened") > 0) {
            event_type = "session_opened"
        } else if (index($0, "session closed") > 0) {
            event_type = "session_closed"
        } else if (index($0, "logout() returned an error") > 0) {
            event_type = "logout_error"
        } else if (index($0, "Server listening on") > 0) {
            event_type = "server_started"
        }

        
        # message — извлекаем правильно для всех случаев
        message = ""
        pos = index($0, "]:")
        if (pos > 0) {
            # Если есть ]: — берём после него (стандартный случай)
            message = substr($0, pos + 2)
        } else {
            # Иначе ищем после последнего :
            pos = match($0, /:[^:]*$/)
            if (pos > 0) {
                message = substr($0, pos + 2)
            } else {
                message = $0
            }
        }
        gsub(/"/, "\\\"", message)


        # user — ищем после "user " или "user="
        user = "unknown"
        if (match($0, /user [^ ]+/)) {
            user = substr($0, RSTART + 5, RLENGTH - 5)
        } else if (match($0, /user=[^ ]+/)) {
            user = substr($0, RSTART + 5, RLENGTH - 5)
        }

        # --- ФОРМИРУЕМ JSON СТРОКУ ---
        if (!first) {
            print ","
        }
        first = 0

        printf "  \"event\": {\n"
        printf "    \"timestamp\": \"%s\",\n", timestamp
        printf "    \"service\": \"sshd\",\n"
        printf "    \"pid\": %s,\n", pid
        printf "    \"event_type\": \"%s\",\n", event_type
        printf "    \"message\": \"%s\",\n", message
        printf "    \"user\": \"%s\",\n", user
        printf "    \"src_ip\": \"%s\",\n", ip
        printf "    \"port\": %s\n", port
        printf "  }"
    }
    ' "$input_file"
}

# 6. Основная функция нормализации
normalize_logs() {
    local start_time=$(date +%s%N)

    echo "[INFO]: Начинаю обработку..."

    # Получаем общее количество строк
    local total_lines=$(wc -l < "$LATEST_LOG")
    echo "[INFO]: Всего строк в файле: $total_lines"

    # Проверяем, есть ли события sshd
    if ! grep -q "sshd" "$LATEST_LOG"; then
        echo "[WARN]: В логах нет событий sshd."
        echo "[INFO]: JSON не создан."
        return 1
    fi

    # Запускаем парсер и сохраняем вывод
    local json_output
    json_output=$(parse_logs_with_awk "$LATEST_LOG")

    # Проверяем, есть ли данные
    if [ -z "$json_output" ]; then
        echo "[WARN]: Не удалось распарсить события."
        echo "[INFO]: JSON не создан."
        return 1
    fi

    # Записываем JSON в файл
    {
        echo "["
        echo "$json_output"
        echo "]"
    } > "$OUTPUT_FILE"

    # Отмечаем файл как обработанный
    echo "$LATEST_LOG" >> "$PROCESSED_MARKER"

    local end_time=$(date +%s%N)
    local elapsed_ns=$((end_time - start_time))
    local elapsed_sec=$((elapsed_ns / 1000000000))
    local elapsed_ms=$(( (elapsed_ns / 1000000) % 1000 ))

    local event_count=$(grep -c '"event"' "$OUTPUT_FILE")

    echo ""
    echo "[SUCCESS]: Нормализованные логи сохранены в: $OUTPUT_FILE"
    echo "[STATS]: Всего обработано строк: $total_lines"
    echo "[STATS]: Найдено событий: $event_count"
    echo "[STATS]: Время обработки: $(format_time $elapsed_sec $elapsed_ms)"
}

# 7. Форматирование времени
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
echo " Classic SIEM Normalizer v0.2.1"
echo "================================"

create_output_dir
find_latest_log
check_if_processed
check_has_events
normalize_logs

echo "================================"
