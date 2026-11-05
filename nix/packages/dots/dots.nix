{ stdenv, host, overlay, matugen }:

stdenv.mkDerivation {
    name = "dots";
    src = ../../../.;
    patchPhase = ''
        patchShebangs environment/scripts
    '';
    nativeBuildInputs = [ matugen ];
    buildPhase = ''
        export HOST="${host}"
        export OVERLAY="${overlay}"
        export SOURCE="$src"
        export TARGET="$out"

        environment/scripts/dots copy
        environment/scripts/dots set-theme
    '';
}
