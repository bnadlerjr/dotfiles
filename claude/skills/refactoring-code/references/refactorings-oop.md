# Refactoring Catalog (OOP)

The top 15 most common refactorings from Martin Fowler's *Refactoring* (2nd Edition). Each entry includes motivation, mechanics, and a sketch.

## Extract Function

**Motivation**: Code fragment that can be grouped together, or code needing a comment to explain its purpose.

**Mechanics**:
1. Create new function, name it by what it does (not how)
2. Copy extracted code into new function
3. Scan for references to variables local to source scope
4. Pass variables as parameters, or extract more broadly
5. Replace extracted code with call to new function
6. Test

**Sketch**:
```
// Before
function printOwing(invoice) {
  printBanner();
  let outstanding = calculateOutstanding();

  // print details
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}

// After
function printOwing(invoice) {
  printBanner();
  let outstanding = calculateOutstanding();
  printDetails(invoice, outstanding);
}

function printDetails(invoice, outstanding) {
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}
```

## Inline Function

**Motivation**: Function body is as clear as name, or indirection is obscuring.

**Mechanics**:
1. Check this isn't a polymorphic method
2. Find all callers
3. Replace each call with function body
4. Test after each replacement
5. Remove function definition

## Extract Variable

**Motivation**: Expression is complex and hard to understand.

**Mechanics**:
1. Ensure expression has no side effects
2. Declare immutable variable, set to expression
3. Replace original expression with variable reference
4. Test

**Sketch**:
```
// Before
return order.quantity * order.itemPrice -
  Math.max(0, order.quantity - 500) * order.itemPrice * 0.05 +
  Math.min(order.quantity * order.itemPrice * 0.1, 100);

// After
const basePrice = order.quantity * order.itemPrice;
const quantityDiscount = Math.max(0, order.quantity - 500) * order.itemPrice * 0.05;
const shipping = Math.min(basePrice * 0.1, 100);
return basePrice - quantityDiscount + shipping;
```

## Inline Variable

**Motivation**: Variable name doesn't communicate more than the expression itself.

**Mechanics**:
1. Check that the right-hand side has no side effects
2. Find all references to variable
3. Replace each with the right-hand side expression
4. Test
5. Remove variable declaration

## Rename Variable

**Motivation**: Name doesn't clearly express what it represents.

**Mechanics**:
1. If variable is widely used, consider encapsulating it first
2. Find all references and change them
3. Test

## Encapsulate Variable

**Motivation**: Data that needs wider scope, or mutable data you want to track changes to.

**Mechanics**:
1. Create encapsulating functions (getter/setter)
2. Replace all references with calls to functions
3. Restrict visibility of variable
4. Test

## Introduce Parameter Object

**Motivation**: Data items that regularly travel together.

**Mechanics**:
1. Create a suitable structure (class/struct)
2. Add parameter for the new structure to the function
3. Test
4. For each element of the new structure, modify callers to pass it via structure
5. Remove original parameters
6. Test

**Sketch**:
```
// Before
function amountInvoiced(startDate, endDate) { ... }
function amountReceived(startDate, endDate) { ... }
function amountOverdue(startDate, endDate) { ... }

// After
class DateRange {
  constructor(startDate, endDate) { ... }
}

function amountInvoiced(range) { ... }
function amountReceived(range) { ... }
function amountOverdue(range) { ... }
```

## Combine Functions into Class

**Motivation**: Group of functions that operate on the same data.

**Mechanics**:
1. Apply Encapsulate Record to common data
2. Move each function into the new class
3. Extract functions that operate on the data into the class
4. Test after each move

## Split Phase

**Motivation**: Code dealing with two different things (e.g., parsing then processing).

**Mechanics**:
1. Extract second phase into its own function
2. Introduce intermediate data structure as argument
3. Examine parameters of second phase; move to intermediate structure
4. Apply Extract Function on first phase
5. Test

**Sketch**:
```
// Before
function priceOrder(product, quantity, shippingMethod) {
  const basePrice = product.basePrice * quantity;
  const discount = Math.max(quantity - product.discountThreshold, 0)
    * product.basePrice * product.discountRate;
  const shippingPerCase = (basePrice > shippingMethod.discountThreshold)
    ? shippingMethod.discountedFee : shippingMethod.feePerCase;
  const shippingCost = quantity * shippingPerCase;
  return basePrice - discount + shippingCost;
}

// After
function priceOrder(product, quantity, shippingMethod) {
  const priceData = calculatePricingData(product, quantity);
  return applyShipping(priceData, shippingMethod);
}
```

