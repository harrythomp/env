inputs: { pkgs, ... }:

let
    unstable-pkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    session = inputs.session.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{

    environment.systemPackages = with pkgs; [
        tmux
        luaPackages.tree-sitter-cli
        yazi
        air
        neocities
        fzf
        ripgrep
        pkg-config
        openssl
        fastfetch
        gnumake
        inotify-tools
        nmap
        udiskie
        colorz
        cava
        git-filter-repo
        git
        btop
        zoxide
        unzip
        tldr
        mdp
        gtypist
        bat
        starship
        jq
        tokei
        caddy
        go-task
        jujutsu
        smartmontools
        chafa
        ffmpeg
        socat
        ascii
        compose2nix
        gcc
        matugen
    ] ++ [
        session
    ] ++ (with unstable-pkgs; [
        opencode
        neovim
    ]);

}
