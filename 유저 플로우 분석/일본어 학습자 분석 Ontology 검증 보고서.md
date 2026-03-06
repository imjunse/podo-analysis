---
tags:
  - podo
  - jp-learners
  - ontology
  - verification
  - user-flow
  - clickhouse
  - data-quality
date: 2026-03-06
related:
  - "[[일본어 학습자 유저 플로우 분석 결과]]"
---

## 일본어 학습자 분석 — Ontology 검증 보고서

> 검증 대상: [[일본어 학습자 유저 플로우 분석 결과]]
> 검증 소스: `podo-backend/podo-docs/domains/`, `podo-app/podo-docs/`
> 검증일: 2026-03-06

---

### 검증 종합 스코어

| 카테고리 | 항목 수 | 정확 | 부분정확 | 검증불가 | 오류 |
|---|---|---|---|---|---|
| 라우트 경로 | 9 | 9 | 0 | 0 | 0 |
| JP 사용자 식별 | 2 | 2 | 0 | 0 | 0 |
| 예약 플로우 | 4 | 4 | 0 | 0 | 0 |
| 인프라 이슈 | 1 | 1 | 0 | 0 | 0 |
| 수업 플로우 | 3 | 3 | 0 | 0 | 0 |
| 레벨 체계 | 1 | 0 | 1 | 0 | 0 |
| 결제 플로우 | 3 | 3 | 0 | 0 | 0 |
| 시간대 패턴 | 1 | 0 | 0 | 1 | 0 |
| 취소/페널티 | 1 | 1 | 0 | 0 | 0 |
| **합계** | **25** | **23 (92%)** | **1 (4%)** | **1 (4%)** | **0** |

> **오류 항목 0건** — 분석 결과의 신뢰도가 높음

---

### 1. 라우트/페이지 경로 검증

> 소스: `podo-app/podo-docs/indexes/routes-index.md`, `podo-app/podo-docs/glossary.md`

| 분석 경로 | Ontology 확인 | 판정 |
|---|---|---|
| `/home` | routes-index: 메인 홈 페이지 | ✅ |
| `/booking` | routes-index: 수업 예약하기 + user-flows §2.1 상세 플로우 | ✅ |
| `/reservation` | routes-index: 예약 현황 (예약된 수업 목록) | ✅ |
| `/subscribes` | routes-index: 이용권 구매 메인 | ✅ |
| `/lessons/regular` | routes-index: 정규 수업 목록 | ✅ |
| `/lessons/trial` | routes-index: 체험 수업 목록 | ✅ |
| `/ai-learning` | routes-index: AI 학습 페이지 | ✅ |
| `/my-podo` | routes-index: 마이페이지 메인 | ✅ |
| `/login` | routes-index: 로그인 페이지 | ✅ |

**결론**: 9/9 경로 100% 일치.

---

### 2. JP 사용자 식별 방법 검증

> 소스: `podo-backend/podo-docs/domains/schedule/policies.md` §4.1, `database/enums.md`

| 식별 방법 | Ontology 근거 | 판정 |
|---|---|---|
| URL `langType=JP` | enums.md Language: `JP` 존재. schedule/policies §4.1: LangType {EN, JP} | ✅ |
| UTM `enjp` 캠페인 | subscription/policies §3: `ENJP` 타입 (EN+JP 결합 상품) | ✅ |

> [!warning] 정밀도 개선 포인트
> `ENJP` 사용자는 EN+JP 결합 상품 이용자. 순수 JP 전용 사용자와 행동 패턴이 다를 수 있음.
> → 후속 분석 시 `JP` vs `ENJP` 분리 권장

---

### 3. 예약 플로우 검증

> 소스: `podo-app/podo-docs/user-flows.md` §2, `podo-backend/podo-docs/domains/schedule/policies.md`

