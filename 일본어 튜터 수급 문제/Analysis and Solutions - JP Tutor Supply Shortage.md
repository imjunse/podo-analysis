---
created: 2026-03-24
tags:
  - tutor-supply
  - japanese
  - churn-prevention
  - booking
status: analysis-complete
---

# Japanese Tutor Supply Shortage → Student Churn: Analysis & Solutions

> Source: [[Strategy & Plan_ Enhancing Lesson Experience]]
> Author: Andrew (original), GA (analysis summary)
> Date: 2026-03-24

---

## 1. Problem Summary

Japanese lessons are consistently fully booked, preventing students from reserving classes. This leads to churn (refunds + poor retention).

### Problem Structure

```
Tutor supply ceiling (bilingual ~290 cap)
    ↓
Fully booked → Students unable to reserve lessons
    ↓
Student churn (33% refund rate + low retention)
    ↓
Growth stagnation
```

### Root Causes

- Japanese beginner classes depend on **bilingual (JP-KR) tutors**
- Supply of such tutors is limited (~290 is effectively the ceiling)
- Student acquisition rate > tutor recruitment rate
- JP tutor average working hours are declining (Jan 11hrs → Mar 8.5hrs/week)

---

## 2. Key Metrics (as of March 2026)

| Metric | Current Status |
|--------|---------------|
| JP bilingual tutors | ~290 (stagnant) |
| Avg tutor hours | 8.5 hrs/week (declining trend) |
| Fully booked rate | 17–24% (higher during peak hours) |
| JP low-level refund rate | 33.06% |
| JP overall refund rate | 29.99% |
| EN overall refund rate | 33.93% |
| JP tutor cost ratio | ~33% of revenue |
| EN tutor cost ratio | ~19% of revenue |
| JP cost per class | ₩3,374 (25min) / ₩2,309 (15min) |

### Supply Lever Comparison

| Lever | Impact |
|-------|--------|
| Add 50 tutors (300→350) | +800 lessons/week |
| Add 2 hrs per tutor (8→10 hrs) | +1,200 lessons/week |

> **Increasing hours per tutor is more impactful than expanding the tutor pool**

### January Gift Incentive Results

- Total cost: ~₩2.3M
- Effect: Average 8.5 hrs → 11 hrs/week (+2.5 hrs)
- Problem: Hours dropped back immediately after incentive ended (failed to build habits)

---

## 3. Short-Term Solutions

### Solution 1: Waitlist + Notification System

> Difficulty: Low | Timeline: ~1–2 weeks | Expected Impact: High

When a student's desired time slot is unavailable:
- Offer: "Would you like to be notified when a spot opens up at this time?"
- Auto-notify when a tutor cancels or opens additional slots
- Implementation: one notification table + a cron job
- Shifts the student experience from "nothing I can do" → "I can at least wait" — preventing immediate churn

**Enhancement:** Give notified students a **5-minute priority booking window**. Without this, students receive the notification but fail to book anyway → even greater frustration.

### Solution 2: Weekly Consistency Bonus

> Difficulty: Non-dev (operational) | Timeline: Immediate | Expected Impact: High

The January incentive's problem: **monthly cadence → failed to build habits**.

**Improvement:**
- Switch to weekly milestones (e.g., bonus for 20 classes this week)
- Additional bonus for 4 consecutive weeks of achievement
- Budget of ~₩2.3M/month based on proven results
- Focus on habit formation

**Enhancement:** Rather than absolute milestone targets, consider **"this week vs. last week" personal growth-based bonuses**. Rewarding relative increases motivates smaller tutors as well.

**ROI Analysis (based on refund data):**
- Investment: ~₩2.3M/month (based on January incentive results)
- Expected recovery: Confirmed booking-related JP refunds run at ₩3–5M/month (see [[Refund Data Analysis (2025.10-2026.03)]]). This is a conservative keyword-matching estimate; actual scale is estimated at 2–3x (₩6–15M/month)
- **₩2.3M investment vs. ₩3–15M in preventable refund losses → ROI of 1.3x – 6.5x**
- Additional silent churn prevention (non-renewal) not included in this calculation

