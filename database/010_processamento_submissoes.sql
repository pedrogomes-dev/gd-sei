-- Incremental: executar no banco GD-SEI após 008. Não altera referências ou o SEI.
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID('dbo.processamento_submissao', 'U') IS NULL
BEGIN
  -- Ausência de registro = PENDENTE; presença = ATUALIZADO. Uma linha por atribuição.
  CREATE TABLE dbo.processamento_submissao (
    id_atribuicao int NOT NULL,
    id_usuario_atualizacao int NOT NULL,
    data_atualizacao datetime2 NOT NULL
      CONSTRAINT DF_processamento_submissao_data DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_processamento_submissao PRIMARY KEY (id_atribuicao),
    CONSTRAINT FK_processamento_submissao_atribuicao FOREIGN KEY (id_atribuicao)
      REFERENCES dbo.consulta_orgao_tipo(id_atribuicao),
    CONSTRAINT FK_processamento_submissao_usuario FOREIGN KEY (id_usuario_atualizacao)
      REFERENCES dbo.usuario(id_usuario)
  );
END;
COMMIT;
