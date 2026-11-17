# Executar e depurar no VS Code

Instale as extensões Python e Python Debugger recomendadas. Abra a raiz do
repositório, crie `.venv`, instale `requirements-dev.txt` e configure `.env` na
raiz. Selecione o interpretador `.venv/Scripts/python.exe`.

Em Executar e Depurar, selecione **GD-SEI: Django** e pressione F5. A aplicação
inicia em http://127.0.0.1:8000/. Não é mais necessário iniciar Dart e Flutter
separadamente. A opção `--noreload` evita processos duplicados no depurador.

Se a porta estiver ocupada, encerre a execução anterior ou ajuste a porta em
`.vscode/launch.json`. Nunca encerre processos de terceiros automaticamente.
Credenciais ficam somente no `.env`/ambiente, nunca no launch.json.

Após trocar de branch ou configuração de autenticação, reinicie o servidor.
Personifique um usuário administrador para ver o menu de Administração.
