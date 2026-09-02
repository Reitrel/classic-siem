#!/bin/bash

#=====================================================
# Classic-SIEM - Correlator Module
# Версия: 0.1.1
# Назначение: обнаружение аномалий и генерация алертов
# Автор: Денис АЛЕКСЕЕВ / Classic-SIEM
# Лицензия: CNU GPL v3.0
#=====================================================

clear

# --- ПЕРЕМЕННЫЕ ---
INPUT_DIR="./normalized"
ALERTS_DIR="./alerts"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ALERT_FILE="$ALERTS_DIR/alerts_$TIMESTAMP.txt"

# --- ФУНКЦИИ ---

create_alerts_dir() {
    if [ ! -d "$ALERTS_DIR" ]; then
        mkdir -p "$ALERTS_DIR"
        echo "[INFO]: Создана директория: $ALERTS_DIR"
    fi
}

find_latest_json() {
    LATEST_JSON=$(ls -t "$INPUT_DIR"/normalized_*.json 2>/dev/null | head -n1)
    if [ -z "$LATEST_JSON" ]; then
        echo "[ERROR]: Нет нормализованных логов. Запустите сначала normalizer.sh"
        exit 1
    fi
    echo "[INFO]: Обработка файла: $LATEST_JSON"
}

correlate_events() {
    echo "[INFO]: Анализирую события..."

    if ! command -v jq &> /dev/null; then
        echo "[ERROR]: jq не установлен! Установите: sudo apt install jq -y"
        exit 1
    fi

    local tmp_alerts=$(mktemp)
    local alert_count=0

    echo "=======================================" > "$tmp_alerts"
    echo " Classic-SIEM - Алерты" >> "$tmp_alerts"
    echo " Время: $(date)" >> "$tmp_alerts"
    echo "=======================================" >> "$tmp_alerts"
    echo "" >> "$tmp_alerts"

    echo "[INFO]: Проверка правила: брутфорс (5+ неудачных попыток)"

    local tmp_counts=$(mktemp)

    jq -r '.[] | select(.event.event_type == "failed_password") | .event.src_ip' "$LATEST_JSON" | \
    sort | uniq -c > "$tmp_counts"

    while read count ip; do
        if [ "$count" -ge 5 ]; then
            echo "[ALERT]: Брутфорс! IP: $ip, попыток: $count" >> "$tmp_alerts"
            echo "ВРЕМЯ: $(date)" >> "$tmp_alerts"
            echo "" >> "$tmp_alerts"
            alert_count=$((alert_count + 1))
        fi
    done < "$tmp_counts"

    rm -f "$tmp_counts"

    if [ "$alert_count" -gt 0 ]; then
        cp "$tmp_alerts" "$ALERT_FILE"

        # Правильное склонение
        if [ "$alert_count" -eq 1 ]; then
            echo "[SUCCESS]: Обнаружена $alert_count угроза! Алерты сохранены в: $ALERT_FILE"
        elif [ "$alert_count" -ge 2 ] && [ "$alert_count" -le 4 ]; then
            echo "[SUCCESS]: Обнаружено $alert_count угрозы! Алерты сохранены в: $ALERT_FILE"
        else
            echo "[SUCCESS]: Обнаружено $alert_count угроз! Алерты сохранены в: $ALERT_FILE"
        fi
    else
        echo "[INFO]: Угроз не обнаружено. Алерт-файл не создан."
        rm -f "$tmp_alerts"
    fi

    echo "[INFO]: Анализ завершён!"
    echo ""
}

# --- ОСНОВНАЯ ЛОГИКА ---

echo "========================================"
echo "     Classic-SIEM Correlator v0.1.1     "
echo "========================================"

create_alerts_dir
find_latest_json
correlate_events

