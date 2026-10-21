# Instalação do banco GD-SEI

SQL Server 2016 SP1 ou posterior, compatibilidade >=130. Execute os scripts
no banco GD-SEI selecionado, com uma ferramenta que interprete `GO` e pare
no primeiro erro. O script 006 contém `USE sei_gd`: confira o destino antes
de executá-lo. Não execute esta sequência no SEI oficial.

## Banco novo

1. Execute `database/001_base.sql`.
2. Execute `database/009_referencias_complementares.sql`, antes de 002/006.
   O número 009 identifica um complemento posterior; a ordem não é numérica.
3. Execute `database/002_publicacao.sql`.
4. Carregue da fonte SEI autorizada `ref_assunto`, `ref_tipo_procedimento` e
   `ref_rel_tipo_procedimento_assunto`, nessa ordem. Informe o pai por ID em
   `ref_assunto.id_assunto_pai`; raízes usam NULL. Nunca deduza pais pelos códigos.
   Carregue também `hipotese_legal` e `tipo_procedimento_restricao` da fonte
   autorizada. Não há dados de exemplo nem carga automática dessas referências.
5. Publique com `sp_publicar_versao_sei`, informando operador e origem reais.
6. Execute `004_consultas.sql` e `005_manifestacoes.sql`.
7. Cadastre os órgãos com os IDs preservados do SEI. `orgao.id_orgao` é IDENTITY:
   a importação administrativa deve preservar explicitamente os IDs, inclusive 0.
   Cadastre os vínculos `usuario_orgao` e a rodada `consulta` com sua versão.
8. Execute `006_completar_atribuicoes.sql` para instalar a procedure. Confira sua
   prévia para a rodada correta; aplique as atribuições somente após revisão.
9. Execute `007_administracao.sql` e `008_decisao_tipo.sql`. O 007 promove o
   usuário inicial criado pelo 004 e audita a operação; revise esse acesso antes
   de disponibilizar a aplicação.

`003_validacao.sql` e `database/tests/` são roteiros de homologação, não etapas
de instalação. Execute testes com escrita somente em banco descartável.

## Base existente

Não reaplique 001, 004, 005 ou 007. Execute somente 009 e reaplique 002 para
atualizar a publicação. O 009 cria apenas os objetos ausentes e não modifica
dados, pais existentes ou referências já instaladas. Não corrige automaticamente
objetos existentes com tipos divergentes.

A referência atual foi conferida pelo responsável e `id_assunto_pai` está correto. Para novas instalações, os pais devem continuar sendo carregados explicitamente a partir da fonte autorizada; não inferir hierarquia pelo código. UPDATE/DELETE das `ref_*` permanecem bloqueados e não se deve desabilitar triggers para contornar essa regra.

A publicação atualizada copia o pai junto com cada Assunto para a mesma versão.
Rejeita pai ausente ou igual ao próprio Assunto e impede a perda silenciosa de
um pai existente na última versão quando a referência ainda está sem esse pai.
Não usa `sin_ultima` para relacionar snapshots de versões diferentes.

`hipotese_legal` e `tipo_procedimento_restricao` reproduzem colunas, nulabilidade,
collation e chaves primárias observadas no banco existente. São referências
atuais sem versão própria. A procedure 006 valida os Tipos na versão da rodada;
não representa uma distribuição histórica versionada. Não crie FKs dessas
referências para uma versão arbitrária de snapshots.

## Verificação

Execute `dart run bin/check_database.dart` e `dart run bin/check_schema.dart`
a partir de `backend`, com credenciais de leitura configuradas. O segundo
verifica objetos básicos e complementares; não comprova instalação completa,
conteúdo da carga, permissões mínimas ou comportamento das procedures.

Em banco descartável, execute `database/tests/publicacao_hierarquia.sql` após
001, 009 e 002. Ele verifica publicação dos pais em duas versões e preservação
do histórico. Depois homologue a instalação completa, avaliações e submissão.

A instalação completa em banco novo ainda deve ser homologada com escrita em ambiente descartável. Essa pendência não invalida a conferência das referências atuais.
