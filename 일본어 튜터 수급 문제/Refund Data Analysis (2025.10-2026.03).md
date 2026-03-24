---
created: 2026-03-24
tags:
  - tutor-supply
  - japanese
  - refund
  - data-analysis
  - full-booking
status: complete
---

# JP Tutor Supply Shortage - Refund Data Analysis

> Data Source: Metabase (GT_PAYMENT_INFO + ticket table join)
> Analysis Period: 2025.10.27 ~ 2026.03.24
> Related: [[Analysis and Solutions - JP Tutor Supply Shortage]]

---

## 1. Executive Summary

- **Total Refunds**: 1,538 cases / ~KRW 316M (~USD 230K)
- **Japanese (JP+ENJP) Refunds**: 1,079 cases (70.2%) / ~KRW 220M (~USD 160K)
- **Full Booking-Attributed Refunds (confirmed)**: 91 cases (~74 users) / ~KRW 15.8M (~USD 11.5K)
- March is on pace to be the highest month for booking-related refund amounts

> [!warning] Conservative Estimate
> Cases where users selected "Lack of study time" as the reason but were actually unable to book lessons are NOT included. The real scale is likely significantly larger.

---

## 2. Methodology

### Data Join Structure

```
ticket (refund tickets)
  → JOIN on user_id = GT_PAYMENT_INFO.USER_UID
  → Extract actual refund payment amounts for JP refund ticket users
    with booking-related keyword matches
```

### Full Booking Detection Keywords

Tickets matched if content contains one or more of the following keywords OR refund reason is "Tutor Assignment System" / "Booking System":

| Category | Keywords (Korean) |
|----------|------------------|
| Booking | reservation, can't book, booking unavailable |
| Class unavailability | no classes available, can't take class |
| Slot/Capacity | no slots, fully booked, sold out, no openings |
| Tutor shortage | no tutors, no teachers, assignment, supply |
| Scheduling | preferred time, schedule conflict, schedule |
| Other | full, full booking, can't secure, hard to get |

---

## 3. Overall Refund Summary (Period Total)

| Segment | Cases | Share | Refund Amount |
|---------|-------|-------|---------------|
| **Total** | 1,538 | 100% | **KRW 315.5M** |
| JP (Japanese) | 787 | 51.2% | KRW 158.9M |
| ENJP (JP+EN Bundle) | 292 | 19.0% | KRW 70.7M |
| **JP+ENJP Subtotal** | **1,079** | **70.2%** | **KRW 219.6M** |
| EN (English) | 459 | 29.8% | KRW 85.9M |

> [!important] Japanese accounts for 70% of all refunds
> JP alone exceeds 51%. Combined with ENJP, it reaches 70.2% — the Japanese tutor supply problem has a dominant impact on overall refund volume.

---

## 4. Monthly Summary

| Month | Total Refund | JP+ENJP Refund | Booking-Related | Booking Share |
|-------|-------------|----------------|-----------------|---------------|
| Oct (27~) | KRW 8.5M | KRW 5.8M | KRW 1.0M | 17.9% |
| Nov | KRW 58.4M | KRW 44.1M | KRW 3.8M | 8.5% |
| Dec | KRW 66.8M | KRW 47.3M | KRW 2.6M | 5.5% |
| Jan | KRW 50.4M | KRW 30.6M | KRW 3.5M | 11.4% |
| Feb | KRW 73.2M | KRW 49.0M | KRW 3.9M | 8.0% |
| Mar (~24) | KRW 58.2M | KRW 39.1M | KRW 5.0M | **12.7%** |

---

## 5. Weekly Breakdown

| Week | Start | Total Cases | Total Amount | JP+ENJP Cases | JP+ENJP Amount | Booking Cases (Users) | Booking Amount |
|------|-------|-------------|-------------|---------------|----------------|----------------------|----------------|
| W44 | 10/27 | 80 | KRW 8.5M | 53 | KRW 5.8M | 4 (3) | KRW 1.0M |
| W45 | 11/03 | 86 | KRW 10.6M | 66 | KRW 6.7M | 2 (2) | KRW 1.3M |
| W46 | 11/10 | 93 | KRW 16.0M | 61 | KRW 12.9M | **7 (4)** | KRW 0.8M |
| W47 | 11/17 | 72 | KRW 14.2M | 54 | KRW 9.1M | 5 (4) | KRW 1.5M |
| W48 | 11/24 | 73 | KRW 17.6M | 47 | KRW 15.5M | 3 (2) | KRW 0.2M |
| W49 | 12/01 | 77 | KRW 10.3M | 54 | KRW 7.5M | 6 (5) | KRW 0.7M |
| W50 | 12/08 | 82 | KRW 22.8M | 51 | KRW 14.6M | 0 | 0 |
| W51 | 12/15 | 79 | KRW 16.1M | 53 | KRW 10.4M | 4 (2) | +KRW 0.1M* |
| W52 | 12/22 | 70 | KRW 15.0M | 52 | KRW 11.9M | 4 (4) | KRW 1.7M |
| W01 | 12/29 | 48 | KRW 14.8M | 29 | KRW 9.6M | 1 (1) | KRW 0.2M |
| W02 | 01/05 | 80 | KRW 11.0M | 64 | KRW 7.4M | **8 (5)** | KRW 0.2M |
| W03 | 01/12 | 74 | KRW 13.3M | 59 | KRW 8.5M | 4 (3) | KRW 0.6M |
| W04 | 01/19 | 67 | KRW 8.9M | 47 | KRW 5.6M | 6 (5) | KRW 1.8M |
| W05 | 01/26 | 66 | KRW 17.2M | 46 | KRW 9.1M | 3 (3) | KRW 0.8M |
| W06 | 02/02 | 68 | KRW 16.6M | 45 | KRW 10.2M | 4 (4) | KRW 1.6M |
| W07 | 02/09 | 95 | KRW 20.7M | 57 | KRW 11.8M | 3 (2) | KRW 0.2M |
| W08 | 02/16 | 40 | KRW 9.7M | 28 | KRW 7.1M | 3 (3) | KRW 1.6M |
| W09 | 02/23 | 90 | KRW 26.3M | 69 | KRW 20.0M | 6 (4) | KRW 0.5M |
| W10 | 03/03 | 52 | KRW 13.4M | 35 | KRW 8.8M | 4 (3) | KRW 1.6M |
| W11 | 03/09 | 60 | KRW 21.8M | 45 | KRW 15.7M | 4 (4) | KRW 1.4M |
| W12 | 03/16 | 60 | KRW 11.2M | 46 | KRW 7.1M | 1 (1) | KRW 1.0M |
| W13 | 03/23 | 26 | KRW 9.5M | 19 | KRW 7.6M | 2 (2) | KRW 1.1M |

