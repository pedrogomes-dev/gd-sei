## Documentação

Manter o `AGENTS.md` como referência de desenvolvimento, preservando as decisões de arquitetura.

Revisar `docs/pendencias.md` com base na situação efetiva do código.

Classificar as pendências em:

1. Defeitos confirmados.
2. Testes/homologações pendentes.
3. Ajustes de documentação e instalação.
4. Funcionalidades futuras dependentes de decisão.

Não misturar evoluções futuras com defeitos do MVP.

## Diretrizes para execução

- Priorizar simplicidade, segurança, desempenho e manutenção.
- Reutilizar componentes existentes.
- Reduzir duplicação e complexidade ciclomática.
- Evitar ternários aninhados e métodos excessivamente extensos.
- Não modificar regras funcionais sem necessidade comprovada.
- Não criar novas dependências sem justificativa.
- Não fazer alterações amplas sem relação com o problema.
- Não inventar campos, tabelas, endpoints ou requisitos.
- Não realizar ações destrutivas no banco.
- Não confundir revisão estática com teste executado.

Implementar diretamente correções pequenas, confirmadas e de baixo risco, desde que não dependam de decisões funcionais ou migrações.

Para mudanças relevantes, criar branches específicas e PRs separados, sempre a partir da `main` atualizada.

Não realizar merge automaticamente.
