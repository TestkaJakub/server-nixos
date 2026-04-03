{ lib, ... }:

# ── Profile ────────────────────────────────────────────────────────────────────
# Mirrors meta/profile.nix on the PC.
{
  options.profile = {
    username = lib.mkOption {
      type        = lib.types.str;
      default     = "jakub";
      description = "Primary user's login name.";
    };

    homeDirectory = lib.mkOption {
      type        = lib.types.str;
      default     = "/home/jakub";
      description = "Primary user's home directory.";
    };

    stateVersion = lib.mkOption {
      type        = lib.types.str;
      default     = "25.11";
      description = "NixOS and home-manager state version.";
    };

    hostname = lib.mkOption {
      type        = lib.types.str;
      default     = "server";
      description = "Machine hostname.";
    };
  };
}