## Move Function

**Motivation**: Function references more elements of another context than its current one.

**Mechanics**:
1. Examine everything the function uses in current context
2. Check if function is polymorphic
3. Copy function to target context
4. Adjust function to fit new home (rename, adjust parameters)
5. Create reference from source to target
6. Turn source function into delegating function
7. Test
8. Consider inlining the delegating function

## Move Field

**Motivation**: Field is used more by another class, or field needs to move when moving functions.

**Mechanics**:
1. Ensure field is encapsulated
2. Create field (and accessors) in target
3. Adjust source accessors to use target field
4. Test
5. Remove field from source

## Replace Conditional with Polymorphism

**Motivation**: Switch statement that tests type code, or conditional logic based on type.

**Mechanics**:
1. If conditional isn't already isolated, use Extract Function
2. If conditional is in superclass, create subclasses for each type
3. Create method in superclass that hosts conditional
4. For each leg of conditional, override method in corresponding subclass
5. Leave default case in superclass, or make abstract
6. Test after each override

**Sketch**:
```
// Before
function plumage(bird) {
  switch (bird.type) {
    case 'EuropeanSwallow': return 'average';
    case 'AfricanSwallow': return bird.numberOfCoconuts > 2 ? 'tired' : 'average';
    case 'NorwegianBlueParrot': return bird.voltage > 100 ? 'scorched' : 'beautiful';
  }
}

// After
class Bird {
  get plumage() { return 'unknown'; }
}

class EuropeanSwallow extends Bird {
  get plumage() { return 'average'; }
}

class AfricanSwallow extends Bird {
  get plumage() { return this.numberOfCoconuts > 2 ? 'tired' : 'average'; }
}

class NorwegianBlueParrot extends Bird {
  get plumage() { return this.voltage > 100 ? 'scorched' : 'beautiful'; }
}
```

## Decompose Conditional

**Motivation**: Complex conditional logic that's hard to follow.

**Mechanics**:
1. Apply Extract Function on condition
2. Apply Extract Function on then-leg
3. Apply Extract Function on else-leg
4. Test

**Sketch**:
```
// Before
if (date.before(SUMMER_START) || date.after(SUMMER_END))
  charge = quantity * winterRate + winterServiceCharge;
else
  charge = quantity * summerRate;

// After
if (isSummer(date))
  charge = summerCharge(quantity);
else
  charge = winterCharge(quantity);
```

## Replace Nested Conditional with Guard Clauses

**Motivation**: Conditional with one leg that's the normal case and others that are unusual.

**Mechanics**:
1. Select outermost condition to replace
2. If condition is unusual, use it as guard clause (return early)
3. Test
4. Repeat for remaining conditions

**Sketch**:
```
// Before
function getPayAmount() {
  let result;
  if (isDead)
    result = deadAmount();
  else {
    if (isSeparated)
      result = separatedAmount();
    else {
      if (isRetired)
        result = retiredAmount();
      else
        result = normalPayAmount();
    }
  }
  return result;
}

// After
function getPayAmount() {
  if (isDead) return deadAmount();
  if (isSeparated) return separatedAmount();
  if (isRetired) return retiredAmount();
  return normalPayAmount();
}
```

## Replace Loop with Pipeline

**Motivation**: Collection processing that's hard to follow in loop form.

**Mechanics**:
1. Create variable for the collection
2. Start with first loop operation, convert to pipeline
3. Test
4. Continue with next operation
5. Test after each conversion

**Sketch**:
```
// Before
const names = [];
for (const i of input) {
  if (i.job === 'programmer')
    names.push(i.name);
}

// After
const names = input
  .filter(i => i.job === 'programmer')
  .map(i => i.name);
```

## Remove Dead Code

**Motivation**: Code that's never executed adds confusion without benefit.

**Mechanics**:
1. Verify code is not called (use static analysis, search, tests)
2. Delete the code
3. Test

> "When you see dead code, delete it. Don't comment it out; just delete. If you might need it again, you have version control."
