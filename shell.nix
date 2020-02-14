let
  pkgs = import <nixpkgs> {};

in
pkgs.mkShell rec {
  name = "env";

  buildInputs = with pkgs; [
    bundix
    libxml2
    ruby
  ];
}
