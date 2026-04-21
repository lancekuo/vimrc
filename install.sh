#!/usr/bin/env bash
set -euo pipefail

VIMHOME="$HOME/.vim"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# OS Detection
# =============================================================================

detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macos"
            PROFILE="$HOME/.bash_profile"
            ;;
        Linux*)
            OS="linux"
            PROFILE="$HOME/.bashrc"
            ;;
        *)
            die "Unsupported operating system: $(uname -s)"
            ;;
    esac
    echo "Detected OS: $OS (profile: $PROFILE)"
}

# Get Homebrew binary path based on OS, with fallback
get_brew_path() {
    if [[ "$OS" == "macos" ]]; then
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo "/opt/homebrew/bin/brew"; return
        elif [[ -f "/usr/local/bin/brew" ]]; then
            echo "/usr/local/bin/brew"; return
        fi
    else
        if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
            echo "/home/linuxbrew/.linuxbrew/bin/brew"; return
        fi
    fi
    # Fallback: find brew in PATH
    command -v brew 2>/dev/null || true
}

# =============================================================================
# Helper Functions
# =============================================================================

warn() {
    echo "$1" >&2
}

die() {
    warn "$1"
    exit 1
}

# Prompt user with y/n question, returns 0 for yes, 1 for no
prompt_yn() {
    local prompt="$1"
    local response
    read -rp "==> $prompt (y/n) " response
    [[ "$response" =~ ^[yY]([eE][sS])?$ ]]
}

# Append line to file only if it doesn't already exist
append_if_missing() {
    local file="$1"
    local line="$2"
    local marker="${3:-$line}"  # Optional marker to search for
    if ! grep -qF "$marker" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
        return 0
    fi
    return 1
}

# Create symlink with backup if target exists
safe_symlink() {
    local source="$1"
    local target="$2"
    mkdir -p "$(dirname "$target")"
    if [ -L "$target" ]; then
        echo "Symlink $target already exists, skipping."
    elif [ -e "$target" ]; then
        echo "Backing up existing $target to ${target}.bak"
        mv "$target" "${target}.bak"
        ln -s "$source" "$target"
    else
        ln -s "$source" "$target"
        echo "Created symlink: $target -> $source"
    fi
}

# =============================================================================
# Installation Sections
# =============================================================================

install_homebrew() {
    if command -v brew &>/dev/null; then
        echo "Homebrew already installed, skipping."
        return
    fi

    # Linux requires build dependencies
    if [[ "$OS" == "linux" ]]; then
        echo "Installing Homebrew dependencies for Linux..."
        if command -v apt-get &>/dev/null; then
            sudo apt-get update
            sudo apt-get install -y build-essential procps curl file git
        elif command -v yum &>/dev/null; then
            sudo yum groupinstall -y 'Development Tools'
            sudo yum install -y procps-ng curl file git
        fi
    fi

    # NONINTERACTIVE=1 skips "Press RETURN/ENTER" prompt
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Set PATH directly for current session (profile is generated later by setup_shell_profile)
    if [[ "$OS" == "linux" ]]; then
        export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
    elif [[ -d "/opt/homebrew" ]]; then
        export HOMEBREW_PREFIX="/opt/homebrew"
    else
        export HOMEBREW_PREFIX="/usr/local"
    fi
    export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
    export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
    export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"

    echo "Homebrew installed and configured."
}

install_core_tools() {
    # Core CLI tools
    # terraform is installed via tfenv (pinned to 1.5.7, last MPL-licensed release)
    brew install vim jq yq fzf git go tfenv terraform-ls bat node

    # Pin terraform to 1.5.7 (last MPL-licensed release; later versions are BUSL)
    if command -v tfenv &>/dev/null; then
        tfenv install 1.5.7 || true
        tfenv use 1.5.7
    fi

    # agtop - TUI for monitoring Claude Code / Codex sessions
    # Install into ~/.local (scoped to this command; leaves global npm prefix untouched)
    if command -v npm &>/dev/null; then
        mkdir -p "$HOME/.local/bin"
        npm install -g --prefix "$HOME/.local" @ldegio/agtop || true
    fi

    # bash-completion may conflict with util-linux on Linux
    brew install bash-completion 2>&1 || echo "Note: bash-completion skipped (may conflict with util-linux)"

    # AWS CLI
    brew install awscli

    # Kubernetes tools
    brew install kubernetes-cli kubectx helm k9s

    # GitOps tools
    brew install argocd kargo

    # Install fzf key bindings and fuzzy completion
    if ! "$(brew --prefix)/opt/fzf/install" --no-zsh --no-fish --no-update-rc --key-bindings --completion 2>/dev/null; then
        echo "Note: fzf shell integration skipped (fzf still available via brew)"
    fi

    # Install helm plugins (check if already installed)
    if ! helm plugin list | grep -q "^diff"; then
        helm plugin install --verify=false https://github.com/databus23/helm-diff
    fi
    if ! helm plugin list | grep -q "^secrets"; then
        helm plugin install --verify=false https://github.com/jkroepke/helm-secrets
    fi
}

