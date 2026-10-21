# Executar e depurar no VS Code

Abra a pasta raiz `gd-sei` no VS Code e instale as extensões recomendadas Dart
e Flutter. Os SDKs devem estar disponíveis no ambiente do editor e o Chrome
instalado para depurar o frontend web.

Na primeira execução, obtenha as dependências:

```powershell
cd backend
dart pub get
cd ../frontend
flutter pub get
```

Configure `backend/.env` com os dados locais reais de SQL Server/ODBC e SMTP,
conforme a documentação existente. O backend é iniciado com `cwd` em `backend`,
portanto mantém a leitura desse arquivo pelo próprio código da aplicação.
Credenciais não devem ser incluídas em `launch.json` nem versionadas.

Em **Executar e Depurar** (`Ctrl+Shift+D`), selecione:

- **GD-SEI: Backend Dart** — inicia `backend/bin/server.dart` em `127.0.0.1:8080`.
- **GD-SEI: Frontend Flutter Web** — inicia `frontend/lib/main.dart` no Chrome,
  em `http://localhost:3000`, usando a API em `http://localhost:8080`.
- **GD-SEI: Backend + Frontend** — inicia os dois depuradores. Ao parar uma das
  sessões, a opção `stopAll` encerra também a outra.

Use **F5** para depurar com breakpoints ou **Ctrl+F5** para executar sem depuração.
As configurações usam as portas locais já adotadas no projeto. No backend,
HOST, PORT e ALLOWED_ORIGIN são definidos explicitamente para corresponder
ao frontend; as demais configurações continuam vindo do ambiente/`.env`.
Não há ativação automática do acesso temporário de desenvolvimento.

Se já houver processos nas portas 8080 ou 3000, encerre-os no terminal em que
foram iniciados antes de usar a configuração conjunta. O VS Code não aguarda
uma verificação de saúde da API no início conjunto; os dois processos iniciam
em paralelo. Não há migração ou carga de banco automática.

Somente `launch.json` e `extensions.json` são compartilhados da pasta `.vscode`;
demais preferências pessoais continuam ignoradas pelo Git.

Verificação desta alteração: JSON parseado, caminhos de entrada e referências
da configuração conjunta conferidos, e regras de ignore verificadas.
Falta homologar F5/Ctrl+F5 e breakpoints no VS Code; não foi executado teste
interativo de depuração nesta alteração. Nenhum código Dart/Flutter foi alterado.

Referências: [Dart Code](https://dartcode.org/docs/launch-configuration/) e
[VS Code](https://code.visualstudio.com/docs/debugtest/debugging-configuration).
