# Punk_OS Setup Script

A comprehensive development environment setup script for Pop!_OS and Ubuntu-based distributions that transforms your fresh installation into a fully-equipped development machine.

## Overview

The `setup.sh` script is an interactive installer that helps you quickly set up a complete development environment on Pop!_OS. It includes development tools, programming languages, IDEs, productivity applications, and system optimizations commonly needed by developers.

## Quick Start

```bash
# Clone or download the setup script
wget https://raw.githubusercontent.com/your-repo/punk_os/main/setup.sh

# Make it executable
chmod +x setup.sh

# Run the script interactively
./setup.sh

# Or run non-interactively (auto-accept all prompts)
./setup.sh -y
```

**Important:** Do NOT run this script with `sudo`. The script will prompt for your password when elevated privileges are needed.

## Quick Reference

After installation, you can access comprehensive documentation anytime:

```bash
# View the manual page (installed automatically)
man punk_os

# Generate a list of what's installed on your system
./check-installed.sh
cat INSTALLED.md
```

The man page provides instant offline access to:
- All available installation options
- Usage examples for version managers (nvm, pyenv, rustup)
- Docker, PostgreSQL, and database setup commands
- CLI tool examples (jq, ripgrep, fzf, etc.)
- Troubleshooting guides
- Quick reference commands

## Available Tools

This repository includes three main tools:

1. **setup.sh** - Interactive installer for development environment
2. **check-installed.sh** - Generate a reference manual of installed software
3. **install-manpage.sh** - Install the `punk_os` man page (also done automatically by setup.sh)

## Command Line Options

### setup.sh
- **Interactive Mode** (default): `./setup.sh` - Prompts for each installation step
- **Non-Interactive Mode**: `./setup.sh -y` or `./setup.sh --yes` - Automatically accepts all prompts
- **Help**: `./setup.sh -h` or `./setup.sh --help` - Shows usage information

### check-installed.sh
```bash
./check-installed.sh                  # Generate INSTALLED.md
./check-installed.sh my-system.md     # Generate with custom filename
```

### install-manpage.sh
```bash
./install-manpage.sh                  # Install man page for 'man punk_os' command
```

## What Does This Script Do?

The setup script is fully interactive - you'll be prompted before each installation step, allowing you to customize your setup. Here's what it can install and configure:

### 🔧 System Updates & Essential Tools

- **System Package Updates**: Updates all system packages to latest versions
- **Build Essentials**: Essential development tools including:
  - `build-essential` (GCC, G++, make, etc.)
  - `git` - Version control
  - `curl` & `wget` - Download tools
  - `vim` & `neovim` - Text editors
  - `htop` - System monitor
  - `tmux` - Terminal multiplexer
  - `zsh` - Advanced shell
  - `timeshift` - System backups
  - `net-tools` - Network utilities

### ⚡ System Optimizations

- **File Watcher Limits**: Increases `inotify` file watchers for development tools (VS Code, webpack, etc.)
- **SSD Optimization**: Enables `fstrim` timer for better SSD performance and longevity

### 🛠️ Modern CLI Tools

Replaces traditional Unix tools with modern, faster alternatives:

- **`bat`** - Syntax-highlighted `cat` replacement
- **`fzf`** - Fuzzy finder for files and command history
- **`ripgrep` (rg)** - Ultra-fast grep alternative
- **`fd`** - Fast and user-friendly `find` replacement
- **`tldr`** - Simplified man pages with practical examples

### 🔧 Essential Developer Utilities

- **`jq`** - Command-line JSON processor (essential for API work)
- **`tree`** - Display directory structures in tree format
- **`httpie`** - User-friendly HTTP client for API testing

### 📦 Archive & Compression Tools

- **`zip/unzip`** - ZIP archive support
- **`p7zip-full`** - 7-Zip compression with full format support
- **`unrar`** - RAR archive extraction

### 🐳 Containerization

- **Docker**: Complete Docker installation with:
  - Docker Engine
  - Docker Compose
  - BuildKit support
  - User added to docker group (no sudo required)

### 🌐 Node.js Development

- **Node Version Manager (nvm)**: Manage multiple Node.js versions
- **Node.js LTS**: Latest Long Term Support version installed by default

