# --- Build a ROS 1 (catkin) workspace ---------------------------------------------
# Requires a ROS 1 base image, see ros1-noetic-base.dockerfile.
# Variant A (cached): clone + build before COPY. The workspace lives INSIDE ${REPO_DIR}
# so the visitor can see it in the file browser; requires ENV REPO_DIR further up.
# COPY merges into ${REPO_DIR} and does not delete what this block created.
ENV CATKIN_WS=${REPO_DIR}/catkin_ws
RUN mkdir -p ${CATKIN_WS}/src && \
    git clone --depth=1 --branch __BRANCH__ __PROJECT_URL__ ${CATKIN_WS}/src/__PROJECT_NAME__ && \
    cd ${CATKIN_WS} && \
    . /opt/ros/${ROS_DISTRO}/setup.sh && \
    (rosdep init >/dev/null 2>&1 || true) && rosdep update && \
    apt-get update && rosdep install --from-paths src --ignore-src -y && \
    rm -rf /var/lib/apt/lists/* && \
    catkin_make
# binder/entrypoint.sh already sources ${REPO_DIR}/catkin_ws/devel/setup.bash; nothing to add.
# Note: a local `docker compose` run mounts ../ over /home/repo and hides devel/.

# Variant B (rebuilds on every push): project COPIED into the repo under catkin_ws/src.
# RUN cd ${REPO_DIR}/catkin_ws && \
#     . /opt/ros/${ROS_DISTRO}/setup.sh && \
#     (rosdep init >/dev/null 2>&1 || true) && rosdep update && \
#     apt-get update && rosdep install --from-paths src --ignore-src -y && \
#     rm -rf /var/lib/apt/lists/* && \
#     catkin_make
