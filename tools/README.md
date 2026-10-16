# Project tools

- `neon`: POSIX launcher (Linux/macOS) that invokes the Neon CLI via system Python 3.10+.
- `neon.cmd`: Windows launcher (for legacy use) invoking the project-local Windows Python runtime.
- `neon-cli/`: official portable Neon CLI package.
- `python/`: project-local Windows Python runtime used by `neon.cmd` (Windows only; not included on Linux builds).

Do not modify the portable CLI or generated Neon catalogue by hand. Update the package deliberately and rerun its self-test when changing tooling.
