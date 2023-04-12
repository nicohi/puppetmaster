{ pkgs ? import <nixpkgs> {} }:

let
  node2nix = import ./node2nix.nix { inherit pkgs; };

  # https://github.com/justinwoo/my-blog-posts/blob/master/posts/2019-08-23-using-puppeteer-with-node2nix.md
  package = node2nix.package.override {
   preInstallPhases = "skipChromiumDownload";
   skipChromiumDownload = ''
     export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
   '';
  };

in pkgs.stdenv.mkDerivation {
  name = "puppetmaster";

  src = package;

  buildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    ln -s $src/bin/puppetmaster $out/bin/puppetmaster

    wrapProgram $out/bin/puppetmaster \
      --set PUPPETEER_EXECUTABLE_PATH ${pkgs.chromium.outPath}/bin/chromium
  '';
}
