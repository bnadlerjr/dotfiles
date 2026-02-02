# Code Smells

Martin Fowler's taxonomy from *Refactoring* (2nd Edition). Each smell includes detection criteria and recommended refactorings.

## Bloaters

Smells where code has grown excessively large.

### Long Method
**Detection**: Method > 10 lines, or you need to scroll, or it does multiple things.
**Evidence**: Multiple levels of abstraction, comments explaining sections.
**Refactorings**: Extract Function, Replace Temp with Query, Introduce Parameter Object, Decompose Conditional

### Large Class
**Detection**: Class > 200 lines, or has unrelated responsibilities, or instance variables cluster into groups.
**Evidence**: Prefixed method names (e.g., `orderTotal`, `orderValidate`), variables only used by some methods.
**Refactorings**: Extract Class, Extract Superclass, Replace Type Code with Subclasses

### Long Parameter List
**Detection**: > 3 parameters, or parameters always passed together, or parameter comes from calling a method on another parameter.
**Evidence**: Same parameter groups appear in multiple methods.
**Refactorings**: Replace Parameter with Query, Preserve Whole Object, Introduce Parameter Object, Remove Flag Argument

### Data Clumps
**Detection**: Same 3+ fields appear together in multiple places.
**Evidence**: Repeated parameter groups, field groups that are always accessed together.
**Refactorings**: Extract Class, Introduce Parameter Object, Preserve Whole Object

### Primitive Obsession
**Detection**: Using primitives for domain concepts (string for phone, int for money).
**Evidence**: Validation logic scattered, formatting code duplicated, comparisons on primitives with domain meaning.
**Refactorings**: Replace Primitive with Object, Replace Type Code with Subclasses, Replace Conditional with Polymorphism

## Object-Orientation Abusers

Smells indicating incomplete or incorrect OO application.

### Switch Statements
**Detection**: Same switch/case or if/else chain appears in multiple places, or switch on type code.
**Evidence**: Adding a new type requires changes in multiple locations.
**Refactorings**: Replace Conditional with Polymorphism, Replace Type Code with Subclasses, Replace Parameter with Query

### Parallel Inheritance Hierarchies
**Detection**: Creating a subclass in one hierarchy requires creating a subclass in another.
**Evidence**: Class name prefixes match across hierarchies (e.g., `OrderProcessor`/`OrderValidator`).
**Refactorings**: Move Method, Move Field (collapse one hierarchy into the other)

### Refused Bequest
**Detection**: Subclass doesn't use inherited methods/data, or overrides to throw "not supported".
**Evidence**: Empty method overrides, casting to subclass after calling superclass method.
**Refactorings**: Push Down Method, Push Down Field, Replace Subclass with Delegate

### Alternative Classes with Different Interfaces
**Detection**: Two classes do the same thing but have different method signatures.
**Evidence**: Adapter code, duplicated logic with different names.
**Refactorings**: Rename Method, Move Method, Extract Superclass

## Change Preventers

Smells that make changes difficult.

### Divergent Change
**Detection**: One class changes for multiple unrelated reasons.
**Evidence**: "I need to modify X for both database changes AND reporting changes."
**Refactorings**: Extract Class, Split Phase, Move Function

### Shotgun Surgery
**Detection**: One change requires edits to many different classes.
**Evidence**: Small feature addition touches 10+ files.
**Refactorings**: Move Function, Move Field, Combine Functions into Class, Inline Function/Class

### Feature Envy
**Detection**: Method uses more features of another class than its own.
**Evidence**: Multiple calls to getters on one object, long chains of method calls.
**Refactorings**: Move Function, Extract Function (then Move)

## Dispensables

Smells representing unnecessary code.

### Comments
**Detection**: Comments explain what code does (not why).
**Evidence**: Comments that would be unnecessary if code were clearer.
**Refactorings**: Extract Function (name explains intent), Rename Variable, Introduce Assertion

### Duplicate Code
**Detection**: Same code structure in multiple places.
**Evidence**: Copy-paste patterns, similar algorithms with slight variations.
**Refactorings**: Extract Function, Slide Statements, Pull Up Method

### Lazy Class
**Detection**: Class doesn't do enough to justify its existence.
**Evidence**: Class with 1-2 trivial methods, wrapper that adds nothing.
**Refactorings**: Inline Class, Collapse Hierarchy

### Speculative Generality
**Detection**: Hooks, special cases, or abstractions for features that don't exist.
**Evidence**: "We might need this someday," unused parameters, abstract classes with one subclass.
**Refactorings**: Collapse Hierarchy, Inline Function, Inline Class, Remove Dead Code

### Dead Code
**Detection**: Code that is never executed.
**Evidence**: Unreachable branches, unused variables, methods with no callers.
**Refactorings**: Remove Dead Code

## Couplers

Smells indicating excessive coupling.

### Message Chains
**Detection**: Client asks object A for object B, then asks B for object C, etc.
**Evidence**: Long chains like `a.getB().getC().getD().doSomething()`.
**Refactorings**: Hide Delegate, Extract Function, Move Function

### Middle Man
**Detection**: Class delegates most methods to another class.
**Evidence**: Majority of methods are one-line delegations.
**Refactorings**: Remove Middle Man, Inline Function, Replace Superclass with Delegate

### Inappropriate Intimacy
**Detection**: Classes access each other's private parts excessively.
**Evidence**: Bidirectional associations, friend classes, reaching into internal state.
**Refactorings**: Move Function, Move Field, Hide Delegate, Replace Subclass with Delegate, Change Bidirectional Reference to Unidirectional

### Insider Trading
**Detection**: Modules trade data excessively behind closed doors.
**Evidence**: Hidden dependencies, modules that "know" about each other's internals.
**Refactorings**: Move Function, Move Field, Hide Delegate

## Severity Guidelines

**Critical**: Blocking current work or causing bugs
- Duplicate Code in hot path
- Shotgun Surgery for planned change
- Feature Envy causing bugs

**High**: Significantly impedes understanding or change
- Long Method (> 30 lines)
- Large Class with mixed responsibilities
- Divergent Change

**Medium**: Noticeable but manageable
- Long Parameter List
- Data Clumps
- Message Chains

**Low**: Minor issues, fix opportunistically
- Comments (explaining "what")
- Lazy Class
- Speculative Generality
