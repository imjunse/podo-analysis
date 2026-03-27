# Product Requirements Document — 온보딩 퍼널 v1

> **scope**: onboarding-funnel-20260319-001
> **상태**: 구현 완료
> **작성일**: 2026-03-19 (build-spec 기반 재정리)

---

## Executive Summary

PODO 앱의 신규 유저 온보딩 퍼널 v1. 기존에는 앱 가입 즉시 체험 신청 팝업만 표시했으나, v1에서 인트로 → 레벨 테스트 → 체험 예약의 단계적 온보딩 플로우를 도입한다.

**As-is 문제점:**
1. **가치 전달 없음** — PODO가 뭔지, 수업이 어떻게 진행되는지 설명 없이 바로 체험 신청
2. **불안 해소 없음** — 외국어 전화 수업에 대한 불안을 해소할 기회 부재
3. **개인화 없음** — 레벨/목표 파악 없이 일괄적 체험 신청

**v1 방향:**
- 인트로 화면으로 PODO 핵심 가치 전달
- 객관식 6문항 레벨 테스트 + 말하기 경험 자가 평가로 레벨 판정
- 테스트 결과 기반 추천 레벨 + 안심 메시지 제공
- 기존 체험 예약 페이지 리사이클

### Goal Metrics

| Metric | Current (As-is) | Target (v1) |
|--------|-----------------|-------------|
| 체험 예약 전환율 | 기존 /subscribes/trial 전환율 기준 | 개선 (구체 수치 미설정) |
| 체험 완료율 | 기존 대비 | 개선 |

---

## Success Criteria

### User Success
- 신규 유저가 PODO 서비스를 이해하고 체험 예약까지 완료
- 레벨 테스트로 적절한 레벨 매칭
- 안심 메시지로 전화 수업 불안감 해소

### Business Success
- 체험 예약 전환율 향상
- 학습 목표/말하기 경험 데이터 수집

### Technical Success
- GT_USER_ONBOARDING 테이블로 온보딩 상태 추적
- 피처 플래그(Flagsmith) 기반 점진적 롤아웃
- 기존 /subscribes/trial과 안전한 공존

---

## Product Scope

### 온보딩 플로우 (9단계)

| # | Feature | Description |
|---|---------|-------------|
| ❶ | 인트로 화면 | 2~3화면 스와이프, PODO 핵심 가치 전달, skip 가능 |
| ❷ | 로그인 | 기존 OAuth 그대로 (카카오/애플) |
| ❸ | 언어 선택 | 영어/일본어 중 1개 |
| ❹ | 학습 목표 | 업무/여행/시험/취미 복수 선택 |
| ❺ | 말하기 경험 | 5단계 자가 평가 |
| ❻ | 레벨 테스트 | 객관식 6문항 (난이도 섞어 배치) |
| ❼ | 테스트 결과 | 추천 레벨 + 안심 메시지 + 마케팅 동의 |
| ❽ | 체험 예약 | 기존 예약 페이지 리사이클, 언어/레벨 프리셋 |
| ❾ | 예약 완료 | 사전 설명 + OS 알림 동의 + 예습 유도 |

### 제외 범위

| 제외 항목 | 사유 |
|----------|------|
| 홈 화면 리뉴얼 | 변경 범위가 커서 별도 scope |
| 정기 구독 결제 퍼널 | 별도 PRD |
| 체험 완료 후 구독 전환 유도 | 별도 scope |
| 튜터 매칭 화면 | 랜덤 매칭 구조상 불가 |
| AI 학습 기능 변경 | 기존 AI 학습탭으로 유도만 |

---

## User Journeys

### Journey 1: 영어 초보, 전화 수업 불안감 높은 신규 유저

**Persona:** 수진 (28세, 영어 스피킹 경험 거의 없음)

앱 설치 → 인트로 3화면 스와이프 ("외국인 앞에 서면 머릿속이 하얘지나요?" → "할 말을 미리 준비하니까 긴장할 필요 없어요" → "25분 무료 체험, 한 번이면 충분해요") → 카카오 로그인 → 영어 선택 → "취미/자기계발" → 말하기 경험 "긴장돼서 아는 것도 못 말해요" → 레벨 테스트 6문항 → 결과: 초급 추천 + 불안 해소 메시지 ("수업 전 교재로 미리 예습하고, 편하게 전화하면 돼요") → 체험 예약 (레벨/언어 프리셋) → 예약 완료 + 알림 동의 + 예습 유도 → 메인

### Journey 2: 일본어 중급, 업무 목적 유저

**Persona:** 민수 (34세, 일본어 일상회화 가능)

인트로(skip) → 카카오 로그인 → 일본어 → "업무/비즈니스" → "일상 대화는 괜찮은데, 전문 주제는 어려워요" → 레벨 테스트 6문항 → 결과: 중고급 추천 + 동기 부여 메시지 ("실력에 맞는 수업 준비했어요") → 체험 예약 → 완료

### Journey 3: 온보딩 중 이탈 후 재방문

