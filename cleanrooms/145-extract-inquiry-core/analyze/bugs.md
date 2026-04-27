# Bugs encontrados durante v0.2.0

**Issue:** #145
**Branch:** release/0.2.0

---

## Registro

| # | Descripción | Archivo | Estado |
|---|-------------|---------|--------|
| 1 | URL de install scripts incorrecta (`www.si14bm.com/inquiry` vs `inquiry.si14bm.com`) | `code/vscode/src/installer.ts`, `README.md` | ✅ Corregido en #143/#144 |
| 2 | Doctor reporta "0 skills deployed" cuando sí hay 4 skills en `~/.copilot/skills/` | `code/cli/lib/modules/global/commands/doctor.dart` | 🔍 Pendiente investigar |
| 3 | `iq init` crea `docs\cleanrooms` en vez de `.\cleanrooms` en la raíz del proyecto | `code/cli/lib/modules/global/commands/init.dart` | 🔍 Pendiente investigar |
