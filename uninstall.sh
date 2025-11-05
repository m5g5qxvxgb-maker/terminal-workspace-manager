#!/bin/bash

# Terminal Workspace Manager - Uninstall Script
# Version: 2.0.0
# License: MIT

set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║   🗑️  Terminal Workspace Manager - Деинсталляция         ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Пожалуйста, запустите скрипт с sudo"
    exit 1
fi

read -p "⚠️  Вы уверены, что хотите удалить Terminal Workspace Manager? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Деинсталляция отменена"
    exit 0
fi

echo ""
read -p "💾 Сохранить данные рабочих столов? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    BACKUP_FILE="$HOME/terminal-workspace-backup-$(date +%Y%m%d-%H%M%S).json"
    if [ -f /var/www/terminal/data/workspaces.json ]; then
        cp /var/www/terminal/data/workspaces.json "$BACKUP_FILE"
        echo "✅ Данные сохранены: $BACKUP_FILE"
    else
        echo "⚠️  Файл данных не найден"
    fi
fi

echo ""
echo "🛑 Остановка сервисов..."
systemctl stop terminal-manager 2>/dev/null || true
systemctl stop workspace-sync 2>/dev/null || true
systemctl stop terminal-titles 2>/dev/null || true

echo "🗑️  Отключение автозапуска..."
systemctl disable terminal-manager 2>/dev/null || true
systemctl disable workspace-sync 2>/dev/null || true
systemctl disable terminal-titles 2>/dev/null || true

echo "📄 Удаление systemd сервисов..."
rm -f /etc/systemd/system/terminal-manager.service
rm -f /etc/systemd/system/workspace-sync.service
rm -f /etc/systemd/system/terminal-titles.service
systemctl daemon-reload

echo "🔧 Удаление скриптов..."
rm -f /usr/local/bin/start-terminal-services.sh
rm -f /usr/local/bin/stop-terminal-services.sh
rm -f /usr/local/bin/update-terminal-titles.sh

echo "🌐 Удаление конфигурации nginx..."
rm -f /etc/nginx/sites-enabled/terminal-manager
rm -f /etc/nginx/sites-available/terminal-manager
systemctl reload nginx 2>/dev/null || true

echo "📁 Удаление файлов..."
rm -rf /var/www/terminal

echo "🧹 Удаление tmux сессий..."
for session in $(tmux list-sessions 2>/dev/null | grep "terminal-" | cut -d: -f1); do
    tmux kill-session -t "$session" 2>/dev/null || true
done

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║           ✅ ДЕИНСТАЛЛЯЦИЯ ЗАВЕРШЕНА УСПЕШНО! ✅         ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
if [ -n "$BACKUP_FILE" ] && [ -f "$BACKUP_FILE" ]; then
    echo "💾 Резервная копия данных: $BACKUP_FILE"
    echo ""
fi
echo "📦 Установленные зависимости не удалены:"
echo "   - tmux, nginx, nodejs, ttyd"
echo ""
echo "Для удаления зависимостей выполните:"
echo "   sudo apt remove --purge tmux nginx nodejs ttyd"
echo "   sudo apt autoremove"
echo ""