**Persona:** 지은 (26세, 레벨 테스트 도중 이탈)

앱 재실행 → 로그인 유지 → 온보딩 미완료 감지 (currentStep=LEVEL_TEST) → 레벨 테스트부터 자동 재개. 리셋 없음. 이전 입력값 유지.

### Journey 4: 온보딩 완료 재방문 유저

앱 실행 → onboardingStatus=COMPLETED → 바로 홈 화면 진입. 온보딩 재실행 없음.

---

## Domain-Specific Requirements

### DR-001: 레벨 테스트 채점 로직

**배분 비율**: 객관식 70점 + 말하기 경험 30점 = 총 100점 (7:3)

#### 객관식 배점 (70점)

| 문항 | 난이도 | 배점 |
|------|--------|------|
| 1번 | 중 | 10점 |
| 2번 | 하 | 8점 |
| 3번 | 상 | 15점 |
| 4번 | 하 | 8점 |
| 5번 | 상 | 14점 |
| 6번 | 중 | 15점 |

#### 말하기 경험 점수 (30점)

| 선택 | 점수 |
|------|------|
| ① 글자나 발음부터 배워야 해요 | 0점 |
| ② 읽고 쓰긴 하는데, 말하려면 긴장돼요 | 8점 |
| ③ 간단한 대화는 되는데, 길어지면 막혀요 | 15점 |
| ④ 일상 대화는 괜찮은데, 전문 주제는 어려워요 | 23점 |
| ⑤ 대부분 상황에서 자유롭게 대화할 수 있어요 | 30점 |

#### 최종 레벨 컷오프

| 점수 | 레벨 |
|------|------|
| 0 ~ 25 | 초급 |
| 26 ~ 50 | 중급 |
| 51 ~ 75 | 중고급 |
| 76 ~ 100 | 고급 |

### DR-002: 안심 메시지 분기

- experience_level 1~3 → **불안 해소**: "수업 전 교재로 미리 예습하고, 편하게 전화하면 돼요"
- experience_level 4~5 → **동기 부여**: "실력에 맞는 수업 준비했어요. 한 단계 더 올라가 볼까요?"

### DR-003: 알림 동의 타이밍

- iOS 네이티브 알림 팝업은 앱당 1회만 표시 가능
- 예약 완료 시점에 요청 — 유저가 알림의 가치를 가장 잘 이해하는 시점
- "나중에" 선택지 없음

---

## Technical Requirements

### Tech Stack

| 영역 | 기술 |
|------|------|
| Frontend | Next.js 15, TanStack Query |
| BFF | Hono |
| Backend | Spring Boot 3.5, Java |
| DB | MySQL (GT_USER_ONBOARDING) |
| Feature Flag | Flagsmith |
| Push | Expo Push + FCM/APNs |

### API Endpoints

| Method | Path | 설명 |
|--------|------|------|
| GET | /api/v1/onboarding/status | 온보딩 상태 조회 |
| PATCH | /api/v1/onboarding/step | 단계별 저장 |
| GET | /api/v1/onboarding/level-test?lang={lang} | 레벨 테스트 문항 조회 |
| POST | /api/v1/onboarding/level-test/score | 레벨 테스트 채점 |
| POST | /api/v1/onboarding/complete | 온보딩 완료 처리 |

### Database — GT_USER_ONBOARDING

```sql
CREATE TABLE GT_USER_ONBOARDING (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'NOT_STARTED'
                    COMMENT 'NOT_STARTED | IN_PROGRESS | COMPLETED | SKIPPED',
    current_step    VARCHAR(30) NULL
                    COMMENT 'LANGUAGE | GOAL | EXPERIENCE | LEVEL_TEST | RESULT | BOOKING | COMPLETE',
    language        VARCHAR(10) NULL,
    goals           VARCHAR(200) NULL
                    COMMENT '복수 선택, 쉼표 구분',
    experience_level TINYINT NULL
                    COMMENT '1~5',
    quiz_score      TINYINT NULL
                    COMMENT '객관식 점수 (0~70)',
    experience_score TINYINT NULL
                    COMMENT '말하기 경험 점수 (0~30)',
    total_score     TINYINT NULL
                    COMMENT '합산 점수 (0~100)',
    recommended_level VARCHAR(10) NULL
                    COMMENT '초급 | 중급 | 중고급 | 고급',
    marketing_agreed TINYINT(1) NOT NULL DEFAULT 0,
    notification_agreed TINYINT(1) NULL,
    intro_skipped   TINYINT(1) NOT NULL DEFAULT 0,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at    DATETIME NULL,

    CONSTRAINT fk_onboarding_user FOREIGN KEY (user_id) REFERENCES GT_USER(id),
    UNIQUE KEY uk_user_onboarding (user_id)
);
```

### Component Structure

**Frontend** (`apps/web/src/app/(internal)/onboarding/`):

