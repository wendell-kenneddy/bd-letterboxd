CREATE TABLE "usuarios" (
  "id" INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  "apelido" VARCHAR(128) UNIQUE NOT NULL,
  "primeiro_nome" VARCHAR(128) NOT NULL,
  "sobrenome" VARCHAR(128) NOT NULL,
  "senha_hash" TEXT NOT NULL,
  "bio" TEXT,
  "data_cadastro" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "atualizado_em" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE "usuarios_seguidores" (
  "usuario_seguido" INT NOT NULL REFERENCES "usuarios" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE,
  "usuario_seguidor" INT NOT NULL REFERENCES "usuarios" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE,
  "data_seguido" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY ("usuario_seguido", "usuario_seguidor"),
  CHECK ("usuario_seguido" <> "usuario_seguidor")
);

CREATE TABLE "paises" (
  "codigo" CHAR(3) PRIMARY KEY,
  "nome" VARCHAR(128) UNIQUE NOT NULL
);

CREATE TABLE "idiomas" (
  "codigo" VARCHAR(5) PRIMARY KEY,
  "nome" VARCHAR(128) UNIQUE NOT NULL
);

CREATE TABLE "personalidades" (
  "id" INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  "nome" VARCHAR(128) NOT NULL,
  "nacionalidade" CHAR(3) NOT NULL REFERENCES "paises" ("codigo"),
  "bio" TEXT NOT NULL
);

CREATE TABLE "generos" (
  "id" INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  "nome" VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE "filmes" (
  "id" INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  "titulo" TEXT NOT NULL,
  "sinopse" TEXT NOT NULL,
  "idioma_original" VARCHAR(5) NOT NULL REFERENCES "idiomas" ("codigo"),
  "duracao_minutos" INT NOT NULL,
  "banner_url" TEXT NOT NULL,
  "ano_lancamento" INT NOT NULL
);

CREATE TABLE "filmes_diretores" (
  "filme_id" INT NOT NULL REFERENCES "filmes" ("id") ON DELETE CASCADE,
  "diretor_id" INT NOT NULL REFERENCES "personalidades" ("id") ON DELETE CASCADE,
  PRIMARY KEY ("filme_id", "diretor_id")
);

CREATE TABLE "filmes_generos" (
  "filme_id" INT NOT NULL REFERENCES "filmes" ("id") ON DELETE CASCADE,
  "genero_id" INT NOT NULL REFERENCES "generos" ("id") ON DELETE CASCADE,
  PRIMARY KEY ("filme_id", "genero_id")
);

CREATE TABLE "filmes_atores" (
  "filme_id" INT NOT NULL REFERENCES "filmes" ("id") ON DELETE CASCADE,
  "ator_id" INT NOT NULL REFERENCES "personalidades" ("id") ON DELETE CASCADE,
  "personagem" VARCHAR(128) NOT NULL,
  PRIMARY KEY ("ator_id", "filme_id", "personagem")
);

CREATE TABLE "listas" (
  "id" INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  "usuario_id" INT NOT NULL REFERENCES "usuarios" ("id") ON DELETE CASCADE,
  "titulo" VARCHAR(128) NOT NULL,
  "descricao" TEXT,
  "publica" BOOLEAN NOT NULL,
  "criada_em" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE "listas_filmes" (
  "lista_id" INT NOT NULL REFERENCES "listas" ("id") ON DELETE CASCADE,
  "filme_id" INT NOT NULL REFERENCES "filmes" ("id") ON DELETE CASCADE,
  "posicao" INT NOT NULL,
  "adicionado_em" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY ("filme_id", "lista_id"),
  UNIQUE ("lista_id", "posicao") DEFERRABLE INITIALLY IMMEDIATE
);

CREATE TABLE "watchlist" (
  "usuario_id" INT NOT NULL REFERENCES "usuarios" ("id") ON DELETE CASCADE,
  "filme_id" INT NOT NULL REFERENCES "filmes" ("id") ON DELETE CASCADE,
  "adicionado_em" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY ("usuario_id", "filme_id")
);

CREATE TABLE "visualizacoes" (
  "id" INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  "usuario_id" INT NOT NULL REFERENCES "usuarios" ("id") ON DELETE CASCADE,
  "filme_id" INT NOT NULL REFERENCES "filmes" ("id") ON DELETE CASCADE,
  "nota" NUMERIC(2, 1) CHECK ("nota" > 0 AND "nota" <= 5 AND MOD(nota, 0.5) = 0),
  "curtido" BOOLEAN NOT NULL DEFAULT FALSE,
  "visto_em" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE "avaliacoes" (
  "id" INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  "visualizacao_id" INT NOT NULL REFERENCES "visualizacoes" ("id") ON DELETE CASCADE,
  "review" TEXT NOT NULL,
  "avaliado_em" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "atualizado_em" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
