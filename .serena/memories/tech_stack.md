# Tech Stack (alvo — ver `mem:core`; ainda não instalado)

- **Linguagem**: Ruby 4.x (ou versão estável compatível)
- **Framework**: Rails 8
- **Banco**: PostgreSQL
- **Cache**: Solid Cache
- **Background jobs**: Solid Queue (via Active Job)
- **Autenticação**: `has_secure_password` (sessão). Futuro: Devise.
- **Autorização**: Policies próprias. Futuro: Pundit.
- **Front-end**: ERB + Turbo + Stimulus + TailwindCSS
- **API**: REST/JSON, prefixo `/api/v1`
- **Testes**: RSpec, FactoryBot, Faker, Shoulda Matchers, SimpleCov
- **Qualidade**: RuboCop, Brakeman, Bullet
- **Upload**: Active Storage
- **Paginação**: Pagy
- **i18n**: I18n (mensagens de erro voltadas ao usuário em pt-BR)
- **Container**: Docker + Docker Compose
- **Email (dev)**: Mailpit + Action Mailer

## Recursos de API previstos
`/login`, `/logout`, `/rooms`, `/reservations` (JSON + códigos HTTP corretos).

Política de dependências (ADR-012): priorizar recursos nativos do Rails; adicionar
gems só quando agregarem valor claro.
