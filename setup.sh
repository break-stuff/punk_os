#!/bin/bash
###############################################################################
# Punk_OS - Ubuntu Development Environment Setup Script
# Compatible with Ubuntu 20.04+, Pop!_OS, Linux Mint, Elementary OS, Zorin OS,
# and other Ubuntu-based distributions using apt.
#
# This script is interactive unless -y/--yes is supplied.
#
# Packaging Source Override:
#   --gui-source flatpak|snap|apt   (priority override for GUI apps)
#
# Automatic detection order (if no override):
#   1. Flatpak (if present or user installs)
#   2. Snap
#   3. apt/.deb fallback
#
# GUI apps supported via Flatpak / Snap:
#   VS Code, Discord, Slack, Zoom, Spotify, Postman, Obsidian, Chromium,
#   OBS Studio, Flameshot, Alacritty, Zed, GIMP, Inkscape
###############################################################################

set -e  # Exit immediately on error

show_logo() {
    echo "                            @@@@@  "
    echo "                           @@   @@ "
    echo "        __                 @-   @@ "
    echo "      @@=-@@               @    #@ "
    echo "     @@    @              #@    *@ "
    echo "     @@    @@             @@    +@ "
    echo "     %@    *@         @@@@@@    -@ "
    echo "     -@     @@ @@@@@@@:   @@    .@ "
    echo "      @+    @@@@   :@=    .@     @ "
    echo "      @@    #@@     .@     @.    @="
    echo "      @@      @-     @:    +@    @+"
    echo "      @@       @     @@@@@@@@    @%"
    echo "      %@       @@ @@-        @#  @@"
    echo "       @=       =@@           :@+@@"
    echo "       @@          @@@@@@@      @@@"
    echo "       @@             #@  #+    @@."
    echo "        @%           @=         @@ "
    echo "        %@           @          @@ "
    echo "         @@=                   @@  "
    echo "           @@.               @@@   "
    echo "             @@@@#.     +@@@@-     "
    echo "                   -##-            "
}

# ----------------------------- Argument Parsing ------------------------------
AUTO_YES=false
GUI_SOURCE_OVERRIDE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        --gui-source=*)
            GUI_SOURCE_OVERRIDE="${1#*=}"
            shift
            ;;
        --gui-source)
            GUI_SOURCE_OVERRIDE="$2"
            shift 2
            ;;
        -h|--help)
            cat <<'USAGE'
Usage: setup.sh [options]

Options:
  -y, --yes                 Non-interactive mode (auto accept all prompts)
  --gui-source <flatpak|snap|apt>
                            Force GUI application source priority
  -h, --help                Show this help message

Examples:
  ./setup.sh --gui-source flatpak
  ./setup.sh -y --gui-source=snap

Do NOT run this script with sudo. It will request elevation when needed.
USAGE
            exit 0
            ;;
        *)
            echo "[ERROR] Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# ----------------------------- Output Formatting -----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ----------------------------- Prompt Function -------------------------------
prompt_install() {
  if [[ "$AUTO_YES" == true ]]; then
    return 0
  fi
  local prompt_text="$1"
  read -p "$prompt_text (y/n) " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]]
}

# ----------------------------- Safety Checks ---------------------------------
if [[ $EUID -eq 0 ]]; then
    echo_error "Do not run as root. Re-run without sudo."
    exit 1
fi

if ! command -v apt >/dev/null 2>&1; then
    echo_error "apt package manager not found. This script targets Debian/Ubuntu-based systems."
    exit 1
fi

DISTRO=$(lsb_release -is 2>/dev/null || echo "Ubuntu")
DISTRO_VERSION=$(lsb_release -rs 2>/dev/null || echo "unknown")

# echo_info "Starting Punk_OS Development Environment Setup..."
# echo_info "Detected: $DISTRO $DISTRO_VERSION"
[[ "$AUTO_YES" == true ]] && echo_info "Non-interactive mode enabled (auto-accepting prompts)"