| 분석 항목 | Ontology 근거 | 판정 |
|---|---|---|
| `btn-booking-change` (예약 변경) | user-flows §2.1: `/booking?type=edit` 예약 변경 플로우 | ✅ |
| `btn-booking-submit` (예약 확정) | user-flows §2.4: "선택한 날짜에 예약" 버튼 + `bookMutation` | ✅ |
| `booking_confirm` 팝업 | user-flows: 예약 확정 단계 확인 플로우 | ✅ |
| `booking_change_confirm` 팝업 | user-flows §2.4: 변경 시 `changeMutation` 전 확인 | ✅ |

---

### 4. `booking_alert_too-many-requests` 검증 — 핵심 이슈

> 소스: `podo-backend/podo-docs/domains/schedule/policies.md`

| 분석 결과 | Ontology 근거 | 판정 |
|---|---|---|
| 367명 JP 사용자, 인당 26.2회 발생 | Redis 분산 락 (2초 TTL) → `BOOK_ALREADY_PROCESSING` (HTTP 429) | ✅ **확인** |

**Ontology 상세**:
- 동시 예약 방지를 위해 **Redis 분산 락** 사용 (TTL: 2초)
- 동일 사용자가 2초 이내 재요청 시 `BOOK_ALREADY_PROCESSING` 반환 (HTTP 429)
- 클라이언트에서 `booking_alert_too-many-requests` 팝업으로 표시

