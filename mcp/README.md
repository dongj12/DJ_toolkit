# MCP 설정 (선택)

**기본은 MCP를 쓰지 않는 것입니다.** MCP는 설정·재시작 시간이 들고, 도구 설명과 페이지 구조가 대화에 들어가 토큰이 늘어납니다(토큰 사용량은 평가에 반영).
화면은 사람이 Browser 탭에서 직접 확인합니다. Computer Use(AI의 화면 자동 조작)가 금지이므로 브라우저 자동화 MCP는 넣지 않았습니다.

- 응시 환경의 **MCP 탭**에 붙여 넣습니다. `config.toml`을 직접 고치지 마세요 (플랫폼 설정 수정 금지).
- **개인 API 키는 넣지 마세요.** 아래는 키 없이 동작하는 공개 MCP입니다.
- 저장 후 Codex를 다시 시작하고 `/mcp`로 도구가 보이는지 확인합니다.

## 1. JSON 형식 (MCP 탭이 JSON일 때)

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@4.4.4"]
    }
  }
}
```

## 2. TOML 형식 (MCP 탭이 config.toml 형식일 때)

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp@4.4.4"]
```

## 각 서버가 하는 일

| 서버 | 용도 | 주의 |
|---|---|---|
| context7 | 라이브러리 최신 공식 문서 검색 (예: "FastAPI 최신 lifespan 사용법") | 키 없이 쓰면 호출 횟수 제한이 낮음. 과제 내용·코드는 보내지 말고 라이브러리 이름과 질문만 |

## 확인할 것 (사전 체험)
- [ ] MCP 탭 형식이 JSON인지 TOML인지
- [ ] 저장 후 `/mcp`에 context7 도구가 보이는지
