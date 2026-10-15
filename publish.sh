#!/bin/sh -eu
# Publie une box sur GitHub Releases et l'ajoute au catalogue Vagrant docs/debian-<majeure>.json
# Servi par GitHub Pages (Content-Type application/json compatible Vagrant).
#
#   ./publish.sh build/debian-13-arm64-13.7.0.virtualbox.box
#
# Mise à jour du catalogue.

REPO="${REPO:?REPO=propriétaire/dépôt GitHub}"
NAMESPACE="${NAMESPACE:-harry-lleen}"

box="$1"
file=$(basename "$box")
version=$(echo "$file" | sed -E 's/^debian-[0-9]+-arm64-(.+)\.virtualbox\.box$/\1/')
major=${version%%.*}
tag="debian-$major-v$version"
sha=$(shasum -a 256 "$box" | cut -d' ' -f1)

gh release view "$tag" --repo "$REPO" >/dev/null 2>&1 ||
  gh release create "$tag" --repo "$REPO" --title "Debian $version (arm64, VirtualBox)" --notes "SHA256 : \`$sha\`"
gh release upload "$tag" "$box" --repo "$REPO" --clobber

mkdir -p docs
python3 - "docs/debian-$major.json" "$NAMESPACE/debian-$major" "$version" \
  "https://github.com/$REPO/releases/download/$tag/$file" "$sha" <<'EOF'
import json, os, sys
path, name, version, url, sha = sys.argv[1:]
cat = json.load(open(path)) if os.path.exists(path) else {
    "name": name, "description": f"Debian {version.split('.')[0]} arm64 pour VirtualBox (Apple Silicon)", "versions": []}
cat["versions"] = [v for v in cat["versions"] if v["version"] != version] + [{
    "version": version, "status": "active",
    "providers": [{"name": "virtualbox", "architecture": "arm64", "default_architecture": True,
                   "url": url, "checksum_type": "sha256", "checksum": sha}]}]
cat["versions"].sort(key=lambda v: [int(x) for x in v["version"].split(".")], reverse=True)
json.dump(cat, open(path, "w"), indent=2)
EOF
echo "OK : docs/debian-$major.json mis à jour"
echo "TODO : commit + push"
