---
scope_id: "onboarding-funnel-v2-20260323-001"
version: "1.0"
status: "reviewed"
created_at: "2026-03-23"
drafted_at: "2026-03-27"
reviewed_at: "2026-03-27"
review_method: "ooo pm interview"
projectInfo:
  name: "PODO"
  service_type: "외국어 전화 수업 앱"
  domain_entities:
    - User (GT_USER)
    - UserOnboarding (GT_USER_ONBOARDING)
    - PaymentInfo (GT_PAYMENT_INFO)
    - ClassTicket (GT_CLASS_TICKET)
    - Class (GT_CLASS)
    - AlarmManage (GT_ALARM_MANAGE)
  enums:
    onboarding_status: [NOT_STARTED, IN_PROGRESS, COMPLETED, SKIPPED]
    onboarding_step: [INTRO, LANGUAGE, GOAL, EXPERIENCE, FREQUENCY, PREFERRED_TIME, CLASS_STYLE, CLASS_LENGTH, RESULT, BOOKING, NOTIFICATION, COMPLETE]
    language: [en, ja]
    experience_level: [1, 2, 3, 4, 5]
    class_length_preference: [10, 25, 40]
inputDocuments:
  brief: { path: "inputs/brief.md" }
  align_packet: { path: "build/align-packet.md" }
  exploration_log: { path: "build/exploration-log.md" }
  surface_preview: { path: "surface/preview/index.html" }
  v1_reference:
    align_packet: { path: "../onboarding-funnel-20260319-001/build/align-packet.md" }
    build_spec: { path: "../onboarding-funnel-20260319-001/build/build-spec.md" }
constraintSummary:
  total: 5
  inject: 3
  defer: 2
changeLog:
  - { event: "scope.created", date: "2026-03-23", summary: "v2 scope 생성" }
  - { event: "exploration.completed", date: "2026-03-23", summary: "6 phase exploration 완료" }
  - { event: "align.locked", date: "2026-03-23", summary: "범위 합의 + approve" }
  - { event: "surface.confirmed", date: "2026-03-23", summary: "v2 프로토타입 생성" }
  - { event: "pm.reviewed", date: "2026-03-27", summary: "ooo pm 인터뷰 기반 PRD 리뷰 완료" }
---

# Product Requirements Document — 온보딩 퍼널 v2

## Brownfield Sources

| 소스 | 핵심 정보 |
|------|----------|
| podo-backend (Spring Boot 3.5) | AuthGateway.java (OAuth + 신규 유저 생성), PodoUserDto (trialPaymentYn/paymentYn), FeatureFlagService (Flagsmith), NotificationController (멀티 채널) |
| podo-app (Next.js 15) | redirect/page.tsx (OAuth 콜백), trial-subscribes/view.tsx (기존 체험 신청), HomeRedirection (라우팅 분기) |
| v1 build-spec | GT_USER_ONBOARDING 테이블 설계, API 엔드포인트 구조, 프론트엔드 라우트 구조 |
| ClickHouse 이벤트 DB | 체험 구매 유저 89.5%가 5분 이내 결정 (v1 참고) |

---

## Executive Summary

PODO 앱의 온보딩 퍼널 v1에서 팀 내부 피드백을 반영하여 v2를 설계한다.

**v1의 문제점:**
1. **레벨 테스트 유효성** — 단어/문법 객관식 6문항이 스피킹 앱의 실제 말하기 실력을 진단하지 못함
2. **이탈 우려** — 온보딩 중간의 테스트 6문항이 허들로 작용
3. **personalization 부족** — 학습 스타일, 선호 시간, 수업 방식 등 개인화 정보 미수집

**v2 방향:**
- 레벨 테스트 삭제 → 말하기 경험 자가 평가 기반 레벨 결정 (체험 예약 시 유저가 직접 변경 가능)
- personalization 질문 추가 — 수업 빈도, 선호 시간대, 수업 스타일, 수업 길이(리서치 목적)
- 전체 온보딩 UX를 PODO 캐릭터와의 대화형 인터랙션으로 재설계
- "7가지만 물어볼게요!" 사전 안내로 유저의 심리적 부담 감소

### Goal Metrics

| Metric | Current (As-is) | Target (v2) |
|--------|-----------------|-------------|
| 온보딩 완료율 | 측정 불가 (온보딩 플로우 부재) | 70%+ |
| 체험 예약 전환율 | 기존 /subscribes/trial 전환율 기준 (베이스라인: podo-analysis 볼트 "회원가입 → 체험완료 퍼널 분석" 문서 참조) | +15% 이상 향상 |
| 체험 완료율 | 현재 기준 대비 | +10% 향상 (추가 쿠폰 인센티브) |
| personalization 데이터 수집률 | 0% (수집 안 함) | 온보딩 완료 유저의 95%+ |

---

## Success Criteria

### User Success
- 신규 유저가 앱 설치 후 체험 예약까지 **3분 이내** 완료 가능
- PODO 캐릭터와의 대화형 인터랙션으로 **친근하고 부담 없는** 온보딩 경험 제공
- 개인화 결과 화면에서 **"나에게 맞는 수업"**이라는 확신 제공
- 이탈 후 재방문 시 처음부터 다시 하지 않고 **중단 지점부터 자동 재개**

### Business Success
- 온보딩 완료율 70% 이상 달성
- 체험 예약 전환율 기존 대비 15% 이상 향상
- 학습 스타일/선호 데이터 수집으로 향후 커리큘럼 개인화 기반 마련
- 수업 길이 선호도 리서치 데이터 확보 (10분/25분/40분 비율)

### Technical Success
- GT_USER_ONBOARDING 테이블로 온보딩 상태 완전 추적
- 피처 플래그(Flagsmith) 기반 점진적 롤아웃 (버그 대응 목적)
- 기존 /subscribes/trial 페이지와의 안전한 공존 (리다이렉트)

---

## Product Scope

### Phase 1: 온보딩 퍼널 v2

