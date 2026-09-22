---
name: setup-vrb-lab
description: Turn an existing research project (local folder or GitHub repo) into a new Virtual Research Lab for the EASE Virtual Research Building (VRB) that runs on BinderHub. Guides a first-time lab author step by step, asks before every decision that is not obvious, and never touches git or GitHub without explicit consent. Use when someone wants to create, set up, or integrate a project into a VRB lab / Binder lab.
---

# Set up a new Virtual Research Lab (VRB)

You are helping someone who has probably never built a VRB lab before. Your job is to
turn **their project** into a **public GitHub repository** that BinderHub
(`https://binder.intel4coro.de`) can build into a Docker image and launch as JupyterLab.

**The repository you are running in is that lab.** It is a clone or fork of the VRB
template, and it already contains everything a lab needs: `binder/Dockerfile`,
`binder/entrypoint.sh`, `binder/docker-compose.yml`, `requirements.txt`, `notebooks/`,
`README.md`. Setting up a lab means **editing those files in place** — above all
`binder/Dockerfile`. Do not scaffold a second lab in another directory.

Work interactively. Explain what each step does in one or two sentences before doing it.
Prefer asking one focused question over guessing.

## Hard rules

1. **Never run git or GitHub commands without being told to.** No `git init`, `git add`,
   `git commit`, `git push`, `gh repo create`, no creating branches, tags, or repos.
   Always show the exact command, explain what it does, and wait for a clear "yes".
   Approval for one command does not carry over to the next one.
2. **Always propose a local Docker build test before pushing.** Online builds on Binder
   are slow (often 10 to 40 minutes). Local iteration finds small mistakes in minutes.
3. **Everything the visitor should see goes under `${REPO_DIR}` (`/home/repo`).**
   See "Where files must live" below. Never clone the project into `/home/${NB_USER}/libs`,
   `/workspace` or any other path outside it.
4. **Build the lab in this repository, in place.** Change `binder/Dockerfile` and the
   other files at the repository root. Never create a new lab directory, never copy the
   template or `templates/minimal/` somewhere else, never write outside this repository.
   The one exception: the user explicitly asks for a separate lab repo — then say that
   the simplest route is a fresh clone or fork of the template and let them make it.
5. **Do not modify the user's original project** unless they ask. Their project is an
   input; the edits happen here.
6. **When the project analysis is ambiguous, ask.** Do not invent dependencies, ROS
   distributions, or entry points.
7. If any file you write contains a placeholder (`__LIKE_THIS__`), fill it in or
   ask for the value. Never leave placeholders behind.

## Where files must live

The lab image sets `ENV REPO_DIR=/home/repo` and `WORKDIR ${REPO_DIR}`. JupyterLab serves
that directory as its root, so **the file browser cannot show anything above or outside it**.
A project cloned to `/home/${NB_USER}/libs/foo` is importable but invisible: the visitor
opens the lab and sees only the lab's own files, with no way to browse, read or edit the
code the lab is actually about.

So: clone the project to `${REPO_DIR}/<project-name>`, and put ROS workspaces at
`${REPO_DIR}/ros2_ws` or `${REPO_DIR}/catkin_ws` (the paths `binder/entrypoint.sh` already
sources). This costs nothing in build time: `COPY . ${REPO_DIR}/` merges into the directory
instead of replacing it, so a clone placed *before* the `COPY` line stays cached across
pushes and survives it.

Two consequences to tell the user about:

- `ENV REPO_DIR=/home/repo` must appear **above** the clone, not next to the `COPY` line.
- During a local `docker compose` run, `../:/home/repo` mounts the host directory over
  `${REPO_DIR}`, which hides anything the build put there (the clone, `ros2_ws/install/`).
  On Binder there is no mount and everything is present. To exercise the real layout
  locally, either clone the project into the repository root by hand (and add it to
  `.gitignore`) or comment out the `volumes:` line in `binder/docker-compose.yml`.

## Files that belong to this skill

All paths are relative to the directory that contains this `SKILL.md`:

| Path | Purpose |
|------|---------|
| `templates/minimal/` | Reference skeleton of a lean lab. **Read blocks out of it into this repository's files; never copy the directory anywhere.** |
| `templates/snippets/*.dockerfile` | Dockerfile blocks to splice in: clone project, pip install, colcon (ROS 2), catkin (ROS 1), ROS 1 base image |
| `reference/project-analysis.md` | How to detect what kind of project the user has and what it needs |
| `reference/base-images.md` | Available base images and which ROS versions they support |
| `reference/troubleshooting.md` | Build and runtime problems with fixes; the checklist to run before pushing |

