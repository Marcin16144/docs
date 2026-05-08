# Agenci LLM i Tools

## Czym jest agent LLM?

**Agent** to system, w którym LLM nie tylko generuje tekst, ale **decyduje o akcjach**: wywołuje narzędzia, czyta wyniki, planuje kolejne kroki, iteruje aż do osiągnięcia celu.

```
┌─────────────────────────────────────┐
│              AGENT                  │
│  ┌─────────────────────────────┐   │
│  │         LLM (mózg)           │   │
│  └──┬───────────────────────┬──┘   │
│     │                        │      │
│  ┌──▼──────┐         ┌──────▼──┐   │
│  │ Memory  │         │  Tools  │   │
│  │ (state) │         │ (akcje) │   │
│  └─────────┘         └─────────┘   │
│         ↓                  ↓        │
│  ┌──────────────────────────────┐  │
│  │       Świat zewnętrzny:       │  │
│  │  pliki, API, baza, internet   │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

## Tradycyjna aplikacja vs Agent

```
Tradycyjna aplikacja:
User → kod (sztywny przepływ) → API → odpowiedź

Agent:
User → LLM → "Co zrobić?" → wybierz tool → wynik
              ↑                              ↓
              └──── feedback loop ──────────┘
```

## Function Calling / Tool Use

Podstawowa zdolność: LLM otrzymuje listę dostępnych funkcji i może je "wywołać" w odpowiedzi.

### Anthropic Claude Tool Use

```python
import anthropic

client = anthropic.Anthropic()

tools = [{
    "name": "get_weather",
    "description": "Get current weather for a city",
    "input_schema": {
        "type": "object",
        "properties": {
            "city": {"type": "string", "description": "City name"},
            "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]}
        },
        "required": ["city"]
    }
}]

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "Jaka jest pogoda w Warszawie?"}]
)

# Model zdecyduje czy wywołać tool
if response.stop_reason == "tool_use":
    tool_call = response.content[-1]
    result = get_weather(**tool_call.input)  # Twoja implementacja

    # Kontynuuj rozmowę z wynikiem
    response = client.messages.create(
        model="claude-sonnet-4-6",
        tools=tools,
        messages=[
            {"role": "user", "content": "Jaka jest pogoda w Warszawie?"},
            {"role": "assistant", "content": response.content},
            {"role": "user", "content": [{
                "type": "tool_result",
                "tool_use_id": tool_call.id,
                "content": str(result)
            }]}
        ]
    )
```

### OpenAI Function Calling

Podobny pattern, składnia różni się delikatnie. W 2026 standardem jest **OpenAI-compatible** schema (kompatybilna z większością modeli).

## ReAct Pattern

**ReAct** = **Re**asoning + **Act**ing. Klasyczny pattern dla agentów.

```
Question: Jaka będzie pogoda jutro w stolicy Francji?

Thought: Muszę najpierw znaleźć stolicę Francji.
Action: search("stolica Francji")
Observation: Stolica Francji to Paryż.

Thought: Teraz mogę sprawdzić pogodę w Paryżu na jutro.
Action: get_weather(city="Paryż", date="tomorrow")
Observation: Jutro w Paryżu: 15°C, słonecznie.

Thought: Mam już odpowiedź.
Answer: Jutro w Paryżu (stolicy Francji) będzie 15°C i słonecznie.
```

W 2026 nowoczesne reasoning models (Claude, o3, R1) robią to **automatycznie** w extended thinking.

## Frameworki do agentów (2026)

### LangGraph (preferowany 2026)

Następca LangChain Agents. Graph-based, stateful, lepiej zaprojektowany.

```python
from langgraph.graph import StateGraph, END
from langgraph.prebuilt import create_react_agent
from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(model="claude-sonnet-4-6")

@tool
def search_web(query: str) -> str:
    """Search the web."""
    return ddg_search(query)

@tool
def calculator(expression: str) -> str:
    """Evaluate math expression."""
    return str(eval(expression))

agent = create_react_agent(
    llm,
    tools=[search_web, calculator],
    prompt="Jesteś badaczem internetu."
)

result = agent.invoke({
    "messages": [("user", "Ile wynosi PKB Polski podzielone przez populację?")]
})
```

### Claude Agent SDK

SDK od Anthropic do budowy agentów (jak Claude Code):

```python
from claude_agent_sdk import Agent, tool

@tool
def read_file(path: str) -> str:
    """Read file contents."""
    return open(path).read()

@tool
def write_file(path: str, content: str) -> str:
    """Write content to file."""
    open(path, "w").write(content)
    return f"Written to {path}"

agent = Agent(
    model="claude-opus-4-7",
    tools=[read_file, write_file],
    system_prompt="Jesteś pomocnym asystentem programistycznym."
)

