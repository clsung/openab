FROM ghcr.io/openabdev/openab-native:beta

USER root
RUN groupadd -g 1000660000 sandbox 2>/dev/null || true && \
    usermod -u 1000660000 -g 1000660000 agent 2>/dev/null || true

USER agent
WORKDIR /home/agent
