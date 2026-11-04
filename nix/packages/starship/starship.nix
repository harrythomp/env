{ symlinkJoin, makeWrapper, dots, starship }:

symlinkJoin {
    name = "starship";
    paths = [ starship ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
        wrapProgram $out/bin/starship --set STARSHIP_CONFIG ${dots}/.config/starship.toml
    '';
}
