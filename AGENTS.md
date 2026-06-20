# Skills

Never run tests directly.

Always run tests only with the default make target without args to ensure the
tests are run with cqfd to run the tests inside a docker container with
everything mounted inside it at the same paths.

| Situation | Skill |
|---|---|
| Committing, tagging, releasing, or generating a changelog | `.agents/skills/git-best-practices` |
| Reviewing a diff or PR | `.agents/skills/code-review` |
| Adding a feature or fixing a bug | `.agents/skills/tdd` |
| Writing or reviewing bash scripts | `.agents/skills/bash-syntax` |
