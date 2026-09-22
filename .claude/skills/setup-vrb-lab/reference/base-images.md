# Base images

Verified on Docker Hub on 2026-09-14. Re-check with:

```bash
curl -s "https://hub.docker.com/v2/repositories/intel4coro/jupyter-ros2/tags?page_size=100" | python3 -c "import sys,json;print([t['name'] for t in json.load(sys.stdin)['results']])"
```

## Recommended: `intel4coro/jupyter-ros2`

Source: https://github.com/IntEL4CoRo/jupyter-ros2

| Tag | ROS | Python | Notes |
|-----|-----|--------|-------|
| `jazzy-py3.12` | ROS 2 Jazzy (desktop) | 3.12 (conda) | Default of the template |
| `humble-py3.10` | ROS 2 Humble (desktop) | 3.10 (conda) | Use when the project needs Humble |

Both include JupyterLab, VSCode server, a VNC/Xpra desktop (`DISPLAY=:1`), mamba, git.
Useful environment variables the image defines: `ROS_DISTRO`, `ROS_PATH=/opt/ros/$ROS_DISTRO`,
`NB_USER=jovyan`, `HOME=/home/jovyan`, `CODE_WORKING_DIRECTORY`. The image ends as
`USER jovyan`; the template switches to `USER root` for installs and stays root.

Works for projects **without ROS** too; the ROS install is simply unused. This is the
simplest choice for a plain Python project because VSCode and the desktop come for free.

## ROS 1 Noetic

No documented intel4coro ROS 1 image with a matching README. Two options:

1. **Official ROS image plus JupyterLab** (documented path, in `templates/snippets/ros1-noetic-base.dockerfile`).
   No VSCode, no desktop. Ubuntu 20.04, Python 3.8. Good enough for notebooks and CLI.
2. `intel4coro/base-notebook` has tags `noetic`, `20.04-noetic-xpra`, `20.04-noetic-full-xpra`
   and others. The repository is not public, so the contents are undocumented. Only use if
   the user already knows these images; test locally first.

## Other ROS 2 distributions (Iron, Rolling, ...)

`intel4coro/base-notebook` lists `py3.10-ros-iron` and `22.04-iron`, also undocumented.
Otherwise start from `ros:<distro>` or `osrf/ros:<distro>-desktop` and add JupyterLab, as
in the ROS 1 snippet but with `ros2` paths. Requirements for any custom base image:

1. JupyterLab installed and on `PATH`
2. Port 8888 exposed
3. An entrypoint that sources ROS and ends in `exec "$@"`

The Binder default command is `jupyter lab --ip=0.0.0.0 --port=8888 ...`; the entrypoint
must not block before `exec "$@"`.