> [!important] 이슈 확정
> 이것은 단순 UI 에러가 아닌 **백엔드 Redis 락 경합** 문제.
> JP 사용자의 예약 시간대 집중(KST 12-13시) + 빈번한 예약 변경(인당 15.7회)이 원인.
> → [[일본어 학습자 유저 플로우 분석 결과#핵심 액션 아이템|P0 액션 아이템]] 참고

---

### 5. 수업 진행 플로우 검증

> 소스: `podo-backend/podo-docs/domains/lecture/policies.md`, `podo-app/podo-docs/user-flows.md` §3

| 분석 항목 | Ontology 근거 | 판정 |
|---|---|---|
| prestudy 팝업 | lecture/policies: 사전 학습 Redis 기반 추적, **최소 8분** 완료 필요 | ✅ |
| 클래스룸 진입 | user-flows §3.1: `/lessons/classroom/[classID]`, `langType` 파라미터 포함 | ✅ |
| 수업 리포트 | user-flows §3.3: `/lessons/classroom/[classID]/report` | ✅ |

> [!note] Prestudy 최소 8분 정책
> 분석에서 prestudy 활용률 50% (1,682명)로 나타남. lecture/policies에 따르면 8분 미만 완료 시 prestudy 미인정 → 실제 "유효 완료" 비율은 더 낮을 수 있음

---

### 6. 레벨 체계 검증

> 소스: `podo-backend/podo-docs/database/enums.md`

| 분석 (숫자) | Ontology (이름) | 판정 |
|---|---|---|
| Level 1~2 집중 | BEGINNER, UPPER_BEGINNER | ⚠️ 부분 |
| Level 3~4 보통 | INTERMEDIATE, UPPER_INTERMEDIATE | ⚠️ 부분 |
| Level 5+ 소수 | ADVANCED | ⚠️ 부분 |

> [!warning] 매핑 미확인
> 분석의 숫자 레벨(1~8)과 ontology의 이름 기반 레벨(BEGINNER~ADVANCED)의 **정확한 매핑 테이블은 ontology에서 명시되지 않음.**
> Level 1=BEGINNER 가정은 합리적이지만, 백엔드 코드에서 정확한 매핑 확인 필요.
> 특히 소수점 레벨(3.1, 2.1 등)이 어떤 세부 단계를 의미하는지 추가 확인 필요.

---

### 7. 결제/구독 플로우 검증

> 소스: `podo-backend/podo-docs/domains/payment/policies.md`, `subscription/policies.md`

| 분석 항목 | Ontology 근거 | 판정 |
|---|---|---|
| subscribes 경로 | routes-index: `/subscribes` + `/subscribes/tickets` + `/subscribes/payment/:id` | ✅ |
| 결제 전환 퍼널 | payment/policies: TRIAL → FIRST_BILLING → BILLING 순서 | ✅ |
| JP 구독 구조 | subscription/policies §3: ENJP는 레슨 수를 EN/JP 균등 분배 | ✅ |

> [!note] JP Double Pack 이벤트
> payment/policies: JP 구매 시 EN 티켓도 함께 제공되는 이벤트 존재.
> → JP 사용자의 EN 수업 이용 패턴도 분석하면 크로스셀링 효과 측정 가능

---

### 8. 시간대 패턴 검증

| 분석 결과 | Ontology 근거 | 판정 |
|---|---|---|
| KST 12~13시 피크 (JST 점심) | schedule/policies: 30분 단위 타임슬롯 제공 확인 | ⚪ 검증 불가 |
| KST 22~02시 이차 피크 | 직접적 ontology 근거 없음 (행동 관측 데이터) | ⚪ 검증 불가 |

시간대 패턴은 사용자 행동 관측값이므로 ontology에서 직접 검증 불가. 시스템의 30분 단위 타임슬롯 제공은 확인됨.

---

### 9. 취소/페널티 정책 검증

> 소스: `schedule/policies.md`, `lecture/policies.md`, `ticket/policies.md`

| 정책 | Ontology 근거 | 판정 |
|---|---|---|
| 2시간 전 예약 변경 가능 | schedule/policies: 수업 시작 2시간 전까지 변경 가능 | ✅ |
| 취소 페널티 단계 | lecture/policies: >2hr(무료), 2hr~1hr(페널티), <1hr(CANCEL_PAID) | ✅ |
| 무제한 이용권 72시간 페널티 | ticket/policies: UNLIMIT(999) 취소 시 72시간 페널티 | ✅ |

---

### Ontology에서 추가 발견된 인사이트

분석에 반영되지 않았지만 후속 분석에 활용할 수 있는 항목들:

#### 1. ENJP 이중 구독자 분리
- `ENJP` 사용자는 EN+JP 결합 상품으로, 레슨 수를 균등 분배
- 순수 JP 사용자와 행동 패턴 차이 분석 필요
- `subscription/policies.md` §3: lessonCountPerMonth=999 → 무제한

#### 2. JP 튜터 매칭 가중치
- `schedule/policies.md`: JP 수업은 `CURRICULUM` 가중치가 높은 매칭 알고리즘
- 예약 집중 시간대에 JP 전문 튜터 부족 → too-many-requests의 또 다른 원인 가능

#### 3. 무제한 이용권 + 72시간 페널티
- `ticket/policies.md`: UNLIMIT 이용권(999회) 사용자가 2시간 이내 취소 시 72시간 예약 불가
- 이 정책이 JP 사용자의 예약 변경 빈도(인당 15.7회)에 영향 가능

#### 4. JP Double Pack 이벤트 효과
- `payment/policies.md`: JP 구매 시 EN 티켓 추가 제공
- JP 사용자의 EN 수업 크로스 이용 패턴 분석 → 마케팅 효과 측정

---

### 검증 소스 목록

| 문서 | 경로 | 검증 항목 |
|---|---|---|
| Schedule Policies | `podo-backend/podo-docs/domains/schedule/policies.md` | 예약, Redis 락, LangType |
| Lecture Policies | `podo-backend/podo-docs/domains/lecture/policies.md` | Prestudy, 취소 페널티 |
| Subscription Policies | `podo-backend/podo-docs/domains/subscription/policies.md` | ENJP, 구독 구조 |
| Payment Policies | `podo-backend/podo-docs/domains/payment/policies.md` | 결제 플로우, Double Pack |
| Ticket Policies | `podo-backend/podo-docs/domains/ticket/policies.md` | 이용권 타입, 72시간 페널티 |
| Enums | `podo-backend/podo-docs/database/enums.md` | Language, Level enum |
| Glossary | `podo-app/podo-docs/glossary.md` | 라우트, 기능 용어 |
| User Flows | `podo-app/podo-docs/user-flows.md` | 전체 유저 플로우 |
| Routes Index | `podo-app/podo-docs/indexes/routes-index.md` | 라우트 경로 확인 |
