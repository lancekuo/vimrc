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

# Cross-platform sed in-place edit
sed_inplace() {
    if [[ "$OS" == "macos" ]]; then
        sed -i "" "$@"
    else
        sed -i "$@"
    fi
}

# Get Homebrew binary path based on OS
get_brew_path() {
    if [[ "$OS" == "macos" ]]; then
        # Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo "/opt/homebrew/bin/brew"
        # Intel Mac
        elif [[ -f "/usr/local/bin/brew" ]]; then
            echo "/usr/local/bin/brew"
        fi
    else
        # Linux
        echo "/home/linuxbrew/.linuxbrew/bin/brew"
    fi
}

# Get Homebrew shellenv command based on OS
get_brew_shellenv() {
    local brew_path
    brew_path="$(get_brew_path)"
    echo "eval \"\$($brew_path shellenv)\""
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

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew shellenv to profile and evaluate it now
    local brew_path brew_shellenv
    brew_path="$(get_brew_path)"
    brew_shellenv="$(get_brew_shellenv)"
    append_if_missing "$PROFILE" "$brew_shellenv" "brew shellenv"

    # Evaluate using full path (brew not in PATH yet)
    eval "$("$brew_path" shellenv)"
    echo "Homebrew installed and configured."
}

install_core_tools() {
    # Core CLI tools
    # terraform@1.5.* stays with Mozilla Public License
    brew install vim jq yq fzf git bash-completion go terraform terraform-ls bat

    # AWS CLI
    brew install awscli

    # Kubernetes tools
    brew install kubernetes-cli kubectx helm k9s

    # GitOps tools
    brew tap akuity/tap
    brew install argocd akuity/tap/kargo

    # Install fzf key bindings and fuzzy completion
    "$(brew --prefix)/opt/fzf/install" --no-zsh --no-fish --no-update-rc

    # Terraform autocomplete
    terraform -install-autocomplete 2>/dev/null || true

    # Install helm plugins (check if already installed)
    if ! helm plugin list | grep -q "^diff"; then
        helm plugin install https://github.com/databus23/helm-diff
    fi
    if ! helm plugin list | grep -q "^secrets"; then
        helm plugin install https://github.com/jkroepke/helm-secrets
    fi
}

install_gcloud() {
    brew install google-cloud-sdk
}

setup_homebrew_token() {
    local token
    read -rp '==>==> Paste your GitHub token: ' token
    if [ -z "$token" ]; then
        echo "No token provided, skipping."
        return
    fi

    # Remove existing token line if present
    if grep -qe "HOMEBREW_GITHUB_API_TOKEN" "$PROFILE" 2>/dev/null; then
        sed_inplace '/HOMEBREW_GITHUB_API_TOKEN/d' "$PROFILE"
    fi
    echo "export HOMEBREW_GITHUB_API_TOKEN=$token" >> "$PROFILE"
    echo "Token for Homebrew configured in $PROFILE"
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
}

setup_bash_prompt() {
    local prompt_file="bash-prompt.bash"
    local source_line="source ~/.vim/prompt.bash/$prompt_file"

    if append_if_missing "$PROFILE" "$source_line" "bash-prompt"; then
        echo "Injected $prompt_file into $PROFILE"
    else
        echo "SKIP: $prompt_file already in $PROFILE"
    fi
}

setup_bash_completion() {
    local completion_block='# Homebrew bash completion
if type brew &>/dev/null; then
    HOMEBREW_PREFIX="$(brew --prefix)"
    if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
        source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
    else
        for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
            [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
        done
    fi
fi'

    if ! grep -q "Homebrew bash completion" "$PROFILE" 2>/dev/null; then
        echo "$completion_block" >> "$PROFILE"
        echo "Added bash completion to $PROFILE"
    else
        echo "SKIP: Bash completion already in $PROFILE"
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

setup_kubectl_completion() {
    append_if_missing "$PROFILE" 'complete -o default -o nospace -F __start_kubectl k' "__start_kubectl" && \
        echo "Added kubectl completion for 'k' alias"
    append_if_missing "$PROFILE" 'complete -F _kube_contexts ktx' "_kube_contexts" && \
        echo "Added kubectx completion for 'ktx' alias"
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
    if prompt_yn "Install core tools (vim, jq, yq, fzf, git, bash-completion, go, terraform, terraform-ls, bat, awscli, kubectl, kubectx, helm, k9s, argocd, kargo)?"; then
        install_core_tools
    fi

    # Google Cloud SDK
    if prompt_yn "Install Google Cloud SDK?"; then
        install_gcloud
    fi

    # Homebrew GitHub token
    if prompt_yn "Setup GitHub token for Homebrew?"; then
        setup_homebrew_token
    fi

    # Git submodules
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
    setup_symlinks

    # Bash prompt
    setup_bash_prompt

    # Bash completion
    setup_bash_completion

    # SSH config
    setup_ssh_config

    # Kubectl completion
    setup_kubectl_completion

    echo ""
    echo "============================================="
    echo "  Installation complete!"
    echo "============================================="
    echo ""
    echo "Please restart your terminal or run:"
    echo "  source $PROFILE"
}

main "$@"
