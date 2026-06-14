-- Habilita busca por similaridade de trigramas, necessária para indexar texto livre com GIN
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Busca de filmes por título (ILIKE / similaridade), principal porta de entrada do catálogo
CREATE INDEX "idx_filmes_titulo" ON "filmes" USING GIN ("titulo" gin_trgm_ops);

-- Filtro e ordenação por ano de lançamento
CREATE INDEX "idx_filmes_ano_lancamento" ON "filmes" ("ano_lancamento");

-- FKs não ganham índice automático no Postgres; estas são as junções mais frequentes nas consultas
CREATE INDEX "idx_visualizacoes_filme" ON "visualizacoes" ("filme_id");
CREATE INDEX "idx_visualizacoes_usuario" ON "visualizacoes" ("usuario_id");
CREATE INDEX "idx_avaliacoes_visualizacao" ON "avaliacoes" ("visualizacao_id");

-- A PK de usuarios_seguidores cobre buscas por seguido; esta cobre o caminho inverso
-- (quem um usuário segue), usado na consulta de "seguir mútuo"
CREATE INDEX "idx_seguidores_seguidor" ON "usuarios_seguidores" ("usuario_seguidor");
