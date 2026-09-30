# 정적 비교 데모

[demo/index.html](./demo/index.html)에 기존 리뷰의 주요 지적과 실제 두 Godot 웹
게임을 제공합니다. 원본과 리뷰 반영판을 같은 페이지에서 불러오거나 각각 크게
플레이할 수 있습니다. GitHub Pages에서는 `main`의 `/docs`가 게시 대상입니다.
공개 배포 설정·URL 접속 검증은 아직 수행하지 않았습니다.

## 로컬 실행

저장소 루트에서 Python이 설치된 환경으로 실행합니다.

```powershell
python -m http.server 8765 --bind 127.0.0.1 --directory docs
```

브라우저에서 `http://127.0.0.1:8765/demo/`를 여세요. 게임은 WebAssembly와
WebGL 2를 사용하므로 `file://`로 직접 열지 않습니다. 데스크톱 키보드로 조작하며,
각 게임을 클릭하고 Enter로 시작합니다. seed 입력은 두 게임에 같은 숫자를
전달하지만 생성 규칙이 달라 지형까지 같은 것은 아닙니다.

## 재생성

Godot 4.7.2와 해당 버전의 Web 단일 스레드 내보내기 템플릿이 필요합니다.
[Godot 공식 내려받기](https://godotengine.org/download/archive/4.7.2-stable/)에서
템플릿을 설치한 뒤 저장소 루트에서 실행합니다.

```powershell
./tools/export-demos.ps1
```

두 게임은 공식 Godot Web 내보내기입니다. WASM·JavaScript 런타임 한 벌을 공유하며
게임별 PCK는 별도로 제공합니다. 별도의 JavaScript 게임을 만들어 비교하지 않습니다.
원본 빌드 사본에는 웹용 한글 글꼴과 비교 페이지의 상태 표시만 추가합니다.
원본 GDD·게임 소스·리뷰 파일은 변경하지 않습니다. 빌드 사본·로그·템플릿은
`local/` 또는 Godot 사용자 디렉터리에 보관합니다.

근거: [Godot 공식 Web 내보내기 안내](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).
단일 스레드 내보내기는 교차 출처 격리 헤더를 요구하지 않아 정적 제공에 사용했습니다.
