{ config, ... }:

# ── Nix & system core ──────────────────────────────────────────────────────────
# Mirrors system/nix.nix on the PC.
{
  networking.hostName = config.profile.hostname;

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 30d";
    };
  };

  system.stateVersion = config.profile.stateVersion;
}
