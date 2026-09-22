# --- Build a ROS 2 workspace with colcon ----------------------------------------
# Variant A (cached): clone + build before COPY, so a push that only changes notebooks
# does not rebuild the workspace. The workspace lives INSIDE ${REPO_DIR} so the visitor
# can see and edit the sources in the file browser; requires ENV REPO_DIR further up.
# COPY merges into ${REPO_DIR} and does not delete what this block created.
ENV ROS2_WS=${REPO_DIR}/ros2_ws
RUN mkdir -p ${ROS2_WS}/src && \
    git clone --depth=1 --branch __BRANCH__ __PROJECT_URL__ ${ROS2_WS}/src/__PROJECT_NAME__ && \
    cd ${ROS2_WS} && \
    . ${ROS_PATH}/setup.sh && \
    (rosdep init >/dev/null 2>&1 || true) && rosdep update && \
    apt update && rosdep install --from-paths src --ignore-src -y && \
    rm -rf /var/lib/apt/lists/* && \
    colcon build --symlink-install && \
    rm -rf build log
# binder/entrypoint.sh already sources ${REPO_DIR}/ros2_ws/install/setup.bash; nothing to add.
# Note: a local `docker compose` run mounts ../ over /home/repo and hides install/, so ROS
# packages are not found locally unless you build the workspace in the mounted directory.

# Variant B (rebuilds on every push): project COPIED into the repo under ros2_ws/src.
# Put this block in PROJECT BUILD STEPS (after COPY). Same path, also visible.
# RUN cd ${REPO_DIR}/ros2_ws && \
#     . ${ROS_PATH}/setup.sh && \
#     (rosdep init >/dev/null 2>&1 || true) && rosdep update && \
#     apt update && rosdep install --from-paths src --ignore-src -y && \
#     rm -rf /var/lib/apt/lists/* && \
#     colcon build --symlink-install
