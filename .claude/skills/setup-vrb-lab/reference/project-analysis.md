# Analyzing the project to integrate

Goal: find out what the project is, what it needs to run, and what a visitor should open
first. Report findings in plain words and mark everything you are unsure about as
"unknown" so the user can fill it in.

## 1. Project type

Look for these markers (top level first, then one or two levels down):

| Marker | Meaning |
|--------|---------|
| `pyproject.toml`, `setup.py`, `setup.cfg` | Installable Python package → `pip install -e .` |
| `requirements.txt` | Plain pip dependencies → merge into the lab `requirements.txt` |
| `environment.yml` | Conda environment → translate to pip where possible; the base image has mamba, so `mamba env update -n base -f environment.yml` is an option |
| `poetry.lock` | Poetry project → `pip install poetry && poetry config virtualenvs.create false && poetry install` |
| `package.xml` | ROS package. Read `<buildtool_depend>` / `<export><build_type>`: `ament_cmake` or `ament_python` → ROS 2; `catkin` → ROS 1 |
| `CMakeLists.txt` next to `package.xml` | ROS C++ package; needs colcon/catkin build and compilers |
| `*.ipynb` | Notebooks. Candidates for the default notebook |
| `Dockerfile`, `docker-compose.yml` | The project already knows its system deps. Read them and reuse apt/pip lines; do not use their base image blindly |
| `.gitmodules` | Submodules. Every URL must be HTTPS for Binder; check |
| `*.urdf`, `*.xacro`, `*.sdf`, `*.stl`, `*.dae` | Robot models. Often needs `xacro`, `robot_state_publisher`, RViz |
| `*.xml` with `<mujoco>` | MuJoCo models → `mujoco` pip package, works with VNC desktop |
| `README*` | Install instructions. Extract apt/pip/ROS commands verbatim and show them to the user |

If nothing matches, ask the user what the project is and how they normally run it.

## 2. ROS distribution

Evidence, strongest first:

1. Explicit mention in README or CI config (`ros-jazzy-*`, `ros-humble-*`, `ros-noetic-*`, `ROS_DISTRO=`).
2. `package.xml` build type (see table) tells ROS 1 vs ROS 2, not the distribution.
3. Python code importing `rclpy` → ROS 2; `rospy` → ROS 1.
4. `colcon` in docs → ROS 2 (usually); `catkin_make`/`catkin build` → ROS 1.

If only "ROS 2" is known, suggest Jazzy (default image) and ask. Do not assume a
distribution from the year of the last commit.

## 3. Dependencies

- Python: collect from every marker above. Note pinned versions. Flag packages that need
  compilation (they may need `build-essential`, `python3-dev`, or a `-dev` apt package).
- System: apt lines from README/Dockerfile; `<depend>` entries in `package.xml`
  (rosdep can resolve them: `rosdep install --from-paths src -y`).
- External repositories the project clones or expects (other ROS packages, model zoos,
  datasets). These belong *before* the `COPY` line in the Dockerfile for caching.
- Large downloads (models, datasets): ask whether they must be in the image or fetched at
  runtime.
- Hardware: real-robot drivers, cameras, CUDA-only code. Binder has no hardware and no
  GPU. Warn the user and ask what to disable or stub.

## 4. Entry point for visitors

Pick the best "open this first" candidate:

1. A notebook named like `demo`, `tutorial`, `intro`, `getting_started`, `index`, `01_*`.
2. The notebook referenced first in the README.
3. Any notebook, if there is only one.
4. Otherwise propose creating `notebooks/welcome.ipynb` from the template that imports
   the project and prints a hello, so the lab is verifiable on first launch.

Note whether the candidate needs a running ROS node, a display, or hardware before its
first cell works. Mention it in the summary.

## 5. Things Binder cannot do

State these if relevant so the user is not surprised:

- No GPU, limited RAM (a few GB) and CPU; heavy simulation may be slow
- No persistent storage: everything the visitor changes is gone when the session ends
- No inbound network ports; web UIs must go through Jupyter's proxy
- Sessions time out after inactivity
- SSH clone URLs and private repos do not work
