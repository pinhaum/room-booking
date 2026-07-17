# Plan: Fase 2 — Autorização (Policies)

**Source Roadmap**: `.claude/plans/room-booking-roadmap.plan.md`
**Selected Milestone**: Fase 2 — Autorização
**Complexity**: Small–Medium
**Depends on**: Fase 1 (concluída)

## Summary
Estabelecer a **camada de autorização própria** baseada em Policies (ADR-006), sem Pundit.
O modelo **não é RBAC puro**: as policies combinam **papel** (`user.admin?`) e **propriedade**
(`record.user == user`) — ver ADR-006 revisado. Esta fase entrega uma `ApplicationPolicy` base
(deny-by-default) com helpers `admin?`/`owner?`, e um concern `Authorization` que os controllers
usam para autorizar ações e que traduz negação em **HTTP 403** (ADR-009). Como ainda não há
recursos de domínio, entrega-se a **infraestrutura + um caminho 403 verificável**; policies
concretas (`RoomPolicy`, `ReservationPolicy`) subclassificam `ApplicationPolicy` nas Fases 3 e 4.

## Decisões-chave (fiéis aos ADRs)
- **Policies próprias (ADR-006):** convenção estilo Pundit (`Policy.new(user, record)`, métodos `action?`), mas implementação própria — sem a gem.
- **Deny-by-default:** todo método de `ApplicationPolicy` retorna `false`; subclasses liberam explicitamente.
- **Erro → HTTP (ADR-009):** negação levanta `Authorization::NotAuthorized`; o concern faz `rescue_from` → 403 + mensagem pt-BR.
- **Papel + ownership (ADR-006):** policies avaliam `user.admin?` (enum já existente) e, quando há dono, `record.user == user`. Não é RBAC puro; sem novos campos.
- **TDD (ADR-008):** specs de policy primeiro, depois request (403).

## Patterns to Mirror
| Category | Source | Pattern |
|---|---|---|
| Policy | ADR-006 | `app/policies/`, uma policy por recurso, base comum |
| Controller | `Authentication` concern (Fase 1) | Concern incluído no `ApplicationController`, helpers + `rescue_from` |
| Erro→HTTP | ADR-009 / `SessionsController` | Exceção específica traduzida em status/redirect |
| Testes | ADR-008 | `spec/policies/`, request spec para o 403 |
| i18n | `mem:conventions` | Mensagem de acesso negado em `config/locales/pt-BR.yml` |

## Files to Change
| File | Action | Why |
|---|---|---|
| `app/policies/application_policy.rb` | CREATE | Base deny-by-default + `Scope` interna |
| `app/policies/authorization/not_authorized.rb` (ou em `app/services`) | CREATE | Exceção de autorização |
| `app/controllers/concerns/authorization.rb` | CREATE | `authorize`, `policy`, `policy_scope`, `rescue_from NotAuthorized` → 403 |
| `app/controllers/application_controller.rb` | UPDATE | `include Authorization` |
| `config/locales/pt-BR.yml` | UPDATE | `authorization.not_authorized` |
| `public/403.html` (opcional) | CREATE | Página estática de acesso negado |
| `spec/policies/application_policy_spec.rb` | CREATE | Deny-by-default + Scope |
| `spec/support/authorization_helpers.rb` (opcional) | CREATE | Policy/controller de teste para exercitar o 403 |
| `spec/requests/authorization_spec.rb` | CREATE | Prova a tradução negação → 403 |

## Tasks (ordem TDD)

### Task 1: `ApplicationPolicy` base (TDD)
- **Action**: `spec/policies/application_policy_spec.rb`: por padrão `index?/show?/create?/update?/destroy?`
  retornam `false`; `Scope#resolve` retorna `scope.none` (ou `scope.all` — decidir e testar).
  Implementar `app/policies/application_policy.rb` com `initialize(user, record)`, métodos deny-by-default,
  helpers `admin?` (`user&.admin?`) e `owner?` (`record.respond_to?(:user) && record.user == user`),
  e classe interna `Scope` (`initialize(user, scope)` + `resolve`). Testar `owner?` com um record dummy
  que responda a `user`.
- **Mirror**: ADR-006.
- **Validate**: `docker compose run --rm -e RAILS_ENV=test web bundle exec rspec spec/policies`

### Task 2: Exceção + concern `Authorization`
- **Action**: definir `Authorization::NotAuthorized < StandardError`. Concern
  `app/controllers/concerns/authorization.rb`: `policy(record)` (resolve `#{record.class}Policy`),
  `authorize(record, query = nil)` (usa `"#{action_name}?"`; levanta `NotAuthorized` se falso e
  retorna o record se ok), `policy_scope(scope)`, e `rescue_from Authorization::NotAuthorized`
  respondendo `403` (HTML: página/redirect com alerta pt-BR; JSON: `head :forbidden`).
  Incluir no `ApplicationController`.
- **Mirror**: `Authentication` concern (Fase 1); ADR-009.
- **Validate**: `docker compose run --rm web bin/rails zeitwerk:check`

### Task 3: i18n + prova de 403 (TDD request)
- **Action**: `config/locales/pt-BR.yml` → `authorization.not_authorized: "Você não tem permissão..."`.
  `spec/requests/authorization_spec.rb`: usar um controller/policy de teste (em `spec/support`) ou
  uma rota admin-only mínima para provar: usuário sem permissão → **403**; autorizado → 200.
- **Mirror**: ADR-009, ADR-004 (status correto).
- **Validate**: `docker compose run --rm -e RAILS_ENV=test web bundle exec rspec spec/requests/authorization_spec.rb`

### Task 4: Portão de qualidade
- **Action**: suíte completa + ferramental.
- **Validate**: bloco abaixo.

## Validation
```bash
docker compose run --rm -e RAILS_ENV=test web bundle exec rspec
docker compose run --rm web bundle exec rubocop
docker compose run --rm web bin/brakeman -q
```

## Risks
| Risk | Likelihood | Mitigation |
|---|---|---|
| Autorização "no vazio" sem recursos → testes artificiais | Média | Usar policy/controller de teste em `spec/support`; policies reais chegam nas Fases 3–4 |
| Resolução de nome de policy (`XPolicy`) frágil | Baixa | Método explícito `policy_class`/convenção testada |
| Divergência entre `Scope#resolve` padrão (`none` vs `all`) | Média | Decidir deny-by-default (`none`) e documentar; recursos liberam explicitamente |
| Esquecer de chamar `authorize` num controller futuro | Média | (Fase 3+) adicionar `after_action :verify_authorized` opcional |

## Acceptance
- [ ] `ApplicationPolicy` deny-by-default com `Scope`; specs verdes
- [ ] Concern `Authorization` incluído; negação → 403 (HTML e JSON)
- [ ] Mensagem de acesso negado em pt-BR
- [ ] Request spec prova 403 (negado) e 200 (autorizado)
- [ ] `rspec` verde, `rubocop` limpo, `brakeman` sem alerta
- [ ] Commit: `feat(authz): add policy-based authorization layer`

## Próximo passo
Fase 3 — Rooms: criar `RoomPolicy < ApplicationPolicy` e aplicar `authorize`/`policy_scope`
no `RoomsController`. Gerar `phase-3-rooms.plan.md` ao iniciar.
