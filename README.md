# My Indiekit server

This repository contains the configuration for the Indiekit server I use for [giacomodebidda.com](https://www.giacomodebidda.com/).

## Development

To run this project locally you will need a MongoDB database and the Indiekit app itself. The file [`devenv.nix`](./devenv.nix) declares all the necessary components for a complete developer environment. This file is used by [devenv](https://github.com/cachix/devenv) to create and manage such environment.

`devenv.nix` defines a `mongodb` service (under the hood this background process is managed by [Process Compose](https://github.com/F1bonacc1/process-compose)). You can start it by running this command in a terminal:

```sh
devenv up
```

To run the Indiekit Node.js app itself you have these alternatives:

- run the `serve` script defined in `devenv.nix` to launch Indiekit as a **Node.js application**.
- run the `container-run` script defined in `devenv.nix` to launch Indiekit as a **containerized application** (you will need to build the container image first by running `container-build`).
- Click **Run and Debug** in VS Code to use the [launch configuration](https://code.visualstudio.com/docs/editor/debugging#_launch-configurations) provided in `.vscode/launch.json`.

> [!TIP]
> When debugging is useful to set the `DEBUG` environment variable.

## Production

My Indiekit server is deployed on [Fly.io](https://fly.io/). My MongoDB database is hosted on [MongoDB Atlas](https://www.mongodb.com/products/platform/atlas-database).

Every time I need to deploy a new version of my Indiekit server I run this command:

```sh
fly-deploy
```

> [!NOTE]
> The `Dockerfile` is used to build the container image locally and it's also used by Fly.io. However, [Fly.io uses a Dockerfile not to build a container image, but to create a Firecracker microVM](https://fly.io/blog/docker-without-docker/).

Whenever I change a secret (e.g. `MONGO_URL`), I redeploy my secrets to Fly.io using this command.

```sh
fly-secrets-set
```

> [!WARNING]
> As far as I understand, existing deployments in Fly.io are not updated to use the new secrets, so as soon as I edit my secrets I immediately redeploy my Indiekit server with `fly-deploy`.

## Troubleshooting

To explore all layers of the container image, you can run this command that launches [dive](https://github.com/wagoodman/dive):

```sh
container-dive
```

To scan the container image for vulnerabilities, you can run this command that uses [trivy](https://github.com/aquasecurity/trivy):

```sh
container-dive
```

To inspect the developer environment generated by devenv, you can run `devenv info`.

> [!CAUTION]
> The command `devenv info` will print all the secrets that you defined in your `devenv.nix`.

When testing localizations, I find it useful to launch an instance of Indiekit in English, and another one in the target locale (e.g. Italian). This is how I do it:

```sh
serve    # port 3001
serve-it # port 3002
```

## Other people's Indiekit configurations

- [ciccarello-indiekit](https://github.com/aciccarello/ciccarello-indiekit/)
- [paulrobertlloyd-indiekit](https://github.com/paulrobertlloyd/paulrobertlloyd-indiekit)
