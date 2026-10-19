-- Instalação nova: após 001 e antes de 002/006.
-- Base existente: executar este complemento e reaplicar 002.
-- Não carrega referências nem altera os pais dos snapshots existentes.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO
BEGIN TRY
 BEGIN TRANSACTION;
 IF OBJECT_ID('dbo.ref_assunto','U') IS NULL OR OBJECT_ID('dbo.assunto','U') IS NULL
  THROW 51300,'Execute 001_base.sql antes deste complemento.',1;

 IF COL_LENGTH('dbo.ref_assunto','id_assunto_pai') IS NULL
  ALTER TABLE dbo.ref_assunto ADD id_assunto_pai int NULL;
 IF COL_LENGTH('dbo.assunto','id_assunto_pai') IS NULL
  ALTER TABLE dbo.assunto ADD id_assunto_pai int NULL;

 -- Definições conferidas no banco existente em 19/10/2026.
 -- São referências atuais, sem versão própria. Não adicionar FKs a snapshots.
 IF OBJECT_ID('dbo.hipotese_legal','U') IS NULL
  CREATE TABLE dbo.hipotese_legal (
   id_hipotese_legal int NOT NULL CONSTRAINT PK_hipotese_legal PRIMARY KEY,
   nome varchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
   base_legal varchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
   descricao varchar(500) COLLATE Latin1_General_CI_AS NULL,
   sta_nivel_acesso char(1) COLLATE Latin1_General_CI_AS NOT NULL,
   sin_ativo char(1) COLLATE Latin1_General_CI_AS NOT NULL
  );
 IF OBJECT_ID('dbo.tipo_procedimento_restricao','U') IS NULL
  CREATE TABLE dbo.tipo_procedimento_restricao (
   id_tipo_procedimento int NOT NULL,
   id_orgao int NOT NULL,
   CONSTRAINT PK_restricao PRIMARY KEY(id_tipo_procedimento,id_orgao)
  );
 COMMIT;
END TRY
BEGIN CATCH
 IF XACT_STATE()<>0 ROLLBACK;
 THROW;
END CATCH;
GO
