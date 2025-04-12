{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = with inputs; [
            devshell.overlays.default
          ];
        };
        pkg = builtins.fromJSON (builtins.readFile ./package.json);
        makeCommand = key: {
          name = "pnpm " + key;
          command = ''
            #!/usr/bin/env bash
            pnpm ${key}
          '';
          help = pkg.scripts.${key};
          category = "[scripts]";
        };
        scriptNames = builtins.attrNames pkg.scripts;
        commandsFromScripts = builtins.map makeCommand scriptNames;
      in
      {
        devShells.default = pkgs.devshell.mkShell {
          devshell = {
            name = "Astropedia";
            startup = {
              install-pnpm-dependencies.text = "pnpm install --frozen-lockfile";
            };
          };
          commands =
            with pkgs;
            [
              {
                package = nodejs_23;
                name = "node";
              }
              { package = pnpm; }
            ]
            ++ commandsFromScripts;

          motd = ''
            {73}🔨 Welcome to the {201}Astro{105}pedia{73} Devshell!{reset}
            $(type -p menu &>/dev/null && menu)
          '';
        };
      }
    );
}
