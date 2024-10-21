{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cloudflare_r2 = builtins.fromJSON (builtins.readFile /run/secrets/cloudflare/r2);
  fly_indiekit = builtins.fromJSON (builtins.readFile /run/secrets/fly/indiekit);
  indiekit = builtins.fromJSON (builtins.readFile /run/secrets/indiekit);
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
    FLY_API_TOKEN = fly_indiekit.deploy_token;
    GITHUB_TOKEN = builtins.readFile /run/secrets/github-tokens/indiekit_github_content_store;
    MONGO_PORT = "27017";
    MONGO_INITDB_ROOT_USERNAME = "mongoadmin";
    MONGO_INITDB_ROOT_PASSWORD = "secret";
    # MongoDB I use in development (use `devenv up` to launch it)
    MONGO_URL = "mongodb://${config.env.MONGO_INITDB_ROOT_USERNAME}:${config.env.MONGO_INITDB_ROOT_PASSWORD}@localhost:${config.env.MONGO_PORT}";
    # MongoDB I use in production (hosted on MongoDB Atlas)
    MONGO_URL_PRODUCTION = indiekit.mongo_url;
    PASSWORD_SECRET = indiekit.password_secret;
    PASSWORD_SECRET_ESCAPED = indiekit.password_secret_escaped;
    PORT = "3001";
    S3_ACCESS_KEY = cloudflare_r2.personal.access_key_id;
    S3_SECRET_KEY = cloudflare_r2.personal.secret_access_key;
    SECRET = indiekit.secret;
  };

  languages = {
    nix.enable = true;
  };

  packages = with pkgs; [
    dive # tool for exploring each layer in a docker image
    git
    nodejs
    trivy # container scanner
  ];

  # https://devenv.sh/pre-commit-hooks/
  pre-commit.hooks = {
    alejandra.enable = true;
    hadolint.enable = true;
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

    container-dive.exec = "dive indiekit:latest";

    container-inspect.exec = ''
      docker inspect indiekit:latest --format json | jq "."
    '';

    container-run.exec = ''
      docker run \
        --env DEBUG="indiekit:*,-indiekit:request,indiekit-store:*" \
        --env GITHUB_TOKEN=${config.env.GITHUB_TOKEN} \
        --env MONGO_URL=${config.env.MONGO_URL} \
        --env PASSWORD_SECRET=${config.env.PASSWORD_SECRET_ESCAPED} \
        --env PORT=${config.env.PORT} \
        --env SECRET=${config.env.SECRET} \
        --network host \
        indiekit:latest
    '';

    container-scan.exec = ''
      trivy image --severity MEDIUM,HIGH,CRITICAL -f table indiekit:latest
    '';

    fly-deploy.exec = "fly deploy --ha=false --debug --verbose";

    fly-scale.exec = "fly scale count 1 --debug --verbose";

    fly-secrets-set.exec = ''
      fly secrets set GITHUB_TOKEN="${config.env.GITHUB_TOKEN}"
      fly secrets set MONGO_URL="${config.env.MONGO_URL_PRODUCTION}"
      fly secrets set PASSWORD_SECRET="${config.env.PASSWORD_SECRET_ESCAPED}"
      fly secrets set S3_ACCESS_KEY="${config.env.S3_ACCESS_KEY}"
      fly secrets set S3_SECRET_KEY="${config.env.S3_SECRET_KEY}"
      fly secrets set SECRET="${config.env.SECRET}"
    '';

    fly-secrets-unset.exec = ''
      fly secrets unset GITHUB_TOKEN
      fly secrets unset MONGO_URL
      fly secrets unset PASSWORD_SECRET
      fly secrets unset S3_ACCESS_KEY
      fly secrets unset S3_SECRET_KEY
      fly secrets unset SECRET
    '';

    serve.exec = ''
      node node_modules/@indiekit/indiekit/bin/cli.js serve \
      --config indiekit.config.js --port ${config.env.PORT}
    '';

    versions.exec = ''
      echo "=== Versions ==="
      dive --version
      docker --version
      fly version
      git --version
      echo "Node.js $(node --version)"
      echo "=== === ==="
    '';
  };

  services = {
    # minio.enable = true;
    # opentelemetry-collector.enable = true;
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
}
