#!/bin/bash

# Check Installed Software Script
# Generates a comprehensive reference manual of installed development tools
# Usage: ./check-installed.sh [output-file]

OUTPUT_FILE="${1:-INSTALLED.md}"

# Colors for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_section() {
    echo -e "${BLUE}[CHECKING]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get version of a command
get_version() {
    local cmd=$1
    local version_flag=${2:---version}
    if command_exists "$cmd"; then
        $cmd $version_flag 2>&1 | head -n 1
    else
        echo "Not installed"
    fi
}

echo_info "Checking installed software and generating reference manual..."
echo_info "Output will be saved to: $OUTPUT_FILE"
echo ""

# Start generating the markdown file
cat > "$OUTPUT_FILE" << 'EOF'
# Installed Software Reference Manual

This document provides a comprehensive reference of all development tools, applications, and utilities installed on this system.

**Generated:** $(date "+%Y-%m-%d %H:%M:%S")
**Hostname:** $(hostname)
**OS:** $(lsb_release -d | cut -f2)

---

## Table of Contents

- [System Information](#system-information)
- [Package Managers & Version Managers](#package-managers--version-managers)
- [Programming Languages & Runtimes](#programming-languages--runtimes)
- [Development Tools & IDEs](#development-tools--ides)
- [Command Line Tools](#command-line-tools)
- [Database Systems](#database-systems)
- [Container & Virtualization](#container--virtualization)
- [API Development Tools](#api-development-tools)
- [Communication & Productivity](#communication--productivity)
- [System Utilities](#system-utilities)
- [Developer Fonts](#developer-fonts)
- [Shell Configuration](#shell-configuration)

---

## System Information

EOF

# Add actual system information
{
    echo "| Item | Value |"
    echo "|------|-------|"
    echo "| OS | $(lsb_release -d | cut -f2) |"
    echo "| Kernel | $(uname -r) |"
    echo "| Architecture | $(uname -m) |"
    echo "| Hostname | $(hostname) |"
    echo "| User | $USER |"
    echo "| Home Directory | $HOME |"
    echo ""
} >> "$OUTPUT_FILE"

echo_section "System Information"

# Package Managers & Version Managers
{
    echo "## Package Managers & Version Managers"
    echo ""
    echo "| Tool | Status | Version | Location |"
    echo "|------|--------|---------|----------|"
} >> "$OUTPUT_FILE"

echo_section "Package Managers"

# Check nvm
if [ -d "$HOME/.nvm" ]; then
    NVM_VERSION=$(cat "$HOME/.nvm/.version" 2>/dev/null || echo "installed")
    echo "| nvm (Node Version Manager) | ✅ Installed | $NVM_VERSION | \`~/.nvm\` |" >> "$OUTPUT_FILE"
else
    echo "| nvm (Node Version Manager) | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Check pyenv
if command_exists pyenv; then
    PYENV_VERSION=$(pyenv --version | awk '{print $2}')
    echo "| pyenv (Python Version Manager) | ✅ Installed | $PYENV_VERSION | \`$(which pyenv)\` |" >> "$OUTPUT_FILE"
else
    echo "| pyenv (Python Version Manager) | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Check rustup
if command_exists rustup; then
    RUSTUP_VERSION=$(rustup --version | head -n1 | awk '{print $2}')
    echo "| rustup (Rust Toolchain Manager) | ✅ Installed | $RUSTUP_VERSION | \`$(which rustup)\` |" >> "$OUTPUT_FILE"
else
    echo "| rustup (Rust Toolchain Manager) | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Check apt
if command_exists apt; then
    APT_VERSION=$(apt --version | head -n1)
    echo "| apt (Package Manager) | ✅ Installed | $APT_VERSION | \`$(which apt)\` |" >> "$OUTPUT_FILE"
fi

# Check snap
if command_exists snap; then
    SNAP_VERSION=$(snap version | grep "snap" | awk '{print $2}')
    echo "| snap (Package Manager) | ✅ Installed | $SNAP_VERSION | \`$(which snap)\` |" >> "$OUTPUT_FILE"
else
    echo "| snap (Package Manager) | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# Programming Languages & Runtimes
{
    echo "## Programming Languages & Runtimes"
    echo ""
    echo "| Language | Status | Version | Location |"
    echo "|----------|--------|---------|----------|"
} >> "$OUTPUT_FILE"

echo_section "Programming Languages"

# Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo "| Node.js | ✅ Installed | $NODE_VERSION | \`$(which node)\` |" >> "$OUTPUT_FILE"
else
    echo "| Node.js | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# npm
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    echo "| npm | ✅ Installed | $NPM_VERSION | \`$(which npm)\` |" >> "$OUTPUT_FILE"
else
    echo "| npm | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Python 3
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    echo "| Python 3 | ✅ Installed | $PYTHON_VERSION | \`$(which python3)\` |" >> "$OUTPUT_FILE"
else
    echo "| Python 3 | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# pip
if command_exists pip3; then
    PIP_VERSION=$(pip3 --version | awk '{print $2}')
    echo "| pip3 | ✅ Installed | $PIP_VERSION | \`$(which pip3)\` |" >> "$OUTPUT_FILE"
else
    echo "| pip3 | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Rust
if command_exists rustc; then
    RUST_VERSION=$(rustc --version | awk '{print $2}')
    echo "| Rust | ✅ Installed | $RUST_VERSION | \`$(which rustc)\` |" >> "$OUTPUT_FILE"
else
    echo "| Rust | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Cargo
if command_exists cargo; then
    CARGO_VERSION=$(cargo --version | awk '{print $2}')
    echo "| Cargo | ✅ Installed | $CARGO_VERSION | \`$(which cargo)\` |" >> "$OUTPUT_FILE"
else
    echo "| Cargo | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Go
if command_exists go; then
    GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    echo "| Go | ✅ Installed | $GO_VERSION | \`$(which go)\` |" >> "$OUTPUT_FILE"
else
    echo "| Go | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# GCC
if command_exists gcc; then
    GCC_VERSION=$(gcc --version | head -n1 | awk '{print $NF}')
    echo "| GCC | ✅ Installed | $GCC_VERSION | \`$(which gcc)\` |" >> "$OUTPUT_FILE"
else
    echo "| GCC | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# Development Tools & IDEs
{
    echo "## Development Tools & IDEs"
    echo ""
    echo "| Tool | Status | Version | Location |"
    echo "|------|--------|---------|----------|"
} >> "$OUTPUT_FILE"

echo_section "IDEs and Editors"

# VS Code
if command_exists code; then
    CODE_VERSION=$(code --version | head -n1)
    echo "| Visual Studio Code | ✅ Installed | $CODE_VERSION | \`$(which code)\` |" >> "$OUTPUT_FILE"
else
    echo "| Visual Studio Code | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Zed
if command_exists zed; then
    echo "| Zed IDE | ✅ Installed | - | \`$(which zed)\` |" >> "$OUTPUT_FILE"
else
    echo "| Zed IDE | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Git
if command_exists git; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    echo "| Git | ✅ Installed | $GIT_VERSION | \`$(which git)\` |" >> "$OUTPUT_FILE"
else
    echo "| Git | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Vim
if command_exists vim; then
    VIM_VERSION=$(vim --version | head -n1 | awk '{print $5}')
    echo "| Vim | ✅ Installed | $VIM_VERSION | \`$(which vim)\` |" >> "$OUTPUT_FILE"
else
    echo "| Vim | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Neovim
if command_exists nvim; then
    NVIM_VERSION=$(nvim --version | head -n1 | awk '{print $2}')
    echo "| Neovim | ✅ Installed | $NVIM_VERSION | \`$(which nvim)\` |" >> "$OUTPUT_FILE"
else
    echo "| Neovim | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Alacritty
if command_exists alacritty; then
    ALACRITTY_VERSION=$(alacritty --version | awk '{print $2}')
    echo "| Alacritty | ✅ Installed | $ALACRITTY_VERSION | \`$(which alacritty)\` |" >> "$OUTPUT_FILE"
else
    echo "| Alacritty | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# Command Line Tools
{
    echo "## Command Line Tools"
    echo ""
    echo "| Tool | Status | Version | Location | Description |"
    echo "|------|--------|---------|----------|-------------|"
} >> "$OUTPUT_FILE"

echo_section "CLI Tools"

# bat
if command_exists bat; then
    BAT_VERSION=$(bat --version | awk '{print $2}')
    echo "| bat | ✅ Installed | $BAT_VERSION | \`$(which bat)\` | Syntax-highlighted cat |" >> "$OUTPUT_FILE"
else
    echo "| bat | ❌ Not Installed | - | - | - |" >> "$OUTPUT_FILE"
fi

# fzf
if command_exists fzf; then
    FZF_VERSION=$(fzf --version | awk '{print $1}')
    echo "| fzf | ✅ Installed | $FZF_VERSION | \`$(which fzf)\` | Fuzzy finder |" >> "$OUTPUT_FILE"
else
    echo "| fzf | ❌ Not Installed | - | - | - |" >> "$OUTPUT_FILE"
fi

# ripgrep
if command_exists rg; then
    RG_VERSION=$(rg --version | head -n1 | awk '{print $2}')
    echo "| ripgrep (rg) | ✅ Installed | $RG_VERSION | \`$(which rg)\` | Fast grep alternative |" >> "$OUTPUT_FILE"
else
    echo "| ripgrep (rg) | ❌ Not Installed | - | - | - |" >> "$OUTPUT_FILE"
fi

# fd
if command_exists fd; then
    FD_VERSION=$(fd --version | awk '{print $2}')
    echo "| fd | ✅ Installed | $FD_VERSION | \`$(which fd)\` | Fast find alternative |" >> "$OUTPUT_FILE"
else
    echo "| fd | ❌ Not Installed | - | - | - |" >> "$OUTPUT_FILE"
fi

# jq
if command_exists jq; then
    JQ_VERSION=$(jq --version | sed 's/jq-//')
    echo "| jq | ✅ Installed | $JQ_VERSION | \`$(which jq)\` | JSON processor |" >> "$OUTPUT_FILE"
else
    echo "| jq | ❌ Not Installed | - | - | - |" >> "$OUTPUT_FILE"
fi

# tree
if command_exists tree; then
    TREE_VERSION=$(tree --version | head -n1 | awk '{print $2}')
    echo "| tree | ✅ Installed | $TREE_VERSION | \`$(which tree)\` | Directory tree view |" >> "$OUTPUT_FILE"
else
    echo "| tree | ❌ Not Installed | - | - | - |" >> "$OUTPUT_FILE"
fi

# httpie
if command_exists http; then
    HTTP_VERSION=$(http --version | awk '{print $2}')
    echo "| httpie | ✅ Installed | $HTTP_VERSION | \`$(which http)\` | HTTP client |" >> "$OUTPUT_FILE"
else
    echo "| httpie | ❌ Not Installed | - | - | - |" >> "$OUTPUT_FILE"
fi

# tldr
if command_exists tldr; then
    TLDR_VERSION=$(tldr --version 2>/dev/null | head -n1 || echo "installed")
    echo "| tldr | ✅ Installed | $TLDR_VERSION | \`$(which tldr)\` | Simplified man pages |" >> "$OUTPUT_FILE"
else
    echo "| tldr | ❌ Not Installed | - | - | - |" >> "$OUTPUT_FILE"
fi

# htop
if command_exists htop; then
    HTOP_VERSION=$(htop --version | head -n1 | awk '{print $2}')
    echo "| htop | ✅ Installed | $HTOP_VERSION | \`$(which htop)\` | System monitor |" >> "$OUTPUT_FILE"
else
    echo "| htop | ❌ Not Installed | - | - | - |" >> "$OUTPUT_FILE"
fi

# tmux
if command_exists tmux; then
    TMUX_VERSION=$(tmux -V | awk '{print $2}')
    echo "| tmux | ✅ Installed | $TMUX_VERSION | \`$(which tmux)\` | Terminal multiplexer |" >> "$OUTPUT_FILE"
else
    echo "| tmux | ❌ Not Installed | - | - | - |" >> "$OUTPUT_FILE"
fi

# curl
if command_exists curl; then
    CURL_VERSION=$(curl --version | head -n1 | awk '{print $2}')
    echo "| curl | ✅ Installed | $CURL_VERSION | \`$(which curl)\` | Data transfer tool |" >> "$OUTPUT_FILE"
else
    echo "| curl | ❌ Not Installed | - | - | - |" >> "$OUTPUT_FILE"
fi

# wget
if command_exists wget; then
    WGET_VERSION=$(wget --version | head -n1 | awk '{print $3}')
    echo "| wget | ✅ Installed | $WGET_VERSION | \`$(which wget)\` | Download tool |" >> "$OUTPUT_FILE"
else
    echo "| wget | ❌ Not Installed | - | - | - |" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# Database Systems
{
    echo "## Database Systems"
    echo ""
    echo "| Database | Status | Version | Location |"
    echo "|----------|--------|---------|----------|"
} >> "$OUTPUT_FILE"

echo_section "Databases"

# PostgreSQL
if command_exists psql; then
    PSQL_VERSION=$(psql --version | awk '{print $3}')
    echo "| PostgreSQL | ✅ Installed | $PSQL_VERSION | \`$(which psql)\` |" >> "$OUTPUT_FILE"
else
    echo "| PostgreSQL | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# Container & Virtualization
{
    echo "## Container & Virtualization"
    echo ""
    echo "| Tool | Status | Version | Location |"
    echo "|------|--------|---------|----------|"
} >> "$OUTPUT_FILE"

echo_section "Containers"

# Docker
if command_exists docker; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    echo "| Docker | ✅ Installed | $DOCKER_VERSION | \`$(which docker)\` |" >> "$OUTPUT_FILE"
else
    echo "| Docker | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# Docker Compose
if command_exists docker-compose || docker compose version >/dev/null 2>&1; then
    if command_exists docker-compose; then
        COMPOSE_VERSION=$(docker-compose --version | awk '{print $3}' | sed 's/,//')
    else
        COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || echo "integrated")
    fi
    echo "| Docker Compose | ✅ Installed | $COMPOSE_VERSION | \`$(which docker-compose || echo 'docker compose')\` |" >> "$OUTPUT_FILE"
else
    echo "| Docker Compose | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# API Development Tools
{
    echo "## API Development Tools"
    echo ""
    echo "| Tool | Status | Location/Notes |"
    echo "|------|--------|----------------|"
} >> "$OUTPUT_FILE"

echo_section "API Tools"

# Postman
if command_exists postman; then
    echo "| Postman | ✅ Installed | \`$(which postman)\` |" >> "$OUTPUT_FILE"
elif [ -f "/opt/Postman/Postman" ]; then
    echo "| Postman | ✅ Installed | \`/opt/Postman/Postman\` |" >> "$OUTPUT_FILE"
else
    echo "| Postman | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# Bruno
if command_exists bruno; then
    echo "| Bruno | ✅ Installed | \`$(which bruno)\` |" >> "$OUTPUT_FILE"
else
    echo "| Bruno | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# Communication & Productivity
{
    echo "## Communication & Productivity"
    echo ""
    echo "| Application | Status | Notes |"
    echo "|-------------|--------|-------|"
} >> "$OUTPUT_FILE"

echo_section "Applications"

# Discord
if command_exists discord || snap list 2>/dev/null | grep -q discord; then
    echo "| Discord | ✅ Installed | Communication platform |" >> "$OUTPUT_FILE"
else
    echo "| Discord | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# Slack
if command_exists slack || snap list 2>/dev/null | grep -q slack; then
    echo "| Slack | ✅ Installed | Team communication |" >> "$OUTPUT_FILE"
else
    echo "| Slack | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# Zoom
if command_exists zoom; then
    echo "| Zoom | ✅ Installed | Video conferencing |" >> "$OUTPUT_FILE"
else
    echo "| Zoom | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# Spotify
if command_exists spotify || snap list 2>/dev/null | grep -q spotify; then
    echo "| Spotify | ✅ Installed | Music streaming |" >> "$OUTPUT_FILE"
else
    echo "| Spotify | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# VLC
if command_exists vlc; then
    VLC_VERSION=$(vlc --version 2>/dev/null | head -n1 | awk '{print $3}' || echo "installed")
    echo "| VLC Media Player | ✅ Installed | Media player - v$VLC_VERSION |" >> "$OUTPUT_FILE"
else
    echo "| VLC Media Player | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# Obsidian
if command_exists obsidian || snap list 2>/dev/null | grep -q obsidian; then
    echo "| Obsidian | ✅ Installed | Note-taking app |" >> "$OUTPUT_FILE"
else
    echo "| Obsidian | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# OBS Studio
if command_exists obs; then
    echo "| OBS Studio | ✅ Installed | Screen recording |" >> "$OUTPUT_FILE"
else
    echo "| OBS Studio | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# Chromium
if command_exists chromium || command_exists chromium-browser; then
    echo "| Chromium | ✅ Installed | Web browser |" >> "$OUTPUT_FILE"
else
    echo "| Chromium | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# Flameshot
if command_exists flameshot; then
    FLAMESHOT_VERSION=$(flameshot --version | awk '{print $2}')
    echo "| Flameshot | ✅ Installed | Screenshot tool - v$FLAMESHOT_VERSION |" >> "$OUTPUT_FILE"
else
    echo "| Flameshot | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# System Utilities
{
    echo "## System Utilities"
    echo ""
    echo "| Utility | Status | Version | Purpose |"
    echo "|---------|--------|---------|---------|"
} >> "$OUTPUT_FILE"

echo_section "System Utilities"

# zip/unzip
if command_exists zip; then
    ZIP_VERSION=$(zip --version 2>&1 | head -n2 | tail -n1 | awk '{print $2}')
    echo "| zip/unzip | ✅ Installed | $ZIP_VERSION | Archive compression |" >> "$OUTPUT_FILE"
else
    echo "| zip/unzip | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# 7z
if command_exists 7z; then
    P7ZIP_VERSION=$(7z | head -n2 | tail -n1 | awk '{print $3}')
    echo "| p7zip (7z) | ✅ Installed | $P7ZIP_VERSION | 7-Zip compression |" >> "$OUTPUT_FILE"
else
    echo "| p7zip (7z) | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# unrar
if command_exists unrar; then
    echo "| unrar | ✅ Installed | - | RAR extraction |" >> "$OUTPUT_FILE"
else
    echo "| unrar | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

# timeshift
if command_exists timeshift; then
    TIMESHIFT_VERSION=$(timeshift --version 2>&1 | grep "version" | awk '{print $3}')
    echo "| Timeshift | ✅ Installed | $TIMESHIFT_VERSION | System backups |" >> "$OUTPUT_FILE"
else
    echo "| Timeshift | ❌ Not Installed | - | - |" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# Developer Fonts
{
    echo "## Developer Fonts"
    echo ""
    echo "The following developer fonts with ligature support are checked:"
    echo ""
    echo "| Font | Status | Location |"
    echo "|------|--------|----------|"
} >> "$OUTPUT_FILE"

echo_section "Fonts"

# Check for JetBrains Mono
if fc-list | grep -qi "JetBrains Mono"; then
    echo "| JetBrains Mono | ✅ Installed | System fonts |" >> "$OUTPUT_FILE"
else
    echo "| JetBrains Mono | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# Check for Fira Code
if fc-list | grep -qi "Fira Code"; then
    echo "| Fira Code | ✅ Installed | System fonts |" >> "$OUTPUT_FILE"
else
    echo "| Fira Code | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# Check for Cascadia Code
if fc-list | grep -qi "Cascadia"; then
    echo "| Cascadia Code | ✅ Installed | System fonts |" >> "$OUTPUT_FILE"
else
    echo "| Cascadia Code | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# Shell Configuration
{
    echo "## Shell Configuration"
    echo ""
    echo "| Item | Status | Details |"
    echo "|------|--------|---------|"
} >> "$OUTPUT_FILE"

echo_section "Shell"

# Current shell
CURRENT_SHELL=$(echo $SHELL)
echo "| Current Shell | ✅ Active | \`$CURRENT_SHELL\` |" >> "$OUTPUT_FILE"

# Zsh
if command_exists zsh; then
    ZSH_VERSION=$(zsh --version | awk '{print $2}')
    echo "| Zsh | ✅ Installed | $ZSH_VERSION |" >> "$OUTPUT_FILE"
else
    echo "| Zsh | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "| Oh My Zsh | ✅ Installed | \`~/.oh-my-zsh\` |" >> "$OUTPUT_FILE"
else
    echo "| Oh My Zsh | ❌ Not Installed | - |" >> "$OUTPUT_FILE"
fi

# Bash
if command_exists bash; then
    BASH_VERSION=$(bash --version | head -n1 | awk '{print $4}')
    echo "| Bash | ✅ Installed | $BASH_VERSION |" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# Add useful commands section
{
    echo "## Quick Reference Commands"
    echo ""
    echo "### Version Managers"
    echo ""
    echo '```bash'
    echo "# Node.js versions (nvm)"
    echo "nvm list                    # List installed Node versions"
    echo "nvm install node            # Install latest Node.js"
    echo "nvm use 18                  # Switch to Node.js 18"
    echo ""
    echo "# Python versions (pyenv)"
    echo "pyenv versions              # List installed Python versions"
    echo "pyenv install 3.12.0        # Install Python 3.12.0"
    echo "pyenv global 3.12.0         # Set global Python version"
    echo ""
    echo "# Rust toolchain (rustup)"
    echo "rustup update               # Update Rust"
    echo "rustup show                 # Show installed toolchains"
    echo '```'
    echo ""
    echo "### Docker"
    echo ""
    echo '```bash'
    echo "docker ps                   # List running containers"
    echo "docker images               # List images"
    echo "docker compose up -d        # Start services in background"
    echo "docker compose down         # Stop services"
    echo '```'
    echo ""
    echo "### Database"
    echo ""
    echo '```bash'
    echo "# PostgreSQL"
    echo "sudo systemctl status postgresql   # Check PostgreSQL status"
    echo "sudo -u postgres psql              # Access PostgreSQL CLI"
    echo '```'
    echo ""
    echo "### System Information"
    echo ""
    echo '```bash'
    echo "# Installed packages"
    echo "apt list --installed        # List all apt packages"
    echo "snap list                   # List all snap packages"
    echo ""
    echo "# Check versions"
    echo "node --version              # Node.js version"
    echo "python3 --version           # Python version"
    echo "go version                  # Go version"
    echo "rustc --version             # Rust version"
    echo '```'
    echo ""
} >> "$OUTPUT_FILE"

# Add footer
{
    echo "---"
    echo ""
    echo "## Notes"
    echo ""
    echo "- This document was auto-generated by \`check-installed.sh\`"
    echo "- To update this document, run: \`./check-installed.sh\`"
    echo "- Some applications installed via snap or flatpak may not appear in PATH"
    echo "- Version numbers are current as of the generation date above"
    echo ""
    echo "## Regenerating This Document"
    echo ""
    echo '```bash'
    echo "# Generate with default filename (INSTALLED.md)"
    echo "./check-installed.sh"
    echo ""
    echo "# Generate with custom filename"
    echo "./check-installed.sh my-system-info.md"
    echo '```'
} >> "$OUTPUT_FILE"

echo ""
echo_info "✅ Reference manual generated successfully!"
echo_info "📄 Output saved to: $OUTPUT_FILE"
echo_info ""
echo_info "You can view it with:"
echo_info "  cat $OUTPUT_FILE"
echo_info "  or open it in your markdown viewer/editor"
