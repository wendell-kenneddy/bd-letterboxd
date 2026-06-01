-- =============================================================================
-- Consultas de demonstração do schema (Letterboxd-like)
-- =============================================================================
-- Pré-requisitos: aplicar scripts/migrations/V1__init_schema.sql e
-- carregar scripts/seed/seed.sql.
--
-- 10 consultas em dificuldade progressiva + 1 view, mapeadas aos requisitos do
-- README (seleções simples; junções INNER/LEFT/RIGHT; subconsultas
-- correlacionadas e não-correlacionadas; agregação com GROUP BY/HAVING;
-- operadores de conjunto; e ao menos uma view):
--
--   Q01 ... seleção simples (WHERE, ORDER BY)
--   Q02 ... INNER JOIN (várias tabelas via associativas)
--   Q03 ... LEFT JOIN + IS NULL
--   Q04 ... RIGHT JOIN + IS NULL
--   Q05 ... agregação com GROUP BY (AVG/COUNT, tratamento de NULL)
--   Q06 ... GROUP BY + HAVING + subconsulta NÃO-correlacionada
--   Q07 ... subconsulta CORRELACIONADA (escalar, MAX por usuário)
--   Q08 ... subconsulta CORRELACIONADA com EXISTS (seguir mútuo)
--   Q09 ... operador de conjunto: UNION
--   Q10 ... operador de conjunto: EXCEPT
--   VW .... VIEW (criação + consulta)
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Q01 | Seleção simples
-- Conceito: SELECT/WHERE/ORDER BY sobre uma única tabela.
-- Pergunta: filmes lançados a partir de 2000, do mais recente ao mais antigo.
-- -----------------------------------------------------------------------------
SELECT "titulo", "ano_lancamento", "duracao_minutos"
FROM "filmes"
WHERE "ano_lancamento" >= 2000
ORDER BY "ano_lancamento" DESC, "titulo";


-- -----------------------------------------------------------------------------
-- Q02 | INNER JOIN
-- Conceito: junção interna encadeando filme -> associativa -> personalidade.
-- Pergunta: cada filme e seu(s) diretor(es). Filmes com co-direção aparecem
--           em mais de uma linha (caso de borda: multi-diretor).
-- -----------------------------------------------------------------------------
SELECT f."titulo", p."nome" AS diretor
FROM "filmes" f
INNER JOIN "filmes_diretores" fd ON fd."filme_id" = f."id"
INNER JOIN "personalidades" p   ON p."id" = fd."diretor_id"
ORDER BY f."titulo", p."nome";


-- -----------------------------------------------------------------------------
-- Q03 | LEFT JOIN + IS NULL
-- Conceito: preservar a tabela da esquerda e filtrar ausência de correspondência.
-- Pergunta: visualizações que NÃO geraram nenhuma review (assistido mas sem
--           resenha). Caso de borda: review é opcional por sessão.
-- -----------------------------------------------------------------------------
SELECT u."apelido", f."titulo", v."visto_em"
FROM "visualizacoes" v
INNER JOIN "usuarios" u ON u."id" = v."usuario_id"
INNER JOIN "filmes" f   ON f."id" = v."filme_id"
LEFT JOIN "avaliacoes" a ON a."visualizacao_id" = v."id"
WHERE a."id" IS NULL
ORDER BY v."visto_em";


-- -----------------------------------------------------------------------------
-- Q04 | RIGHT JOIN + IS NULL
-- Conceito: preservar a tabela da direita (personalidades) mesmo sem par.
-- Pergunta: personalidades que nunca atuaram (são apenas diretores).
-- -----------------------------------------------------------------------------
SELECT p."nome", p."nacionalidade"
FROM "filmes_atores" fa
RIGHT JOIN "personalidades" p ON p."id" = fa."ator_id"
WHERE fa."ator_id" IS NULL
ORDER BY p."nome";


-- -----------------------------------------------------------------------------
-- Q05 | Agregação com GROUP BY
-- Conceito: AVG/COUNT por grupo; COUNT(coluna) ignora NULL.
-- Pergunta: por filme, total de visualizações, quantas tiveram nota e a média.
--           Caso de borda: filme assistido sem nota (NULL) entra na contagem de
--           visualizações mas não na média nem em total_com_nota.
-- -----------------------------------------------------------------------------
SELECT f."titulo",
       COUNT(v."id")            AS total_visualizacoes,
       COUNT(v."nota")          AS total_com_nota,
       ROUND(AVG(v."nota"), 2)  AS nota_media
FROM "filmes" f
INNER JOIN "visualizacoes" v ON v."filme_id" = f."id"
GROUP BY f."id", f."titulo"
ORDER BY nota_media DESC NULLS LAST, total_visualizacoes DESC;


