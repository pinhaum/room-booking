# Plan: Fase 3 — Rooms (CRUD + filtros)

**Source Roadmap**: `.claude/plans/room-booking-roadmap.plan.md`
**Selected Milestone**: Fase 3 — Rooms
**Complexity**: Medium
**Depends on**: Fase 2 (concluída)

## Summary
Entregar o recurso **`Room`**: model persistente (ADR-005), casos de uso em Service Objects
(ADR-001/003), filtros via **Scopes do ActiveRecord** (ADR-010), `RoomPolicy < ApplicationPolicy`
(ADR-006: leitura para autenticados, escrita só admin) e um `RoomsController` enxuto usando
`authorize`/`policy_scope`. É o primeiro recurso de domínio real — consolida o padrão que
`Reservation` seguirá na Fase 4. Views ERB mínimas para exercitar o CRUD; o polimento de UI
fica para a Fase 8.

## Decisões-chave (fiéis aos ADRs)
- **Services (ADR-001/003):** `RoomCreator`, `RoomUpdater`, `RoomDestroyer` encapsulam a escrita;
  controller só orquestra. Mesmo padrão do `UserAuthenticator` (método de classe `.call`, exceção específica).
- **Filtros via Scopes (ADR-010):** `Room.available`, `Room.with_min_capacity(n)`, `Room.search_by_name(q)`;
  combinados por um método de classe `Room.filter(params)` (ou query object) para o controller não montar cadeias.
- **Autorização (ADR-006):** `RoomPolicy` — `index?/show?` liberados a qualquer usuário logado; `create?/update?/destroy?` exigem `admin?`. Sala não tem dono, então `owner?` não se aplica; `Scope#resolve` retorna `scope.all` (todos veem todas as salas).
- **Erro → HTTP (ADR-009):** services levantam exceção específica em falha; controller traduz (validação → `422`, negação de policy → `403` já tratado pelo concern).
- **Integridade (ADR-005):** `null: false` nas colunas obrigatórias, `default` para `available`, comentários nas colunas da tabela (convenção SQL do projeto).
- **TDD (ADR-008):** ordem Service → Model → Request → Policy.

## Patterns to Mirror
| Category | Source | Pattern |
|---|---|---|
| Service | `app/services/user_authenticator.rb` | `.call(**)` de classe, `new.call`, exceção interna (`InvalidCredentials`) |
| Controller enxuto | `app/controllers/sessions_controller.rb` | Chama service, `rescue` → flash + status; sem regra de negócio |
| Policy | `app/policies/application_policy.rb` | Subclasse abre ações explicitamente; helper `admin?` |
| Autorização no controller | `Authorization` concern (Fase 2) | `authorize(record)` / `policy_scope(Room)` |
| Model + enum/normalização | `app/models/user.rb` | `before_validation`, validações explícitas |
| i18n | `config/locales/pt-BR.yml` | Chaves de domínio + mensagens de usuário em pt-BR |
| Testes | `spec/services/`, `spec/models/`, `spec/requests/`, `spec/policies/` | Um spec por camada; FactoryBot |

## Files to Change
| File | Action | Why |
|---|---|---|
| `db/migrate/XXXXXX_create_rooms.rb` | CREATE | Tabela `rooms` (name, capacity, description, available) + comentários |
| `db/schema.rb` | UPDATE | Resultado do migrate |
| `app/models/room.rb` | CREATE | Validações + Scopes de filtro (ADR-010) |
| `app/services/room_creator.rb` | CREATE | Caso de uso: criar sala |
| `app/services/room_updater.rb` | CREATE | Caso de uso: atualizar sala |
| `app/services/room_destroyer.rb` | CREATE | Caso de uso: remover sala |
| `app/policies/room_policy.rb` | CREATE | Leitura p/ logados, escrita p/ admin; `Scope#resolve = scope.all` |
| `app/controllers/rooms_controller.rb` | CREATE | CRUD enxuto; `authorize` + `policy_scope` + filtros |
| `config/routes.rb` | UPDATE | `resources :rooms` |
| `app/views/rooms/index.html.erb` | CREATE | Lista + form de filtro (Tailwind mínimo) |
| `app/views/rooms/show.html.erb` | CREATE | Detalhe |
| `app/views/rooms/new.html.erb` / `edit.html.erb` / `_form.html.erb` | CREATE | Form admin |
| `config/locales/pt-BR.yml` | UPDATE | `activerecord.attributes.room.*` + `rooms.*` (flash) |
| `db/seeds.rb` | UPDATE | Semear algumas salas idempotentemente (dev) |
| `spec/factories/rooms.rb` | CREATE | Factory `:room` (+ trait `:unavailable`) |
| `spec/models/room_spec.rb` | CREATE | Validações + cada scope |
| `spec/services/room_creator_spec.rb` (+ updater/destroyer) | CREATE | Sucesso e falha de cada service |
| `spec/policies/room_policy_spec.rb` | CREATE | member vs admin; Scope |
| `spec/requests/rooms_spec.rb` | CREATE | CRUD + 403 (member tentando escrever) + filtros |

