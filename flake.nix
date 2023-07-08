{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs.lib.lists) optionals;
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            argocd
            awscli2
            dive
            exa
            gh
            graphviz
            jsonnet
            k9s
            kubectl
            kubernetes-helm
            kubeseal
            kustomize
            minikube
            nodejs_20
            sccache
            skaffold
          ]
          ++ optionals stdenv.isDarwin [ darwin.libiconv watch ]
          ++ optionals stdenv.isLinux [ openssl_legacy ];
          shellHook = ''
            unset PYTHONPATH
            export _NIX_PROMPT="🧊️"
          '';
        };
      }
    );
}
