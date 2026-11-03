{ self, ... }: { pkgs, ... }:

let
    scripts = self.packages.${pkgs.stdenv.hostPlatform.system}.scripts;
in
{

    environment.systemPackages = [
        scripts
    ];

}
