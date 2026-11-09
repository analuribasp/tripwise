# Manual de instalação e configuração

Este guia leva você **do zero até o TripWise rodando** no seu computador, no navegador e em um celular Android (emulado ou de verdade). Não é preciso saber nada de Flutter: é só seguir os passos na ordem.

> Feito para **Windows 10/11**. Os comandos vão no **PowerShell**: aperte a tecla Windows, digite `PowerShell` e abra.
> Quando aparecer um bloco de código, copie **uma linha por vez**, cole no PowerShell e aperte **Enter**.

**Tempo estimado:** 40 a 60 minutos na primeira vez (quase tudo é download).

---

## Sumário

1. [O que vamos instalar](#1-o-que-vamos-instalar)
2. [Instalar o Git](#2-instalar-o-git)
3. [Instalar o Flutter](#3-instalar-o-flutter)
4. [Baixar o projeto TripWise](#4-baixar-o-projeto-tripwise)
5. [Rodar no navegador (o jeito mais rápido)](#5-rodar-no-navegador-o-jeito-mais-rápido)
6. [Instalar o Android Studio e criar o celular virtual](#6-instalar-o-android-studio-e-criar-o-celular-virtual)
7. [Rodar no celular virtual](#7-rodar-no-celular-virtual)
8. [Rodar no seu celular de verdade (opcional)](#8-rodar-no-seu-celular-de-verdade-opcional)
9. [Rodar os testes automáticos](#9-rodar-os-testes-automáticos)
10. [Deu erro? Problemas comuns](#10-deu-erro-problemas-comuns)

---

## 1. O que vamos instalar

| Programa | Para que serve |
|---|---|
| **Git** | Baixar o código do GitHub e enviar alterações |
| **Flutter** | O "kit" que transforma o código em app (Android e web) |
| **Android Studio** | Traz o Android SDK e o **emulador** (um celular Android dentro do PC) |
| **Google Chrome** | Rodar a versão web do app (você provavelmente já tem) |

---

## 2. Instalar o Git

Confira se já existe:

```powershell
git --version
```

- Apareceu algo como `git version 2.x` → **já está instalado**, pule para o passo 3.
- Deu erro → instale:

```powershell
winget install --id Git.Git -e --source winget
```

Depois **feche e abra o PowerShell de novo**.

---

## 3. Instalar o Flutter

**3.1. Baixar o Flutter** (canal estável) para a pasta `C:\Users\SEU_USUARIO\dev\flutter`:

```powershell
git clone -b stable --depth 1 https://github.com/flutter/flutter.git $env:USERPROFILE\dev\flutter
```

**3.2. Colocar o Flutter no PATH** (assim o Windows encontra o comando `flutter`):

```powershell
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";$env:USERPROFILE\dev\flutter\bin", "User")
$env:Path += ";$env:USERPROFILE\dev\flutter\bin"
```

**3.3. Configurar e baixar os componentes** (a primeira vez demora alguns minutos e **parece travar** em "Got dependencies". É normal, espere):

```powershell
flutter config --no-analytics --enable-web
flutter precache --web
flutter doctor
```

No resultado do `flutter doctor`, o importante agora é ✓ em **Flutter** e **Chrome**. O ✗ em "Visual Studio" pode ser ignorado (só serve para apps de Windows). O ✗ em "Android toolchain" resolvemos no passo 6.

---

## 4. Baixar o projeto TripWise

Escolha uma pasta (exemplo: Documentos) e baixe o código:

```powershell
cd $env:USERPROFILE\Documents
git clone https://github.com/tbahiasantos/tripwise.git
cd tripwise
flutter pub get
```

> `flutter pub get` baixa as bibliotecas que o app usa (SQLite, SharedPreferences etc.).

---

## 5. Rodar no navegador (o jeito mais rápido)

Sempre que quiser abrir o app no navegador:

```powershell
flutter run -d chrome
```

O Chrome abre com o TripWise. Para fechar, volte ao PowerShell e aperte **`q`**.

> Os arquivos do SQLite para o navegador (`web/sqlite3.wasm` e `web/sqflite_sw.js`) já vêm no repositório. Se um dia o app abrir em branco no navegador, rode `dart run sqflite_common_ffi_web:setup` para baixá-los de novo.
>
> No navegador, os dados ficam salvos no próprio Chrome (IndexedDB). Para a demonstração em aula, use o **celular virtual** (passos 6 e 7).

---

## 6. Instalar o Android Studio e criar o celular virtual

**6.1. Instalar:**

```powershell
winget install --id Google.AndroidStudio -e
```

**6.2. Primeira abertura:** abra o **Android Studio** pelo menu Iniciar. No assistente, escolha **Standard** e vá clicando em **Next** até **Finish**. Ele baixa o Android SDK e o emulador (pode demorar).

**6.3. Ferramentas de linha de comando:** na tela inicial do Android Studio, clique em **More Actions → SDK Manager** → aba **SDK Tools** → marque **Android SDK Command-line Tools (latest)** → **Apply** → **OK**.

**6.4. Criar o celular virtual:** na tela inicial, **More Actions → Virtual Device Manager**.

- Se já aparecer um aparelho na lista (ex.: *Medium Phone API 37*), pode usar esse.
- Se não, clique em **+** → escolha **Pixel 7** (ou outro) → **Next** → selecione a imagem recomendada → **Finish**.

**6.5. Ligar o celular virtual:** na lista do Virtual Device Manager, clique no **▶** ao lado do aparelho. Espere aparecer a tela inicial do Android (1 a 3 minutos na primeira vez).

**6.6. Conferir** no PowerShell:

```powershell
flutter doctor
flutter devices
```

- Em `flutter doctor`: **Android toolchain** com ✓.
- Em `flutter devices`: uma linha com **emulator-5554** (o nome do seu emulador).

> Se aparecer `flutter doctor --android-licenses`: nas versões novas do Android essa etapa não é mais necessária ("The --licenses option is no longer needed"). Pode seguir.

---

## 7. Rodar no celular virtual

Com o emulador **ligado**, dentro da pasta do projeto:

```powershell
cd $env:USERPROFILE\Documents\tripwise
flutter run -d emulator-5554
```

- A **primeira vez demora 5 a 10 minutos** (baixa o Gradle e compila). As próximas levam menos de 1 minuto.
- Quando aparecer `Flutter run key commands`, o app está aberto no emulador.
- **Deixe o PowerShell aberto** enquanto usa o app. Para fechar tudo, aperte **`q`** no PowerShell.

> O app fica **instalado** no emulador. Depois da primeira vez, você também pode abri-lo pelo ícone **TripWise** na lista de apps do celular virtual, sem PowerShell.

---

## 8. Rodar no seu celular de verdade (opcional)

1. No celular Android: **Configurações → Sobre o telefone** → toque **7 vezes** em **Número da versão**. Aparece "Você agora é um desenvolvedor".
2. **Configurações → Sistema → Opções do desenvolvedor** → ative **Depuração USB**.
3. Conecte o celular no PC pelo cabo USB e aceite o aviso **"Permitir depuração USB?"** no celular.
4. No PowerShell:

```powershell
flutter devices
```

5. Copie o identificador do seu celular (2ª coluna) e rode:

```powershell
flutter run -d IDENTIFICADOR_DO_CELULAR
```

---

## 9. Rodar os testes automáticos

```powershell
flutter test
```

Resultado esperado: `All tests passed!`. São 5 testes, 4 deles do banco de dados: criação das tabelas, CRUD de usuário, cálculo do Travel Match e CRUD de viagem + roteiro com exclusão em cascata.

---

## 10. Deu erro? Problemas comuns

| Mensagem ou situação | O que fazer |
|---|---|
| `flutter : O termo 'flutter' não é reconhecido` | O PATH não foi aplicado. Feche e abra o PowerShell. Se continuar, refaça o passo 3.2. |
| Fica parado em **"Got dependencies"** na primeira vez | É normal: o Flutter está compilando a própria ferramenta. Espere de 2 a 5 minutos. |
| `Android sdkmanager did not install NDK 28.x` | Rode `flutter run -d emulator-5554` **de novo**: na segunda tentativa ele costuma instalar sozinho. Se insistir: Android Studio → **SDK Manager → SDK Tools** → marque **Show Package Details** → em **NDK (Side by side)** marque a versão pedida no erro → **Apply**. |
| `No supported devices connected` / emulador não aparece | O emulador está desligado. Ligue pelo **Virtual Device Manager (▶)** e espere a tela inicial. |
| `Lost connection to device` | O app foi fechado no emulador. É normal. Rode `flutter run -d emulator-5554` de novo, ou abra pelo ícone do app. |
| Aviso amarelo `Expected to find fonts for ... CupertinoIcons` | Pode ignorar, não afeta o app. |
| `Visual Studio not installed` no `flutter doctor` | Pode ignorar, só é necessário para apps de Windows. |
| App no navegador abre em branco | Rode `dart run sqflite_common_ffi_web:setup` e tente de novo. |
| Quero **apagar todos os dados** do app no emulador | `& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" shell pm clear br.pucminas.tripwise` |

---

Próximo passo: veja o **[Manual de demonstração](DEMONSTRACAO.md)** para apresentar o app em aula.
