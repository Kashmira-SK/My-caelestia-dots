# Project preferences

## Delivery

- Every change must be documented in `CHANGELOG.md` and committed before the task is considered complete, unless the user explicitly instructs otherwise.
- Do this automatically without waiting for a reminder or a separate request to commit. Use focused commits for separate changes and include the matching changelog update in each commit.
- Stage only the files and hunks belonging to the current task; preserve unrelated work. Committing does not authorize pushing.

## Changelog

- Read the full `CHANGELOG.md`, including older entries, before choosing the style for an update. Do not copy only the newest entry or commit.
- Default to concise `Added`, `Fixed`, and `Notes` sections with short, flat bullets. Mention file paths inline where useful.
- Reserve `Notes` for unresolved bugs, unfinished or deferred work, known limitations, and important operational caveats. Do not describe these as completed fixes. Omit the section when there is nothing important to record.
- Do not add routine validation or progress commentary to the changelog, such as "waiting for visual validation", "needs visual verification", "checks passed", or "shell reloaded". Report routine verification in the conversation instead; describe a concrete unresolved issue under `Notes` only when one exists.
- Scale detail to the size of the change. The unusually detailed recent overhaul entries are exceptions, not the everyday template.
- Keep newest entries at the top, use `## [YYYY-MM-DD] - Short description`, and separate entries with `---`.
- Use exactly one entry per date. Always merge same-day changes into the existing entry, combining any duplicate entries for that date and updating the description as needed. Do not create a separate entry for each commit or follow-up fix.
- When asked to summarize commits, inspect the relevant commits and cover their actual changes without listing every implementation detail.
