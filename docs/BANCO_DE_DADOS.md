# Banco de dados

Resumo do banco SQLite do TripWise. O projeto completo (diagrama entidade-relacionamento, dicionário de dados e SQL) está no PDF **[sprint3-armazenamento-e-persistencia.pdf](sprint3-armazenamento-e-persistencia.pdf)**.

## Visão geral

- **Banco:** SQLite, arquivo `tripwise.db`, gravado no próprio aparelho.
- **Pacote:** [`sqflite`](https://pub.dev/packages/sqflite) (no navegador: `sqflite_common_ffi_web`).
- **Sessão do usuário:** [`shared_preferences`](https://pub.dev/packages/shared_preferences), chave `usuario_id`.
- **Versão do esquema:** 1 (criado em `onCreate`; mudanças futuras devem usar `onUpgrade`).
- **Chaves estrangeiras ativadas** com `PRAGMA foreign_keys = ON`.

```text
Telas  ──►  Repositórios (lib/data/*_repository.dart)  ──►  DatabaseHelper  ──►  SQLite (tripwise.db)
   └────►  Session (lib/data/session.dart)  ──────────────────────────────►  SharedPreferences
```

## Tabelas

| Tabela | Para que serve | Relações |
|---|---|---|
| `usuarios` | Contas (nome, e-mail único, hash da senha, cidade) | 1:N com viagens, buscas e favoritos |
| `estilos` | Catálogo de estilos de viajante | N:N com usuários |
| `usuario_estilos` | Liga usuários aos estilos | FK → usuarios, estilos |
| `destinos` | Destinos avaliados pelo Travel Match | 1:N com custos e roteiro modelo |
| `custos_destino` | Custos de referência (passagem, hospedagem…) com unidade de cálculo | FK → destinos |
| `roteiro_modelo` | Roteiro sugerido de cada destino | FK → destinos |
| `buscas` | Histórico do questionário do match | FK → usuarios |
| `viagens` | Viagens planejadas (datas, pessoas, orçamento, status) | FK → usuarios, destinos |
| `roteiro_itens` | Atividades do roteiro de cada viagem | FK → viagens (cascade) |
| `favoritos` | Destinos favoritados | FK → usuarios, destinos |

O SQL completo de criação está em [`lib/data/schema.dart`](../lib/data/schema.dart).

## Onde está cada operação (CRUD)

| Tabela | Create | Read | Update | Delete |
|---|---|---|---|---|
| `usuarios` | Cadastro | Login, Home, Perfil | Perfil | Perfil → Excluir conta |
| `viagens` | Planejar esta viagem | Home, Minhas Viagens, Viagem | Editar viagem | Minhas Viagens, Viagem |
| `roteiro_itens` | + Atividade / cópia do roteiro sugerido | Tela da viagem | Editar atividade, marcar feita | Lixeira da atividade |
| `favoritos` | ♥ no destino | ♥ preenchido | — | ♥ de novo |
| `buscas` | Encontrar meu match | Preenche o questionário | — | Cascata |

## Arquivos do código

| Arquivo | Conteúdo |
|---|---|
| `lib/data/schema.dart` | `CREATE TABLE` das 10 tabelas e dados iniciais (8 destinos) |
| `lib/data/database_helper.dart` | Abre o banco, ativa as chaves estrangeiras, cria tabelas e dados |
| `lib/data/usuario_repository.dart` | CRUD de usuários e estilos, hash da senha |
| `lib/data/viagem_repository.dart` | CRUD de viagens e itens do roteiro |
| `lib/data/destino_repository.dart` | Destinos, cálculo do Travel Match, buscas e favoritos |
| `lib/data/session.dart` | Sessão com SharedPreferences |
| `test/database_test.dart` | Testes do CRUD em banco em memória |

## Ver os dados no celular virtual

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb shell "run-as br.pucminas.tripwise sqlite3 databases/tripwise.db '.tables'"
& $adb shell "run-as br.pucminas.tripwise sqlite3 databases/tripwise.db 'SELECT * FROM viagens;'"
```

Mais detalhes no **[Manual de demonstração](DEMONSTRACAO.md#4-provar-que-os-dados-estão-gravados)**.
