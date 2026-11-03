{ stdenv }:

stdenv.mkDerivation {
    name = "scripts";
    src = ../../../.;
    patchPhase = ''
        find environment/scripts -type f | while read -r script; do
            patchShebangs "$script"
        done
    '';
    installPhase = ''
        mkdir -p "$out/bin"
        cp -R "environment/scripts/" "$out/bin"
    '';
}
