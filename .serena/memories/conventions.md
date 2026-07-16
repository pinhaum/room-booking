# Convenções

## Arquitetura (ADR-001, ARCHITECTURE.md)
MVC + Service Objects. Camadas em `app/`:
`controllers models services policies presenters queries jobs mailers serializers forms validators components`.

- **Controllers**: enxutos — só recebem a requisição e delegam; convertem resultados/exceções de services em respostas HTTP.
- **Models**: entidades e persistência (Active Record); sem regra de negócio pesada.
- **Services** (`app/services`): casos de uso. Ex.: `ReservationCreator`, `ReservationCanceller`, `RoomAvailabilityChecker`.
- **Policies**: toda autorização centralizada aqui.
- **Queries/Scopes**: pesquisa e filtros via Scopes do Active Record (ADR-010).
- **Jobs**: tarefas demoradas via Active Job (ADR-007).

## Tratamento de erros (ADR-009)
Services retornam um resultado OU levantam exceções específicas; o controller traduz para HTTP.

## Idioma
- Código, identificadores e mensagens de commit: **inglês**.
- Mensagens de erro voltadas ao usuário: **pt-BR** (via I18n).
- Documentação/ADRs do projeto: pt-BR.

## Commits (padrão do usuário)
Conventional Commits: `type(scope): description in English`.
Ex.: `feat(reservation): add overlap validation`.

## ADRs
Registrar decisões em `.context/decisions/ADR-XXX-*.md`, formato curto: Status / Contexto / Decisão / Consequências.
