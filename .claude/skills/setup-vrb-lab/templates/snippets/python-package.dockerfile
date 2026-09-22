# --- Install the project as a Python package -----------------------------------
# Use in PROJECT BUILD STEPS when the project was COPIED into the lab repo, or in
# EXTERNAL REPOSITORIES right after the clone when it was cloned. Either way the path
# is inside ${REPO_DIR} (${PROJECT_DIR} after the clone snippet), so the sources are
# visible in the file browser.
#
# Editable install: code changes in the mounted repo are live during local dev.
RUN python3 -m pip install --no-cache-dir -e ${REPO_DIR}/__PROJECT_NAME__
#
# Poetry project instead:
# RUN python3 -m pip install --no-cache-dir poetry && \
#     cd ${REPO_DIR}/__PROJECT_NAME__ && \
#     poetry config virtualenvs.create false && \
#     poetry install --no-interaction
#
# Conda environment.yml instead (mamba is in the intel4coro images):
# RUN mamba env update -n base -f ${REPO_DIR}/__PROJECT_NAME__/environment.yml && mamba clean -afy
