{
  self,
  withSystem,
  inputs,
  ...
}:

let
  inherit (builtins) attrValues removeAttrs;

  mkDarwin =
    name:
    {
      system ? "aarch64-darwin",
      user ? self.users.default,
      stateVersion ? 5,
      homeManagerStateVersion ? "24.11",
      modules ? [ ],
    }:
    withSystem system (
      ctx:
      inputs.nix-darwin.lib.darwinSystem {
        inherit (ctx) system;
        specialArgs = {
          inherit inputs;
        };
        modules =
          attrValues self.commonModules
          ++ attrValues self.darwinModules
          ++ [
            # Composed home-manager configuration.
            inputs.home-manager.darwinModules.home-manager
            (
              { pkgs, config, ... }:
              {
                inherit (ctx) nix;
                homebrew.enable = true;
                _module.args = ctx.extraModuleArgs;
                nixpkgs = removeAttrs ctx.nixpkgs [ "hostPlatform" ];
                system.stateVersion = stateVersion;
                users.primaryUser = user;
                networking.hostName = name;
                networking.computerName = name;
                environment.systemPackages = ctx.basePackagesFor pkgs;
                # `home-manager` config
                users.users.${user.username} = {
                  home = "/Users/${user.username}";
                  shell = pkgs.fish;
                };
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${user.username} = {
                  imports = attrValues self.homeManagerModules ++ [
                    # inputs.sops.homeManagerModules.sops
                    # (
                    #   { ... }:
                    #   {
                    #     home.sessionVariables.EDITOR = "nano";
                    #   }
                    # )
                  ];
                  home.enableNixpkgsReleaseCheck = false;
                  home.stateVersion = homeManagerStateVersion;
                  home.user-info = user;
                  home.username = user.username;
                  home.packages = [
                    # pkgs.sops
                    config.nix.package
                  ];
                  # sops.gnupg.home = "~/.gnupg";
                  # sops.gnupg.sshKeyPaths = [ ];
                  # sops.defaultSopsFile = ../../secrets/secret.yaml;
                  # sops.secrets.openai_api_key.path = "%r/openai_api_key";
                  # sops.secrets.codeium.path = "%r/codeium";
                  # git diff integrations
                  # programs.git.extraConfig.diff.sopsdiffer.textconv = "sops -d --config /dev/null";
                };
              }
            )
          ]
          ++ modules;
      }
    );

  mkDarwinConfigurations = configurations: builtins.mapAttrs mkDarwin configurations;
in

{
  flake.users = {
    default = rec {
      username = "budhilaw";
      fullName = "Ericsson Budhilaw";
      email = "hi@budhilaw.com";
      nixConfigDirectory = "/Users/${username}/.config/nixverse";
      within = {
        # neovim.enable = false;
        gpg.enable = true;
        pass.enable = true;
      };
    };
  };
  # nix-darwin configurations
  flake.darwinConfigurations = mkDarwinConfigurations {
    budhilaw = { };
  };
}