# Ubuntu version advisory
if [[ "$DISTRO" == "Ubuntu" ]] || [[ "$DISTRO" == "Pop" ]]; then
    MAJOR_VERSION=$(echo "$DISTRO_VERSION" | cut -d. -f1 || echo 0)
    if [[ "$MAJOR_VERSION" -lt 20 ]]; then
        echo_warn "Script designed for Ubuntu 20.04+. Detected: $DISTRO_VERSION"
        if [[ "$AUTO_YES" != true ]]; then
            read -p "Continue anyway? (y/n) " -n 1 -r; echo
            [[ $REPLY =~ ^[Yy]$ ]] || { echo_info "Cancelled."; exit 0; }
        fi
    fi
fi

# ------------------------- Install Prompt Map & Functions --------------------
# Associative array mapping function names to prompt strings
# Ordered install function list (preserves declaration order for menu)
INSTALL_PROMPTS=(
  "enable_fstrim:Enable fstrim timer (SSD optimization)?"
  "tune_inotify:Increase inotify file watchers (recommended for editors & tooling)?"
  "set_fn_function_mode:Set the function key row to \"Function\" mode instead of multimedia keys?"
  "update_keyboard_shortcuts_mac:Update keyboard shortcuts to use Mac"
  "create_projects_dir:Create ~/Projects directory?"
  "install_tpl:Install TPL (improves battery life)?"
  "install_oh_my_zsh:Install Oh My Zsh with plugins?"
  "install_alacritty:Install Alacritty (GPU-accelerated terminal)?"
  "install_restricted_extras:Install proprietary codecs & drivers (improves support for Nvidia, MP3, MP4, etc.)?"
  "install_dev_fonts:Install developer fonts (JetBrains Mono, Fira Code, Cascadia Code)?"
  "install_essential_dev_tools:Install essential dev tools (git, curl, wget, vim, etc.)?"
  "install_modern_cli_tools:Install modern CLI tools (bat, ripgrep, fd, tldr)?"
  "install_developer_utilities:Install developer utilities (jq, tree, httpie)?"
  "install_nvm_node:Install Node.js LTS & Node Version Manager (nvm)?"
  "install_python_pyenv:Install Python development tools & pyenv?"
  "install_rust:Install Rust toolchain (rustup)?"
  "install_go:Install Go (Golang)?"
  "install_vscode:Install Visual Studio Code?"
  "install_zed:Install Zed IDE?"
  "install_postman:Install Postman?"
  "install_docker:Install Docker (Engine, Compose)?"
  "install_postgresql:Install PostgreSQL?"
  "install_chromium:Install Chromium Browser?"
  "install_archive_tools:Install archive/compression tools (zip, unzip, 7z, rar)?"
  "install_discord:Install Discord?"
  "install_slack:Install Slack?"
  "install_zoom:Install Zoom?"
  "install_spotify:Install Spotify?"
  "install_obsidian:Install Obsidian?"
  "install_flameshot:Install Flameshot (screenshot tool)?"
  "install_obs_studio:Install OBS Studio?"
  "install_gimp:Install GIMP (image editor)?"
  "install_inkscape:Install Inkscape (vector graphics editor)?"
)

install_fzf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo_info "Installing fzf (fuzzy finder for interactive menu)..."
    sudo apt install -y fzf
  fi
}

