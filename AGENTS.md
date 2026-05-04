# AGENTS.md

## Project Notes
- This is a Ruby on Rails 7.1 app on Ruby 3.3.4.
- Frontend uses Hotwire/Turbo, Stimulus controllers, import maps, and Tailwind CSS.
- Local development and test databases use PostgreSQL; `compose.yml` can start them with `docker compose up -d`.
- The root route is the Books experience. `/books` is kept as an alias, but navigation should use `Home` and `Collections`, not a separate `Books` link.

## Workflow
- If currently on `main`, create a `codex/...` branch before editing.
- Treat the worktree as shared. Do not revert, overwrite, stage, or commit changes you did not make unless explicitly asked.
- Keep changes small and committable. For multi-step features, commit each logical step separately.
- Use `rg`/`rg --files` for search and `apply_patch` for manual edits.

## Testing
- Run targeted Rails tests while iterating, for example:
  - `bin/rails test test/controllers/collections_controller_test.rb`
- Run the full suite serially before handoff:
  - `PARALLEL_WORKERS=1 bin/rails test`
- If Rails or Bundler reports old system-Ruby errors, retry from the repo shell without wrapping the command in another login shell.
- The Browserslist `caniuse-lite is outdated` warning can appear during tests and is not itself a failure.

## Collections Behavior
- Collections are publicly browsable; creation, editing, and deletion require authentication.
- A Collection belongs to an existing Owner and must include at least one existing Book.
- Books selected for a Collection may belong to any Owner because the library is shared.
- Collection summaries use the format: `Contains X book(s), from Y author(s), spanning Z genre(s)`.
