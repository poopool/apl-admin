#! /bin/bash

#Mapping build ARGs
DB_UTILS_TAG=${DB_UTILS_TAG}
APL_COMMON_TAG=${APL_COMMON_TAG}
APL_ADMIN_TAG=${APL_ADMIN_TAG}
BB_API_KEY=${BB_API_KEY}
SSH_PASSWD=${SSH_PASSWD}

echo "APL_COMMON_TAG= $APL_COMMON_TAG"
echo "DB_UTILS_TAG= $DB_UTILS_TAG"

#Installing some tools
apt update \
    && apt install -y wget bsdtar openssl libc-dev gcc netcat bsdtar openssh-server \
    && apt -y autoremove \
    && rm -rf /var/lib/apt/lists/*

#Setting up SSH server
mkdir /var/run/sshd
echo "root:$SSH_PASSWD" | chpasswd
sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#Installing apl-common and db-utils
pip install https://applariat:$BB_API_KEY@bitbucket.org/applariat/apl-db-utils/get/${DB_UTILS_TAG}.zip
pip install --upgrade https://applariat:$BB_API_KEY@bitbucket.org/applariat/apl-common/get/${APL_COMMON_TAG}.zip

#pulling and installing apl-admin
wget https://applariat:$BB_API_KEY@bitbucket.org/applariat/apl-admin/get/${APL_ADMIN_TAG}.zip
mkdir -p /usr/src/app
bsdtar -xf $APL_ADMIN_TAG -s'|[^/]*/||' -C /usr/src/app
cd /usr/src/app/
ls -alh
pip install .