| Feature | Description | v1 대비 변경 |
|---------|-------------|-------------|
| 인트로 화면 | PODO 캐릭터 대화형으로 강화 | v1 기반 캐릭터 강화 |
| 사전 안내 화면 | "7가지만 물어볼게요!" 질문 수 사전 고지 | NEW |
| 언어 선택 | 영어/일본어 중 1개 선택 | v1 유지 |
| 학습 목표 | 복수 선택 (업무/여행/시험/취미) | v1 유지 |
| 말하기 경험 | 5단계 자가 평가 | v1 유지 (레벨 테스트 대체) |
| 수업 빈도 | 주 몇 회 수업할지 선택 | NEW |
| 선호 시간대 | 수업 선호 시간대 선택 | NEW |
| 수업 스타일 | 프리토킹/주제/토론 등 선호도 | NEW (MBTI식 튜터 매칭 대체) |
| 수업 길이 | 10분/25분/40분 선호도 (리서치 목적) | NEW |
| 나의 학습 플랜 결과 | 개인화 추천 + 세일즈 + 추가 쿠폰 안내 | NEW |
| 체험 예약 | 레벨 유저 직접 선택(워딩 구체화) + 선호 시간대 프리셋 | 레벨 테스트 → 자가 선택 |
| 예약 완료 | 사전 설명 + OS 알림 동의 + 마케팅 동의 + 예습 유도 + 추가 쿠폰 안내 | 쿠폰 안내 추가 |
| 레벨 테스트 | 삭제 | REMOVED |
| 온보딩 상태 추적 | DB/API 신규 구축 (이탈 복구) | v1 설계 기반 확장 |
| 피처 플래그 리다이렉트 | 기존 /subscribes/trial → 새 온보딩으로 | v1 유지 |

### 제외 범위

| 제외 항목 | 사유 |
|----------|------|
| 홈 화면 리뉴얼 | 변경 범위가 커서 별도 scope |
| 정기 구독 결제 퍼널 | 별도 PRD |
| 체험 완료 후 구독 전환 유도 | 별도 scope |
| 추가 쿠폰 실제 발급 로직 | 다음 PRD (체험 신청~완료 플로우) |
| 인앱 알림 | 나중에 별도 추가 예정 |
| 튜터 매칭 고도화 | 수업 스타일 데이터 수집만, 매칭 로직은 별도 |

---

## User Journeys

### Journey 1: 영어 초보, 전화 수업 불안감 높은 신규 유저 (Happy Path)

**Persona:** 수진 (28세, 대학원생, 영어 스피킹 경험 거의 없음. 외국인 앞에서 머릿속이 하얘지는 경험이 잦음.)

**Opening Scene:**
수진은 친구 추천으로 PODO 앱을 설치한다. 외국어 전화 수업이라는 컨셉에 관심이 있지만, "진짜 외국인이랑 전화하는 건가?" 하는 불안감도 있다.

**Rising Action:**

1. **인트로 화면** — 앱 실행 시 PODO 캐릭터가 등장. 3화면 스와이프:
   - "외국인 앞에 서면 머릿속이 하얘지나요?"
   - "할 말을 미리 준비하니까 긴장할 필요 없어요"
   - "25분 무료 체험, 한 번이면 충분해요"

   수진은 "교재로 미리 준비할 수 있구나" 하고 안심한다. "시작하기" 버튼을 누른다.

2. **로그인** (`/callback/oauth/`) — 카카오 로그인. 기존 OAuth 플로우 그대로.

3. **사전 안내** — PODO 캐릭터 말풍선: "반가워요! 딱 맞는 수업을 추천해 드릴게요. 7가지만 물어볼게요!" 수진은 "7개만이면 금방이네" 하고 다음으로 넘어간다.

4. **언어 선택** (`/onboarding/language`) — "어떤 언어를 배우고 싶으세요?" 영어 선택.

5. **학습 목표** (`/onboarding/goal`) — "영어 배우는 이유가 뭐예요?" "취미/자기계발" 선택.

6. **말하기 경험** (`/onboarding/experience`) — "영어로 말할 때 어떤 느낌이에요?" PODO 캐릭터 말풍선으로 질문. "긴장돼서 아는 것도 못 말해요" 선택. → 내부적으로 experience_level=2, 기본 레벨 "초급" 세팅.

7. **수업 빈도** (`/onboarding/frequency`) — "일주일에 몇 번 수업하고 싶으세요?" 주 2회 선택.

8. **선호 시간대** (`/onboarding/preferred-time`) — "언제 수업하면 좋을까요?" 평일 저녁 선택.

9. **수업 스타일** (`/onboarding/class-style`) — "어떤 수업이 좋으세요?" 프리토킹 위주 선택.

10. **수업 길이** (`/onboarding/class-length`) — "한 번에 몇 분 수업이 좋으세요?" 25분 선택.

**Climax:**

11. **나의 학습 플랜 결과** (`/onboarding/result`) — PODO 캐릭터가 결과를 보여준다:
    - "수진님의 학습 플랜이 완성됐어요!"
    - 주 2회 · 평일 저녁 · 프리토킹 위주 · 25분 수업
    - "초보도 괜찮아요! 수업 전 교재로 미리 예습하고, 편하게 전화하면 돼요"
    - "지금 무료 체험 예약하면, 체험 완료 후 다른 언어도 무료로 체험할 수 있어요!"
    - "무료 체험 예약하기" CTA 버튼

12. **체험 예약** (`/onboarding/booking`) — 레벨: "초급" (4단계 전부 노출, 변경 가능, 구체적 설명형 워딩). 선호 시간대 프리셋 적용. 수진은 레벨을 확인하고 시간을 선택한 후 예약 완료.

**Resolution:**

13. **예약 완료** (`/onboarding/complete`) —
    - 수업 진행 방식 사전 설명
    - OS 알림 동의 팝업 → 수진은 "허용" 선택
    - 마케팅 수신 동의 체크박스
    - "수업 전에 교재 한번 살펴보세요!" 예습 유도
    - "체험 완료하면 다른 언어도 무료 체험 가능!" 안내
    - 메인 화면으로 이동

    수진은 "생각보다 간단하네, 교재도 미리 볼 수 있고" 하며 안심한다.

