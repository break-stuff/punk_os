# Punk_OS

A comprehensive development environment setup script for Ubuntu and Ubuntu-based distributions (including Pop!_OS, Linux Mint, Elementary OS, and others) that transforms your fresh installation into a fully-equipped development machine.

## Overview

The `setup.sh` script is an interactive installer that helps you quickly set up a complete development environment on Ubuntu-based systems. It includes development tools, programming languages, IDEs, productivity applications, and system optimizations commonly needed by developers.

**Compatibility**: Works on Ubuntu 20.04+, Pop!_OS, Linux Mint, Elementary OS, Zorin OS, and other Ubuntu-based distributions that use the apt package manager.

## Quick Start

```bash
/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/break-stuff/punk_os/refs/heads/main/setup.sh || curl -fsSL https://raw.githubusercontent.com/break-stuff/punk_os/refs/heads/main/setup.sh)"
```

**Important:** Do NOT run this script with `sudo`. The script will prompt for your password when elevated privileges are needed.

## What Does This Script Do?

The setup script is fully interactive - you'll be prompted before each installation step, allowing you to customize your setup. Here's what it can install and configure:

### ⚡ System Optimizations

- **SSD Optimization**: Enables `fstrim` timer for better SSD performance and longevity
- **TLP (Battery Life)**: Installs TLP for improved laptop battery management
- **File Watcher Limits**: Increases `inotify` file watchers for development tools (VS Code, webpack, etc.)
- **Restricted Extras**: Installs proprietary codecs and drivers (improves support for Nvidia, MP3, MP4, etc.)

### ⌨️ Keyboard Configuration

- **Function Key Mode**: Option to set function key row to "Function" mode instead of multimedia keys
- **Mac-Style Keyboard Shortcuts**: Option to update keyboard shortcuts to use Mac-style Command key mappings
  - **Note**: If Mac shortcuts don't work properly after installation, you may need to run the `kinto_patch.sh` script to fix compatibility issues with the xkeysnail service

### 🔧 Essential Development Tools

- **Essential Dev Tools**: Core development utilities including:
  - `build-essential` (GCC, G++, make, etc.)
  - `git` - Version control
  - `curl` & `wget` - Download tools
  - `vim` & `neovim` - Text editors
  - `htop` - System monitor
  - `tmux` - Terminal multiplexer
  - `zsh` - Advanced shell
  - `net-tools` - Network utilities

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

- **Archive Tools**: Complete suite of compression utilities
  - `zip/unzip` - ZIP archive support
  - `p7zip-full` - 7-Zip compression with full format support
  - `unrar` - RAR archive extraction

### 🐳 Containerization

- **Docker**: Complete Docker installation with:
  - Docker Engine
  - Docker Compose
  - BuildKit support
  - User added to docker group (no sudo required)

### 🌐 Node.js Development

- **Node.js LTS**: Latest Long Term Support version installed by default
- **Node Version Manager (nvm)**: Manage multiple Node.js versions

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
  - Useful aliases and environment variables configured

### 🗂️ Development Setup

- **Projects Directory**: Creates `~/Projects` for organizing code projects

### 📱 Productivity Applications

- **Communication**: Discord, Slack, Zoom
- **Media**: Spotify
- **Note-taking**: Obsidian
- **Screen Recording**: OBS Studio
- **Web Browser**: Chromium

### 🛠️ API Development Tools

- **Postman**: Popular API testing and development platform
- **HTTPie**: Command-line HTTP client with intuitive syntax (installed with Developer Utilities)

### 📸 Screenshot Tools

- **Flameshot**: Advanced screenshot tool with annotation features

### 🗄️ Database

- **PostgreSQL**: Full PostgreSQL installation with contrib packages
  - Optional pgAdmin 4 Desktop for database management GUI
  - You'll be prompted to install pgAdmin during PostgreSQL setup

## Troubleshooting

### Common Issues

**Mac Keyboard Shortcuts Not Working:**
- If Mac-style shortcuts (Command key mappings) aren't functioning correctly, run the Kinto patch script:
  ```bash
  /bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/break-stuff/punk_os/refs/heads/main/kinto_patch.sh || curl -fsSL https://raw.githubusercontent.com/break-stuff/punk_os/refs/heads/main/kinto_patch.sh)"

  ```
- This script fixes compatibility issues with the xkeysnail service by patching the input.py file
- The script will automatically restart the xkeysnail service after applying the patch
- Note: Requires kinto-master to be extracted in ~/Downloads/

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

- **OS**: Ubuntu 20.04+ or any Ubuntu-based distribution (Pop!_OS, Linux Mint, Elementary OS, Zorin OS, etc.)
- **Package Manager**: apt (Debian/Ubuntu package manager)
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
- Distribution-specific customizations (uses standard Ubuntu packages)

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
