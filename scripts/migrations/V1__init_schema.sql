CREATE TABLE "usuarios" (
  "id" INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  "apelido" VARCHAR(128) UNIQUE NOT NULL,
  "primeiro_nome" VARCHAR(128) NOT NULL,
  "sobrenome" VARCHAR(128) NOT NULL,
  "email" TEXT NOT NULL UNIQUE,
  "senha_hash" TEXT NOT NULL,
  "bio" TEXT,
  "data_cadastro" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "atualizado_em" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Check impede que um usuário siga a si mesmo
-- DEFERRABLE INITIALLY IMMEDIATE permite a troca da direção da associação, validando a constraint de CHECK
-- somente no final da transação.
CREATE TABLE "usuarios_seguidores" (
  "usuario_seguido" INT NOT NULL REFERENCES "usuarios" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE,
  "usuario_seguidor" INT NOT NULL REFERENCES "usuarios" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE,
  "data_seguido" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY ("usuario_seguido", "usuario_seguidor"),
  CHECK ("usuario_seguido" <> "usuario_seguidor")
);

CREATE TABLE "paises" (
  "codigo"  VARCHAR(3) PRIMARY KEY,
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
  "duracao_minutos" INT NOT NULL CHECK ("duracao_minutos" > 0),
  "poster_url" TEXT NOT NULL,
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
  "publica" BOOLEAN NOT NULL DEFAULT TRUE,
  "criada_em" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- DEFERRABLE INITIALLY IMMEDIATE dá a opção de, numa transação, postergar a validação da constraint
-- para a fase de commit, o que permite que duas tuplas ocupem a mesma posição numa lista de filmes,
-- seguindo o fluxo de reordenação de tuplas existentes.
-- Ex: (1, 2) -> (2, 2) -> (2, 1)
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

-- Intencionalmente uma mesma "sessão" (assistir a um filme) pode ter mais de uma review.
-- O ato de assistir novamente (criar uma nova tupla em "visualizacoes") levaria o sistema
-- a cadastrar novas tuplas de "avaliacoes" relacionadas a sessão mais recente.
CREATE TABLE "avaliacoes" (
  "id" INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  "visualizacao_id" INT NOT NULL REFERENCES "visualizacoes" ("id") ON DELETE CASCADE,
  "review" TEXT NOT NULL,
  "avaliado_em" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "atualizado_em" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
