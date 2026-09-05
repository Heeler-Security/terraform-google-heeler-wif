#!/usr/bin/env sh
set -eu

resource_count="$(awk '/^resource "google_project_service"/ { count++ } END { print count + 0 }' services.tf)"
if [ "$resource_count" -ne 11 ]; then
  echo "Expected exactly 11 google_project_service resources, found $resource_count." >&2
  exit 1
fi

actual_apis="$(mktemp)"
expected_apis="$(mktemp)"
trap 'rm -f "$actual_apis" "$expected_apis"' EXIT

sed -n 's/^[[:space:]]*service[[:space:]]*=[[:space:]]*"\([^"]*\.googleapis\.com\)"/\1/p' services.tf | sort >"$actual_apis"

printf '%s\n' \
  artifactregistry.googleapis.com \
  cloudresourcemanager.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  pubsub.googleapis.com \
  serviceusage.googleapis.com \
  sqladmin.googleapis.com \
  storage.googleapis.com \
  sts.googleapis.com >"$expected_apis"

if ! diff -u "$expected_apis" "$actual_apis"; then
  echo "services.tf does not declare the exact supported 11-API baseline." >&2
  exit 1
fi
