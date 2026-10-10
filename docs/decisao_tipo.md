# Decisão sobre o Tipo de Processo

Instalar database/008_decisao_tipo.sql em sei_gd antes de atualizar backend e frontend. O script não foi executado pelo Codex.

A decisão é compartilhada pelo órgão e salva no mesmo rascunho, revisão e evento de auditoria da manifestação. MANTER libera a avaliação dos Assuntos. DESCONTINUAR é uma proposta para a SETIC, exige justificativa de até 2000 caracteres e dispensa os vínculos. Não altera a referência nem o SEI.

Os vínculos já salvos permanecem no banco ao sugerir descontinuação, mas são excluídos do resumo efetivo e da submissão. Ao voltar para MANTER reaparecem. Alterações ainda não salvas permanecem apenas na tela; salvar descontinuação não grava alterações nos vínculos.

Os quatro cards contam apenas vínculos originais: mantidos, removidos, pendentes e concluídos (mantidos + removidos). Inclusões propostas continuam em bloco separado. Cards refletem o preenchimento atual; a confirmação permanece no botão Salvar rascunho.

A finalização exige visualização e decisão de todos os Tipos. Os mantidos precisam de todos os vínculos originais decididos. Descontinuações precisam de justificativa. Banco e backend validam essas regras, preservando bloqueio de submissões finalizadas e controle de concorrência.

Submissões antigas são preservadas como manutenção pelo fluxo legado. Rascunhos anteriores precisam de decisão explícita. A migração pode ser reaplicada sem sobrescrever decisões existentes.

Homologação: Tipo sem decisão (inclusive sem vínculos), manutenção parcial/completa, descontinuação sem/com justificativa, troca de decisão com rascunho salvo, recarga, resumo sem vínculos desconsiderados, totais da Home, conflito entre usuários e tentativa de alterar órgão finalizado.