### Solution 3: Available Slot Pre-Notification

> Difficulty: Low | Timeline: ~1 week | Expected Impact: Medium-High

Currently, students discover "fully booked" only when they try to reserve. Flip this:

- Send a **push notification** every morning or evening with "tomorrow's available time slots"
- Students enter the booking flow already knowing which slots are open → **reduces the "booking failure" experience itself**
- Side effect: nudges earlier bookings
- Low dev cost (push notification + availability query API)

### Solution 4: "Personalized Email" Automation

> Difficulty: Medium | Timeline: ~2 weeks | Expected Impact: Medium

Manually tested method with a **50% success rate**.

**How it works:**
1. Detect fully booked time slots
2. Select 2 tutors whose schedules end just before that time
3. Send a personalized email:
   > "Dear [Tutor Name], many students want to book a class at 9 PM tonight but all slots are full. Would you be able to open your schedule for just one more hour?"

**Key constraints:**
- Max **once per week** per tutor (more frequent = effect disappears)
- Emails must **look like they were sent personally** by a staff member
- Targeted to **only 2 tutors per time slot**, not mass-sent

**Feasibility check:**
- 50% success rate was from manual outreach. Automation will likely reduce this
- Tutors will recognize the pattern over time — effective lifespan estimated at 2–3 months
- Switching from fixed 5 PM detection to **real-time triggers on full booking events** would improve effectiveness (but increases dev cost)

**Positioning:** The 2–3 month effective lifespan aligns with the Level Up curriculum launch (expected April–May). **Explicitly position this as a bridge solution until Level Up launches**, then naturally transition to non-bilingual tutor expansion.

### Solution 5: Add "Emotional Friction" to Class Cancellation

> Difficulty: Very Low | Timeline: ~1 week | Expected Impact: Low

**Current (As-is):**
> "Are you sure you want to cancel this class?"

**Proposed (To-be):**
> "This is your class with [Student Name]. This student has taken [N] classes with you and [left feedback]. Are you sure you want to cancel?"

**Feasibility check:**
- Only requires a frontend text change + one simple API call
- However, Podo is a side gig for JP tutors. Emotional friction **may backfire in Japanese culture** — tutors could feel pressured and open fewer slots overall
- Reducing cancellations doesn't solve the fundamental problem of insufficient open hours
- **Recommend small-scale testing with Japanese cultural context** before full rollout

---

## 4. Mid-Term Solution: Non-Bilingual "Reassurance Option" Experiment

### Overview

Instead of removing the bilingual filter entirely, give users the choice — but don't actually connect to non-bilingual lessons yet.

### Tutor Team Warnings

#### Warning 1: Lesson Quality Degradation → Increased Refunds (Andrew)

> The current curriculum is designed in a way that is extremely difficult for non-Korean-speaking tutors to teach. If non-bilingual tutors are assigned beginner classes with the current materials, lesson quality will drop and refund rates may actually increase.

**Core question:**
> Which is worse — booking a class one day later, or having a terrible class experience?

| | Unable to Book (current problem) | Bad Class Experience (new risk) |
|---|---|---|
| Churn type | Silent departure | Active refund + negative word-of-mouth |
| Recoverability | High (may return when slots open) | Low (trust is broken) |
| Data visibility | Not visible | Visible (refund rate, class ratings) |

#### Warning 2: Classes Are Physically Impossible with Current Materials (Tutor Team)

The current Japanese beginner curriculum (MyLite, JLPT) class flow:

1. **Word pronunciation correction** — possible without Korean
2. **Making sentences from words + simple conversation** — impossible for beginners
3. **Making sentences from grammar + simple conversation** — impossible for beginners
4. **Free talking with questions** — impossible for beginners

