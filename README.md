![PUNK_OS logo](https://github.com/break-stuff/punk_os/blob/main/assets/punk_os-blue.png?raw=true)

# Punk_OS

*Because spending 3 days manually installing packages is so 2010* 🎸

Transform your boring, vanilla Ubuntu installation into a fully-loaded development beast with just one script. It's like a makeover montage, but for your OS (and with fewer costume changes).

## Overview

The `setup.sh` script is your new best friend – an interactive installer that handles all the tedious setup work so you can get straight to the fun stuff (breaking things and fixing them). It comes loaded with dev tools, programming languages, IDEs, productivity apps, and enough system optimizations to make your computer feel like it just had an espresso.

**Compatibility**: Works on Ubuntu 20.04+, Pop!_OS, Linux Mint, Elementary OS, Zorin OS, and basically any Ubuntu-flavored distro. If it uses apt, we're good to go! 🚀

## Quick Start

```bash
/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/break-stuff/punk_os/refs/heads/main/setup.sh || curl -fsSL https://raw.githubusercontent.com/break-stuff/punk_os/refs/heads/main/setup.sh)"
```

**Important:** Do NOT run this script with `sudo`. Seriously. Don't do it. The script is smart enough to ask for your password when it needs superpowers. Running it with sudo is like wearing a tuxedo to a punk show – technically possible, but you're doing it wrong.

## What Does This Script Do?

Glad you asked! The setup script is fully interactive (it won't install anything you don't want), giving you total control over your digital destiny. Here's the buffet of goodies available:

### ⚡ System Optimizations

*Making your computer go brrrrr*

- **SSD Optimization**: Enables `fstrim` timer so your SSD lives longer than your last houseplant 🌱
- **TLP (Battery Life)**: Because nobody wants their laptop dying mid-meeting (again)
- **File Watcher Limits**: Cranks up `inotify` limits so VS Code and webpack don't throw tantrums
- **Restricted Extras**: All the proprietary stuff Ubuntu doesn't include by default (Nvidia drivers, MP3s, MP4s, and other legally questionable abbreviations)

### ⌨️ Keyboard Configuration

- **Function Key Mode**: Make F1-F12 actually do function key things instead of changing volume (revolutionary, I know)
- **Mac-Style Keyboard Shortcuts**: (*For the ex-Mac users in denial*) muscle memory is hard to break, we get it. This makes `cmd` work like you're used to
  - **Note**: If shortcuts act weird (or don't work at all), run the `kinto_patch.sh` script.

### 🔧 Essential Development Tools

*The stuff you'll use every single day*

- **Essential Dev Tools**: The classics that never go out of style:
  - `build-essential` (GCC, G++, make, etc.) – Compilers! For when you need to build things from scratch like a pioneer
  - `git` – Because `final_FINAL_v2_ACTUALLY_FINAL.zip` is not a version control strategy
  - `curl` & `wget` – Download all the things! ⬇️
  - `vim` & `neovim` – Text editors for when you're feeling adventurous (and remember how to exit)
  - `htop` – Like Task Manager, but cooler and with colors
  - `tmux` – Multiple terminals in one terminal. Terminal inception! 🤯
  - `zsh` – Bash's cooler, more feature-rich cousin
  - `net-tools` – Network utilities (for when WiFi inevitably breaks)

### 🛠️ Modern CLI Tools

*Your grandpa's Unix tools, but faster and shinier*

- **`bat`** – Like `cat`, but with syntax highlighting and Git integration. It's what `cat` dreams of being when it grows up
- **`fzf`** – Fuzzy finder that makes searching through files feel like magic ✨
- **`ripgrep` (rg)** – `grep` on steroids. Searches code so fast you'll wonder what it's hiding
- **`fd`** – `find` command, but actually user-friendly (what a concept!)
- **`tldr`** – Man pages for people who don't have 3 hours to read documentation

### 🔧 Essential Developer Utilities

*The tools you didn't know you needed until you REALLY needed them*

- **`jq`** – JSON wrangler extraordinaire. Makes API responses actually readable
- **`tree`** – Shows your directory structure in a pretty tree format (great for README screenshots)
- **`httpie`** – Like `curl`, but for humans who value their sanity

### 📦 Archive & Compression Tools

*For when people send you files in weird formats*

- **Archive Tools**: Unzip, compress, extract – basically everything:
  - `zip/unzip` – The classic
  - `p7zip-full` – For those 7z files your friend insists on using
  - `unrar` – Because someone, somewhere, is still using RAR files in 2025

### 🐳 Containerization

*"It works on my machine" – Now it works everywhere!*

- **Docker**: Full Docker setup with all the bells and whistles:
  - Docker Engine – The container overlord
  - Docker Compose – For when one container just isn't enough chaos
  - BuildKit support – Makes builds fast (or at least less painfully slow)
  - No sudo required – We add you to the docker group automatically (you're welcome)

### 🌐 Node.js Development

*JavaScript, but make it server-side*

- **Node.js LTS**: The latest Long Term Support version (because living on the bleeding edge is overrated)
- **Node Version Manager (nvm)**: Switch Node versions like changing socks. Essential when that one project still uses Node 14 for "reasons"

### 🐍 Python Development

*The language named after Monty Python (no, really)*

- **Python Tools**: Everything you need to Python properly:
  - `python3-pip` – Package installer (prepare for dependency hell)
  - `python3-venv` – Virtual environments to keep your projects from fighting
  - `python3-dev` – Headers and stuff for building packages
- **pyenv**: Juggle multiple Python versions like a circus performer 🎪

### 🦀 Rust Development

*The language that won't let you shoot yourself in the foot*

- **Rust Toolchain**: Complete Rust setup via rustup (the compiler that bullies you into writing better code)
- **Cargo**: Package manager included (much friendlier than the compiler)

### 🐹 Go Development

*Fast, simple, and has a cute gopher mascot*

- **Go (Golang)**: Latest stable compiler and toolchain
- **GOPATH**: Auto-configured with `~/go` (the only path Go cares about)
- **Tools**: `go build`, `go run`, `go get` – Everything you need to Go go go!

### 💻 IDEs & Editors

*Where the actual coding happens*

- **Visual Studio Code**: Microsoft's love letter to developers (and it's actually really good)
- **Zed IDE**: The new kid on the block. Fast, modern, written in Rust (because of course it is)
- **Alacritty**: Terminal emulator so fast it uses your GPU. For when you need those FPS in your CLI 🎮

### 🔤 Developer Fonts

*Making your code look pretty since... well, recently*

Professional monospaced fonts with ligatures (fancy connected characters):

- **JetBrains Mono**: Clean and modern, like a minimalist coffee shop
- **Fira Code**: The font that started the ligature craze
- **Cascadia Code**: Microsoft's attempt (and they actually nailed it)

### 🐚 Shell Enhancement

*Pimp your terminal*

- **Oh My Zsh**: Zsh, but on maximum overdrive:
  - `zsh-autosuggestions` – Finishes your commands like an overeager friend
  - `zsh-syntax-highlighting` – Colors that tell you if you messed up BEFORE you hit enter
  - Set as default shell automatically (goodbye, bash!)
  - Pre-loaded with useful aliases so you can be lazy efficiently

### 🗂️ Development Setup

- **Projects Directory**: Creates `~/Projects` because having all your code in random places is a nightmare

### 📱 Productivity Applications

*Apps for when you need to pretend you're working*

- **Communication**: Discord (for the memes), Slack (for work), Zoom (for mandatory video calls)
- **Media**: Spotify – Because coding in silence is weird
- **Note-taking**: Obsidian – For building your second brain (your first one is full)
- **Screen Recording**: OBS Studio – Capture your bugs in glorious 4K
- **Web Browser**: Chromium – Like Chrome, but without Google looking over your shoulder

### 🛠️ API Development Tools

*For poking APIs until they respond*

- **Postman**: The industry standard for making your APIs behave
- **HTTPie**: Command-line HTTP client that's actually pleasant to use (also installed with Developer Utilities)

### 📸 Screenshot Tools

*For capturing bugs before they disappear*

- **Flameshot**: Screenshot tool with annotation powers. Perfect for pointing out exactly where things broke

### 🎨 Graphics & Design

*For when code isn't pretty enough*

- **GIMP**: Photoshop's scrappy open-source cousin. Does basically everything but won't drain your wallet
- **Inkscape**: Vector graphics editor for making SVGs and logos that scale infinitely (unlike your motivation)

### 🗄️ Database

*Where your data lives*

- **PostgreSQL**: The database that's actually fun to say out loud
  - Comes with all the contrib packages
  - Optional pgAdmin 4 for those who prefer clicking over typing SQL
  - We'll ask before installing pgAdmin (consent is important)

## Troubleshooting

*When things go sideways (they will)*

### Common Issues

**Mac Keyboard Shortcuts Not Working:**
- Your Cmd key acting like it has amnesia? Run the Kinto patch script:
  ```bash
  /bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/break-stuff/punk_os/refs/heads/main/kinto_patch.sh || curl -fsSL https://raw.githubusercontent.com/break-stuff/punk_os/refs/heads/main/kinto_patch.sh)"

  ```
- This patches the xkeysnail service's input.py file (it's like therapy for keyboard shortcuts)
- Automatically restarts the service after patching
- Note: Needs kinto-master extracted in ~/Downloads/

**Docker Permission Denied:**
- Log out and back in (the IT Crowd was right about turning it off and on again)
- Or try: `newgrp docker` (the lazy option)

**Command Not Found:**
- Did you try turning it off and on again? Just kidding. Do this: `source ~/.bashrc`
- Or open a fresh terminal (new terminal, new you)

**nvm Command Not Found:**
- Restart your terminal or run: `source ~/.bashrc`
- nvm needs a fresh shell to work its magic

**Python/Node Version Issues:**
- Wrong version? Switch with: `pyenv global <version>` or `nvm use <version>`
- Version managers are your friends (treat them well)

### Script Fails Midway

*When the universe decides to test your patience*

The script uses `set -e` so it bails at the first sign of trouble. If it fails:
1. Read the error message (I know, reading is hard, but try)
2. Fix the issue (usually your WiFi being dramatic)
3. Re-run the script – it's smart enough to skip stuff that's already installed

## Requirements

*What you need before we can make magic happen*

- **OS**: Ubuntu 20.04+ or any Ubuntu-flavored distro (Pop!_OS, Linux Mint, Elementary OS, Zorin OS, etc.)
- **Package Manager**: apt (if you don't have this, you're on the wrong distro, friend)
- **Network**: Internet connection (no, we can't download more RAM)
- **Storage**: At least 5GB free space (delete those old memes if needed)
- **User**: Non-root user with sudo privileges (we need to be powerful, not reckless)
- **Time**: 30-60 minutes (perfect time to make coffee, watch a YouTube video, or contemplate existence)

## What's Not Included

*We had to draw the line somewhere*

This script is focused on dev tools, so we're NOT including:
- Games or gaming stuff (this is work equipment, not a gaming rig... yet)
- 3D modeling software (Blender is cool but outside our scope)
- Hardware-specific drivers (your RGB keyboard is on its own)
- Custom kernel modifications (we like to live dangerously, but not THAT dangerously)
- Distribution-specific tweaks (we stick to standard Ubuntu packages)

## Contributing

*Want to make this even better? We're listening!*

Pull requests and issues are welcome! Help us:
- Add new development tools
- Fix compatibility issues
- Improve error handling
- Add productivity applications
- Make the script even more awesome

## Security Notes

*We're paranoid so you don't have to be*

- Downloads from official sources only (no sketchy websites)
- GPG keys verified where available (trust, but verify)
- No hardcoded credentials or API keys (we're not monsters)
- User prompted before installations (consent is sexy)

## License

This setup script is provided as-is for educational and development purposes. Individual software packages have their own licenses (we're not lawyers, please don't sue us). 

---

Built with ❤️ by developers who were tired of manual setups
