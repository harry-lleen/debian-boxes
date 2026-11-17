#!/bin/sh -eu
# Publie une box sur GitHub Releases et l'ajoute au catalogue docs/<box>.json (GitHub Pages).
#   ./publish.sh build/debian-13-arm64-13.7.0.virtualbox.box   (ou build/kali-headless-arm64-2026.3.virtualbox.box)
REPO=harry-lleen/debian-boxes

box="$1"
file=$(basename "$box")
base=${file%.virtualbox.box}
version=${base##*-}
name=${base%-arm64-*}
tag="$name-v$version"
sha=$(shasum -a 256 "$box" | cut -d' ' -f1)

gh release view "$tag" --repo "$REPO" >/dev/null 2>&1 ||
  gh release create "$tag" --repo "$REPO" --title "$name $version (arm64, VirtualBox)" --notes "SHA256 : \`$sha\`"
gh release upload "$tag" "$box" --repo "$REPO" --clobber

mkdir -p docs
python3 - "docs/$name.json" "harry-lleen/$name" "$version" \
  "https://github.com/$REPO/releases/download/$tag/$file" "$sha" <<'EOF'
import json, os, sys
path, name, version, url, sha = sys.argv[1:]
cat = json.load(open(path)) if os.path.exists(path) else {
    "name": name, "description": f"{name.split('/')[1]} arm64 pour VirtualBox (Apple Silicon)", "versions": []}
cat["versions"] = [v for v in cat["versions"] if v["version"] != version] + [{
    "version": version, "status": "active",
    "providers": [{"name": "virtualbox", "architecture": "arm64", "default_architecture": True,
                   "url": url, "checksum_type": "sha256", "checksum": sha}]}]
cat["versions"].sort(key=lambda v: [int(x) for x in v["version"].split(".")], reverse=True)
json.dump(cat, open(path, "w"), indent=2)
EOF
echo "OK : docs/$name.json mis à jour"
echo "TODO : commit + push"
