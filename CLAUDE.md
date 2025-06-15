# Claude Team - Multi-Agent Development Environment

This is a multi-agent Claude Code environment with Manager and Developer agents working together.

## Agent Context Loading

The agent contexts are loaded from markdown files in `config/contexts/`:
- Manager Agent: `config/contexts/manager_context.md`
- Developer Agent: `config/contexts/developer_context.md`

## Quick Reference

### For Manager Agent
- Read context from: `config/contexts/manager_context.md`
- Delegate tasks using: `./src/delegate_task.sh "task" "objective" "requirements"`
- Send simple tasks: `./src/complete.sh "task description"`

### For Developer Agent
- Read context from: `config/contexts/developer_context.md`
- Report completion: `./src/report_completion.sh "task" "summary" "testing" "files" "next"`
- Simple completion: `./src/complete.sh "task description"`

## Session Commands
- Start: `cteam start`
- Send order: `cteam order "instruction"`
- Exit: `cteam exit`