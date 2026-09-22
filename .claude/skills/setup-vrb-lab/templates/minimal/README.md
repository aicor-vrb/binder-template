# __LAB_TITLE__

[![Binder](https://binder.intel4coro.de/badge_logo.svg)](https://binder.intel4coro.de/v2/gh/__GITHUB_USER__/__REPO__/__BRANCH__?urlpath=lab/tree/__DEFAULT_NOTEBOOK__)

__LAB_DESCRIPTION__

This lab is part of the [EASE Virtual Research Building (VRB)](https://vrb.ease-crc.org/).
It packages [__PROJECT_NAME__](__PROJECT_URL__) so it can be tried in the browser without installing anything.

## Launch

| Interface | Link |
|-----------|------|
| JupyterLab (opens `__DEFAULT_NOTEBOOK__`) | https://binder.intel4coro.de/v2/gh/__GITHUB_USER__/__REPO__/__BRANCH__?urlpath=lab/tree/__DEFAULT_NOTEBOOK__ |
| JupyterLab (saved layout) | https://binder.intel4coro.de/v2/gh/__GITHUB_USER__/__REPO__/__BRANCH__?urlpath=lab/workspaces/new-workspace |
| VSCode | https://binder.intel4coro.de/v2/gh/__GITHUB_USER__/__REPO__/__BRANCH__?urlpath=vscode |

The first launch after a push builds the Docker image and can take a long time. Later launches reuse the image.

To freeze the lab to a specific version, replace `__BRANCH__` in the URL with a tag or a commit hash.

## What is inside

- `__DEFAULT_NOTEBOOK__` – start here
- `binder/Dockerfile` – how the image is built (base image, system packages, project install)
- `binder/entrypoint.sh` – what runs before JupyterLab starts (sources ROS, workspaces)
- `requirements.txt` – Python packages
- `binder/docker-compose.yml` – run the lab locally

## Run locally

Requires Docker and Docker Compose on Linux.

```bash
docker compose -f binder/docker-compose.yml up --build
# open http://localhost:8888
docker compose -f binder/docker-compose.yml down
```

The repository is mounted into the container, so notebook and code edits are visible immediately.
Files created inside the container belong to root; fix ownership with `sudo chown -R $USER:$USER .` if needed.

## Credits

Created with the `setup-vrb-lab` skill from [aicor-vrb/binder-template](https://github.com/aicor-vrb/binder-template).
