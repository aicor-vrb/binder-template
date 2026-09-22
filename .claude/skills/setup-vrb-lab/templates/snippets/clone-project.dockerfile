# --- Clone the project from GitHub (put in the EXTERNAL REPOSITORIES section) ---
# Destination is INSIDE ${REPO_DIR}: JupyterLab's file browser is rooted there, so a
# clone anywhere else (${HOME}/libs, /workspace, ...) is importable but invisible to
# the visitor. Requires `ENV REPO_DIR=/home/repo` to be defined further up.
#
# Placed BEFORE `COPY . ${REPO_DIR}/` so Docker caches it between pushes; COPY merges
# into the directory and does not delete the clone.
# Pin __BRANCH__ to a tag or commit for a reproducible lab. HTTPS URL only.
ENV PROJECT_DIR=${REPO_DIR}/__PROJECT_NAME__
RUN git clone --depth=1 --branch __BRANCH__ __PROJECT_URL__ ${PROJECT_DIR}
# To pin an exact commit instead (drop --depth=1 and --branch):
# RUN git clone __PROJECT_URL__ ${PROJECT_DIR} && git -C ${PROJECT_DIR} checkout __COMMIT__
#
# Local `docker compose` mounts ../ over /home/repo and hides this clone. Either clone
# __PROJECT_NAME__ into the lab directory by hand (and list it in the lab .gitignore, so
# `git add .` does not commit a nested checkout) or comment out the volumes: line.
