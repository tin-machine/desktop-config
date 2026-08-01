#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
package_dir="${script_dir}/kwin-script"
plugin_id="desktop-config-window-actions"

if kpackagetool6 --type=KWin/Script --upgrade "${package_dir}"; then
    printf 'updated %s\n' "${plugin_id}"
else
    kpackagetool6 --type=KWin/Script --install "${package_dir}"
    printf 'installed %s\n' "${plugin_id}"
fi

kwriteconfig6 \
    --file kwinrc \
    --group Plugins \
    --key "${plugin_id}Enabled" \
    true

if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure
elif command -v qdbus >/dev/null 2>&1; then
    qdbus org.kde.KWin /KWin reconfigure
else
    printf 'warning: qdbus6/qdbus not found; re-login or enable the script manually\n' >&2
fi