response = agent.run("Przeczytaj README.md i streszcz go")
```

### AutoGen (Microsoft)

Multi-agent framework, agenci rozmawiają ze sobą.

```python
from autogen import AssistantAgent, UserProxyAgent

assistant = AssistantAgent("assistant", llm_config={"model": "gpt-5"})
user = UserProxyAgent("user", code_execution_config={"work_dir": "tmp"})

user.initiate_chat(assistant, message="Napisz prostą grę w Snake")
```

### CrewAI

Multi-agent z zdefiniowanymi rolami:

```python
from crewai import Agent, Task, Crew

researcher = Agent(role="Researcher", goal="Find latest AI papers")
writer = Agent(role="Writer", goal="Write summary")

task1 = Task(description="Research AI trends", agent=researcher)
task2 = Task(description="Write blog post", agent=writer)

crew = Crew(agents=[researcher, writer], tasks=[task1, task2])
result = crew.kickoff()
```

### Pydantic AI

Type-safe agent framework.

```python
from pydantic import BaseModel
from pydantic_ai import Agent

class Answer(BaseModel):
    response: str
    sources: list[str]

agent = Agent("anthropic:claude-sonnet-4-6", result_type=Answer)
```

## Model Context Protocol (MCP)

**MCP** (Anthropic, 2024) — protokół do integracji narzędzi z agentami. **De facto standard 2026**.

```
MCP Client (Claude Desktop, Cursor, Claude Code)
       ↓
   MCP Protocol (JSON-RPC over stdio/SSE)
       ↓
   MCP Server (filesystem, postgres, github, slack...)
       ↓
   Real tool/data
```

### Przykład: prosty MCP server

```python
# my_mcp_server.py
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("My Tools")

@mcp.tool()
def calculate(expression: str) -> str:
    """Evaluate math."""
    return str(eval(expression))

@mcp.resource("config://app")
def get_config() -> str:
    """App configuration."""
    return open("config.yaml").read()

if __name__ == "__main__":
    mcp.run()
```

Konfiguracja w Claude Desktop:
```json
{
  "mcpServers": {
    "my-tools": {
      "command": "python",
      "args": ["my_mcp_server.py"]
    }
  }
}
```

### Popularne MCP servery (2026)

- **filesystem** — operacje na plikach
- **postgres** — query bazy danych
- **github** — repo, issues, PR
- **slack** — wiadomości
- **google-drive** — pliki Google
- **web-search** — Brave, Tavily
- **memory** — persistent memory
- **fetch** — HTTP requests
- **playwright** — browser automation

Repozytorium 1000+ MCP serverów w 2026.

## Memory dla agentów

### Short-term memory (working memory)
Historia rozmowy w prompcie. Limit: context window.

```python
messages = [
    {"role": "user", "content": "Mam na imię Marcin"},
    {"role": "assistant", "content": "Miło cię poznać, Marcin"},
    {"role": "user", "content": "Jak mam na imię?"}
]
```

### Long-term memory
Persystentna baza wiedzy o userze, poprzednich interakcjach.

**Typy:**
- **Episodic** — pamięć konkretnych zdarzeń ("3 dni temu pytałem o X")
- **Semantic** — fakty o świecie i userze ("user lubi Python")
- **Procedural** — jak coś robić ("user preferuje krótkie odpowiedzi")

### Implementacja

```python
# 1. Po każdej rozmowie — ekstrahuj fakty
facts = llm.generate(f"""
Wyciągnij ważne fakty z rozmowy:
{conversation}

Fakty:
""")

# 2. Zapisz w vector DB
vector_db.upsert(facts)

# 3. Przy następnej rozmowie — retrieve relevant
relevant_memory = vector_db.search(current_query)

# 4. Dodaj do system prompt
system_prompt = f"""
Wiedza o userze:
{relevant_memory}

[reszta promptu]
"""
```

### Frameworki memory
- **mem0** — managed memory layer dla agentów
- **Letta** (dawniej MemGPT) — open source memory
- **LangGraph checkpoints** — state w Postgres
- **Zep** — conversational memory

## Multi-agent systems

W 2025-2026 rosnący trend: zamiast jednego mega-agenta, **specjalizowane agenty współpracujące**.

```
┌──────────────────────────┐
│      Orchestrator         │  (planuje, deleguje)
└────────────┬─────────────┘
             │
   ┌─────────┼─────────┐
   ▼         ▼         ▼