---

### Journey 2: 일본어 중급, 업무 목적 신규 유저 (Happy Path)

**Persona:** 민수 (34세, IT 회사 PM, 일본어 일상회화 가능하지만 업무 미팅에서 말문이 막힘.)

**Opening Scene:**
민수는 일본 본사와의 화상 미팅이 늘어나면서 비즈니스 일본어 스피킹 연습이 필요하다고 느낀다. 동료가 PODO를 추천해서 설치한다.

**Rising Action:**
인트로(skip) → 카카오 로그인 → 사전 안내 "7가지만 물어볼게요!" → 일본어 선택 → "업무/비즈니스" → "일상 대화는 괜찮은데, 업무/전문 주제는 어려워요" (experience_level=4) → 주 3회 → 주말 오전 → "특정 주제 위주" → 25분

**Climax:**
학습 플랜 결과: "비즈니스 일본어 실력을 한 단계 올려볼까요! 실력에 맞는 수업 준비했어요." + 추가 쿠폰 안내. 체험 예약: "중급" 레벨 (4단계 전부 노출, 변경 가능).

**Resolution:**
예약 완료. 알림 동의. 예습 유도. 민수는 "비즈니스 주제로 연습할 수 있겠네" 하고 기대한다.

---

### Journey 3: 온보딩 중 이탈 후 재방문 (Exception Path)

**Persona:** 지은 (26세, 디자이너, 영어 초급. 온보딩 중 수업 빈도 질문에서 앱을 닫았음.)

**Opening Scene:**
지은은 3일 전 PODO를 설치하고 온보딩을 시작했지만, 수업 빈도 질문에서 "지금은 잘 모르겠다"며 앱을 닫았다.

**Rising Action:**
앱 재실행 → 로그인 유지 상태 → 시스템이 `onboardingStatus=IN_PROGRESS`, `currentStep=FREQUENCY` 감지 → 수업 빈도 질문 화면부터 자동 재개. 이전에 입력한 언어(영어), 학습 목표(취미), 말하기 경험(왕초보)은 이미 저장되어 있어 다시 묻지 않음.

**Climax:**
수업 빈도 → 선호 시간대 → 수업 스타일 → 수업 길이 → 학습 플랜 결과 → 체험 예약.

지은은 중간에 "아, 영어 말고 일본어도 괜찮을 것 같은데?" 하며 뒤로가기 버튼을 눌러 이전 화면으로 돌아간다. 이전에 입력한 응답이 그대로 남아 있어서 쉽게 수정할 수 있다. 다시 앞으로 진행.

**Resolution:**
지은은 "이전에 했던 거 다시 안 해도 되고, 뒤로가기도 되네" 하며 예약 완료.

---

### Journey 4: 이미 온보딩 완료한 재방문 유저 (Happy Path)

**Persona:** 현우 (30세, 체험 예약 완료 상태.)

**Opening Scene:**
현우는 어제 온보딩을 완료하고 체험을 예약했다. 오늘 앱을 다시 열어본다.

**Rising Action:**
앱 실행 → `onboardingStatus=COMPLETED` 확인 → 바로 홈 화면 진입. 온보딩 재실행 없음.

**Resolution:**
홈에서 예약된 체험 수업 확인. 예습 교재 열람 가능.

---

### Journey 5: 10분 수업 선호 유저 — AI 수업 안내 (Exception Path)

**Persona:** 서연 (22세, 대학생, 짧은 시간 부담 없이 연습하고 싶음.)

**Opening Scene:**
서연은 "매일 10분씩 가볍게"라는 마인드로 PODO를 설치한다.

**Rising Action:**
인트로 → 로그인 → 7개 질문 진행 → 수업 길이 질문에서 "10분" 선택.

**Climax:**
학습 플랜 결과 화면:
- "지금은 25분 수업으로 시작해 볼까요?"
- "짧게 연습하고 싶다면 AI 학습도 있어요!" + AI 수업 CTA 버튼

서연은 "일단 무료 체험 25분 해보자" 하고 체험 예약. 또는 AI 수업 탭으로 이동.

**Resolution:**
체험 예약 완료 또는 AI 학습탭 진입. 시스템은 10분 선호 데이터를 수집하여 향후 10분 수업 기획에 활용.

---

## Domain-Specific Requirements

### DR-001: 레벨 결정 정책 (source: CST-002, Exploration Phase 5)
- v2에서 레벨 테스트 삭제. 말하기 경험 자가 평가(5단계) 기반으로 기본 레벨 세팅.
- 체험 예약 화면에서 유저가 직접 레벨 변경 가능.
- 레벨 워딩은 추상적 라벨(초급/중급) 대신 **구체적 설명형 워딩** 사용.

| 말하기 경험 | 기본 레벨 | 레벨 설명 워딩 (예시) | 결과 화면 분기 |
|------------|----------|---------------------|-------------|
| ① 글자나 발음부터 배워야 해요 | 초급 | "알파벳/히라가나부터 천천히 시작해요" | 불안 해소 |
| ② 긴장돼서 아는 것도 못 말해요 | 초급 | "간단한 인사, 자기소개를 연습해요" | 불안 해소 |
| ③ 간단한 대화는 되는데 길어지면 막혀요 | 초중급 | "일상 대화를 자연스럽게 이어가요" | 불안 해소 |
| ④ 일상 대화는 괜찮은데 전문 주제는 어려워요 | 중급 | "업무, 시사 주제로 토론해요" | 동기 부여 |
| ⑤ 대부분 상황에서 자유롭게 대화해요 | 고급 | "유창하게 의견을 전달하고 토론해요" | 동기 부여 |

> **레벨 체계**: 현재 초급 / 초중급 / 중급 / 고급 (4단계). 추가 레벨 커리큘럼 디벨롭 중이나 확정 시점 미정. v2 첫 출시는 현재 4단계 기준. 레벨 매핑은 config/설정값으로 관리하여 하드코딩 금지.

