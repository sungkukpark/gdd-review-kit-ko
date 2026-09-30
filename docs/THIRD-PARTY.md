# 정적 데모의 외부 구성 요소

## Godot Engine 4.7.2

두 게임은 [Godot 공식 4.7.2 내보내기 템플릿](https://godotengine.org/download/archive/4.7.2-stable/)의
Web 단일 스레드 버전으로 빌드했습니다. `demo/runtime/`의 WASM·JavaScript·오디오
워크렛은 두 게임이 공유하며, 게임별 `index.pck`는 별도 데이터입니다.

- [Godot MIT 라이선스](./GODOT-LICENSE.txt)
- [Godot 포함 라이브러리의 저작권·라이선스](./GODOT-COPYRIGHT.txt)
- [공식 원문](https://github.com/godotengine/godot/tree/4.7.2-stable)

## Noto Sans KR

두 웹 게임의 PCK에 Noto Sans KR을 포함했습니다. 개선본 네이티브 프로젝트에도
같은 글꼴을 동봉합니다. 원본 네이티브 프로젝트는 그대로 보존했으며 원본
웹 빌드 사본에만 이 글꼴을 적용했습니다.

- [원본 글꼴과 OFL 파일](https://github.com/google/fonts/tree/main/ofl/notosanskr)
- [동봉 OFL 1.1](./NOTO-OFL.txt)
- Copyright 2014–2021 Adobe. Reserved Font Name: Source.

게임 도형·아이콘은 프로젝트 코드로 작성한 자작 요소입니다. 웹 페이지는
시스템 글꼴을 사용하며 외부 CDN이나 글꼴 요청을 하지 않습니다.
