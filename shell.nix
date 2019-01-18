with import <nixpkgs> {};

let
  myRuby = pkgs.ruby;
  bundler = pkgs.bundler.override { ruby = myRuby; };

in stdenv.mkDerivation rec {
  name = "env";
  buildInputs = [
    libxml2
    myRuby
  ];

  nativeBuildInputs = [
    bundix
    bundler
  ];
}