| 라우트 | 화면 |
|--------|------|
| intro/page.tsx | 인트로 (스와이프 3화면) |
| language/page.tsx | 언어 선택 |
| goal/page.tsx | 학습 목표 |
| experience/page.tsx | 말하기 경험 |
| level-test/page.tsx | 레벨 테스트 |
| result/page.tsx | 테스트 결과 |
| booking/page.tsx | 체험 예약 |
| complete/page.tsx | 예약 완료 + 알림 |

**Backend** (`applications/onboarding/`):

| 파일 | 역할 |
|------|------|
| OnboardingController.java | REST API |
| OnboardingGateway.java | 도메인 서비스 조합 |
| OnboardingService.java | 온보딩 상태 관리 |
| LevelTestScoringService.java | 레벨 채점 로직 |
| UserOnboardingRepository.java | JPA Repository |

---

## Functional Requirements

### 인트로 (`/onboarding/intro`)
- **FR-001:** 3화면 스와이프 인트로 (PODO 핵심 가치 전달)
- **FR-002:** 우측 상단 "건너뛰기" 버튼으로 skip 가능
- **FR-003:** 마지막 슬라이드에서 "시작하기" → 로그인

### 질문 플로우 (`/onboarding/language ~ experience`)
- **FR-004:** 언어 선택 — 영어/일본어 중 1개
- **FR-005:** 학습 목표 — 업무/여행/시험/취미 복수 선택, 1개 이상 필수
- **FR-006:** 말하기 경험 — 5단계 단일 선택

### 레벨 테스트 (`/onboarding/level-test`)
- **FR-007:** 객관식 6문항, 난이도 섞어 배치
- **FR-008:** 문항은 JSON 파일로 관리 (영어/일본어 별도)
- **FR-009:** 6문항 모두 답변 후 서버에 한 번에 전송 → 채점

### 테스트 결과 (`/onboarding/result`)
- **FR-010:** 추천 레벨 표시 (초급/중급/중고급/고급)
- **FR-011:** 안심 메시지 분기 (experience 1~3: 불안 해소 / 4~5: 동기 부여)
- **FR-012:** 레벨 변경 가능 (바텀시트에서 수동 선택)
- **FR-013:** 마케팅 수신 동의 체크박스 (기본 미체크)
- **FR-014:** "무료 체험 예약하기" CTA

### 체험 예약 (`/onboarding/booking`)
- **FR-015:** 기존 체험 예약 페이지 리사이클
- **FR-016:** 언어/레벨 프리셋 적용
- **FR-017:** 결제 건너뛰기 (무료 체험)

### 예약 완료 (`/onboarding/complete`)
- **FR-018:** 수업 진행 방식 사전 설명
- **FR-019:** OS 알림 동의 팝업 (예약 완료 시점)
- **FR-020:** 예습 유도 문구
- **FR-021:** "메인으로 가기" → 홈 화면 이동

### 온보딩 상태 추적
- **FR-022:** 신규 유저 생성 시 GT_USER_ONBOARDING 자동 생성 (NOT_STARTED)
- **FR-023:** 각 단계 완료 시 currentStep 업데이트 (이탈 복구용)
- **FR-024:** step 순서 위반 시 400 에러
- **FR-025:** 재방문 시 currentStep 기반 자동 재개

### 라우팅 분기
- **FR-026:** 피처 플래그 ON 시:
  - NOT_STARTED → `/onboarding/intro`
  - IN_PROGRESS → `/onboarding/{currentStep}`
  - COMPLETED → `/` (홈)
- **FR-027:** 기존 /subscribes/trial 접근 시 피처 플래그 ON이면 새 온보딩으로 리다이렉트

---

## Non-Functional Requirements

### Performance
- 각 step 저장 API 응답 시간 < 300ms
- 레벨 테스트 채점 응답 시간 < 500ms

### Security
- 모든 온보딩 API는 Bearer 토큰 인증 필수
- 타인의 온보딩 데이터 접근 불가

### Error Handling
- 온보딩 상태 조회 실패 시: 기존 /subscribes/trial로 폴백
- step 순서 위반 시: 400 에러 + 올바른 step 안내

---

## Event Tracking

| Event | Parameters | Trigger |
|-------|-----------|---------|
| `onboarding_started` | `source: "intro" \| "skip"` | 인트로 완료 또는 skip |
| `onboarding_step_completed` | `step, data, duration_ms` | 각 단계 완료 |
| `onboarding_level_test_completed` | `quiz_score, experience_score, total_score, level` | 레벨 테스트 채점 완료 |
| `onboarding_level_changed` | `from_level, to_level` | 결과에서 레벨 수동 변경 |
| `onboarding_booking_completed` | `language, level, booking_id` | 체험 예약 완료 |
| `onboarding_notification_agreed` | `agreed: boolean` | 알림 동의 결과 |
| `onboarding_completed` | `total_duration_ms` | 온보딩 전체 완료 |
| `onboarding_abandoned` | `last_step, total_duration_ms` | 온보딩 중 이탈 |
| `onboarding_resumed` | `resume_step` | 이탈 후 재개 |
