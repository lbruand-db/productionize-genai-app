#!/usr/bin/env python3
"""Download Databricks brand icons for use in presentations.

Usage:
  python3 scripts/download-brand-icon.py --list                  # list all available icons
  python3 scripts/download-brand-icon.py --search "predict"      # search by keyword
  python3 scripts/download-brand-icon.py predict analytics       # download specific icons

Icons are saved as SVG to assets/dbrx-icon-<name>.svg.

Sources (checked in order):
  1. Local drawio-diagram skill cache (61 SVGs from Brandfolder, no auth needed)
  2. Brandfolder API (if BRANDFOLDER_API_KEY is set — fetches from Architecture Icons collection)
"""
import argparse, glob, json, os, re, sys, urllib.parse, urllib.request
from pathlib import Path

ASSETS_DIR = Path(__file__).parent.parent / "assets"

# Brandfolder API settings (optional, for fresh fetches)
API_BASE = "https://brandfolder.com/api/v4"
COLLECTION_ID = "x44sjvk8rscxcx2gxktsxbtj"
VARIANT_PREFERENCE = ["orange", "navy", "white"]

# Drawio skill icon cache (primary source — already fetched SVGs as data URIs)
DRAWIO_CACHE_GLOB = os.path.expanduser(
    "~/.claude/plugins/cache/fe-vibe/fe-specialized-agents/*/skills/drawio-diagram/icons/databricks_icons.json")


def load_drawio_cache():
    """Load Databricks icons from the drawio-diagram skill cache."""
    paths = glob.glob(DRAWIO_CACHE_GLOB)
    if not paths:
        return {}
    with open(paths[0]) as f:
        data = json.load(f)
    # Keep only brandfolder-sourced SVG icons
    icons = {}
    for key, entry in data.items():
        if isinstance(entry, dict) and entry.get("source") == "brandfolder":
            icons[key] = entry
    return icons


def decode_data_uri(data_uri):
    """Decode a data:image/svg+xml,... URI back to SVG bytes."""
    if data_uri.startswith("data:image/svg+xml,"):
        encoded = data_uri[len("data:image/svg+xml,"):]
        return urllib.parse.unquote(encoded).encode("utf-8")
    elif data_uri.startswith("data:image/svg+xml;base64,"):
        import base64
        encoded = data_uri[len("data:image/svg+xml;base64,"):]
        return base64.b64decode(encoded)
    return None


def api_get(endpoint, api_key, params=None):
    url = f"{API_BASE}{endpoint}"
    if params:
        query = "&".join(f"{k}={v}" for k, v in params.items())
        url = f"{url}?{query}"
    req = urllib.request.Request(url, headers={
        "Authorization": f"Bearer {api_key}",
        "Accept": "application/json",
    })
    resp = urllib.request.urlopen(req, timeout=30)
    return json.loads(resp.read().decode("utf-8"))


def normalize_key(name):
    key = name.lower()
    for prefix in ("primary icon ", "product icon ", "customer logo "):
        if key.startswith(prefix):
            key = key[len(prefix):]
    return re.sub(r"[^a-z0-9]+", "_", key.strip()).strip("_")


def pick_best_attachment(att_rels, included):
    att_ids = {r["id"] for r in att_rels.get("data", [])}
    candidates = []
    for inc in included:
        if inc.get("type") == "attachments" and inc["id"] in att_ids:
            attrs = inc.get("attributes", {})
            url, ext, fn = attrs.get("url", ""), attrs.get("extension", ""), attrs.get("filename", "")
            if ext in ("svg", "png") and url:
                candidates.append({"url": url, "filename": fn, "ext": ext})
    if not candidates:
        return None
    def sort_key(c):
        ext_score = 0 if c["ext"] == "svg" else 1
        variant_score = len(VARIANT_PREFERENCE)
        fn = c["filename"].lower()
        for i, v in enumerate(VARIANT_PREFERENCE):
            if v in fn:
                variant_score = i
                break
        return (ext_score, variant_score)
    candidates.sort(key=sort_key)
    return candidates[0]


def fetch_from_brandfolder(api_key):
    """Fetch icon index from Brandfolder API."""
    icons = {}
    page, total_pages = 1, None
    print("Fetching from Brandfolder API...", file=sys.stderr)
    while total_pages is None or page <= total_pages:
        print(f"  Page {page}/{total_pages or '?'}...", file=sys.stderr)
        data = api_get(f"/collections/{COLLECTION_ID}/assets", api_key,
                       params={"include": "attachments", "per": "200", "page": str(page)})
        total_pages = data.get("meta", {}).get("total_pages", 1)
        included = data.get("included", [])
        for asset in data.get("data", []):
            name = asset["attributes"]["name"]
            if name.startswith("Customer Logo"):
                continue
            key = normalize_key(name)
            att_rels = asset.get("relationships", {}).get("attachments", {})
            best = pick_best_attachment(att_rels, included)
            if best:
                icons[key] = {"name": name, "url": best["url"], "filename": best["filename"], "ext": best["ext"]}
        page += 1
    return icons


