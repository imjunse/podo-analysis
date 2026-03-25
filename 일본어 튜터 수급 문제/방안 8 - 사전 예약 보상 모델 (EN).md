---
created: 2026-03-24
updated: 2026-03-25
tags:
  - tutor-supply
  - japanese
  - churn-prevention
  - booking
  - incentive
  - demand-distribution
status: planning
parent: "[[문제 분석 및 해결 방안]]"
tier: 1
priority: high
---

# Solution 8: Advance Booking Reward Model

> Parent doc: [[문제 분석 및 해결 방안]]
> Difficulty: Medium | Timeline: ~2-3 weeks | Expected impact: High

---

## 1. Problem Redefinition: Why Last Minute Booking Is a Problem

### 1-1. Booking Map Findings (Week of 2026-03-23)

| Category | Available Slots | Status |
|----------|----------------|--------|
| Mon/Tue (today~tomorrow) | 0-10 | Red/Pink (nearly full) |
| Wed-Sun (2+ days out) | 12-48 | Green (plenty available) |
| 0 Tutor time slots | Mon: 14, Tue: 23 | No tutors scheduled at all |

**Key pattern:** Sufficient availability exists 2+ days out, but same-day/next-day rush causes full booking.

### 1-2. Root Cause of Last Minute Booking

```
Current policy: Booking available up to 1 hour before class

Reality for Korean office workers:
  09:00 Start work
  ... meetings, overtime uncertainty ...
  18:00 "Looks like I'll finish by 7pm" → tries to book 7:30 class
  → Already fully booked → frustration/churn
```

- Not student "laziness" but a **rational response to unpredictable work schedules**
- Previous 12-hour advance booking policy eliminated rush, but was **relaxed to 1 hour for user convenience**

### 1-3. Why "Reward" Not "Enforce"

| Approach | Effect | Risk |
|----------|--------|------|
| Enforce 6-12hr advance booking | Reduces rush | Accelerates churn (more students unable to book) |
| **Reward** advance booking | Gradual distribution | No churn (existing UX maintained) |

> **Principle: Never degrade existing user experience. Instead, provide clear advantages for advance booking to drive behavior change.**

---

## 2. Core Hypothesis

> "By providing tangible rewards for advance booking (peak time slot priority, cancellation flexibility), students will gradually book earlier, reducing peak-time full-booking frequency."

**Key Metrics:**
- Advance booking (12hr+) rate change
- Peak-time (19-23h) full-booking frequency change
- Overall booking success rate change
- Refund rate change (booking-related)
- Retention change (advance bookers vs last-minute bookers)

---

## 3. System Constraints

### 3-1. Random Matching System

The current app uses **random/algorithmic tutor assignment** — students cannot select specific tutors.

→ Previously considered "tutor selection" and "tutor designation" rewards are **not feasible** given the system architecture.

### 3-2. Current Cancellation Policy (from codebase)

| Time Window | Status | Result |
|-------------|--------|--------|
| **2+ hours** before | `CANCEL` | Free cancellation (credit restored + rebooking) |
| **1-2 hours** before | `CANCEL` | Credit deducted / Unlimited plan: 72hr booking ban |
| **Within 1 hour** | `CANCEL_PAID` | Credit deducted / Unlimited plan: 72hr booking ban |
| **No-show** | `NOSHOW_S` | 24hr booking ban (reduced from 72hr) |

> Reference: [[정규 수업 예약 및 취소 정책]]

---

## 4. Reward System Design (v2)

### 4-1. Advance Booking Reward Tiers

```
┌──────────────────────────────────────────────────────────┐
│              Advance Booking Reward Tiers (v2)            │
│                                                          │
│  🥉 1hr before    → Same as current (no restrictions)    │
│  🥈 6hr+ before   → Peak time slot priority              │
│  🥇 12hr+ before  → Peak priority + free cancel up to    │
│                      1hr before class                     │
│  💎 24hr+ before  → All benefits + highest priority       │
│                                                          │
│  ⚡ Key: Existing 1hr-before booking remains unchanged!  │
│     Nothing taken away — earlier booking = more benefits  │
└──────────────────────────────────────────────────────────┘
```

### 4-2. Reward Details

#### Reward 1: Peak Time Slot Priority (6hr+ advance)

**Concept:** Reserve a portion of peak-time (19-23h) slots for advance bookers

