inputs:

inputs.nixpkgs.lib.nixosSystem {
    modules = [
        (import ./configuration.nix inputs)
        (import ./secrets.nix inputs)
        ./hardware-configuration.nix
    ];
}