select_installations_menu() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo_warn "fzf not found; skipping interactive selection menu."
    return 1
  fi
  [[ $FZF_DEFAULT_OPTS == *"--tac"* ]] && echo_warn "Detected --tac in FZF_DEFAULT_OPTS (reverses order). Overriding for menu."
  echo_info "Launching interactive installation selection menu (fzf)..."
  local menu
  FZF_DEFAULT_OPTS='' \
  menu=$(for i in "${!INSTALL_PROMPTS[@]}"; do
            local item="${INSTALL_PROMPTS[$i]}"
            local fn="${item%%:*}"
            local prompt="${item#*:}"
            printf "%02d. %s\t%s\n" "$((i+1))" "$fn" "$prompt"
         done | command fzf --no-sort --layout=reverse-list --multi --with-nth=2,3 --bind='space:toggle' --prompt="Select installations (SPACE to toggle, ENTER to confirm): " --delimiter=$'\t' --height=80% --border) || {
    echo_warn "Menu cancelled (no selections)."
    return 1
  }
  SELECTED_INSTALL_FUNCS=()
  while IFS=$'\t' read -r first _; do
     fn="${first#*. }"
     # Ensure we extract only the function name (strip any trailing colon-delimited content)
     fn="${fn%%:*}"
     [[ -n "$fn" ]] && SELECTED_INSTALL_FUNCS+=("$fn")
  done <<< "$menu"
  echo_info "Selections: ${SELECTED_INSTALL_FUNCS[*]:-(none)}"
}

# Execute only selected installation functions (if any)
run_selected_installations() {
  if [[ ${#SELECTED_INSTALL_FUNCS[@]} -eq 0 ]]; then
    echo_warn "No selections captured; nothing to run from menu."
    return 0
  fi
  for fn in "${SELECTED_INSTALL_FUNCS[@]}"; do
    if declare -F "$fn" >/dev/null 2>&1; then
      echo_info "Running: $fn"
      "$fn"
    else
      echo_warn "Undefined function selected: $fn"
    fi
  done
}

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    chsh -s "$(which zsh)"
    echo_info "Zsh set as default shell (logout/login to activate)"
  else
    echo_info "Oh My Zsh already installed"
  fi
}

install_essential_dev_tools() {
  echo_info "Installing essential dev tools..."
  sudo apt install -y \
    build-essential git gh curl wget vim neovim htop tmux zsh \
    gnome-shell-extensions timeshift net-tools ca-certificates gnupg lsb-release
}

install_restricted_extras() {
  echo_info "Installing proprietary codecs and drivers (ubuntu-restricted-extras)..."
  echo_info "This includes: MP3/MP4 codecs, Microsoft fonts, Flash plugin, DVD playback support"
  # Pre-accept EULA for ttf-mscorefonts-installer to avoid interactive prompt
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
  sudo apt install -y ubuntu-restricted-extras
  echo_info "Proprietary codecs and drivers installed successfully"
}

tune_inotify() {
  echo_info "Adjusting inotify watcher limit..."
  echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p
}

set_fn_function_mode() {
  echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode
  echo options hid_apple fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
  sudo update-initramfs -u -k all
}

install_tlp() {
    sudo add-apt-repository ppa:linrunner/tlp
    sudo apt install tlp tlp-rdw
    sudo tlp start
}

install_cleanup_tools() {
    sudo apt autoclean autoremove clean -y
}

update_keyboard_shortcuts_mac() {
    /bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh || curl -fsSL https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh)"
}

enable_fstrim() {
  sudo systemctl enable fstrim.timer
}

install_modern_cli_tools() {
  sudo apt install -y bat ripgrep fd-find tldr
  mkdir -p ~/.local/bin
  ln -sf /usr/bin/batcat ~/.local/bin/bat 2>/dev/null || true
  ln -sf /usr/bin/fdfind ~/.local/bin/fd 2>/dev/null || true
}

install_developer_utilities() {
  sudo apt install -y jq tree httpie
}

install_archive_tools() {
  sudo apt install -y zip unzip p7zip-full p7zip-rar unrar
}

install_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER"
    echo_info "Docker installed. Log out and back in for group membership to take effect."
  else
    echo_info "Docker already installed"
  fi
}

