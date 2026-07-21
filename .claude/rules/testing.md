---
# Path-scoped rule: applies whenever an agent touches files matching the paths below.
# Remove or update the `paths` frontmatter to change the scope.
paths:
  - "tests/**"
  - "**/*.test.*"
  - "**/*.spec.*"
---

# Testing rules

- NEVER modify tests to make them pass; fix the implementation instead.
- NEVER introduce mocks for modules that exist in this repo — test them directly.
- Each test must assert a concrete outcome; do not write tests that always pass.
- Run the full test suite after every implementation change to catch regressions.
- If a test file does not exist yet, create it before writing the implementation (TDD).