```
[Tutor A's 20:00 slot]

12hr+ advance booking: Opens at 8:00 AM
6hr+ advance booking:  Opens at 2:00 PM
1hr before booking:    Opens at 7:00 PM (remaining slots only)
```

**Implementation: "Staggered Release"**

```
Peak-time slots = assume 30 total

Phase 1 (24hr+ before class): 10 of 30 (33%) open
  → 24hr+ advance bookers get first access

Phase 2 (12hr+ before class): Additional 10 (33%) open
  → 12hr+ advance bookers get access

Phase 3 (6hr+ before class): Additional 5 (17%) open

Phase 4 (1hr+ before class): Remaining 5 (17%) open
  → Last-minute bookers can still book (fewer slots)
```

**Why this works:**
- What students want most is "booking at their preferred time"
- Securing preferred time slots = high perceived value (zero cost)
- "Book early = get the time you want" → powerful motivation
- Only requires slot release logic changes — no new system needed

#### Reward 2: Extended Cancellation Flexibility (12hr+ advance bookers)

**Current policy:** All bookings — free cancellation up to 2 hours before class
**Change:** 12hr+ advance bookers — free cancellation up to 1 hour before class

```
┌─────────────────────────────────────────────────────┐
│              Cancellation Policy Comparison           │
│                                                      │
│  Regular booking:        Free cancel 2hr+ before     │
│  Advance booking (12h+): Free cancel 1hr+ before     │
│                                                      │
│  * Tutor confirmed: 1hr-before cancellation is OK    │
│  * No-show penalty (24hr ban) remains unchanged      │
└─────────────────────────────────────────────────────┘
```

**Why this is the key reward — Office Worker Scenario:**

```
[Current] Advance booking carries risk:
  Monday night: Books Tuesday 20:00 class
  Tuesday 18:00: "Overtime confirmed" → past 2hr cutoff → can't cancel free
  → Credit deducted or 72hr booking ban 💀
  → Conclusion: "Advance booking = risky" → only books same-day

[After change] Advance booking is safe:
  Monday night: Advance-books Tuesday 20:00 class (12hr+ ahead)
  Tuesday 19:00: "Overtime confirmed" → still within 1hr window → free cancel ✅
  → Slot reopens at 19:00 → another student can grab it
  → Tutor has 1hr notice — acceptable
  → Conclusion: "Advance booking is safe" → barrier removed
```

**Strengths of this reward:**
- Directly removes the **biggest psychological barrier** to advance booking (overtime uncertainty)
- Zero cost (only extends free cancellation window by 1 hour)
- Tutors confirmed 1-hour-before cancellation is acceptable
- Cancelled slots immediately reopen → available for other last-minute students

---

## 5. Staggered Release — Detailed Design

### 5-1. Why Staggered Release

**Current problem:**
```
All slots available from 1 hour before class simultaneously
→ Students leaving work at 18:00 rush 19-23h slots at once
→ Fully booked within 10 minutes
→ Student arriving at 18:15 finds everything sold out
```

**After staggered release:**
```
8:00 AM:  33% of peak slots open → captures pre-work bookers
2:00 PM:  Additional 33% open → captures lunch-break bookers
6:00 PM:  Additional 17% open → captures post-work bookers
7:00 PM:  Remaining 17% open → last-minute still possible

→ Full-booking shifts from "all at 18:00" to "gradual throughout the day"
→ Reframes from "if I miss it, it's over" to "next time I'll book earlier"
```

### 5-2. Slot Allocation Ratios

| Phase | Opens At | Ratio | Target Students | Reward |
|-------|----------|-------|-----------------|--------|
| Early Bird | 24hr+ before | 30% | Planners | Slot priority + cancel flexibility |
| Planner | 12hr+ before | 30% | Morning bookers | Slot priority + cancel flexibility |
| Same-day | 6hr+ before | 20% | Afternoon bookers | Slot priority |
| Last Minute | 1hr+ before | 20% | Post-work bookers | Standard booking (remaining) |

**Note:** Ratios are initial values. Adjust every 2 weeks based on actual booking pattern data.

### 5-3. Off-Peak Hours

Staggered release applies to **peak hours (19-23h) only**.

Off-peak (10-18h) has sufficient supply — maintains existing 1-hour-before booking.

```
Peak (19:00-23:30):    Staggered release applied
Off-peak (10:00-18:30): Existing 1hr-before booking maintained
```

---

## 6. UX Design

### 6-1. Booking Screen Changes

