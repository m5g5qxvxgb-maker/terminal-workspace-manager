# 📤 Инструкция по загрузке на GitHub

## Шаг 1: Создайте репозиторий на GitHub

1. Откройте https://github.com/new
2. Введите название: `terminal-workspace-manager`
3. Описание: `Modern web interface for terminal workspace management with cloud sync`
4. Выберите **Public** (чтобы друг мог скачать)
5. **НЕ** добавляйте README, .gitignore или LICENSE (они уже есть)
6. Нажмите **Create repository**

## Шаг 2: Загрузите код

После создания репозитория GitHub покажет инструкции. Выполните:

```bash
cd /root/terminal-workspace-manager

# Добавьте remote (замените YOUR_USERNAME на ваш username)
git remote add origin https://github.com/YOUR_USERNAME/terminal-workspace-manager.git

# Переименуйте ветку в main (опционально)
git branch -M main

# Загрузите код
git push -u origin main
```

### Альтернатива: через SSH

Если у вас настроен SSH ключ:

```bash
git remote add origin git@github.com:YOUR_USERNAME/terminal-workspace-manager.git
git branch -M main
git push -u origin main
```

### Если возникла ошибка авторизации

Используйте Personal Access Token:

1. Перейдите: https://github.com/settings/tokens
2. Нажмите **Generate new token (classic)**
3. Выберите scope: `repo`
4. Скопируйте токен
5. Используйте его вместо пароля при push

```bash
# При запросе пароля вставьте токен
git push -u origin main
```

## Шаг 3: Дайте ссылку другу

После загрузки отправьте другу ссылку:

```
https://github.com/YOUR_USERNAME/terminal-workspace-manager
```

Ваш друг сможет установить проект командой:

```bash
git clone https://github.com/YOUR_USERNAME/terminal-workspace-manager.git
cd terminal-workspace-manager
sudo ./install.sh
```

## Шаг 4: Улучшите README (опционально)

Замените `YOUR_USERNAME` на свой username в README.md:

```bash
sed -i 's/YOUR_USERNAME/your-actual-username/g' README.md
git add README.md
git commit -m "Update username in README"
git push
```

## Шаг 5: Добавьте topics на GitHub

На странице репозитория нажмите ⚙️ **Settings** → **Topics** и добавьте:
- `terminal`
- `tmux`
- `workspace-manager`
- `web-terminal`
- `github-copilot`
- `cloud-sync`
- `nodejs`
- `nginx`

## Дополнительно: Создайте Release

1. Перейдите на вкладку **Releases**
2. Нажмите **Create a new release**
3. Tag: `v2.0.0`
4. Title: `Terminal Workspace Manager v2.0.0`
5. Description: скопируйте основные возможности из README
6. Нажмите **Publish release**

## Быстрая команда (всё в одном)

Замените `YOUR_USERNAME` и выполните:

```bash
cd /root/terminal-workspace-manager
git remote add origin https://github.com/YOUR_USERNAME/terminal-workspace-manager.git
git branch -M main
git push -u origin main
echo ""
echo "✅ Проект загружен на GitHub!"
echo "📎 Ссылка: https://github.com/YOUR_USERNAME/terminal-workspace-manager"
```

## Проблемы?

### Ошибка: remote origin already exists

```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/terminal-workspace-manager.git
git push -u origin main
```

### Ошибка: fatal: refusing to merge unrelated histories

```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

### Нужно изменить username в истории

```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
git commit --amend --reset-author --no-edit
git push -f origin main
```

---

**Готово! Теперь проект доступен на GitHub!** 🎉
