# PODO 예약 변경 제한 정책 v2

*Generated: 2026-03-27 09:22 UTC*
*PM ID: pm_seed_interview_20260327_084428*

## Goal

슈퍼 체인저(355명)의 과도한 예약 변경으로 인한 '가짜 풀부킹' 문제를 해결하여, 일반 유저의 예약 가용성을 개선한다. 3가지 정책 옵션을 비교 분석하여 최적 정책을 선정한다.

## User Stories

1. **As a** 일반 UNLIMIT 유저, **I want to** 원하는 시간에 수업을 예약하고 싶다, **so that** 가짜 풀부킹으로 인한 예약 불가 상황을 겪지 않기 위해.
2. **As a** 슈퍼 체인저 (고빈도 변경 유저), **I want to** 합리적인 범위 내에서 예약을 변경하고 싶다, **so that** 서비스를 계속 이용하면서 유연하게 스케줄을 관리하기 위해.
3. **As a** PM/운영팀, **I want to** 풀부킹 감소 효과가 가장 큰 정책을 선택하고 싶다, **so that** 유저 이탈을 최소화하면서 예약 시스템의 공정성을 확보하기 위해.

## Constraints

- 적용 대상: UNLIMIT 수강권 유저(originCount == 999)만. COUNT/TRIAL은 제한 미적용
- 변경 정의: 슬롯(시간) 변경 = 변경 1회. 튜터는 랜덤 매칭이므로 별도 변경 불가
- 취소 후 재예약도 변경 1회로 카운트 (우회 방지)
- 튜터 취소/어드민 변경으로 인한 강제 변경은 카운트 비대상 (세 옵션 모두 동일)
- 세 옵션은 상호 배타적 — 하나만 선택, 조합 불가
- 제한 도달 시 기존 예약은 유지, 변경만 차단 (변경 버튼 비활성화 + 안내 메시지)
- 피처 플래그로 관리하여 롤백 가능해야 함 (기존 PRD 롤백 기준 활용)

## Success Criteria

1. 풀부킹 체감(일평균 풀부킹 알림 ~770회) 대폭 감소
2. 일평균 변경 건수(~1,450건)를 슬롯 수(1,053개) 이하로 감소
3. 슈퍼 체인저 이탈 최소화 (피처 플래그 + 롤백 기준으로 모니터링)
4. 저빈도 유저(80% 이상)는 정책 영향 없음

## Assumptions

- 슈퍼 체인저 변경의 약 80% 이상이 당일 수업에 집중되어 있음
- 의사결정 우선순위: 1) 풀부킹 감소 효과 최우선, 2) 이탈은 피처 플래그로 관리 가능, 3) 구현 복잡도/우회 가능성은 부차적
- 옵션 A: 주 5회 변경 제한, 매주 월요일 리셋 — ClickHouse 시뮬레이션 기준 전체 변경의 59.3% 차단, 80% 유저-주 영향 없음
- 옵션 B: 캘린더 날짜 기준 당일 수업 변경 완전 불가
- 옵션 C: 개별 수업(예약) 단위 변경 횟수 제한 (1회 또는 2회)
- 슈퍼 체인저 355명은 UNLIMIT의 89%를 차지하며, 누적 결제 3.17억원(전체 UNLIMIT JP 매출의 4.4%)
- 변경 밀도 11건+/10분 구간에서 풀부킹 알림의 76.5% 발생

## Decide Later

The following items were deferred or identified as premature at this stage. They should be revisited when more context is available:

- 옵션 B 당일 vs 전일 변경 비율 세부 분석 (현재 약 80%+ 당일 변경으로 추정)
- 옵션 C의 기본 횟수(1회 vs 2회) 결정 — 시뮬레이션 비교 후 결정
- 옵션 C에서 수업당 변경 제한을 1회로 할지 2회로 할지 — 둘 다 시뮬레이션 후 결정

## Existing Codebase Context

- **podo-backend** (`/Users/ga/Desktop/podo/backend/podo-backend`)
- **podo-app** (`/Users/ga/Desktop/podo/frontend/podo-app`)

---
*Interview ID: interview_20260327_084428*
