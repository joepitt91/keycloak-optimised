<!--
SPDX-FileCopyrightText: 2025 Joe Pitt

SPDX-License-Identifier: GPL-3.0-only
-->
# Keycloak (Optimised)

Pre-optimised Keycloak container image.

Enables and optimises for:

* Postgres backend
* Persistent User Sessions
* Recovery Codes
* Health Checks
* Metrics
* Proxy Address Forwarding

Installs `curl` for a basic health check using the `/health/ready` endpoint.
