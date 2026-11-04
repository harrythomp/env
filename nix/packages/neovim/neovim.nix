{ symlinkJoin, makeWrapper, dots, neovim }:

symlinkJoin {
    name = "neovim";
    paths = [ neovim ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
        wrapProgram $out/bin/nvim --set XDG_CONFIG_HOME ${dots}/.config
    '';
}
