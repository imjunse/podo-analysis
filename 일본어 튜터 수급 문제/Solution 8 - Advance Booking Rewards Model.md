---
created: 2026-03-24
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

# Solution 8: Advance Booking Rewards Model

> Parent doc: [[문제 분석 및 해결 방안]]
> Difficulty: Medium | Timeline: ~2-3 weeks | Expected Impact: High

---

## 1. Problem Reframing: Why Last-Minute Booking Is the Problem

### 1-1. Findings from the Booking Map (Week of 2026-03-23)

| Timeframe | Available Slots | Status |
|-----------|----------------|--------|
| Mon/Tue (today~tomorrow) | 0–10 | Red/pink (nearly full) |
| Wed–Sun (2+ days out) | 12–48 | Green (plenty available) |
| 0-Tutor time slots | Mon: 14, Tue: 23 | No tutors scheduled at all |

**Key pattern:** Sufficient availability exists 2+ days out, but same-day/next-day demand surge causes full booking.

### 1-2. Root Cause of Last-Minute Booking

```
Current policy: Students can book up to 1 hour before the lesson

Reality for Korean office workers:
  09:00  Start work
  ...    Meetings, uncertain overtime schedule...
  18:00  "Looks like I'll be free by 7pm" → Tries to book 7:30pm lesson
  →      Already fully booked → Frustration / churn
```

- This isn't "laziness" — it's a **rational response to unpredictable work schedules**
- The previous 12-hour advance booking policy had no surge issues, but it was **relaxed to 1 hour for user convenience**

### 1-3. Why "Rewards" Instead of "Restrictions"

