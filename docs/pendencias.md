# Pendências — migração Django (17/11/2026)

Referências: AGENTS.md e [migracao_django.md](migracao_django.md).
Implementação nesta branch ainda não equivale a homologação/implantação.

## 1. Defeitos confirmados

Nenhum defeito adicional confirmado pelos checks executados da migração.
Isso não afirma ausência de defeitos nos cenários ainda não homologados.

## 2. Testes e homologações pendentes

- ALTO: escrita no SQL Server de testes, procedures, revisões e concorrência;
  testes automatizados de escrita usam banco simulado.
- ALTO: autorização com sessões reais em todos os fluxos, SMTP, revogação e logout.
- ALTO: duas sessões administrativas e carga de atribuições simultânea.
- MÉDIO: navegador desktop/estreito, interação JavaScript, modais, seleção em lote
  entre páginas/filtros e preservação de edição após erro.
- MÉDIO: comparação funcional completa com a release Dart/Flutter anterior.

Conferência integrada de leitura no banco existente passou para as nove telas
descritas na documentação da migração. Não executou gravações nem validou SMTP.

## 3. Documentação e instalação

- ALTO: homologar instalação SQL completa em banco novo e esquema até 011.
- ALTO: construir a imagem Django e conferir implantação, HTTPS/proxy e permissões
  do diretório de sessões no ambiente corporativo. Não houve deploy/OpenShift.
- MÉDIO: homologar configuração SQL/SMTP da raiz e checklist de transição/rollback.
- MÉDIO: revisar consumidores externos/favoritos das rotas antigas antes de
  substituir a release. API Dart não permanece ativa.
- BAIXO: documentos históricos marcados com Dart/Flutter servem de referência
  funcional, não como comandos de execução da versão Django.

## 4. Funcionalidades futuras dependentes de decisão

- Integração/atualização automática no SEI e consolidação de divergências.
- Reabertura ou edição de pareceres administrativos já registrados.
- Gestão de rodadas/cargas pela interface e Tipos de Documento × Assuntos.
- Códigos/sessões distribuídos e múltiplas réplicas/processos de autenticação.
- Exportações e relatórios adicionais.

Não confundir essas evoluções com defeitos do MVP nem implementá-las nesta migração.
