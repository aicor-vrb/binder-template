#!/bin/bash
# Entrypoint of the VRB lab image. Binder (and docker-compose) pass the
# JupyterLab start command as arguments; this script prepares the shell
# environment and then hands over with `exec "$@"`.
#
# Do NOT start blocking foreground processes here. Background helpers must
# end with `&`, otherwise Jupyter never starts and Binder reports a timeout.
set -e

REPO_DIR="${REPO_DIR:-/home/repo}"

# --- Source ROS (if the base image provides it) ------------------------------
if [[ -n "${ROS_PATH:-}" && -f "${ROS_PATH}/setup.bash" ]]; then
    # shellcheck disable=SC1091
    source "${ROS_PATH}/setup.bash"
elif [[ -n "${ROS_DISTRO:-}" && -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]]; then
    # shellcheck disable=SC1091
    source "/opt/ros/${ROS_DISTRO}/setup.bash"
fi

# --- Source built workspaces (if any exist) ----------------------------------
for ws_setup in \
    "${REPO_DIR}/ros2_ws/install/setup.bash" \
    "${REPO_DIR}/catkin_ws/devel/setup.bash" \
    "/workspace/ros/install/setup.bash"
do
    if [[ -f "${ws_setup}" ]]; then
        # shellcheck disable=SC1090
        source "${ws_setup}"
    fi
done

# --- Restore the saved JupyterLab layout (optional) --------------------------
workspace_file="${JUPYTER_WORKSPACE_FILE:-${REPO_DIR}/new-workspace.jupyterlab-workspace}"
if [[ -f "${workspace_file}" ]]; then
    jupyter lab workspaces import "${workspace_file}" >/tmp/jupyter-workspace-import.log 2>&1 || \
        echo "Workspace import failed; see /tmp/jupyter-workspace-import.log" >&2
fi

# --- Lab-specific startup (background only) ----------------------------------
# Example: start a ROS node visitors need, in the background:
# ros2 launch my_pkg my_launch.py >/tmp/my_launch.log 2>&1 &

exec "$@"
