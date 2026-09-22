# Troubleshooting and pre-push checklist

## Pre-push checklist

Run through this before proposing the first push. Each item is a common Binder failure.

- [ ] Every `git clone` URL in the Dockerfile and in `.gitmodules` is `https://`, not `git@`
- [ ] `USER root` precedes any `apt` or system-wide `pip` install
- [ ] Every `apt install` is in the same `RUN` as an `apt update` (and `rm -rf /var/lib/apt/lists/*` after)
- [ ] No `cd` whose effect is expected in a later `RUN` (use `WORKDIR` or `cd ... && ...` in one `RUN`)
- [ ] Time-consuming, rarely changing steps (apt, clones, big pip installs) come **before** `COPY . ${REPO_DIR}/`
- [ ] `requirements.txt` is copied and installed before `COPY .` so a notebook edit does not reinstall everything
- [ ] The entrypoint ends with `exec "$@"` and nothing before it blocks in the foreground
- [ ] No secrets, tokens or private URLs in the repo
- [ ] No files over ~50 MB unless intended (GitHub warns at 50 MB, rejects at 100 MB)
- [ ] The default notebook path used in the launch URL exists and is spelled correctly (case matters)
- [ ] Clones and ROS workspaces are under `${REPO_DIR}`; nothing the visitor needs sits in `${HOME}/libs` or `/workspace`
- [ ] README launch links point at the *new* owner/repo/branch
- [ ] The repository will be **public**
- [ ] Local `docker compose ... up --build` succeeded and JupyterLab opened

## Build failures

| Symptom in log | Cause | Fix |
|----------------|-------|-----|
| `E: Unable to locate package` | No `apt update` in that layer, or wrong package name for this Ubuntu | Same `RUN` as `apt update`; check the name for the Ubuntu version of the base image (Jazzy → 24.04, Humble → 22.04, Noetic → 20.04) |
| `Permission denied` during install | Not root | Add `USER root` before the `RUN` |
| `fatal: Could not read from remote repository` / `Host key verification failed` | SSH clone URL | Use HTTPS; also in `.gitmodules` |
| `returned a non-zero code: N` | Some command in the `RUN` failed | Scroll up; the real error is above the last line. Rebuild with `docker compose build --progress=plain` to see everything |
| `No such file or directory` | `cd` from a previous `RUN` did not persist, or file copied later than used | Combine commands or use `WORKDIR`; move `COPY` earlier |
| `error: externally-managed-environment` | pip refuses system install on newer Ubuntu | Use the conda Python (`python3 -m pip` in the intel4coro image is already conda) or add `--break-system-packages` on official ROS images |
| `ResolutionImpossible` from pip | Conflicting pins | Relax pins; check Python version of the base image |
| `rosdep: command not found` / `rosdep init` errors | rosdep not initialized | `rosdep init || true && rosdep update` before `rosdep install` |
| colcon `Package ... not found` | Missing ROS dependency | `rosdep install --from-paths src -y --ignore-src` or add `ros-$ROS_DISTRO-<pkg>` to apt |
| Build stalls on `Configuring tzdata` or similar prompt | Interactive apt | `ENV DEBIAN_FRONTEND=noninteractive` |
| Out of disk / very long build on Binder | Image too large | Use `--depth=1` clones, delete build dirs, avoid `-desktop-full` metapackages |

## Runtime failures

| Symptom | Cause | Fix |
|---------|-------|-----|
| Binder shows "Timeout" after a successful build | Entrypoint does not reach `exec "$@"`, or Jupyter crashes | Run locally, check `docker compose logs`; look for a foreground process in `entrypoint.sh` |
| Container exits immediately locally | Same as above, or `command:` in compose is wrong | `docker compose logs` |
| JupyterLab starts but notebook is missing | Wrong `WORKDIR` or wrong path in launch URL | Check `WORKDIR ${REPO_DIR}` and the `lab/tree/...` path |
| `ModuleNotFoundError` for the project | Not installed, or installed into a different Python | Install with `python3 -m pip` (same interpreter as the kernel); for ROS Python packages, source the workspace in `entrypoint.sh` |
| ROS packages not found in notebook | Workspace not sourced in the process that starts Jupyter | Source the `setup.bash` in `binder/entrypoint.sh` (the template's entrypoint does this for known paths) |
| GUI app cannot open display | No display in headless Binder | Start it on `DISPLAY=:1` (the VNC desktop) and open the Desktop tab, or set `LIBGL_ALWAYS_SOFTWARE=1` |
| Project folder missing from the file browser | Cloned outside `${REPO_DIR}`, or the compose volume mount hides it | Clone into `${REPO_DIR}/<project>`; locally, comment out `volumes:` or clone by hand into the lab directory |
| Files owned by root on host after local run | Container runs as root | `sudo chown -R $USER:$USER <lab-directory>` |
| Port 8888 already in use locally | Another Jupyter | Stop it or change the port mapping in `binder/docker-compose.yml` |
| Changes to Python files not visible locally | Volume mount missing | Check the `volumes:` line maps `../:/home/repo` |