## The repository you are in is the lab

Three directories above this `SKILL.md` is the repository root: the lab you are editing.
In its shipped state it is the "CRAM preinstalled" flavor — `binder/Dockerfile` installs
the PyCRAM / cognitive_robot_abstract_machine stack and the IAI robot descriptions.

The files you change are always these, at the repository root:

| File | What you do to it |
|------|-------------------|
| `binder/Dockerfile` | The main work: base image, apt packages, the project clone or copy, build steps |
| `requirements.txt` | Python dependencies of the project |
| `notebooks/` | The notebook a visitor opens first |
| `README.md` | Title, description, launch links and badge |
| `binder/entrypoint.sh` | Only if something must run at startup (background processes only) |
| `binder/docker-compose.yml` | Only for local extras (GPU, host display) |

If you are somehow **not** inside a clone of the template (no `binder/Dockerfile` at the
repository root), stop and say so: the user should clone or fork
`https://github.com/aicor-vrb/binder-template` first and re-run the skill inside it.
Ask before cloning it yourself.

## Workflow

### Step 0: Check the tools

Run these and report what is available. Missing tools are not blockers; they change
what you can offer later.

```bash
git --version
docker --version && docker compose version && docker info >/dev/null && echo "docker daemon reachable"
gh --version && gh auth status
```

Docker missing means no local build test (say so clearly and recommend installing it).
`docker info` failing with "permission denied ... docker.sock" means the user is not in the
`docker` group: suggest `sudo usermod -aG docker $USER` followed by a re-login (do not run
it yourself). `gh` missing means GitHub steps are done in the browser instead of the CLI.

### Step 1: Find out what should be integrated

If the user has not already said which project to integrate, ask:

> Which project should become the lab? Give me a local directory path or a GitHub URL.

Then determine:

- **Local directory** → confirm it exists and list its top level.
- **GitHub URL** → normalize to HTTPS (`https://github.com/<org>/<repo>.git`). SSH URLs do
  not work inside Binder builds. Ask which branch, tag, or commit to use; default `main`.
  Clone it read-only into a temporary directory to analyze it (this is not a git decision
  about *their* repo, but tell them you are doing it).
- Neither → ask again; do not proceed without a project.

### Step 2: Analyze the project

Follow `reference/project-analysis.md`. Produce a short summary for the user in plain words:

- What kind of project it is (Python package, ROS 2 workspace, ROS 1 workspace, notebooks only, mixed, unknown)
- Which ROS distribution it appears to need, if any, and how confident you are
- Python dependencies found (and where: `requirements.txt`, `pyproject.toml`, `setup.py`, `environment.yml`)
- System (apt) dependencies you can see (README install sections, `package.xml`, Dockerfiles)
- Notebooks found, and a guess at the best "open this first" notebook
- Anything you could not figure out

Ask the user to confirm or correct this summary before continuing. Concretely ask about
every "unknown" item.

### Step 3: Decisions (ask, do not assume)

Ask these one at a time. Recommend an option when the analysis supports it, but let the user choose.

1. **Flavor** — both are the same repository, the difference is what stays in
   `binder/Dockerfile`.
   - *Minimal*: strip the CRAM blocks out of `binder/Dockerfile` (the poetry/CRAM install
     and the `/workspace/ros` clone-and-colcon block), leaving base image, apt, pip, COPY
     and entrypoint. Use `templates/minimal/binder/Dockerfile` as the reference for what
     should remain. Fast builds. Recommended for most projects.
   - *CRAM preinstalled*: keep those blocks. Very long build (well over an hour on
     Binder). Only sensible when the project builds on PyCRAM or the IAI robots.
   Whichever they pick, show the removals as a diff and get a yes before writing.
2. **ROS version** (see `reference/base-images.md`)
   - None, ROS 2 Jazzy (default base image), ROS 2 Humble, ROS 1 Noetic, or another
     distribution. Recommend what the analysis found. If the project needs a
     distribution that no ready-made image covers, explain the "other base image" path
     (install JupyterLab yourself, expose port 8888) and its trade-offs (no VSCode, no
     VNC desktop unless they add it).
