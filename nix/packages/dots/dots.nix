{ stdenv, host, overlay }:

stdenv.mkDerivation {
    name = "dots";
    src = ../../../.;
    patchPhase = ''
        find environment/scripts -type f | while read -r script; do
            patchShebangs "$script"
        done
    '';
    buildPhase = ''
        HOST=${host} OVERLAY=${overlay} SOURCE="$src" TARGET="$out" environment/scripts/dots copy
    '';
    installPhase = ''
        cp -R "$out/.local/scripts" "$out/bin"
    '';
}
