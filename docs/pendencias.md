# Pendências consolidadas — 10/10/2026

Revisão da main no commit a81e23874bc7b0a1aac71202451c2d475eb605ce, considerando o histórico fornecido e a documentação. Nenhum PR estava aberto no início desta revisão; mudanças dos PRs 27, 28 e 29 já constam na main. A revisão foi estática: não substitui compilação, teste no navegador ou execução no SQL Server. A instalação efetiva do banco e a configuração do servidor não foram inspecionadas.

## Prioridades para concluir o primeiro release

| ID | Prioridade | Pendência | Evidência e conclusão esperada |
| --- | --- | --- | --- |
| T01 | Alta | Homologar autorização com usuário comum | Alterar órgão/consulta/atribuição diretamente na URL e pela API. Usuário comum sem vínculo deve ser impedido de consultar resumo, detalhes, registrar visualização, salvar e submeter. Administrador sem vínculo pode consultar resumo, mas não editar/submeter. Conferir também rotas administrativas e revogação após retirar vínculo/perfil. Regras presentes no código; teste solicitado pelo responsável ainda pendente. |
| T02 | Alta | Homologar órgão 0 | Código da rota aceita zero apenas para órgão. Conferir Home → resumo, submissão autorizada e acesso negado sem vínculo. Atualizar e reiniciar backend antes do teste; sem migração específica. |
| T03 | Alta | Homologar decisão do Tipo e concorrência | Confirmar aplicação de 008; testar manter, descontinuar com/sem justificativa, Tipo sem vínculos, rascunho preservado ao trocar decisão, resumo efetivo e submissão. Testar duas abas/usuários e bloqueio depois de finalizar. Scripts SQL existem, mas execução integral não está confirmada no histórico. |
| T04 | Alta | Reproduzir instalação completa | Backend faz JOIN com dbo.hipotese_legal, mas database/ não contém criação/carga dessa tabela. A carga foi feita manualmente no banco do responsável. Versionar o script correspondente. 006 também depende da tabela tipo_procedimento_restricao já existente; documentar seu provisionamento. Corrigir a sequência de instalação para incluir 007 e 008 e validar em banco vazio. |
| T05 | Alta | Preparar produção | Desativar DEV_AUTH_ENABLED; configurar HTTPS, origem exata, cookie Secure e SMTP. Definir permissões mínimas do usuário SQL, sem privilégios de carga/publicação/alteração de referência. Documentar implantação, backup/restauração e retorno à versão anterior. Nenhuma implantação produtiva foi verificada. |
| T06 | Alta | Consolidar resultados para SETIC | Já existem acompanhamento por órgão e resumo, inclusive proposta de descontinuação. Falta consulta/exportação consolidada entre órgãos para comparar decisões, justificativas, inclusões e divergências por rodada/versão. Definir o formato com o responsável antes de implementar. |
| T07 | Média | Atualizar documentação histórica | README, proxima_etapa, acesso_temporario, administracao, inicio e interface contradizem funcionalidades atuais. Ver detalhamento abaixo. |
| T08 | Média | Concluir referência de grau de sigilo | Ainda exibido como código, com 0 = Não informado. Hipótese legal já integrada; nível de acesso 1/2 já traduzido. Falta referência confirmada dos demais códigos de sigilo, sem inferir significados. |
| T09 | Média | Homologar ajustes visuais e contagens | Cards exclusivos da Home, filtro por card, contagens de catálogos/administração com mais de 50 resultados, filtro por órgão, pesquisa, descrições longas, escala de texto, datas e rolagem. Validar também Meus Tipos e resumo; a existência dos ajustes no código não comprova ausência de overflow no navegador. |
| T10 | Média | Executar verificações reproduzíveis | dart analyze, flutter analyze, flutter build web; testes de autenticação, check_estados_inicio e scripts SQL de administração/manifestações/publicação em homologação. Não há pipeline de CI no repositório revisado. Automatizar checks básicos quando o ambiente estiver disponível. |

## Autenticação: implementada, com limites a decidir

O histórico informa autenticação por e-mail validada. Não deve constar como funcionalidade faltante. Código de uso único, expiração, limite de tentativas, reenvio, SMTP e revogação administrativa estão implementados. Confirmar as configurações e o comportamento no servidor de produção.

Sessões e códigos ficam em memória; reiniciar o backend exige novo login. O desenho atual pressupõe uma única instância. Persistência e prazos configuráveis são decisões futuras, necessárias se houver requisito de sobreviver a reinício ou executar múltiplas instâncias. Não introduzir essa complexidade no MVP sem necessidade. Confirmar comportamento dos limites de solicitações atrás do proxy e porta/certificado SMTP na implantação.

LOGIN/LOGIN_DEV/LOGOUT já são auditados. Um relatório administrativo de último acesso/quantidade de acessos não está implementado; é evolução, não ausência de auditoria.

## Divergências encontradas na documentação

- README e docs/proxima_etapa.md ainda dizem que SMTP e autenticação por e-mail não foram implementados. docs/autenticacao_email.md descreve o funcionamento atual.
- docs/administracao.md ainda trata o login por e-mail e a trilha de autenticação como etapa futura e sugere testar apenas com o bypass. Há login real e eventos de autenticação.
- docs/acesso_temporario.md descreve confirmação manual de visualização. A interface registra visualização ao escolher Manter/Sugerir descontinuação; a decisão é persistida ao salvar.
- docs/inicio.md descreve quatro indicadores sobrepostos, nomes antigos e Tipo sem vínculos concluído apenas por visualização. A regra atual tem cinco estados exclusivos: Aguardando, Visualizados, Analisados, Validando e Submetidos; decisão explícita é necessária.
- docs/interface.md descreve usuário sem nome, catálogo por atribuição e endpoint com atribuicao. Hoje há nome cadastrado e catálogo único por versão publicada. Também afirma que propriedades não inferem unidades, embora os prazos numéricos agora exibam anos conforme orientação do responsável.
- docs/proxima_etapa.md coloca cadastros administrativos e dashboards fora do MVP, apesar da administração de usuários e acompanhamento existentes.
- A documentação das propriedades ainda menciona descrição extensa/inatividade da hipótese legal; a apresentação aprovada agora contém somente nome/base legal.

## Segundo release e evoluções fora do escopo atual

- Tipos de Documento × Assuntos, com seleção de categoria, indicadores e submissão independentes dos Tipos de Processo. Proposta discutida; não implementada.
- Importação por interface, criação/gestão de rodadas e associação órgão × Tipo por interface: operações ainda manuais/SQL. Não constam como requisitos obrigatórios para concluir o MVP.
- Reabertura, decisão final da SETIC e integração de alterações no SEI: sem implementação e fora do fluxo aprovado até aqui.
- Correção/substituição de referências imutáveis e política de rótulos históricos: requer procedimento definido. A hipótese legal é uma referência atual, sem versão própria; atualizações de nomes podem alterar a exibição de rodadas antigas sem mudar o ID armazenado.
- Rever a cópia local de dart_odbc quando houver correção upstream; preservar os patches documentados e testar parâmetros/textos longos no ambiente de destino. Conexão/HY104 e submissão básica já foram validadas no histórico, portanto não são pendências de implementação.

## Critério de encerramento

Registrar data, ambiente, responsável e resultado das homologações. Não marcar testes como concluídos apenas porque o PR foi integrado ou existe roteiro. As prioridades acima são recomendações da revisão; itens dependentes de nova decisão de produto permanecem separados das falhas e testes do release atual.