install_nvm_node() {
    if [ -d "$HOME/.nvm" ] || [ -n "$NVM_DIR" ]; then
        echo_info "nvm is already installed"
        return 0
    fi
    echo_info "Installing nvm (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    if command -v nvm >/dev/null 2>&1; then
        echo_info "Installing Node.js LTS via nvm..."
        nvm install --lts
        nvm use --lts
    fi
}

install_python_pyenv() {
  sudo apt install -y python3-pip python3-venv python3-dev
  if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
    cat >> ~/.bashrc <<'EOF'
# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
  else
    echo_info "pyenv already installed"
  fi
}

install_rust() {
  if ! command -v rustc >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  else
    echo_info "Rust already installed"
  fi
}

install_go() {
  if ! command -v go >/dev/null 2>&1; then
    GO_VERSION="1.21.5"
    wget -O go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go.tar.gz
    rm go.tar.gz
    cat >> ~/.bashrc <<'EOF'
# Go configuration
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF
    export PATH=$PATH:/usr/local/go/bin
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
    echo_info "Go installed. Reload shell or source ~/.bashrc to update PATH."
  else
    echo_info "Go already installed"
  fi
}

install_dev_fonts() {
  mkdir -p ~/.local/share/fonts
  if [ ! -d ~/.local/share/fonts/JetBrainsMono ]; then
    wget -O jetbrains.zip https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
    unzip -q jetbrains.zip -d ~/.local/share/fonts/JetBrainsMono
    rm jetbrains.zip
  fi
  if [ ! -d ~/.local/share/fonts/FiraCode ]; then
    wget -O firacode.zip https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip
    unzip -q firacode.zip -d ~/.local/share/fonts/FiraCode
    rm firacode.zip
  fi
  if [ ! -d ~/.local/share/fonts/CascadiaCode ]; then
    wget -O cascadia.zip https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
    unzip -q cascadia.zip -d ~/.local/share/fonts/CascadiaCode
    rm cascadia.zip
  fi
  fc-cache -fv
}

create_projects_dir() {
  mkdir -p ~/Projects
}

# GUI-related functions (run after choose_gui_source)
install_alacritty() {
  case "$GUI_SOURCE" in
    flatpak) flatpak_install "$FP_ALACRITTY" "Alacritty" || { gui_fallback_notice "Alacritty"; } ;;
    snap)    snap_install alacritty "" "Alacritty"       || { gui_fallback_notice "Alacritty"; } ;;
  esac
  if ! command -v alacritty >/dev/null 2>&1 && [[ "$GUI_SOURCE" == "apt" ]]; then
    sudo apt install -y alacritty
  fi
}

install_flameshot() {
  case "$GUI_SOURCE" in
    flatpak) flatpak_install "$FP_FLAMESHOT" "Flameshot" || { gui_fallback_notice "Flameshot"; } ;;
    snap)    snap_install flameshot "" "Flameshot"       || { gui_fallback_notice "Flameshot"; } ;;
  esac
  if ! command -v flameshot >/dev/null 2>&1 && [[ "$GUI_SOURCE" == "apt" ]]; then
    sudo apt install -y flameshot
  fi
  echo_info "Configure Flameshot keybinding: Super+Shift+S → flameshot gui"
}

install_vscode() {
  case "$GUI_SOURCE" in
    flatpak)
      flatpak_install "$FP_VSCODE" "VS Code" || { gui_fallback_notice "VS Code"; }
      ;;
    snap)
      snap_install code "--classic" "VS Code" || { gui_fallback_notice "VS Code"; }
      ;;
  esac
  if ! command -v code >/dev/null 2>&1 && [[ "$GUI_SOURCE" == "apt" ]]; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    rm packages.microsoft.gpg
    sudo apt install -y code
  fi
}

install_zed() {
  case "$GUI_SOURCE" in
    flatpak)
      flatpak_install "$FP_ZED" "Zed IDE" || { gui_fallback_notice "Zed IDE"; }
      ;;
    snap)
      echo_warn "No official snap for Zed IDE; using install script."
      ;;
  esac
  if ! command -v zed >/dev/null 2>&1 && [[ "$GUI_SOURCE" != "flatpak" ]]; then
    echo_info "Installing Zed IDE via official install script..."
    curl -f https://zed.dev/install.sh | sh
  fi
}

