# Asset pipeline

## Directory contract

- `assets/source/blender/`: `.blend` files and Blender scripts.
- `assets/source/raster/`: `.kra`, `.xcf`, and source texture documents.
- `assets/source/vector/`: `.svg` source artwork and radar files.
- `assets/manifests/`: stable asset metadata and licensing.
- `assets/build/`: generated exports; ignored by Git.
- `assets/review/`: previews and human review output; ignored by Git.

## Asset IDs

Use lowercase ASCII IDs with one ID across source, exports, textures, collision, animation, map, path, and preview files. Record units, coordinate system, pivot, LOD, collision, material, target resource, source tool, license, and attribution.

## Approval gates

1. Source document opens and is reproducible.
2. Export script or job is deterministic.
3. Manifest and license data exist.
4. Preview is reviewed visually.
5. Runtime files pass MTA packaging and resource checks.
6. In-game appearance and performance are verified.
