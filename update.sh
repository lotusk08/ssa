#!/usr/bin/env bash
#
# Re-vendor the static assets in this repository.
#
# Adapted from cotes2020/chirpy-static-assets. Differences that matter here:
#
#   * curl instead of wget, and BSD-safe `sed -i ''`, so it runs on macOS.
#   * This fork renames upstream's directories and files (loading-attribute-
#     polyfill -> polyfill/, simple-jekyll-search -> search/), so each package
#     carries an explicit source -> destination map rather than assuming the
#     npm layout.
#   * Font Awesome is not vendored. This fork serves icons from a single
#     sprite in the parent repo (assets/icons.svg).
#   * Adds chart.js and @waline/client, which upstream does not carry.
#
# package.json is the single source of truth for versions. Bump it (by hand or
# with `ncu -u`), then run this. Re-running with unchanged versions is a no-op
# in effect: the same bytes are downloaded again.
#
# Usage: ./update.sh [-h] [PACKAGE]
#   PACKAGE   only update this one (e.g. mermaid, tocbot, chart.js)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_JSON="$SCRIPT_DIR/package.json"
README="$SCRIPT_DIR/README.md"

# Read the pinned version for a package, stripping any ^ ~ >= prefix.
pkg_version() {
  node -e "
    const d = require('$PACKAGE_JSON').dependencies || {};
    const v = d['$1'];
    if (!v) { process.exit(1); }
    console.log(v.replace(/^[^0-9]*/, ''));
  "
}

# Update a row of the Versions table in README.md. Keyword is a sed pattern.
readme_set_version() {
  local keyword="$1" version="$2"
  [[ -f "$README" ]] || return 0
  sed -i '' "/${keyword}/s/\`[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\`/\`${version}\`/" "$README"
}

# fetch <url> <destination>
fetch() {
  local url="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if ! curl -sSfL --retry 3 --max-time 120 -o "$dest" "$url"; then
    echo "Error: failed to download $url" >&2
    exit 1
  fi
  echo "  $(basename "$dest")  <-  $url"
}

# vendor <npm-name> <readme-keyword> <dest-dir> <src-path:dest-name>...
#
# src-path is relative to the package root on jsDelivr; dest-name is the file
# name this fork uses, which is often not the upstream one.
vendor() {
  local pkg="$1" keyword="$2" dir="$3"
  shift 3

  local version
  if ! version=$(pkg_version "$pkg"); then
    echo "Error: '$pkg' is not in package.json dependencies" >&2
    exit 1
  fi

  echo ""
  echo "$pkg -> v${version}"

  local pair src name
  for pair in "$@"; do
    src="${pair%%:*}"
    name="${pair#*:}"
    fetch "https://cdn.jsdelivr.net/npm/${pkg}@${version}/${src}" "$SCRIPT_DIR/${dir}/${name}"
  done

  readme_set_version "$keyword" "$version"
}