| Approach | Effect | Risk |
|----------|--------|------|
| **Enforce** 6–12hr advance booking | Reduces surge | Accelerates churn (students can't book at all) |
| **Reward** advance booking | Gradual distribution | Zero churn risk (existing experience preserved) |

> **Principle: Never degrade the existing user experience. Instead, provide clear advantages for advance booking to drive behavioral change.**

---

## 2. Core Hypothesis

> "If we offer tangible rewards for advance booking (tutor selection, priority access to peak slots), students will gradually shift their booking timing earlier, reducing peak-hour full-booking frequency."

**Key Metrics:**
- Advance booking (6hr+) rate change
- Peak-hour (19:00–23:00) full-booking frequency change
- Overall booking success rate change
- Refund rate change (booking-related)
- Retention: advance bookers vs. last-minute bookers

---

## 3. Reward Tier Design

### 3-1. Time-Based Reward Tiers

```
┌──────────────────────────────────────────────────────────────┐
│              Advance Booking Reward Tiers                      │
│                                                                │
│  🥉 1hr before    → Same as today (no restrictions)           │
│  🥈 6hr+ before   → "Tutor Selection Priority"                │
│  🥇 12hr+ before  → "Peak Slot Priority Access" + Selection   │
│  💎 24hr+ before  → "Choose Your Tutor" + Priority Access     │
│                                                                │
│  ⚡ Key: Existing 1-hour booking stays exactly the same!      │
│     Nothing is taken away — booking earlier only adds benefits │
└──────────────────────────────────────────────────────────────┘
```

### 3-2. Reward Details

#### Reward 1: Tutor Selection Priority (6hr+ advance)

**Current:** Available tutors assigned by algorithm/random
**Change:** Booking 6hr+ ahead lets students browse tutor profiles and choose directly

```
[6hr+ Advance Booking Screen]

"⭐ Advance Booking Perk: Choose your tutor!"

┌─────────────────────────┐  ┌─────────────────────────┐
│ 🧑‍🏫 Tanaka-sensei        │  │ 🧑‍🏫 Sato-sensei          │
│ ⭐ 4.8 (324 lessons)    │  │ ⭐ 4.9 (215 lessons)    │
│ Strength: Pronunciation │  │ Strength: Grammar       │
│ [Book with this tutor]  │  │ [Book with this tutor]  │
└─────────────────────────┘  └─────────────────────────┘

vs.

[1hr Before Booking Screen]

"3/25 (Tue) 20:00 Booking"
[Book Now]  ← Tutor auto-assigned
```

**Why this works:**
- Students want to learn from "good tutors"
- Choice = high perceived value (actual cost: $0)
- "If I book earlier, I get the teacher I want" → powerful motivation

#### Reward 2: Peak Slot Priority Access (12hr+ advance)

**Concept:** Reserve a portion of peak-hour (19–23:00) slots for advance bookers

```
[Tutor A's 20:00 slot]

12hr+ advance booking available from: 8:00 AM
6hr+ advance booking available from:  2:00 PM
1hr before booking available from:    7:00 PM (remaining slots only)
```

**Implementation: "Staggered Release"**

```
Peak-hour slots = assume 30 total

Phase 1 (24hr+ before lesson): 10 of 30 (33%) released
  → Earliest bookers get first pick

Phase 2 (12hr+ before lesson): +10 (33%) released
  → Morning planners get next pick

Phase 3 (6hr+ before lesson): +5 (17%) released

Phase 4 (1hr+ before lesson): remaining 5 (17%) released
  → Last-minute bookers can still book (fewer spots)
```

**Effects:**
- "Booking early guarantees my spot" experience → reinforces future advance booking
- Last-minute users can still book (17% reserved) → prevents churn
- Full-booking perception decreases (gradual fill throughout the day)

#### Reward 3: Choose Your Tutor — Named Booking (24hr+ advance)

**Concept:** Booking a day ahead allows students to "name" a specific tutor

```
"I want to take a lesson with Tanaka-sensei tomorrow at 8pm"
→ If Tanaka-sensei's 8pm slot is open → instant confirmation
→ If not yet open → "Auto-book when Tanaka-sensei opens their schedule" setting
```

**Synergy:** Connects with Solution 4 (Personalized Tutor Emails)
- "Tanaka-sensei, [student name] wants to take your lesson tomorrow at 8pm"
- Named requests = powerful tutor motivation ("a student specifically wants me!")

---

## 4. Staggered Release — Detailed Design

### 4-1. Why Staggered Release

**Current problem:**
```
All slots become bookable 1 hour before the lesson
→ Students leaving work at 6pm rush 19–23:00 slots simultaneously
→ Fully booked within 10 minutes
→ Student arriving at 6:15pm sees everything sold out
```

**After Staggered Release:**
```
8:00 AM:  33% of peak slots open → Pre-work bookers secured
2:00 PM:  +33% open → Lunch-break bookers secured
6:00 PM:  +17% open → Post-work immediate bookers secured
7:00 PM:  Remaining 17% open → Last-minute still possible

→ Full-booking shifts from "all at once at 6pm" to "gradual fill throughout the day"
→ Reframing: "too late" becomes "I should've booked earlier" (learnable behavior)
```

### 4-2. Slot Allocation Ratios

| Phase | Release Time | Allocation | Target Student | Reward |
|-------|-------------|------------|----------------|--------|
| Early Bird | 24hr+ before lesson | 30% | Planners | Named tutor + priority selection |
| Planner | 12hr+ before lesson | 30% | Morning bookers | Tutor priority selection |
| Same-day | 6hr+ before lesson | 20% | Afternoon bookers | Basic booking |
| Last Minute | 1hr+ before lesson | 20% | Post-work bookers | Basic booking (remaining) |

**Note:** Ratios are starting values. Adjust every 2 weeks based on actual booking pattern data.

### 4-3. Off-Peak Hours

Staggered release applies to **peak hours (19:00–23:00) only**.

Off-peak (10:00–18:00) already has sufficient supply — keep the existing 1-hour policy.

```
Peak (19:00–23:30):    Staggered release applied
Off-peak (10:00–18:30): Existing 1-hour booking maintained
```

---

## 5. UX Design

### 5-1. Booking Screen Changes

**Current booking screen:**
```
3/25 (Tue)
19:00  [Book Now]
19:30  [Book Now]
20:00  [Sold Out]
20:30  [Sold Out]
21:00  [Book Now]
```

**Updated booking screen:**
```
3/25 (Tue)

19:00  [Book Now]
19:30  [Book Now]
20:00  [Sold Out] → 🔔 Notify me (Solution 1 integration)
20:30  ⭐ Advance-only (opens 12hrs before)
       "Available tomorrow at 8:30 AM!"
21:00  [Book Now]
21:30  ⭐ Advance-only (opens tomorrow 2:00 PM)
```

### 5-2. "Why Book Early" Nudge

First-time advance booking onboarding message:

```
┌─────────────────────────────────────────────────┐
│  💡 Did you know?                                │
│                                                  │
│  Booking early unlocks better lessons!           │
│                                                  │
│  ⭐ 6hr ahead → Choose your favorite teacher    │
│  ⭐ 12hr ahead → Priority peak-hour access      │
│  ⭐ 1 day ahead → Name your teacher!            │
│                                                  │
│  [Book tomorrow's lesson now]                    │
└─────────────────────────────────────────────────┘
```

### 5-3. Booking Confirmation Reinforcement

```
"⭐ Advance booking confirmed! Your lesson with Tanaka-sensei is set."
"Because you booked early, you got to choose your preferred teacher!"
```

→ "Thanks to booking early" framing = reinforces future advance booking

### 5-4. Last-Minute Booker Nudge

```
[When 20:00 slot is sold out]

"This time slot was filled by advance bookers."
"Next time, book ahead to secure popular time slots!"

[Book tomorrow's lesson now]  [View other times]  [🔔 Notify me (Solution 1)]
```

→ Not "sold out" but "filled by advance bookers" = **teaches the next action (book earlier)**

---

## 6. Behavioral Economics Design Principles

### 6-1. Loss Aversion

```
❌ "Book early and get a bonus!" (gain framing)
✅ "This time slot is assigned to advance bookers first" (loss framing)
```

"If I don't act, someone else gets it first" → stronger motivation

### 6-2. Default Effect

```
Post-lesson automatic popup:
"Want to book your next lesson in advance?"
[Same time tomorrow] [This Friday] [Later]
```

→ Right after a lesson = peak motivation to book the next one

### 6-3. Social Proof

```
"78% of students who booked this time slot used advance booking"
"2 students have already booked tomorrow's lesson with Tanaka-sensei"
```

### 6-4. Endowed Progress

```
[Advance Booking Habit Tracker]

"This month's advance bookings: 🟢🟢🟢⚪⚪⚪⚪⚪ (3/8)"
"Reach 5 to unlock premium time slot priority next month!"
```

---

## 7. Tutor-Side Impact

### 7-1. What Changes for Tutors

**Almost nothing.** This is the solution's biggest advantage.

| Item | Change |
|------|--------|
| Tutor compensation | No change |
| Schedule management | No change |
| Lesson format | No change |
| Student assignment logic | Minor change (advance bookers matched first) |

### 7-2. Positive Effects for Tutors

- **Fewer cancellations**: Advance bookers cancel less than last-minute bookers (psychological commitment)
- **Better schedule predictability**: If 30–60% of slots are filled a day ahead, tutors can plan better
- **Named bookings = motivation**: "A student specifically requested me" → higher lesson quality

### 7-3. Synergy with Tutor Schedule Opening Timing

Current issue: If tutors open their schedule late, advance booking is impossible

**Mitigations:**
- Notify tutors: "If you open tomorrow's schedule by this evening, advance-booked students will be matched immediately"
- Add "24hr advance schedule opening" bonus to [[방안 2 - 주간 일관성 보너스|Solution 2 (Weekly Consistency Bonus)]]
- When a student names a tutor, send notification: "○○ wants your lesson tomorrow" → encourages schedule opening

---

## 8. Demand Distribution Simulation

### 8-1. Current Booking Timing Distribution (Estimated)

```
Booking timing distribution (peak hours 19–23:00):
  24hr+ before:   10%
  12hr+ before:   10%
  6hr+ before:    15%
  1–6hr before:   25%
  Within 1hr:     40%  ← This is where full-booking occurs
```

### 8-2. Expected Distribution After Advance Booking Rewards

```
Target distribution (after 3 months):
  24hr+ before:   25%  (+15pp)  ← Named tutor incentive
  12hr+ before:   20%  (+10pp)  ← Peak slot priority
  6hr+ before:    20%  (+5pp)   ← Tutor selection
  1–6hr before:   20%  (-5pp)
  Within 1hr:     15%  (-25pp)  ← Significant reduction
```

### 8-3. Full-Booking Frequency Change Projection

```
Current: 30 peak-hour slots consumed entirely between 6–7pm
  → Student arriving at 6:15pm sees everything sold out
  → Perceived full-booking rate: ~80%

After change: 30 slots consumed gradually throughout the day
  - By morning: 9 consumed (30%)
  - By afternoon: 18 consumed (60%)
  - By 6pm: 24 consumed (80%)
  - At 7pm: 6 remaining (20%)
  → Student arriving at 6:15pm still sees 6 available slots
  → Perceived full-booking rate: ~30%
```

**Same supply (30 slots), but perceived full-booking drops from 80% → 30%.**

---

## 9. Phased Rollout Strategy

### 9-1. Phase 0: Data Collection (1 week)

Establish an accurate baseline of current booking patterns

- [ ] Collect booking timing distribution data (how many hours before lesson start was each booking made)
- [ ] Analyze booking-to-sellout timing by time slot and day of week
- [ ] Compare retention/cancellation rates: advance bookers vs. last-minute bookers
- [ ] Student survey: "When do you usually book? What would motivate you to book earlier?"

### 9-2. Phase 1: Soft Launch — Rewards Only (2 weeks)

**No staggered release yet** — introduce rewards only to drive behavioral change

- [ ] Enable "Tutor Selection Priority" for 6hr+ advance bookings
- [ ] Add "Book your next lesson in advance" post-lesson nudge
- [ ] Monitor advance booking rate changes
- [ ] Measure booking timing distribution shifts

**If Phase 1 already shows meaningful increase in advance bookings → Phase 2 may not be needed.**

### 9-3. Phase 2: Staggered Release (2 weeks)

Only if Phase 1 rewards alone don't achieve sufficient distribution

- [ ] Apply staggered release to peak-hour slots (30/30/20/20 ratio)
- [ ] Show "Advance booking only" slot UI indicators
- [ ] Display "Filled by advance bookers" message for last-minute users
- [ ] Measure full-booking frequency changes

### 9-4. Phase 3: Optimization (ongoing)

- [ ] Optimize staggered release ratios based on data
- [ ] Add Named Tutor Booking feature (24hr+ advance)
- [ ] Advance booking habit tracker / gamification
- [ ] Monthly "Advance Booking Champion" badge

---

## 10. Success/Failure Criteria

### Phase 1 (Rewards Only) — After 2 Weeks

| Metric | Target | Failure Threshold |
|--------|--------|-------------------|
| Advance booking (6hr+) rate | +10pp vs. baseline | No change |
| Tutor selection feature usage | 60%+ of advance bookers | Below 20% |
| Total booking volume | Maintained or increased | **Decreased** (side effect) |
| Last-minute booking rate | -5pp or more | Increased |

### Phase 2 (Staggered Release) — After 2 Weeks

| Metric | Target | Failure Threshold |
|--------|--------|-------------------|
| Peak-hour full-booking frequency | -30% | No change |
| Overall booking success rate | +15% | No change |
| Remaining slots at 1hr before lesson | 5+ (currently 0) | Below 2 |
| Booking-related refunds | -20% | Increased |

### Long-Term (3 Months)

| Metric | Target |
|--------|--------|
| Advance booking rate (24hr+) | 25%+ |
| Perceived peak-hour full-booking rate | Below 30% (currently ~80% est.) |
| Monthly booking-related refunds | Below KRW 3M (currently KRW 4.98M pace) |

---

## 11. Edge Cases

### 11-1. What if students book in advance, then cancel?

- Risk of gaming: reserve a good tutor → cancel → re-reserve
- **Mitigation:** Cancelled advance-booked slots return to the general pool immediately; same-day rebooking doesn't qualify for advance booking perks
- **Pattern detection:** Flag students with 30%+ advance booking cancellation rate

### 11-2. What if advance-only slots don't fill?

- If Phase 1 (24hr ahead) slots remain empty → auto-convert to general pool at Phase 2 timing
- **Never leave slots empty** → prevents supply waste

```
10 slots opened 24hr ahead → only 3 booked
→ At the 12hr mark, remaining 7 merge into general pool
→ Effective 12hr pool = 7 + 10 = 17 slots
```

### 11-3. What if tutors open their schedule late?

- Slots from tutors who haven't opened 24hr ahead are NOT part of staggered release
- Those slots enter the general pool from the moment they're opened
- **Use Solution 2 (Weekly Bonus) to add a "24hr advance schedule opening" bonus incentive**

### 11-4. What about off-peak requests?

- Even for off-peak, advance bookers still get tutor selection (incentive consistency)
- Staggered release only applies to peak hours (off-peak supply is sufficient)

---

## 12. Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Last-minute user churn (fewer available slots) | Medium | High | Guarantee 20% reserved for last-minute; Phase 1 tests rewards only first |
| Advance booking abuse (reserve → cancel → repeat) | Low | Medium | Cancel pattern detection; no perks on same-day rebooking |
| Advance-only slots go unfilled → supply waste | Medium | Medium | Auto-convert to general pool at next phase |
| Tutors open schedules late → staggered release ineffective | Medium | High | Combine with Solution 2 bonus; student named requests nudge tutors to open |
| Increased system complexity | Medium | Medium | Phase 1 (rewards only) is simple; Phase 2 (staggered release) only if needed |

---

## 13. Economic Analysis

### 13-1. Costs

| Item | Cost |
|------|------|
| Development (Phase 1) | ~1 week engineering (tutor selection UI + nudges) |
| Development (Phase 2) | ~2 weeks engineering (staggered release logic + slot management) |
| Ongoing operations | None (fully automated) |
| Additional tutor costs | **None** (no supply-side changes) |

### 13-2. Expected Revenue Impact

| Item | Conservative | Optimistic |
|------|-------------|------------|
| Reduced full-booking perception → fewer refunds | KRW 1.5M/mo | KRW 4M/mo |
| Improved retention (advance bookers retain better) | KRW 1M/mo | KRW 3M/mo |
| Fewer cancellations (advance booking = higher commitment) | KRW 0.5M/mo | KRW 1M/mo |
| **Total expected monthly revenue impact** | **KRW 3M/mo** | **KRW 8M/mo** |

### 13-3. ROI

- Development cost: One-time ~3 weeks of engineering
- Ongoing cost: KRW 0/month
- **Revenue impact: KRW 3–8M/month → Payback within 1 month**

---

## 14. Synergy Map with Other Solutions

| Solution | Synergy | Specific Connection |
|----------|---------|---------------------|
| [[방안 1 - 웨이팅리스트 + 알림 시스템\|Solution 1: Waitlist + Notifications]] | **High** | When last-minute slots are gone → waitlist + "Book earlier next time" nudge |
| [[방안 2 - 주간 일관성 보너스\|Solution 2: Weekly Consistency Bonus]] | **High** | Tutor "24hr advance schedule opening" bonus ensures advance slots exist |
| [[방안 3 - 예약 가능 시간대 사전 공지\|Solution 3: Available Slot Pre-Notifications]] | **Very High** | Evening push: "Tomorrow's advance booking slots are open!" → drives advance booking |
| [[방안 4 - 개인화 이메일 자동화\|Solution 4: Personalized Tutor Emails]] | **High** | Named booking data → "○○ is waiting for you" tutor emails |
| [[방안 7 - AI 보조 하이브리드 수업\|Solution 7: AI-Assisted Hybrid Lessons]] | Medium | Advance bookers get time to complete AI pre-study before the lesson |

---

## 15. Why This Solution Is Unique

Solutions 1–7 mostly intervene on the **supply side (tutors)**. This solution:

1. **Changes demand-side (student) behavior** → same supply, dramatically lower perceived full-booking
2. **Zero tutor policy changes** → zero tutor churn risk
3. **Zero cost** → rewards are "feature unlocks," not monetary incentives
4. **Easy to revert** → if Phase 1 doesn't work, just turn it off
5. **Generates data** → precise booking timing distribution insights for future optimization

> **Core framing: "Book earlier, get a better lesson" — we're not taking anything away, only giving more.**
