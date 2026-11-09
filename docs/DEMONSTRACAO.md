# Manual de demonstração em aula

Roteiro para apresentar o TripWise **no celular virtual (emulador Android) do computador** e provar ao professor que os dados ficam **gravados no aparelho** (SQLite + SharedPreferences).

> Ainda não instalou nada? Comece pelo **[Manual de instalação](INSTALACAO.md)**.

**Duração sugerida:** 8 a 10 minutos.

---

## Sumário

1. [Checklist antes da aula](#1-checklist-antes-da-aula)
2. [Ligar o celular virtual e abrir o app](#2-ligar-o-celular-virtual-e-abrir-o-app)
3. [Roteiro da demonstração (CRUD)](#3-roteiro-da-demonstração-crud)
4. [Provar que os dados estão gravados](#4-provar-que-os-dados-estão-gravados)
5. [O que falar sobre o banco de dados](#5-o-que-falar-sobre-o-banco-de-dados)
6. [Plano B se algo der errado](#6-plano-b-se-algo-der-errado)

---

## 1. Checklist antes da aula

Faça isto **antes** de chegar na sala (de preferência no dia anterior):

- [ ] Abrir o app pelo menos uma vez no emulador (a **primeira compilação demora**).
- [ ] Rodar `flutter test` e ver `All tests passed!`.
- [ ] Decidir se vai começar **com o app vazio** (mostra o cadastro) ou com dados de exemplo.
  - Para **zerar** os dados do app:
    ```powershell
    & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" shell pm clear br.pucminas.tripwise
    ```
- [ ] Notebook **na tomada** (o emulador gasta bateria) e com o **PDF da Sprint 3** aberto em outra janela.
- [ ] Deixar dois PowerShell abertos: um para o app e outro para os comandos de prova (seção 4).

---

## 2. Ligar o celular virtual e abrir o app

1. Abra o **Android Studio** → **More Actions → Virtual Device Manager** → clique em **▶** no aparelho.
2. Espere a tela inicial do Android aparecer.
3. No **PowerShell 1**:
   ```powershell
   cd CAMINHO\DA\PASTA\tripwise
   flutter run -d emulator-5554
   ```
4. Quando aparecer `Flutter run key commands`, o app está aberto. **Não feche esse PowerShell.**

> Atalho: se o app já foi instalado antes, também dá para abrir pelo ícone **TripWise** no emulador. Mas para usar o Database Inspector (seção 4.3) ele precisa ter sido aberto pelo `flutter run`.

---

## 3. Roteiro da demonstração (CRUD)

Cada passo mostra uma operação no banco. Fale a letra (C, R, U, D) em voz alta, pois ajuda o professor a acompanhar.

| # | Faça no app | O que acontece no banco |
|---|---|---|
| 1 | Tela inicial → **Começar agora** → preencha nome, e-mail, cidade e senha, escolha estilos → **Criar conta** | **C** `INSERT` em `usuarios` e `usuario_estilos` (senha salva como hash) |
| 2 | Mostre a **Home** com o seu nome | **R** `SELECT` em `usuarios` |
| 3 | Aba **Match** → ajuste orçamento e tipo de viagem → **Encontrar meu match** | **C** `INSERT` em `buscas`; **R** `SELECT` em `destinos` e `custos_destino` para calcular o % de match |
| 4 | Abra o 1º destino e toque no **♥** | **C** `INSERT` em `favoritos` (tocar de novo = **D**) |
| 5 | **Planejar esta viagem** → escolha as datas → **Salvar viagem** | **C** `INSERT` em `viagens` + cópia do roteiro sugerido para `roteiro_itens` (em uma transação) |
| 6 | Na tela da viagem: **+ Atividade** → preencha → **Salvar** | **C** `INSERT` em `roteiro_itens` |
| 7 | Marque uma atividade como feita (☑) | **U** `UPDATE roteiro_itens SET concluido = 1` |
| 8 | Toque na 🗑 de uma atividade → **Excluir** | **D** `DELETE` em `roteiro_itens` |
| 9 | Toque no ✏ (editar viagem) → mude o status para **Confirmada** e o número de pessoas → **Salvar alterações** | **U** `UPDATE viagens` (o custo é recalculado) |
| 10 | Aba **Viagens** → veja a lista atualizada | **R** `SELECT` com `JOIN` em `destinos` |
| 11 | Feche o app e abra de novo (seção 4.1) | Continua logado e com tudo salvo → **persistência** |
| 12 | Aba **Viagens** → ⋮ → **Excluir** a viagem | **D** `DELETE` em `viagens`; os itens do roteiro somem juntos (`ON DELETE CASCADE`) |
| 13 | Home → ícone de **perfil** → edite o nome → **Salvar** | **U** `UPDATE` em `usuarios` e `usuario_estilos` |
| 14 | (Opcional, no final) **Excluir minha conta** | **D** `DELETE` em `usuarios` → apaga em cascata viagens, roteiros, buscas e favoritos |

---

## 4. Provar que os dados estão gravados

Use **pelo menos uma** das três provas. A combinação **4.1 + 4.2** é a mais simples e convincente.

### 4.1. Fechar e reabrir o app

1. No emulador, deslize de baixo para cima e **segure** no meio da tela (ou clique no botão **▢** da barra lateral do emulador).
2. Arraste o cartão do TripWise **para cima** para fechar.
3. Abra de novo pelo ícone **TripWise**.

✅ O app vai **direto para a Home**, logado (sessão no SharedPreferences), com as viagens salvas (SQLite).

> No PowerShell 1 vai aparecer `Lost connection to device`. É normal, porque o app foi fechado.

> Detalhe para comentar: a mensagem `Banco tripwise.db criado (versão 1)` aparece no log **só na primeira vez**. Ao reabrir ela não aparece, porque o banco já existe e foi apenas aberto.

### 4.2. Mostrar os arquivos e as tabelas pelo terminal

No **PowerShell 2** (com o emulador ligado):

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
```

**Arquivos gravados no celular:**

```powershell
& $adb shell run-as br.pucminas.tripwise ls -la databases shared_prefs
```

Mostra `databases/tripwise.db` (o banco SQLite) e `shared_prefs/FlutterSharedPreferences.xml` (a sessão).

**Conteúdo da tabela de viagens:**

```powershell
& $adb shell "run-as br.pucminas.tripwise sqlite3 databases/tripwise.db 'SELECT id, destino_id, data_ida, pessoas, status FROM viagens;'"
```

Dica de impacto: **edite uma viagem no app** e rode o comando de novo. A linha muda na hora.

**Outras consultas úteis** (troque o SQL entre aspas simples):

```powershell
& $adb shell "run-as br.pucminas.tripwise sqlite3 databases/tripwise.db 'SELECT id, nome, email FROM usuarios;'"
& $adb shell "run-as br.pucminas.tripwise sqlite3 databases/tripwise.db 'SELECT viagem_id, dia, titulo, concluido FROM roteiro_itens;'"
& $adb shell "run-as br.pucminas.tripwise sqlite3 databases/tripwise.db '.tables'"
```

**Usuário logado (SharedPreferences):**

```powershell
& $adb shell run-as br.pucminas.tripwise cat shared_prefs/FlutterSharedPreferences.xml
```

Mostra algo como `<int name="flutter.usuario_id" value="1" />`.

### 4.3. Database Inspector do Android Studio (visual)

1. Com o app aberto **pelo `flutter run`**, no Android Studio aperte **Ctrl + Shift + A**, digite `App Inspection` e dê Enter.
2. Clique em **No Process Selected ⌄** → escolha o emulador → **br.pucminas.tripwise**.
3. Aba **Database Inspector** → expanda `tripwise.db` → dê dois cliques em `viagens`.
4. Dá para rodar SQL na hora: botão **Open New Query Tab** → `SELECT * FROM viagens;`.

> Se a lista de processos aparecer **opaca**, o app não está rodando pelo `flutter run`. Rode-o de novo e reabra o App Inspection. Se mesmo assim não funcionar, use a prova 4.2.

---

## 5. O que falar sobre o banco de dados

Frases curtas para explicar durante a demonstração:

- "Usamos **SQLite** com o pacote **sqflite**, o mesmo da aula de Persistência parte 3. O banco é um arquivo `tripwise.db` **dentro do celular**."
- "Temos **10 tabelas**. As principais são `usuarios`, `viagens` e `roteiro_itens`, ligadas por **chaves estrangeiras**."
- "Ao excluir uma viagem, os itens do roteiro somem junto por causa do **ON DELETE CASCADE**."
- "A senha **não fica em texto puro**: salvamos o **hash SHA-256**."
- "A **sessão** (quem está logado) fica no **SharedPreferences**, visto na aula de Persistência parte 1."
- "O acesso ao banco fica em **repositórios** (`lib/data/`), um para cada tabela, como o `SQLHelper` do exemplo da aula."
- "Temos **testes automáticos** que rodam o CRUD inteiro em um banco em memória (`flutter test`)."

O projeto completo do banco (diagrama, dicionário de dados e SQL) está no PDF **`docs/sprint3-armazenamento-e-persistencia.pdf`** e em **[BANCO_DE_DADOS.md](BANCO_DE_DADOS.md)**.

---

## 6. Plano B se algo der errado

| Problema na hora | Solução rápida |
|---|---|
| Emulador muito lento ou travado | Feche o emulador e ligue de novo pelo Virtual Device Manager. |
| `flutter run` demorando demais | Abra o app pelo **ícone** no emulador, pois ele já está instalado. |
| App com dados "bagunçados" de testes | Zere com `adb shell pm clear br.pucminas.tripwise` (seção 1) e recomece pelo cadastro. |
| Sem emulador funcionando | Rode no navegador: `flutter run -d chrome`. O CRUD funciona igual. |
| Nada funciona | Mostre o **PDF da Sprint 3**, que tem prints de todas as operações CRUD e a saída dos testes. |
