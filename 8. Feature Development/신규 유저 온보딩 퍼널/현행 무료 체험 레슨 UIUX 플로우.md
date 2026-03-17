---
title: 현행 무료 체험 레슨 UI/UX 플로우
date: 2026-03-17
type: ux-analysis
parent: "[[PRD - 신규 유저 온보딩 퍼널]]"
tags:
  - UIUX
  - 온보딩
  - 체험레슨
  - Squad-C
---

# 현행 무료 체험 레슨 UI/UX 플로우

> **분석 대상**: podo-app (Next.js), podo-backend (Spring), podo-ui-flows
> **분석 기준일**: 2026-03-17
> **목적**: 온보딩 퍼널 전환 작업을 위한 현행 체험 레슨 플로우 정밀 분석

---

## 전체 퍼널 다이어그램

```
다운로드 → 로그인 → [서버: 체험 대상 판별]
  → 홈 (자동 리다이렉트) → 체험 구매 화면 (0원)
  → 홈 + 튜토리얼 가이드 (5 STEP)
  → 체험 레슨 목록 → 예약 → [선택적: 예습]
  → 수업 진행 (Zoom 25분) → 리뷰 (문제풀기)
  → 리뷰 완료 ("잘했어요!") → [NPS 서베이]
  → 홈 → 정규 결제 유도 (/subscribes/tickets)
```

---

## 화면별 상세 분석

### 화면 1: 앱 최초 실행 — 게이트웨이

| 항목 | 내용 |
|------|------|
| **라우트** | `/` (내부) |
| **파일** | `apps/web/src/app/(internal)/page.tsx` |

- RN WebView에서 열면 `AppGatewayPage`, 웹 브라우저면 `WebGatewayPage`
- 인증 토큰 없으면 → 로그인 화면으로 리다이렉트
- 토큰 있으면 → OAuth 콜백으로 이동

---

### 화면 2: 로그인

| 항목 | 내용 |
|------|------|
| **라우트** | `/login` |
| **파일** | `apps/web/src/views/login/view.tsx` |

- **카카오 로그인** / **애플 로그인** 버튼
- `trial_free` 피처 플래그 ON → 배너 이미지가 `login_event_banner_free_trial.png`으로 변경 (무료 체험 강조)
- 로그인 성공 → OAuth 콜백 처리

---

### 화면 3: OAuth 콜백 — 자동 분기 (화면 없음)

| 항목 | 내용 |
|------|------|
| **파일** | `apps/web/src/server/domains/oauth/kakao/controller/login.handler.ts` |

서버에서 사용자 상태를 판별:

```
조건 (체험 유도 대상):
  trialClassCompYn === 'N'  (체험 미완료)
  AND paymentYn === 'N'     (정규 결제 없음)
  AND trialPaymentYn === 'N' (체험권 미구매)
→ /home?redirection=trial 로 이동
```

---

### 화면 4: 홈 화면 → 자동 리다이렉트

| 항목 | 내용 |
|------|------|
| **라우트** | `/home` 또는 `/home?redirection=trial` |
| **파일** | `apps/web/src/features/home-redirection/ui/home-redirection.tsx` |

- `?redirection=trial` 파라미터 감지
- `localStorage`에 `podo_auto_redirected=trial` 저장 (1회만 동작)
- **자동으로 `/subscribes/trial`로 리다이렉트**

> 홈에 머무는 경우 `TrialBanner`와 `TrialTutorial` 컴포넌트가 체험 수업을 안내

---

### 화면 5: 체험 레슨 구매 화면 ⭐ (핵심)

