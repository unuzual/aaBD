﻿-- CRIAÇÃO TABELA ORIGINAL CSV

CREATE SCHEMA IF NOT EXISTS aa_bd_px_gs_rm;
set schema 'aa_bd_px_gs_rm';

DROP TABLE IF EXISTS raw_data;

create table raw_data (
    "Codigo_Orgao_Superior" VARCHAR NOT NULL,
    "Nome_Orgao_Superior" VARCHAR NOT NULL,
    "Codigo_Orgao_Subordinado" VARCHAR NOT NULL,
    "Nome_Orgao_Subordinado" VARCHAR NOT NULL,
    "Codigo_Unidade_Gestora" VARCHAR NOT NULL,
    "Nome_Unidade_Gestora" VARCHAR NOT NULL,
    "Codigo_Funcao" VARCHAR NOT NULL,
    "Nome_Funcao" VARCHAR NOT NULL,
    "Codigo_Subfuncao" VARCHAR NOT NULL,
    "Nome_Subfuncao" VARCHAR NOT NULL,
    "Codigo_Programa" VARCHAR NOT NULL,
    "Nome_Programa" VARCHAR NOT NULL,
    "Codigo_Acao" VARCHAR NOT NULL,
    "Nome_Acao" VARCHAR NOT NULL,
    "Linguagem_Cidada" VARCHAR,
    "CPF_Favorecido" VARCHAR NOT NULL,
    "Nome_Favorecido" VARCHAR NOT NULL,
    "Documento_Pagamento" VARCHAR NOT NULL,
    "Gestao_Pagamento" VARCHAR NOT NULL,
    "Data_Pagamento" VARCHAR NOT NULL,
    "Valor_Pagamento" DOUBLE PRECISION NOT NULL
);
COMMIT;

set client_encoding = UTF8;
COPY raw_data_test from '/home/over/git/aa_BD/201403_Diarias.csv' delimiter ',' CSV HEADER;
-- Finalizar importação
COMMIT;

END;

create table orgao_superior (
	codigo_orgao_superior varchar PRIMARY KEY,
	nome_orgao_superior varchar
);

create table orgao_subordinado (
	codigo_orgao_subordinado varchar PRIMARY KEY,
	nome_orgao_subordinado varchar,
	codigo_orgao_superior varchar,

	CONSTRAINT table_orgao_subordinado_codigo_orgao_superior FOREIGN KEY(codigo_orgao_superior)
		REFERENCES orgao_superior(codigo_orgao_superior) MATCH SIMPLE
);

create table unidade_gestora (
	codigo_unidade_gestora varchar PRIMARY KEY,
	nome_unidade_gestora varchar,
	codigo_orgao_subordinado varchar,

	CONSTRAINT table_unidade_gestora_id_orgao_unidade_gestora_fkey FOREIGN KEY (codigo_orgao_subordinado)
		REFERENCES orgao_subordinado(codigo_orgao_subordinado) MATCH SIMPLE
);

create table funcao (
	codigo_funcao varchar PRIMARY KEY,
	nome_funcao varchar
);

create table subfuncao (
	codigo_subfuncao varchar PRIMARY KEY,
	nome_subfuncao varchar
);

create table programa (
	codigo_programa varchar PRIMARY KEY,
	nome_programa varchar
);

create table acao (
	codigo_acao varchar PRIMARY KEY,
	nome_acao varchar,
	linguagem_cidada varchar
);

create table favorecido (
	id_favorecido SERIAL PRIMARY KEY,
	cpf_favorecido varchar,
	nome_favorecido varchar
);

create table funcao_geral (
	id_funcao_geral SERIAL PRIMARY KEY,
	id_funcao varchar,
	id_subfuncao varchar,
	
	CONSTRAINT table_funcao_fkey FOREIGN KEY (id_funcao)
		REFERENCES funcao (codigo_funcao) MATCH SIMPLE,
	CONSTRAINT table_subfuncao_fkey FOREIGN KEY (id_subfuncao)
		REFERENCES subfuncao (codigo_subfuncao) MATCH SIMPLE
);

create table programa_acao (
	id_programa_acao SERIAL PRIMARY KEY,
	codigo_acao varchar,
	codigo_programa varchar,

	CONSTRAINT table_programa_acao_acao_fkey FOREIGN KEY (codigo_acao)
		REFERENCES acao (codigo_acao) MATCH SIMPLE,
	CONSTRAINT table_programa_acao_programa_programa_fkey FOREIGN KEY (codigo_programa)
		REFERENCES programa (codigo_programa) MATCH SIMPLE
);


