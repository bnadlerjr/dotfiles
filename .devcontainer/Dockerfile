FROM node:22

ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest
ARG GIT_DELTA_VERSION=0.18.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh \
    git \
    gh \
    ripgrep \
    fd-find \
    fzf \
    jq \
    bat \
    vim \
    neovim \
    tmux \
    python3 \
    python3-pip \
    python3-venv \
    iptables \
    ipset \
    iproute2 \
    dnsutils \
    aggregate \
    curl \
    ca-certificates \
    wget \
    build-essential \
    sudo \
    less \
    procps \
    man-db \
    unzip \
    gnupg2 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ARCH=$(dpkg --print-architecture) \
  && wget -q "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" \
  && dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" \
  && rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Debian ships fd-find as `fdfind` and bat as `batcat` to avoid name collisions; expose canonical names.
RUN ln -s /usr/bin/fdfind /usr/local/bin/fd \
  && ln -s /usr/bin/batcat /usr/local/bin/bat

RUN mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R node:node /commandhistory \
  && echo 'export PROMPT_COMMAND="history -a" HISTFILE=/commandhistory/.bash_history' >> /etc/bash.bashrc

RUN mkdir -p /workspace /home/node/.claude \
  && chown -R node:node /workspace /home/node/.claude

# Configure git at the system level. ~/.gitconfig is a symlink to the tracked
# dotfiles file, so any --global write would pollute version-controlled content.
# - safe.directory: /workspace bind-mount UID may not match `node` on Linux hosts.
# - commit/tag.gpgsign off: no SSH agent inside the container (1Password agent
#   socket lives in macOS's sandboxed Group Containers and isn't reachable from
#   Docker Desktop's VM). Sign on the host instead.
RUN git config --system --add safe.directory /workspace \
  && git config --system commit.gpgsign false \
  && git config --system tag.gpgsign false

ENV DEVCONTAINER=true \
    CLAUDE_CONFIG_DIR=/home/node/.claude \
    SHELL=/bin/bash \
    EDITOR=nvim

USER node
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin:/home/node/.local/bin
RUN mkdir -p /home/node/.npm-global \
  && npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

USER root
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
COPY post-create.sh /usr/local/bin/post-create.sh
COPY print-welcome.sh /usr/local/bin/print-welcome.sh
RUN chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/post-create.sh /usr/local/bin/print-welcome.sh \
  && echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall \
  && chmod 0440 /etc/sudoers.d/node-firewall

USER node
WORKDIR /workspace
