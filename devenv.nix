{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  # Read and parse ther JSON file containing the Indiekit secrets
  indiekit_secrets = builtins.fromJSON (builtins.readFile /run/secrets/indiekit);
in {
  enterShell = ''
    versions
  '';

  enterTest = ''
    echo "Assert Node.js version is 20.11.1"
    node --version | grep "20.11.1"
  '';

  env = {
    DEBUG = "indiekit:*,-indiekit:request,indiekit-store:*";
    GITHUB_TOKEN = builtins.readFile /run/secrets/github-tokens/indiekit_github_content_store;
    MONGO_PORT = "27017";
    MONGO_INITDB_ROOT_USERNAME = "mongoadmin";
    MONGO_INITDB_ROOT_PASSWORD = "secret";
    # MongoDB I use in development (use `devenv up` to launch it)
    MONGO_URL = "mongodb://${config.env.MONGO_INITDB_ROOT_USERNAME}:${config.env.MONGO_INITDB_ROOT_PASSWORD}@localhost:${config.env.MONGO_PORT}";
    # MongoDB I use in production
    # MONGO_URL = indiekit_secrets.mongo_url;
    PASSWORD_SECRET = indiekit_secrets.password_secret;
    SECRET = indiekit_secrets.secret;
  };

  languages = {
    nix.enable = true;
  };

  packages = with pkgs; [
    git
    nodejs
    trivy # container scanner
  ];

  # https://devenv.sh/pre-commit-hooks/
  pre-commit.hooks = {
    alejandra.enable = true;
    prettier.enable = true;
    shellcheck.enable = true;
    statix.enable = true;
  };

  # Example: https://github.com/F1bonacc1/process-compose/blob/main/process-compose.yaml
  process.managers.process-compose = {
    settings = {
      processes = {
        mongodb = {
          availability = {
            restart = "on_failure";
          };
        };
      };
    };
    tui.enable = true;
  };

  scripts = {
    container-build.exec = ''
      docker build --build-arg NODE_VERSION=22.9.0 --tag indiekit:latest .
    '';
    container-dive.exec = ''
      dive indiekit:latest
    '';
    container-run.exec = ''
      docker run \
        --env GITHUB_TOKEN=${config.env.GITHUB_TOKEN} \
        --env MONGO_URL=${config.env.MONGO_URL} \
        --env PASSWORD_SECRET=${config.env.PASSWORD_SECRET} \
        --env SECRET=${config.env.SECRET} \
        -p 3001:3000 indiekit:latest
    '';
    container-scan.exec = ''
      trivy image --severity MEDIUM,HIGH,CRITICAL -f table indiekit:latest
    '';
    serve.exec = ''
      # npx indiekit serve --port 3002
      node node_modules/@indiekit/indiekit/bin/cli.js serve --port 3001
    '';
    versions.exec = ''
      echo "=== Versions ==="
      git --version
      echo "Node.js $(node --version)"
      echo "=== === ==="
    '';
  };

  services = {
    mongodb = {
      enable = true;
      additionalArgs = [
        "--port"
        "${config.env.MONGO_PORT}"
      ];
      initDatabasePassword = "${config.env.MONGO_INITDB_ROOT_PASSWORD}";
      initDatabaseUsername = "${config.env.MONGO_INITDB_ROOT_USERNAME}";
    };
  };

  tasks = {
    "app:versions" = {
      exec = "versions";
    };
    "bash:hello" = {
      exec = "echo 'Hello World'";
    };
  };
}
