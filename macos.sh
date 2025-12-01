#!/bin/bash
###############################################################################
# 🎸 Punk_OS - macOS Development Environment Setup Script 🎸
# Compatible with macOS Ventura (13) and newer. Probably fine on Monterey too.
#
# This script is interactive (we ask before we brew). Add -y/--yes to auto-yes
# everything like the chaotic good developer you are.
###############################################################################

set -euo pipefail

# ----------------------- Output Formatting (Making things pretty) ------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

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

# ------------------------ Prompt Function (Ask before we act) ---------------
AUTO_YES=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes)
      AUTO_YES=true
      shift
      ;;
    -h|--help)
      cat <<'USAGE'
Usage: macos.sh [options]

Options:
  -y, --yes    Non-interactive mode (auto accept all prompts)
  -h, --help   Show this help message

Examples:
  ./macos.sh
  ./macos.sh -y
USAGE
      exit 0
      ;;
    *)
      echo_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

prompt_install() {
  local prompt_text="$1"
  if [[ "$AUTO_YES" == true ]]; then
    echo_info "Auto-yes mode: $prompt_text"
    return 0
  fi
  read -p "$prompt_text (y/n) " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]]
}

# ------------------------ Safety Checks (Hold my LaCroix) -------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo_error "This script is for macOS. Your system says it's $(uname -s)."
  exit 1
fi

if ! command -v xcode-select >/dev/null 2>&1; then
  echo_error "Missing xcode-select? That's suspicious."
fi

COMPLETED_STEPS=()

record_step() {
  COMPLETED_STEPS+=("$1")
}

# -------------------------- Homebrew Management -----------------------------
ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    echo_info "Homebrew already installed."
    eval "$(brew shellenv)"
    return
  fi

  echo_info "Installing Homebrew (please don't close this terminal)..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -d /opt/homebrew/bin ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo_info "Detected Apple Silicon Homebrew at /opt/homebrew."
  elif [[ -d /usr/local/bin && -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    echo_info "Detected Intel Homebrew at /usr/local."
  else
    echo_warn "Homebrew installed but could not auto-detect location. Add it to PATH manually."
  fi
}

install_rosetta_if_needed() {
  if [[ $(uname -m) == "arm64" ]]; then
    if ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
      echo_info "Installing Rosetta 2 for Intel-only tools..."
      /usr/sbin/softwareupdate --install-rosetta --agree-to-license || echo_warn "Rosetta install skipped. Some Intel-only tools may fail."
    fi
  fi
}

ensure_mas_cli() {
  if ! command -v mas >/dev/null 2>&1; then
    echo_info "Installing mas (Mac App Store CLI)..."
    brew install mas
  fi
}

# ---------------------------- Install Functions -----------------------------
install_xcode_cli() {
  if xcode-select -p >/dev/null 2>&1; then
    echo_info "Command Line Tools already installed."
  else
    echo_info "Installing Xcode Command Line Tools..."
    xcode-select --install || echo_warn "If a GUI prompt appeared, finish it manually."
  fi
  record_step "Xcode Command Line Tools"
}

install_fzf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo_info "Installing fzf (fuzzy finder for interactive menu)..."
    brew install fzf
  fi
}

