{
  description = "Jakub's server NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url                    = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
  let
    # ── Recursive module walker ─────────────────────────────────────────────
    # Identical to the one in your PC flake.nix
    collectModules = dir: blacklist:
      let
        walk = prefix: entries:
          nixpkgs.lib.concatMap (name:
            let
              path    = dir + "/${prefix}${name}";
              relPath = "${prefix}${name}";
              type    = entries.${name};
            in
            if type == "directory" then
              walk "${prefix}${name}/" (builtins.readDir path)
            else if type == "regular"
              && nixpkgs.lib.hasSuffix ".nix" name
              && !(builtins.elem relPath blacklist)
            then [ path ]
            else []
          ) (builtins.attrNames entries);
      in
        walk "" (builtins.readDir dir);

    moduleBlacklist = [ "system/hardware.nix" ];

    pkgs = import nixpkgs {
      system             = "x86_64-linux";
      config.allowUnfree = true;
    };
  in
  {
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      inherit pkgs;

      modules =
        (collectModules ./modules moduleBlacklist)
        ++ [ ./modules/system/hardware.nix ]
        ++ [ home-manager.nixosModules.home-manager ];

      specialArgs = { inherit inputs; };
    };
  };
}
