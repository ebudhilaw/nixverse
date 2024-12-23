{ self, ... }:

{
  flake.homeManagerModules = {
    budhilaw-activation = import ./activation.nix;
    budhilaw-packages = import ./packages.nix;
    budhilaw-shell = import ./shells.nix;
    budhilaw-git = import ./git.nix;
    budhilaw-ssh = import ./ssh.nix;
    #budhilaw-tmux = import ./tmux.nix;
    gpg = import ./gpg.nix;
    home-user-info =
      { lib, ... }:
      {
        options.home.user-info =
          (self.commonModules.users-primaryUser { inherit lib; }).options.users.primaryUser;
      };
  };
}
