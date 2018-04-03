with import <nixpkgs> {};

let
  ruby = pkgs.ruby_2_4;
  bundler = pkgs.bundler.override { inherit ruby; };

in stdenv.mkDerivation rec {
  name = "env";
  buildInputs = [
    libxml2
  ];

  nativeBuildInputs = [
    bundix
  ];
}
