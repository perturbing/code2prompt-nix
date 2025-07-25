{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, naersk, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };

        naersk' = pkgs.callPackage naersk { };
        pkg = naersk'.buildPackage {
          name = "code2prompt";
          src = ./.;
          package = "code2prompt";
          nativeBuildInputs = with pkgs; [ m4 pkg-config perl ];
          release = true;
          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
        };
        app = flake-utils.lib.mkApp {
          drv = pkg;
          name = "code2prompt";
        };

      in
      rec {
        # For `nix build` & `nix run`:
        defaultPackage = pkg;
        apps.default = app;

        # For `nix develop`:
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ rustc cargo ];
        };
      }
    );
}

