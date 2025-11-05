#!/bin/bash

# Terminal Workspace Manager - Installation Script
# Version: 2.0.0
# License: MIT

set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║   🖥️  Terminal Workspace Manager - Установка             ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Пожалуйста, запустите скрипт с sudo"
    exit 1
fi

# Check OS
if [ ! -f /etc/os-release ]; then
    echo "❌ Не удалось определить операционную систему"
    exit 1
fi

. /etc/os-release
echo "📋 Обнаружена ОС: $NAME $VERSION"
echo ""

# Check dependencies
echo "🔍 Проверка зависимостей..."
MISSING_DEPS=()

if ! command -v tmux &> /dev/null; then
    MISSING_DEPS+=("tmux")
fi

if ! command -v nginx &> /dev/null; then
    MISSING_DEPS+=("nginx")
fi

if ! command -v node &> /dev/null; then
    MISSING_DEPS+=("nodejs")
fi

if ! command -v ttyd &> /dev/null; then
    MISSING_DEPS+=("ttyd")
fi

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo "⚠️  Не установлены зависимости: ${MISSING_DEPS[*]}"
    echo ""
    read -p "Установить недостающие пакеты? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 Установка зависимостей..."
        apt update
        apt install -y tmux nginx nodejs npm git curl
        
        # Install ttyd
        if ! command -v ttyd &> /dev/null; then
            echo "📥 Установка ttyd..."
            if apt install -y ttyd 2>/dev/null; then
                echo "✅ ttyd установлен из репозитория"
            else
                echo "📥 Скачивание ttyd из GitHub..."
                wget -q https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 -O /usr/local/bin/ttyd
                chmod +x /usr/local/bin/ttyd
                echo "✅ ttyd установлен из GitHub"
            fi
        fi
    else
        echo "❌ Установка прервана"
        exit 1
    fi
else
    echo "✅ Все зависимости установлены"
fi

echo ""
echo "📁 Создание директорий..."
mkdir -p /var/www/terminal/data
chmod 755 /var/www/terminal/data

echo "📄 Копирование веб-файлов..."
cp web/* /var/www/terminal/
chown -R www-data:www-data /var/www/terminal

echo "🔧 Установка скриптов..."
cp scripts/*.sh /usr/local/bin/
chmod +x /usr/local/bin/*.sh

echo "⚙️  Установка systemd сервисов..."
cp systemd/*.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable terminal-manager workspace-sync terminal-titles

echo "🌐 Настройка nginx..."
cp nginx/terminal-manager.conf /etc/nginx/sites-available/terminal-manager

# Ask for IP or domain
echo ""
read -p "Введите IP адрес или домен сервера (Enter для автоопределения): " SERVER_IP
if [ -z "$SERVER_IP" ]; then
    # Try to detect IP
    SERVER_IP=$(hostname -I | awk '{print $1}')
    echo "🔍 Автоопределен IP: $SERVER_IP"
fi

echo "📝 Обновление конфигурации..."
# No need to update nginx config as it already listens on all interfaces

# Enable nginx site
if [ -L /etc/nginx/sites-enabled/terminal-manager ]; then
    rm /etc/nginx/sites-enabled/terminal-manager
fi
ln -s /etc/nginx/sites-available/terminal-manager /etc/nginx/sites-enabled/

echo "✅ Проверка конфигурации nginx..."
if nginx -t 2>&1 | grep -q "successful"; then
    echo "✅ Конфигурация nginx корректна"
else
    echo "❌ Ошибка в конфигурации nginx"
    nginx -t
    exit 1
fi

echo ""
echo "🚀 Запуск сервисов..."
systemctl start terminal-manager
sleep 2
systemctl start workspace-sync
systemctl start terminal-titles
systemctl reload nginx

echo ""
echo "🔍 Проверка статуса сервисов..."
SERVICES_OK=true

if systemctl is-active --quiet terminal-manager; then
    echo "✅ terminal-manager: запущен"
else
    echo "❌ terminal-manager: не запущен"
    SERVICES_OK=false
fi

if systemctl is-active --quiet workspace-sync; then
    echo "✅ workspace-sync: запущен"
else
    echo "❌ workspace-sync: не запущен"
    SERVICES_OK=false
fi

if systemctl is-active --quiet terminal-titles; then
    echo "✅ terminal-titles: запущен"
else
    echo "❌ terminal-titles: не запущен"
    SERVICES_OK=false
fi

if systemctl is-active --quiet nginx; then
    echo "✅ nginx: запущен"
else
    echo "❌ nginx: не запущен"
    SERVICES_OK=false
fi

echo ""
if [ "$SERVICES_OK" = true ]; then
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║              ✅ УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО! ✅          ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    echo "🌐 Откройте в браузере:"
    echo "   http://$SERVER_IP:8888"
    echo ""
    echo "📖 Документация:"
    echo "   README.md в директории проекта"
    echo ""
    echo "🛠️  Управление сервисами:"
    echo "   sudo systemctl status terminal-manager"
    echo "   sudo systemctl restart terminal-manager"
    echo "   sudo journalctl -u terminal-manager -f"
    echo ""
    echo "💡 Рекомендации:"
    echo "   - Установите GitHub Copilot CLI для AI помощи"
    echo "   - Настройте Tailscale для безопасного доступа"
    echo "   - Добавьте firewall правила"
    echo ""
else
    echo "⚠️  УСТАНОВКА ЗАВЕРШЕНА С ПРЕДУПРЕЖДЕНИЯМИ"
    echo ""
    echo "Некоторые сервисы не запустились. Проверьте логи:"
    echo "   sudo journalctl -xe"
    echo ""
fi

# Check if Copilot is installed
echo "📋 Проверка GitHub Copilot CLI..."
if command -v github-copilot-cli &> /dev/null; then
    echo "✅ GitHub Copilot CLI установлен"
else
    echo "⚠️  GitHub Copilot CLI не установлен"
    echo ""
    read -p "Установить GitHub Copilot CLI? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 Установка GitHub Copilot CLI..."
        npm install -g @githubnext/github-copilot-cli
        echo ""
        echo "🔐 Теперь нужно авторизоваться:"
        echo "   github-copilot-cli auth"
        echo ""
        echo "И добавить алиас в ~/.bashrc:"
        echo '   echo '\''eval "$(github-copilot-cli alias -- "$0")"'\'' >> ~/.bashrc'
        echo "   source ~/.bashrc"
    fi
fi

echo ""
echo "🎉 Готово! Приятной работы!"
