-- Incremental após 008. Preserva 010 e quaisquer marcações antigas, sem inferir aceite.
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID('dbo.avaliacao_setic_tipo', 'U') IS NULL
  CREATE TABLE dbo.avaliacao_setic_tipo (
    id_atribuicao int NOT NULL PRIMARY KEY REFERENCES dbo.manifestacao_tipo(id_atribuicao),
    parecer varchar(8) NOT NULL CHECK (parecer IN ('ACEITO','RECUSADO')),
    id_usuario_avaliacao int NOT NULL REFERENCES dbo.usuario(id_usuario),
    data_avaliacao datetime2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
IF OBJECT_ID('dbo.avaliacao_setic_assunto', 'U') IS NULL
  CREATE TABLE dbo.avaliacao_setic_assunto (
    id_atribuicao int NOT NULL,
    id_assunto int NOT NULL,
    parecer varchar(8) NOT NULL CHECK (parecer IN ('ACEITO','RECUSADO')),
    id_usuario_avaliacao int NOT NULL REFERENCES dbo.usuario(id_usuario),
    data_avaliacao datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
    PRIMARY KEY (id_atribuicao, id_assunto),
    FOREIGN KEY (id_atribuicao, id_assunto)
      REFERENCES dbo.manifestacao_vinculo(id_atribuicao, id_assunto)
  );
COMMIT;
