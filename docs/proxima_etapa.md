# Próximas etapas

## Pendência das propriedades dos Tipos de Processo

Hipótese legal integrada pela tabela `dbo.hipotese_legal`, carregada pelo responsável: catálogo e avaliação exibem nome, base legal, descrição e indicação de inatividade. Referências ausentes preservam o ID. Nível de acesso: 1 = Restrito; 2 = Sigiloso, conforme confirmação do responsável. Outros códigos permanecem explícitos. Grau de sigilo continua pendente de referência.

A tabela de hipótese legal é uma referência atual, sem versão própria; sua atualização altera os rótulos exibidos também em rodadas anteriores, preservando o ID registrado no Tipo de Processo.

Administração implementada: cadastro/edição de usuários, órgãos vinculados, acesso/perfil e trilha administrativa; instalação e homologação em `docs/administracao.md`. A autenticação ainda usa o acesso temporário. Indicadores e trilha de autenticação pertencem à próxima etapa.

Já implementados: base versionada, publicação transacional, usuários/órgãos/atribuições, acesso temporário, listagem/detalhe, visualização, pesquisa de Assuntos ativos, manifestação compartilhada, rascunhos, resumo, submissão por órgão e auditoria.

Pendente: autenticação real pelo servidor de e-mail; token_acesso de uso único separado de sessao persistente; limite de solicitações/tentativas e expiração configurável. Manter autorização por órgão no backend. Cookie HttpOnly/Secure/SameSite e proteção de origem permanecem.

Antes de habilitar produção: desativar DEV_AUTH_ENABLED, configurar HTTPS, SMTP e usuário SQL com permissões mínimas. Validar compilação e testes em homologação. A conexão ODBC foi validada pelo responsável; novas operações de manifestação ainda precisam de validação integrada.

Fora do MVP: importação por interface, cadastros administrativos, associação órgão/Tipo por interface, exportação, reabertura, decisão SETIC, integração SEI, dashboards, mobile ou múltiplos níveis de aprovação.


