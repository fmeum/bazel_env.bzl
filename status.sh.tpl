#!/usr/bin/env bash

set -euo pipefail

cd "$BUILD_WORKSPACE_DIRECTORY"

cat << 'EOF'

====== {{name}} ======

EOF

if [[ {{has_tools}} == True ]]; then

if type direnv >/dev/null 2>/dev/null; then
    echo "✅ direnv is installed"
else
    echo "❌ direnv is not installed. Please follow the instructions at https://direnv.net/docs/installation.html."
fi

if type {{unique_name_tool}} >/dev/null 2>/dev/null; then
    echo "✅ direnv added {{bin_dir}} to PATH"
else
    cat << 'EOF'
❌ {{name}}'s bin directory is not in PATH. Please follow these steps:

1. Enable direnv's shell hook as described in https://direnv.net/docs/hook.html.

2. Add the following snippet to a .envrc file next to your MODULE.bazel file:

watch_file {{bin_dir}}
PATH_add {{bin_dir}}
if [[ ! -d {{bin_dir}} ]]; then
  log_error "ERROR[bazel_env.bzl]: Run 'bazel run {{label}}' to regenerate {{bin_dir}}"
fi

3. Allowlist the file with 'direnv allow .envrc'.
EOF
    exit 1
fi

cleaned=0
for f in '{{bin_dir}}'/*;
do
  if basename "$f" | grep -q -v '{{tools_regex}}'; then
    rm -rf ./"$f"
    cleaned=1
  fi
done

if [[ $cleaned == 1 ]]; then
cat << 'EOF'
✅ Cleaned up stale tools
EOF
fi


cat << 'EOF'

Tools available in PATH:
{{tools}}

EOF
fi

if [[ {{has_toolchains}} == True ]]; then
cat << 'EOF'
Toolchains available at stable relative paths:
{{toolchains}}

EOF
fi
