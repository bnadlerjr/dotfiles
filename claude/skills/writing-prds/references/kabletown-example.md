# Kabletown PRD Example

A complete Product Requirements Document derived from the Kabletown Support Assistant Product Brief.

---

# Product Requirements Document: Helpy McHelpface

## High-Level Requirements

- Per the Product Brief, we're trying to increase user satisfaction and lower support burden while being revenue neutral.
- We're focusing on technical support interactions (Sad Lisa persona) for the first milestone.
- We're going to target the frequent tasks, such as slow internet diagnosis, first. When Helpy detects something outside its expertise, it will delegate to a human rather than trying to help.
- We'll be focused on safety early to keep Helpy within clear guardrails even if that means sometimes not being as helpful as it could.

### Design Principles

1. **Delegation over overreach**: When uncertain, escalate to humans rather than attempt risky actions
2. **Common cases first**: Optimize for frequent support scenarios before edge cases
3. **Measurement built-in**: Include feedback mechanisms from day one
4. **Revenue-neutral**: Don't block legitimate downgrades, but don't encourage them

---

## Use Case Compendium

### Technical Support Scenarios (Sad Lisa)

| Requirement | Milestone | Persona | North Star |
|-------------|-----------|---------|------------|
| Lisa can easily find Helpy on the home page without first logging in when looking for tech support | M1 | Sad Lisa | Customer hardware problem |
| Helpy is visible and clearly labeled for support (e.g., chatbot button in lower right) | M1 | Sad Lisa | Customer hardware problem |
| Helpy can gather setup information through guided questions (device type, connection type) | M1 | Sad Lisa | Customer hardware problem |
| Helpy can check outage status for user's location before starting diagnostics | M1 | Sad Lisa | Outage |
| When an outage exists, Helpy informs the user and provides an ETA | M1 | Sad Lisa | Outage |
| Helpy can efficiently guide Lisa through diagnostics of slow internet, with causes ranging from software to hardware | M1 | Sad Lisa | Customer hardware problem |
| Helpy suggests the most successful interventions learned from the support database | M1 | Sad Lisa | Customer hardware problem |
| Diagnostic suggestions are ordered by historical success rate | M1 | Sad Lisa | Customer hardware problem |
| Helpy asks Lisa what worked so it can keep learning as technology changes | M2 | Sad Lisa | Customer hardware problem |
| When remediations are inconclusive, Helpy suggests future follow-ups before signing off | M1 | Sad Lisa | Customer hardware problem |
| Helpy can send follow-up notifications when outages are resolved | M1 | Sad Lisa | Outage |
| Lisa is presented satisfaction surveys after support interactions | M1 | Sad Lisa | Customer hardware problem, Outage |
| Helpy can be trained on satisfaction surveys to become more effective over time | M2 | Sad Lisa | Customer hardware problem |

### Account Support Scenarios (Tinker Tia)

| Requirement | Milestone | Persona | North Star |
|-------------|-----------|---------|------------|
| Tia can find Helpy when logged into her account | M2 | Tinker Tia | Cable box installation |
| Helpy can access Tia's current subscription and account details | M2 | Tinker Tia | Cable box installation, Downgrade |
| Helpy can explain available plan options and their costs | M2 | Tinker Tia | Cable box installation, Downgrade |
| Helpy can guide users through adding equipment to their plan | M2 | Tinker Tia | Cable box installation |
| Helpy can determine if professional installation is required | M2 | Tinker Tia | Cable box installation |
| Helpy can initiate shipping orders for equipment | M2 | Tinker Tia | Cable box installation |
| Helpy can notify users when shipments are dispatched | M2 | Tinker Tia | Cable box installation |
| Helpy can coordinate installation appointment scheduling after shipment | M2 | Tinker Tia | Cable box installation |
| Helpy works with users to find appointment times within their constraints | M2 | Tinker Tia | Cable box installation |
| Helpy can check back with users after installation to conduct surveys | M2 | Tinker Tia | Cable box installation |
| Helpy can search for comparable plans with lower costs when users request downgrades | M2 | Tinker Tia | Downgrade |
| Helpy can clearly explain cost savings from plan changes | M2 | Tinker Tia | Downgrade |
| Helpy can process subscription changes pending equipment return | M2 | Tinker Tia | Downgrade |
| Helpy can send return packaging for equipment | M2 | Tinker Tia | Downgrade |
| Helpy detects when downgrade requests would not save money (e.g., promotional rates) | M2 | Tinker Tia | Angry customer |
| Helpy explains why a downgrade wouldn't help and offers alternatives | M2 | Tinker Tia | Angry customer |