**Current booking screen:**
```
Tue 3/25
19:00  [Book]
19:30  [Book]
20:00  [Full]
20:30  [Full]
21:00  [Book]
```

**Updated booking screen:**
```
Tue 3/25

19:00  [Book]
19:30  [Book]
20:00  [Full] → 🔔 Waitlist alert (Solution 1 integration)
20:30  ⭐ Advance booking only (opens 12hr before)
       "Available tomorrow at 8:30 AM!"
21:00  [Book]
21:30  ⭐ Advance booking only (opens tomorrow 2:00 PM)
```

### 6-2. "Why Book Ahead" Nudge

Onboarding message for first-time advance booking:

```
┌─────────────────────────────────────────────┐
│  💡 Did you know?                           │
│                                              │
│  Booking ahead unlocks extra benefits!       │
│                                              │
│  ⭐ 6hr ahead → Priority for popular times  │
│  ⭐ 12hr ahead → Free cancel up to 1hr      │
│     before class!                            │
│                                              │
│  [Book tomorrow's class now]                 │
└─────────────────────────────────────────────┘
```

### 6-3. Booking Confirmation Reinforcement

```
"⭐ Advance booking confirmed! You've secured a popular time slot."
"Since you booked 12hr+ ahead, you can cancel free up to 1hr before class!"
```

→ "Thanks to booking early" framing = reinforces advance booking behavior

### 6-4. Nudge for Last-Minute Bookers

```
[When 20:00 slot is full]

"This time slot was filled by advance bookers."
"Next time, book ahead to secure popular times!"
"Advance bookers also get flexible cancellation (free up to 1hr before)"

[Book tomorrow's class]  [View other times]  [Waitlist alert (Solution 1)]
```

→ "Filled by advance booking" not "fully booked" = **teaches the next behavior (book early)**

---

## 7. Behavioral Economics Design Principles

### 7-1. Loss Aversion

```
❌ "Book early for a bonus" (gain framing)
✅ "This time slot is assigned to advance bookers first" (loss framing)
```

"If I don't do it, someone else gets it first" → stronger motivation

### 7-2. Default Effect

```
Post-class auto-popup:
"Want to book your next class in advance?"
[Same time tomorrow] [This Friday] [Later]
```

→ Right after class = highest motivation to book next session

### 7-3. Risk Reversal

```
❌ "Book in advance!" (what if I have overtime? → anxiety)
✅ "Book ahead — free cancel up to 1hr before if plans change!" (risk removed)
```

→ Directly addresses the #1 barrier to advance booking (schedule uncertainty)

### 7-4. Social Proof

```
"78% of students who booked this time used advance booking"
"3 students have already advance-booked tomorrow's 20:00 class"
```

### 7-5. Endowed Progress

```
[Advance Booking Habit Tracker]

"This month's advance bookings: 🟢🟢🟢⚪⚪⚪⚪⚪ (3/8)"
"Reach 5 to get premium time priority next month!"
```

---

## 8. Tutor-Side Impact

### 8-1. What Changes for Tutors

**Almost nothing.** This is the biggest advantage of this solution.

| Item | Change |
|------|--------|
| Tutor compensation | No change |
| Schedule management | No change |
| Teaching method | No change |
| Student matching logic | No change (random matching maintained) |
| 1hr-before cancellation | Acceptable (tutor-confirmed) |

### 8-2. Positive Impact on Tutors

- **Fewer cancellations**: Advance bookers cancel less than last-minute bookers (psychological commitment)
- **Better schedule predictability**: 30-60% filled a day ahead = easier for tutors to plan
- **1hr-before cancellations reopen slots**: Even if cancelled, another student can grab it — minimizes empty slots

### 8-3. Tutor Schedule Opening Synergy

Current problem: If tutors open schedules late, advance booking is impossible

**Mitigation:**
- Notify tutors: "Open tomorrow's schedule by tonight — advance-booking students will be assigned immediately"
- Add "24hr advance schedule opening" bonus to [[방안 2 - 주간 일관성 보너스]]

---

## 9. Demand Distribution Simulation

### 9-1. Current Booking Time Distribution (Estimated)

```
Booking time distribution (peak 19-23h):
  24hr+ before:   10%
  12hr+ before:   10%
  6hr+ before:    15%
  1-6hr before:   25%
  Within 1hr:     40%  ← full booking happens here
```

### 9-2. Expected Distribution After Rewards

