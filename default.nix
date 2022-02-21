{ compiler ? "ghc8107" }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};

  gitignore = pkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];

  myHaskellPackages = pkgs.haskell.packages.${compiler}.override {
    overrides = hself: hsuper: {
      "game-demo" =
        hself.callCabal2nix
          "game-demo"
          (gitignore ./.)
          {};
    };
  };

  shell = myHaskellPackages.shellFor {
    packages = p: [
      p."game-demo"
    ];
    buildInputs = [
      myHaskellPackages.haskell-language-server
      pkgs.haskellPackages.cabal-install
      pkgs.haskellPackages.ghcid
      pkgs.haskellPackages.ormolu
      pkgs.haskellPackages.hlint
      pkgs.haskellPackages.hpack
      pkgs.haskellPackages.stack
      pkgs.niv
      pkgs.nixpkgs-fmt
      pkgs.figlet
    ];
    withHoogle = true;
    shellHook = ''
     set -o vi
     ~/.emacs.d/bin/doom env
      echo "game demo" | figlet
'';
  };
in
{
  inherit shell;
  inherit myHaskellPackages;
  "game-demo" = myHaskellPackages."game-demo";
}
