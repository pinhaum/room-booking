# Roadmap de Implementação: room-booking (Rails 8)

**Modo:** conversational (sem PRD)
**Fonte de requisitos:** `.context/ecosystem.md` + `.context/decisions/ADR-001..012`
**Estado atual:** só documentação — nenhum `Gemfile`, `app/`, banco ou teste existe
**Complexidade global:** Média-Alta (projeto de estudo, greenfield, arquitetura em camadas)

## Restrições do usuário (aplicadas)
- Preservar o `.gitignore` já redigido e o `.tool-versions` (ruby 3.4.8 — LTS, não v4).
- Docker Compose padronizado desde o início.
- RuboCop ativado incrementalmente (`.rubocop_todo.yml`).
- Validar + commitar ao fim de cada fase.

## Princípio transversal
Cada fase termina com o **portão de qualidade** (Definition of Done do `ecosystem.md`):
testes verdes → `rubocop` limpo → `brakeman` sem alerta crítico → docs/ADR atualizados →
commit convencional. TDD na prioridade: **Services → Models → Requests → Policies → Jobs**.

---

## Fase 0 — Fundação / Bootstrap
**Objetivo:** projeto Rails 8 rodando em Docker, suíte de testes verde, andaime vazio.
- `rails new` (Rails 8, PostgreSQL, Tailwind, Turbo/Stimulus), preservando `.gitignore` e `.tool-versions`.
- Docker Compose: `web` (Ruby 3.4.8), `db` (Postgres), `mailpit`. Solid Cache/Solid Queue configurados.
- RSpec + FactoryBot + Faker + Shoulda + SimpleCov; RuboCop (rails-omakase, ajuste incremental) + Brakeman + Bullet.
- I18n com `pt-BR` para mensagens de usuário.
- Criar diretórios de camadas (`services/ policies/ queries/ ...`) com autoload verificado.
- **Gate:** `rspec` verde (smoke test), app sobe via `docker compose up`.
- **Complexidade:** Média · **Dependências:** nenhuma.

## Fase 1 — Autenticação
**Objetivo:** `User` + login/logout por sessão.
- Model `User` (name, email, password_digest, role) com `has_secure_password` (ADR-002).
- `SessionsController` (`/login`, `/logout`), service de autenticação, tratamento de erro (ADR-009).
- **Gate:** specs de model + request de login/logout.
- **Complexidade:** Média · **Dependências:** Fase 0.

## Fase 2 — Autorização (Policies)
**Objetivo:** camada de policies própria (ADR-006), base para regras de cancelamento.
- `ApplicationPolicy` + convenção de uso nos controllers; ainda sem Pundit.
- **Gate:** specs de policy isoladas.
- **Complexidade:** Baixa · **Dependências:** Fase 1.

## Fase 3 — Rooms
**Objetivo:** CRUD de salas + filtros.
- Model `Room` (name, capacity, description, available); Scopes/Queries para busca/filtro (ADR-010).
- Services (`RoomCreator`, etc.) + controllers enxutos.
- **Gate:** specs service/model/request/policy.
- **Complexidade:** Média · **Dependências:** Fase 2.

## Fase 4 — Reservations (núcleo do domínio)
**Objetivo:** reservas com todas as invariantes de negócio.
- Model `Reservation` (room, user, starts_at, ends_at, purpose, status).
- Services `ReservationCreator`, `ReservationCanceller`, `RoomAvailabilityChecker`.
- Invariantes (ADR-003): sem sobreposição na mesma sala; sem reserva no passado;
  `ends_at > starts_at`; cancelamento só por criador/admin.
- **Gate:** specs cobrindo cada invariante (foco em service).
- **Complexidade:** Alta · **Dependências:** Fase 3.

## Fase 5 — API `/api/v1`
**Objetivo:** expor `/rooms` e `/reservations` em JSON.
- Serializers, códigos HTTP corretos, tradução centralizada de exceções→HTTP (ADR-004/009), Pagy na listagem.
- **Gate:** request specs de contrato JSON + status codes.
- **Complexidade:** Média · **Dependências:** Fases 3–4.

## Fase 6 — Auditoria
**Objetivo:** registrar criação/edição/cancelamento de reservas (ADR-011).
- Trilha de auditoria (via callback/service dedicado, conforme ADR).
- **Gate:** specs verificando registros de auditoria nos 3 eventos.
- **Complexidade:** Média · **Dependências:** Fase 4.

## Fase 7 — Jobs + Mailer
**Objetivo:** notificações assíncronas.
- Solid Queue via Active Job (ADR-007), Action Mailer + Mailpit (dev) para e-mails de reserva.
- **Gate:** job specs + mailer specs.
- **Complexidade:** Média · **Dependências:** Fases 4, 6.

## Fase 8 — Front-end
**Objetivo:** UI ERB + Turbo/Stimulus/Tailwind.
- Telas de salas/reservas, Active Storage (uploads, se aplicável a salas), Pagy na UI.
- **Gate:** request/system specs das telas principais.
- **Complexidade:** Média-Alta · **Dependências:** Fases 3–5.

---

## Riscos
| Risco | Prob. | Mitigação |
|---|---|---|
| Concorrência em reservas sobrepostas (race condition) | Alta | Constraint de exclusão no Postgres + checagem no service; teste concorrente |
| Escopo grande para projeto de estudo | Média | Fases pequenas e commitáveis; parar em qualquer gate |
| RuboCop "omakase" gerando ruído inicial | Média | Ativar cops incrementalmente, `.rubocop_todo.yml` |
| Solid Queue/Cache config no Rails 8 + Docker | Média | Validar já na Fase 0, não deixar para a Fase 7 |
| Fuso/timezone em `starts_at/ends_at` | Média | Definir timezone da app e testar limites de "passado" |

## Ordem crítica de dependências
`Fase 0 → 1 → 2 → 3 → 4` é o caminho obrigatório.
`5, 6, 7, 8` derivam de 3–4 e podem ser reordenadas conforme prioridade de estudo.

## Próximo passo
Cada fase merece seu próprio `/ecc:plan` detalhado (tarefas + validação) ao chegar nela.
Recomendação: começar detalhando a **Fase 0**.
