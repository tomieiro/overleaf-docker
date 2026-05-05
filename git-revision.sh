#!/bin/sh

for gitDir in $(find "$PWD" -name .git); do
  repoDir=$(dirname "$gitDir")
  echo -n "${repoDir},"

  if git -C "$repoDir" rev-parse HEAD >/dev/null 2>&1; then
    git -C "$repoDir" rev-parse HEAD
    continue
  fi

  if [ -f "$gitDir" ]; then
    resolvedGitDir=$(sed -n 's/^gitdir: //p' "$gitDir")
    if [ -n "$resolvedGitDir" ] && [ -d "$repoDir/$resolvedGitDir" ]; then
      git --git-dir="$repoDir/$resolvedGitDir" rev-parse HEAD
      continue
    fi
  fi

  echo "unknown"
done