-- -----------------------------------------------------------------------------
-- Q06 | GROUP BY + HAVING + subconsulta NÃO-correlacionada
-- Conceito: HAVING comparando agregado do grupo com um escalar global calculado
--           por subconsulta independente (avaliada uma única vez).
-- Pergunta: filmes cuja nota média supera a média de nota de todo o catálogo.
-- -----------------------------------------------------------------------------
SELECT f."titulo", ROUND(AVG(v."nota"), 2) AS nota_media
FROM "filmes" f
INNER JOIN "visualizacoes" v ON v."filme_id" = f."id"
GROUP BY f."id", f."titulo"
HAVING AVG(v."nota") > (SELECT AVG("nota") FROM "visualizacoes")
ORDER BY nota_media DESC;


-- -----------------------------------------------------------------------------
-- Q07 | Subconsulta CORRELACIONADA (escalar)
-- Conceito: a subconsulta referencia a linha externa (v.usuario_id) e é
--           reavaliada por linha.
-- Pergunta: para cada usuário, a(s) visualização(ões) com a maior nota que ele
--           já deu. Empates retornam mais de uma linha.
-- -----------------------------------------------------------------------------
SELECT u."apelido", f."titulo", v."nota", v."visto_em"
FROM "visualizacoes" v
INNER JOIN "usuarios" u ON u."id" = v."usuario_id"
INNER JOIN "filmes" f   ON f."id" = v."filme_id"
WHERE v."nota" = (
    SELECT MAX(v2."nota")
    FROM "visualizacoes" v2
    WHERE v2."usuario_id" = v."usuario_id"
)
ORDER BY u."apelido", f."titulo";


-- -----------------------------------------------------------------------------
-- Q08 | Subconsulta CORRELACIONADA com EXISTS
-- Conceito: EXISTS correlacionado para testar reciprocidade.
-- Pergunta: pares de "seguir mútuo" (A segue B e B segue A).
-- -----------------------------------------------------------------------------
SELECT seguidor."apelido" AS quem_segue,
       seguido."apelido"  AS quem_e_seguido
FROM "usuarios_seguidores" s
INNER JOIN "usuarios" seguidor ON seguidor."id" = s."usuario_seguidor"
INNER JOIN "usuarios" seguido  ON seguido."id"  = s."usuario_seguido"
WHERE EXISTS (
    SELECT 1
    FROM "usuarios_seguidores" s2
    WHERE s2."usuario_seguidor" = s."usuario_seguido"
      AND s2."usuario_seguido"  = s."usuario_seguidor"
)
ORDER BY quem_segue, quem_e_seguido;


-- -----------------------------------------------------------------------------
-- Q09 | Operador de conjunto: UNION
-- Conceito: UNION elimina duplicatas entre os dois conjuntos.
-- Pergunta: todos os filmes "de interesse" do usuário 1, sejam os já assistidos
--           ou os que estão na watchlist (sem repetição).
-- -----------------------------------------------------------------------------
SELECT f."titulo", 'assistido' AS origem
FROM "visualizacoes" v
INNER JOIN "filmes" f ON f."id" = v."filme_id"
WHERE v."usuario_id" = 1
UNION
SELECT f."titulo", 'watchlist' AS origem
FROM "watchlist" w
INNER JOIN "filmes" f ON f."id" = w."filme_id"
WHERE w."usuario_id" = 1
ORDER BY "titulo";


-- -----------------------------------------------------------------------------
-- Q10 | Operador de conjunto: EXCEPT
-- Conceito: diferença de conjuntos.
-- Pergunta: filmes que o usuário 1 tem na watchlist mas ainda NÃO assistiu.
-- -----------------------------------------------------------------------------
SELECT f."titulo"
FROM "filmes" f
WHERE f."id" IN (
    SELECT "filme_id" FROM "watchlist"     WHERE "usuario_id" = 1
    EXCEPT
    SELECT "filme_id" FROM "visualizacoes" WHERE "usuario_id" = 1
)
ORDER BY f."titulo";


-- -----------------------------------------------------------------------------
-- VW | VIEW (criação + consulta)
-- Conceito: encapsular uma consulta de estatísticas reutilizável. Usa LEFT JOIN
--           para que filmes sem visualização/review ainda apareçam (com zeros/
--           NULL), e COUNT(DISTINCT ...) para não inflar contagens na junção.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW "vw_estatisticas_filmes" AS
SELECT f."id"                         AS filme_id,
       f."titulo",
       f."ano_lancamento",
       COUNT(DISTINCT v."id")         AS total_visualizacoes,
       COUNT(DISTINCT v."usuario_id") AS espectadores_distintos,
       ROUND(AVG(v."nota"), 2)        AS nota_media,
       COUNT(DISTINCT a."id")         AS total_reviews
FROM "filmes" f
LEFT JOIN "visualizacoes" v ON v."filme_id" = f."id"
LEFT JOIN "avaliacoes" a    ON a."visualizacao_id" = v."id"
GROUP BY f."id", f."titulo", f."ano_lancamento";

-- Consulta usando a view:
SELECT *
FROM "vw_estatisticas_filmes"
ORDER BY "nota_media" DESC NULLS LAST, "total_visualizacoes" DESC;