```
Target distribution (3 months out):
  24hr+ before:   25%  (+15pp)  ← cancel flexibility + priority incentive
  12hr+ before:   20%  (+10pp)  ← cancel flexibility incentive
  6hr+ before:    20%  (+5pp)   ← time slot priority
  1-6hr before:   20%  (-5pp)
  Within 1hr:     15%  (-25pp)  ← significant reduction
```

### 9-3. Full-Booking Frequency Projection

```
Current: 30 peak-time slots consumed between 18:00-19:00 (1 hour)
  → Arriving at 18:15 = already sold out (perceived full-booking rate ~80%)

After change: 30 slots consumed gradually throughout the day
  - By morning: 9 consumed (30%)
  - By afternoon: 18 consumed (60%)
  - By 18:00: 24 consumed (80%)
  - By 19:00: 6 remaining (20%)
  → Arriving at 18:15 = 6 still available (perceived full-booking rate ~30%)
```

**Same supply (30) but perceived full-booking drops from 80% → 30%.**

### 9-4. Honest Limitations of This Solution

```
⚠️ Solution 8 distributes WHEN slots fill — it does NOT solve absolute supply shortage.

If demand = 50 students vs supply = 30 slots:
  Current:     30 consumed at 18:00 → 20 students can't book
  Solution 8:  30 consumed throughout day → still 20 can't book

→ Demand ≈ Supply (slight shortage): Solution 8 alone significantly improves perception
→ Demand >> Supply (severe shortage): Must combine with supply expansion solutions
```

---

## 10. Phased Rollout Strategy

### 10-1. Phase 0: Data Collection (1 week)

Establish accurate baseline of current booking patterns

- [ ] Collect booking time distribution data (how many hours before class was it booked)
- [ ] Analyze booking-to-sellout timing by time slot and day of week
- [ ] Compare retention/cancellation rates: advance bookers vs last-minute bookers
- [ ] Student survey: "When do you usually book? Would advance booking benefits interest you?"

### 10-2. Phase 1: Soft Launch — Cancellation Flexibility Only (2 weeks)

**No staggered release yet** — only introduce cancellation flexibility to drive behavior change

- [ ] For 12hr+ advance bookings, extend free cancellation from 2hr → 1hr before class
- [ ] Add "Book your next class ahead" nudge after class completion
- [ ] Display "Free cancellation up to 1hr before" for advance bookings
- [ ] Monitor advance booking rate changes

**If Phase 1 already shows significant increase in advance booking → Phase 2 may be unnecessary.**

### 10-3. Phase 2: Staggered Release (2 weeks)

If Phase 1 rewards alone don't sufficiently distribute demand

- [ ] Apply staggered release to peak-time slots (30/30/20/20 ratio)
- [ ] Show "Advance booking only" slot UI
- [ ] Display "Filled by advance booking" message for last-minute bookers
- [ ] Measure full-booking frequency changes

### 10-4. Phase 3: Optimization (ongoing)

- [ ] Data-driven optimization of staggered release ratios
- [ ] Advance booking habit tracker / gamification
- [ ] Monthly "advance booking champion" badge

---

## 11. Success/Failure Criteria

### Phase 1 (Cancellation Flexibility) — After 2 Weeks

| Metric | Target | Failure Threshold |
|--------|--------|-------------------|
| Advance booking (12hr+) rate | +10pp vs baseline | No change |
| Cancel flexibility awareness | 70%+ of advance bookers | Below 30% |
| Total booking volume | Maintained or increased | **Decreased** (side effect) |
| Last-minute booking rate | -5pp or more | Increased |

### Phase 2 (Staggered Release) — After 2 Weeks

| Metric | Target | Failure Threshold |
|--------|--------|-------------------|
| Peak-time full-booking frequency | -30% | No change |
| Overall booking success rate | +15% | No change |
| Remaining slots 1hr before class | 5+ (currently 0) | Below 2 |
| Booking-related refunds | -20% | Increased |

### Long-term (3 months)

| Metric | Target |
|--------|--------|
| Advance booking rate (12hr+) | 30%+ |
| Perceived peak-time full-booking rate | Below 30% (currently ~80% est.) |
| Monthly booking-related refunds | Below ₩3M (currently ₩4.98M pace) |

---

## 12. Edge Cases

### 12-1. Cancellation Abuse (Slot Hoarding → Cancel → Rebook)

- Cancel flexibility could enable "book just in case, cancel later" pattern
- **Mitigation:** Cancelled advance-booking slots immediately return to general pool
- **Pattern detection:** Students with 30%+ advance-cancel rate lose flexibility benefit
- **Key:** No-show penalty (24hr ban) remains unchanged → no-show deterrent intact