install_discord() {
  case "$GUI_SOURCE" in
    flatpak) flatpak_install "$FP_DISCORD" "Discord" || { gui_fallback_notice "Discord"; } ;;
    snap)    snap_install discord "" "Discord"       || { gui_fallback_notice "Discord"; } ;;
  esac
  if ! command -v discord >/dev/null 2>&1 && [[ "$GUI_SOURCE" == "apt" ]]; then
    wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt install -y ./discord.deb
    rm discord.deb
  fi
}

install_slack() {
  case "$GUI_SOURCE" in
    flatpak) flatpak_install "$FP_SLACK" "Slack" || { gui_fallback_notice "Slack"; } ;;
    snap)    snap_install slack "" "Slack"       || { gui_fallback_notice "Slack"; } ;;
  esac
  if ! command -v slack >/dev/null 2>&1 && [[ "$GUI_SOURCE" == "apt" ]]; then
    wget -O slack.deb https://downloads.slack-edge.com/releases/linux/4.40.128/prod/x64/slack-desktop-4.40.128-amd64.deb
    sudo apt install -y ./slack.deb
    rm slack.deb
  fi
}

install_zoom() {
  case "$GUI_SOURCE" in
    flatpak) flatpak_install "$FP_ZOOM" "Zoom" || { gui_fallback_notice "Zoom"; } ;;
    snap)    snap_install zoom-client "" "Zoom"       || { gui_fallback_notice "Zoom"; } ;;
  esac
  if ! command -v zoom >/dev/null 2>&1 && [[ "$GUI_SOURCE" == "apt" ]]; then
    wget -O zoom.deb https://zoom.us/client/latest/zoom_amd64.deb
    sudo apt install -y ./zoom.deb
    rm zoom.deb
  fi
}

install_spotify() {
  case "$GUI_SOURCE" in
    flatpak) flatpak_install "$FP_SPOTIFY" "Spotify" || { gui_fallback_notice "Spotify"; } ;;
    snap)    snap_install spotify "" "Spotify"       || { gui_fallback_notice "Spotify"; } ;;
  esac
  if ! command -v spotify >/dev/null 2>&1 && [[ "$GUI_SOURCE" == "apt" ]]; then
    curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/spotify.gpg
    echo "deb [signed-by=/etc/apt/keyrings/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt install -y spotify-client
  fi
}

install_obsidian() {
  case "$GUI_SOURCE" in
    flatpak) flatpak_install "$FP_OBSIDIAN" "Obsidian" || { gui_fallback_notice "Obsidian"; } ;;
    snap)    snap_install obsidian "" "Obsidian"       || { gui_fallback_notice "Obsidian"; } ;;
  esac
  if ! command -v obsidian >/dev/null 2>&1 && [[ "$GUI_SOURCE" == "apt" ]]; then
    wget -O obsidian.deb https://github.com/obsidianmd/obsidian-releases/releases/download/v1.7.7/obsidian_1.7.7_amd64.deb
    sudo apt install -y ./obsidian.deb
    rm obsidian.deb
  fi
}

install_postman() {
  case "$GUI_SOURCE" in
    flatpak) flatpak_install "$FP_POSTMAN" "Postman" || { gui_fallback_notice "Postman"; } ;;
    snap)    snap_install postman "" "Postman"       || { gui_fallback_notice "Postman"; } ;;
  esac
  if ! command -v postman >/dev/null 2>&1 && [[ "$GUI_SOURCE" == "apt" ]]; then
    wget -O postman.tar.gz https://dl.pstmn.io/download/latest/linux64
    sudo tar -xzf postman.tar.gz -C /opt
    sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman
    rm postman.tar.gz
    cat > ~/.local/share/applications/postman.desktop <<'EOF'
