-- Executar uma vez em banco vazio previamente criado. SQL Server 2016 SP1+.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.versao_base (
 versao int NOT NULL PRIMARY KEY CHECK (versao >= 0),
 data_carga datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
 usuario_carga nvarchar(150) NOT NULL,
 origem nvarchar(250) NOT NULL,
 observacao nvarchar(1000) NULL
);
GO
CREATE TABLE dbo.ref_assunto (
id_assunto int NOT NULL,
codigo_estruturado varchar(50) NOT NULL,
descricao varchar(250) NOT NULL,
observacao varchar(500) NULL,
idx_assunto varchar(1000) NULL,
sin_ativo char(1) NOT NULL,
prazo_intermediario int NULL,
prazo_corrente int NULL,
sta_destinacao char(1) NULL,
sin_estrutural char(1) NULL,
id_tabela_assuntos int NOT NULL,
CONSTRAINT PK_ref_assunto PRIMARY KEY (id_assunto)
);
GO
CREATE TABLE dbo.assunto (
id_assunto int NOT NULL,
codigo_estruturado varchar(50) NOT NULL,
descricao varchar(250) NOT NULL,
observacao varchar(500) NULL,
idx_assunto varchar(1000) NULL,
sin_ativo char(1) NOT NULL,
prazo_intermediario int NULL,
prazo_corrente int NULL,
sta_destinacao char(1) NULL,
sin_estrutural char(1) NULL,
id_tabela_assuntos int NOT NULL,
versao int NOT NULL,
sin_ultima char(1) NOT NULL CHECK (sin_ultima IN ('S','N')),
CONSTRAINT PK_assunto PRIMARY KEY (versao, id_assunto),
CONSTRAINT FK_assunto_versao FOREIGN KEY (versao) REFERENCES dbo.versao_base(versao)
);
GO
CREATE OR ALTER TRIGGER dbo.tr_ref_assunto_imutavel
ON dbo.ref_assunto INSTEAD OF UPDATE, DELETE AS
BEGIN
 THROW 51000, 'Tabela de referencia imutavel: UPDATE e DELETE proibidos.', 1;
END;
GO
CREATE TABLE dbo.ref_tipo_procedimento (
id_tipo_procedimento int NOT NULL,
nome varchar(100) NOT NULL,
descricao varchar(250) NULL,
sin_ativo char(1) NOT NULL,
sta_nivel_acesso_sugestao char(1) NOT NULL,
sin_interno char(1) NOT NULL,
sin_ouvidoria char(1) NOT NULL,
sin_individual char(1) NOT NULL,
id_hipotese_legal_sugestao int NULL,
sta_grau_sigilo_sugestao char(1) NULL,
id_plano_trabalho int NULL,
sin_ouvidoria_anonimo char(1) NOT NULL,
CONSTRAINT PK_ref_tipo_procedimento PRIMARY KEY (id_tipo_procedimento)
);
GO
CREATE TABLE dbo.tipo_procedimento (
id_tipo_procedimento int NOT NULL,
nome varchar(100) NOT NULL,
descricao varchar(250) NULL,
sin_ativo char(1) NOT NULL,
sta_nivel_acesso_sugestao char(1) NOT NULL,
sin_interno char(1) NOT NULL,
sin_ouvidoria char(1) NOT NULL,
sin_individual char(1) NOT NULL,
id_hipotese_legal_sugestao int NULL,
sta_grau_sigilo_sugestao char(1) NULL,
id_plano_trabalho int NULL,
sin_ouvidoria_anonimo char(1) NOT NULL,
versao int NOT NULL,
sin_ultima char(1) NOT NULL CHECK (sin_ultima IN ('S','N')),
CONSTRAINT PK_tipo_procedimento PRIMARY KEY (versao, id_tipo_procedimento),
CONSTRAINT FK_tipo_procedimento_versao FOREIGN KEY (versao) REFERENCES dbo.versao_base(versao)
);
GO
CREATE OR ALTER TRIGGER dbo.tr_ref_tipo_procedimento_imutavel
ON dbo.ref_tipo_procedimento INSTEAD OF UPDATE, DELETE AS
BEGIN
 THROW 51000, 'Tabela de referencia imutavel: UPDATE e DELETE proibidos.', 1;
END;
GO
CREATE TABLE dbo.ref_rel_tipo_procedimento_assunto (
id_tipo_procedimento int NOT NULL,
sequencia int NOT NULL,
id_assunto_proxy int NOT NULL,
CONSTRAINT PK_ref_rel_tipo_procedimento_assunto PRIMARY KEY (id_tipo_procedimento, sequencia)
);
GO
CREATE TABLE dbo.rel_tipo_procedimento_assunto (
id_tipo_procedimento int NOT NULL,
sequencia int NOT NULL,
id_assunto_proxy int NOT NULL,
versao int NOT NULL,
sin_ultima char(1) NOT NULL CHECK (sin_ultima IN ('S','N')),
CONSTRAINT PK_rel_tipo_procedimento_assunto PRIMARY KEY (versao, id_tipo_procedimento, sequencia),
CONSTRAINT FK_rel_tipo_procedimento_assunto_versao FOREIGN KEY (versao) REFERENCES dbo.versao_base(versao)
);
GO
CREATE OR ALTER TRIGGER dbo.tr_ref_rel_tipo_procedimento_assunto_imutavel
ON dbo.ref_rel_tipo_procedimento_assunto INSTEAD OF UPDATE, DELETE AS
BEGIN
 THROW 51000, 'Tabela de referencia imutavel: UPDATE e DELETE proibidos.', 1;
END;
GO
ALTER TABLE dbo.ref_rel_tipo_procedimento_assunto ADD
 CONSTRAINT FK_ref_rel_tipo FOREIGN KEY (id_tipo_procedimento) REFERENCES dbo.ref_tipo_procedimento(id_tipo_procedimento),
 CONSTRAINT FK_ref_rel_assunto FOREIGN KEY (id_assunto_proxy) REFERENCES dbo.ref_assunto(id_assunto);
ALTER TABLE dbo.rel_tipo_procedimento_assunto ADD
 CONSTRAINT FK_rel_tipo FOREIGN KEY (versao,id_tipo_procedimento) REFERENCES dbo.tipo_procedimento(versao,id_tipo_procedimento),
 CONSTRAINT FK_rel_assunto FOREIGN KEY (versao,id_assunto_proxy) REFERENCES dbo.assunto(versao,id_assunto);
GO