┌─────┐  ┌─────┐  ┌─────┐
│ Res │  │ Cod │  │ Wri │  Specjalizowani agenci
│earch│  │ er  │  │ ter │
└─────┘  └─────┘  └─────┘
```

**Wzorce:**
- **Sequential** — agent A → B → C
- **Hierarchical** — orchestrator deleguje subtaski
- **Concurrent** — agenci pracują równolegle
- **Debate** — agenci dyskutują dla lepszej decyzji
- **Voting** — głosują na najlepsze rozwiązanie

## Agent design patterns

### Reflection
Agent ocenia własną pracę i poprawia:
```
Generate → Critique → Refine → Critique → Final
```

### Planning
Agent najpierw tworzy plan, potem wykonuje:
```
Goal → Plan (steps 1-N) → Execute step 1 → Re-plan → Execute step 2 → ...
```

### Tool use orchestration
Agent decyduje który tool kiedy:
```
Query → Identify needed tools → Execute in order → Synthesize results
```

## Bezpieczeństwo agentów

Agenci działający autonomicznie to ryzyko:
- **Prompt injection** — atakujący wpływa na decyzje
- **Niezamierzone akcje** — agent usuwa pliki
- **Loop infinity** — agent w nieskończonej pętli
- **Cost explosion** — agent wywołuje LLM 1000 razy
- **Data exfiltration** — agent wysyła wrażliwe dane

### Mitigations:
1. **Human-in-the-loop** — confirmation przed destructive actions
2. **Sandboxing** — agent w izolowanym środowisku
3. **Permission system** — explicit consent dla każdego tool
4. **Rate limiting** — max N akcji na minutę
5. **Cost limits** — max budget per session
6. **Audit logging** — log wszystkich akcji
7. **Input validation** — sanitize tool inputs
8. **Restricted tools** — tylko niezbędne tools

## Real-world agent applications

### Coding agents
- **Claude Code** (Anthropic) — terminal-based, multi-step coding
- **Cursor Composer** — multi-file edits w IDE
- **Aider** — open source CLI coding
- **Devin** (Cognition Labs) — fully autonomous SWE
- **GitHub Copilot Workspace** — repo-level changes
- **Cline / Continue** — open source IDE agents

### Research agents
- **Perplexity** — web search + synthesis
- **You.com** — multi-source research
- **Manus** — general purpose agent

### Customer support
- **Sierra** — AI customer support
- **Decagon** — enterprise AI agents
- **Intercom Fin** — built-in AI agent

### Personal assistants
- **Claude (Anthropic)** — claude.ai z Projects, Computer Use
- **ChatGPT Operator** — web automation agent

### Specialized
- **Code review** agents
- **Data analysis** agents
- **Sales prospecting** agents
- **HR screening** agents

## Computer Use (2024+)

Anthropic w 2024 udostępniła **Computer Use** — Claude może obsługiwać komputer (klikać, pisać, nawigować). W 2026 standardem dla browsing agents.

```python
response = client.messages.create(
    model="claude-opus-4-7",
    tools=[{"type": "computer_20250124"}],
    messages=[{"role": "user", "content": "Otwórz przeglądarkę i wyszukaj 'pogoda Warszawa'"}]
)
```

Model otrzymuje screenshot, decyduje gdzie kliknąć, co napisać.

## Trendy 2026

1. **Reasoning models w agentach** — Claude/o3/R1 pozwalają na skomplikowane planowanie
2. **MCP** — uniwersalny protokół dla tools
3. **Multi-agent collaboration** — zespoły agentów, nie pojedynczy
4. **Agent skill libraries** — preset zachowania (jak Claude Skills)
5. **Computer Use** — agenci jako digital workers
6. **Self-improving agents** — agenci uczą się z błędów
7. **Persistent memory** — agenci pamiętają miesiącami

## Praktyczna rada — kiedy budować agenta?

**TAK, agent ma sens gdy:**
- Zadanie wymaga **wielu kroków** trudnych do zaplanowania z góry
- Potrzebne są **różne narzędzia** (search + DB + compute)
- Decyzje zależą od pośrednich wyników
- Workflow jest **dynamiczny**, nie sztywny

**NIE, klasyczny pipeline lepszy gdy:**
- Workflow jest **przewidywalny** i zawsze ten sam
- Zadanie jest pojedyncze (1 LLM call wystarczy)
- Wymagana jest **deterministyczność**
- Latency jest krytyczne (agent = wiele LLM calls)

## Stack agenta — rekomendacja 2026

### Prosty agent
```
Claude Agent SDK + 5-10 tools (Python functions)
```

### Średni agent
```
LangGraph + MCP servers + LangSmith (observability)
```

### Zaawansowany multi-agent
```
LangGraph + AutoGen patterns + custom orchestration
+ Mem0/Letta (memory)
+ Langfuse (tracing)
+ Permissions middleware
```

### Production-ready
```
+ Human-in-the-loop dla destructive actions
+ Cost tracking i limits
+ Audit logs
+ Sandboxed execution (Docker, Firecracker)
+ Fallback strategies
+ Eval suite (real conversations)
```
