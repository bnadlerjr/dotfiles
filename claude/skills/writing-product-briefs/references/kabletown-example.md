# Product Brief for Kabletown Support Assistant

Our automated support agent, Helpy McHelpface, will revolutionize technical and account support at Kabletown.

## Product Thesis

We make two basic claims:

**Reduced user frustration**
Users are frustrated with our current assistant, who does a poor job on most requests and does not even understand when to delegate to a human agent, getting this wrong 80% of the time. Helpy McHelpface will handle direct communication with customers better than the old technology because it understands users' intent better, lowering user frustration.

**Lowered support toil**
Today's assistant must bring in a human whenever it wants to make a change. By giving Helpy tools to make changes to accounts, create appointments, or order shipped packages, we can automate up to more than half of the remaining unautomated support volume. By speeding up these routine-but-toilsome actions, we can dramatically improve wait times and user happiness while easing the backlog for our support representatives.

## Antithesis/Risks

What might cause this to not work as we expect?

- Helpy will take actions that it shouldn't, causing users to be unpleasantly surprised.
- We won't be able to achieve this with an assistant as opposed to an autonomous planning agent, increasing costs to build and run.
- Our knowledge base isn't good enough to provide the context that Helpy needs.

## Target Audience

We have two target personas, though we may start with one or the other:

**Account support user**
Tinker Tia is a longtime Kabletown internet and cable TV customer who wants to make changes to her account, such as upgrading or downgrading her service or adding or upgrading hardware.

**Technical support user**
Sad Lisa is a newly joined Kabletown internet customer who has something not working and wants to get it fixed.

## Product Goals

Our primary goals are to increase user happiness and improve our support backlog without hiring a bunch more people. We think we can do both at the same time. We're not aiming to improve profitability in the short term.

**Adoption metric**
Increase the number of fully automated support interactions from 15% to 65%.

**Value metric**
Improve customer satisfaction ratings after assistant and human support interactions from 2.1 to 3.5 (out of 5).

**KPI**
Profit-neutral. While we hope to reduce expenses on human support over time, we may also lower revenue by, for example, making it easier to downgrade users' plans. We will track downgrades to understand revenue impact.

## North Star Scenarios

**Cable box installation**
Tinker Tia wants to obtain a new cable box for a second TV she's put in her bedroom. She goes to kabletown.com on her laptop and finds Helpy. He agrees to help and asks whether she will require assistance from an installer, and she says she will. It guides her through the changes to her plan, gets her agreement, and kicks off a shipping order. It pings the chat when the order ships, and Tia gets notified that it's time to schedule the installation appointment. Helpy works with her to establish her time constraints and set up an appointment for after the shipment is scheduled to arrive. Once the technician reports the install was complete, Helpy will check back with her to do a survey.

**Downgrade**
Tinker Tia has two cable boxes but never uses the one attached to the TV in her bedroom, and she wants to reduce her monthly bill. Helpy searches for a subscription plan that is like hers, but without the extra cable box, and proposes it to her along with the cost savings she will receive. She okays this plan and Helpy tells her that the reduction will be processed as soon as she returns the box. She okays that, so he sends her packaging in which to ship the device. She ships it and he sends her a survey after it's received.

**Angry customer with account change**
Tinker Tia never uses the cable box in one of her rooms, and she wants to reduce her monthly bill. She goes to check on her account and finds a link to Helpy. She asks Helpy, who notices she's on a promotional rate and informs her there's no plan she can move to that will save her money. She gets upset and demands to talk to a supervisor. A support rep inherits the chat from Helpy and takes it over. They are able to arrange a small one-time discount for her in return for returning the cable box. She approves and receives a survey.

**Outage**
Sad Lisa's cable internet has stopped working. She opens the Kabletown app on her phone--on her still working wireless plan--sees the Helpy button, and asks Helpy what's going on. Helpy checks her address against the outage map, discovers there's an outage, and sends her an ETA. When it's resolved, it follows up to let her know, along with a satisfaction survey.

**Customer hardware problem**
Sad Lisa's internet is slow, and she blames Kabletown. She sees the Helpy "get support" button at kabletown.com and clicks it. Helpy asks her questions about her setup, discovering that she's on a PC laptop on wireless. It figures out there's no outage, so it guides her through a series of diagnostics and suggestions, starting with the ones that have worked the most in the past, including resetting her wireless router, running Windows network diagnostics, and so forth. Resetting her Kabletown-supplied wireless router does the trick. Helpy tells her to contact it if the problem keeps happening (e.g. in case it's a faulty router), then sends her a survey, and she gives strong ratings.

---

## Analysis: Why This Example Works

### Thesis Claims
- **Specific**: "getting this wrong 80% of the time" gives a baseline
- **Falsifiable**: If frustration doesn't decrease, the claim fails
- **Mechanism explained**: "because it understands users' intent better"

### Risks
- Each risk could invalidate a thesis claim
- Risks are specific enough to watch for
- Includes technical risk (assistant vs. agent), data risk (knowledge base), and UX risk (wrong actions)

### Personas
- Memorable names (Tinker Tia, Sad Lisa) that hint at situation
- Distinct segments (account vs. technical support)
- Clear primary goals for each

### Metrics
- Adoption: 15% → 65% (specific baseline and target)
- Value: 2.1 → 3.5 satisfaction (outcome-focused)
- Business: Honest about potential downside (easier downgrades)

### Scenarios
1. **Cable box installation**: Happy path for Tinker Tia, multi-step journey
2. **Downgrade**: Another happy path, tests the "lowered toil" claim
3. **Angry customer**: Failure/escalation case, shows handoff to human
4. **Outage**: Happy path for Sad Lisa, different problem type
5. **Hardware problem**: Diagnostic journey, tests knowledge base

Each scenario ends with value capture (survey).
