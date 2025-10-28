# Quick Start Guide - Punk_OS

Welcome! This guide helps you quickly access documentation for your Punk_OS development environment.

## 📖 How to Access Documentation

### Option 1: Man Page (Recommended)
The fastest way to get help - works offline from anywhere:

```bash
man punk_os
```

This gives you instant access to:
- Installation options and examples
- Version manager commands (nvm, pyenv, rustup, Go)
- Docker and PostgreSQL setup
- CLI tool usage examples
- Troubleshooting guides

**Navigation Tips:**
- Press `Space` to page down, `b` to page up
- Press `/` to search, then type your search term
- Press `q` to quit
- Press `h` for help

### Option 2: Installation Reference
See exactly what's installed on your system:

```bash
./check-installed.sh
cat INSTALLED.md
```

This generates a comprehensive report including:
- All installed software with versions
- Installation locations
- Status of each component
- Quick reference commands

### Option 3: Full README
For detailed information about all features:

```bash
cat README.md
# or open it in your editor/browser
```

## 🚀 First-Time Setup

```bash
# 1. Run the setup script
./setup.sh

# 2. Follow the prompts (or use -y for automatic installation)
./setup.sh -y

# 3. After installation, view what was installed
./check-installed.sh

# 4. Access the manual anytime
man punk_os
```

## 🔧 Common Commands After Installation

### Version Managers

```bash
# Node.js (nvm)
nvm list                    # See installed versions
nvm install node            # Install latest
nvm use 18                  # Switch to version 18

# Python (pyenv)
pyenv versions              # See installed versions
pyenv install 3.12.0        # Install Python 3.12
pyenv global 3.12.0         # Set as default

# Rust (rustup)
rustup update               # Update Rust
rustup show                 # Show toolchains

# Go
go version                  # Check version
```

### Docker

```bash
docker ps                   # List containers
docker images               # List images
docker compose up -d        # Start services
docker compose down         # Stop services
```

### Database (PostgreSQL)

```bash
sudo systemctl status postgresql    # Check status
sudo -u postgres psql               # Access PostgreSQL
```

## 📚 Documentation Hierarchy

1. **Quick Help**: `man punk_os` - Fast reference, always available
2. **What's Installed**: `./check-installed.sh` - Current system state
3. **Full Guide**: `README.md` - Complete documentation
4. **Man Page Guide**: `MAN_PAGE_GUIDE.md` - How to use/update man pages

## ❓ Getting Help

### For specific tools:
```bash
man docker              # Docker manual
man git                 # Git manual
node --help             # Node.js help
python3 --help          # Python help
```

### For Punk_OS features:
```bash
man punk_os             # Full Punk_OS manual
./setup.sh --help       # Setup script options
```

### Search the man page:
```bash
# Open man page and search for "docker"
man punk_os
# Then press '/' and type 'docker'
```

## 🎯 Quick Reference

| What You Need | Command |
|---------------|---------|
| **Full manual** | `man punk_os` |
| **What's installed** | `./check-installed.sh` |
| **Install software** | `./setup.sh` |
| **Install man page only** | `./install-manpage.sh` |
| **Setup help** | `./setup.sh --help` |
| **Automated install** | `./setup.sh -y` |

## 💡 Pro Tips

1. **Always check the man page first**: `man punk_os` is faster than searching online
2. **Generate installation reports**: Keep track of what's on each machine with `./check-installed.sh`
3. **Use search in man pages**: Press `/` while viewing to find specific topics
4. **Bookmark important sections**: The man page has clear section headers for easy navigation
5. **Keep documentation handy**: The man page works offline - perfect for travel or limited connectivity

## 🔄 Updating Documentation

After installing new software or making changes:

```bash
# Regenerate what's installed
./check-installed.sh

# If you've updated the man page source
./install-manpage.sh
```

## 📍 Where Everything Lives

| Item | Location |
|------|----------|
| **Setup script** | `./setup.sh` |
| **Check installed** | `./check-installed.sh` |
| **Man page source** | `./punk_os.1` |
| **Installed man page** | `/usr/local/man/man1/punk_os.1` |
| **Generated report** | `./INSTALLED.md` |
| **Projects directory** | `~/Projects` |
| **Shell config** | `~/.bashrc` or `~/.zshrc` |

## 🎓 Next Steps

1. ✅ Run `man punk_os` to familiarize yourself with available commands
2. ✅ Generate your installation report: `./check-installed.sh`
3. ✅ Set up your first project in `~/Projects`
4. ✅ Configure your shell and editor preferences
5. ✅ Install language-specific tools as needed

---

**Remember**: The documentation is always at your fingertips with `man punk_os`! 🚀