3. **How to bring the project into the lab**
   | Mode | When to recommend | What it means |
   |------|-------------------|---------------|
   | Copy | Project is a local directory, or the user wants the lab to be self-contained | Files are copied into the lab repo and land in the image via `COPY . /home/repo/` |
   | Clone in Dockerfile | Project is on GitHub and evolves independently | `RUN git clone` into `${REPO_DIR}/<project>` placed *before* the `COPY` line so Docker caches it; pin a branch/tag/commit |
   | Git submodule | User wants version tracking of the project inside the lab repo | `git submodule add <https url>`; remind them: HTTPS only, and the lab README must mention `--recurse-submodules` |
   Default: local → Copy, GitHub URL → Clone in Dockerfile.
4. **Lab name**, used in the README title and later as the GitHub repository name.
   Suggest `<project>-vrb-lab` or similar; lowercase, hyphens. This does **not** rename
   the directory on disk — the lab stays where it is.
5. **Which notebook opens at launch.** Offer the guess from Step 2, or write a new
   `notebooks/welcome.ipynb` modelled on `templates/minimal/notebooks/welcome.ipynb`.
   Ask before replacing or deleting `notebooks/demo.ipynb`.
6. **Extras**: GPU section in compose (only for local use), RViz autostart, desktop panel.
   Default all off for Minimal (the RViz autostart lives in `binder/entrypoint.sh`).
7. **Branch.** Report the current branch (`git branch --show-current`) and ask whether to
   work on it or on a new one, suggesting `<repo-name>_vrb_lab` (the repository's own name,
   lowercase, underscores) as the name. Recommend a new branch when the current branch is
   `main` or carries unrelated work, and the current branch when they are already on one
   made for this lab. A new branch needs a yes before you run `git switch -c <name>`
   (Hard rule 1), and it is the branch that ends up in the Binder launch URL in Step 7.

Summarize all decisions in a table and get one final confirmation.

### Step 4: Edit this repository

Everything below happens in the repository you are running in. No new directory, no copy
of the template elsewhere. Before the first edit: if a new branch was chosen in Step 3,
create it now (`git switch -c <name>`, with the yes from that decision), then show
`git status` so the user sees a clean starting point, and tell them which files you are
about to touch.

**1. `binder/Dockerfile` (the main work)**

- *Minimal flavor*: remove the CRAM blocks (the `poetry` / cognitive_robot_abstract_machine
  install and the `/workspace/ros` clone-and-colcon block), and the `ros-jazzy-*` apt
  packages that only CRAM needs. Compare against
  `templates/minimal/binder/Dockerfile` for the structure that should remain.
- *CRAM preinstalled flavor*: leave those blocks untouched.
- Change the `FROM` line if a different ROS distribution was chosen
  (`reference/base-images.md`; for ROS 1 use `templates/snippets/ros1-noetic-base.dockerfile`).
- Make sure `ENV REPO_DIR=/home/repo` stands **above** the clone section; move it up if
  this repository still defines it next to `COPY . ${REPO_DIR}/`.
- Add apt packages found in Step 2 to the apt block (same `RUN` as `apt update`).

**2. Bring the project in, according to the mode chosen in Step 3**

- *Copy*: `cp -r` the project into `<repo-root>/<project-name>/` (exclude `.git`,
  `__pycache__`, virtualenvs, large data unless the user wants it). Tell the user what was
  excluded. It reaches the image through the existing `COPY . ${REPO_DIR}/`.
- *Clone*: splice `templates/snippets/clone-project.dockerfile` in before
  `COPY . ${REPO_DIR}/`. It clones into `${REPO_DIR}/<project-name>`, so the project is
  visible in the file browser.
- *Submodule*: show the `git submodule add` command and wait for consent (Hard rule 1).

**3. Build steps** from `templates/snippets/`, after `COPY . ${REPO_DIR}/`:

- Python package → `python-package.dockerfile`
- ROS 2 package(s) → `ros2-colcon.dockerfile`
- ROS 1 package(s) → `ros1-catkin.dockerfile`
- Plain requirements → append to this repository's `requirements.txt`

**4. The rest of the repository**

- `notebooks/`: add or adjust the notebook that opens at launch. Ask before touching
  `notebooks/demo.ipynb`, `notebooks/demo_ui.py`, `notebooks/utils.py` or `notebooks/rviz/`.
- `README.md`: title, one paragraph on what the lab shows, launch links and badge pointing
  at the user's own owner/repo/branch — the shipped links point at the template and would
  otherwise launch someone else's lab.
- `binder/entrypoint.sh`: for the Minimal flavor, point out `update_cognitive_architecture`
  (pulls CRAM on every start) and `start_rviz`, and ask whether to remove them.
