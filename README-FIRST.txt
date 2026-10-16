MTA:SA Neon Linux server

1. Edit mods/deathmatch/mtaserver.conf.
2. Extract MTA-Neon-Linux-Server-x64.tar.gz here if mta-server64 is missing
   (the Windows build MTA Server64.exe and x64/*.dll must be removed).
3. Start mta-server64 from this directory (chmod +x if needed).
4. Allow the configured UDP game port and TCP HTTP port through the firewall.

Keep this server on the same Neon build as clients that use Neon-specific
network features. Documentation: https://mtasa-neon-wiki.vercel.app/neon/download