[Desktop Entry]
Name=Postman
Exec=/opt/Postman/Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Type=Application
Categories=Development;
EOF
  fi
}

install_chromium() {
  case "$GUI_SOURCE" in
    flatpak) flatpak_install "$FP_CHROMIUM" "Chromium" || { gui_fallback_notice "Chromium"; } ;;
    snap)    snap_install chromium "" "Chromium"       || { gui_fallback_notice "Chromium"; } ;;
  esac
  if ! command -v chromium-browser >/dev/null 2>&1 && ! command -v chromium >/dev/null 2>&1 && [[ "$GUI_SOURCE" == "apt" ]]; then
    sudo apt install -y chromium-browser || sudo apt install -y chromium || echo_warn "Chromium apt install failed"
  fi
}

install_pgadmin() {
  local prompt="Install pgAdmin (PostgreSQL GUI client)?"
  if prompt_install "$prompt"; then
    case "$GUI_SOURCE" in
      flatpak)
        flatpak_install "$FP_PGADMIN" "pgAdmin" || {
          gui_fallback_notice "pgAdmin"
          if ! command -v pgadmin4 >/dev/null 2>&1; then
            curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/pgadmin.gpg
            echo "deb [signed-by=/usr/share/keyrings/pgadmin.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list
            sudo apt install -y pgadmin4-desktop
          fi
        }
        ;;
      snap)
        snap_install pgadmin4 "" "pgAdmin" || {
          gui_fallback_notice "pgAdmin"
          if ! command -v pgadmin4 >/dev/null 2>&1; then
            curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/pgadmin.gpg
            echo "deb [signed-by=/usr/share/keyrings/pgadmin.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list
            sudo apt install -y pgadmin4-desktop
          fi
        }
        ;;
      *)
        if ! command -v pgadmin4 >/dev/null 2>&1; then
          curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/pgadmin.gpg
          echo "deb [signed-by=/usr/share/keyrings/pgadmin.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list
          sudo apt install -y pgadmin4-desktop
        fi
        ;;
    esac
    echo_info "pgAdmin installation step complete"
  else
    echo_warn "Skipping pgAdmin"
  fi
}

install_postgresql() {
  sudo apt install -y postgresql postgresql-contrib
  echo_info "PostgreSQL installed (default user: postgres)"
  install_pgadmin
}

install_obs_studio() {
  case "$GUI_SOURCE" in
    flatpak) flatpak_install "$FP_OBS" "OBS Studio" || { gui_fallback_notice "OBS Studio"; } ;;
    snap)    echo_warn "No official snap for OBS Studio; using apt." ;;
  esac
  if ! command -v obs >/dev/null 2>&1 && ! command -v obs-studio >/dev/null 2>&1; then
    sudo apt install -y obs-studio
  fi
}

install_gimp() {
  case "$GUI_SOURCE" in
    flatpak) flatpak_install "$FP_GIMP" "GIMP" || { gui_fallback_notice "GIMP"; } ;;
    snap)    snap_install gimp "" "GIMP"       || { gui_fallback_notice "GIMP"; } ;;
  esac
  if ! command -v gimp >/dev/null 2>&1 && [[ "$GUI_SOURCE" == "apt" ]]; then
    sudo apt install -y gimp
  fi
}

install_inkscape() {
  case "$GUI_SOURCE" in
    flatpak) flatpak_install "$FP_INKSCAPE" "Inkscape" || { gui_fallback_notice "Inkscape"; } ;;
    snap)    snap_install inkscape "" "Inkscape"       || { gui_fallback_notice "Inkscape"; } ;;
  esac
  if ! command -v inkscape >/dev/null 2>&1 && [[ "$GUI_SOURCE" == "apt" ]]; then
    sudo apt install -y inkscape
  fi
}



