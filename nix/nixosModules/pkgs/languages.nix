inputs: { pkgs, ... }:

{

    environment.systemPackages = with pkgs; [
        cargo
        cargo-shuttle
        go
        templ
        gleam
        zig
        mysql84
        typescript
        nodejs_22
        jdk
        erlang_27
        gcc
        rebar3
        elixir
        # deno
        python314
        php
        php83Packages.composer
        laravel
        lua
        odin

        rust-analyzer
        rustc
        typescript-language-server
        gopls
        vtsls
        vue-language-server
        tailwindcss-language-server
        superhtml
        emmet-ls
        zls
        elixir-ls
        bash-language-server
        fish-lsp
        intelephense
        clang-tools
        ols
    ];
    
}
