{ ... }:
{
  flake.commonModules = {
    system-shells = import ./shells.nix;
    users-primaryUser = import ./user.nix;
  };

  flake.darwinModules = {
    system-darwin = import ./darwin/system.nix;
    system-darwin-gpg = import ./darwin/gpg.nix;
    system-darwin-homebrew = import ./darwin/homebrew.nix;
    system-darwin-network = import ./darwin/network.nix;
  };
}
