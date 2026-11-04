{ system, nixpkgs, self, ... }:

let
    pkgs = import nixpkgs { inherit system; };
in
pkgs.mkShell {
    packages = with self.packages.${system}; [
        btop
        fish
        neovim
        session
        starship
        tmux
        yazi
    ] ++ (with pkgs; [
        fzf
        fastfetch
        git
        unzip
        tldr
        bat
        jq
        ascii
    ]);
    shellHook = ''
        exec fish
    '';
}
