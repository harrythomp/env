{ symlinkJoin, makeWrapper, dots, fish }:

symlinkJoin {
    name = "fish";
    paths = [ fish ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
        wrapProgram $out/bin/fish --add-flag -C --add-flag 'source ${dots}/.config/fish/config.fish'
    '';
    passthru = {
        meta = fish.meta;
        shellPath = fish.shellPath;
    };
}
