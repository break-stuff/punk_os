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
  if brew install git gh wget curl gnu-sed gnu-tar gnupg coreutils make cmake; then
    record_step "Essential CLI packages"
  else
    echo_error "Failed to install essential CLI packages"
  fi
}

install_modern_cli_suite() {
  echo_info "Installing modern CLI goodies..."
  if brew install bat eza fd ripgrep tldr tree jq httpie; then
    record_step "Modern CLI tools"
  else
    echo_error "Failed to install modern CLI tools"
  fi
}

install_shell_upgrades() {
  echo_info "Installing shell upgrades (zsh plugins, starship)..."
  if brew install zsh zsh-autosuggestions zsh-syntax-highlighting starship; then
    record_step "Shell upgrades"
  else
    echo_error "Failed to install shell upgrades"
  fi
}

install_nvm_manager() {
  echo_info "Installing nvm (Node Version Manager) and Node.js LTS..."
  if brew install nvm; then
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
      if nvm install --lts && nvm alias default lts/*; then
        record_step "Node.js LTS"
      else
        echo_error "Failed to install Node.js LTS"
      fi
    else
      echo_warn "nvm command unavailable after install; skipping Node.js LTS."
    fi
  else
    echo_error "Failed to install nvm"
  fi
}

install_pyenv_manager() {
  echo_info "Installing pyenv (Python version manager)..."
  if brew install pyenv; then
    record_step "pyenv"
  else
    echo_error "Failed to install pyenv"
  fi
}

install_go_toolchain() {
  echo_info "Installing Go toolchain..."
  if brew install go; then
    record_step "Go toolchain"
  else
    echo_error "Failed to install Go toolchain"
  fi
}

install_rust_toolchain() {
  echo_info "Installing rustup (Rust toolchain installer)..."
  if brew install rustup-init; then
    record_step "Rust toolchain"
  else
    echo_error "Failed to install Rust toolchain"
  fi
}


install_vscode() {
  if brew list --cask | grep -q visual-studio-code; then
    echo_info "Visual Studio Code already installed"
    record_step "VS Code"
  else
    echo_info "Installing Visual Studio Code..."
    if brew install --cask visual-studio-code; then
      record_step "VS Code"
    else
      echo_error "Failed to install Visual Studio Code"
    fi
  fi
}

install_zed_editor() {
  if brew list --cask | grep -q zed; then
    echo_info "Zed editor already installed"
    record_step "Zed"
  else
    echo_info "Installing Zed editor..."
    if brew install --cask zed; then
      record_step "Zed"
    else
      echo_error "Failed to install Zed editor"
    fi
  fi
}

install_iterm2() {
  if brew list --cask | grep -q iterm2; then
    echo_info "iTerm2 already installed"
    record_step "iTerm2"
  else
    echo_info "Installing iTerm2..."
    if brew install --cask iterm2; then
      record_step "iTerm2"
    else
      echo_error "Failed to install iTerm2"
    fi
  fi
}

install_warp_terminal() {
  if brew list --cask | grep -q warp; then
    echo_info "Warp terminal already installed"
    record_step "Warp terminal"
  else
    echo_info "Installing Warp terminal..."
    if brew install --cask warp; then
      record_step "Warp terminal"
    else
      echo_error "Failed to install Warp terminal"
    fi
  fi
}

install_alacritty_app() {
  if brew list --cask | grep -q alacritty; then
    echo_info "Alacritty already installed"
    record_step "Alacritty"
  else
    echo_info "Installing Alacritty..."
    if brew install --cask alacritty; then
      record_step "Alacritty"
    else
      echo_error "Failed to install Alacritty"
    fi
  fi
}

install_slack_app() {
  if brew list --cask | grep -q slack; then
    echo_info "Slack already installed"
    record_step "Slack"
  else
    echo_info "Installing Slack..."
    if brew install --cask slack; then
      record_step "Slack"
    else
      echo_error "Failed to install Slack"
    fi
  fi
}

install_discord_app() {
  if brew list --cask | grep -q discord; then
    echo_info "Discord already installed"
    record_step "Discord"
  else
    echo_info "Installing Discord..."
    if brew install --cask discord; then
      record_step "Discord"
    else
      echo_error "Failed to install Discord"
    fi
  fi
}

install_zoom_app() {
  if brew list --cask | grep -q zoom; then
    echo_info "Zoom already installed"
    record_step "Zoom"
  else
    echo_info "Installing Zoom..."
    if brew install --cask zoom; then
      record_step "Zoom"
    else
      echo_error "Failed to install Zoom"
    fi
  fi
}

install_firefox_app() {
  if brew list --cask | grep -q firefox; then
    echo_info "Firefox already installed"
    record_step "Firefox"
  else
    echo_info "Installing Firefox..."
    if brew install --cask firefox; then
      record_step "Firefox"
    else
      echo_error "Failed to install Firefox"
    fi
  fi
}

install_chrome_app() {
  if brew list --cask | grep -q google-chrome; then
    echo_info "Google Chrome already installed"
    record_step "Google Chrome"
  else
    echo_info "Installing Google Chrome..."
    if brew install --cask google-chrome; then
      record_step "Google Chrome"
    else
      echo_error "Failed to install Google Chrome"
    fi
  fi
}

install_notion_app() {
  if brew list --cask | grep -q notion; then
    echo_info "Notion already installed"
    record_step "Notion"
  else
    echo_info "Installing Notion..."
    if brew install --cask notion; then
      record_step "Notion"
    else
      echo_error "Failed to install Notion"
    fi
  fi
}

install_obsidian_app() {
  if brew list --cask | grep -q obsidian; then
    echo_info "Obsidian already installed"
    record_step "Obsidian"
  else
    echo_info "Installing Obsidian..."
    if brew install --cask obsidian; then
      record_step "Obsidian"
    else
      echo_error "Failed to install Obsidian"
    fi
  fi
}

install_rectangle_app() {
  if brew list --cask | grep -q rectangle; then
    echo_info "Rectangle already installed"
    record_step "Rectangle"
  else
    echo_info "Installing Rectangle (window manager)..."
    if brew install --cask rectangle; then
      record_step "Rectangle"
    else
      echo_error "Failed to install Rectangle"
    fi
  fi
}

install_devops_tools() {
  local attempted_install=false
  
  if ! brew list --cask | grep -q docker; then
    echo_info "Installing Docker..."
    if brew install --cask docker; then
      attempted_install=true
    else
      echo_error "Failed to install Docker"
    fi
  else
    echo_info "Docker already installed"
    attempted_install=true
  fi
  
  if ! brew list | grep -q kubectl; then
    echo_info "Installing kubectl..."
    if brew install kubectl; then
      attempted_install=true
    else
      echo_error "Failed to install kubectl"
    fi
  else
    echo_info "kubectl already installed"
    attempted_install=true
  fi
  
  if ! brew list | grep -q kubectx; then
    echo_info "Installing kubectx..."
    if brew install kubectx; then
      attempted_install=true
    else
      echo_error "Failed to install kubectx"
    fi
  else
    echo_info "kubectx already installed"
    attempted_install=true
  fi
  
  if ! brew list | grep -q helm; then
    echo_info "Installing helm..."
    if brew install helm; then
      attempted_install=true
    else
      echo_error "Failed to install helm"
    fi
  else
    echo_info "helm already installed"
    attempted_install=true
  fi
  
  if $attempted_install; then
    record_step "DevOps tools"
  fi
}

install_postman() {
  if brew list --cask | grep -q postman; then
    echo_info "Postman already installed"
    record_step "Postman"
  else
    echo_info "Installing Postman..."
    if brew install --cask postman; then
      record_step "Postman"
    else
      echo_error "Failed to install Postman"
    fi
  fi
}

install_gimp_app() {
  if brew list --cask | grep -q gimp; then
    echo_info "GIMP already installed"
    record_step "GIMP"
  else
    echo_info "Installing GIMP..."
    if brew install --cask gimp; then
      record_step "GIMP"
    else
      echo_error "Failed to install GIMP"
    fi
  fi
}

install_inkscape_app() {
  if brew list --cask | grep -q inkscape; then
    echo_info "Inkscape already installed"
    record_step "Inkscape"
  else
    echo_info "Installing Inkscape..."
    if brew install --cask inkscape; then
      record_step "Inkscape"
    else
      echo_error "Failed to install Inkscape"
    fi
  fi
}

install_obs_app() {
  if brew list --cask | grep -q obs; then
    echo_info "OBS Studio already installed"
    record_step "OBS Studio"
  else
    echo_info "Installing OBS Studio..."
    if brew install --cask obs; then
      record_step "OBS Studio"
    else
      echo_error "Failed to install OBS Studio"
    fi
  fi
}

install_spotify_app() {
  if brew list --cask | grep -q spotify; then
    echo_info "Spotify already installed"
    record_step "Spotify"
  else
    echo_info "Installing Spotify..."
    if brew install --cask spotify; then
      record_step "Spotify"
    else
      echo_error "Failed to install Spotify"
    fi
  fi
}

install_parallels_app() {
  if brew list --cask | grep -q parallels; then
    echo_info "Parallels Desktop already installed"
    record_step "Parallels Desktop"
  else
    echo_info "Installing Parallels Desktop..."
    if brew install --cask parallels; then
      record_step "Parallels Desktop"
    else
      echo_error "Failed to install Parallels Desktop"
    fi
  fi
}

install_affinity_suite() {
  if brew list --cask | grep -q affinity; then
    echo_info "Affinity suite already installed"
    record_step "Affinity suite"
  else
    echo_info "Installing Affinity suite (Designer, Photo, Publisher) via Mac App Store..."
    if brew install --cask affinity; then
      record_step "Affinity suite"
    else
      echo_error "Failed to install Affinity suite"
    fi
  fi
}

install_fonts() {
  local attempted_install=false
  
  if ! brew list --cask | grep -q font-jetbrains-mono; then
    echo_info "Installing JetBrains Mono font..."
    if brew install --cask font-jetbrains-mono 2>/dev/null; then
      attempted_install=true
      echo_info "JetBrains Mono font installed successfully"
    else
      echo_warn "JetBrains Mono font installation failed (may already be installed as variable font)"
    fi
  else
    echo_info "JetBrains Mono font already installed"
    attempted_install=true
  fi
  
  if ! brew list --cask | grep -q font-fira-code; then
    echo_info "Installing Fira Code font..."
    if brew install --cask font-fira-code; then
      attempted_install=true
      echo_info "Fira Code font installed successfully"
    else
      echo_error "Failed to install Fira Code font"
    fi
  else
    echo_info "Fira Code font already installed"
    attempted_install=true
  fi
  
  if ! brew list --cask | grep -q font-cascadia-code; then
    echo_info "Installing Cascadia Code font..."
    if brew install --cask font-cascadia-code; then
      attempted_install=true
      echo_info "Cascadia Code font installed successfully"
    else
      echo_error "Failed to install Cascadia Code font"
    fi
  else
    echo_info "Cascadia Code font already installed"
    attempted_install=true
  fi
  
  if $attempted_install; then
    record_step "Developer fonts"
  fi
}

install_bartender_app() {
  if brew list --cask | grep -q bartender; then
    echo_info "Bartender already installed"
    record_step "Bartender"
  else
    echo_info "Installing Bartender..."
    if brew install --cask bartender; then
      record_step "Bartender"
    else
      echo_error "Failed to install Bartender"
    fi
  fi
}

install_cleanshot_app() {
  if brew list --cask | grep -q cleanshot; then
    echo_info "CleanShot X already installed"
    record_step "CleanShot X"
  else
    echo_info "Installing CleanShot X..."
    if brew install --cask cleanshot; then
      record_step "CleanShot X"
    else
      echo_error "Failed to install CleanShot X"
    fi
  fi
}

install_raycast_app() {
  if brew list --cask | grep -q raycast; then
    echo_info "Raycast already installed"
    record_step "Raycast"
  else
    echo_info "Installing Raycast..."
    if brew install --cask raycast; then
      record_step "Raycast"
    else
      echo_error "Failed to install Raycast"
    fi
  fi
}

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo_info "Installing Oh My Zsh (prepare for terminal awesomeness)..."
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
      if git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null; then
        echo_info "Installed zsh-autosuggestions"
      else
        echo_warn "Failed to install zsh-autosuggestions"
      fi
      
      if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null; then
        echo_info "Installed zsh-syntax-highlighting"
      else
        echo_warn "Failed to install zsh-syntax-highlighting"
      fi
      
      if chsh -s "$(which zsh)"; then
        echo_info "Zsh set as default shell (logout/login to activate your new superpowers)"
      else
        echo_warn "Failed to set zsh as default shell"
      fi
      
      record_step "Oh My Zsh"
    else
      echo_error "Failed to install Oh My Zsh"
    fi
  else
    echo_info "Oh My Zsh already installed (you're already cool)"
    record_step "Oh My Zsh"
  fi
}

create_projects_dir() {
  echo_info "Creating ~/Projects directory (because code in random places is chaos)..."
  mkdir -p ~/Projects
  record_step "Projects directory"
}

install_archive_tools() {
  echo_info "Installing archive/compression tools (for all those weird file formats)..."
  if brew install p7zip; then
    record_step "Archive tools"
  else
    echo_error "Failed to install archive tools"
  fi
}

install_postgresql() {
  echo_info "Installing PostgreSQL (the database that's actually fun to say out loud)..."
  if brew install postgresql && brew services start postgresql; then
    echo_info "PostgreSQL installed. Run 'brew services start postgresql' to start it."
    record_step "PostgreSQL"
  else
    echo_error "Failed to install PostgreSQL"
  fi
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
  echo "Built with ❤️ and caffeine. Enjoy your shiny dev environment!"
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
