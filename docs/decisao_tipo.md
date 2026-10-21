# Decisão sobre o Tipo de Processo

`database/008_decisao_tipo.sql` integra a instalação do banco. O fluxo funcional correspondente já foi homologado no ambiente atual; a instalação completa em banco novo continua pendente de homologação.

A decisão é compartilhada pelo órgão e salva no mesmo rascunho, revisão e evento de auditoria da manifestação. MANTER libera a avaliação dos Assuntos. DESCONTINUAR é uma proposta para a SETIC, exige justificativa de até 2000 caracteres e dispensa os vínculos. Não altera a referência nem o SEI.

Os vínculos já salvos permanecem no banco ao sugerir descontinuação, mas são excluídos do resumo efetivo e da submissão. Ao voltar para MANTER reaparecem. Alterações ainda não salvas permanecem apenas na tela; salvar descontinuação não grava alterações nos vínculos.

Os quatro cards contam apenas vínculos originais: mantidos, removidos, pendentes e concluídos (mantidos + removidos). Inclusões propostas continuam em bloco separado. Cards refletem o preenchimento atual; a confirmação permanece no botão Salvar rascunho.

A finalização exige visualização e decisão de todos os Tipos. Os mantidos precisam de todos os vínculos originais decididos. Descontinuações precisam de justificativa. Banco e backend validam essas regras, preservando bloqueio de submissões finalizadas e controle de concorrência.

Submissões antigas são preservadas como manutenção pelo fluxo legado. Rascunhos anteriores precisam de decisão explícita. A migração pode ser reaplicada sem sobrescrever decisões existentes.

A homologação funcional incluiu decisão pendente, manutenção, proposta de descontinuação, justificativas, recarga, resumo, submissão, órgão 0 e bloqueio após finalização.
