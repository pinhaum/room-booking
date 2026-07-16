# room-booking — Core

Aplicação **Ruby on Rails 8** para gerenciamento de reservas de salas de reunião.
Projeto de **estudo** (arquitetura, boas práticas, desenvolvimento orientado por IA).

## Estado atual (IMPORTANTE)
O repositório contém **apenas documentação** — ainda **não há código Rails, Gemfile,
banco ou testes**. Os diretórios `app/`, `spec/`, etc. descritos abaixo são o alvo a
ser criado, não o estado atual. Antes de assumir que algo existe, verifique.

## Mapa de fontes
- `README.md` — placeholder (só o título).
- `.context/ecosystem.md` — visão geral: objetivo, stack completa, recursos de API,
  estratégia de testes, Definition of Done. **Fonte primária de requisitos.**
- `.context/ARCHITECTURE.md` — padrões arquiteturais e estrutura de `app/`.
- `.context/domain.md` — entidades (User, Room, Reservation) e regras de negócio.
- `.context/decisions/ADR-001..012` — decisões arquiteturais (curtas, uma decisão cada).

## Domínio
- **User**: name, email, password_digest, role.
- **Room**: name, capacity, description, available.
- **Reservation**: room, user, starts_at, ends_at, purpose, status.

## Invariantes de negócio (ADR + domain.md)
- Não permitir reservas sobrepostas na mesma sala.
- Não permitir reservas no passado.
- `ends_at` deve ser maior que `starts_at`.
- Apenas o criador ou um admin pode cancelar uma reserva.
- Registrar auditoria de criação, edição e cancelamento de reservas.

## Memórias relacionadas
`mem:tech_stack`, `mem:conventions`, `mem:suggested_commands`, `mem:task_completion`.
