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
            google-cloud-sdk
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
            
            # nicked from https://github.com/direnv/direnv/issues/443#issuecomment-642275550
            # and adapted for zsh use
            _nix_fpath_inputs=( "''${buildInputs[@]}" )
            for p in ''${_nix_fpath_inputs[@]}; do
            if [[ -d "$p/share/zsh/site-functions" ]]; then
                _NIX_FPATH="''${_NIX_FPATH}''${_NIX_FPATH+:}$p/share/zsh/site-functions"
            fi
            done
            export _NIX_FPATH
          '';
        };
      }
    );
}
