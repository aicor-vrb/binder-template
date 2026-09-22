# Agent instructions for this repository

This repository is the template for Virtual Research Labs of the EASE Virtual Research
Building (VRB). It ships agent skills in the vendor-neutral
[Agent Skills](https://agentskills.io) format under `.claude/skills/`.

## Available skills

| Skill | Use when |
|-------|----------|
| [`.claude/skills/setup-vrb-lab/SKILL.md`](.claude/skills/setup-vrb-lab/SKILL.md) | Someone wants to turn an existing project (local folder or GitHub repo) into a new VRB lab that runs on Binder |

When a request matches a skill, read its `SKILL.md` and follow it. The skill's
`reference/` and `templates/` directories are meant to be read on demand.

## Repository rules for agents

- Do not run git or GitHub commands (commit, push, create repo, tag) without the user's
  explicit approval for that specific command.
- Always suggest a local `docker compose -f binder/docker-compose.yml up --build` before
  pushing; Binder builds are slow.
- Clone URLs in Dockerfiles and `.gitmodules` must be HTTPS.

## Tool-specific discovery

- **Claude Code**: the skill lives at `.claude/skills/setup-vrb-lab/`, so it is discovered
  automatically and appears as `/setup-vrb-lab` in sessions started inside this repository.
- **Other agents** (Codex, Cursor, Copilot, Gemini CLI, ...): they read this `AGENTS.md`
  automatically or can be pointed at `.claude/skills/setup-vrb-lab/SKILL.md` directly.
