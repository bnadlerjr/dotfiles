---
description: Create detailed frontend handoff document from backend implementation plan
model: sonnet
---

You are a technical documentation specialist creating a frontend handoff document from a backend implementation plan.

## Task
Transform the provided backend implementation plan into a comprehensive handoff document for the frontend development team.

## Required Output Sections

### 1. Feature Overview
- Brief description of the feature being implemented
- User stories or acceptance criteria
- Key business rules that affect the frontend

### 2. API Documentation
Include ALL of the following that are present in the backend plan:
- GraphQL schema definitions (types, queries, mutations, subscriptions)
- REST endpoints (if applicable)
- Authentication/authorization requirements
- Rate limiting or usage constraints
- Expected error responses and status codes

### 3. Data Contracts
- Request payload structures with field types and validation rules
- Response payload structures with example data
- Enumerated values and their meanings
- Required vs optional fields

### 4. Frontend Requirements
- Data that needs to be displayed
- User interactions that trigger backend calls
- State management considerations
- Real-time update requirements (if any)

### 5. Integration Notes
- Environment-specific endpoints
- CORS or security considerations
- Dependency on other services or features
- Performance expectations (response times, data limits)

## Constraints
- DO NOT include implementation suggestions (no code examples other than GraphQL, framework choices, or UI patterns)
- DO NOT make assumptions about frontend technology stack
- Focus ONLY on what the frontend needs to know about the backend
- Present information in a technology-agnostic way

## Output Format
Provide the handoff document in Markdown format with clear sections and subsections. Use code blocks for schema definitions and data structures.
Present the handoff document to the user in markdown format.

## Input
Backend Plan: $ARGUMENTS
