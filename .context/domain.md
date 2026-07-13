# Domínio

## Entidades

### User

- name
- email
- password_digest
- role

### Room

- name
- capacity
- description
- available

### Reservation

- room
- user
- starts_at
- ends_at
- purpose
- status

## Regras

- Não permitir reservas sobrepostas.
- Não permitir reservas no passado.
- Hora final deve ser maior que a inicial.
- Apenas o criador ou administrador pode cancelar.
