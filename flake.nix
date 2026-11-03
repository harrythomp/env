{
    description = "Nixos config flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        nixos-hardware = {
            url = "github:nixos/nixos-hardware/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        session = {
            url = "github:harrythomp/session";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        noctalia = {
            url = "github:noctalia-dev/noctalia/cachix";
        };
    };

    outputs = inputs:
    let
        loadFiles = import ./nix/util/loadFiles.nix;
        supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
		eachSupportedSystem = inputs.nixpkgs.lib.genAttrs supportedSystems;
    in
    {
        nixosModules = loadFiles ./nix/nixosModules { args = inputs; };
        nixosConfigurations = loadFiles ./nix/nixosConfigurations { shallow = true; args = inputs; };
        packages = eachSupportedSystem (system: loadFiles ./nix/packages { shallow = true; args = inputs // { inherit system; }; });
    };
}
