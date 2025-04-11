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
        # Read and parse package.json
        pkg = builtins.fromJSON (builtins.readFile ./package.json);

        # Create a function that formats a command using the key and its value.
        makeCommand = key: {
          name = "pnpm " + key;
          command = ''
            #!/usr/bin/env bash
            pnpm ${key}
          '';
          help = pkg.scripts.${key};
          category = "scripts";
        };

        # Get all the script keys
        scriptNames = builtins.attrNames pkg.scripts;

        # Map over the keys to generate the list of command attributes.
        commandsFromScripts = builtins.map makeCommand scriptNames;
      in
      {
        devShells.default = pkgs.devshell.mkShell {
          commands =
            with pkgs;
            [
              {
                package = nodejs_23;
                name = "node";
              }
              {
                package = pnpm;
              }
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
