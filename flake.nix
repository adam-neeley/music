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
        default = pkgs.stdenv.mkDerivation {
          pname = "music";
          version = "0001";
          src = ./.;
          buildInputs = with pkgs; [ makeWrapper alda coreutils ];

          installPhase = ''
            mkdir -p $out/bin $out/src
            cp ${./bin/music} $out/bin/music
            cp ${./src}/* $out/src
            chmod +x $out/bin/music
            wrapProgram $out/bin/music \
              --set PATH ${pkgs.alda}/bin:${pkgs.coreutils}/bin \
              --set SRC_DIR $out/src
          '';

        };
      });
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell { packages = with pkgs; [ alda ]; };
      });
    };
}
