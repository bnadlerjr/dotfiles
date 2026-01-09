# Agile Story Examples

Complete examples demonstrating the agile-story skill.

---

## Example 1: Order Cancellation

### Discovery Summary

**Actor**: Customer who has placed an order
**Trigger**: Changed their mind about a purchase
**Outcome**: Order cancelled, refund confirmation received
**Constraints**: Only before shipment; returns process applies after
**Failure Modes**: Already shipped, payment refund fails

### Final Story

```markdown
## Story: Customer Cancels Order Before Shipment

When customers change their mind about a purchase, they need to cancel it
and receive confirmation that their refund is being processed. This must
happen before the order ships, since the returns process applies afterward.

### Context
Available for orders in "confirmed" or "processing" status that haven't
been handed off to shipping.

### Acceptance Criteria

#### Scenario: Successful cancellation of unshipped order
- Given a customer has an order in "confirmed" status
- When they request to cancel the order
- Then the order status changes to "cancelled"
- And a refund is initiated for the full order amount
- And they receive a cancellation confirmation

#### Scenario: Cancellation with promotional discount
- Given a customer used a 20% promotional code on their order
- When they cancel the order
- Then the full amount paid is refunded
- And the promotional code is restored for future use

#### Scenario: Attempting to cancel an already-shipped order
- Given an order has already left the warehouse
- When the customer attempts to cancel
- Then they are informed the order cannot be cancelled
- And they are directed to the returns process instead

#### Scenario: Cancellation when refund processing fails
- Given a customer requests cancellation
- When the payment provider cannot process the refund
- Then the order is still cancelled
- And the customer is informed their refund is being processed manually
- And customer service is notified to follow up
```

---

## Example 2: Data Export for Compliance

### Discovery Summary

**Actor**: Account holder responding to data subject request
**Trigger**: GDPR/CCPA compliance requirement
**Outcome**: Complete personal data download in portable format
**Constraints**: Must be verified account, 30-day retention window
**Failure Modes**: Unverified email, high system load delays

### Final Story

```markdown
## Story: Account Holder Exports Personal Data for Compliance

When account holders receive data subject requests (GDPR/CCPA), they need
to download a complete copy of their personal data in a portable format.
This allows them to fulfill legal obligations and maintain records
independently of the platform.

### Context
Available to verified account holders with active or recently-closed
accounts (within 30-day retention window).

### Acceptance Criteria

#### Scenario: Successful full data export
- Given an account holder with purchase history and profile data
- When they request a data export
- Then they receive a downloadable archive within 24 hours
- And the archive contains all personal data in machine-readable format
- And they receive email notification when ready

#### Scenario: Export for account with minimal data
- Given a new account holder with only profile information
- When they request a data export
- Then they receive their export within minutes
- And the archive contains their profile data

#### Scenario: Export request during high system load
- Given many export requests are queued
- When an account holder requests their export
- Then they see estimated completion time
- And they can continue using the platform while waiting
- And they receive notification when complete

#### Scenario: Attempting export with unverified email
- Given an account holder hasn't verified their email
- When they attempt to request a data export
- Then they're prompted to verify their email first
- And the security reason is explained clearly
```

---

## Example 3: Password Reset

### Discovery Summary

**Actor**: User who cannot access their account
**Trigger**: Forgot password or security concern
**Outcome**: Secure password reset, account access restored
**Constraints**: Email verification required, link expiration
**Failure Modes**: Email not found, expired link, rate limiting

### Final Story

```markdown
## Story: User Resets Forgotten Password

When users cannot remember their password or suspect their account may be
compromised, they need a secure way to reset their credentials and regain
access. The process must verify their identity while remaining accessible.

### Context
Available from the login page when a user cannot authenticate.

### Acceptance Criteria

#### Scenario: Successful password reset
- Given a user with a verified email address
- When they request a password reset
- Then they receive an email with a secure reset link
- And the link expires after 1 hour
- And they can set a new password using the link

#### Scenario: Reset for unregistered email
- Given the email address is not in the system
- When someone requests a reset for that email
- Then the same "check your email" message is shown
- And no email is sent (prevents account enumeration)

#### Scenario: Expired reset link
- Given a user received a reset link more than 1 hour ago
- When they try to use the link
- Then they are informed the link has expired
- And they can request a new reset link

#### Scenario: Multiple reset requests
- Given a user has requested reset 3 times in 10 minutes
- When they request another reset
- Then they are asked to wait before trying again
- And they're offered to contact support if urgent

#### Scenario: Password requirements not met
- Given a user is setting their new password
- When they enter a password that doesn't meet requirements
- Then they see specific feedback about what's needed
- And they can try again without requesting a new link
```

---

## Anti-Pattern Examples

### What NOT to Write

**Template smell**:
```markdown
❌ As a user, I want to reset my password so that I can access my account.
```

**Implementation leak**:
```markdown
❌ ## Story: Password Reset API

The system needs a /auth/reset-password endpoint that accepts POST
requests with email in JSON body and returns 200 OK.

### Acceptance Criteria

#### Scenario: Valid request
- Given a valid JSON payload
- When POST to /auth/reset-password
- Then return 200 with { success: true }
- And insert reset_token into password_resets table
```

**Vague outcomes**:
```markdown
❌ ### Acceptance Criteria

#### Scenario: Reset password
- Given a user forgets password
- When they reset it
- Then it works correctly
```

**Missing failure modes**:
```markdown
❌ ### Acceptance Criteria

#### Scenario: Successful reset
- Given a registered user
- When they request reset
- Then they receive email and can reset

[No scenarios for: invalid email, expired link, rate limiting, etc.]
```

---

## Story Sizing Guide

### Too Large (Epic)
```markdown
❌ User Account Management

Users can create accounts, update profiles, manage security settings,
configure notification preferences, handle billing, and export data.
```

### Right Size (Stories)
```markdown
✅ Story 1: User Creates Account
✅ Story 2: User Updates Profile Information
✅ Story 3: User Enables Two-Factor Authentication
✅ Story 4: User Configures Email Notifications
✅ Story 5: User Updates Payment Method
✅ Story 6: User Exports Personal Data
```

Each story should be completable in one iteration with clear acceptance criteria.
