FROM python:2.7

ARG artifact_root="."

COPY $artifact_root/build.sh /build.sh
COPY $artifact_root/entrypoint.sh /entrypoint.sh
COPY pycharm_helpers/ /root/.pycharm_helpers

RUN chmod +x /build.sh /entrypoint.sh && /build.sh

WORKDIR /usr/src/app

ENTRYPOINT ["/entrypoint.sh"]