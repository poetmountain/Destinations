---
name: new-destination
description: Scaffold a new, empty Destinations screen module (Provider, state model, and View) and register it with the app's Flow.
argument-hint: <Name>
disable-model-invocation: true
---

# New Destination

Scaffold an empty Destination module named: $ARGUMENTS

Use only the first word as the module name, in PascalCase without a `View` suffix. This action only scaffolds: don't add Events, Interactors, presentations, data, or UI beyond a minimal placeholder body. If more text follows the name, ignore it and mention that in the report.

## Steps

1. Read the main Destinations skill at `../SKILL.md` (the same plugin, `${CLAUDE_SKILL_DIR}/../SKILL.md`) for its general rules. Read `../references/views.md` (including how a Destination with no Events declares its `Events` enum), `../references/providers.md`, and `../references/state-models.md` before writing code.
2. Inspect the project: the app's destination type enum, its `DestinationTypes` equivalent, content type, and where the Flow's providers dictionary is built.
3. Create `<Name>View.swift`, `<Name>State.swift`, and `<Name>Provider.swift` together in `Modules/<Name>/`. Always use this layout, even if the project's existing modules are organized differently. If there's no `Modules` directory, create it next to the app's other source folders.
4. Add the new case to the destination type enum and register the Provider in the Flow's providers dictionary. Don't change any other existing files.
5. Build the project and fix compiler errors.
6. Report as plain Markdown, not inside a code block, with no code and nothing else, in this shape:

**Created**
- `Modules/<Name>/<Name>View.swift`
- `Modules/<Name>/<Name>State.swift`
- `Modules/<Name>/<Name>Provider.swift`

**Edited**
- `<path>`: <what changed, a few words>

**Build:** succeeded, or failed with the first error

**Next:** <one sentence on how to present it from another screen>