> The only part that both students and tutors can do without stress is **#1 (pronunciation correction)**. Steps 2–4 are **physically impossible** for beginner students without Korean.

- Andrew and Scott conducted 2 test classes playing the student role, confirming that **conversation simply does not work without Korean**
- For non-bilingual tutors to teach beginners, a **fundamentally different curriculum** is needed — one where students can practice Japanese without heavy back-and-forth with the tutor
- Harim's team and the tutor team have nearly finalized the framework for a new beginner curriculum

**Tutor Team Conclusion:**
> Ideally, non-bilingual tutors should only be assigned to beginner classes **after the new curriculum is ready**.

### Strategy: Waitlist-Integrated Reassurance Option

Given the warnings above, the purpose of the non-bilingual opt-in should shift from actual lesson matching to **providing the perception of choice**. To avoid feeling like an empty promise, **integrate naturally with the waitlist system**.

#### Specific UX Flow

Screen shown to students during a fully booked situation:

> "All bilingual tutors are currently booked."
>
> - **[View other time slots]** ← Main CTA
> - **[Get notified when a spot opens]** ← Waitlist
> - **[Notify me when Japanese-only classes open]** ← Demand data collection + future connection

The third option leads to **notification registration** rather than "coming soon" — avoiding the empty promise feeling while collecting demand data.

#### Benefits of This Approach

1. **Students**: "There are alternatives — I'm not stuck" → prevents immediate churn
2. **Tutors**: No actual non-bilingual beginner classes → zero risk
3. **Buys time**: Acts as a bridge until the new Level Up curriculum is ready
4. **Demand data collection**: Click rate on the third option quantifies actual demand for non-bilingual classes

#### Transition After New Curriculum Launch

When Harim's team's beginner curriculum is complete → connect the third option to **actual lessons**. The UI/flow is already built, so the transition is seamless.

### Execution Order

1. Implement waitlist-integrated UI (3 choices on fully booked screen) (~1 week)
2. Monitor click rates on the third option for demand data
3. When new curriculum (Level Up) launches → connect to actual non-bilingual lessons
4. Monitor class ratings + refund rates, then expand or adjust

---

## 5. Additional Solutions Under Review

### Group Classes (1:1 → 1:2 or 1:3)

> Previously discussed internally. Feasibility not yet confirmed.

**Principle:**
- Current 1:1 model: 1 tutor = 1 lesson
- With 1:2, **the same tutor pool covers twice the students**
- Beginner students at the same level may actually benefit from group dynamics (peer learning effect)
- Tutor cost stays the same, but cost per student is halved

**Risks:**
- If Podo's core value proposition is "1:1 lessons," this could damage brand identity
- Schedule matching becomes much more complex (need 2–3 students at the same time + same level)

**Implementation approach (if pursued):**
- Only offer "Would you like to take a class with another student?" during full booking situations
- Offer ticket discounts for group classes as student incentive
- Keep 1:1 as the default; position group classes as an **additional option**

### AI-Assisted Hybrid Classes

> Podo already has interactive AI lessons (non-speaking format). Potential to recycle these assets.

**Principle:**
- Combine existing AI interactive content with tutor sessions
- Example: 15min AI interactive practice + 10min tutor feedback
- Allows one tutor to cover more students per hour
- Non-bilingual tutors can handle 10-minute feedback sessions

**Existing AI lesson issues:**
- The 100% AI conversation curriculum had a 17.9% refund rate (higher than other curricula)
- However, "AI only" vs. "AI + tutor hybrid" could yield different results

**Recycling potential:**
- Repurpose existing AI interactive content as **pre-class practice** or **in-class activities**
- No new AI content development needed — reposition existing assets as tutor-class support tools
- Could integrate with the Level Up curriculum's "pre-study" materials for synergy

