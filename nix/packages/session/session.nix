{ symlinkJoin, makeWrapper, dots, session }:

symlinkJoin {
    name = "session";
    paths = [ session ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
        wrapProgram $out/bin/session --set XDG_CONFIG_HOME ${dots}/.config
    '';
}
