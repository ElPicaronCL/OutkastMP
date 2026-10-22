§MBEL:5.0
# activeContext — OutkastMP

[FOCUS]
@task::harnessConsolidation✓{2026-10-20}
>imported::friendHarness{MVL-clone}→adapted::OutkastMP
>retired::MCP{F-01obsolete,removed mcp-mta-tools/+.vscode/mcp.json}
✓memory-octree::OutkastMPlayers{contract+.neon+docs+CLI+git+runtime+refs}
✓memory-bank::reinitialized{thisfile}
✓.serena::reinitialized{4memories}
✓.sadie::repointed{docs/ vault+OutkastMP categories}
✓.harness-memory::wiped{REdumps removed}
✓pruned::skills{mvl-re,token-efficiency,hybrid-re-setup}+commands{deploy}

[DECISIONS]
@retrievalAuthority::NeonCLI>docs{always}
@mcp::revisitOnlyIf{secondFrontend|CLIunexpressibleNeed}
@districtMTA::readOnlyReference{¬import}
@harness-memory::keepTooling{npx harness-memory v0.5.1}+emptyDB

[BLOCKERS]
!F-02::CIbroken{rootnpm ci¬package.json,branch main≠master}
!F-03::OVruntimeACL{loadstring+fetchRemotedenied, scene.lua:37nilCall}
?F-04::ov-runtime¬registered in neon.project.json
?F-06::ov-core¬exports
?F-07::noGamemodeTests

[NEXT]
?F-06→F-07→firstVerticalSlice{see implementation_plan.md§7}
?revisit::harness-memory{populate after real sessions}
