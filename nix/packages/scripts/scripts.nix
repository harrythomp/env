{ stdenv, dots }:

stdenv.mkDerivation {
    name = "scripts";
    src = ../../../.;
    nativeBuildInputs = [ dots ];
    installPhase = ''
        mkdir -p "$out"
        cp -R "${dots}/.local/scripts" "$out/bin"
    '';
}
