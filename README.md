# Classic SIEM

**Платформа обнаружения угроз на чистом Bash**

Classic SIEM — это лёгкая, быстрая и прозрачная SIEM-система, написанная на Bash. Она собирает системные логи, приводит их к единому формату и анализирует с помощью правил корреляции для обнаружения атак.

---

## 🚀 Ключевые возможности

- ✅ **Сбор логов** — из `/var/log/auth.log`, `/var/log/syslog` и других источников.
- ⏳ **Нормализация** — приведение логов к единому формату (в разработке).
- 📋 **Корреляция** — обнаружение аномалий на основе правил (в плане).
- 🔔 **Алерты** — уведомления в Telegram (в плане).
- 🧠 **AI-аналитика** — обнаружение аномалий с использованием ИИ (в плане).

---

## 📂 Структура проекта

```text
classic-siem/
├── src/
│   ├── collector.sh        # Сбор логов из /var/log/
│   ├── normalizer.sh       # Нормализация событий (в разработке)
│   └── correlator.sh       # Корреляция и правила (в плане)
├── logs/                   # Собранные логи
├── config/
│   └── settings.conf       # Настройки
└── README.md
```
---

## ⚙️ Быстрый старт
Клонируй репозиторий и запусти сбор логов:

bash
git clone https://github.com/Reitre1/classic-siem.git
cd classic-siem
chmod +x src/collector.sh
./src/collector.sh


## 📌 Статус разработки
Модуль	Статус
Collector	✅ Готов
Normalizer	⏳ В разработке
Correlator	📋 Запланирован
Alerter	📋 Запланирован
Web-интерфейс	📋 Запланирован

---


## 📬 Контакты
- **Сайт:** [classic-siem.ru](https://classic-siem.ru)  
- **Почта:** [support@classic-siem.ru](mailto:support@classic-siem.ru)  
- **VK:** [SIEM Navigation](https://vk.com/cyber_siem)  
- **Дзен:** [Канал на Дзен](https://dzen.ru/a/akZNi6H1F0km-5yk)  
- **GitHub:** [Reitre1/classic-siem](https://github.com/Reitre1/classic-siem)



📜 Лицензия
Проект распространяется под лицензией GNU General Public License v3.0.