# ---------------------- Flatpak / Snap GUI Source Logic ----------------------
# Determine availability
FLATPAK_AVAILABLE=false
SNAP_AVAILABLE=false
command -v flatpak >/dev/null 2>&1 && FLATPAK_AVAILABLE=true
command -v snap    >/dev/null 2>&1 && SNAP_AVAILABLE=true

GUI_SOURCE=""   # flatpak | snap | apt

choose_gui_source() {
    # Override flag takes absolute priority if valid
    if [[ -n "$GUI_SOURCE_OVERRIDE" ]]; then
        case "$GUI_SOURCE_OVERRIDE" in
            flatpak|snap|apt)
                GUI_SOURCE="$GUI_SOURCE_OVERRIDE"
                echo_info "GUI source overridden by flag: $GUI_SOURCE"
                return
                ;;
            *)
                echo_warn "Invalid --gui-source value '$GUI_SOURCE_OVERRIDE'; ignoring override."
                ;;
        esac
    fi

    # If both available, ask user preference
    if $FLATPAK_AVAILABLE && $SNAP_AVAILABLE; then
        if prompt_install "Prefer Flatpak over Snap for GUI apps?"; then
            GUI_SOURCE="flatpak"
        else
            GUI_SOURCE="snap"
        fi
        return
    fi

    # Only flatpak available
    if $FLATPAK_AVAILABLE; then
        GUI_SOURCE="flatpak"
        return
    fi

    # Only snap available
    if $SNAP_AVAILABLE; then
        GUI_SOURCE="snap"
        return
    fi

    # Neither installed: default to apt
    echo_info "Neither Flatpak nor Snap detected. Using apt for GUI apps."
    GUI_SOURCE="apt"
}

choose_gui_source
# echo_info "GUI application packaging source selected: $GUI_SOURCE"

# Initialize Flathub if using Flatpak
setup_flathub() {
    if [[ "$GUI_SOURCE" == "flatpak" ]]; then
        if ! flatpak remotes | awk '{print $1}' | grep -qx flathub; then
            echo_info "Adding Flathub remote..."
            sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi
    fi
}

setup_snap() {
    if [[ "$GUI_SOURCE" == "snap" ]]; then
        if [ -f /etc/apt/preferences.d/nosnap.pref ]; then
            echo_info "Removing nosnap.pref to enable snap installs"
            sudo rm /etc/apt/preferences.d/nosnap.pref
        fi
        if ! command -v snap >/dev/null 2>&1; then
            echo_info "Installing snapd..."
            sudo apt install -y snapd
        fi
        # Optional store (Ubuntu flavors typically)
        if ! snap list | awk '{print $1}' | grep -qx snap-store 2>/dev/null; then
            sudo snap install snap-store || echo_warn "snap-store install failed (continuing)"
        fi
    fi
}

setup_flathub
setup_snap

# Helper functions for GUI installations
flatpak_install() {
    local app_id="$1" friendly="$2"
    if flatpak list --app | awk '{print $1}' | grep -qx "$app_id"; then
        echo_info "Flatpak $friendly ($app_id) already installed"
        return 0
    fi
    echo_info "Installing Flatpak $friendly ($app_id)..."
    if [[ "$AUTO_YES" == true ]]; then
        flatpak install -y flathub "$app_id" || return 1
    else
        flatpak install flathub "$app_id" || return 1
    fi
}

snap_install() {
    local pkg="$1" flags="$2" friendly="$3"
    if snap list | awk '{print $1}' | grep -qx "$pkg"; then
        echo_info "Snap $friendly ($pkg) already installed"
        return 0
    fi
    echo_info "Installing Snap $friendly ($pkg)..."
    if sudo snap install "$pkg" $flags; then
        return 0
    else
        return 1
    fi
}

# Fallback messaging
gui_fallback_notice() {
    local name="$1"
    echo_warn "Primary GUI source ($GUI_SOURCE) failed for $name; falling back to native package method"
}

