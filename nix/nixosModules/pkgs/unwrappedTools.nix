inputs: { pkgs, ... }:

let
    unstable-pkgs = import inputs.nixpkgs-unstable { system = pkgs.stdenv.hostPlatform.system; };
    session = inputs.session.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{

    environment.systemPackages = with pkgs; [
        luaPackages.tree-sitter-cli
        btop
        fish
        starship
        tmux
        yazi
    ] ++ [
        session
    ] ++ (with unstable-pkgs; [
        neovim
    ]);

}