install_gcloud() {
    brew install google-cloud-sdk
}

setup_git_config() {
    local git_name git_email

    # Check if git user is already configured
    if git config --global user.name &>/dev/null; then
        echo "Git user.name already set to: $(git config --global user.name)"
        if ! prompt_yn "Override git user configuration?"; then
            echo "Keeping existing git user configuration."
            git_name=""
        fi
    fi

    if [ -z "${git_name:-}" ]; then
        read -rp "==> Git user.name [Lance Kuo]: " git_name
        git_name="${git_name:-Lance Kuo}"
        read -rp "==> Git user.email [lancekuo@gmail.com]: " git_email
        git_email="${git_email:-lancekuo@gmail.com}"

        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
    fi

    git config --global init.defaultBranch main
    git config --global merge.tool vimdiff
    git config --global merge.conflictstyle diff3
    git config --global mergetool.prompt false
    git config --global commit.gpgsign true

    # Use SSH instead of HTTPS for GitHub (useful for go modules)
    git config --global url.git@github.com:.insteadOf https://github.com/

    # Git aliases
    git config --global alias.oldest-ancestor '!bash -c '\''diff --old-line-format='' --new-line-format='' <(git rev-list --first-parent "${1:-master}") <(git rev-list --first-parent "${2:-HEAD}") | head -1'\'' -'
    git config --global alias.branchdiff '!bash -c "git diff `git oldest-ancestor`.."'
    git config --global alias.branchlog '!bash -c "git log `git oldest-ancestor`.."'
    git config --global alias.permission-resetb '!git diff -p --no-ext-diff --no-color --diff-filter=d | grep -E "^(diff|old mode|new mode)" | sed -e "s/^old/NEW/;s/^new/old/;s/^NEW/new/" | git apply'
    git config --global alias.glog 'log --oneline --graph --all --decorate'

    echo "Git configuration complete."
}

setup_symlinks() {
    safe_symlink "$SCRIPT_DIR" "$HOME/.vim"
    safe_symlink "$HOME/.vim/vimrc" "$HOME/.vimrc"
    safe_symlink "$HOME/.vim/tmux.conf" "$HOME/.tmux.conf"
    safe_symlink "$HOME/.vim/terraformrc" "$HOME/.terraformrc"
    # Plugin cache dir referenced by terraformrc ╬ô├ç├╢ must exist or terraform warns
    mkdir -p "$HOME/.terraform.d/plugin-cache"
    safe_symlink "$SCRIPT_DIR/claude-skills" "$HOME/.claude/skills"
    safe_symlink "$SCRIPT_DIR/scripts/workspace.sh" "$HOME/.local/bin/workspace"
    safe_symlink "$SCRIPT_DIR/scripts/md2docx.sh" "$HOME/.local/bin/md2docx"
    safe_symlink "$SCRIPT_DIR/scripts/md2docx-reference" "$HOME/.local/bin/md2docx-reference"
    safe_symlink "$SCRIPT_DIR/scripts/md2gdoc.sh" "$HOME/.local/bin/md2gdoc"
}

setup_local_bin_path() {
    # ~/.local/bin — user scripts
    # Ubuntu's default ~/.profile adds this to PATH automatically;
    # macOS needs an explicit PATH entry (added in setup_local_bin_path).
    mkdir -p "$HOME/.local/bin"

    # Ubuntu's default ~/.profile already adds ~/.local/bin when the dir exists.
    # Only inject on macOS where that convention doesn’t exist.
    if [[ "$OS" == "macos" ]]; then
        if append_if_missing "$PROFILE" 'export PATH="$HOME/.local/bin:$PATH"' ".local/bin"; then
            echo "Added ~/.local/bin to PATH in $PROFILE"
        else
            echo "SKIP: ~/.local/bin already in $PROFILE"
        fi
    fi
}