create table funcao_geral_programa_acao (
	id_funcao_geral_programa_acao SERIAL PRIMARY KEY,
	id_funcao_geral integer,
	id_programa_acao integer,

	CONSTRAINT table_funcao_geral_programa_acao_id_funcao_geral_fkey FOREIGN KEY (id_funcao_geral)
		REFERENCES funcao_geral (id_funcao_geral) MATCH SIMPLE,
	CONSTRAINT table_funcao_geral_programa_acao_id_programa_acao_fkey FOREIGN KEY (id_programa_acao)
		REFERENCES programa_acao (id_programa_acao) MATCH SIMPLE
);

/* QUERIES DE INSERÇÃO NAS TABELAS */

INSERT INTO orgao_superior (codigo_orgao_superior,nome_orgao_superior) SELECT DISTINCT "Codigo_Orgao_Superior", "Nome_Orgao_Superior" from raw_data ORDER BY "Codigo_Orgao_Superior" ASC;

INSERT INTO orgao_subordinado(codigo_orgao_subordinado,nome_orgao_subordinado,codigo_orgao_superior) SELECT DISTINCT  "Codigo_Orgao_Subordinado", "Nome_Orgao_Subordinado","Codigo_Orgao_Superior" from raw_data ORDER BY "Nome_Orgao_Subordinado" ASC;

INSERT INTO unidade_gestora (codigo_unidade_gestora,nome_unidade_gestora,codigo_orgao_subordinado) SELECT DISTINCT "Codigo_Unidade_Gestora", "Nome_Unidade_Gestora","Codigo_Orgao_Subordinado" from raw_data ORDER BY "Codigo_Unidade_Gestora" ASC;

INSERT INTO funcao(codigo_funcao,nome_funcao) SELECT DISTINCT "Codigo_Funcao", "Nome_Funcao" from raw_data ORDER BY "Nome_Funcao" ASC;

INSERT INTO subfuncao(codigo_subfuncao,nome_subfuncao) SELECT DISTINCT "Codigo_Subfuncao", "Nome_Subuncao" from raw_data ORDER BY "Nome_Subuncao" ASC;

INSERT INTO funcao_geral(id_funcao,id_subfuncao) SELECT DISTINCT "Codigo_Funcao","Codigo_Subfuncao" from raw_data;

INSERT INTO programa(codigo_programa,nome_programa) SELECT DISTINCT "Codigo_Programa", "Nome_Programa" from raw_data ORDER BY "Nome_Programa" ASC;

INSERT INTO acao(codigo_acao,nome_acao,linguagem_cidada) SELECT DISTINCT "Codigo_Acao", "Nome_Acao","Linguagem_Cidada" from raw_data;

INSERT INTO programa_acao (codigo_programa,codigo_acao) select distinct "Codigo_Programa","Codigo_Acao" from raw_data;

INSERT INTO favorecido (cpf_favorecido,nome_favorecido) select distinct "CPF_Favorecido","Nome_Favorecido" from raw_data;

/* FIM QUERIES DE INSERÇÃO NAS TABELAS */


BEGIN;