### DR-002: 수업 길이 선호 — 리서치 목적 (source: CST-001)
- 현재 모든 수업은 25분 고정. 수업 길이 질문은 **리서치 데이터 수집 목적**.
- 결과 화면에서 "25분 수업으로 시작" 안내로 기대 불일치 해소.
- 10분 선택 시: AI 수업 CTA 제공.
- 40분 선택 시: "25분이 집중력에 딱 좋아요" 안내.

### DR-003: 수업 스타일 데이터 (source: CST-005, PM Review)
- 수업 스타일 선호(프리토킹/주제 중심/토론 등)를 수집하되, **첫 출시(v2.0)에서는 결과 화면 분기에 사용하지 않음**.
- **첫 출시**: 데이터 수집만. 결과 화면 분기 변수는 말하기 경험(5단계) 1개만 사용.
- **향후 업데이트(v2.x)**: 수업 스타일 선택지 확정 후(커리큘럼팀 협의) 2번째 분기 변수로 추가.
- 수업 스타일 선택지 목록이 미확정 상태이므로 연쇄 블로커가 되지 않도록 디커플링.

### DR-004: 추가 무료 체험 쿠폰 안내 (source: brief.md)
- 영어/일본어 2개 언어 중 하나의 체험 완료 시, 다른 언어 무료 체험 1회 추가.
- 이 scope에서는 **안내 문구만 포함**. 실제 쿠폰 발급 로직은 다음 PRD에서 구현.
- 안내 위치: 학습 플랜 결과 화면 + 예약 완료 화면.

### DR-005: 알림 동의 타이밍 (source: v1 CST-005)
- iOS 네이티브 알림 팝업은 앱당 1회만 표시 가능.
- 예약 완료 시점에 요청 (v1 결정 유지). 이 시점이 유저가 알림의 가치를 가장 잘 이해하는 시점.

### DR-006: 개인정보 수집 동의 (source: CST-004)
- 학습 빈도, 시간대, 수업 스타일 등 선호도 수집 시 기존 이용약관/개인정보처리방침의 커버 여부 확인 필요.
- **확인 필요**: 기존 약관 원문 대조 → 부족하면 항목 추가.

---

## Technical Requirements

### Tech Stack

| 영역 | 기술 | 비고 |
|------|------|------|
| Frontend | Next.js 15, TanStack Query | podo-app 기존 스택 |
| BFF | Hono | 기존 BFF 레이어 |
| Backend | Spring Boot 3.5, Java | podo-backend |
| DB | MySQL | GT_USER_ONBOARDING 테이블 |
| Feature Flag | Flagsmith | FeatureFlagService.java |
| Push | Expo Push + FCM/APNs | NotificationController |

### API Requirements

#### API-001: 온보딩 상태 조회
```
GET /api/v1/onboarding/status
Authorization: Bearer {token}

Response 200:
{
  "status": "NOT_STARTED" | "IN_PROGRESS" | "COMPLETED" | "SKIPPED",
  "currentStep": "LANGUAGE" | null,
  "language": "en" | null,
  "goals": ["BUSINESS", "TRAVEL"] | null,
  "experienceLevel": 2 | null,
  "frequency": 2 | null,
  "preferredTime": "WEEKDAY_EVENING" | null,
  "classStyle": "FREE_TALK" | null,
  "classLengthPreference": 25 | null,
  "recommendedLevel": "초급" | null
}
```

#### API-002: 온보딩 단계별 저장
```
PATCH /api/v1/onboarding/step
Authorization: Bearer {token}

Request:
{
  "step": "LANGUAGE",
  "data": { "language": "en" }
}

Response 200:
{
  "status": "IN_PROGRESS",
  "currentStep": "GOAL",
  "savedData": { "language": "en" }
}
```

**각 step별 data 형식:**

| step | data 필드 | 타입 |
|------|----------|------|
| `INTRO_SKIP` | `skipped: boolean` | 인트로 skip 여부 |
| `LANGUAGE` | `language: "en" \| "ja"` | 언어 선택 |
| `GOAL` | `goals: string[]` | 학습 목표 배열 |
| `EXPERIENCE` | `experienceLevel: 1~5` | 말하기 경험 |
| `FREQUENCY` | `frequency: number` | 주 N회 |
| `PREFERRED_TIME` | `preferredTime: string` | 선호 시간대 |
| `CLASS_STYLE` | `classStyle: string` | 수업 스타일 |
| `CLASS_LENGTH` | `classLengthPreference: 10 \| 25 \| 40` | 수업 길이 선호 |
| `RESULT_CONFIRM` | `marketingAgreed: boolean` | 마케팅 동의 |
| `BOOKING` | `bookingId: number` | 체험 예약 ID |
| `NOTIFICATION` | `agreed: boolean` | 알림 동의 |
| `COMPLETE` | (없음) | 온보딩 완료 |

#### API-003: 온보딩 완료 처리
```
POST /api/v1/onboarding/complete
Authorization: Bearer {token}

Response 200:
{
  "status": "COMPLETED",
  "completedAt": "2026-03-27T15:30:00"
}
```

### Database — GT_USER_ONBOARDING 테이블 (v2 확장)