### Escalation & Safety

| Requirement | Milestone | Persona | North Star |
|-------------|-----------|---------|------------|
| Users can request to speak with a human support representative at any time | M1 | Both | Angry customer |
| When escalating, Helpy transfers full conversation context to the human agent | M1 | Both | Angry customer |
| Helpy recognizes emotional cues (frustration, anger) and offers human escalation | M1 | Both | Angry customer |
| Helpy clearly acknowledges its limitations when asked about topics outside its expertise | M1 | Both | All |
| Helpy does not take account-modifying actions without explicit user confirmation | M2 | Tinker Tia | All |
| All satisfaction surveys are sent after interactions, including escalated ones | M1 | Both | All |

---

## Milestone Definitions

### Milestone 1: Technical Support Foundation

**Goal**: Prove that Helpy can successfully handle common technical support issues, increasing automated resolution from 15% toward 65%.

**Persona focus**: Sad Lisa (Technical support user)

**Scope**:
- Pre-login discoverability on home page and mobile app
- Outage detection and notification
- Slow internet diagnostics with guided troubleshooting
- Success-rate-ordered intervention suggestions
- Follow-up suggestions for inconclusive diagnostics
- Human escalation at any point
- Satisfaction surveys after all interactions

**Explicitly excluded**:
- Account changes (requires authentication and higher-risk actions) → M2
- Learning from feedback (can ship with manual analysis first) → M2
- Equipment ordering and shipping → M2
- Appointment scheduling → M2

**Success criteria**:
- 50%+ of technical support interactions fully automated
- Customer satisfaction ≥ 3.0 for Helpy-handled interactions
- Escalation rate ≤ 30% for technical support

---

### Milestone 2: Account Support & Learning

**Goal**: Enable account modifications and implement learning capabilities.

**Persona focus**: Tinker Tia (Account support user)

**Scope**:
- Authenticated access to account details
- Plan comparison and downgrade requests
- Equipment ordering and shipping
- Installation appointment scheduling
- Learning from successful interventions
- Training on satisfaction survey feedback

**Explicitly excluded**:
- Complex billing disputes → Human only
- Multi-service bundle changes → Future milestone
- Automated promotional offers → Future milestone

**Success criteria**:
- 65% of all support interactions fully automated
- Customer satisfaction ≥ 3.5 (up from 2.1 baseline)
- Revenue impact within ±5% (neutral)

---

## Traceability Matrix

| North Star Scenario | M1 Reqs | M2 Reqs | Total |
|---------------------|---------|---------|-------|
| Customer hardware problem | 9 | 2 | 11 |
| Outage | 4 | 0 | 4 |
| Cable box installation | 0 | 10 | 10 |
| Downgrade | 0 | 5 | 5 |
| Angry customer | 3 | 2 | 5 |
| **Total** | **16** | **19** | **35** |

---

## Notes for Implementation

### Risk Mitigations Built Into Requirements

1. **"Actions outside expertise → delegate to human"** addresses the risk that Helpy takes actions it shouldn't
2. **Explicit confirmation for account changes** reduces surprise actions
3. **Satisfaction surveys from day one** enables tracking and course correction
4. **Learning deferred to M2** allows manual analysis first to validate approach

### Open Questions for Engineering

1. How will outage status be accessed? (API integration with network ops)
2. What's the latency requirement for diagnostic suggestions?
3. How is conversation context structured for human handoff?
4. What authentication flow is required for account access in M2?
