§MBEL:5.0
# techContext — OutkastMP

[STACK]
@engine::MTA:SA Neon{Linux, range>=1.7.0<1.8.0}
@serverBinary::mta-server64{repoRoot}
@config::mods/deathmatch/mtaserver.conf
@resources::mods/deathmatch/resources/[custom]/+[ov-runtime]/
@lua::server|client|shared{declaredIn meta.xml}
@framework::OV-MTA{ov-sa repos¬DayZ}
@reference::districtMTA{gameplayDesignOnly}

[TOOLCHAIN]
@neonCLI::tools/neon{POSIX,systemPython3.10+}
@cliPackage::tools/neon-cli/
@catalogue::.neon-tooling/neon-api.json
@generated::.neon/{agent-context,api-index,project-api,artifacts}.json

[COMMANDS]
✓tools/neon check --json
✓tools/neon generate project --json
✓tools/neon context verify --json
✓tools/neon api search "<intent>" --json
✓tools/neon api get <NAME> --json
✓tools/neon project resolve --json
✓tools/neon scenario run --json{allowlistedStaticSteps+evidence}
✓tools/neon supervisor ...{boundedReadOnlyRuntimeObservation}
✓tools/neon resource start|stop|restart ...

[RUNTIME_EVIDENCE]
@logs::mods/deathmatch/logs/{server.log,scripts.log}
@rule::processStart≠gameplayWorks

[AGENT_INTERFACE]
@retrieval::NeonCLI+nativeFileRead/grep
@mcp::retired{2026-10-20,F-01obsolete}
@skills::.opencode/skills/{memory-octree,git-release,obsidian-skills/*}
@memory::memory-bank/+.serena/memories/+.sadie/{index+search}

[SECRETS]
@neverCommit{server-id.keys,databases,logs,backups,passwords,tokens}
@aclPrivileged{loadstring,fetchRemote,restartResource,ModifyOtherObjects,resourceControl,filesystem}