### 🐍 Python Development

- **Python Tools**: 
  - `python3-pip` - Package installer
  - `python3-venv` - Virtual environments
  - `python3-dev` - Development headers
- **pyenv**: Python version manager for multiple Python versions

### 🦀 Rust Development

- **Rust Toolchain**: Complete Rust installation via rustup
- **Cargo**: Rust package manager included

### 🐹 Go Development

- **Go (Golang)**: Latest stable Go compiler and toolchain
- **GOPATH**: Automatically configured with `~/go` workspace
- **Tools**: Access to `go build`, `go run`, `go get`, etc.

### 💻 IDEs & Editors

- **Visual Studio Code**: Microsoft's popular code editor
- **Zed IDE**: Fast, modern code editor built in Rust
- **Alacritty**: GPU-accelerated terminal emulator

### 🔤 Developer Fonts

Professional coding fonts with ligature support:

- **JetBrains Mono**: Clean, modern monospaced font
- **Fira Code**: Popular font with programming ligatures
- **Cascadia Code**: Microsoft's developer font with ligatures

### 🐚 Shell Enhancement

- **Oh My Zsh**: Feature-rich Zsh framework with:
  - `zsh-autosuggestions` - Command suggestions
  - `zsh-syntax-highlighting` - Syntax highlighting
  - Zsh set as default shell

### 🗂️ Development Setup

- **Projects Directory**: Creates `~/Projects` for organizing code
- **Shell Configuration**: Adds useful aliases and environment variables:
  - `ll='ls -lah'`
  - `gs='git status'`
  - `gp='git pull'`
  - `dc='docker-compose'`
  - `nv='nvim'`

### 🎨 GNOME Extensions

- **Caffeine**: Prevents screen from going to sleep
- **System Monitor**: Shows system resources in top bar

### 📱 Productivity Applications

- **Communication**: Discord, Slack, Zoom
- **Media**: Spotify, VLC Media Player
- **Note-taking**: Obsidian
- **Screen Recording**: OBS Studio
- **Web Browser**: Chromium

### 🛠️ API Development Tools

- **Postman**: Popular API testing tool
- **Bruno**: Open-source API client alternative
- **HTTPie**: Command-line HTTP client with intuitive syntax

### 📸 Screenshot Tools

- **Flameshot**: Advanced screenshot tool with annotation features

### 🗄️ Database

- **PostgreSQL**: Full PostgreSQL installation with contrib packages

## Usage Examples

### Interactive Mode (Default)

The script is interactive by default, so you can skip any sections you don't need:

```bash
./setup.sh
# Answer 'y' for items you want, 'n' for items you want to skip
```

### Non-Interactive Mode

For automated setups or when you want to install everything:

```bash
./setup.sh -y
# Automatically installs all available packages without prompting
```

This is useful for:
- Automated deployments
- Setting up multiple machines
- CI/CD environments
- When you want a complete development environment

### Post-Installation Steps

After running the script, you'll need to:

1. **Log out and back in** (or reboot) for all changes to take effect
2. **Configure GNOME Extensions** using GNOME Tweaks
3. **Set up your terminal** (Alacritty config at `~/.config/alacritty/alacritty.yml`)
4. **Configure your dotfiles** repository if you have one

### Version Managers Usage

**Node.js with nvm:**
```bash
nvm install node          # Install latest Node.js
nvm install --lts         # Install LTS version
nvm use 18                # Switch to Node.js 18
nvm list                  # List installed versions
```

**Python with pyenv:**
```bash
pyenv install 3.12.0      # Install Python 3.12.0
pyenv global 3.12.0       # Set as global version
pyenv versions            # List installed versions
```

**Rust with rustup:**
```bash
rustup update             # Update Rust
rustup install stable     # Install stable toolchain
cargo --version           # Check Cargo version
```

**Go:**
```bash
go version                # Check Go version
go get github.com/user/pkg # Install a package
go build                  # Compile current package
go run main.go            # Run a Go file
```

### Docker Usage

```bash
# Test Docker installation (no sudo needed after relogin)
docker run hello-world

# Use Docker Compose
docker compose up -d

# Build with BuildKit (faster builds)
docker build --progress=plain .
```

### PostgreSQL Setup

