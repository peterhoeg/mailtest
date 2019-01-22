with import <nixpkgs> {};

let
  ruby = pkgs.ruby;
  bundler = pkgs.bundler.override { inherit ruby; };

in stdenv.mkDerivation rec {
  name = "env";
  buildInputs = [
    libxml2
    ruby
  ];

  nativeBuildInputs = [
    bundix
    bundler
  ];
}
