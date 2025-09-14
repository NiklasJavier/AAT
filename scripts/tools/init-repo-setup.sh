#!/bin/bash

AAT_HOME="/opt/AAT"
SCRIPTS_DIR="${AAT_HOME}/scripts"
TOOLS_DIR="${SCRIPTS_DIR}/tools"

echo "alias aat='bash ${TOOLS_DIR}/auto_update_repo.sh && cd ${SCRIPTS_DIR}'" >> ~/.bashrc
source ~/.bashrc

bash "${TOOLS_DIR}/transfer-data.sh"

if ! crontab -l 2>/dev/null | grep -q "${TOOLS_DIR}/auto_update_repo.sh"; then
  (crontab -l 2>/dev/null; echo "*/5 * * * * /bin/bash ${TOOLS_DIR}/auto_update_repo.sh") | crontab -
fi
