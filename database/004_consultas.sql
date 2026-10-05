-- Executar uma vez em sei_gd, após scripts 001 e 002.
SET XACT_ABORT ON;
BEGIN TRANSACTION;
CREATE TABLE dbo.usuario (
 id_usuario int IDENTITY PRIMARY KEY,
 email varchar(250) NOT NULL UNIQUE,
 sin_ativo char(1) NOT NULL DEFAULT 'S' CHECK(sin_ativo IN ('S','N'))
);
CREATE TABLE dbo.orgao (
 id_orgao int IDENTITY PRIMARY KEY,
 nome nvarchar(150) NOT NULL,
 sigla varchar(30) NOT NULL UNIQUE
);
CREATE TABLE dbo.usuario_orgao (
 id_usuario int NOT NULL REFERENCES dbo.usuario(id_usuario),
 id_orgao int NOT NULL REFERENCES dbo.orgao(id_orgao),
 PRIMARY KEY(id_usuario,id_orgao)
);
CREATE TABLE dbo.consulta (
 id_consulta int IDENTITY PRIMARY KEY,
 nome nvarchar(150) NOT NULL,
 versao int NOT NULL REFERENCES dbo.versao_base(versao),
 UNIQUE(id_consulta,versao)
);
CREATE TABLE dbo.consulta_orgao (
 id_consulta int NOT NULL REFERENCES dbo.consulta(id_consulta),
 id_orgao int NOT NULL REFERENCES dbo.orgao(id_orgao),
 status varchar(12) NOT NULL DEFAULT 'RASCUNHO' CHECK(status IN ('RASCUNHO','FINALIZADA')),
 PRIMARY KEY(id_consulta,id_orgao)
);
CREATE TABLE dbo.consulta_orgao_tipo (
 id_atribuicao int IDENTITY PRIMARY KEY,
 id_consulta int NOT NULL,
 id_orgao int NOT NULL,
 versao int NOT NULL,
 id_tipo_procedimento int NOT NULL,
 UNIQUE(id_consulta,id_orgao,id_tipo_procedimento),
 FOREIGN KEY(id_consulta,id_orgao) REFERENCES dbo.consulta_orgao(id_consulta,id_orgao),
 FOREIGN KEY(id_consulta,versao) REFERENCES dbo.consulta(id_consulta,versao),
 FOREIGN KEY(versao,id_tipo_procedimento) REFERENCES dbo.tipo_procedimento(versao,id_tipo_procedimento)
);
CREATE TABLE dbo.visualizacao_tipo (
 id_atribuicao int NOT NULL PRIMARY KEY REFERENCES dbo.consulta_orgao_tipo(id_atribuicao),
 id_usuario int NOT NULL REFERENCES dbo.usuario(id_usuario),
 data_visualizacao datetime2 NOT NULL DEFAULT SYSUTCDATETIME()
);
CREATE TABLE dbo.auditoria (
 id_auditoria bigint IDENTITY PRIMARY KEY,
 data_evento datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
 id_usuario int NOT NULL REFERENCES dbo.usuario(id_usuario),
 evento varchar(50) NOT NULL,
 detalhe nvarchar(1000) NULL
);
INSERT dbo.usuario(email) VALUES('pg@setic.ro.gov.br');
COMMIT;
GO
CREATE OR ALTER TRIGGER dbo.tr_auditoria_imutavel ON dbo.auditoria
INSTEAD OF UPDATE,DELETE AS
BEGIN
 THROW 51020, 'Historico de auditoria nao pode ser sobrescrito.', 1;
END;
GO
