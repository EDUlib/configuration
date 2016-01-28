#!/usr/bin/env bash

OPENEDX_ROOT="/edx"
TARGET="edulib-dogwood-rc"

echo "Avant installation de la derniere partie"

if [[ -f /edx/app/edx_ansible/server-vars.yml ]]; then
  SERVER_VARS="--extra-vars=\"@${OPENEDX_ROOT}/app/edx_ansible/server-vars.yml\""
fi

cd /var/tmp/configuration/playbooks
echo "edx_platform_repo: 'https://github.com/EDUlib/edx-platform.git'" > vars.yml
echo "edx_platform_version: $TARGET" >> vars.yml
echo "ora2_source_repo: 'https://github.com/EDUlib/edx-ora2.git'" >> vars.yml
echo "ora2_version: $TARGET" >> vars.yml
echo "CERTS_REPO: 'https://github.com/EDUlib/edx-certificates.git'" >> vars.yml
echo "certs_version: $TARGET" >> vars.yml
echo "forum_source_repo: 'https://github.com/EDUlib/cs_comments_service.git'" >> vars.yml
echo "forum_version: $TARGET" >> vars.yml
echo "xqueue_source_repo: 'https://github.com/EDUlib/xqueue.git'" >> vars.yml
echo "xqueue_version: $TARGET" >> vars.yml
sudo ansible-playbook \
    --inventory-file=localhost, \
    --connection=local \
    --extra-vars="@vars.yml" \
    $SERVER_VARS \
    vagrant-fullstack.yml

echo "On devrait pouvoir rebooter"
