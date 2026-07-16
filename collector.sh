#!/bin/bash

# ============================================
# Classic SIEM — Collector Module
# Версия: 0.1.0
# Назначение: сбор системных логов из /var/log/
# Автор: Reitre1 / Classic SIEM
# Лицензия: GNU GPL v3.0
# ============================================

# --- 1. ПЕРЕМЕННЫЕ ---
# Директория с системными логами
LOG_DIR="/var/log"

# Директория для сохранения собранных логов
OUTPUT_DIR="./logs"

# Текущая метка времени (формат: ГГГГ-ММ-ДД_ЧЧ-ММ-СС)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Имя выходного файла
OUTPUT_FILE="$OUTPUT_DIR/collected_logs_$TIMESTAMP.log"

# Список файлов для сбора (можно расширять)
FILES_TO_COLLECT=(
    "auth.log"          # Авторизация и аутентификация
    "syslog"            # Системные события
    "kern.log"          # Ядро системы
    "dpkg.log"          # Установка пакетов
    "apt/history.log"   # История APT
)

# --- 2. ФУНКЦИИ ---

# Функция: создание выходной директории
create_output_dir() {
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
        echo "[INFO] Создана директория: $OUTPUT_DIR"
    fi
}

# Функция: сбор логов
collect_logs() {
    echo "[INFO] Начинаю сбор логов..."
    echo "# Classic SIEM Collector Log" > "$OUTPUT_FILE"
    echo "# Время запуска: $(date)" >> "$OUTPUT_FILE"
    echo "# Источники: ${FILES_TO_COLLECT[*]}" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"

    for file in "${FILES_TO_COLLECT[@]}"; do
        if [ -f "$LOG_DIR/$file" ]; then
            echo "[INFO] Собираю: $LOG_DIR/$file"
            echo "=== $LOG_DIR/$file ===" >> "$OUTPUT_FILE"
            cat "$LOG_DIR/$file" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
        else
            echo "[WARN] Файл не найден: $LOG_DIR/$file"
        fi
    done

    echo "[SUCCESS] Логи сохранены в: $OUTPUT_FILE"
}

# Функция: подсчёт количества строк
count_lines() {
    if [ -f "$OUTPUT_FILE" ]; then
        LINES=$(wc -l < "$OUTPUT_FILE")
        echo "[INFO] Всего собрано строк: $LINES"
    fi
}

# --- 3. ОСНОВНОЙ ХОД ВЫПОЛНЕНИЯ ---

echo "======================================"
echo "  Classic SIEM Collector v0.1.0"
echo "======================================"

create_output_dir
collect_logs
count_lines

echo "======================================"
echo "  Готово!"
echo "======================================"
