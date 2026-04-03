{ pkgs, ... }:

# ── Misc packages ──────────────────────────────────────────────────────────────
# Headless subset of dev-tools/misc.nix on the PC.
{
  environment.systemPackages = with pkgs; [
    git
    wget
    micro
    unzip
    nix-diff
    parted
    htop
    bat
    glow
  ];
}
