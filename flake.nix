{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {self, nixpkgs, flake-utils, ...}@inputs: let
    recipe = {
      stdenv
    , lib
    , makeWrapper
    , timewarrior
    , jq
    }: stdenv.mkDerivation rec {
      name = "toki";
      # renovate: datasource=github-releases depName=aklomp/shrinkpdf extractVersion=^shrinkpdf-(?<version>.+)$
      src = ./.;

      preferLocalBuild = true;

      unpackPhase = "true";
      configurePhase = "true";
      buildPhase = "true";

      nativeBuildInputs = [
        makeWrapper
      ];

      installPhase = ''
        for sf in "$src"/src/toki*; do
          df="$out/bin/.$(basename "$sf")-wrapped"
          wrapper="$out/bin/$(basename "$sf")"
          install -Dm755 "$sf" "$df"
          makeWrapper "$df" "$wrapper" \
            --suffix PATH : ${lib.makeBinPath [ timewarrior jq ]}
        done
      '';

      meta = with lib; {
        description = "A Bash wrapper around the Timewarrior CLI that aims to improve its usability.";
        homepage = https://github.com/lykos153/toki;
        license = licenses.isc;
        platforms = platforms.all;
      };
    };
  in flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {
        inherit system;
    };
    in {
      defaultPackage = pkgs.callPackage recipe {};
    }
  );
}