*\* Positive amount = cancellation penalty exceeds refund*

---

## 6. Refund Reason Breakdown (JP Tickets)

Distribution of refund reasons from Japanese refund tickets (last 6 months):

| Refund Reason | Cases | w/ Booking Keywords |
|---------------|-------|-------------------|
| Lack of study time | 325 | 10 |
| Accidental purchase | 162 | 5 |
| Other | 103 | 6 |
| Impulse buy / Financial | 78 | 7 |
| Curriculum | 71 | 7 |
| Tutor quality | 56 | 5 |
| **Tutor assignment system** | **52** | **18** |
| Payment method change | 47 | 0 |
| App errors | 38 | 4 |
| **Booking system** | **25** | **10** |
| Textbook-based format | 24 | 3 |
| Switched to competitor | 9 | 0 |

> [!note] The "Lack of study time" trap
> Even the top category (325 cases) contains 10 cases with booking-related keywords. Many users likely couldn't book lessons but selected "lack of time" instead — the actual booking-driven churn is significantly underreported.

---

## 7. Insights

### 7-1. Japanese Refunds Are Overwhelming

- JP+ENJP accounts for **70.2%** of all refunds (69.6% by amount)
- Resolving the Japanese tutor supply problem would directly reduce overall refund volume

### 7-2. Full Booking Refunds Are the Tip of the Iceberg

- Keyword-matched confirmed cases: **KRW 15.8M / 74 users** (5 months)
- This only captures users who explicitly mentioned booking issues in their ticket content
- Users who selected "Lack of study time" but were actually unable to book represent a much larger **hidden churn pool**
- Conservative estimate: 2-3x actual scale; optimistic: up to 5x (estimated KRW 30M-80M / USD 22K-58K)

### 7-3. March Warning Signal

- March has only 3 weeks (W10-W13) but booking-related refunds already at KRW 5.0M — **on pace for the highest monthly total**
- Per-case refund amounts are trending higher (high-value package users beginning to churn)
- W10-W11 saw 4 cases/week consecutively — a supply deterioration signal

### 7-4. High Variance in Refund Amounts

- Booking-related refunds are low in volume but have **high per-case variance** (KRW 100K - 1.8M)
- A single high-value package (e.g., 12-month plan) user churning causes a sharp spike in refund amounts
- This means **high-LTV users are churning**, making the true cost of the supply problem far greater than the refund amount alone

### 7-5. Hidden Costs: Churn Without Refund

- Costs not captured in refund data may be even larger:
  - Quiet churn via non-renewal (subscription lapse)
  - Unused lesson credits expiring → low NPS / negative reviews
  - Word-of-mouth degradation reducing new user acquisition

---

## 8. Recommended Actions

### Immediate (1-2 weeks)
- [ ] Partner with CS team to sample "Lack of study time" refund tickets and estimate the true booking-unavailability rate
- [ ] Evaluate adding "No available lessons to book" as a refund reason option in ticket templates

### Short-term (1 month)
- [ ] Quantify tutor supply vs. demand gap during JP peak hours (7-10 PM KST)
- [ ] Build detection logic for "booking failure" users pre-refund (e.g., 3+ failed booking attempts)

### Mid-term (1-3 months)
- [ ] Expand Japanese tutor recruitment/onboarding pipeline (current ceiling ~290 bilingual tutors)
- [ ] Implement fallback systems for fully-booked slots (waitlist, alternative time suggestions, compensation credits)

---

## 9. Data Limitations & Caveats

1. **Keyword matching approach**: Cannot capture all natural language expressions (False Negatives exist)
2. **Reason selection bias**: Users may select a reason different from their actual motivation
3. **ENJP inseparability**: Cannot distinguish whether EN-JP bundle refunds are driven by JP supply issues or EN dissatisfaction
4. **Penalty offset**: Some weeks show positive amounts where cancellation penalties exceed the refund
5. **W13 (3/23) is in progress**: Data for the current week is incomplete
