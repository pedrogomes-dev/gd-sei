# Próximas etapas

## Pendência das propriedades dos Tipos de Processo

O responsável fará uma carga com os nomes correspondentes aos códigos de nível de acesso, hipótese legal e grau de sigilo. Após essa carga, integrar as referências para exibir os nomes nas propriedades. Até lá, manter os códigos/IDs recebidos da base, sem deduzir rótulos. A organização visual desses campos é independente da carga.

Administração implementada: cadastro/edição de usuários, órgãos vinculados, acesso/perfil e trilha administrativa; instalação e homologação em `docs/administracao.md`. A autenticação ainda usa o acesso temporário. Indicadores e trilha de autenticação pertencem à próxima etapa.

Já implementados: base versionada, publicação transacional, usuários/órgãos/atribuições, acesso temporário, listagem/detalhe, visualização, pesquisa de Assuntos ativos, manifestação compartilhada, rascunhos, resumo, submissão por órgão e auditoria.

Pendente: autenticação real pelo servidor de e-mail; token_acesso de uso único separado de sessao persistente; limite de solicitações/tentativas e expiração configurável. Manter autorização por órgão no backend. Cookie HttpOnly/Secure/SameSite e proteção de origem permanecem.

Antes de habilitar produção: desativar DEV_AUTH_ENABLED, configurar HTTPS, SMTP e usuário SQL com permissões mínimas. Validar compilação e testes em homologação. A conexão ODBC foi validada pelo responsável; novas operações de manifestação ainda precisam de validação integrada.

Fora do MVP: importação por interface, cadastros administrativos, associação órgão/Tipo por interface, exportação, reabertura, decisão SETIC, integração SEI, dashboards, mobile ou múltiplos níveis de aprovação.


