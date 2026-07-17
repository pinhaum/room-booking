# ADR-006 — Autorização

## Status
Aceito

## Contexto
O acesso depende de dois critérios distintos: o **papel** do usuário (`role`: member/admin)
e a **propriedade** do recurso (ex.: "apenas o criador ou um admin pode cancelar uma reserva",
ver `domain.md`). RBAC puro (só papéis) não cobre a regra de ownership.

## Decisão
Centralizar toda autorização em **Policies próprias** (sem Pundit ou outra gem). O modelo
**não é RBAC puro**: cada Policy avalia, quando aplicável, tanto o papel (`user.admin?`) quanto
a propriedade do recurso (`record.user == user`). Uma `ApplicationPolicy` define o padrão
deny-by-default; cada recurso tem sua policy (`RoomPolicy`, `ReservationPolicy`) liberando
ações explicitamente.

## Consequências
- Regras de acesso ficam em um único lugar por recurso, testáveis isoladamente.
- Suporta combinação papel + ownership sem forçar tudo em papéis.
- Papéis novos ou regras de ownership mais ricas são adicionados nas policies, sem gem externa.
- Evolução futura para Pundit é possível pois a convenção (`Policy.new(user, record)`, métodos `action?`) já é compatível.
