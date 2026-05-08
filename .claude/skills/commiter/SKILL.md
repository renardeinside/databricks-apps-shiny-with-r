---
name: commiter
description: Create git commits with emoji prefixes and conventional commit messages. Use when the user wants to commit changes.
---

# Commiter

Create well-formatted git commits with emoji prefixes and conventional commit style.

## When to Use

- When the user asks to commit and push changes
- When the user mentions "just pm" or wants to create a commit
- When the user asks for help with commit messages
- After completing a task and the user wants to save progress

## Emoji Reference

Use ONLY these emojis for commit messages:

| Emoji | Code                 | Type     | Description                              |
| ----- | -------------------- | -------- | ---------------------------------------- |
| ✨    | `:sparkles:`         | feat     | New feature or capability                |
| 🐛    | `:bug:`              | fix      | Bug fix                                  |
| 🔧    | `:wrench:`           | chore    | Configuration, tooling, or maintenance   |
| 📝    | `:memo:`             | docs     | Documentation changes                    |
| ♻️    | `:recycle:`          | refactor | Code refactoring without behavior change |
| 🎨    | `:art:`              | style    | Code style, formatting, structure        |
| ✅    | `:white_check_mark:` | test     | Adding or updating tests                 |
| 🚀    | `:rocket:`           | perf     | Performance improvements                 |
| 🔒    | `:lock:`             | security | Security fixes or improvements           |
| ⬆️    | `:arrow_up:`         | deps     | Dependency updates                       |
| 🗑️    | `:wastebasket:`      | remove   | Removing code or files                   |
| 🚧    | `:construction:`     | wip      | Work in progress                         |

## Instructions

1. **Gather context** - Run these commands to understand the changes:

   ```bash
   git status
   git diff --staged
   git diff
   ```

2. **Analyze changes** - Determine the primary type of change:
   - New functionality → feat (✨)
   - Bug fix → fix (🐛)
   - Documentation → docs (📝)
   - Refactoring → refactor (♻️)
   - Configuration/tooling → chore (🔧)
   - Tests → test (✅)

3. **Compose the message** - Format: `<emoji> <type>: <short description>`
   - Keep it under 72 characters total
   - Use imperative mood ("add feature" not "added feature")
   - Be specific but concise
   - Lowercase after the type prefix

## Examples

Good commit messages:

- `✨ feat: add user authentication endpoint`
- `🐛 fix: resolve null pointer in config parser`
- `📝 docs: update API documentation for v2`
- `🔧 chore: add commiter skill for git workflow`
- `♻️ refactor: simplify error handling logic`
- `✅ test: add unit tests for payment module`
- `⬆️ deps: bump fastapi to 0.110.0`

Bad commit messages (avoid these):

- `fix stuff` (too vague)
- `✨ feat: Added the new feature for users` (past tense, too long)
- `🎉 party: celebrate` (wrong emoji, wrong type)

## Multi-Change Commits

If changes span multiple categories, choose the primary one or suggest splitting into multiple commits. Prefer atomic commits that focus on a single concern.

## Pre-Commit Checklist

Before committing, verify:

- [ ] All changes are intentional (review `git diff`)
- [ ] No sensitive data (credentials, secrets) in staged files
- [ ] The commit message accurately describes the changes
- [ ] Tests pass (if applicable)
