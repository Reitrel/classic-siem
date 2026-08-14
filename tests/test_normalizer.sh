#!/bin/bash

# ============================================
# Classic SIEM - Тесты для модуля Normalizer
# Версия: 1.0
# Назначение: автоматическая проверка работоспособности normalizer.sh
# Автор: Денис Алексеев / Classic SIEM
# Лицензия: GNU GPL v3.0
# ============================================

clear

echo "=========================================="
echo "  Classic SIEM — Тестирование Normalizer"
echo "=========================================="

ERRORS=0
JSON_FILE=""

# --- 1. Проверка: существует ли файл normalizer.sh ---
echo "[1] Проверка наличия файла src/normalizer.sh..."
if [ -f "src/normalizer.sh" ]; then
    echo "    ✅ Файл найден."
else
    echo "    ❌ Файл НЕ найден!"
    ERRORS=$((ERRORS + 1))
fi

# --- 2. Проверка: есть ли права на выполнение ---
echo "[2] Проверка прав на выполнение..."
if [ -x "src/normalizer.sh" ]; then
    echo "    ✅ Права есть."
else
    echo "    ⚠️  Прав нет. Добавляю..."
    chmod u+x src/normalizer.sh
    if [ -x "src/normalizer.sh" ]; then
        echo "    ✅ Права успешно добавлены."
    else
        echo "    ❌ Не удалось добавить права!"
        ERRORS=$((ERRORS + 1))
    fi
fi

# --- 3. Проверка: создаётся ли директория ./normalized/ ---
echo "[3] Проверка наличия директории для JSON..."
if [ -d "normalized" ]; then
    echo "    ✅ Директория normalized/ уже существует."
else
    echo "    ⚠️  Директория отсутствует. Будет создана при запуске."
fi

# --- 4. Запуск нормализатора (весь вывод → /dev/null) ---
echo "[4] Запуск normalizer.sh..."
./src/normalizer.sh > /dev/null 2>&1

# --- 5. Проверка, создался ли JSON-файл ---
echo "[5] Проверка создания JSON-файла..."
JSON_FILE=$(ls -t ./normalized/normalized_*.json 2>/dev/null | head -n1)
if [ -f "$JSON_FILE" ]; then
    echo "    ✅ JSON-файл создан: $JSON_FILE"
else
    echo "    ❌ JSON-файл НЕ создан!"
    ERRORS=$((ERRORS + 1))
fi

# --- 6. Проверка валидности JSON ---
if [ -f "$JSON_FILE" ]; then
    echo "[6] Проверка валидности JSON..."
    if command -v jq &> /dev/null; then
        if jq empty "$JSON_FILE" 2>/dev/null; then
            echo "    ✅ JSON валидный."
        else
            echo "    ❌ JSON НЕ валидный!"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "    ⚠️  jq не установлен. Пропускаем проверку валидности."
        echo "    Для установки: sudo apt install jq -y"
    fi
fi

# --- ИТОГ ---
echo "=========================================="
if [ $ERRORS -eq 0 ]; then
    echo "  ✅ ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО!"
    echo "  Normalizer работает корректно."
    echo ""
    exit 0
else
    echo "  ❌ ОБНАРУЖЕНО ОШИБОК: $ERRORS"
    echo "  Проверьте вывод выше и исправьте проблемы."
    echo ""
    exit 1
fi
