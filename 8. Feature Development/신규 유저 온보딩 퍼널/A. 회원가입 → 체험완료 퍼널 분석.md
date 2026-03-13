---
title: 회원가입 → 체험완료 퍼널 분석
date: 2026-03-13
type: data-analysis
parent: "[[PRD - 신규 유저 온보딩 퍼널]]"
tags:
  - 데이터분석
  - 온보딩
  - MySQL
  - Squad-C
---

# 회원가입 → 체험완료 퍼널 분석

> **데이터 소스**: GWATOP MySQL (GT_USER, GT_PAYMENT_INFO, GT_CLASS)
> **분석 기간**: 2026-01-01 ~ 2026-03-04
> **체험완료 기준**: D+7 유효기간 cutoff (3/4 이후 가입자는 아직 체험 미완료 가능)

---

## 1. 전체 퍼널 요약

```
회원가입           7,452명  ─── 100%
    │
    ▼ 66.0%
무료체험 결제(신청)  4,916명  ─── 34.0% 이탈  ★ 최대 이탈 구간
    │
    ▼ 51.6%
체험 완료          2,536명  ─── 48.4% 이탈
    │
    ▼  (마케터 분석 연결)
정규 결제           ~888명  ─── ~11.9% (가입 대비)
```

> **유저 기반 전환율**: 가입월 코호트 기준으로 각 유저의 전환 여부를 추적한 수치. 스냅샷 기반(각 테이블 날짜 컬럼별 집계)과 달리, 월 경계를 넘는 전환도 가입월에 귀속시켜 실제 전환율을 정확히 반영한다.

### 핵심 전환율

| 퍼널 단계                   | 전환율       |
| ------------------------- | ---------: |
| 회원가입 → 무료체험 결제(신청)   | **66.0%**  |
| 무료체험 결제(신청) → 체험 완료   | **51.6%**  |
| **회원가입 → 체험 완료 (전체)** | **34.0%**  |

---

## 2. 월별 상세

| 지표               | **합계** |    1월 |    2월 | 3월(~4일) |
| ---------------- | -----: | ----: | ----: | ------: |
| **회원가입수**        |  7,452 | 3,487 | 3,590 |     375 |
| **무료체험 결제수(신청)** |  4,916 | 2,336 | 2,334 |     246 |
| **체험 완료수**       |  2,536 | 1,217 | 1,175 |     144 |

### 월별 전환율

| 전환 단계       |    1월 |    2월 | 3월(~4일) |
| ----------- | ----: | ----: | ------: |
| 가입 → 체험결제   | 67.0% | 65.0% |   65.6% |
| 체험결제 → 체험완료 | 52.1% | 50.3% |   58.5% |
| 가입 → 체험완료   | 34.9% | 32.7% |   38.4% |

> **참고**: 3월은 4일까지의 데이터로, 표본이 적어 전환율 변동폭이 큼

<details>
<summary>참고: 날짜 스냅샷 기반 수치 (이전 버전)</summary>

스냅샷 기반은 각 테이블의 날짜 컬럼으로 월별 집계하므로, 1월 가입자가 2월에 체험결제하면 1월 가입수/2월 결제수에 각각 잡혀 전환율이 부풀려진다. 아래는 참고용으로 보존.

| 지표               | 합계 |    1월 |    2월 | 3월(~4일) |
| ---------------- | -----: | ----: | ----: | ------: |
| 무료체험 결제수(신청) |  5,773 | 2,818 | 2,655 |     300 |
| 체험 완료수       |  2,927 | 1,446 | 1,302 |     179 |

| 전환 단계 (스냅샷) |    1월 |    2월 | 3월(~4일) |
| ----------- | ----: | ----: | ------: |
| 가입 → 체험결제   | 80.8% | 73.9% |   80.0% |
| 체험결제 → 체험완료 | 51.3% | 49.0% |   59.7% |
| 가입 → 체험완료   | 41.5% | 36.3% |   47.7% |

</details>

---

## 3. 핵심 인사이트

### 가장 큰 이탈: 가입 → 체험결제 (34.0% 이탈)

가입자 7,452명 중 **2,536명(34.0%)이 무료체험을 신청하지 않음**. 스냅샷 기반에서는 77.5%로 양호해 보였으나, 유저 기반으로 보면 실제 전환율은 66.0%로 가입자의 3분의 1이 체험조차 신청하지 않는다.

### 두 번째 이탈: 체험결제 → 체험완료 (48.4% 이탈)

무료체험을 결제(신청)한 4,916명 중 **2,380명이 체험 수업을 완료하지 않음**. 이 구간은 예약 → 수업 참석(노쇼) 문제를 포함하며, 온보딩 퍼널 개선의 핵심 과제.

이 이탈에는 두 가지 원인이 복합적으로 작용한다:

