{ symlinkJoin, makeWrapper, dots, tmux }:

symlinkJoin {
    name = "tmux";
    paths = [ tmux ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
        wrapProgram $out/bin/tmux --add-flag -f --add-flag ${dots}/.config/tmux/tmux.conf
    '';
}
