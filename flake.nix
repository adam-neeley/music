{
  description = "music flake";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f:
        nixpkgs.lib.genAttrs supportedSystems
        (system: f { pkgs = import nixpkgs { inherit system; }; });
    in {
      packages = forEachSupportedSystem ({ pkgs }: {
        # default = pkgs.mkShellScriptBin "music" ''
        #   #
        #   alda play -f
        # '';
        default = pkgs.stdenv.mkDerivation {
          name = "music";
          src = ./.;
          buildInputs = [ pkgs.alda ];

          buildPhase = ''
            mkdir -p $out/bin $out/src
            cp ./bin/* $out/bin/
            cp ./src/* $out/src/
          '';

        };
      });
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell { packages = with pkgs; [ alda ]; };
      });
    };
}
