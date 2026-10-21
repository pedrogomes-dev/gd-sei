#!/usr/bin/env bash
set -euo pipefail

project="${1:?Informe backend ou frontend}"
case "$project" in
  backend|frontend) ;;
  *) echo "Projeto inválido: $project" >&2; exit 1 ;;
esac
cd "$(git rev-parse --show-toplevel)"

# PR: base do PR; push: revisão anterior. Execução manual: último commit.
base="${FORMAT_BASE:-HEAD^}"
if [[ "$base" =~ ^0+$ ]]; then
  base="$(git hash-object -t tree /dev/null)"
fi
# Arquivo temporário permite propagar erros de git diff (sem mascarar a falha).
changed="$(mktemp)"
trap 'rm -f "$changed"' EXIT
git diff --name-only --diff-filter=ACMR -z "$base" HEAD -- \
  "$project/**/*.dart" "$project/*.dart" \
  ':!backend/vendor/**' > "$changed"
mapfile -d '' -t files < "$changed"
if (( ${#files[@]} == 0 )); then
  echo "Nenhum arquivo Dart alterado em $project."
  exit 0
fi
dart format --output=none --set-exit-if-changed "${files[@]}"