# Generate managed shell init content
generate_shell_init() {
    local brew_path brew_eval_line
    brew_path="$(get_brew_path)"

    if [[ -n "$brew_path" ]]; then
        brew_eval_line="eval \"\$($brew_path shellenv)\""
    else
        warn "WARNING: Could not find brew binary. Shell profile may be incomplete."
        brew_eval_line="# brew not found during install — run install.sh again after installing Homebrew"
    fi

    cat << MANAGED
# =============================================================================
# Generated by ~/vimrc/install.sh — DO NOT EDIT
# User customizations go in ~/.bash_profile.local
# =============================================================================

# Homebrew
$brew_eval_line

# Bash prompt
source ~/.vim/prompt.bash/bash-prompt.bash

# Homebrew bash completion
if type brew &>/dev/null; then
    HOMEBREW_PREFIX="\$(brew --prefix)"
    if [[ -r "\${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
        source "\${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
    else
        for COMPLETION in "\${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
            [[ -r "\${COMPLETION}" ]] && source "\${COMPLETION}"
        done
    fi
fi

# Terraform autocomplete
if command -v terraform &>/dev/null; then
    complete -C "\$(command -v terraform)" terraform
fi

# Kubectl completions
complete -o default -o nospace -F __start_kubectl k
complete -F _kube_contexts ktx

# PATH
export PATH="\$HOME/.local/bin:\$PATH"

# User customizations
[[ -f ~/.bash_profile.local ]] && source ~/.bash_profile.local
MANAGED
}

# Set up shell profile — macOS: overwrite, Ubuntu: append source lines
setup_shell_profile() {
    if [[ "$OS" == "macos" ]]; then
        # macOS: .bash_profile is fully managed — overwrite each run
        generate_shell_init > "$PROFILE"
        echo "Generated $PROFILE (managed by install.sh)"
    else
        # Ubuntu: never overwrite .bashrc — write managed file, append source line
        local managed="$HOME/.bash_managed"
        generate_shell_init > "$managed"
        echo "Generated $managed"

        # Append source line to .bashrc (like Ubuntu's .bash_aliases pattern)
        if append_if_missing "$PROFILE" '[[ -f ~/.bash_managed ]] && source ~/.bash_managed' ".bash_managed"; then
            echo "Added source line for ~/.bash_managed to $PROFILE"
        else
            echo "SKIP: $PROFILE already sources ~/.bash_managed"
        fi
    fi

    # Create .bash_profile.local if it doesn't exist
    if [[ ! -f "$HOME/.bash_profile.local" ]]; then
        cat > "$HOME/.bash_profile.local" << 'LOCAL'
# User customizations — not managed by install.sh
# Add personal environment variables, aliases, etc. here
LOCAL
        echo "Created ~/.bash_profile.local"
    else
        echo "SKIP: ~/.bash_profile.local already exists"
    fi
}

setup_ssh_config() {
    mkdir -p "$HOME/.ssh/config.d"

    if [ ! -e "$HOME/.ssh/config.d/default" ]; then
        cat > "$HOME/.ssh/config.d/default" << 'EOF'
Host *
    ControlMaster auto
    ControlPath ~/.ssh/ssh_mux_%h_%p_%r
EOF
        echo "Created SSH config: ~/.ssh/config.d/default"
    else
        echo "SKIP: SSH config already exists"
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo "============================================="
    echo "  Vim Configuration Installation Script"
    echo "============================================="
    echo ""

    # Detect OS first
    detect_os
    echo ""

    # Homebrew
    if prompt_yn "Install Homebrew?"; then
        install_homebrew
    fi

    # Core tools (includes AWS CLI and Kubernetes tools)
    if prompt_yn "Install core tools (vim, jq, yq, fzf, git, bash-completion, go, tfenv+terraform 1.5.7, terraform-ls, bat, node+agtop, awscli, kubectl, kubectx, helm, k9s, argocd, kargo)?"; then
        install_core_tools
    fi

    # Google Cloud SDK
    if prompt_yn "Install Google Cloud SDK?"; then
        install_gcloud
    fi

    # Git submodules
    echo ""
    if prompt_yn "Update git submodules?"; then
        git submodule update --init
    fi

    # Git configuration
    if prompt_yn "Setup git configuration?"; then
        setup_git_config
    fi

    # Symlinks
    echo ""
    echo "Setting up symlinks..."
    setup_local_bin_path
    setup_symlinks

    # Shell profile (generates .bash_profile on macOS, .bash_managed on Ubuntu)
    echo ""
    echo "Setting up shell profile..."
    setup_shell_profile

    # SSH config
    setup_ssh_config

    echo ""
    echo "============================================="
    echo "  Installation complete!"
    echo "============================================="
    echo ""
    echo "Please restart your terminal or run:"
    echo "  source $PROFILE"
}

main "$@"
