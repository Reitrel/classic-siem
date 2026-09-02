#!/bin/bash

# ============================================================
# Classic SIEM — Оркестратор
# Версия: 1.2
# Назначение: последовательный запуск Collector → Normalizer → Correlator
# Автор: Денис Алексеев / Classic SIEM
# Лицензия: GNU GPL v3.0
# ============================================================

# --- 0. ОПРЕДЕЛЯЕМ ДИРЕКТОРИЮ СКРИПТА (динамически) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || {
    echo "[ERROR]: $(date): Не удалось перейти в директорию проекта"
    exit 1
}

# --- 1. БЛОКИРОВКА (предотвращает повторный запуск) ---
LOCKFILE="/tmp/classic_siem.lock"

exec 200>"$LOCKFILE"
if ! flock -n 200; then
    echo "[WARN]: $(date): Скрипт уже запущен. Выход."
    exit 1
fi

# --- 2. ОЧИСТКА СТАРЫХ ЛОГОВ (автоматическая) ---
echo "[INFO]: $(date): Удаляю логи старше 7 дней..."
find ./logs/ -name "*.log" -mtime +7 -delete
find ./normalized/ -name "*.json" -mtime +7 -delete
find ./alerts/ -name "*.txt" -mtime +7 -delete
echo "[INFO]: Очистка завершена."

# --- 3. ОСНОВНАЯ ЛОГИКА ---
echo "[INFO]: $(date): Запуск оркестратора Classic SIEM"
echo "[INFO]: Рабочая директория: $(pwd)"

# --- 3.1. Запуск Collector ---
echo "[INFO]: Запуск Collector..."
./src/collector.sh

if [ $? -eq 0 ]; then
    echo "[INFO]: Collector завершён успешно."

    # --- 3.2. Запуск Normalizer ---
    echo "[INFO]: Запуск Normalizer..."
    ./src/normalizer.sh

    if [ $? -eq 0 ]; then
        echo "[INFO]: Normalizer завершён успешно."

        # --- 3.3. Запуск Correlator ---
        echo "[INFO]: Запуск Correlator..."
        ./src/correlator.sh

        if [ $? -eq 0 ]; then
            echo "[INFO]: Correlator завершён успешно."
        else
            echo "[ERROR]: $(date): Correlator завершён с ошибкой!"
            exit 1
        fi

    else
        echo "[ERROR]: $(date): Normalizer завершён с ошибкой!"
        exit 1
    fi

else
    echo "[ERROR]: $(date): Collector завершён с ошибкой!"
    exit 1
fi

echo "[INFO]: $(date): Все модули отработали успешно."

# --- 4. ЗАВЕРШЕНИЕ ---
exit 0
