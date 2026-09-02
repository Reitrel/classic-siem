#!/bin/bash

# ===================================================================
# Classic-SIEM - Тесты для модуля Correlator
# Версия: 1.0
# Назначение: автоматическая проверка работоспособности correlator.sh
# Автор: Денис АЛЕКСЕЕВ / Classic-SIEM
# Лицензия: GNU GPL v3.0
# ===================================================================

# --- Очистка экрана
clear

echo "================================================"
echo "     Classic-SIEM - Тестирование Correlator     "
echo "================================================"


# --- Переменые ---
ERRORS=0
ALERT_FILE=""


# --- 1. Проверка: существует ли файл correlator.sh
echo "[1] Проверка наличия файла src/correlator.sh"
if [ -f "src/correlator.sh"  ]
then
   printf "	✅ Файл найден!\n\n"
else
   echo "	❌ Файл не найден!"
   ERRORS=$((ERRORS+1))
fi



# --- 2. Проверка: есть ли права на выполнение
echo "[2] Проверка прав на выполнение"
if [ -x "src/correlator.sh" ]
then
   printf "	✅ Права есть!\n\n"
else
   echo "	❌Прав нет! Добавляю... "
   chmod u+x src/correlator.sh
   if [ -x "src/correlator.sh" ]
   then
      printf "	✅ Права успешно добавлены!\n\n"
   else
      echo "	❌ Права не удалось добавить!"
      ERRORS=$((ERRORS+1))
   fi
fi



# --- 3. Проверка: создаётся ли директория ./alert/ 
echo "[3] Проверка наличия директории для алертов"
if [ -d "alerts"  ]
then
   printf "	✅ Директория alerts/ уже существует.\n\n"
else
   echo "	❌ Директория отсутствует. Будет создана при запуске Correlator"
fi



# --- 4. Проверка установлен ли jq
echo "[4] Проверка наличия jq"
if command -v jq &> /dev/null 
then
   printf "	✅ jq установлен.\n\n"
else
   echo "	❌ jq НЕ установлен."
   echo "	Установите jq: sudo apt install jq -y"
   ERRORS=$((ERRORS+1))
fi



# --- 5. Проверка есть ли нормализованные логи
echo "[5] Проверка наличия нормализованных логов"
if ls ./normalized/normalized_*.json &> /dev/null
then
   printf "	✅ JSON-файлы найдены.\n\n"
else
   echo "	❌ JSON-файлы НЕ найдены."
   echo "	Запустите сначала normalizer.sh"
   ERRORS=$((ERRORS+1))
fi




# --- 6. Запуск коррелятора (весь вывод в > /dev/null)
printf "[6] Запуск correlator.sh\n\n"
./src/correlator.sh > /dev/null 2>&1



# --- 7. Проверка, создался или алерт-файл
echo "[7] Проверка создания алерт-файла"
ALERT_FILE=$(ls -t ./alerts/alerts_*.txt 2>/dev/null | head -n1)
  if [ -f "$ALERT_FILE" ]
  then
	printf "	✅ Алерт-файл создан: $ALERT-FILE.\n\n"
  else
	echo "	❌ Алерт-файл НЕ создан (угроз не обнаружено)."
  fi



# --- 8. Проверка содержимого алерт-файла
if [ -f "$ALERT_FILE" ]
then
   echo "[8] Проверка содержимого алерт-файла"
   if grep -q "ALERT" "$ALERT_FILE"
   then
	echo "	✅ Алерт найден:"
	grep "ALERT" "$ALERT_FILE" | head -3
	echo ""
   else
	echo "	❌ Алертов в файле нет."
   fi
fi



# --- Итог
echo "================================================"
if [ $ERRORS -eq 0 ]
then
   echo " ✅ ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО!"
   echo " Correlator работает корректно."
   echo "================================================"
   echo ""
   exit 0
else
   echo " ❌ Обнаружено ошибок: $ERRORS"
   exit 1
fi














