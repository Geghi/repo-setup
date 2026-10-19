<!--
TEMPLATE — this repo's testing facts, read by the `testing` skill. Copy to `docs/agents/testing.md`, fill every {{PLACEHOLDER}}, delete what doesn't apply, delete this comment.
Facts only: the rules live in the skill.
-->

# Testing — {{REPO_NAME}}

## Layers

| Layer       | Command               | Needs                  |
| ----------- | --------------------- | ---------------------- |
| Unit        | `{{UNIT_CMD}}`        | nothing                |
| Integration | `{{INTEGRATION_CMD}}` | {{INTEGRATION_NEEDS}}  |
| E2E         | `{{E2E_CMD}}`         | {{E2E_NEEDS}}          |

{{Extra layers (e.g. pgTAP): a row above plus one line on when to use it. Delete if none.}}

## Folder structure

```
{{TEST_TREE}}
```

## Isolation

{{How test data is isolated here, e.g. "every file creates its own tenant via `createTestTenant()`; never query across tenants". Delete if nothing beyond the skill's rule.}}
