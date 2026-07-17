# Plan: Fase 1 — Autenticação

**Source Roadmap**: `.claude/plans/room-booking-roadmap.plan.md`
**Selected Milestone**: Fase 1 — Autenticação
**Complexity**: Medium
**Depends on**: Fase 0 (concluída)

## Summary
Introduzir o modelo `User` com `has_secure_password` e autenticação **baseada em sessão**
(ADR-002), expondo `/login` e `/logout`. A verificação de credenciais fica num Service
(`UserAuthenticator`) que retorna o usuário ou levanta exceção específica; o
`SessionsController` traduz isso em resposta HTTP (ADR-009). Sem autorização por papéis
ainda (isso é a Fase 2) — aqui só autenticação e a sessão do usuário logado.

## Decisões-chave (fiéis aos ADRs)
- **Sessão + `has_secure_password` (ADR-002):** adicionar `bcrypt`; sem Devise/JWT.
- **Native-first (ADR-012):** cookie de sessão do Rails; `Current` attributes para o usuário logado.
- **Erros via Service (ADR-009):** `UserAuthenticator` levanta `UserAuthenticator::InvalidCredentials`; o controller converte para 401/redirect.
- **Segurança:** `reset_session` no login (anti session fixation); e-mail normalizado (downcase) e único; comparação constante mesmo com usuário inexistente (evitar enumeração).
- **TDD (ADR-008):** ordem Services → Models → Requests.

## Patterns to Mirror
| Category | Source | Pattern |
|---|---|---|
| Service | ADR-001 / ADR-009 | Caso de uso em `app/services/`; retorna resultado ou levanta exceção específica |
| Model | `mem:conventions` | AR só persistência/validação; regra fica no service |
| Controller | `ARCHITECTURE.md` | Enxuto: delega ao service e traduz resultado/exceção em HTTP |
| Testes | ADR-008 | RSpec; specs de service → model → request; FactoryBot; Shoulda |
| i18n | `mem:conventions` | Mensagens ao usuário em `config/locales/pt-BR.yml` |

## Files to Change
| File | Action | Why |
|---|---|---|
| `Gemfile` | UPDATE | Descomentar `gem "bcrypt"` (necessário para `has_secure_password`) |
| `db/migrate/*_create_users.rb` | CREATE | Tabela `users` + índice único em `email` |
| `db/seeds.rb` | UPDATE | Semear um usuário admin de desenvolvimento |
| `app/models/user.rb` | CREATE | `has_secure_password`, validações, enum `role`, normalização de e-mail |
| `app/models/current.rb` | CREATE | `Current.user` (ActiveSupport::CurrentAttributes) |
| `app/services/user_authenticator.rb` | CREATE | Autentica email+senha; retorna `User` ou levanta `InvalidCredentials` |
| `app/controllers/concerns/authentication.rb` | CREATE | `current_user`, `logged_in?`, `require_authentication`, `sign_in`/`sign_out` |
| `app/controllers/application_controller.rb` | UPDATE | `include Authentication` |
| `app/controllers/sessions_controller.rb` | CREATE | `new`/`create`/`destroy` |
| `app/views/sessions/new.html.erb` | CREATE | Formulário de login (Tailwind) |
| `config/routes.rb` | UPDATE | `get/post "/login"`, `delete "/logout"`, `root` |
| `config/locales/pt-BR.yml` | UPDATE | Mensagens de erro/sucesso de autenticação |
| `spec/factories/users.rb` | CREATE | Factory de `User` (Faker) |
| `spec/services/user_authenticator_spec.rb` | CREATE | Specs do service (TDD, primeiro) |
| `spec/models/user_spec.rb` | CREATE | Specs de model (validações, secure password) |
| `spec/requests/sessions_spec.rb` | CREATE | Specs de request (login/logout, sessão) |

## Tasks (ordem TDD)

### Task 1: bcrypt + factory + migration da tabela `users`
- **Action**: descomentar `gem "bcrypt"` no Gemfile e `bundle install` (como root no container).
  Gerar migration `create_users`: `name:string` (null: false), `email:string` (null: false),
  `password_digest:string` (null: false), `role:integer` (null: false, default: 0);
  `add_index :users, :email, unique: true`. Criar `spec/factories/users.rb`.
- **Mirror**: ADR-005 (modelo de dados), ADR-008 (FactoryBot).
- **Validate**: `docker compose run --rm web bin/rails db:migrate && bin/rails db:test:prepare`

### Task 2: Model `User` (TDD — escrever specs primeiro)
- **Action**: `spec/models/user_spec.rb` cobrindo: validações de presença (`name`, `email`),
  unicidade case-insensitive de `email`, formato de e-mail, `has_secure_password` (senha mínima),
  enum `role` (`member: 0`, `admin: 1`, default `member`), normalização de e-mail (downcase/strip).
  Implementar `app/models/user.rb` até verde.
- **Mirror**: Shoulda Matchers (`validate_presence_of`, `validate_uniqueness_of`, `have_secure_password`).
- **Validate**: `docker compose run --rm -e RAILS_ENV=test web bundle exec rspec spec/models/user_spec.rb`

