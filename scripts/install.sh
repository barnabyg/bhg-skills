#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [--target DIRECTORY]\n' "$0"
  printf 'Link this repository\047s skills into ~/.agents/skills by default.\n'
}

target_dir="${HOME}/.agents/skills"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      if [[ $# -lt 2 || -z "$2" ]]; then
        printf 'Error: --target requires a directory.\n' >&2
        exit 2
      fi
      target_dir="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Error: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
sources=()
for source in "$repo_root"/skills/*; do
  [[ -d "$source" && -f "$source/SKILL.md" ]] || continue
  sources+=("$source")
done
if [[ ${#sources[@]} -eq 0 ]]; then
  printf 'Error: no skill folders found in %s/skills.\n' "$repo_root" >&2
  exit 1
fi

mkdir -p -- "$target_dir"
target_dir="$(cd -- "$target_dir" && pwd -P)"

# Check every destination before creating links, so conflicts leave installs alone.
for source in "${sources[@]}"; do
  destination="$target_dir/${source##*/}"
  if [[ -e "$destination" || -L "$destination" ]]; then
    if [[ -L "$destination" && -d "$destination" ]] &&
       [[ "$(cd -- "$destination" && pwd -P)" == "$source" ]]; then
      continue
    fi
    printf 'Error: refusing to replace existing path: %s\n' "$destination" >&2
    exit 1
  fi
done

for source in "${sources[@]}"; do
  destination="$target_dir/${source##*/}"
  if [[ -L "$destination" ]]; then
    printf 'Already installed: %s\n' "$destination"
  else
    ln -s -n -- "$source" "$destination"
    printf 'Installed: %s -> %s\n' "$destination" "$source"
  fi
done
