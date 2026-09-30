# 시각화 감사 — 최종 확인 (5라운드 3단계)

## 0. 확인 범위

- 이번 최종 확인은 **직전 재감사의 MUST-FIX A1과, 그 뒤 호스트가 수정했다고 알린 항목(A2, A3, A4, U4, U3/U7)에만** 한정된다. 처음부터 다시 한 전체 감사가 아니다.
- 읽은 것:
  - `reviews/player-psychologist.md`의 "## 2라운드 — 교차 검토" 아래 C1, C2 항목(대조에 필요한 부분만)
  - `reviews/viz-data.json`: `cross_exam_conflicts` 30개 전체, player-psychologist의 `cross_exam_connections`(L1~L4), `reviewer_stats`의 player-psychologist 항목
  - `review-viz.html`: CSS·마크업(1~353행)과 렌더링 스크립트(355~1184행)
  - `local/t05/viz-browser-validation.json`
- 다시 읽지 않은 것: 나머지 원본 리뷰 다섯 편, `SYNTHESIS.md`, `viz-spec.md`. 이 파일들이 보존되었는지는 이전 감사와 호스트 검증 결과에 따른다.
- **감사자는 브라우저를 실행하지 않았다.** 아래의 동작 판단은 모두 소스 검토에 근거한다. 실제 동작 결과는 호스트 보고로만 알고 있으며, 해당 항목에는 따로 표시했다.

## 1. 정확성 오류

### 감사자가 소스를 검토해 확인한 사항

- **A1: 해결됨.**
  - 원본: player-psychologist/2라운드 C1의 제목과 본문이 반대하는 대상은 systems-designer/F1뿐이다("systems-designer/F1이 권하는 방향, 즉 회복 공급만 줄이는 조정에는 반대한다"). adversarial-qa/F3은 "분산 문제를 함께 봐야 한다"는 근거로만 인용된다.
  - JSON(`viz-data.json` 915~931행): `peer_reviewers`는 `["systems-designer"]`뿐이고, `referenced_findings`는 `["systems-designer/F1", "adversarial-qa/F3"]`다. 원본과 일치한다.
  - V3 집계 로직(HTML 427~457행): 충돌은 `peer_reviewers`로, 연결은 `referenced_findings`의 소유자로 센다. 이 규칙으로 심리→QA 칸을 계산하면 다음과 같다.
    - 충돌: C2 한 건(`peer_reviewers`에 adversarial-qa가 있음). C1은 adversarial-qa를 세지 않는다. 결과는 **충돌 1**.
    - 연결: L1(adversarial-qa/F2)과 L3(adversarial-qa/F5) 두 건. L2와 L4에는 QA 지적이 없다. 결과는 **연결 2**.
    - 호스트가 알린 기대값(충돌 1, 연결 2)과 같다.
  - V3 상세(903~912행): 심리→시스템 칸을 열면 C1 항목에 "이 동료의 참조 지적: systems-designer/F1"이 표시되고, adversarial-qa/F3은 "근거로 인용한 동료 지적"에 따로 나온다. 지지 근거가 논쟁 상대와 섞이지 않는다.
  - `reviewer_stats`에서 player-psychologist의 `debated_peers`에 adversarial-qa가 남아 있다. C2가 adversarial-qa/F3과 실제로 논쟁하므로 맞는 값이다.
- **나머지 29개 충돌 항목의 `peer_reviewers`:** 30개 항목을 모두 읽었다. 각 항목의 `peer_reviewers`는 제목에서 반대하거나 긴장 관계로 명시한 상대와 일치한다. 복수 상대인 항목(psych C2·C5, adversarial-qa C1·C3, business-analyst C4)도 제목이나 본문에서 두 상대를 모두 직접 논박한다. 다만 **수정 전 JSON이 없어 "바뀌지 않았다"는 사실 자체는 비교하지 못했다.** 확인한 것은 현재 값의 타당성까지다. 원본 리뷰 다섯 편과 다시 대조하지도 않았다.

### 확인하지 못한 사항

- HTML 354행 `const DATA = …`는 한 줄이 약 84,000토큰이다. 읽기 도구 한도(25,000토큰)를 넘어 **읽지 못했다.** 그래서 HTML 안의 DATA가 JSON과 같은지, 그 안의 psych C1 값이 무엇인지는 감사자가 직접 확인하지 못했다.
- `htmlSha256`(c788fcd9…)이 현재 `review-viz.html`의 해시와 같은지도 **계산하지 못했다.** 해시 계산 도구가 없다.

### 호스트 브라우저 검증에서 보고된 사항 (감사자 미검증)

- Edge 154와 Firefox 155에서 `embeddedDataEqual: true`(HTML 안의 DATA와 JSON이 같음)가 보고되었다.
- `matrixCounts`는 "primary conflict targets and source connection references verified", `supportingReferencesSeparated`는 pass로 보고되었다.
- 지적 30건, 상위 이슈 드릴다운 5개, 쟁점 드릴다운 6개, 매트릭스 30칸이 보고되었다. 콘솔 오류와 외부 요청은 0건이다.

**정확성 오류: 0건.** 남아 있던 A1은 소스 기준으로 해결되었다.

## 2. 항목별 결과

