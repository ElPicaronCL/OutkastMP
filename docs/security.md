# Security and release contract

- Keep `server-id.keys`, databases, logs, backups, passwords, tokens, and private endpoints out of Git.
- Review every ACL request. Treat `loadstring`, `fetchRemote`, resource control, filesystem access, and dynamic code as privileged.
- Validate all client-triggered events and never trust client element data for persistent state.
- Record licenses and attribution for OV libraries, models, textures, sounds, maps, fonts, and generated content.
- Package only intended runtime files. Do not ship source documents, secrets, test fixtures, or development commands.
- Perform a clean-server startup and focused gameplay test before a closed test release.
