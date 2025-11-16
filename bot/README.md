# 🤖 FinTrack Telegram Bot

Telegram бот для мини-приложения FinTrack.

## 📋 Описание

Бот обрабатывает команды и открывает соответствующие страницы Mini App. Реализован **Вариант 1 (МИНИМАЛЬНЫЙ)** из [TELEGRAM_BOT_COMMANDS.md](../TELEGRAM_BOT_COMMANDS.md).

## ✨ Реализованные команды

- `/start` — Запуск приложения с приветствием
- `/add` — Открывает страницу добавления операции
- `/accounts` — Управление счетами
- `/history` — История операций
- `/analytics` — Детальная аналитика
- `/settings` — Настройки приложения
- `/help` — Список команд

## 🚀 Установка и запуск

### 1. Установка зависимостей

```bash
cd bot
pip install -r requirements.txt
```

### 2. Настройка переменных окружения

Создайте файл `.env` на основе `.env.example`:

```bash
cp .env.example .env
```

Заполните переменные:
- `TELEGRAM_BOT_TOKEN` — токен бота от [@BotFather](https://t.me/BotFather)
- `WEBAPP_URL` — URL развернутого фронтенда (по умолчанию: https://wisetrack21.site/)

### 3. Запуск бота

```bash
python bot.py
```

Бот должен вывести:
```
🤖 Бот FinTrack запущен!
🌐 WebApp URL: https://wisetrack21.site/
```

## 🔧 Настройка команд в BotFather

Отправьте [@BotFather](https://t.me/BotFather) команду `/setcommands` и вставьте:

```
start - Запустить FinTrack
add - Добавить операцию
accounts - Управление счетами
history - История операций
analytics - Детальная аналитика
settings - Настройки
help - Справка
```

## 🌐 Настройка Menu Button

Для добавления кнопки "Открыть FinTrack" в поле ввода:

1. Отправьте [@BotFather](https://t.me/BotFather) команду `/setmenubutton`
2. Выберите вашего бота
3. Введите текст: `Открыть FinTrack`
4. Введите URL: `https://wisetrack21.site/`

## 📦 Deployment

Для продакшн-использования бот должен работать 24/7. Варианты:

### VPS (рекомендуется)
```bash
# Установка зависимостей
apt update && apt install python3 python3-pip -y
pip3 install -r requirements.txt

# Запуск с systemd
sudo nano /etc/systemd/system/fintrack-bot.service
```

Содержимое service файла:
```ini
[Unit]
Description=FinTrack Telegram Bot
After=network.target

[Service]
Type=simple
User=yourusername
WorkingDirectory=/path/to/fintrack/bot
ExecStart=/usr/bin/python3 bot.py
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable fintrack-bot
sudo systemctl start fintrack-bot
sudo systemctl status fintrack-bot
```

### Railway / Heroku
Добавьте `Procfile`:
```
worker: python bot.py
```

## 📝 Структура проекта

```
bot/
├── bot.py              # Основной файл с обработчиками команд
├── requirements.txt    # Зависимости Python
├── .env               # Конфигурация (не коммитится)
├── .env.example       # Пример конфигурации
└── README.md          # Эта документация
```

## 🔗 Связанные файлы

- [TELEGRAM_BOT_COMMANDS.md](../TELEGRAM_BOT_COMMANDS.md) — полная документация по командам
- [api/app/services/telegram_service.rb](../api/app/services/telegram_service.rb) — интеграция для отправки документов

## 🛠️ Разработка

Для тестирования локально:

```bash
# Установка в режиме разработки
pip install -r requirements.txt

# Запуск
python bot.py
```

Для расширенного функционала (Вариант 2 с API интеграцией) см. [TELEGRAM_BOT_COMMANDS.md](../TELEGRAM_BOT_COMMANDS.md).

## 📊 Версия

- **Версия:** 1.0 (МИНИМАЛЬНЫЙ ВАРИАНТ)
- **aiogram:** 3.15.0
- **Python:** 3.8+

## 💡 Дальнейшее развитие

Для реализации Варианта 2 (расширенного) потребуется:
- HTTP клиент для запросов к Rails API
- Форматирование текстовых ответов
- Обработка callback queries
- Inline-кнопки с действиями

См. детали в [TELEGRAM_BOT_COMMANDS.md](../TELEGRAM_BOT_COMMANDS.md#-вариант-2-расширенный-для-будущих-версий).
