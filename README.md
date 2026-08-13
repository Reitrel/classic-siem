# Classic SIEM

**Платформа обнаружения угроз на Bash и AWK**

Classic SIEM — это лёгкая, быстрая и прозрачная SIEM-система, написанная на Bash. Она собирает системные логи, приводит их к единому формату и анализирует с помощью правил корреляции для обнаружения атак.

---

## 🚀 Ключевые возможности

- ✅ **Сбор логов** — из `/var/log/auth.log`, `/var/log/syslog` и других источников (модуль Collector)
- ✅ **Нормализация** — приведение логов к единому формату JSON (AWK, **1M+ строк/сек**)
- 📋 **Корреляция** — обнаружение аномалий на основе правил (в плане)
- 🔔 **Алерты** — уведомления в Telegram (в плане)
- 🧠 **AI-аналитика** — обнаружение аномалий с использованием ИИ (в плане)

---

## 🛠 Технологии

- **Bash** — управление модулями, автоматизация
- **AWK** — высокопроизводительный парсер логов (1M+ строк/сек)
- **Linux** — системные логи, среда выполнения
- **Git** — контроль версий

---

## 📂 Структура проекта

```text
classic-siem/
├── demo/                   # Демонстрационное видео работы
│   └── collector_demo.wmv
├── screenshots/            # Скриншоты интерфейса и тестов
│   ├── 01_welcome.png
│   ├── 02_progress.png
│   ├── 03_stats.png
│   ├── 04_stats.png
│   ├── 05_complete.png
│   ├── 06_logs_sample.png
│   └── 07_test_collector.png
├── src/                    # Исходный код модулей
│   ├── collector.sh        # ✅ Сбор логов из /var/log/
│   └── normalizer.sh       # ✅ Нормализация в JSON (AWK, 1M+ строк/сек)
├── tests/                  # Автоматические тесты
│   └── test_collector.sh   # Тесты для проверки collector.sh
├── logs/                   # Собранные логи (игнорируется Git)
├── config/
│   └── settings.conf       # Настройки (в плане)
├── .gitignore              # Файлы, исключённые из Git
├── LICENSE                 # GNU General Public License v3.0
└── README.md               # Описание проекта
```

---

## ⚙️ Быстрый старт
Клонируй репозиторий и запусти сбор логов:

```Bash
git clone https://github.com/Reitrel/classic-siem.git
cd classic-siem
chmod +x src/collector.sh
./src/collector.sh
```

---

## 📌 Статус разработки

| Модуль | Статус | Производительность |
|--------|--------|-------------------|
| Collector | ✅ Готов | — |
| Normalizer | ✅ Готов (v0.2.0) | **~1 182 000 строк/сек** |
| Correlator | 📋 Запланирован | — |
| Alerter | 📋 Запланирован | — |
| Web-интерфейс | 📋 Запланирован | — |

---

## 🧪 Тестирование
Проект включает автоматические тесты для проверки работоспособности модулей. 

### Что проверяется
Тест _test_collector.sh_ выполняет следующие проверки: 

|№  | Проверка | Что делает |
|:---:|----------|------------|
|1	|Наличие файла |	Проверяет, существует ли src/collector.sh |
|2	|Права на выполнение |	Проверяет, есть ли у файла права +x. Если нет — добавляет |
|3	|Директория для логов |	Проверяет, существует ли папка logs/. Если нет — будет создана при запуске |
|4	|Создание лог-файла |	Запускает collector.sh и проверяет, что создался файл с логами |

### Запуск тестов
```Bash
cd classic-siem
./tests/test_collector.sh
```

### Ожидаемый результат 

Все проверки должны быть пройдены успешно: 

[Скриншот результата ](https://github.com/Reitrel/classic-siem/blob/main/screenshots/07_test_collector.png)

Если какая-то проверка не пройдена — тест укажет на проблему и завершится с кодом ошибки. 

---

## 📸 Демонстрация работы модуля **collector.sh**

### 1. Приветственное окно: 
![Приветствие](https://github.com/Reitrel/classic-siem/blob/main/screenshots/01_welcome.png)  
### 2. Прогресс сбора логов: 
![Прогресс сбора](https://github.com/Reitrel/classic-siem/blob/main/screenshots/02_progress.png)  
### 3. Статистика по данным: 
![Статистика](https://github.com/Reitrel/classic-siem/blob/main/screenshots/03_stats.png)  
### 4. Статистика по файлам: 
![Статистика](https://github.com/Reitrel/classic-siem/blob/main/screenshots/04_stats.png)  
### 5. Завершение работы: 
![Завершение](https://github.com/Reitrel/classic-siem/blob/main/screenshots/05_complete.png)  
### 6. Пример собранных логов: 
![Пример логов](https://github.com/Reitrel/classic-siem/blob/main/screenshots/06_logs_sample.png)  

## 🎥 Видиодемонстрация модуля **collector.sh**

[Видео: работа Classic SIEM Collector](https://github.com/Reitrel/classic-siem/blob/main/demo/collector_demo.wmv)

---

## 📸 Демонстрация работы **Normalizer.sh**

### 1. Запуск Normalizer
![Запуск Normalizer](screenshots/normalizer_start.png)

### 2. Результат работы Normalizer
![Результат Normalizer](screenshots/normalizer_result.png)

---

## 📬 Контакты 
**Сайт**: classic-siem.ru  
__Почта:__ support@classic-siem.ru  
**VK:** SIEM Navigation  
**Дзен:** Канал на Дзен  
**GitHub:** Reitrel/classic-siem  


---

## 📜 Лицензия
Проект распространяется под лицензией GNU General Public License v3.0.

> Сделано на Bash. Для тех, кто ценит скорость и контроль.


---

