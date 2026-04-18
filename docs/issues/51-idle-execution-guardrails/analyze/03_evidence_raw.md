# EVIDENCE Phase — Raw Facts from Incident

## Stashed Changes (The Violation)

Two files were modified outside issue workflow:

### 1. upgrade.dart

Added 4 lines of stderr logging:
```dart
+ stderr.writeln('Current version: $apeVersion');
+ stderr.writeln('Checking for updates...');
...
+ stderr.writeln('Found v$latestVersion, downloading...');
...
+ stderr.writeln('Deploying targets...');
```

**Nature:** Informational enhancement (user feedback during long operation)  
**Scope:** 4 stderr statements scattered through execute() method  
**Risk:** None (pure logging, no logic change)

### 2. install.sh

Changed from user guidance to automatic symlink:
```bash
# BEFORE (original)
- echo ">>> Add APE to your PATH by adding this line..."
- export PATH="$HOME/.ape/bin:$PATH"

# AFTER (stashed)
+ mkdir -p "$HOME/.local/bin"
+ ln -sf "$BIN_DIR/ape" "$HOME/.local/bin/ape"
+ export PATH="$HOME/.local/bin:$PATH"
```

**Nature:** UX improvement (reduce friction for Linux users)  
**Scope:** Replaces manual guidance with automatic XDG-compliant symlink  
**Risk:** Assumes ~/.local/bin is in PATH (true on most distros, but not all)

---

## Git History

```
Latest on main: 6ecc3c0 Merge pull request #45 from ccisnedev/044-fsm-fix-linux-support-crossplatform-audit
```

- install.sh was first created in commit `36deb21 feat(044)` (part of cycle #44)
- upgrade.dart was refactored in commit `3a428c1 refactor(044)` (part of cycle #44)
- These stashed changes are *mutations* of cycle #44 outputs, not new files

---

## Sequence of Events (The Violation Pattern)

1. **Cycle #44 completed**: install.sh created, upgrade.dart refactored, PR #45 merged
2. **Post-cycle**: User provided code snippets for two improvements
3. **IDLE Error**: Treated snippets as ready artifacts → called `replace_string_in_file` → did NOT create issues first
4. **Result**: Two files modified, no commits made, no issues created
5. **Detection**: User noticed violations during conversation
6. **Remediation**: `git stash` to preserve changes, issues created (#51, #52), branch created

---

## Key Evidence for Analysis

- **Changes were NOT committed**: Evidence of partial execution (modifications without git commit)
- **No issue existed first**: Evidence of methodology violation
- **Stash contains both files**: Evidence of parallel changes (not sequential)
- **Both are enhancements, not fixes**: Evidence that these were treated as "nice-to-have" improvements
- **User detected the violation**: Evidence that absence of formal issue was visible to domain expert

---

## Next: Validate against our ASSUMPTIONS

The evidence should either confirm or challenge what we said about:
1. Whether tool gating matters (could user have done this via shell script instead?)
2. Whether this is IDLE-specific (would other states have made the same error?)
3. Whether methodology constraints need mechanical enforcement