| 항목 | 내용 |
|------|------|
| **라우트** | `/subscribes/trial` |
| **파일** | `apps/web/src/views/trial-subscribes/view.tsx` |
| **뷰모델** | `apps/web/src/views/trial-subscribes/model/use-trial-subscribe-view-model.ts` |
| **Figma** | [체험레슨 신청](https://www.figma.com/design/DUFbC6C797d9jW5HsjFh9S/-PODO--APP-DESIGN?node-id=455-3798) |

**화면 구성:**
1. 언어 선택 — 영어 / 일본어
2. 레벨 선택 — 초급(B) / 중급(C1) / 중고급(C2) / 고급(D)
3. 결제 금액 — **0원 무료** (1회차) / 10,000원 (2회차)
4. 결제 수단 — 무료면 스킵
5. 이용약관 동의
6. "체험레슨 예약하기" 버튼

**1회차/2회차 분기 로직:**
```typescript
const isFirstTrialSubscribe = selectedSubscribe.subPrice === 500
const isTrialFreeEnabled = trialFreeFlag.enabled && isFirstTrialSubscribe
// isTrialFreeEnabled === true → handleTrialFreePayment (결제 UI 스킵)
// isTrialFreeEnabled === false → 유료 결제 플로우
```

**백엔드 처리:**
- 무료: BFF `/api/payment/trial-free` → 웹훅 `?payment_type=TRIAL_FREE&amount=0`
- `TrialPaymentProcessor`가 수강권(7일 만료) + 구독 매핑 생성
- ⚠️ `TRIAL_FREE`는 수업방(`GT_CLASS`) 자동 생성 안 함 (`TRIAL`만 생성)

> **🔴 제거 대상**: 유료 체험 결제(TRIAL) 관련 UI/로직 전체 제거 예정. 2회차 10,000원 유료 체험도 폐지.

---

### 화면 6: 홈 (체험 구매 완료) + 튜토리얼 가이드

| 항목 | 내용 |
|------|------|
| **라우트** | `/home` |
| **파일** | `apps/web/src/features/trial-tutorial/ui/tutorial.tsx` |
| **스키마** | `apps/web/src/entities/trial-tutorial/model/schema.ts` |
| **API** | `GET /api/v1/user/podo/getTrialStepInfo` / `POST /api/v1/user/podo/insertStep` |

구매 완료 후 홈에 5단계 체험 튜토리얼 가이드 표시:

| STEP | 이름 | 설명 | 버튼 |
|------|------|------|------|
| 1 | 레슨 예약 | 인기 시간대 안내 | "예약하기" → `/subscribes` |
| 2 | 레슨 미리보기 | 영상 & 간접체험 | "영상보기" (YouTube) / "레슨 간접체험" |
| 3 | 태블릿/PC로 이동 | 디지털 학습지 안내 | "완료" 버튼 |
| 4 | 예습하기 | 사전 예습 | "예습 하기" |
| 5 | 레슨하기 | 10분 전 입장 활성화 | "입장하기" |

---

### 화면 7: 체험 레슨 목록/상세

| 항목 | 내용 |
|------|------|
| **라우트** | `/lessons/trial?langType=EN` |
| **파일** | `apps/web/src/widgets/trial-lesson-detail-list/trial-lesson-detail-list.tsx` |
| **액션 버튼** | `apps/web/src/features/booking-lesson/ui/trial-lesson-booking-action-buttons/trial-lesson-booking-action-buttons.tsx` |
| **Figma** | [체험레슨 신청](https://www.figma.com/design/DUFbC6C797d9jW5HsjFh9S/-PODO--APP-DESIGN?node-id=455-3798) |

**API (병렬 호출):**
```typescript
await Promise.all([
  trialLessonDetail({ bearerToken, langType }),
  tickets({ bearerToken }),
  getCurrentUser({ bearerToken }),
])
```

**카드 상태별 액션:**

| 수업 상태 | 버튼 | 이동 |
|-----------|------|------|
| 미예약 (`NOT_RESERVED`) | "예약하기" + "학습 및 수강" | → 예약 화면 |
| 예약됨 (변경가능) | "예약변경" + "학습 및 수강" | → 예약 변경 |
| 예약됨 (변경불가) | "예약취소" + "학습 및 수강" | — |
| 완료 (`COMPLETED`) | "다시보기" / "리포트 보기" | → `/lessons/ai/trial-report/{uuid}` |

---

### 화면 8: 예약

| 항목 | 내용 |
|------|------|
| **라우트** | `/booking?classId={id}&type=new&classType=trial` |
| **피처 플래그** | `migration_booking_react` (React/PHP 분기) |
| **Figma** | [예약](https://www.figma.com/design/DUFbC6C797d9jW5HsjFh9S/-PODO--APP-DESIGN?node-id=4707-16463) |

**화면 구성:**
1. 날짜 선택 — 주 단위 날짜 칩 (수평 스크롤)
2. 시간대 선택 — 가능/마감/선택됨 상태 그리드
3. "선택한 날짜에 예약" CTA → 예약 확인 다이얼로그
4. 예약 완료 → 예약 목록으로 이동

**엣지 케이스:**
- 수강권 없음 → "사용 가능한 회차권이 없습니다"
- 가능 일정 없음 → "예약 가능한 일정이 없어요"
- 서버사이드: `type=new`일 때 `hasAvailableDates()` 확인 → 없으면 `/subscribes`로 리다이렉트

---

### 화면 9: 예습 (Pre-Study) — 선택적

| 항목 | 내용 |
|------|------|
| **라우트** | `/lessons/classroom/{classID}?langType=EN&...` (PRE_STUDY 모드) |

- `langType` 파라미터 + 수업 시작 전 → **예습 모드** 자동 감지
- `pre_zoom_join_url`로 예습 환경 접속
- 1분마다 `updatePreStudyTime` API 호출로 예습 시간 기록
- 종료 시 → 이전 화면 복귀 (리뷰 없음)

---

### 화면 10: 수업 진행 (Classroom)

| 항목 | 내용 |
|------|------|
| **라우트** | `/lessons/classroom/{classID}?level=&week=&permission=&sessionId=` |
| **피처 플래그** | `classroom_migration` (React/PHP 분기) |

- **Zoom iframe embed**로 실시간 수업 진행 (25분)
- 헤더 버튼: 강의 영상(보라) / MP3(파랑) / 나가기(검정)
- 나가기 → "정말 나가시겠어요?" 확인 → `requestFinishPodoClass` API
- 수업 완료 시 → 리뷰 화면으로 자동 이동

**백엔드 상태 변화:** `GT_CLASS.credit: 1(REGIST) → 2(DONE)`, `class_state → 'FINISH'`

---

### 화면 11: 수업 리뷰

| 항목 | 내용 |
|------|------|
| **라우트** | `/lessons/classroom/{classID}/review?feedbackIds=...` |
| **Figma** | [복습](https://www.figma.com/design/DUFbC6C797d9jW5HsjFh9S/-PODO--APP-DESIGN?node-id=21498-8538) |

`@use-funnel` 라이브러리로 문제를 스텝 관리:

| 유형 | UI |
|------|-----|
| `BLANK_FILLING` | 텍스트 입력 (빈칸 채우기) |
| `SENTENCE_MAKING` | 단어 카드 드래그앤드롭 |
| `MULTI_CHOICE_SENTENCE` | 4지선다 (문장) |
| `MULTI_CHOICE_WORD` | 4지선다 (단어) |

- 정답 → 초록 토스트 "정답입니다!" → "다음"
- 오답 → 빨간 토스트 + AI 설명 + 정답 표시 → "다음"
- 마지막 문제 완료 → 리뷰 완료 화면

---

### 화면 12: 리뷰 완료

| 항목 | 내용 |
|------|------|
| **라우트** | `/lessons/classroom/{classID}/review-complete` |
| **Figma** | [리뷰 완료](https://www.figma.com/design/DUFbC6C797d9jW5HsjFh9S/-PODO--APP-DESIGN?node-id=21498-8538) |

1. `CheerupIconLottie` 애니메이션 (2초)
2. "잘했어요!" 화면 표시
3. NPS 서베이 (피처 플래그 `TBD_260219_NPS_INAPP` ON이면)
4. CTA: "다음 레슨 예약하기" → `/home`

---

### 화면 13: 홈 (체험 완료 후) → 정규 결제 유도

| 항목 | 내용 |
|------|------|
| **라우트** | `/home` |
| **파일** | `apps/web/src/features/home-redirection/ui/home-redirection.tsx` |

```
trialClassCompYn === 'Y' (체험 완료) AND paymentYn === 'N' (정규 미결제)
→ 자동으로 /subscribes/tickets?paymentType=SUBSCRIBE 이동
```

정규 결제 완료 시 → 백엔드에서 체험 수업/수강권 자동 취소 (`cancelTrialLecture`)

---

## 유료 vs 무료 체험 데이터 (Metabase 조회, 2026-03-17 기준)

### 전체 누적

| 결제 유형 | 건수 | 비중 |
|-----------|------|------|
| 유료 500원 (1회차) | 35,399건 | 77% |
| 무료 0원 (1회차) | 9,599건 | 21% |
| 유료 10,000원 (2회차) | 944건 | 2% |
| 기타 100원 | 87건 | <1% |

### 월별 추이 (2025.01 ~ 2026.03)

| 월 | 무료 0원 | 유료 500원 | 유료 10,000원 |
|-----|---------|-----------|--------------|
| 2025-01 | 514 | **2,338** | 58 |
| 2025-02 | 61 | **2,273** | 42 |
| 2025-03 | 43 | **2,573** | 111 |
| 2025-04 | 40 | **1,927** | 58 |
| 2025-05 | 44 | **1,532** | 49 |
| 2025-06 | 69 | **1,842** | 30 |
| 2025-07 | 62 | **2,594** | 48 |
| 2025-08 | 62 | **2,176** | 36 |
| 2025-09 | 91 | **1,692** | 43 |
| 2025-10 | 34 | **1,555** | 34 |
| 2025-11 | 28 | **1,540** | 48 |
| **2025-12** | 882 | **1,245** | 61 |
| **2026-01** | **3,299** | 0 | 58 |
| **2026-02** | **2,698** | 0 | 43 |
| **2026-03** (진행중) | **1,245** | 0 | 29 |

> **전환 시점**: 2025년 12월 `trial_free` 피처 플래그 활성화. 2026년 1월부터 500원 유료 체험 완전 폐지.

---

## 백엔드 핵심 데이터 모델

### 결제 타입

| PaymentType | 설명 | 수업방 자동 생성 |
|-------------|------|-----------------|
| `TRIAL` | 유료 체험 (500원/10,000원) | O |
| `TRIAL_FREE` | 무료 체험 (0원) | X |

### 사용자 상태 필드 (userInfo)

| 필드 | 의미 |
|------|------|
| `paymentYn` | 정규 수업권 결제 여부 (Y/N) |
| `trialPaymentYn` | 체험권 결제 여부 (Y/N) |
| `trialClassCompYn` | 체험 수업 완료 여부 (Y/N) |

**체험 유도 조건:** `trialClassCompYn === 'N' && paymentYn !== 'Y' && trialPaymentYn !== 'Y'`

### 체험 완료 판정 (GT_CLASS)

```sql
city = 'PODO_TRIAL' AND (
  credit = '2'  -- 정상 완료
  OR class_state IN ('PREFINISH', 'FINISH')
  OR (credit = '3' AND noshow_datetime IS NOT NULL AND tutor_price_per_class > 0)  -- 노쇼(패널티)도 완료 처리
)
```

### 체험 수강권 (GT_CLASS_TICKET)

| 필드 | 값 |
|------|-----|
| `event_type` | `PODO_TRIAL` |
| `class_type` | `PODO` |
| `n_purchased` | 1 |
| 유효기간 | 7일 (SmartTalk은 1일) |
| `class_minute` | 25 |

---

## 관련 피처 플래그

| 플래그 | 효과 |
|--------|------|
| `trial_free` | 첫 체험권 500원 → 0원 무료화 |
| `ENABLE_REACT_HOME` | 홈 화면 React vs PHP |
| `migration_booking_react` | 예약 화면 React vs PHP |
| `classroom_migration` | 수업 진행 화면 React vs PHP |
| `RESERVATION_MIGRATION` | `/booking` vs `/reservation` 경로 |
| `TBD_260219_NPS_INAPP` | 리뷰 완료 후 NPS 서베이 |

---

## SmartTalk 체험 (별도 제품 라인)

일반 튜터 체험과 별개로 AI 기반 대화형 수업 체험 경로가 존재:

| 항목 | 일반 체험 | SmartTalk 체험 |
|------|----------|---------------|
| 수업 형태 | 실제 튜터 Zoom 1:1 (25분) | AI 대화형 수업 |
| 홈 화면 | `/home` (Basic) | `/home/ai` (Smart Talk) |
| 구매 경로 | `/subscribes/trial` | `/subscribes/trial/smart-talk` |
| 수강권 유효기간 | 7일 | 1일 |
| curriculumType | 일반 | `SMART_TALK` |

---

## 라우트 전체 맵

| 단계 | 화면 | 라우트 |
|------|------|--------|
| 1 | 게이트웨이 | `/` |
| 2 | 로그인 | `/login` |
| 3 | OAuth 콜백 | `/callback/oauth/redirect` |
| 4 | 홈 (자동 리다이렉트) | `/home?redirection=trial` |
| 5 | 체험 구매 | `/subscribes/trial` |
| 6 | 홈 + 튜토리얼 | `/home` |
| 7 | 체험 레슨 목록 | `/lessons/trial?langType=EN` |
| 8 | 예약 | `/booking?classId={}&type=new&classType=trial` |
| 9 | 예습 | `/lessons/classroom/{id}?langType=EN` (PRE_STUDY 모드) |
| 10 | 수업 진행 | `/lessons/classroom/{id}` (CLASS 모드) |
| 11 | 수업 리뷰 | `/lessons/classroom/{id}/review` |
| 12 | 리뷰 완료 | `/lessons/classroom/{id}/review-complete` |
| 13 | 체험 리포트 | `/lessons/ai/trial-report/{uuid}` |
| 14 | 정규 결제 유도 | `/subscribes/tickets?paymentType=SUBSCRIBE` |

---

## 핵심 소스 파일 참조

| 목적 | 파일 경로 (podo-app) |
|------|---------------------|
| 앱 진입 게이트웨이 | `apps/web/src/app/(internal)/page.tsx` |
| 로그인 화면 | `apps/web/src/views/login/view.tsx` |
| OAuth 콜백 (trial 판별) | `apps/web/src/server/domains/oauth/kakao/controller/login.handler.ts` |
| 홈 자동 리다이렉트 | `apps/web/src/features/home-redirection/ui/home-redirection.tsx` |
| 체험권 구매 화면 | `apps/web/src/views/trial-subscribes/view.tsx` |
| 체험권 구매 뷰모델 | `apps/web/src/views/trial-subscribes/model/use-trial-subscribe-view-model.ts` |
| 무료 결제 BFF API | `apps/web/src/server/domains/payment/controllers/trial-free/index.ts` |
| 체험 레슨 상세 목록 | `apps/web/src/widgets/trial-lesson-detail-list/trial-lesson-detail-list.tsx` |
| 체험 레슨 액션 버튼 | `apps/web/src/features/booking-lesson/ui/trial-lesson-booking-action-buttons/` |
| 튜토리얼 컴포넌트 | `apps/web/src/features/trial-tutorial/ui/tutorial.tsx` |
| 자가 테스트 화면 | `apps/web/src/views/selftest/view.tsx` |

| 목적 | 파일 경로 (podo-backend) |
|------|------------------------|
| 결제 웹훅 진입점 | `applications/payment/controller/PaymentController.java` |
| 결제 오케스트레이션 | `applications/payment/gateway/PaymentGateway.java` |
| 체험 결제 프로세서 | `applications/payment/processor/TrialPaymentProcessor.java` |
| 체험 수업 생성 | `applications/user/service/UserInfoServiceImpl.java` (createPodoTrialClass) |
| 체험 수강권 생성/취소 | `applications/ticket/service/TicketServiceV2Impl.java` |
| 체험 완료 여부 판단 | `applications/user/gateway/UserGateway.java` |

---

## 온보딩 전환 작업 시 참고 사항

1. **유료 체험 결제 UI 전체 제거**: `TRIAL` 결제 타입, 카드 등록, 결제 수단 선택 UI 모두 불필요. `TRIAL_FREE`만 유지하거나 결제 프로세스 자체를 온보딩 플로우로 대체.
2. **`TRIAL_FREE`는 수업방 미생성**: 무료 체험은 결제 시 `GT_CLASS`가 자동 생성되지 않음. 수업방 생성이 별도 시점에 필요.
3. **노쇼도 체험 완료 처리**: 패널티 노쇼(`credit=3`)도 `trialClassCompYn='Y'`로 판정됨.
4. **정규 결제 시 체험 자동 취소**: 정규 결제 완료 → `cancelTrialLecture()` → 체험 수업/수강권 자동 취소.
5. **SmartTalk은 별도 경로**: 일반 체험과 SmartTalk 체험은 구매/수강/유효기간이 모두 다름. 온보딩 전환 시 SmartTalk 포함 여부 결정 필요.
