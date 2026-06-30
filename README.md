# DFD Manager

Aplicativo mobile desenvolvido em **Flutter** para auxiliar no controle e na consulta de **Documentos de Formalização de Demanda (DFDs)**, utilizado como ferramenta de apoio pessoal a um sistema institucional que não oferece busca eficiente por conteúdo dos registros.

---

## 📌 Tema do Projeto

O sistema oficial utilizado para o registro de DFDs (Documentos de Formalização de Demanda) no ambiente de trabalho permite apenas a consulta de registros por **código** ou **data**, não havendo a possibilidade de busca por **justificativa** ou **objeto** do documento.

Isso torna extremamente difícil localizar uma DFD específica quando o usuário não possui o código exato em mãos, especialmente em cenários onde é necessário **alterar ou revisar** documentos antigos.

O **DFD Manager** resolve esse problema permitindo que o usuário registre, de forma paralela e local, as informações essenciais de cada DFD (código, datas e justificativa), possibilitando buscas rápidas pelo conteúdo textual da justificativa ou do código, e otimizando o tempo gasto para localizar o documento no sistema oficial.

---

## 💡 Motivação

A motivação para este projeto surgiu de um problema **real e recorrente no cotidiano de trabalho** do desenvolvedor, que atua registrando DFDs em um sistema institucional limitado.

Principais motivadores:

- **Resolver um problema observado no cotidiano de trabalho**, relacionado à dificuldade de consulta de documentos antigos;
- **Facilitar uma atividade específica**, reduzindo o tempo gasto procurando manualmente DFDs no sistema oficial;
- **Servir como índice de apoio** pessoal, complementando — e não substituindo — o sistema institucional já existente.

O aplicativo não pretende substituir o sistema oficial, mas sim atuar como uma **camada de busca e indexação local**, agilizando o trabalho diário.

---

## 🎯 Escopo do Projeto

### Funcionalidades incluídas no escopo atual

- Cadastro de uma nova DFD com os seguintes dados:
  - Código da DFD;
  - Data da DFD (data oficial do documento);
  - Data de criação do registro no aplicativo;
  - Justificativa da demanda.
- Listagem de todas as DFDs cadastradas;
- Busca textual por **código** ou **justificativa**;
- Visualização detalhada de uma DFD específica;
- Edição das informações de uma DFD já cadastrada;
- Exclusão de registros, com confirmação prévia;
- Compartilhamento das informações da DFD via aplicativos externos (WhatsApp, e-mail, etc.) utilizando o recurso nativo de compartilhamento do dispositivo;
- Persistência local dos dados utilizando **SQLite**, garantindo o funcionamento do app mesmo sem conexão à internet.

### Funcionalidades fora do escopo atual

- Integração direta com o sistema institucional real (via API ou banco de dados remoto) — **prevista como evolução futura**, mas não implementada nesta etapa;
- Cadastro de itens/produtos vinculados à DFD;
- Autenticação de usuários (login/senha), visto que o aplicativo é de uso individual;
- Upload de fotos ou anexos referentes à DFD (avaliado, mas não incluído na versão atual do projeto);
- Geração de relatórios em PDF.

---

## 🔄 Fluxo de Utilização

O fluxo de uso do aplicativo segue a lógica abaixo:

1. Usuário registra a DFD no sistema institucional real;
2. Usuário abre o aplicativo DFD Manager;
3. Usuário cadastra as informações da DFD (código, data da DFD, data de criação e justificativa);
4. O aplicativo salva os dados localmente via SQLite;
5. Quando necessário, o usuário pesquisa por código ou justificativa na tela principal;
6. O aplicativo retorna a lista de DFDs correspondentes à busca;
7. Usuário visualiza os detalhes da DFD e obtém o código correto;
8. Usuário utiliza o código encontrado para localizar o documento completo no sistema institucional real;
9. Caso necessário, o usuário pode editar, excluir ou compartilhar a DFD registrada no aplicativo.


---

## ✅ Requisitos Funcionais

| Código | Descrição |
|--------|-----------|
| RF01 | O sistema deve permitir o cadastro de uma nova DFD com código, datas e justificativa. |
| RF02 | O sistema deve permitir a listagem de todas as DFDs cadastradas. |
| RF03 | O sistema deve permitir a busca de DFDs por código. |
| RF04 | O sistema deve permitir a busca de DFDs por justificativa. |
| RF05 | O sistema deve permitir a visualização detalhada de uma DFD específica. |
| RF06 | O sistema deve permitir a edição das informações de uma DFD já cadastrada. |
| RF07 | O sistema deve permitir a exclusão de uma DFD, mediante confirmação do usuário. |
| RF08 | O sistema deve permitir o compartilhamento das informações de uma DFD através de aplicativos externos do dispositivo. |
| RF09 | O sistema deve persistir os dados localmente, garantindo o funcionamento do aplicativo sem conexão à internet. |
| RF10 | O sistema deve validar os campos obrigatórios do formulário antes de salvar uma DFD. |

---

## 🛠️ Tecnologias Utilizadas

- **Flutter** — Framework para desenvolvimento da interface e lógica do aplicativo;
- **Dart** — Linguagem de programação utilizada no desenvolvimento;
- **SQLite** (pacote `sqflite`) — Persistência de dados local;
- **path** — Manipulação de caminhos de arquivos compatível com Android e iOS;
- **intl** — Formatação de datas;
- **flutter_localizations** — Internacionalização de componentes nativos (DatePicker em português);
- **share_plus** — Integração com o recurso nativo de compartilhamento do dispositivo (Permissões do dispositivo / Recurso de hardware).

---

## 📂 Estrutura do Projeto

```
lib/
├── main.dart
├── models/
│   └── dfd.dart
├── database/
│   └── database_helper.dart
└── screens/
    ├── home_screen.dart
    ├── form_screen.dart
    └── detail_screen.dart
```

---

## ▶️ Como Executar o Projeto

```bash
# Clonar o repositório
git clone <link-do-repositorio>

# Acessar a pasta do projeto
cd dfd_manager

# Instalar as dependências
flutter pub get

# Executar o aplicativo
flutter run
```

---

## 👤 Autor

Projeto desenvolvido por **Julio Cesar Vieira Barros** como atividade da disciplina de Programação para Dispositivos Móveis.
