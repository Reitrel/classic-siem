#!/bin/bash

# ============================================================
# Classic SIEM — Оркестратор
# Версия: 1.1
# Назначение: последовательный запуск модулей Collector → Normalizer
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

# --- 2. ОСНОВНАЯ ЛОГИКА ---
echo "[INFO]: $(date): Запуск оркестратора Classic SIEM"
echo "[INFO]: Рабочая директория: $(pwd)"

# --- 2.1. Запуск Collector ---
echo "[INFO]: Запуск Collector..."
./src/collector.sh

if [ $? -eq 0 ]; then
    echo "[INFO]: Collector завершён успешно."

    # --- 2.2. Запуск Normalizer ---
    echo "[INFO]: Запуск Normalizer..."
    ./src/normalizer.sh

    if [ $? -eq 0 ]; then
        echo "[INFO]: Normalizer завершён успешно."
    else
        echo "[ERROR]: $(date): Normalizer завершён с ошибкой!"
        exit 1
    fi

else
    echo "[ERROR]: $(date): Collector завершён с ошибкой! Normalizer не запущен."
    exit 1
fi

# --- 2.3. (Будущие модули) Correlator, Alerter, ... ---

echo "[INFO]: $(date): Все модули отработали успешно."

# --- 3. ЗАВЕРШЕНИЕ ---
exit 0