select_installations_menu() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo_warn "fzf not found; skipping fancy interactive menu (sad face)."
    return 1
  fi
  [[ "${FZF_DEFAULT_OPTS:-}" == *"--tac"* ]] && echo_warn "Detected --tac in FZF_DEFAULT_OPTS (reverses order). Overriding because we like things our way."
  echo_info "Launching interactive menu (choose your adventure)..."
  local menu
  FZF_DEFAULT_OPTS='' \
  menu=$(for i in "${!INSTALL_MENU[@]}"; do
            local item="${INSTALL_MENU[$i]}"
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

# Execute only selected functions (Let's do this!)
run_selected_installations() {
  if [[ ${#SELECTED_INSTALL_FUNCS[@]} -eq 0 ]]; then
    echo_warn "No selections? Alright, nothing to do here. 🤷"
    return 0
  fi
  for fn in "${SELECTED_INSTALL_FUNCS[@]}"; do
    if declare -F "$fn" >/dev/null 2>&1; then
      echo_info "Running: $fn"
      "$fn"
    else
      echo_warn "Undefined function selected: $fn (this shouldn't happen, but here we are)"
    fi
  done
}

install_homebrew_basics() {
  echo_info "Installing essential CLI packages via Homebrew..."
  brew install git gh wget curl gnu-sed gnu-tar gnupg coreutils make cmake
  record_step "Essential CLI packages"
}

install_modern_cli_suite() {
  echo_info "Installing modern CLI goodies..."
  brew install bat eza fd ripgrep tldr tree jq httpie
  record_step "Modern CLI tools"
}

install_shell_upgrades() {
  echo_info "Installing shell upgrades (zsh plugins, starship)..."
  brew install zsh zsh-autosuggestions zsh-syntax-highlighting starship
  record_step "Shell upgrades"
}

install_nvm_manager() {
  echo_info "Installing nvm (Node Version Manager) and Node.js LTS..."
  brew install nvm
  record_step "nvm"

  export NVM_DIR="$HOME/.nvm"
  mkdir -p "$NVM_DIR"

  local nvm_script=""
  if command -v brew >/dev/null 2>&1; then
    local brew_prefix
    brew_prefix=$(brew --prefix nvm 2>/dev/null || true)
    if [[ -n "$brew_prefix" && -s "$brew_prefix/nvm.sh" ]]; then
      nvm_script="$brew_prefix/nvm.sh"
    fi
  fi
  if [[ -z "$nvm_script" && -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
    nvm_script="/opt/homebrew/opt/nvm/nvm.sh"
  elif [[ -z "$nvm_script" && -s "/usr/local/opt/nvm/nvm.sh" ]]; then
    nvm_script="/usr/local/opt/nvm/nvm.sh"
  fi

  if [[ -z "$nvm_script" ]]; then
    echo_warn "nvm script not found in Homebrew prefix. Skipping Node.js install."
    return
  fi

  # shellcheck source=/dev/null
  source "$nvm_script"
  if command -v nvm >/dev/null 2>&1; then
    echo_info "Installing Node.js LTS via nvm..."
    nvm install --lts
    nvm alias default lts/*
    record_step "Node.js LTS"
  else
    echo_warn "nvm command unavailable after install; skipping Node.js LTS."
  fi
}

install_pyenv_manager() {
  echo_info "Installing pyenv (Python version manager)..."
  brew install pyenv
  record_step "pyenv"
}

install_go_toolchain() {
  echo_info "Installing Go toolchain..."
  brew install go
  record_step "Go toolchain"
}

install_rust_toolchain() {
  echo_info "Installing rustup (Rust toolchain installer)..."
  brew install rustup-init
  record_step "Rust toolchain"
}


install_vscode() {
  echo_info "Installing Visual Studio Code..."
  brew install --cask visual-studio-code
  record_step "VS Code"
}

install_zed_editor() {
  echo_info "Installing Zed editor..."
  brew install --cask zed
  record_step "Zed"
}

install_iterm2() {
  echo_info "Installing iTerm2..."
  brew install --cask iterm2
  record_step "iTerm2"
}

install_warp_terminal() {
  echo_info "Installing Warp terminal..."
  brew install --cask warp
  record_step "Warp terminal"
}

install_alacritty_app() {
  echo_info "Installing Alacritty..."
  brew install --cask alacritty
  record_step "Alacritty"
}

install_slack_app() {
  echo_info "Installing Slack..."
  brew install --cask slack
  record_step "Slack"
}

install_discord_app() {
  echo_info "Installing Discord..."
  brew install --cask discord
  record_step "Discord"
}

install_zoom_app() {
  echo_info "Installing Zoom..."
  brew install --cask zoom
  record_step "Zoom"
}

install_firefox_app() {
  echo_info "Installing Firefox..."
  brew install --cask firefox
  record_step "Firefox"
}

install_chrome_app() {
  echo_info "Installing Google Chrome..."
  brew install --cask google-chrome
  record_step "Google Chrome"
}

install_notion_app() {
  echo_info "Installing Notion..."
  brew install --cask notion
  record_step "Notion"
}

install_obsidian_app() {
  echo_info "Installing Obsidian..."
  brew install --cask obsidian
  record_step "Obsidian"
}

install_rectangle_app() {
  echo_info "Installing Rectangle (window manager)..."
  brew install --cask rectangle
  record_step "Rectangle"
}

install_devops_tools() {
  echo_info "Installing Docker and friends..."
  brew install --cask docker
  brew install kubectl kubectx helm
  record_step "DevOps tools"
}

install_postman() {
  echo_info "Installing Postman..."
  brew install --cask postman
  record_step "Postman"
}

install_gimp_app() {
  echo_info "Installing GIMP..."
  brew install --cask gimp
  record_step "GIMP"
}

install_inkscape_app() {
  echo_info "Installing Inkscape..."
  brew install --cask inkscape
  record_step "Inkscape"
}

install_obs_app() {
  echo_info "Installing OBS Studio..."
  brew install --cask obs
  record_step "OBS Studio"
}

install_spotify_app() {
  echo_info "Installing Spotify..."
  brew install --cask spotify
  record_step "Spotify"
}

install_davinci_resolve() {
  echo_info "Installing DaVinci Resolve (video editor)..."
  brew install --cask davinci-resolve
  record_step "DaVinci Resolve"
}

install_parallels_app() {
  echo_info "Installing Parallels Desktop..."
  brew install --cask parallels
  record_step "Parallels Desktop"
}

install_affinity_suite() {
  echo_info "Installing Affinity suite (Designer, Photo, Publisher) via Mac App Store..."
  brew install --cask affinity
  record_step "Affinity suite"
}

install_fonts() {
  echo_info "Installing developer fonts..."
  brew tap homebrew/cask-fonts
  brew install --cask font-jetbrains-mono font-fira-code font-cascadia-code
  record_step "Developer fonts"
}

install_bartender_app() {
  echo_info "Installing Bartender..."
  brew install --cask bartender
  record_step "Bartender"
}

install_cleanshot_app() {
  echo_info "Installing CleanShot X..."
  brew install --cask cleanshot
  record_step "CleanShot X"
}

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo_info "Installing Oh My Zsh (prepare for terminal awesomeness)..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    chsh -s "$(which zsh)"
    echo_info "Zsh set as default shell (logout/login to activate your new superpowers)"
  else
    echo_info "Oh My Zsh already installed (you're already cool)"
  fi
  record_step "Oh My Zsh"
}

create_projects_dir() {
  echo_info "Creating ~/Projects directory (because code in random places is chaos)..."
  mkdir -p ~/Projects
  record_step "Projects directory"
}

install_archive_tools() {
  echo_info "Installing archive/compression tools (for all those weird file formats)..."
  brew install p7zip
  record_step "Archive tools"
}

install_postgresql() {
  echo_info "Installing PostgreSQL (the database that's actually fun to say out loud)..."
  brew install postgresql
  brew services start postgresql
  echo_info "PostgreSQL installed. Run 'brew services start postgresql' to start it."
  record_step "PostgreSQL"
}

# Ordered list of prompts and functions
INSTALL_MENU=(
  "install_xcode_cli:Install Xcode Command Line Tools (compiler & headers)?"
  "install_homebrew_basics:Install essential CLI packages (git, curl, etc.)?"
  "install_modern_cli_suite:Install modern CLI tools (bat, eza, fd, ripgrep, tldr, tree, jq, and httpie)?"
  "install_shell_upgrades:Install shell upgrades (zsh plugins, starship)?"
  "install_oh_my_zsh:Install Oh My Zsh with plugins?"
  "install_pyenv_manager:Install pyenv (Python versions)?"
  "install_go_toolchain:Install Go toolchain (go command)?"
  "install_rust_toolchain:Install Rust toolchain (rustup & cargo)?"
  "install_nvm_manager:Install nvm + Node.js LTS?"
  "install_vscode:Install Visual Studio Code (Microsoft editor)?"
  "install_zed_editor:Install Zed editor (fast Rust editor)?"
  "install_iterm2:Install iTerm2 (power terminal)?"
  "install_warp_terminal:Install Warp terminal (GPU accelerated)?"
  "install_alacritty_app:Install Alacritty terminal (lightweight)?"
  "install_rectangle_app:Install Rectangle (window manager)?"
  "install_devops_tools:Install Docker Desktop + Kubernetes tooling?",
  "install_postman:Install Postman (API testing)?"
  "install_postgresql:Install PostgreSQL database?"
  "install_archive_tools:Install archive/compression tools (zip, 7z, rar)?"
  "create_projects_dir:Create ~/Projects directory?",
  "install_affinity_suite:Install Affinity Studio (graphic design software)?"
  "install_gimp_app:Install GIMP (image editor)?"
  "install_inkscape_app:Install Inkscape (vector editor)?"
  "install_obs_app:Install OBS Studio (record/stream)?"
  "install_davinci_resolve:Install DaVinci Resolve (video editor)?"
  "install_parallels_app:Install Parallels Desktop (for running VMs)?"
  "install_slack_app:Install Slack?"
  "install_discord_app:Install Discord?"
  "install_zoom_app:Install Zoom?"
  "install_firefox_app:Install Firefox?"
  "install_chrome_app:Install Google Chrome?"
  "install_notion_app:Install Notion?"
  "install_obsidian_app:Install Obsidian?"
  "install_spotify_app:Install Spotify (music streaming)?"
  "install_fonts:Install developer fonts (JetBrains Mono, Fira Code, Cascadia Code)?"
  "install_bartender_app:Install Bartender (menu bar organizer)?"
  "install_cleanshot_app:Install CleanShot X (screenshot tool)?"
  "install_raycast_app:Install Raycast (launcher/shortcuts)?"
)

show_summary() {
  echo
  echo_info "================================"
  echo_info "🎉  macOS setup complete!"
  echo_info "================================"
  if ((${#COMPLETED_STEPS[@]})); then
    echo "Installed items:"
    for step in "${COMPLETED_STEPS[@]}"; do
      echo "  - $step"
    done
  else
    echo_warn "You skipped everything. Bold choice."
  fi
  echo
  echo_info "Homebrew tips:"
  echo "  brew doctor        # Check your setup"
  echo "  brew update && brew upgrade"
  echo "  brew cleanup"
  echo
  echo_info "Starship prompt: add 'eval \"\$(starship init zsh)\"' to ~/.zshrc"
  echo_info "nvm: add 'source $(brew --prefix nvm)/nvm.sh' to your shell config"
  echo
  echo_info "Built with ❤️  and caffeine. Enjoy your shiny dev environment!"
}

main() {
  echo
  show_logo
  echo
  echo "\n🎸 Welcome to Punk_OS macOS setup! Let's brew some chaos."
  install_rosetta_if_needed
  ensure_homebrew
  brew update
  install_fzf
  select_installations_menu || true
  run_selected_installations
  show_summary
}

main "$@"