### Task 3: Service `UserAuthenticator` (TDD)
- **Action**: `spec/services/user_authenticator_spec.rb`: (a) credenciais válidas → retorna o `User`;
  (b) senha errada → levanta `UserAuthenticator::InvalidCredentials`; (c) e-mail inexistente →
  mesma exceção (sem vazar qual campo falhou); (d) e-mail com caixa/espaços diferentes → autentica.
  Implementar `app/services/user_authenticator.rb` (`call(email:, password:)`), fazendo um
  `BCrypt::Password` dummy quando o usuário não existe (comparação em tempo constante).
- **Mirror**: ADR-009 (service levanta exceção específica).
- **Validate**: `docker compose run --rm -e RAILS_ENV=test web bundle exec rspec spec/services`

### Task 4: Sessão do usuário — concern `Authentication` + `Current`
- **Action**: `app/models/current.rb` com `attribute :user`. `app/controllers/concerns/authentication.rb`
  com `current_user` (memoiza `Current.user ||= User.find_by(id: session[:user_id])`),
  `logged_in?`, `require_authentication` (redireciona/`401` se anônimo), `sign_in(user)`
  (`reset_session` + `session[:user_id] = user.id`) e `sign_out` (`reset_session`).
  Incluir no `ApplicationController`; expor `current_user`/`logged_in?` como `helper_method`.
- **Mirror**: `ARCHITECTURE.md` (controllers enxutos), native-first (ADR-012).
- **Validate**: `docker compose run --rm web bin/rails zeitwerk:check`

### Task 5: `SessionsController` + rotas + view (TDD request)
- **Action**: `spec/requests/sessions_spec.rb`: `GET /login` (200, formulário); `POST /login`
  válido (redireciona autenticado, `session[:user_id]` setado); `POST /login` inválido
  (re-renderiza com flash de erro em pt-BR, status 422); `DELETE /logout` (limpa sessão).
  Implementar `SessionsController#new/create/destroy` (delegando ao service, `rescue`
  `InvalidCredentials`), rotas (`get/post "/login"`, `delete "/logout"`), e `sessions/new.html.erb`.
- **Mirror**: ADR-009 (tradução exceção→HTTP), ADR-004 (status corretos).
- **Validate**: `docker compose run --rm -e RAILS_ENV=test web bundle exec rspec spec/requests`

### Task 6: i18n pt-BR + seed admin
- **Action**: mensagens em `config/locales/pt-BR.yml` (ex.: `auth.invalid_credentials`,
  `auth.signed_in`, `auth.signed_out`). Adicionar seed de usuário admin em `db/seeds.rb`.
- **Mirror**: `mem:conventions` (mensagens ao usuário em pt-BR).
- **Validate**: `docker compose run --rm web bin/rails db:seed` (idempotente via `find_or_create_by`)

### Task 7: Portão de qualidade
- **Action**: rodar a suíte completa e o ferramental.
- **Validate**: bloco de Validation abaixo.

## Validation
```bash
docker compose run --rm --user root web bundle install
docker compose run --rm web bin/rails db:migrate
docker compose run --rm -e RAILS_ENV=test web bin/rails db:test:prepare

docker compose run --rm -e RAILS_ENV=test web bundle exec rspec
docker compose run --rm web bundle exec rubocop
docker compose run --rm web bin/brakeman -q

# Fluxo manual (opcional): subir e testar login
docker compose up -d && curl -si http://localhost:3000/login | head -1
```

## Risks
| Risk | Likelihood | Mitigation |
|---|---|---|
| Enumeração de usuários pela diferença de tempo/resposta | Média | Mesma exceção para senha errada e e-mail inexistente + compare dummy em tempo constante |
| Session fixation | Média | `reset_session` antes de setar `session[:user_id]` |
| Unicidade de e-mail case-sensitive no banco | Média | Normalizar downcase no model + índice único; considerar `citext` numa migration futura |
| `role` como enum inteiro dificultando leitura | Baixa | Enum nomeado (`member`/`admin`); documentar |
| Brakeman apontar CSRF/redirect | Baixa | Manter `protect_from_forgery` (default) e redirects internos |

## Acceptance
- [ ] `bcrypt` ativo; migration aplicada; `User` com `has_secure_password` e enum `role`
- [ ] `UserAuthenticator` retorna usuário ou levanta `InvalidCredentials` (specs verdes)
- [ ] `/login` (GET/POST) e `/logout` funcionam; sessão setada/limpa; `reset_session` no login
- [ ] Mensagens de erro em pt-BR
- [ ] `rspec` verde, `rubocop` limpo, `brakeman` sem alerta
- [ ] Commit: `feat(auth): add session-based authentication with has_secure_password`

## Próximo passo
Fase 2 — Autorização (Policies): usar `current_user`/`role` como base para
`ApplicationPolicy` e regras de acesso. Gerar `phase-2-authorization.plan.md` ao iniciar.
