---
created: 2026-03-24
tags:
  - tutor-supply
  - japanese
  - group-lessons
  - business-model
status: planning
parent: "[[Problem Analysis and Solutions]]"
tier: 3
priority: 6
---

# Solution 6: Introduce Group Lessons (1:1 → 1:2/1:3)

> Parent document: [[Problem Analysis and Solutions]]
> Difficulty: Medium-High | Timeline: 4-6 weeks | Expected Impact: High (2-3x supply expansion) | Priority: Tier 3 - Needs Review

---

## 1. Core Hypothesis

> "During full-booking situations, offering 1:2 group lessons as a 'discounted option' instead of 1:1 can reduce the number of unserved students while improving tutor cost efficiency."

**Mathematical Basis:**
- Current: 1 tutor = 1 student (25 min)
- 1:2: 1 tutor = 2 students (25 min) → **2x capacity with same supply**
- 1:3: 1 tutor = 3 students (25 min) → **3x capacity with same supply**

---

## 2. Brand Risk Analysis

### 2-1. Podo's Core Value = "1:1 Lessons"

If Podo's marketing/positioning is built on 1:1 lessons, introducing group lessons could undermine brand identity.

**Brand Impact Scenarios:**

| Approach | Brand Impact | Risk |
|----------|-------------|------|
| Switch to group lessons as main offering | High (identity damage) | Existing user churn |
| Offer only as alternative during full-booking | Low (complementary) | Limited |
| Separate product line (Podo Group) | None (separate branding) | Increased operational complexity |

**Recommendation: "Offer only during full-booking" or "Separate product line"**

### 2-2. Student Perspective: 1:1 vs Group

| Factor | 1:1 | 1:2 Group |
|--------|-----|-----------|
| Speaking time | ~12 min out of 25 | ~6 min out of 25 |
| Personalized feedback | 100% individualized | 50% individualized |
| Pressure | High (stressful for beginners) | Low (peer effect) |
| Peer learning | None | Yes (learning from each other) |
| Price expectation | Premium | Expects discount |

**Group lessons can actually be advantageous for beginner students:**
- Reduced pressure of speaking Japanese alone for 25 minutes
- Learning from other students' mistakes/successes (observational learning)
- "I'm not the only one struggling" → maintains learning motivation

---

## 3. Lesson Design

### 3-1. Group Lesson Format

```
[1:2 Group Lesson - 25 min Structure]

0-3 min: Greeting + today's topic introduction
3-10 min: Student A speaking + tutor feedback
10-17 min: Student B speaking + tutor feedback
17-23 min: A & B conversation practice (tutor monitoring)
23-25 min: Wrap-up + feedback summary
```

**Key:** Including student-to-student conversation practice reduces tutor burden while maintaining student speaking volume.

### 3-2. Level Matching Criteria

The biggest risk in group lessons = level mismatch

| Allowed Range | Example | Quality Impact |
|--------------|---------|---------------|
| Same sub-level | A1.1 + A1.1 | Optimal |
| ±1 sub-level | A1.1 + A1.2 | Acceptable |
| ±2 or more | A1.1 + A2.1 | Not allowed (both sides dissatisfied) |

### 3-3. Schedule Matching Difficulty

**This is the biggest technical challenge:**

```
1:1 matching: Time + tutor type → match complete
1:2 matching: Time + tutor type + level ±1 + 2 students simultaneously → very difficult to match
```

**Solution Approaches:**
1. **Students "apply" for group lessons** → lesson confirmed when 2 students at same time + same level are found
2. **Minimum matching window**: if 2 students aren't matched within 24 hours → convert to 1:1 or cancel
3. **Peak hours (7-10 PM) priority**: offer only during time slots with large student pools

---

## 4. Pricing Design

### 4-1. Pricing Options

| Option | vs 1:1 Price | Tutor Cost | Margin | Student Incentive |
|--------|-------------|------------|--------|-------------------|
| A. Same price | 100% | 50% (per student) | ↑↑ | None (hard to accept) |
| B. 30% discount | 70% | 50% | ↑ | Moderate |
| C. 50% discount | 50% | 50% | Same | High |
| D. 0.5 lesson credit deduction | 50% | 50% | ↑ | High |

**Recommendation: Option D (0.5 lesson credit deduction)**
- Student perspective: Instead of 1 session of 1:1, they can take 2 sessions of 1:2 → "I can take more lessons"
- Company perspective: Tutor cost is the same but lesson credit consumption is halved → improved retention
- Revenue impact: Short-term decrease in revenue per credit, long-term retention gains compensate

### 4-2. Tutor Compensation

| Option | Pay per Lesson | Expected Tutor Response |
|--------|---------------|------------------------|
| A. Same as 1:1 | ₩3,374 (25 min) | Good (same pay for slightly more effort) |
| B. 1.3x | ~₩4,386 | Very good (incentivized) |
| C. 0.8x | ~₩2,699 | Poor (2 students but less pay) |

