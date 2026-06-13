#!/usr/bin/env bash
set -euo pipefail
find experiments deploy infra -name '*.yaml' -o -name '*.yml' | sort