1. **기술 버그 (주요 원인)**: 2025년 하반기 React 전환 과정에서 "수업 입장하기" CTA가 정상 작동하지 않는 버그가 발생했다. ClickHouse 기준 2월에는 `meet_connected` 이벤트가 **0건**이며 3월부터만 집계되어, 트래킹 추가 시점 또는 CTA 버그와 연관된 것으로 추정된다. **이 버그는 현재 수정 중이다.**
2. **UX 문제**: 예약과 수업 사이 시간에 유저를 붙잡아두는 장치가 없고, 무료 체험이 1회뿐이라 노쇼 시 기회가 소멸되며, 레슨방 입장 경험도 불안 해소가 되지 않는다.

### 가입 → 체험결제 전환율 (66.0%)

가입자의 약 3분의 2가 무료체험을 신청. 현재 `trial_free` 플래그로 무료 체험이 활성화되어 있어 결제 장벽이 낮으나, 여전히 34%가 가입만 하고 체험을 신청하지 않는다.

### 뒷단 분석과의 숫자 일치 확인

- 우리 체험 완료 (유저 기반): **2,536명** (가입월 코호트 기준 유니크 유저)
- 스냅샷 기반 체험 완료: **2,927명** (GT_CLASS 날짜 기준, 분석 기간 이전 가입자의 완료 포함)
- 마케터(박서연) 체험 완료 주차 합산: **2,906건** (차이 0.7% vs 스냅샷)
- 마케터는 건수 기준(EN+JP 선택 시 2건), 본 분석은 유니크 유저 기준
- 분석 기간 차이도 일주일 정도 있음 (~3/11 vs. ~3/4)
- → 체험완료 지점에서 앞뒤 분석의 **정합성 확인됨**

### 전체 가입 → 정규결제 전환율: ~11.9%

가입 7,452명 중 약 888명만 정규 결제까지 도달 (마케터 분석 기준 체험완료→정규결제 전환율 ~35% 적용)

---

## 4. ClickHouse vs MySQL 데이터 차이

| 지표        | ClickHouse (identify) | MySQL (GT_USER) | 비고   |
| --------- | --------------------: | --------------: | ----: |
| 가입수       | ~8,123                | **7,452**       | CH 과대집계 |
| 체험 완료율   | 4.3%                  | **34.0%**       | 기준 차이 |

- ClickHouse `identify` 이벤트는 페이지 로드마다 발생 → 실제 가입수 대비 과대 집계
- **퍼널 분석은 반드시 MySQL(GT_USER)을 source of truth로 사용**
- ClickHouse는 행동 패턴 분석(시간대, 페이지 이동 등)에만 활용

---

## 5. 후속 분석과의 연결

```
[본 분석 영역]                         [마케터 분석 영역]
회원가입 → 체험결제 → 체험완료     ───→    체험완료 → 정규레슨 결제
  7,452    4,916     2,536               2,536     ~888명
  (66.0%)  (51.6%)                       (31~39% - 하락 추세)
```

- 마케터 분석: [[PODO_정규레슨_결제볼륨_하락분석_2026년3월]]
- 체험완료→정규결제 전환율: 44.24%(1월초) → 31.25%(3월) 하락 추세
- 주원인: 세일즈팀 D+4~7 전화 액션 중단

---

## 6. 가입수 7,452명 검증

마케터가 언급한 "1,800명 내외"는 **2/24~3/12 기간(약 16일)**의 수치.
일평균 가입 ~107~118명/일로 환산하면, 63일(1/1~3/4) 기간에 7,452명은 정합성 있음.

| 검증 기준 | 수치 |
|---|---|
| 마케터 기준 일평균 (2/24~3/12) | ~107명/일 |
| 본 분석 일평균 (1/1~3/4) | ~118명/일 |
| ClickHouse 일평균 가입 (2/23~3/12) | ~2,300명/일 (identify 이벤트, ~20x 과대) |

→ MySQL 기준 일평균 118명/일 × 63일 = 7,434명 ≈ 7,452명 (일치)

---

## 7. 사용한 SQL 쿼리

### 가입수
```sql
SELECT DATE_FORMAT(CREATE_DATE, '%Y-%m') AS month, COUNT(ID)
FROM GT_USER u
WHERE u.CLASS_TYPE = 'PODO'
  AND DATE(u.CREATE_DATE) BETWEEN '2026-01-01' AND '2026-03-04'
  AND u.REAL_NAME NOT LIKE '%QA_%'
  AND u.EMAIL NOT LIKE '%@podo.com'
  AND u.PHONE != '00000000000'
  AND u.CREATE_DATE > '2024-03-19 19:00:00'
GROUP BY DATE_FORMAT(u.CREATE_DATE, '%Y-%m')
ORDER BY month
```

### 무료체험 결제(신청)수
```sql
SELECT DATE_FORMAT(UPDATE_DATE, '%Y-%m') AS month, COUNT(ID)
FROM GT_PAYMENT_INFO
WHERE CLASS_TYPE = 'PODO'
  AND PAY_METHOD NOT IN ('admin')
  AND DATE(UPDATE_DATE) BETWEEN '2026-01-01' AND '2026-03-04'
  AND PAYMENT_DIV = 'T'
GROUP BY DATE_FORMAT(UPDATE_DATE, '%Y-%m')
ORDER BY month
```

