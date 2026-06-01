-- Filmes lançados a partir de 2000, do mais recente ao mais antigo.
SELECT "titulo", "ano_lancamento", "duracao_minutos"
FROM "filmes"
WHERE "ano_lancamento" >= 2000
ORDER BY "ano_lancamento" DESC, "titulo";

-- Cada filme e seu(s) diretor(es). Filmes com co-direção aparecem em mais de uma linha (caso de borda: multi-diretor).
SELECT f."titulo", p."nome" AS diretor
FROM "filmes" f
INNER JOIN "filmes_diretores" fd ON fd."filme_id" = f."id"
INNER JOIN "personalidades" p   ON p."id" = fd."diretor_id"
ORDER BY f."titulo", p."nome";

-- Visualizações que NÃO geraram nenhuma review (assistido mas sem resenha).
SELECT u."apelido", f."titulo", v."visto_em"
FROM "visualizacoes" v
INNER JOIN "usuarios" u ON u."id" = v."usuario_id"
INNER JOIN "filmes" f   ON f."id" = v."filme_id"
LEFT JOIN "avaliacoes" a ON a."visualizacao_id" = v."id"
WHERE a."id" IS NULL
ORDER BY v."visto_em";

-- Personalidades que nunca atuaram.
SELECT p."nome", p."nacionalidade"
FROM "filmes_atores" fa
RIGHT JOIN "personalidades" p ON p."id" = fa."ator_id"
WHERE fa."ator_id" IS NULL
ORDER BY p."nome";

-- Por filme, total de visualizações, quantas tiveram nota e a média.
SELECT f."titulo",
       COUNT(v."id")            AS total_visualizacoes,
       COUNT(v."nota")          AS total_com_nota,
       ROUND(AVG(v."nota"), 2)  AS nota_media
FROM "filmes" f
INNER JOIN "visualizacoes" v ON v."filme_id" = f."id"
GROUP BY f."id", f."titulo"
ORDER BY nota_media DESC NULLS LAST, total_visualizacoes DESC;

-- Filmes cuja nota média supera a média de nota de todo o catálogo.
SELECT f."titulo", ROUND(AVG(v."nota"), 2) AS nota_media
FROM "filmes" f
INNER JOIN "visualizacoes" v ON v."filme_id" = f."id"
GROUP BY f."id", f."titulo"
HAVING AVG(v."nota") > (SELECT AVG("nota") FROM "visualizacoes")
ORDER BY nota_media DESC;

-- Para cada usuário, a(s) visualização(ões) com a maior nota que ele já deu. Empates retornam mais de uma linha.
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

-- Pares de "seguir mútuo" (A segue B e B segue A).
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

-- Todos os filmes "de interesse" do usuário 1, sejam os já assistidos ou que estão na watchlist
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

-- Filmes que o usuário 1 tem na watchlist mas ainda NÃO assistiu.
SELECT f."titulo"
FROM "filmes" f
WHERE f."id" IN (
    SELECT "filme_id" FROM "watchlist" WHERE "usuario_id" = 1
    EXCEPT
    SELECT "filme_id" FROM "visualizacoes" WHERE "usuario_id" = 1
)
ORDER BY f."titulo";

-- View para reutilizar estatísticas de filmess.
CREATE OR REPLACE VIEW "vw_estatisticas_filmes" AS
SELECT f."id"                         AS filme_id,
       f."titulo",
       f."ano_lancamento",
       COUNT(v."id")         AS total_visualizacoes,
       COUNT(v."usuario_id") AS espectadores_distintos,
       ROUND(AVG(v."nota"), 2)        AS nota_media,
       COUNT(a."id")                  AS total_reviews
FROM "filmes" f
LEFT JOIN "visualizacoes" v ON v."filme_id" = f."id"
LEFT JOIN "avaliacoes" a    ON a."visualizacao_id" = v."id"
GROUP BY f."id", f."titulo", f."ano_lancamento";

-- Consulta usando a view:
SELECT *
FROM "vw_estatisticas_filmes"
ORDER BY "nota_media" DESC NULLS LAST, "total_visualizacoes" DESC;
