#!/bin/bash

# ============================================================
# Classic SIEM — Установочный скрипт
# Назначение: установка systemd-таймера и настройка окружения
# Автор: Денис Алексеев / Classic SIEM
# ============================================================

clear

echo "[INFO]: Установка Classic-SIEM..."

# Проверка прав (требуется sudo)
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR]: Запустите скрипт с sudo: sudo ./install.sh"
    exit 1
fi

# --- 1. Копируем systemd-файлы ---
echo "[INFO]: Копирую systemd-файлы..."
cp systemd/classic-siem.service /etc/systemd/system/
cp systemd/classic-siem.timer /etc/systemd/system/

# --- 2. Перезагружаем конфигурацию systemd ---
echo "[INFO]: Перезагружаю конфигурацию systemd..."
systemctl daemon-reload

# --- 3. Включаем и запускаем таймер ---
echo "[INFO]: Включаю и запускаю таймер..."
systemctl enable classic-siem.timer
systemctl start classic-siem.timer

# --- 4. Проверяем статус ---
echo "[INFO]: Статус таймера:"
systemctl status classic-siem.timer --no-pager

echo "[INFO]: Установка завершена."
