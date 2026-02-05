# Deciding How Many Acceptance Criteria

None of the major voices prescribe a fixed number—the right count depends on the
story. These heuristics help:

| Signal | Action |
|--------|--------|
| Criteria have similar priority and story fits a sprint | Add criteria to the story (Cohn) |
| Criteria have different priorities | Split the story (Cohn) |
| Story feels too large for one sprint | Split the story (Cohn: SPIDR) |
| Areas where misunderstanding is likely | Add concrete examples (Shore) |
| Areas where the team already agrees | Skip formal criteria—conversation suffices (Shore) |
| Each criterion needs at least one test | Minimum one acceptance test per criterion (Farley) |

## Expert Perspectives

**Farley**: Keep stories as small as possible. Focus on a small unit of behavior.
At minimum, one acceptance test per criterion—usually more.

**Cohn**: Acceptance criteria include only things so important the product owner
would reject the story if unmet. They are a "table of contents into a test plan,"
not the test plan itself.

**Shore**: Focus examples on areas of potential misunderstanding. Not everything
needs formal criteria. Specificity matters more than coverage—concrete examples
with named characters and real values reveal edge cases that abstractions hide.

## Sources

- Farley, D. *Modern Software Engineering* (2021); [Acceptance Testing for Continuous Delivery](https://thinkinglabs.io/notes/2021/07/18/acceptance-testing-for-continuous-delivery-dave-farley.html); [Strategies for Effective Acceptance Testing](https://www.davefarley.net/?p=190)
- Cohn, M. *User Stories Applied* (2004); [The Two Ways to Add Detail](https://www.mountaingoatsoftware.com/blog/the-two-ways-to-add-detail-to-user-stories); [How Detailed Should a User Story Be?](https://www.mountaingoatsoftware.com/blog/what-level-of-detail-should-be-captured-in-a-user-story); [SPIDR](https://www.mountaingoatsoftware.com/blog/five-simple-but-powerful-ways-to-split-user-stories)
- Shore, J. *The Art of Agile Development* (2007, 2nd ed. 2021); [The Problems With Acceptance Testing](https://www.jamesshore.com/v2/blog/2010/the-problems-with-acceptance-testing); [Alternatives to Acceptance Testing](http://www.jamesshore.com/v2/blog/2010/alternatives-to-acceptance-testing)
