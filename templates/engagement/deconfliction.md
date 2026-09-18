# Deconfliction — TARGET_SLUG

## Legal / business boundaries
- AUTHORIZED_SYSTEMS
- SENSITIVE_DATA (types never to collect/store)
- Change-freeze windows: FROZEN_TIMES

## Technical boundaries
- In-scope CIDRs/hosts: IN_SCOPE
- Explicitly off-limits: OFF_LIMITS
- DoS / destructive testing: PROHIBITED (unless separately approved)
- Persistence / lateral movement within target: POLICY

## Engagement controls
- Escalation contact: CONTACT
- Stop conditions: STOP_IF_ANY
- Resumption: RESUME_AFTER

## Operations windows
- Testing window: WINDOW
- Blackout times: BLACKOUTS
- Notification on anomaly: NOTIFY_CONTACT