## Tasks (ordem TDD)

### Task 1: Migration + Model `Room` com Scopes
- **Action**: migration `create_rooms` — `name:string null:false`, `capacity:integer null:false`,
  `description:text`, `available:boolean null:false default:true`; comentários nas colunas; índice em `name`.
  Model `Room`: validações (`name` presença/unicidade, `capacity` inteiro > 0, `available` inclusão),
  scopes `available`, `with_min_capacity(n)`, `search_by_name(q)` (ILIKE), e `self.filter(params)`
  compondo os scopes conforme chaves presentes.
- **Mirror**: `app/models/user.rb` (validações explícitas); ADR-005 (integridade); ADR-010 (scopes).
- **Validate**: `docker compose run --rm -e RAILS_ENV=test web bundle exec rspec spec/models/room_spec.rb`

### Task 2: Services (`RoomCreator`/`RoomUpdater`/`RoomDestroyer`)
- **Action**: cada service com `.call`; sucesso retorna o `Room`, falha de validação levanta
  exceção específica (ex.: `RoomCreator::InvalidRoom`) carregando o record inválido para o controller
  ler `record.errors`. Espelhar a forma de `UserAuthenticator`.
- **Mirror**: `app/services/user_authenticator.rb`; ADR-003/009.
- **Validate**: `docker compose run --rm -e RAILS_ENV=test web bundle exec rspec spec/services`

### Task 3: `RoomPolicy`
- **Action**: `index?`/`show?` → `true` (qualquer autenticado); `create?`/`update?`/`destroy?` → `admin?`;
  `Scope#resolve` → `scope.all`. Spec cobrindo member (só leitura) e admin (tudo).
- **Mirror**: `app/policies/application_policy.rb` (helper `admin?`).
- **Validate**: `docker compose run --rm -e RAILS_ENV=test web bundle exec rspec spec/policies/room_policy_spec.rb`

### Task 4: `RoomsController` + rotas + views + i18n
- **Action**: `resources :rooms`. Controller: `require_authentication`; `index` usa
  `policy_scope(Room).filter(filter_params)`; `show` autoriza; `new/create/edit/update/destroy`
  chamam `authorize` e delegam ao service, com `rescue` da exceção do service → `render ... :unprocessable_entity`
  (mensagem pt-BR) ou redirect com flash de sucesso. Views ERB enxutas com Tailwind; form de filtro no index.
  i18n: atributos do model + flashes (`rooms.created/updated/destroyed`).
- **Mirror**: `SessionsController` (rescue→status); `Authorization` concern; `config/locales/pt-BR.yml`.
- **Validate**: `docker compose run --rm -e RAILS_ENV=test web bundle exec rspec spec/requests/rooms_spec.rb`
  e `docker compose run --rm web bin/rails zeitwerk:check`

### Task 5: Seeds + portão de qualidade
- **Action**: `db/seeds.rb` semeia salas (idempotente, `Rails.env.local?`). Rodar suíte completa + ferramental.
- **Validate**: bloco abaixo.

## Validation
```bash
docker compose run --rm -e RAILS_ENV=test web bin/rails db:prepare
docker compose run --rm -e RAILS_ENV=test web bundle exec rspec
docker compose run --rm web bundle exec rubocop
docker compose run --rm web bin/brakeman -q
```

## Risks
| Risk | Likelihood | Mitigation |
|---|---|---|
| `search_by_name` com ILIKE e input não sanitizado | Média | Usar `sanitize_sql_like` + placeholder do AR; nunca interpolar |
| Filtros montados no controller (lógica vazando) | Média | Centralizar em `Room.filter` (ou query object); controller só passa params |
| Views ERB expandindo escopo (Fase 8) | Média | Manter views mínimas; polimento de UI é Fase 8 |
| `capacity` aceitando 0/negativo | Baixa | Validação `numericality: greater_than: 0` + teste |
| Unicidade de `name` case-insensitive divergente do índice | Baixa | Decidir (case-insensitive) e alinhar validação + índice |

## Acceptance
- [ ] Migration com `null:false`/`default`/comentários; `Room` com validações e scopes; specs de model verdes
- [ ] `RoomCreator/Updater/Destroyer` com sucesso e falha cobertos
- [ ] `RoomPolicy`: leitura p/ logados, escrita só admin; Scope testada
- [ ] `RoomsController` CRUD enxuto; member recebe 403 ao escrever; filtros funcionando
- [ ] Atributos e flashes em pt-BR
- [ ] `rspec` verde, `rubocop` limpo, `brakeman` sem alerta
- [ ] Commit: `feat(rooms): add room resource with filtering and policy`

## Próximo passo
Fase 4 — Reservations: `Reservation` referencia `Room` e `User`; services de reserva/cancelamento
e `RoomAvailabilityChecker` com as invariantes do ADR-003. Gerar `phase-4-reservations.plan.md` ao iniciar.
