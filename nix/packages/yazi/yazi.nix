{ symlinkJoin, makeWrapper, dots, yazi }:

symlinkJoin {
    name = "yazi";
    paths = [ yazi ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
        wrapProgram $out/bin/yazi --set YAZI_CONFIG_HOME ${dots}/.config/yazi
    '';
}