CREATE TABLE pagamentos
(
  id SERIAL PRIMARY KEY,
  codigo_unidade_gestora varchar,
  codigo_funcao varchar,
  codigo_subfuncao varchar,
  id_funcao_geral_programa_acao integer,
  id_funcao_geral integer,
  id_programa_acao integer,
  codigo_programa varchar,
  codigo_acao varchar,
  id_favorecido integer,
  cpf_favorecido varchar,
  nome_favorecido varchar,
  documento_pagamento varchar,
  gestao_pagamento varchar,
  data_pagamento varchar,
  valor_pagamento varchar,
  
  CONSTRAINT pagamentos_codigo_acao_fkey FOREIGN KEY (codigo_acao)
      REFERENCES acao (codigo_acao) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT pagamentos_codigo_funcao FOREIGN KEY (codigo_funcao)
      REFERENCES funcao (codigo_funcao) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT pagamentos_codigo_subfuncao_fkey FOREIGN KEY (codigo_subfuncao)
      REFERENCES subfuncao (codigo_subfuncao) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT pagamentos_funcao_geral_fkey FOREIGN KEY (id_funcao_geral)
      REFERENCES funcao_geral (id_funcao_geral) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT pagamentos_codigo_unidade_gestora FOREIGN KEY (codigo_unidade_gestora)
      REFERENCES unidade_gestora (codigo_unidade_gestora) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT pagamentos_id_favorecido_fkey FOREIGN KEY (id_favorecido)
      REFERENCES favorecido (id_favorecido) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT pagamentos_id_programa_acao_fkey FOREIGN KEY (id_programa_acao)
      REFERENCES programa_acao (id_programa_acao) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT pagamentos_id_funcao_geral_programa_acao_fkey FOREIGN KEY (id_funcao_geral_programa_acao)
      REFERENCES funcao_geral_programa_acao (id_funcao_geral_programa_acao) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE pagamentos
  OWNER TO postgres;

INSERT INTO pagamentos (codigo_unidade_gestora,codigo_funcao,codigo_subfuncao,codigo_acao,codigo_programa,cpf_favorecido,nome_favorecido,documento_pagamento,gestao_pagamento,data_pagamento,valor_pagamento)
	SELECT 
		"Codigo_Unidade_Gestora" ,
		"Codigo_Funcao",
		"Codigo_Subfuncao",
		"Codigo_Acao",
		"Codigo_Programa",
		"CPF_Favorecido",
		"Nome_Favorecido",
		"Documento_Pagamento",
		"Gestao_Pagamento",
		"Data_Pagamento",
		"Valor_Pagamento"
		
from raw_data;

-- Ajustando , para ponto e convertendo o data_type para float para poder utilizar nas querys futuras
UPDATE pagamentos SET valor_pagamento = replace(valor_pagamento, ',', '.');
ALTER TABLE pagamentos ALTER COLUMN valor_pagamento TYPE Numeric(10,2) USING valor_pagamento::Numeric(10,2);
-- Finalizando ajuste de data_type

CREATE INDEX 
   ON pagamentos USING btree (cpf_favorecido ASC NULLS LAST, nome_favorecido ASC NULLS LAST);

CREATE INDEX 
   ON pagamentos USING btree (id_funcao_geral_programa_acao ASC NULLS LAST);

CREATE INDEX ON favorecido USING btree (cpf_favorecido ASC NULLS LAST, nome_favorecido ASC NULLS LAST);

-- Elaborando Favorecidos
UPDATE pagamentos a SET "id_favorecido" = (Select favorecido."id_favorecido" from favorecido,pagamentos where pagamentos."cpf_favorecido" = favorecido."cpf_favorecido" and pagamentos."nome_favorecido" = favorecido."nome_favorecido" and a.id = pagamentos.id);
ALTER TABLE pagamentos DROP "cpf_favorecido";
ALTER TABLE pagamentos DROP "nome_favorecido";
-- Finalizando Favorecidos

------------FUNCAO_GERAL_PROGRAMA_ACAO ---------------------
--Estabelecendo funcao_geral
UPDATE pagamentos a SET "id_funcao_geral" = (Select funcao_geral."id_funcao_geral" from funcao_geral,pagamentos where pagamentos."codigo_funcao" = funcao_geral."id_funcao" and pagamentos."codigo_subfuncao" = funcao_geral."id_subfuncao" and a.id = pagamentos.id);
ALTER TABLE pagamentos DROP "codigo_funcao";
ALTER TABLE pagamentos DROP "codigo_subfuncao";
-- Finalizando funcao_geral


UPDATE pagamentos a SET "id_programa_acao" = (Select programa_acao."id_programa_acao" from programa_acao where a.codigo_acao = programa_acao.codigo_acao and a.codigo_programa = programa_acao.codigo_programa);
ALTER TABLE pagamentos DROP codigo_acao;
ALTER TABLE pagamentos DROP codigo_programa;

--Preenche a tabela funcao_geral_programa_acao
INSERT INTO funcao_geral_programa_acao (id_funcao_geral,id_programa_acao) select distinct "id_funcao_geral","id_programa_acao" from pagamentos;

------------FUNCAO_GERAL_PROGRAMA_ACAO ---------------------

UPDATE pagamentos a SET "id_funcao_geral_programa_acao" = (Select funcao_geral_programa_acao."id_funcao_geral_programa_acao" from funcao_geral_programa_acao where a.id_funcao_geral = funcao_geral_programa_acao.id_funcao_geral and a.id_programa_acao = funcao_geral_programa_acao.id_programa_acao);
ALTER TABLE pagamentos DROP id_funcao_geral;
ALTER TABLE pagamentos DROP id_programa_acao;

COMMIT;

END;