# MathJax is vendored from node_modules rather than file-by-file, because it is
# a large tree of loadable components rather than a handful of bundles.
#
# NOTE: MathJax 4 moved its fonts into a separate package
# (@mathjax/mathjax-newcm-font), which lands outside node_modules/mathjax and
# would therefore NOT be copied by this function. Bumping to 4.x needs the font
# package vendored too, plus an output.font path in the site's MathJax config,
# or self-hosted math renders without glyphs.
update_mathjax() {
  local version
  version=$(pkg_version "mathjax")

  echo ""
  echo "mathjax -> v${version}"

  local major="${version%%.*}"
  if [[ "$major" -ge 4 ]]; then
    echo "Error: MathJax >= 4 also needs @mathjax/mathjax-newcm-font vendored." >&2
    echo "       See the note above update_mathjax() before bumping." >&2
    exit 1
  fi

  local pkg_root="$SCRIPT_DIR/node_modules/mathjax"
  local dest="$SCRIPT_DIR/mathjax"

  if [[ ! -d "$pkg_root" ]]; then
    echo "Error: $pkg_root not found. Run 'npm install' in $SCRIPT_DIR first." >&2
    exit 1
  fi

  # MathJax 3 nests the browser bundles under es5/, but this fork serves them
  # flat: the site requests /assets/lib/mathjax/tex-chtml.js, not .../es5/... .
  # Copy the contents of es5/ up to the destination root.
  local src="$pkg_root/es5"
  if [[ ! -d "$src" ]]; then
    echo "Error: $src not found; the package layout has changed." >&2
    exit 1
  fi

  rm -rf "$dest"
  mkdir -p "$dest"
  cp -r "$src"/. "$dest"/
  cp "$pkg_root/LICENSE" "$dest"/LICENSE

  # Node-only entry points and docs have no place in a web-served tree.
  rm -f "$dest"/node-main.js "$dest"/node-main.mjs "$dest"/node-main.cjs \
    "$dest"/node-main-setup.cjs "$dest"/require.mjs \
    "$dest"/CONTRIBUTING.md "$dest"/README.md "$dest"/package.json

  echo "  vendored $(find "$dest" -type f | wc -l | tr -d ' ') files"
  readme_set_version "MathJax" "$version"
}

update_dayjs() {
  vendor dayjs 'Day\.js' dayjs \
    "dayjs.min.js:dayjs.min.js" \
    "locale/en.js:locale/en.js" \
    "plugin/localizedFormat.js:plugin/localizedFormat.js" \
    "plugin/relativeTime.js:plugin/relativeTime.js"
}

update_clipboard() {
  vendor clipboard 'Clipboard' clipboard \
    "dist/clipboard.min.js:clipboard.min.js"
}

update_mermaid() {
  vendor mermaid 'Mermaid' mermaid \
    "dist/mermaid.min.js:mermaid.min.js"
}

update_glightbox() {
  vendor glightbox 'GLightbox' glightbox \
    "dist/js/glightbox.min.js:glightbox.min.js" \
    "dist/css/glightbox.min.css:glightbox.min.css"
}

update_tocbot() {
  vendor tocbot 'Tocbot' tocbot \
    "dist/tocbot.min.js:tocbot.min.js" \
    "dist/tocbot.min.css:tocbot.min.css"
}

# Upstream keeps this in loading-attribute-polyfill/; this fork shortens it.
update_polyfill() {
  vendor loading-attribute-polyfill 'Loading-attribute-polyfill' polyfill \
    "dist/loading-attribute-polyfill.min.css:polyfill.min.css" \
    "dist/loading-attribute-polyfill.umd.min.js:polyfill.umd.min.js"
}

# Upstream keeps this in simple-jekyll-search/; this fork shortens it.
update_search() {
  vendor simple-jekyll-search 'Simple-Jekyll-Search' search \
    "dest/simple-jekyll-search.min.js:search.min.js"
}

update_chartjs() {
  vendor chart.js 'Chart\.js' chartjs \
    "dist/chart.umd.min.js:chart.umd.min.js"
}

update_waline() {
  vendor @waline/client 'Waline Client' waline \
    "dist/waline.js:waline.js" \
    "dist/waline.css:waline.css"
}

main() {
  local target="${1:-}"

  case "$target" in
  -h | --help)
    sed -n '3,22p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  esac

  local -a all=(
    dayjs clipboard mermaid glightbox tocbot
    polyfill search chartjs waline mathjax
  )

  if [[ -n "$target" ]]; then
    local found=false item
    for item in "${all[@]}"; do
      [[ "$item" == "$target" ]] && found=true && break
    done
    if [[ "$found" == false ]]; then
      echo "Error: unknown package '$target'" >&2
      echo "Available: ${all[*]}" >&2
      exit 1
    fi
    "update_${target}"
  else
    local item
    for item in "${all[@]}"; do
      "update_${item}"
    done
  fi

  echo ""
  echo "Done."
}

main "$@"