**Recommendation: Option A (same pay)**
- Group lessons require slightly more effort for tutors, but equal pay makes it acceptable
- Consider starting at 1.3x → adjusting to 1.0x after stabilization

---

## 5. UX Flow

### 5-1. Group Lesson Suggestion During Full-Booking

```
[Full-Booking Situation]

"All 1:1 lessons are currently booked."

┌──────────────────────────────────────────┐
│ 🔔 Get notified when a spot opens        │  ← Primary
│    (Solution 1)                           │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 👥 Join a group lesson                    │  ← Secondary
│    Learn with another student (0.5 credit)│
│    Matched with a similar-level student   │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ 🕐 View other time slots                 │  ← Tertiary
└──────────────────────────────────────────┘
```

### 5-2. Group Lesson Matching Queue

```
[Group Lesson Application Complete]

"We're looking for a student at a similar level in the same time slot."
"We'll notify you as soon as we find a match!"

Current status: Waiting for match (1/2 students)

[Cancel]
```

### 5-3. Match Success

```
"Your group lesson is confirmed! 🎉"

📅 3/25 (Tue) 20:00
👨‍🏫 [Tutor Name] Sensei
👥 2-person group lesson (25 min)
📖 Level: A1

[Prepare for Lesson]
```

---

## 6. Technical Challenges

### 6-1. Matching Algorithm

```
function matchGroupLesson(request):
    // Find pending requests at same time + same language + level ±1
    candidates = getPendingRequests(
        date = request.date,
        hour = request.hour,
        language = request.language,
        levelRange = [request.level - 1, request.level + 1]
    )

    if candidates.count >= 1:  // If 1 person already waiting, pair is complete
        partner = candidates.sortBy(levelProximity).first()
        tutor = findAvailableTutor(request.date, request.hour, type='group')

        if tutor:
            createGroupLesson(tutor, [request.user, partner.user])
            notify([request.user, partner.user], "Match found!")
        else:
            // No group-capable tutor available
            addToWaitingPool(request)
    else:
        addToWaitingPool(request)

    // Auto-cancel if unmatched after 24 hours
    scheduleJob(after: 24.hours, action: expireIfUnmatched(request.id))
```

### 6-2. Video Lesson Infrastructure

- Does the current 1:1 lesson infrastructure support 1:2?
- Need to verify 3-person video support (WebRTC/Agora/Twilio, etc.)
- Screen layout: 1 tutor + 2 students

### 6-3. Materials/Curriculum

- Current materials are designed for 1:1
- Separate group materials needed: student-to-student conversation prompts, pair activities, etc.
- **Designing group mode alongside the Level Up curriculum** would be efficient

---

## 7. Phased Rollout Plan

### Phase 0: Validation (2 weeks)
- [ ] Student survey: "Would you be willing to take group lessons at a discounted price instead of 1:1?"
- [ ] Tutor survey: "Would you be willing to conduct group lessons (1:2)?"
- [ ] Technical review of video infrastructure for 1:2 support
- [ ] Internal discussion on brand impact

### Phase 1: Pilot (4 weeks)
- [ ] Expose group option only during peak hours (8-9 PM) and only when fully booked
- [ ] Recruit 10 tutors willing to do group lessons
- [ ] Apply 0.5 credit deduction model
- [ ] Weekly NPS + lesson rating monitoring

### Phase 2: Expansion (4 weeks)
- [ ] Expand to all peak hours
- [ ] Develop dedicated group lesson materials
- [ ] Refine matching algorithm

---

## 8. Success/Failure Criteria

### Phase 1 (Pilot) After 4 Weeks

| Metric | Success | Failure |
|--------|---------|---------|
| Group lesson participation rate (among full-booking users) | 20%+ | Below 5% |
| Group lesson rating | 4.0+ (out of 5) | Below 3.5 |
| Group lesson re-participation rate | 50%+ | Below 20% |
| Increase in 1:1 lesson refunds | No change | Increase (cannibalization) |

---

## 9. Risks and Mitigation

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Brand identity damage | Medium | High | Only during full-booking + clearly position as "alternative option" |
| Match failure (no same-level student) | High | Medium | Peak hours only, auto-cancel after 24h |
| Lesson quality degradation | Medium | High | Dedicated materials, tutor training, rating monitoring |
| 1:1 → Group cannibalization | Medium | High | Group only shown during full-booking, hidden when 1:1 spots available |
| Video infrastructure issues | Low | High | Technical review in Phase 0 |

---

## 10. Connection to Other Solutions

| Related Solution | Synergy |
|-----------------|---------|
| [[Solution 1 - Waitlist + Notification System]] | Integrate group option into full-booking UI. While waiting in waitlist → suggest "Take a group lesson right now" |
| [[Solution 7 - AI-Assisted Hybrid Lessons]] | Possible combination of AI practice + group feedback sessions |
| Long-term: Level Up Curriculum | Designing group mode alongside Level Up improves material development efficiency |