def load_index(api_key=None, force_refresh=False):
    """Load icons from drawio cache, optionally supplemented by Brandfolder API."""
    if force_refresh and api_key:
        return fetch_from_brandfolder(api_key)

    cache = load_drawio_cache()
    if cache:
        # Convert to simple format
        icons = {}
        for key, entry in cache.items():
            icons[key] = {
                "name": entry.get("name", key),
                "filename": entry.get("filename", f"{key}.svg"),
                "source": "cache",
                "data_uri": entry.get("data_uri", ""),
            }
        return icons

    # No cache — try Brandfolder API
    if api_key:
        return fetch_from_brandfolder(api_key)

    print("No icon cache found and no BRANDFOLDER_API_KEY set.", file=sys.stderr)
    print("Install the drawio-diagram vibe skill, or set BRANDFOLDER_API_KEY.", file=sys.stderr)
    sys.exit(1)


def download_icon(slug, icon_info):
    """Save an icon to assets/."""
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    out_path = ASSETS_DIR / f"dbrx-icon-{slug.replace('_', '-')}.svg"
    if out_path.exists():
        print(f"  Already exists: {out_path}")
        return out_path

    if "data_uri" in icon_info and icon_info["data_uri"]:
        # Decode from data URI (cache path)
        svg_bytes = decode_data_uri(icon_info["data_uri"])
        if svg_bytes:
            with open(out_path, "wb") as f:
                f.write(svg_bytes)
            print(f"  Saved: {out_path} ({len(svg_bytes)} bytes)")
            return out_path

    if "url" in icon_info:
        # Download from Brandfolder URL
        req = urllib.request.Request(icon_info["url"], headers={"User-Agent": "Mozilla/5.0"})
        resp = urllib.request.urlopen(req, timeout=30)
        data = resp.read()
        ext = icon_info.get("ext", "svg")
        out_path = ASSETS_DIR / f"dbrx-icon-{slug.replace('_', '-')}.{ext}"
        with open(out_path, "wb") as f:
            f.write(data)
        print(f"  Downloaded: {out_path} ({len(data)} bytes)")
        return out_path

    print(f"  Error: no source for {slug}", file=sys.stderr)
    return None


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("icons", nargs="*", help="Icon slugs to download")
    parser.add_argument("--list", action="store_true", help="List all available icons")
    parser.add_argument("--search", type=str, help="Search icons by keyword")
    parser.add_argument("--api-key", type=str, help="Brandfolder API key (optional)")
    parser.add_argument("--refresh", action="store_true", help="Force fetch from Brandfolder API (needs API key)")
    args = parser.parse_args()

    api_key = args.api_key or os.environ.get("BRANDFOLDER_API_KEY")
    if args.refresh and not api_key:
        print("--refresh requires BRANDFOLDER_API_KEY or --api-key", file=sys.stderr)
        sys.exit(1)
    mapping = load_index(api_key=api_key, force_refresh=args.refresh)

    if args.list:
        for slug in sorted(mapping):
            info = mapping[slug]
            print(f"  {slug:45s} {info.get('filename', slug)}")
        print(f"\nTotal: {len(mapping)} icons")
        return

    if args.search:
        q = args.search.lower()
        matches = [(s, i) for s, i in mapping.items()
                    if q in s or q in i.get("name", "").lower() or q in i.get("filename", "").lower()]
        if not matches:
            print(f"No icons matching '{args.search}'")
            return
        for slug, info in sorted(matches):
            print(f"  {slug:45s} {info.get('filename', slug)}")
        print(f"\n{len(matches)} matches. Download with: python3 scripts/download-brand-icon.py {matches[0][0]}")
        return

    if not args.icons:
        parser.print_help()
        return

    for slug in args.icons:
        if slug not in mapping:
            candidates = [s for s in mapping if slug in s]
            if candidates:
                print(f"'{slug}' not found. Did you mean: {', '.join(candidates[:5])}?")
            else:
                print(f"'{slug}' not found. Use --list or --search to find icons.")
            continue
        print(f"Downloading {slug} ({mapping[slug].get('filename', slug)})...")
        download_icon(slug, mapping[slug])


if __name__ == "__main__":
    main()
