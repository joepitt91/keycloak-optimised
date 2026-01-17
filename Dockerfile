# SPDX-FileCopyrightText: 2025-2026 Joe Pitt
#
# SPDX-License-Identifier: GPL-3.0-only
ARG KEYCLOAK_VERSION=latest

FROM redhat/ubi9:latest AS curl
RUN mkdir -p /mnt/rootfs
RUN dnf install --installroot /mnt/rootfs curl --releasever 9 --setopt install_weak_deps=false \
        --nodocs -y && \
    dnf --installroot /mnt/rootfs clean all && \
    rpm --root /mnt/rootfs -e --nodeps setup


FROM keycloak/keycloak:${KEYCLOAK_VERSION} AS build
ENV KC_DB=postgres \
    KC_FEATURES=persistent-user-sessions,recovery-codes \
    KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true \
    PROXY_ADDRESS_FORWARDING=true
WORKDIR /opt/keycloak
RUN /opt/keycloak/bin/kc.sh build

FROM keycloak/keycloak:${KEYCLOAK_VERSION} AS final
COPY --from=curl /mnt/rootfs /
COPY --from=build /opt/keycloak/ /opt/keycloak/
ENV KC_DB=postgres \
    KC_HOSTNAME_STRICT_BACKCHANNEL=true \
    KC_HTTP_ENABLED=true \
    KC_PROXY_HEADERS=xforwarded \
    KC_PROXY_TRUSTED_ADDRESSES=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16 \
    KC_PROXY=edge \
    PROXY_ADDRESS_FORWARDING=true
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized"]
HEALTHCHECK CMD curl --head -fsS http://127.0.0.1:9000/health/ready