- Mention `default.rviz`, `kitchen-default.rviz`, `webapps.json`, `NOTEBOOK_UI_README.md`
  and `img/` as demo leftovers they may want to clean up; do not delete without a yes.

**5. Review before building**

- Cache order: apt and clones near the top, `COPY . ${REPO_DIR}/` as late as possible,
  only steps that need the repository contents after it.
- Every path the build writes to is under `${REPO_DIR}`, or the visitor cannot see it
  (see "Where files must live").
- No placeholder (`__LIKE_THIS__`) is left anywhere.
- Show the full diff of `binder/Dockerfile` and explain each block you changed.

### Step 5: Local build test (always propose this)

Say explicitly why: Binder builds are slow, and the error you find locally in 5 minutes
would take an hour to find online.

```bash
docker compose -f binder/docker-compose.yml up --build
```

Run it from the repository root (the compose file builds with `context: ../`).

Then open `http://localhost:8888`. Ask the user to check:

- JupyterLab loads, the default notebook opens
- The project folder is listed in the file browser next to the notebooks (with the compose
  volume mount active it will not be; see "Where files must live")
- The project imports / launches (run one cell or one command that exercises it)
- For ROS: `ros2 pkg list | grep <pkg>` or `rospack find <pkg>` in a terminal

If the build fails, read the log from the *first* error upward (Docker prints the last
line of a failed command, but the real cause is often higher). Use
`reference/troubleshooting.md`. Fix, rebuild, repeat. Stop with
`docker compose -f binder/docker-compose.yml down`.

Files created inside the container are owned by root; if the user hits permission errors
on the host: `sudo chown -R $USER:$USER .` in the repository root.

Only skip this step if the user explicitly declines or Docker is unavailable.

### Step 6: Git and GitHub (every action needs a yes)

Explain the goal: the lab must be a **public** GitHub repository so Binder can fetch it.
This repository is already a git repository, so there is no `git init` — the question is
*where it gets pushed*. Walk through, asking before each command:

1. Show `git remote -v`, `git status` and the current branch. Establish who owns `origin`:
   the user's own fork, or the upstream template. **Never push to a remote the user does
   not own.** The branch was decided in Step 3; confirm it is still the one they want
   published, since its name goes into the launch URL.
2. Review what will be committed; warn about large files (videos, meshes, datasets over
   ~50 MB) and secrets. If the work ended up on `main` after all, offer a branch now.
3. `git add <paths>` and `git commit -m "..."` (propose a message). Prefer naming the
   changed paths over `git add .` when the project was copied in.
4. Publishing, depending on what step 1 found:
   - `origin` is the user's own repository → `git push -u origin <branch>`.
   - `origin` is the template → the lab needs a repository of their own. Ask **where**
     (their account or an organization such as `aicor-vrb`) and under which **name**, then
     `git remote rename origin upstream` and
     `gh repo create <owner>/<name> --public --source . --remote origin --push`,
     or without `gh` the browser steps plus `git remote add origin <https url>` and
     `git push -u origin <branch>`.
   - Either way: the repository must be **public**, and the branch name goes into the
     launch URL in Step 7.
5. Submodules, if used: verify `.gitmodules` uses HTTPS URLs.

If the user prefers to do all of this themselves, print the full list of commands and stop.

### Step 7: Launch on Binder and verify

Build the launch URL and show it:

```
https://binder.intel4coro.de/v2/gh/<owner>/<repo>/<branch>?urlpath=lab/tree/<path-to-notebook>
```

- `urlpath=lab/workspaces/new-workspace` opens the saved layout instead of one notebook
- `urlpath=vscode` opens VSCode
- Replace `<branch>` with a tag or commit hash for a frozen, reproducible lab

Tell the user the first launch builds the image and can take a long time; later launches
are fast until the next push (Binder rebuilds when the branch has new commits).

Also add the badge to the README if it is not there yet:

```
[![Binder](https://binder.intel4coro.de/badge_logo.svg)](<launch url>)
```

### Step 8: Listing the lab in the VRB (ask)

The VRB overview page (`https://vrb.ease-crc.org/`) and the aicor-vrb GitHub page bundle
the existing labs. Ask whether the new lab should be listed there. If yes, ask the user
where and how they want it registered (they, or the VRB maintainers, know the process);
prepare a short entry (title, one sentence, launch link) they can submit. Do not attempt
to edit those pages yourself.

## Finishing

End with a short recap: which files in this repository you changed, what was built and
tested, where it was pushed, the launch URL, and anything still open (untested steps,
skipped decisions, demo leftovers you did not remove, known limitations).
