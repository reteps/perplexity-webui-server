{
  description = "Use models on Perplexity web through LangChain";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (nixpkgs) lib;
      in {
        devShells.default = with pkgs; mkShellNoCC {
          packages = [
            (python312.withPackages(ps: with ps; [
              openai
              self.packages.${system}.perplexityai
            ]))
          ];
        };
        apps = rec {
          perplexity-webui-server = {
            type = "app";
            program = lib.getExe' (pkgs.python312Packages.toPythonApplication self.packages.${system}.perplexity-webui-server) "perplexity_webui_server";
          };
          default = perplexity-webui-server;
        };
        packages = rec {
           langchain-openai-api-bridge = with pkgs.python312Packages; buildPythonPackage rec {
            pname = "langchain-openai-api-bridge";
            version = "0.11.3";
            format = "pyproject";

            src = pkgs.fetchFromGitHub {
              owner = "samuelint";
              repo = pname;
              rev = "v${version}";
              hash = "sha256-ZPWwjdRM6QUU64tu9PIunmPeFHwesNMrlRtOFCVyScw=";
            };

            nativeBuildInputs = [
              pkgs.python312Packages.poetry-core
            ];

            propagatedBuildInputs = with pkgs.python312Packages; [
              openai
            ];
          };
           perplexityai = with pkgs.python312Packages; buildPythonPackage rec {
            pname = "perplexityai";
            version = "0.1";
            format = "setuptools";

            src = pkgs.fetchFromGitHub {
              owner = "reteps";
              repo = pname;
              rev = "f8a23a39f490577459ae363c263adb4b8f4083e8";
              hash = "sha256-cwDBPblfN7SReaJBvX2i3LXybo3sVKErVkogFWs3MgY=";
            };
            postPatch = ''
              for f in perplexity/{labs,perplexity}.py; do
                substituteInPlace $f --replace-fail 'target=self.ws.run_forever' \
                  'target=self.ws.run_forever, kwargs={"suppress_origin": True}'
              done
            '';

            propagatedBuildInputs = with pkgs.python312Packages; [
              requests websocket-client
            ];
          };
           perplexity-webui-langchain = with pkgs.python312Packages; buildPythonPackage rec {
            pname = "perplexity-webui-langchain";
            version = "0.1";
            format = "setuptools";

            src = pkgs.fetchFromGitHub {
              owner = "reteps";
              repo = pname;
              rev = "caf9be5df571db6579dbf2f3298e96b1cc6ededb";
              hash = "sha256-SzMMkzPGi28i+7UnTnCfVJZxAFFXiaERTh88lKyNwZo=";
            };

            propagatedBuildInputs = with pkgs.python312Packages; [
              langchain
              self.packages.${system}.perplexityai
            ];
          };
           perplexity-webui-server = with pkgs.python312Packages; buildPythonPackage rec {
            pname = "perplexity-webui-server";
            version = "0.1";
            format = "setuptools";

            src = ./.;

            propagatedBuildInputs = with pkgs.python312Packages; [
              self.packages.${system}.perplexity-webui-langchain
              self.packages.${system}.langchain-openai-api-bridge
              fastapi
              python-dotenv
              uvicorn
              langgraph
            ];
          };
        };
      });
}