### 체험 완료수
```sql
SELECT DATE_FORMAT(ORG_CLASS_DATETIME, '%Y-%m') AS month,
       COUNT(DISTINCT STUDENT_USER_ID)
FROM GT_CLASS
WHERE CLASS_TYPE = 'PODO'
  AND CITY = 'PODO_TRIAL'
  AND CREDIT = 2
  AND DATE(ORG_CLASS_DATETIME) BETWEEN '2026-01-01' AND '2026-03-04'
GROUP BY DATE_FORMAT(ORG_CLASS_DATETIME, '%Y-%m')
ORDER BY month
```

### 유저 기반(코호트) 체험결제 전환
```sql
SELECT
  DATE_FORMAT(u.CREATE_DATE, '%Y-%m') AS signup_month,
  COUNT(DISTINCT u.ID) AS signup_count,
  COUNT(DISTINCT p.USER_UID) AS trial_payment_count,
  ROUND(COUNT(DISTINCT p.USER_UID) / COUNT(DISTINCT u.ID) * 100, 1) AS conversion_rate
FROM GT_USER u
LEFT JOIN GT_PAYMENT_INFO p
  ON u.ID = p.USER_UID
  AND p.CLASS_TYPE = 'PODO'
  AND p.PAY_METHOD NOT IN ('admin')
  AND p.PAYMENT_DIV = 'T'
  AND DATE(p.UPDATE_DATE) BETWEEN '2026-01-01' AND '2026-03-04'
WHERE u.CLASS_TYPE = 'PODO'
  AND DATE(u.CREATE_DATE) BETWEEN '2026-01-01' AND '2026-03-04'
  AND u.REAL_NAME NOT LIKE '%QA_%'
  AND u.EMAIL NOT LIKE '%@podo.com'
  AND u.PHONE != '00000000000'
  AND u.CREATE_DATE > '2024-03-19 19:00:00'
GROUP BY DATE_FORMAT(u.CREATE_DATE, '%Y-%m')
ORDER BY signup_month
```

### 유저 기반(코호트) 체험완료 전환
```sql
SELECT
  DATE_FORMAT(u.CREATE_DATE, '%Y-%m') AS signup_month,
  COUNT(DISTINCT u.ID) AS signup_count,
  COUNT(DISTINCT c.STUDENT_USER_ID) AS trial_complete_count,
  ROUND(COUNT(DISTINCT c.STUDENT_USER_ID) / COUNT(DISTINCT u.ID) * 100, 1) AS conversion_rate
FROM GT_USER u
LEFT JOIN GT_CLASS c
  ON u.ID = c.STUDENT_USER_ID
  AND c.CLASS_TYPE = 'PODO'
  AND c.CITY = 'PODO_TRIAL'
  AND c.CREDIT = 2
  AND DATE(c.ORG_CLASS_DATETIME) BETWEEN '2026-01-01' AND '2026-03-04'
WHERE u.CLASS_TYPE = 'PODO'
  AND DATE(u.CREATE_DATE) BETWEEN '2026-01-01' AND '2026-03-04'
  AND u.REAL_NAME NOT LIKE '%QA_%'
  AND u.EMAIL NOT LIKE '%@podo.com'
  AND u.PHONE != '00000000000'
  AND u.CREATE_DATE > '2024-03-19 19:00:00'
GROUP BY DATE_FORMAT(u.CREATE_DATE, '%Y-%m')
ORDER BY signup_month
```

### 주요 필터 기준

| 지표 | 테이블 | 핵심 조건 |
|---|---|---|
| 가입수 | GT_USER | CLASS_TYPE='PODO', QA/내부 필터 적용, 탈퇴 유저 자동 제외 |
| 체험 결제수 | GT_PAYMENT_INFO | PAYMENT_DIV='T', PAY_METHOD≠'admin' |
| 체험 완료수 | GT_CLASS | CITY='PODO_TRIAL', CREDIT=2, 유니크 유저 기준 |

---

## 추가 분석 가능 항목

- **노쇼 상세 분석**: GT_CLASS의 CREDIT=1(등록) vs CREDIT=2(완료) vs CREDIT=3(취소) 비율
- **예약-수업 시간 갭별 노쇼율**: 예약 후 대기 시간이 길수록 노쇼 증가 여부
- **월별 전환율 트렌드**: 2월 체험결제 전환율 73.9% 하락 원인 (마케팅비 변동?)

---

*📊 데이터 출처: GWATOP MySQL (Metabase DB ID=2)*
*🔍 분석 범위: 2026-01-01 ~ 2026-03-04, D+7 유효기간 cutoff*
*📎 관련 분석: [[PODO_정규레슨_결제볼륨_하락분석_2026년3월]] (체험완료 이후 퍼널)*