**Items to investigate:**
- How much existing AI interactive content is suitable for beginners
- What sequencing/ratio of AI content to tutor time works best
- Student acceptance of "AI + tutor" hybrid format

---

## 6. Long-Term Solutions (from Andrew's Strategy Document)

### Level Up Curriculum

- Transition from 25min to 15min classes
- Remove bilingual tutor requirement
- Compensate with robust pre-study materials
- Target: A1-A2, linear learning path
- Expected launch: April–May 2026

### Topic-Based Curriculum

- Target: B1+ students
- Discussion/feedback-focused 25min classes
- New lessons added weekly
- Expected launch: May 2026+

### Cost Impact of 15-Minute Classes

| Scenario | Tutor Cost Ratio |
|----------|-----------------|
| Current (75% JP, 25min) | 29.23% |
| JP rises to 90% (no change) | 31.47% |
| 50% of classes switch to 15min | 24.78% |
| JP 90% + 50% at 15min | 26.73% |

---

## 7. Overall Priority Summary

### Tier 1: Execute Immediately (within 1–2 weeks)

| Priority | Solution | Difficulty | Expected Impact |
|----------|----------|-----------|----------------|
| 1 | Waitlist + notifications (with priority booking) | Low | High |
| 2 | Weekly consistency bonus (personal growth-based, ROI 1.3–6.5x) | Non-dev | High |
| 3 | Available slot pre-notification | Low | Medium-High |
| - | Booking failure event logging (parallel with Tier 1) | Low | Measurement infra |

> **Booking Failure Event Logging:** Current refund analysis relies on keyword matching in ticket content, which has low accuracy (see [[Refund Data Analysis (2025.10-2026.03)]]). Logging a "fully booked — booking failed" event on the reservation screen enables (1) precise measurement of Solutions 1–4's effectiveness and (2) quantification of the true full-booking rate. This is a single event addition to the existing logging pipeline — minimal dev effort.

### Tier 2: Execute within 2–3 weeks

| Priority | Solution | Difficulty | Expected Impact |
|----------|----------|-----------|----------------|
| 4 | Personalized email automation | Medium | Medium |
| 5 | Reassurance option (integrated with waitlist) | Low | Medium |

### Tier 3: Requires Review & Testing

| Solution | Difficulty | Notes |
|----------|-----------|-------|
| Emotional friction on cancellation | Very Low | Small-scale test with Japanese cultural context first |
| Group class option | Medium-High | Brand risk review needed; high potential impact |
| AI hybrid classes | Medium | Investigate recycling potential of existing AI content |

### Excluded

| Solution | Reason for Exclusion |
|----------|---------------------|
| Off-peak demand distribution | Both students (working during day) and tutors (side gig, unavailable during day) are concentrated at peak hours. Incentives unlikely to shift behavior |
| Lesson request feature (standalone) | More efficient to integrate into waitlist + email automation |

### Recommended Execution Plan

**Start #1, #2, and #3 simultaneously** for tangible impact within 2 weeks.
- Solution 1 (Waitlist) = Student-side churn prevention
- Solution 2 (Weekly bonus) = Tutor-side supply increase (ROI 1.3–6.5x)
- Solution 3 (Pre-notification) = Reduce the "booking failure" experience itself
- Booking failure logging = Measurement infrastructure for all of the above

These three work **on both sides (student + tutor) simultaneously**.

Solution 5 (Reassurance option) integrates naturally into Solution 1. Actual non-bilingual lesson matching should proceed only after the new curriculum launches.

> [!warning] March Urgency (as of 2026-03-24)
> March is only 3 weeks in but booking-related JP refunds have already hit ₩5.0M — **on pace for the highest monthly total**. Per-case refund amounts are also trending upward (high-value package users beginning to churn). This is not "execute within 1–2 weeks" — this requires **immediate action**. Detailed data: [[Refund Data Analysis (2025.10-2026.03)]]