```sql
CREATE TABLE GT_USER_ONBOARDING (
    id                    BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id               INT NOT NULL,
    status                VARCHAR(20) NOT NULL DEFAULT 'NOT_STARTED'
                          COMMENT 'NOT_STARTED | IN_PROGRESS | COMPLETED | SKIPPED',
    current_step          VARCHAR(30) NULL
                          COMMENT '이탈 시점 기록',
    language              VARCHAR(10) NULL
                          COMMENT 'en | ja',
    goals                 VARCHAR(200) NULL
                          COMMENT '복수 선택, 쉼표 구분: BUSINESS,TRAVEL,EXAM,HOBBY',
    experience_level      TINYINT NULL
                          COMMENT '1=왕초급, 2=긴장, 3=막힘, 4=일상OK, 5=자유',
    recommended_level     VARCHAR(20) NULL
                          COMMENT '초급 | 초중급 | 중급 | 고급',
    frequency             TINYINT NULL
                          COMMENT '주 N회 (1~7)',
    preferred_time        VARCHAR(50) NULL
                          COMMENT 'WEEKDAY_MORNING | WEEKDAY_EVENING | WEEKEND_MORNING | ...',
    class_style           VARCHAR(30) NULL
                          COMMENT 'FREE_TALK | TOPIC_BASED | DEBATE | ...',
    class_length_pref     TINYINT NULL
                          COMMENT '수업 길이 선호 (10 | 25 | 40, 리서치 목적)',
    marketing_agreed      TINYINT(1) NOT NULL DEFAULT 0,
    notification_agreed   TINYINT(1) NULL
                          COMMENT 'OS 알림 동의 여부 (null=미요청)',
    intro_skipped         TINYINT(1) NOT NULL DEFAULT 0,
    created_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at          DATETIME NULL,

    CONSTRAINT fk_onboarding_user FOREIGN KEY (user_id) REFERENCES GT_USER(id),
    UNIQUE KEY uk_user_onboarding (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**v1 대비 변경점:**
- `quiz_score`, `experience_score`, `total_score` 컬럼 삭제 (레벨 테스트 제거)
- `frequency`, `preferred_time`, `class_style`, `class_length_pref` 컬럼 추가 (personalization)
- `recommended_level` 값: 현재 4단계 (초급/초중급/중급/고급). 레벨 체계 변경 시 매핑만 업데이트

### Component Structure (Frontend)

```
apps/web/src/app/(internal)/onboarding/
├── layout.tsx                  ← 온보딩 전용 레이아웃 (GNB 숨김, 진행률 표시)
├── intro/page.tsx              ← 인트로 (스와이프 + PODO 캐릭터)
├── language/page.tsx           ← 언어 선택
├── goal/page.tsx               ← 학습 목표
├── experience/page.tsx         ← 말하기 경험
├── frequency/page.tsx          ← 수업 빈도
├── preferred-time/page.tsx     ← 선호 시간대
├── class-style/page.tsx        ← 수업 스타일
├── class-length/page.tsx       ← 수업 길이
├── result/page.tsx             ← 학습 플랜 결과
├── booking/page.tsx            ← 체험 예약
└── complete/page.tsx           ← 예약 완료 + 알림

features/onboarding/
├── api/
│   ├── onboarding.api.ts       ← API 호출 함수
│   └── onboarding.query.ts     ← queryOptions 정의
├── model/
│   └── onboarding.types.ts     ← 타입 정의
└── ui/
    ├── OnboardingProgress.tsx   ← 진행률 바 (PODO 컬러)
    ├── PodoSpeechBubble.tsx     ← PODO 캐릭터 + 말풍선 컴포넌트
    ├── OptionCard.tsx           ← 선택지 카드 (단일/복수)
    └── IntroSlider.tsx          ← 인트로 스와이프
```

### Backend Package Structure

```
applications/onboarding/
├── controller/
│   └── OnboardingController.java
├── gateway/
│   └── OnboardingGateway.java
├── service/
│   └── OnboardingService.java      ← 레벨 계산 포함 (테스트 채점 삭제)
├── repository/
│   └── UserOnboardingRepository.java
├── domain/
│   ├── UserOnboarding.java
│   ├── OnboardingStatus.java        ← enum
│   └── OnboardingStep.java          ← enum (v2 스텝 추가)
└── dto/
    ├── request/OnboardingStepRequest.java
    └── response/OnboardingStatusResponse.java
