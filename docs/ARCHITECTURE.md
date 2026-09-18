# Pentagent Architecture

## Design goal

Keep the intelligence portable and the runtime-specific code replaceable.

```text
                    PENTAGENT CORE
              prompts/pentagent-system.md
                         |
          +--------------+--------------+
          |              |              |
       OpenCode       Other AI       Custom API
        adapter        adapter        adapter
          |
      permissions
          |
     local Kali tools
          |
   +------+------+------+------+
   |             |             |
  Web          Android       Network/AD
   |             |             |
   +-------------+-------------+
                 |
             Evidence
                 |
              Findings
                 |
               Reports
```

## Design rules

### Core prompt

Contains behavior, methodology, security reasoning, evidence rules, and reporting standards.

### Runtime adapter

Contains only the configuration needed to expose the core prompt to a particular agent runtime.

### Specialist modules

Should be added as reusable skills or subagents instead of continually inflating the primary prompt.

### Engagement data

Should be isolated from source code and ignored by Git unless explicitly sanitized.