```bash
# Access PostgreSQL as postgres user
sudo -u postgres psql

# Create your user and database
CREATE USER yourusername WITH PASSWORD 'yourpassword';
CREATE DATABASE yourdb OWNER yourusername;

# Enable and start PostgreSQL service
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

### Developer Tools Usage

```bash
# JSON processing with jq
cat data.json | jq '.users[] | .name'
curl -s https://api.example.com/data | jq '.'

# View directory structure with tree
tree -L 2                 # Show 2 levels deep
tree -I 'node_modules'    # Ignore node_modules

# HTTP requests with HTTPie
http GET https://api.example.com/users
http POST api.example.com/users name=John email=john@example.com

# Screenshots with Flameshot
flameshot gui             # Open screenshot tool
flameshot full -p ~/Pictures  # Capture entire screen

# Archive operations
zip -r archive.zip folder/
unzip archive.zip
7z a archive.7z folder/   # Create 7z archive
7z x archive.7z           # Extract 7z archive
```

### Using Developer Fonts

After installation, configure your terminal or editor to use the new fonts:

**VS Code** (`settings.json`):
```json
{
  "editor.fontFamily": "'JetBrains Mono', 'Fira Code', monospace",
  "editor.fontLigatures": true
}
```

**Alacritty** (`~/.config/alacritty/alacritty.yml`):
```yaml
font:
  normal:
    family: "JetBrains Mono"
  size: 12.0
```

**GNOME Terminal**: Edit → Preferences → Your Profile → Custom Font → Select font

## Customization

### Modifying the Script

The script is designed to be easily customizable. Each installation section is wrapped in an `if prompt_install` block, making it easy to:

- Add new software installations
- Modify existing installations
- Remove sections you don't need

### Shell Configuration

The script adds configurations to `~/.bashrc`. You can customize these by editing the file after installation or modifying the script before running.

## Troubleshooting

### Common Issues

**Docker Permission Denied:**
- Log out and back in for group changes to take effect
- Or run: `newgrp docker`

**Command Not Found:**
- Source your shell configuration: `source ~/.bashrc`
- Or open a new terminal session

**nvm Command Not Found:**
- Restart your terminal or run: `source ~/.bashrc`

**Python/Node Version Issues:**
- Use version managers: `pyenv global <version>` or `nvm use <version>`

### Script Fails Midway

The script uses `set -e` to exit on errors. If it fails:
1. Check the error message
2. Fix the issue (often network-related)
3. Re-run the script - it will skip already installed items

## Requirements

- **OS**: Pop!_OS 22.04+ or Ubuntu 22.04+ based distributions
- **Network**: Internet connection for downloading packages
- **Storage**: At least 5GB free space for all packages
- **User**: Non-root user with sudo privileges
- **Time**: 30-60 minutes depending on internet speed and selected packages

## What's Not Included

This script focuses on development tools and doesn't include:
- Games or gaming-related software
- Specialized design software (GIMP, Blender, etc.)
- Hardware-specific drivers
- Custom kernel modifications

## Contributing

Feel free to submit issues or pull requests to improve the script:
- Add new development tools
- Fix compatibility issues
- Improve error handling
- Add new productivity applications

## Security Notes

- Script downloads from official sources only
- GPG keys are verified where available
- No hardcoded credentials or API keys
- User prompted before each installation

## License

This setup script is provided as-is for educational and development purposes. Individual software packages have their own licenses.

## Installed Software Summary

When running with `-y` flag, the following software is installed:

**Languages & Runtimes:** Node.js (nvm), Python (pyenv), Rust, Go  
**Databases:** PostgreSQL  
**Containers:** Docker with Compose  
**IDEs/Editors:** VS Code, Zed, Alacritty  
**CLI Tools:** bat, fzf, ripgrep, fd, jq, tree, httpie, tldr  
**API Tools:** Postman, Bruno, HTTPie  
**Fonts:** JetBrains Mono, Fira Code, Cascadia Code  
**Screenshots:** Flameshot  
**Communication:** Discord, Slack, Zoom, Spotify  
**Media:** VLC, OBS Studio  
**Productivity:** Obsidian, Chromium  
**Utilities:** Archive tools (zip, 7z, rar), GNOME extensions