{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/4ecab3273592f27479a583fb6d975d4aba3486fe";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            argocd
            awscli2
            exa
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
          ] ++ (if stdenv.isDarwin then [darwin.libiconv watch] else []);
          shellHook = ''
            unset PYTHONPATH
            export _NIX_PROMPT=.flake
          '';
        };
      }
    );
}
