#!/bin/bash

# Pop!_OS Ultimate Dev Box Setup Script
# Run with: bash setup.sh [-y]
# Options:
#   -y    Accept all prompts automatically (non-interactive mode)

set -e  # Exit on error

# Parse command line arguments
AUTO_YES=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [-y|--yes] [-h|--help]"
            echo "Options:"
            echo "  -y, --yes    Accept all prompts automatically (non-interactive mode)"
            echo "  -h, --help   Show this help message"
            exit 0
            ;;
        *)
            echo_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo_error "This script should not be run as root (don't use sudo)"
   exit 1
fi

echo_info "Starting Pop!_OS Dev Box Setup..."
if [[ "$AUTO_YES" == true ]]; then
    echo_info "Running in non-interactive mode (auto-accepting all prompts)"
fi
echo_info "You may be prompted for your password for sudo commands"
echo ""

# Prompt function
prompt_install() {
    if [[ "$AUTO_YES" == true ]]; then
        echo_info "Auto-accepting: $1"
        return 0
    else
        read -p "$1 (y/n) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Update system first
if prompt_install "Update system packages?"; then
    echo_info "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
else
    echo_warn "Skipping system update"
fi

# Install essential build tools
if prompt_install "Install essential build tools (git, curl, wget, vim, etc.)?"; then
    echo_info "Installing build essentials and common tools..."
    sudo apt install -y \
        build-essential \
        git \
        curl \
        wget \
        vim \
        neovim \
        htop \
        tmux \
        zsh \
        gnome-shell-extensions \
        timeshift \
        net-tools \
        ca-certificates \
        gnupg \
        lsb-release
else
    echo_warn "Skipping essential build tools"
fi

# Increase file watchers for dev tools
if prompt_install "Increase inotify file watchers (needed for many dev tools)?"; then
    echo_info "Increasing inotify file watchers..."
    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
else
    echo_warn "Skipping inotify configuration"
fi

# Enable fstrim for SSD optimization
if prompt_install "Enable fstrim for SSD optimization?"; then
    echo_info "Enabling fstrim timer for SSD optimization..."
    sudo systemctl enable fstrim.timer
else
    echo_warn "Skipping fstrim"
fi

# Install modern CLI tools
if prompt_install "Install modern CLI tools (bat, fzf, ripgrep, fd, tldr)?"; then
    echo_info "Installing modern CLI tools..."
    sudo apt install -y \
        bat \
        fzf \
        ripgrep \
        fd-find \
        tldr

    # Create symlinks for bat and fd (they have different names on Ubuntu/Debian)
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/batcat ~/.local/bin/bat 2>/dev/null || true
    ln -sf /usr/bin/fdfind ~/.local/bin/fd 2>/dev/null || true
else
    echo_warn "Skipping modern CLI tools"
fi

# Install Docker
if prompt_install "Install Docker?"; then
    echo_info "Installing Docker..."
    if ! command -v docker &> /dev/null; then
        # Remove old versions
        sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

        # Add Docker's official GPG key
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Set up the repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # Add user to docker group
        sudo usermod -aG docker $USER
        echo_info "Docker installed. You'll need to log out and back in for group changes to take effect"
    else
        echo_info "Docker already installed"
    fi
else
    echo_warn "Skipping Docker"
fi

# Install Node Version Manager (nvm)
if prompt_install "Install Node Version Manager (nvm) and Node.js LTS?"; then
    echo_info "Installing Node Version Manager (nvm)..."
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        echo_info "Installing Node.js LTS..."
        nvm install --lts
    else
        echo_info "nvm already installed"
    fi
else
    echo_warn "Skipping nvm"
fi

# Install Python tools
if prompt_install "Install Python development tools and pyenv?"; then
    echo_info "Installing Python development tools..."
    sudo apt install -y python3-pip python3-venv python3-dev

    # Install pyenv for Python version management
    if [ ! -d "$HOME/.pyenv" ]; then
        echo_info "Installing pyenv..."
        curl https://pyenv.run | bash

        # Add pyenv to shell (will be sourced on next login)
        cat >> ~/.bashrc << 'EOF'

# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
    else
        echo_info "pyenv already installed"
    fi
else
    echo_warn "Skipping Python tools"
fi

# Install Rust
if prompt_install "Install Rust toolchain?"; then
    echo_info "Installing Rust..."
    if ! command -v rustc &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        echo_info "Rust already installed"
    fi
else
    echo_warn "Skipping Rust"
fi

# Install VS Code
if prompt_install "Install Visual Studio Code?"; then
    echo_info "Installing Visual Studio Code..."
    if ! command -v code &> /dev/null; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
        sudo apt update
        sudo apt install -y code
    else
        echo_info "VS Code already installed"
    fi
else
    echo_warn "Skipping VS Code"
fi

# Install Zed IDE
if prompt_install "Install Zed IDE?"; then
    echo_info "Installing Zed IDE..."
    if ! command -v zed &> /dev/null; then
        curl -f https://zed.dev/install.sh | sh
    else
        echo_info "Zed already installed"
    fi
else
    echo_warn "Skipping Zed IDE"
fi

# Install Alacritty (GPU-accelerated terminal)
if prompt_install "Install Alacritty (GPU-accelerated terminal)?"; then
    echo_info "Installing Alacritty terminal..."
    sudo apt install -y alacritty
else
    echo_warn "Skipping Alacritty"
fi

# Configure Oh My Zsh (optional but recommended)
if prompt_install "Install Oh My Zsh with plugins?"; then
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        # Install popular plugins
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

        # Set zsh as default shell
        chsh -s $(which zsh)
        echo_info "Zsh set as default shell. Log out and back in for changes to take effect"
    else
        echo_info "Oh My Zsh already installed"
    fi
else
    echo_warn "Skipping Oh My Zsh"
fi

# Add useful shell configurations
if prompt_install "Add useful shell configurations and aliases?"; then
    echo_info "Adding shell configurations..."
    cat >> ~/.bashrc << 'EOF'

# Dev box optimizations
export EDITOR=vim
export PATH="$HOME/.local/bin:$PATH"
export DOCKER_BUILDKIT=1

# Aliases
alias ll='ls -lah'
alias gs='git status'
alias gp='git pull'
alias dc='docker-compose'
alias nv='nvim'

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Rust configuration
. "$HOME/.cargo/env"
EOF
else
    echo_warn "Skipping shell configuration"
fi

# Create a projects directory
if prompt_install "Create ~/Projects directory?"; then
    echo_info "Creating ~/Projects directory..."
    mkdir -p ~/Projects
else
    echo_warn "Skipping Projects directory"
fi

# Install GNOME extensions (requires manual enabling)
if prompt_install "Install GNOME Shell Extensions (Caffeine, System Monitor)?"; then
    echo_info "Installing GNOME Shell Extensions..."
    sudo apt install -y \
        gnome-shell-extension-caffeine \
        gnome-shell-extension-system-monitor
else
    echo_warn "Skipping GNOME extensions"
fi

# Install Spotify
if prompt_install "Install Spotify?"; then
    echo_info "Installing Spotify..."
    if ! command -v spotify &> /dev/null; then
        curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
        echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
        sudo apt update
        sudo apt install -y spotify-client
    else
        echo_info "Spotify already installed"
    fi
else
    echo_warn "Skipping Spotify"
fi

# Install Discord
if prompt_install "Install Discord?"; then
    echo_info "Installing Discord..."
    if ! command -v discord &> /dev/null; then
        wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
        sudo apt install -y ./discord.deb
        rm discord.deb
    else
        echo_info "Discord already installed"
    fi
else
    echo_warn "Skipping Discord"
fi

# Install Slack
if prompt_install "Install Slack?"; then
    echo_info "Installing Slack..."
    if ! command -v slack &> /dev/null; then
        wget -O slack.deb https://downloads.slack-edge.com/releases/linux/4.40.133/prod/x64/slack-desktop-4.40.133-amd64.deb
        sudo apt install -y ./slack.deb
        rm slack.deb
    else
        echo_info "Slack already installed"
    fi
else
    echo_warn "Skipping Slack"
fi

# Install VLC
if prompt_install "Install VLC Media Player?"; then
    echo_info "Installing VLC..."
    sudo apt install -y vlc
else
    echo_warn "Skipping VLC"
fi

# Install Zoom
if prompt_install "Install Zoom?"; then
    echo_info "Installing Zoom..."
    if ! command -v zoom &> /dev/null; then
        wget -O zoom.deb https://zoom.us/client/latest/zoom_amd64.deb
        sudo apt install -y ./zoom.deb
        rm zoom.deb
    else
        echo_info "Zoom already installed"
    fi
else
    echo_warn "Skipping Zoom"
fi

# Install Obsidian
if prompt_install "Install Obsidian?"; then
    echo_info "Installing Obsidian..."
    if ! command -v obsidian &> /dev/null; then
        wget -O obsidian.deb https://github.com/obsidianmd/obsidian-releases/releases/latest/download/obsidian_amd64.deb
        sudo apt install -y ./obsidian.deb
        rm obsidian.deb
    else
        echo_info "Obsidian already installed"
    fi
else
    echo_warn "Skipping Obsidian"
fi

# Install PostgreSQL
if prompt_install "Install PostgreSQL?"; then
    echo_info "Installing PostgreSQL..."
    sudo apt install -y postgresql postgresql-contrib
    echo_info "PostgreSQL installed. Default user is 'postgres'"
    echo_info "To set up: sudo -u postgres psql"
else
    echo_warn "Skipping PostgreSQL"
fi

# Install OBS Studio
if prompt_install "Install OBS Studio?"; then
    echo_info "Installing OBS Studio..."
    sudo apt install -y obs-studio
else
    echo_warn "Skipping OBS Studio"
fi

# Install Chromium
if prompt_install "Install Chromium Browser?"; then
    echo_info "Installing Chromium..."
    sudo apt install -y chromium-browser
else
    echo_warn "Skipping Chromium"
fi

# Install Postman
if prompt_install "Install Postman?"; then
    echo_info "Installing Postman..."
    if ! command -v postman &> /dev/null; then
        wget -O postman.tar.gz https://dl.pstmn.io/download/latest/linux64
        sudo tar -xzf postman.tar.gz -C /opt
        sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman
        rm postman.tar.gz

        # Create desktop entry
        cat > ~/.local/share/applications/postman.desktop << 'EOF'
[Desktop Entry]
Name=Postman
Exec=/opt/Postman/Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Type=Application
Categories=Development;
EOF
    else
        echo_info "Postman already installed"
    fi
else
    echo_warn "Skipping Postman"
fi

# Install Bruno
if prompt_install "Install Bruno (API client)?"; then
    echo_info "Installing Bruno..."
    if ! command -v bruno &> /dev/null; then
        wget -O bruno.deb https://github.com/usebruno/bruno/releases/latest/download/bruno_amd64.deb
        sudo apt install -y ./bruno.deb
        rm bruno.deb
    else
        echo_info "Bruno already installed"
    fi
else
    echo_warn "Skipping Bruno"
fi

# Summary
echo_info "================================"
echo_info "Setup Complete!"
echo_info "================================"
echo ""
echo_info "Next steps:"
echo "1. Log out and back in (or reboot) for all changes to take effect"
echo "2. Open GNOME Tweaks to enable extensions"
echo "3. Configure your terminal (Alacritty config at ~/.config/alacritty/alacritty.yml)"
echo "4. Set up your dotfiles repository"
echo "5. Install language-specific tools as needed"
echo ""
echo_info "Useful commands installed:"
echo "  - bat (better cat)"
echo "  - fzf (fuzzy finder)"
echo "  - ripgrep (rg - fast grep)"
echo "  - fd (fast find)"
echo "  - nvm (Node version manager)"
echo "  - pyenv (Python version manager)"
echo "  - docker & docker-compose"
echo ""
echo_info "Version Manager Usage:"
echo "  - Node.js: nvm install node (latest) | nvm install --lts | nvm use <version>"
echo "  - Python: pyenv install 3.12.0 | pyenv global 3.12.0"
echo "  - Rust: rustup update | rustup install stable"
echo ""
echo_info "PostgreSQL setup (if installed):"
echo "  - Access PostgreSQL: sudo -u postgres psql"
echo "  - Create your user: CREATE USER yourusername WITH PASSWORD 'password';"
echo "  - Create database: CREATE DATABASE yourdb OWNER yourusername;"
echo "  - Enable/start service: sudo systemctl enable postgresql && sudo systemctl start postgresql"
echo ""
echo_info "Docker tips (if installed):"
echo "  - Test without sudo: docker run hello-world"
echo "  - If permission denied, log out and back in for group changes"
echo "  - Use docker-compose or docker compose for multi-container apps"
echo ""
echo_info "Zsh configuration (if installed):"
echo "  - Edit config: nano ~/.zshrc"
echo "  - Enable plugins: Edit 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)'"
echo "  - Apply changes: source ~/.zshrc"
echo ""
echo_info "Application locations:"
echo "  - Postman: Run 'postman' from terminal or find in application menu"
echo "  - VS Code: Run 'code' from terminal"
echo "  - Zed: Run 'zed' from terminal"
echo ""
echo_warn "IMPORTANT: Log out and back in for Docker group and shell changes to take effect!"