# Mapping for Flatpak IDs
FP_VSCODE="com.visualstudio.code"
FP_DISCORD="com.discordapp.Discord"
FP_SLACK="com.slack.Slack"
FP_ZOOM="us.zoom.Zoom"
FP_SPOTIFY="com.spotify.Client"
FP_POSTMAN="com.getpostman.Postman"
FP_OBSIDIAN="md.obsidian.Obsidian"
FP_CHROMIUM="org.chromium.Chromium"
FP_VLC="org.videolan.VLC"
FP_OBS="com.obsproject.Studio"
FP_FLAMESHOT="org.flameshot.Flameshot"
FP_ALACRITTY="org.alacritty.Alacritty"
FP_PGADMIN="io.pgadmin.pgadmin4"
FP_ZED="dev.zed.Zed"
FP_GIMP="org.gimp.GIMP"
FP_INKSCAPE="org.inkscape.Inkscape"

# ------------------------------- Summary -------------------------------------
show_summary() {
    echo_info "================================"
    echo_info "Setup Complete!"
    echo_info "================================"
    echo
    echo_info "GUI packaging source used: $GUI_SOURCE"
    if [[ "$GUI_SOURCE" == "flatpak" ]]; then
        echo_info "Flatpak list: flatpak list --app"
        echo_info "Flatpak update: flatpak update -y"
    elif [[ "$GUI_SOURCE" == "snap" ]]; then
        echo_info "Snap list: snap list"
        echo_info "Snap update: sudo snap refresh"
    else
        echo_info "GUI apps installed via apt/deb"
    fi
    if [[ -n "$GUI_SOURCE_OVERRIDE" ]]; then
        echo_info "GUI source was forced via flag: $GUI_SOURCE_OVERRIDE"
    fi
    echo
    echo_info "Next steps:"
    echo "  1. Log out/in (or reboot) for shell & group changes (Docker, zsh)"
    echo "  2. Configure GNOME Extensions (if installed)"
    echo "  3. Adjust terminal settings (Alacritty config at ~/.config/alacritty/alacritty.yml)"
    echo "  4. Add/clone your dotfiles"
    echo "  5. Verify language managers (nvm, pyenv, rustup, go)"
    echo
    echo_info "Version manager quick refs:"
    echo "  Node: nvm install --lts | nvm use <version>"
    echo "  Python: pyenv install 3.12.0 | pyenv global 3.12.0"
    echo "  Rust: rustup update | rustup toolchain list"
    echo "  Go: go version"
    echo
    echo_info "Docker tips:"
    echo "  Test: docker run hello-world"
    echo "  If permission denied: newgrp docker OR logout/login"
    echo "  Compose: docker compose up -d"
    echo
    echo_info "PostgreSQL quick setup:"
    echo "  sudo -u postgres psql"
    echo "  CREATE USER youruser WITH PASSWORD 'yourpass';"
    echo "  CREATE DATABASE yourdb OWNER youruser;"
    echo
    echo_info "Zsh tips:"
    echo "  Edit: nano ~/.zshrc"
    echo "  Plugins: plugins=(git zsh-autosuggestions zsh-syntax-highlighting)"
    echo "  Apply: source ~/.zshrc"
    echo
    echo_warn "IMPORTANT: Logout & login for Docker group and default shell changes."
    echo_info "System: $DISTRO $DISTRO_VERSION"
    echo_info "All requested tasks processed."
    echo
}

start_installs() {
    echo
    show_logo
    echo
    echo "Welcome to PUNK_OS!!!"
    echo "This script is designed to help you quickly set up a development environment on an Ubuntu-based system."
    echo
    if prompt_install "Are you ready to get started?"; then
        install_fzf
        echo_info "Running updates..."
        sudo apt update -qq
        select_installations_menu || true
        run_selected_installations
        sudo apt update -qq
        show_summary
    else
        GUI_SOURCE="snap"
    fi
}

start_installs