| 항목 | 결과 | 근거 (소스 검토) |
|---|---|---|
| A1 | **확인** | JSON의 C1 `peer_reviewers`가 원본과 일치한다. 집계 로직상 심리→QA는 충돌 1, 연결 2다. HTML에 넣은 DATA의 동일성은 호스트 보고로만 알고 있다(354행을 읽지 못함). |
| A2 | **확인** | V3 상세 행 라벨이 "이 동료의 참조 지적:"으로 바뀌었다(909행). 지지 근거는 "근거로 인용한 동료 지적:"으로 분리되어 있다(910행). |
| A3 | **확인** | 쟁점 패널 푸터에 "추출자가 연결한 관련 지적:"(809행), V1 최종 상태 단계에 "추출된 관련 지적을 기준으로 연결한 미해결 쟁점:"(699행)이 표시된다. |
| A4 | **부분 확인** | 수정한 곳: V4 등급 변경 목록의 "수정 요약:"(1022행), V5 상세의 "수정 요약:"(1126행)과 "리뷰어 자기평가 요약"(1127행). 남은 곳: 아래 N1, N2. |
| U4 | **확인** | 필터 막대의 초기화 버튼에 `data-filter-key="reset"`이 있다(1094행). 따라서 `renderV5`가 다시 그린 뒤에도 포커스가 유지된다(1176~1184행). 빈 상태의 초기화 버튼은 다시 그린 뒤 `#fbar [data-filter-key="reset"]`에 포커스를 둔다(1171행). 실제 포커스 동작은 호스트가 pass로 보고했다(`filterFocusRetained`, `emptyState`). |
| U3/U7 | **확인** | Esc 처리기(559~563행)는 툴팁을 닫은 뒤 `closeDisputes(!!document.activeElement.closest('#v2'))`를 호출한다. 포커스가 V2 안에 있을 때만 쟁점 행 제목으로 포커스를 돌리고, 그 밖에서는 패널만 닫고 포커스를 옮기지 않는다(814~820행). 실제 동작은 호스트가 `singleEscapeClosesDispute: pass`로 보고했다. |

## 3. 사용성 문제 (이번 확인에서 새로 발견한 것)

- **N1. SHOULD-FIX(권장 수정): V5 행과 상세에서 `self_reported_outcome` 라벨이 서로 다르다.**
  - 행의 메타 영역(1161행)에서는 "리뷰어 수정 요약" 옆에 SURVIVED · 유지 같은 교차 검토 결과 태그가 붙는다.
  - 같은 값이 상세(1127행)에서는 "리뷰어 자기평가 요약"으로 표시된다.
  - 행 라벨의 "수정 요약"은 V4·V5에서 `revision_note`에 쓰는 라벨과 같아서, 결과 태그를 수정 내용의 요약으로 잘못 읽을 수 있다. 행 라벨도 "리뷰어 자기평가"로 맞추기를 권한다.
- **N2. SHOULD-FIX(권장 수정): V1 상세의 "원 지적자의 2라운드 수정" 블록에서 `revision_note`에 라벨이 없다.**
  - 675행은 `r.revision_note`를 라벨 없이 보조 텍스트로 표시한다. V4·V5에서는 같은 값에 "수정 요약:"을 붙였으므로 A4를 적용하지 않고 남은 곳이다.
  - 원문은 "수정 이유 보기"에 있고 이 블록의 제목이 맥락을 주므로 오해 위험은 낮다. 그래서 MUST-FIX로 올리지 않는다.
- **참고(등급 없음):** V1 카드의 "관련 지적:"(637행, `iss.related_findings`)에는 추출자가 연결했다는 표시가 없다. 이 필드의 출처가 SYNTHESIS 원문인지 추출자인지는 이번 범위에서 확인하지 않았다. A3가 쟁점에 한정된 수정이었으므로 판정에 반영하지 않는다.

새로 발견한 MUST-FIX는 없다.

**남은 MUST-FIX: 0**

## 4. 이번 확인 범위 밖

직전 재감사의 권고 가운데 이번 수정 범위에 들지 않아 확인하지 않은 항목은 다음과 같다. 모두 **이번 확인 범위 밖**이며, 해결 여부를 판단하지 않았다.

- 라이트 모드 팔레트(`prefers-color-scheme: light`에서 심각도 텍스트 색 등). 호스트는 `colorScheme: pass`로 보고했지만 감사자는 검토하지 않았다.
- 최소 글자 크기(14~15px 보조 텍스트, 태그 13px 영문 토큰 등의 프로젝터 가독성)
- 그 밖에 이번 요청에 나열되지 않은 SHOULD-FIX, NICE-TO-FIX 권고 전부

## 5. 최종 판정

**바로 보여 줄 수 있다.**

- 유일하게 남아 있던 MUST-FIX A1은 소스 기준으로 해결되었다. JSON이 원본과 일치하고, 집계 로직상 심리→QA 칸은 충돌 1, 연결 2가 된다.
- A2, A3, U4, U3/U7은 소스에서 확인했다. A4는 두 곳(N1, N2)에 라벨 불일치가 남아 부분 확인이지만, 둘 다 SHOULD-FIX다.
- 단서:
  - HTML 안의 DATA가 JSON과 같은지와 HTML 해시는 감사자가 직접 확인하지 못했다. 이 부분은 호스트의 Edge/Firefox 검증 보고에 따른다.
  - 감사자는 브라우저를 실행하지 않았다.
- N1, N2는 다음 빌드 때 함께 고치기를 권한다.
