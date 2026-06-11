FROM archlinux:base-20260111.0.480139

RUN pacman -Syu --noconfirm \
    cloc \
    cocogitto \
    curl \
    git \
    jq \
    make \
    neovim \
    sudo \
    which

COPY plenary-patches /plenary-patches

RUN mkdir -p /usr/local/share/nvim/site/pack/plenary/start && \
    cd /usr/local/share/nvim/site/pack/plenary/start && \
    git clone --depth 1 https://github.com/nvim-lua/plenary.nvim.git && \
    git -C plenary.nvim apply /plenary-patches/*.patch

RUN mkdir -p /usr/local/share/nvim/site/pack/telescope/start && \
    cd /usr/local/share/nvim/site/pack/telescope/start && \
    git clone --depth 1 https://github.com/nvim-telescope/telescope.nvim.git

RUN pacman -S --noconfirm cscope
