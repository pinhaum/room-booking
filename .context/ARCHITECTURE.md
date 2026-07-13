# Architecture

Este documento descreve a arquitetura geral do projeto.

- MVC
- Service Objects
- Active Job
- Policies
- RSpec

# Estrutura

```
app/
├── controllers/
├── models/
├── services/
├── policies/
├── presenters/
├── queries/
├── jobs/
├── mailers/
├── serializers/
├── forms/
├── validators/
└── components/
```

# Arquitetura

- Controllers apenas recebem requisições e delegam.
- Models representam entidades e persistência.
- Services implementam casos de uso.
- Policies coBootstrap 5ncentram autorização.
- Jobs executam tarefas assíncronas.
- Mailers enviam e-mails.
