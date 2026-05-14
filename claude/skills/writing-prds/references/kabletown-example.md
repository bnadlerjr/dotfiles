# Kabletown PRD Example

A complete Product Requirements Document derived from the Kabletown Support Assistant Product Brief.

This example illustrates **sparse prioritization**: only requirements from the chosen north star scenarios (Sad Lisa's customer hardware problem and outage flows) carry `1.0` or `1.5` values. Everything else — including the entire Tinker Tia account-support arc and the cross-cutting escalation requirements — is captured but left blank, to be prioritized when planning a later milestone.

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

All requirements from all north star scenarios are presented in a single unified table. The North Star column provides traceability. Only requirements that the chosen north star (Sad Lisa technical support) depends on are prioritized; everything else is intentionally left blank and will be prioritized when planning a future milestone.

| Requirement | Milestone | Persona | North Star |
|-------------|-----------|---------|------------|
| Lisa can easily find Helpy on the home page without first logging in when looking for tech support | 1.0 | Sad Lisa | Customer hardware problem |
| Helpy is visible and clearly labeled for support (e.g., chatbot button in lower right) | 1.0 | Sad Lisa | Customer hardware problem |
| Helpy can gather setup information through guided questions (device type, connection type) | 1.0 | Sad Lisa | Customer hardware problem |
| Helpy can check outage status for user's location before starting diagnostics | 1.0 | Sad Lisa | Outage |
| When an outage exists, Helpy informs the user and provides an ETA | 1.0 | Sad Lisa | Outage |
| Helpy can efficiently guide Lisa through diagnostics of slow internet, with causes ranging from software to hardware | 1.0 | Sad Lisa | Customer hardware problem |
| Helpy suggests the most successful interventions learned from the support database | 1.0 | Sad Lisa | Customer hardware problem |
| Users can request to speak with a human support representative at any time | 1.0 | Both | Angry customer |
| When escalating, Helpy transfers full conversation context to the human agent | 1.0 | Both | Angry customer |
| Diagnostic suggestions are ordered by historical success rate | 1.5 | Sad Lisa | Customer hardware problem |
| When remediations are inconclusive, Helpy suggests future follow-ups before signing off | 1.5 | Sad Lisa | Customer hardware problem |
| Helpy can send follow-up notifications when outages are resolved | 1.5 | Sad Lisa | Outage |
| Lisa is presented satisfaction surveys after support interactions | 1.5 | Sad Lisa | Customer hardware problem, Outage |
| Helpy asks Lisa what worked so it can keep learning as technology changes | | Sad Lisa | Customer hardware problem |
| Helpy can be trained on satisfaction surveys to become more effective over time | | Sad Lisa | Customer hardware problem |
| Tia can find Helpy when logged into her account | | Tinker Tia | Cable box installation |
| Helpy can access Tia's current subscription and account details | | Tinker Tia | Cable box installation, Downgrade |
| Helpy can explain available plan options and their costs | | Tinker Tia | Cable box installation, Downgrade |
| Helpy can guide users through adding equipment to their plan | | Tinker Tia | Cable box installation |
| Helpy can determine if professional installation is required | | Tinker Tia | Cable box installation |
| Helpy can initiate shipping orders for equipment | | Tinker Tia | Cable box installation |
| Helpy can notify users when shipments are dispatched | | Tinker Tia | Cable box installation |
| Helpy can coordinate installation appointment scheduling after shipment | | Tinker Tia | Cable box installation |
| Helpy works with users to find appointment times within their constraints | | Tinker Tia | Cable box installation |
| Helpy can check back with users after installation to conduct surveys | | Tinker Tia | Cable box installation |
| Helpy can search for comparable plans with lower costs when users request downgrades | | Tinker Tia | Downgrade |
| Helpy can clearly explain cost savings from plan changes | | Tinker Tia | Downgrade |
| Helpy can process subscription changes pending equipment return | | Tinker Tia | Downgrade |
| Helpy can send return packaging for equipment | | Tinker Tia | Downgrade |
| Helpy detects when downgrade requests would not save money (e.g., promotional rates) | | Tinker Tia | Angry customer |
| Helpy explains why a downgrade wouldn't help and offers alternatives | | Tinker Tia | Angry customer |
| Helpy recognizes emotional cues (frustration, anger) and offers human escalation | | Both | Angry customer |
| Helpy clearly acknowledges its limitations when asked about topics outside its expertise | | Both | All |
| Helpy does not take account-modifying actions without explicit user confirmation | | Tinker Tia | All |
| All satisfaction surveys are sent after interactions, including escalated ones | | Both | All |

---

## Milestone Definitions

### Milestone 1: Technical Support Foundation

**Goal**: Prove that Helpy can successfully handle common technical support issues, increasing automated resolution from 15% toward 65%.

**Persona focus**: Sad Lisa (technical support user)

**North star scenario**: Customer hardware problem, supported by Outage detection.

**Scope** (the `1.0` rows above):

- Pre-login discoverability on the home page
- Guided diagnostic question flow
- Outage detection and notification
- Slow internet diagnostics with intervention suggestions
- Human escalation at any point with full conversation context

**Stretch** (the `1.5` rows — slippable):

- Success-rate-ordered intervention ranking
- Follow-up suggestions for inconclusive diagnostics
- Outage-resolution follow-up notifications
- Post-interaction satisfaction surveys

**Explicitly excluded**:

- All account-related capabilities (authentication, plan changes, equipment, scheduling) — captured in the compendium with blank milestone values; will be prioritized later
- Learning from feedback — captured but blank; manual analysis is acceptable for the first milestone
- Emotional-cue escalation and limit acknowledgment — captured but blank; explicit user request for a human is sufficient at first

**Success criteria**:

- 50%+ of technical support interactions fully automated
- Customer satisfaction ≥ 3.0 for Helpy-handled interactions
- Escalation rate ≤ 30% for technical support

---

## Traceability Matrix

| North Star Scenario | `1.0` | `1.5` | Blank | Total |
|---------------------|-------|-------|-------|-------|
| Customer hardware problem | 5 | 3 | 2 | 10 |
| Outage | 2 | 1 | 0 | 3 |
| Angry customer | 2 | 0 | 3 | 5 |
| Cross-cutting (Customer hardware problem, Outage) | 0 | 1 | 0 | 1 |
| Cable box installation | 0 | 0 | 10 | 10 |
| Downgrade | 0 | 0 | 5 | 5 |
| All / cross-cutting (blank-priority) | 0 | 0 | 1 | 1 |
| **Total** | **9** | **4** | **22** | **35** |

Distribution: 26% at `1.0`, 11% at `1.5`, **63% blank** — `1.0` sits at the upper edge of the 15–25% target but within tolerance, with healthy room left for blank rows.

---

## Notes for Implementation

### Risk Mitigations Built Into Requirements

1. **"Actions outside expertise → delegate to human"** addresses the risk that Helpy takes actions it shouldn't
2. **Explicit confirmation for account changes** reduces surprise actions (captured for a later milestone)
3. **Satisfaction surveys from the start** enables tracking and course correction
4. **Learning deferred** allows manual analysis first to validate approach

### Open Questions for Engineering

1. How will outage status be accessed? (API integration with network ops)
2. What's the latency requirement for diagnostic suggestions?
3. How is conversation context structured for human handoff?
