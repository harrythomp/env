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
        fzf
        ripgrep
        fastfetch
        gnumake
        git
        btop
        zoxide
        unzip
        tldr
        bat
        starship
        jq
        socat
        ascii
        wget
        gcc
        matugen
    ] ++ [
        session
    ] ++ (with unstable-pkgs; [
        neovim
    ]);

}
