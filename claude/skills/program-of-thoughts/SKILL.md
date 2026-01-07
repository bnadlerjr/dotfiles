---
name: program-of-thoughts
description: Separates reasoning from computation by generating executable code for calculations. Use when user asks for calculations, data processing, or numerical analysis. Recognizes requests like "calculate", "compute", "how much would", "what's the total", "analyze this data", "crunch the numbers", "figure out the math", "process these values". Also applies automatically when implementing logic that involves arithmetic, formulas, or data transformations—generate code instead of computing mentally.
---

# Program of Thoughts (PoT)

Delegates computation to code execution, keeping reasoning in natural language.

## Core Mechanism

Split the cognitive task:
- **LLM handles**: Understanding, decomposition, logic, code generation
- **Interpreter handles**: Actual computation, arithmetic, data manipulation

```
Problem → [LLM: Generate Python] → [Execute] → Result
```

## Process

```
1. Understand the problem in natural language
2. Identify computations needed
3. Generate executable code (Python typically)
4. Execute the code
5. Interpret and present results
```

## Key Principles

- **Separation of concerns**: Reasoning ≠ calculation
- **Precision**: Code execution is deterministic
- **Verifiability**: Code can be inspected and tested
- **Scalability**: Handles large numbers, complex formulas without degradation

## When to Apply

- Numerical calculations (especially with large numbers)
- Multi-step mathematical problems
- Data transformations and analysis
- Financial calculations (compound interest, amortization)
- Any task where arithmetic errors are costly
- Statistics and probability computations

## Implementation Pattern

```
First, let me understand what we need to calculate:
[Natural language reasoning about the problem]

Now I'll write code to compute this precisely:

```python
# [Code with clear variable names and comments]
# Matches the reasoning above
result = ...
print(f"The answer is: {result}")
```

[Execute and present result with interpretation]
```

## Example

Problem: "What is 15% compound interest on $10,000 over 7 years?"

```
Reasoning: Compound interest formula is A = P(1 + r)^t
- P = 10000 (principal)
- r = 0.15 (rate)
- t = 7 (years)

```python
principal = 10000
rate = 0.15
years = 7
final_amount = principal * (1 + rate) ** years
interest_earned = final_amount - principal
print(f"Final amount: ${final_amount:,.2f}")
print(f"Interest earned: ${interest_earned:,.2f}")
```

[Execute → Present results]
```

## Hybrid with CoT

Combine reasoning trace with code execution:
```
Step 1: [Reasoning] → Step 2: [Code for calculation] → Step 3: [Interpret result] → ...
```

## Anti-Patterns

- Writing code for simple arithmetic (overhead not justified)
- Generating code without explaining the logic
- Not executing the code (defeats the purpose)
- Complex code that's harder to verify than manual calculation
