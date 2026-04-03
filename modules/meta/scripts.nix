{ lib, pkgs, config, ... }:

# ── Scripts ────────────────────────────────────────────────────────────────────
# Mirrors meta/scripts.nix on the PC.
#
# cpc  — print all .nix configs to stdout so your PC can grab them:
#          ssh jakub@server cpc | wl-copy
#        Add to your PC's shell/aliases.nix:
#          scpc = "ssh jakub@server cpc | wl-copy";
#
# nrs  — commit + nixos-rebuild switch (mirrors the PC nrs)
# nrsr — nrs + reboot on success
{
  options.scripts = {
    nrs = lib.mkOption {
      type        = lib.types.package;
      readOnly    = true;
      description = "Commit dotfiles and run nixos-rebuild switch.";
    };
    nrsr = lib.mkOption {
      type        = lib.types.package;
      readOnly    = true;
      description = "Run nrs and reboot on success.";
    };
    cpc = lib.mkOption {
      type        = lib.types.package;
      readOnly    = true;
      description = "Print all .nix configs to stdout for piping over SSH.";
    };
  };

  config = {
    scripts = {
      cpc = pkgs.writeShellScriptBin "cpc" ''
        find ~/server-nixos -type f -name '*.nix' \
          -exec echo "===== {} =====" \; \
          -exec cat {} \;
      '';

	nrs = pkgs.writeShellScriptBin "nrs" ''
	  SAVED_DIR=$(pwd)
	  cd ~/server-nixos || exit 1

	  if ! git rev-parse --verify main &>/dev/null; then
	    git checkout -b main || exit 1
	  else
	    git checkout main || exit 1
	  fi

	  git add . || exit 1
	  if ! git diff --cached --quiet; then
	    git commit -m "upgrade $(date '+%Y-%m-%d %H:%M')" || exit 1
	  fi

	  git push -u origin main || exit 1

	  sudo nixos-rebuild switch --flake ~/server-nixos#server
	  result=$?
	  cd "$SAVED_DIR" || exit 1
	  exit $result
	'';

      nrsr = pkgs.writeShellScriptBin "nrsr" ''
        if nrs; then
          echo "Rebuild succeeded. Rebooting..."
          reboot
        else
          echo "Rebuild failed, NOT rebooting."
        fi
      '';
    };

    environment.systemPackages = [
      config.scripts.cpc
      config.scripts.nrs
      config.scripts.nrsr
    ];
  };
}