```

---

## Functional Requirements

### 인트로 화면 (`/onboarding/intro`)

- **FR-001:** 앱 첫 실행 시 PODO 캐릭터가 등장하는 3화면 스와이프 인트로 표시 (source: brief.md)
- **FR-002:** 우측 상단 "건너뛰기" 버튼으로 skip 가능 (source: v1)
- **FR-003:** 마지막 슬라이드에서 "시작하기" 버튼 → 로그인 화면으로 이동 (source: v1)
- **FR-004:** 인트로는 로그인 전이므로 서버 저장 불필요. 로컬 상태만 관리 (source: v1 build-spec)

### 사전 안내 화면

- **FR-005:** 로그인 직후, PODO 캐릭터 말풍선: "반가워요! 딱 맞는 수업을 추천해 드릴게요. 7가지만 물어볼게요!" (source: Exploration Phase 4, PM Review에서 7가지로 수정)
- **FR-006:** 질문 수를 사전 고지하여 유저의 심리적 부담 감소 (source: 모지(MojiMoji) 레퍼런스, PM Review에서 6→7 수정 확정)

### 언어 선택 (`/onboarding/language`)

- **FR-007:** "어떤 언어를 배우고 싶으세요?" — PODO 말풍선으로 질문 (source: v1)
- **FR-008:** 영어/일본어 중 1개만 선택 가능 (source: v1)
- **FR-009:** 선택 → PATCH /onboarding/step → 다음 화면 이동 (source: v1 build-spec)

### 학습 목표 (`/onboarding/goal`)

- **FR-010:** "영어/일본어 배우는 이유가 뭐예요?" — PODO 말풍선 (source: v1)
- **FR-011:** 복수 선택 가능 — 업무/비즈니스, 여행, 시험/자격증, 취미/자기계발 (source: v1)
- **FR-012:** 1개 이상 선택 시 다음 버튼 활성화 (source: v1)

### 말하기 경험 (`/onboarding/experience`)

- **FR-013:** "영어/일본어로 말할 때 어떤 느낌이에요?" — PODO 말풍선 (source: v1)
- **FR-014:** 5단계 단일 선택 (source: v1)
  - ① 글자나 발음부터 배워야 해요
  - ② 긴장돼서 아는 것도 못 말해요
  - ③ 간단한 대화는 되는데, 길어지면 막혀요
  - ④ 일상 대화는 괜찮은데, 전문 주제는 어려워요
  - ⑤ 대부분 상황에서 자유롭게 대화할 수 있어요
- **FR-015:** 선택 기반으로 기본 레벨 자동 세팅 (source: DR-001)

### 수업 빈도 (`/onboarding/frequency`)

- **FR-016:** "일주일에 몇 번 수업하고 싶으세요?" — PODO 말풍선 (source: Exploration Phase 4)
- **FR-017:** 주 1~7회 중 선택 (source: align-packet)

### 선호 시간대 (`/onboarding/preferred-time`)

- **FR-018:** "언제 수업하면 좋을까요?" — PODO 말풍선 (source: Exploration Phase 4)
- **FR-019:** 평일 아침/점심/저녁, 주말 아침/점심/저녁 중 선택 (source: align-packet)
- **FR-020:** 선택한 시간대는 체험 예약 화면에서 프리셋으로 적용 (source: align-packet)

### 수업 스타일 (`/onboarding/class-style`)

- **FR-021:** "어떤 수업이 좋으세요?" — PODO 말풍선 (source: Exploration Phase 5)
- **FR-022:** 프리토킹/주제 중심/토론/기타 중 선택 (source: Exploration Phase 5, 튜터 성향 → 수업 스타일로 변경)
- **FR-023:** 수집 데이터는 결과 화면 추천 문구에만 반영. 커리큘럼 매핑은 향후 (source: DR-003)

### 수업 길이 (`/onboarding/class-length`)

- **FR-024:** "한 번에 몇 분 수업이 좋으세요?" — PODO 말풍선 (source: Exploration Phase 4 Round 2)
- **FR-025:** 10분/25분/40분 중 선택 (source: align-packet)
- **FR-026:** 리서치 목적 수집. 실제 수업은 25분 고정 (source: DR-002)

### 나의 학습 플랜 결과 (`/onboarding/result`)

- **FR-027:** PODO 캐릭터가 입력 기반 개인화 학습 플랜 표시 (source: align-packet)
- **FR-028:** 결과 구성 요소:
  - 수업 빈도 + 선호 시간대 + 수업 스타일 요약
  - "25분 수업으로 시작" 안내 (수업 길이 불일치 해소)
  - **[첫 출시 분기 변수: 말하기 경험만]** experience_level 1~3: 불안 해소 메시지 ("초보도 괜찮아요! 수업 전 교재로 미리 예습하고, 편하게 전화하면 돼요")
  - **[첫 출시 분기 변수: 말하기 경험만]** experience_level 4~5: 동기 부여 메시지 ("실력에 맞는 수업 준비했어요. 한 단계 더 올라가 볼까요?")
  - 추가 쿠폰 안내: **안내 문구만** — "체험 완료하면 다른 언어도 무료 체험 가능!" (실제 쿠폰 발급 로직 없음)
  - "무료 체험 예약하기" CTA → 체험 예약 화면 이동 (가격표/정기구독 결제 CTA 없음)
  - **[향후 v2.x]** 수업 스타일을 2번째 분기 변수로 추가 예정 (커리큘럼팀 협의 후)
- **FR-029:** 10분 선택 유저: AI 수업 CTA 추가 표시 (source: Exploration Phase 4 Round 2)
- **FR-030:** 40분 선택 유저: "25분이 집중력에 딱 좋아요" 안내 (source: Exploration Phase 5)
- **FR-031:** "무료 체험 예약하기" CTA 버튼 (source: align-packet)
- **FR-032:** 마케팅 수신 동의 체크박스 (기본 미체크) (source: v1)

### 체험 예약 (`/onboarding/booking`)

- **FR-033:** 말하기 경험 기반 기본 레벨 프리셋 (source: DR-001) [BROWNFIELD: 기존 예약 API 활용]
- **FR-034:** 레벨 설명은 구체적 설명형 워딩 사용 (source: CST-002)
- **FR-035:** 유저가 레벨을 직접 변경 가능 + "언제든 변경할 수 있어요" 안내 (source: align-packet)
- **FR-036:** 선호 시간대 프리셋 적용 — 온보딩에서 선택한 시간대 기반 (source: align-packet)
- **FR-037:** 기존 체험 예약 API 사용 [BROWNFIELD] (source: v1 build-spec)

### 예약 완료 (`/onboarding/complete`)

- **FR-038:** 수업 진행 방식 사전 설명 (source: v1)
- **FR-039:** OS 알림 동의 팝업 표시 — 예약 완료 시점 (source: DR-005)
- **FR-040:** 마케팅 수신 동의 (source: v1)
- **FR-041:** 예습 유도 문구: "수업 전에 교재 한번 살펴보세요!" (source: v1)
- **FR-042:** 추가 쿠폰 안내: "체험 완료하면 다른 언어도 무료 체험 가능!" (source: DR-004)
- **FR-043:** "메인으로 가기" 버튼 → 홈 화면 이동 (source: v1)

### 온보딩 상태 추적

- **FR-044:** 신규 유저 생성 시 GT_USER_ONBOARDING 레코드 자동 생성 (status=NOT_STARTED) (source: v1 build-spec)
- **FR-045:** 각 단계 완료 시 currentStep 업데이트 — 이탈 복구 지점 기록 (source: CST-003)
- **FR-046:** 이전 step 미완료 상태에서 다음 step 저장 시도 → 400 에러 (source: v1 build-spec)
- **FR-047:** 재방문 시 currentStep 기반 자동 재개 (source: align-packet 시나리오 3)
- **FR-047a:** 뒤로가기로 이전 화면 이동 → 이전 응답 수정 가능 (단순 폼 다시 채우기, 대화 맥락 유지 없음) (source: PM Review)

### 라우팅 분기

- **FR-048:** 피처 플래그 ON 시 HomeRedirection 로직 변경 (source: v1 build-spec):
  - `onboardingStatus === "NOT_STARTED"` → `/onboarding/intro`
  - `onboardingStatus === "IN_PROGRESS"` → `/onboarding/{currentStep}`
  - `onboardingStatus === "COMPLETED"` → `/` (홈)
- **FR-049:** 기존 /subscribes/trial 접근 시 피처 플래그 ON이면 새 온보딩으로 리다이렉트 [BROWNFIELD] (source: v1)

### UX 전체

- **FR-050:** 전체 온보딩 UX — PODO 캐릭터 말풍선 비주얼의 스텝 폼. **빠른 진행 우선, 애니메이션 최소화**. 채팅형 히스토리 누적 UX 아님 — 각 질문은 독립된 화면. (source: brief.md, PM Review)
- **FR-051:** 한 화면 = 한 질문 원칙 (source: Exploration Phase 4)
- **FR-052:** 진행률 바 표시 — PODO 연두색(#B5FD4C) (source: Surface Preview)

---

## Non-Functional Requirements

### Performance
- 각 step 저장 API 응답 시간 < 300ms
- 온보딩 전체 로딩(첫 화면 ~ 인터랙션 가능) < 1.5s

### Reliability
- 네트워크 에러 시 재시도 (TanStack Query 기본 retry)
- step 저장 실패 시 에러 메시지 표시 + 재시도 버튼

### Security
- 모든 온보딩 API는 Bearer 토큰 인증 필수
- 타인의 온보딩 데이터 접근 불가 (user_id 검증)

### Error Handling
- 온보딩 상태 조회 실패 시: 기존 /subscribes/trial로 폴백 [BROWNFIELD]
- step 순서 위반 시: 400 에러 + 올바른 step 안내

---

## QA Considerations

### Happy Path (Priority: HIGH)

| Case | Scenario | Expected Handling |
|------|----------|-------------------|
| QA-001 | 신규 유저 전체 플로우 완주 | 인트로 → 로그인 → 7개 질문 → 결과 → 예약 → 완료. 모든 데이터 GT_USER_ONBOARDING에 저장 |
| QA-002 | 인트로 skip 후 전체 플로우 | skip → 로그인 → 7개 질문. intro_skipped=true 저장 |
| QA-003 | 영어/일본어 각각 전체 플로우 | 언어별 정상 동작 확인 |

### 이탈 복구 (Priority: HIGH)

| Case | Scenario | Expected Handling |
|------|----------|-------------------|
| QA-004 | 수업 빈도에서 이탈 → 재방문 | 수업 빈도 화면부터 재개. 이전 입력값 유지 |
| QA-005 | 결과 화면에서 이탈 → 재방문 | 결과 화면부터 재개 |
| QA-006 | 예약 화면에서 이탈 → 재방문 | 예약 화면부터 재개. 레벨/시간 프리셋 유지 |

### 수업 길이 분기 (Priority: MEDIUM)

| Case | Scenario | Expected Handling |
|------|----------|-------------------|
| QA-007 | 10분 선택 | 결과 화면에 AI 수업 CTA 표시 |
| QA-008 | 25분 선택 | 결과 화면 기본 표시 |
| QA-009 | 40분 선택 | "25분이 집중력에 딱 좋아요" 안내 표시 |

### 레벨 선택 (Priority: MEDIUM)

| Case | Scenario | Expected Handling |
|------|----------|-------------------|
| QA-010 | 말하기 경험 ①(왕초보) | 기본 레벨 "초급" 프리셋 |
| QA-011 | 체험 예약에서 레벨 변경 | 변경된 레벨로 예약 생성 |

### 피처 플래그 (Priority: HIGH)

| Case | Scenario | Expected Handling |
|------|----------|-------------------|
| QA-012 | 피처 플래그 OFF | 기존 /subscribes/trial 플로우 유지 |
| QA-013 | 피처 플래그 ON + 기존 유저 | onboardingStatus 없는 기존 유저 → COMPLETED 간주 → 홈 |
| QA-014 | 피처 플래그 ON + 신규 유저 | 새 온보딩 플로우 진입 |

---

## Event Tracking

### 온보딩 퍼널 이벤트

| Event | Parameters | Trigger |
|-------|-----------|---------|
| `onboarding_started` | `source: "intro" \| "skip"` | 인트로 완료 또는 skip 후 로그인 |
| `onboarding_step_completed` | `step, data, duration_ms` | 각 질문 단계 완료 시 |
| `onboarding_step_skipped` | `step` | 인트로 skip 시 |
| `onboarding_result_viewed` | `recommended_level, class_length_pref, experience_level` | 결과 화면 진입 |
| `onboarding_ai_cta_clicked` | `class_length_pref: 10` | AI 수업 CTA 클릭 |
| `onboarding_booking_started` | `recommended_level, changed_level` | 체험 예약 화면 진입 |
| `onboarding_level_changed` | `from_level, to_level` | 체험 예약에서 레벨 변경 |
| `onboarding_booking_completed` | `language, level, booking_id` | 체험 예약 완료 |
| `onboarding_notification_agreed` | `agreed: boolean` | 알림 동의 결과 |
| `onboarding_marketing_agreed` | `agreed: boolean` | 마케팅 동의 결과 |
| `onboarding_completed` | `total_duration_ms, steps_completed` | 온보딩 전체 완료 |
| `onboarding_abandoned` | `last_step, total_duration_ms` | 온보딩 중 이탈 (세션 종료) |
| `onboarding_resumed` | `resume_step` | 이탈 후 재방문으로 온보딩 재개 |

### 측정 인프라

- **Metabase + ClickHouse** 기반 자동 트래킹 예정
- **확인 필요**: 온보딩 v2 이벤트가 ClickHouse에 적재되는 구조 (개발 착수 시 체크리스트)
- **스텝별 이탈률 트래킹**: 7개 질문 각 스텝별 이탈률 측정

---

## 배포 전략

- **전체 롤아웃** (A/B 테스트 없음)
- **피처 플래그(Flagsmith)**: 점진적 롤아웃 + 버그 대응 목적으로만 사용
- 한 유저는 v1 또는 v2 중 하나의 버전만 경험
- v2 확정 시 v1은 완전 폐기

---

## 미결 사항 및 대응 전략

| # | 미결 사항 | 오너 | 상태 | 블로커 여부 | 대응 |
|---|-----------|------|------|-------------|------|
| 1 | 말하기 경험 5단계 구체적 워딩 확정 | PM | 미확정 | ⚠️ 개발 병행 가능하나 조기 확정 필요 | PM이 워딩 확정 후 전달 |
| 2 | 5단계 → 4단계 레벨 매핑 | PM | 미확정 | ⚠️ 체험 예약 구현 시 필요 | PM이 매핑 테이블 작성 |
| 3 | 불안 해소 / 동기 부여 결과 문구 작성 | PM | 미작성 | ⚠️ 결과 화면 구현 시 필요 | 1~3: 불안 해소 / 4~5: 동기 부여 기준 |
| 4 | 추가 쿠폰 안내 문구 최종 워딩 | PM | 미확정 | ❌ 개발 병행 가능 | 플레이스홀더로 개발 진행 |
| 5 | 수업 스타일 선택지 최종 목록 | PM + 커리큘럼팀 | 협의 전 | ❌ 첫 출시 분기에 미사용 | 커리큘럼팀 협의 후 확정 |
| 6 | 약관 학습 선호도 수집 커버 여부 | PM + 법무팀 | 요청 전 | ⚠️ 결과에 따라 동의 UI 추가 | **즉시 법무 요청** → 결과에 따라 동의 화면 추가 감안하고 개발 착수 |

---

## 리스크

| 리스크 | 영향 | 완화 방안 |
|--------|------|-----------|
| 법무 확인 결과 약관 미커버 → 동의 UI 추가 필요 | 온보딩 플로우 변경, 개발 재작업 | 즉시 법무 요청 + 동의 화면 삽입 가능한 구조로 설계 |
| 레벨 체계 변경 (추가 레벨 커리큘럼) | 5단계→레벨 매핑 재작업 | 매핑을 config/설정값으로 관리, 하드코딩 금지 |
| 수업 스타일 선택지 확정 지연 | 향후 2차 분기 추가 지연 | 첫 출시에서 분기 미사용으로 이미 디커플링됨 |
| 디자인 시안 없이 개발 착수 | UI 재작업 가능성 | sprint-kit 프로토타입 기반 구조 선행, 디자인 확정 후 스타일링 반영 |

---

## 개발 착수 조건 및 체크리스트

### 착수 가능 조건 (현재 충족)
- [x] PRD 확정
- [x] sprint-kit HTML 프로토타입 존재
- [x] 첫 출시 축소 버전 스코프 합의 (말하기 경험 1변수 분기)

### 착수 시 체크리스트
- [ ] 법무팀에 약관 커버 여부 확인 요청 **즉시 진행**
- [ ] ClickHouse 온보딩 이벤트 적재 구조 확인
- [ ] 말하기 경험 5단계 워딩 확정 (개발 병행)
- [ ] 5단계 → 레벨 매핑 테이블 확정 (개발 병행)
- [ ] 결과 화면 분기 문구 작성 (개발 병행)
- [ ] 디자인 시안 병행 진행 (개발은 PRD + HTML 프로토타입 기반 구조 선행)

### 개발 기반
- **백엔드**: podo-backend (Spring Boot 3.5, Java)
- **프론트엔드**: podo-app (Next.js 15, TanStack Query)
- **디자인**: 시안 없이 착수, PRD + sprint-kit HTML 프로토타입 기반, 디자인 병행

### 리서치 데이터 수집 이벤트

| Event | Parameters | Trigger |
|-------|-----------|---------|
| `research_class_length_selected` | `preferred_length: 10 \| 25 \| 40` | 수업 길이 질문 응답 |
| `research_class_style_selected` | `style: string` | 수업 스타일 질문 응답 |
| `research_frequency_selected` | `frequency: number` | 수업 빈도 질문 응답 |

---

## Appendix

### v1 → v2 주요 변경 요약

| 항목 | v1 | v2 |
|------|-----|-----|
| 레벨 테스트 | 객관식 6문항 + 말하기 경험 합산 채점 | 삭제 — 말하기 경험 자가 평가만 |
| 레벨 결정 | 시스템 추천 (점수 기반) | 유저 직접 선택 (자가 평가 기반 프리셋 + 변경 가능) |
| personalization | 없음 | 수업 빈도, 선호 시간대, 수업 스타일, 수업 길이 |
| 온보딩 UX | 일반 폼 스타일 | PODO 캐릭터 대화형 말풍선 인터랙션 |
| 질문 수 안내 | 없음 | "7가지만 물어볼게요!" 사전 고지 |
| 결과 화면 | 테스트 점수 + 추천 레벨 + 안심 메시지 | 개인화 학습 플랜 + 세일즈 + 추가 쿠폰 안내 |
| 추가 쿠폰 | 없음 | "체험 완료 시 다른 언어 무료 체험" 안내 |
| DB 스키마 | quiz_score, experience_score, total_score | frequency, preferred_time, class_style, class_length_pref |

### 미결 사항 (Open Items)

| ID | 항목 | 담당 | 상태 |
|----|------|------|------|
| OPEN-001 | 레벨 구체적 설명형 워딩 최종 확정 | PO + 콘텐츠팀 | 초안 작성 완료, 리뷰 필요 |
| OPEN-002 | 기존 이용약관의 학습 선호도 수집 커버 여부 | 법무 | 확인 필요 |
| OPEN-003 | 추가 쿠폰 안내 문구 최종 워딩 | PO | 확정 필요 |
| OPEN-004 | 수업 스타일 선택지 최종 목록 | PO + 커리큘럼팀 | 확정 필요 |

### 텍스트 와이어프레임 참조

Surface Preview 파일: `surface/preview/index.html`
- PODO 캐릭터(연두색 #B5FD4C 원형) + 말풍선 인터랙션
- 폰 프레임(375x812) 기반 모바일 프로토타입
- 진행률 바, 선택지 카드, CTA 버튼 등 UI 컴포넌트 포함
