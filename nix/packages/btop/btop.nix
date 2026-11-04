{ symlinkJoin, makeWrapper, dots, btop }:

symlinkJoin {
    name = "btop";
    paths = [ btop ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
        wrapProgram $out/bin/btop --add-flag -c --add-flag ${dots}/.config/btop/btop.conf
    '';
}