### 12-2. Advance-Only Slots Not Filling

- If Phase 1 (24hr-ahead) slots remain empty → convert to general pool at Phase 2 cutoff
- **Never leave slots empty** → prevents supply waste

```
10 slots opened 24hr ahead, only 3 booked
→ At 12hr mark, remaining 7 merge into general pool
→ Effective 12hr pool = 7 + 10 = 17 slots
```

### 12-3. Tutors Opening Schedules Late

- Tutors who haven't opened schedules 24hr ahead → their slots are not part of staggered release
- Those slots enter general pool whenever they open
- **Mitigate via Solution 2 (weekly consistency bonus) — add "24hr schedule opening" bonus**

### 12-4. Off-Peak Requests

- Cancellation flexibility applies to advance bookings at all times (incentive consistency)
- Staggered release only applies to peak hours (off-peak has sufficient supply)

### 12-5. 1hr-Before Cancellation → Slot Reopens Too Late?

- Slots cancelled 1hr before immediately reopen → opportunity for last-minute bookers
- Actually **better than current state**: Currently students fear penalty → no-show → slot completely wasted
- After change: Free cancel → slot recycled to another student

---

## 13. Risks and Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Last-minute user churn (fewer slots left) | Medium | High | Guarantee 20% reserve, test Phase 1 (flexibility only) first |
| Advance booking abuse (hoard → cancel) | Medium | Medium | Pattern detection, restrict flexibility for repeat offenders |
| Advance-only slots unfilled → supply waste | Medium | Medium | Auto-convert to general pool at next phase |
| Tutors open schedules late → staggered release ineffective | Medium | High | Tie to Solution 2 bonus |
| System complexity increase | Medium | Medium | Phase 1 (cancel flexibility) is very simple; Phase 2 (staggered) only if needed |

---

## 14. Economic Analysis

### 14-1. Costs

| Item | Cost |
|------|------|
| Development (Phase 1) | ~0.5 week (cancellation policy branching + nudge UI) |
| Development (Phase 2) | ~2 weeks (staggered release logic + slot management) |
| Operating cost | None (automated) |
| Additional tutor cost | **None** (no supply structure changes) |

### 14-2. Expected Revenue Impact

| Item | Conservative | Optimistic |
|------|-------------|-----------|
| Reduced full-booking perception → fewer refunds | ₩1.5M/mo | ₩4M/mo |
| Improved retention (advance bookers retain better) | ₩1M/mo | ₩3M/mo |
| Fewer cancellations (advance booking = higher commitment) | ₩0.5M/mo | ₩1M/mo |
| **Monthly total** | **₩3M/mo** | **₩8M/mo** |

### 14-3. ROI

- Development cost: One-time ~2.5 weeks of engineering
- Operating cost: ₩0/month
- **Revenue: ₩3-8M/month → payback within 1 month**

---

## 15. Synergy Map with Other Solutions

| Connected Solution | Synergy | Specific Connection |
|-------------------|---------|---------------------|
| [[방안 1 - 웨이팅리스트 + 알림 시스템]] | **High** | Last-minute sold out → waitlist + "book ahead next time" nudge |
| [[방안 2 - 주간 일관성 보너스]] | **High** | Tutor "24hr schedule opening" bonus secures advance-bookable slots |
| [[방안 3 - 예약 가능 시간대 사전 공지]] | **Very High** | Evening notification: "Tomorrow's advance booking slots available" → drives early booking |
| [[방안 4 - 개인화 이메일 자동화]] | **High** | "Book tomorrow's class now (free cancel up to 1hr before!)" email |
| [[방안 7 - AI 보조 하이브리드 수업]] | Medium | Advance bookers get AI pre-study time |

---

## 16. Why This Solution Is Special

Solutions 1-7 mostly intervene on the **supply side (tutors)**. This solution:

1. **Changes demand-side (student) behavior** → same supply, dramatically reduced perceived full-booking
2. **Zero tutor policy changes** → zero tutor churn risk
3. **Zero cost** → policy differentiation, not monetary incentives
4. **Easy to revert** → if Phase 1 doesn't work, just turn it off
5. **Builds data** → precisely maps booking time distribution
6. **Random matching preserved** → no app architecture changes needed

> **Core framing: "Book early = secure your preferred time + cancel freely" — giving more, not taking away.**
