# REA Java probe, `EPERM`, and Nix

Checked on 2026-10-20 against the installed `rea-agents` 6.4.0 package and first-party documentation.

## Findings

- The installed REA package identifies itself as `rea-agents` 6.4.0 with source repository `morluto/rea` in its `package.json` (`~/.local/share/pnpm/global/v11/ab338ac99f5969f98c4df934b8e1bd43e8eaa907295ae2d1a698ad37eaef01c3/node_modules/rea-agents/package.json`).
- In installed 6.4.0, `dist/ghidra/GhidraInstallation.js` chooses `$JAVA_HOME/bin/java` when `JAVA_HOME` is set; otherwise it chooses `java` on `PATH`. Its `probeJava` runs that command with Node `spawnSync` and flags the probe as unavailable when `observed.error` exists **or** the child returns a nonzero status. The code does not retain the process error in that result. Thus an `EPERM` from `spawnSync` can appear as a failed Java availability check even if direct execution of the JDK succeeds. [REA source](https://github.com/morluto/rea/blob/main/src/ghidra/GhidraInstallation.ts) describes the corresponding current probe; the version-specific behavior above was verified directly in the installed 6.4.0 file.
- [Node's child process documentation](https://nodejs.org/api/child_process.html#child_processspawnsynccommand-args-options) documents separate `error` and `status` result fields. The local result has `status: 0` alongside `error: EPERM`, so the child actually ran successfully; the error arose elsewhere in Node's child-process handling. It does not establish a Java version or Ghidra compatibility problem.
- [REA's Ghidra installation guide](https://github.com/morluto/rea/blob/main/docs/installation.md) says REA uses an existing Ghidra and JDK installation, selects a JDK through `JAVA_HOME` (or `PATH` if unset), and checks that the JDK meets the Ghidra installation's version bounds. The current upstream code has more detailed `javaProbeFailure` diagnostics, including process error codes; the installed 6.4.0 implementation inspected here does not. [Current REA source](https://github.com/morluto/rea/blob/main/src/ghidra/GhidraInstallation.ts).

## Interpretation and next check

Local checks in the current Codex execution environment:

| Check | Inside sandbox | Outside sandbox |
| --- | --- | --- |
| Node `spawnSync('/bin/true')` | `error: EPERM`, `status: 0` | `status: 0`, no error |
| Node `spawnSync('/usr/bin/java', ['-version'])` | `error: EPERM`, `status: 0`; Java version printed | Not needed for this comparison |
| Node `spawnSync('/nix/store/.../bin/java', ['-version'])` | `error: EPERM`, `status: 0`; Java version printed | Not needed for this comparison |
| `rea doctor --provider ghidra` | `ghidra-java: missing_dependency` | `ghidra-java: healthy`, JDK 25.0.4.1 |

Within the sandbox, `spawnSync('/bin/true', [], {stdio: 'ignore'})` returns `status: 0` without an error. A piped **stdin** reproduces `EPERM`, whereas piping only stdout or stderr does not. This points to a sandbox interaction with Node's default child stdin handling; the exact denied operation is not established. `strace` could not run inside the sandbox because ptrace was denied.

The JDK's `/nix/store` location is therefore not the cause of this `rea doctor` failure. The separate `openProgram` failure still needs its own traceback and reproduction; the failed doctor probe does not identify its cause.
