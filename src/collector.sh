#!/bin/bash

# ============================================
# Classic SIEM — Collector Module
# Версия: 0.1.1
# Назначение: сбор системных логов из /var/log/
# Автор: Reitrel / Classic SIEM
# Лицензия: GNU GPL v3.0
# ============================================

# --- ПЕРЕМЕННЫЕ ---
LOG_DIR="/var/log"
OUTPUT_DIR="./logs"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_FILE="$OUTPUT_DIR/collected_logs_$TIMESTAMP.log"

# Массив с файлами для сбора
FILES_TO_COLLECT=(
    "auth.log"          # Авторизация и аутентификация
    "syslog"            # Все системные события
    "kern.log"          # Ядро системы
    "messages"          # Общие системные сообщения
    "daemon.log"        # Фоновые службы
    "faillog"           # Неудачные попытки входа
    "lastlog"           # Последние входы пользователей
    "secure"            # Безопасность и аутентификация
    "apt/history.log"   # История установки пакетов
    "apt/term.log"      # Терминал при установке
    "dpkg.log"          # Подробный лог пакетов
    "cron.log"          # Планировщик CRON
    "mail.log"          # Почтовый сервер
    "nginx/access.log"  # Веб-сервер Nginx (доступ)
    "nginx/error.log"   # Веб-сервер Nginx (ошибки)
)

# --- ОПРЕДЕЛЕНИЕ СПОСОБА ВЫВОДА ---

# Проверяем, установлен ли dialog
if command -v dialog &> /dev/null; then
    USE_DIALOG=true
else
    USE_DIALOG=false
    echo "[WARN] Утилита dialog не установлена. Использую текстовый вывод."
    echo "[INFO] Для установки выполните: sudo apt install dialog -y"
fi

# Функция вывода сообщений
print_msg() {
    local TYPE="$1"
    local MESSAGE="$2"
    local TITLE="${3:-Classic SIEM}"

    if [ "$USE_DIALOG" = true ]; then
        case "$TYPE" in
            "info")    dialog --title "$TITLE" --msgbox "$MESSAGE" 8 50 ;;
            "stats")   dialog --title "Статистика" --msgbox "$MESSAGE" 20 60 ;;
            "gauge")   echo "$MESSAGE" | dialog --gauge "Сбор логов..." 6 50 0 ;;
            *)         dialog --title "$TITLE" --msgbox "$MESSAGE" 8 50 ;;
        esac
    else
        echo "$MESSAGE"
    fi
}

# --- ФУНКЦИИ ---

# 1. Создание выходной директории
create_output_dir() {
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
        print_msg "info" "Создана директория: $OUTPUT_DIR"
    fi
}

# 2. Сбор логов
collect_logs() {
    echo "# Classic SIEM Collector Log" > "$OUTPUT_FILE"
    echo "# Время запуска: $(date)" >> "$OUTPUT_FILE"
    echo "# Источники: ${FILES_TO_COLLECT[*]}" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"

    FOUND_FILES=()
    MISSING_FILES=()

    TOTAL_FILES=${#FILES_TO_COLLECT[@]}
    CURRENT=0

    for file in "${FILES_TO_COLLECT[@]}"; do
        CURRENT=$((CURRENT + 1))
        PERCENT=$((CURRENT * 100 / TOTAL_FILES))

        if [ "$USE_DIALOG" = true ]; then
            echo "$PERCENT" | dialog --gauge "Сбор логов... ($CURRENT/$TOTAL_FILES)" 6 50 0
        fi

        if [ -f "$LOG_DIR/$file" ]; then
            FOUND_FILES+=("$file")
            echo "[INFO] Собираю: $LOG_DIR/$file"
            echo "=== $LOG_DIR/$file ===" >> "$OUTPUT_FILE"
            cat "$LOG_DIR/$file" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
        else
            MISSING_FILES+=("$file")
            echo "[WARN] Файл не найден: $LOG_DIR/$file"
        fi
    done

    print_msg "info" "Сбор завершён! Логи сохранены в: $OUTPUT_FILE"
}

# 3. Подсчёт строк
count_lines() {
    if [ -f "$OUTPUT_FILE" ]; then
        LINES=$(wc -l < "$OUTPUT_FILE")
        print_msg "info" "Всего собрано строк: $LINES"
    fi
}

# 4. Статистика по файлам
show_statistics() {
    STATS="=== СТАТИСТИКА ===\n\n"
    STATS+="✅ Найдено файлов: ${#FOUND_FILES[@]}\n"
    STATS+="❌ Отсутствует: ${#MISSING_FILES[@]}\n\n"

    if [ ${#FOUND_FILES[@]} -gt 0 ]; then
        STATS+="--- Найденные файлы ---\n"
        for f in "${FOUND_FILES[@]}"; do
            STATS+="  ✅ $f\n"
        done
    fi

    if [ ${#MISSING_FILES[@]} -gt 0 ]; then
        STATS+="\n--- Отсутствующие файлы ---\n"
        for f in "${MISSING_FILES[@]}"; do
            STATS+="  ❌ $f\n"
        done
    fi

    print_msg "stats" "$STATS"
}

# --- ОСНОВНАЯ ЛОГИКА ---

# Показываем приветственное окно
print_msg "info" "Добро пожаловать в Classic SIEM Collector v0.1.1!"

create_output_dir
collect_logs
count_lines
show_statistics

# Финальное сообщение
print_msg "info" "Сбор логов завершён успешно! Файл сохранён: $OUTPUT_FILE"

# Очистка экрана после завершения (только для терминала)
if [ "$USE_DIALOG" = false ]; then
    clear
    echo "======================================"
    echo "  Classic SIEM Collector v0.1.1"
    echo "======================================"
    echo "[SUCCESS] Логи сохранены в: $OUTPUT_FILE"
    echo "[INFO] Всего собрано строк: $LINES"
    echo "======================================"
fi
