CREATE ROLE "audit";

CREATE ROLE "editor";

CREATE ROLE "viewer";

-- View com estatísticas sobre o usuário, utilizada primariamente quando um usuário acessa o perfil de outro
CREATE OR REPLACE VIEW "vw_usuario_perfil" AS
SELECT
    u."id",
    u."apelido",
    u."bio",
    u."data_cadastro",
    COUNT(DISTINCT v."filme_id") AS "filmes_assistidos",
    COUNT(DISTINCT a."id") AS "resenhas_publicadas"
FROM "usuarios" u
LEFT JOIN "visualizacoes" v ON v."usuario_id" = u."id"
LEFT JOIN "avaliacoes" a ON a."visualizacao_id" = v."id"
GROUP BY u."id";

-- Role "editor" tem somente poder editorial sobre o sistema, sendo capaz de criar e gerenciar o catálogo de filmes, atores, gêneros etc.
GRANT SELECT, INSERT, UPDATE, DELETE ON
    "paises",
    "idiomas",
    "generos",
    "personalidades",
    "filmes",
    "filmes_generos",
    "filmes_diretores",
    "filmes_atores"
TO "editor";

-- Role "viewer" pode ver todo o catálogo, bem como os perfis de outros usuários
GRANT SELECT ON
    "paises",
    "idiomas",
    "generos",
    "personalidades",
    "filmes",
    "filmes_generos",
    "filmes_diretores",
    "filmes_atores",
    "vw_usuario_perfil"
TO "viewer";

GRANT SELECT, INSERT, UPDATE, DELETE ON
    "listas",
    "listas_filmes",
    "watchlist",
    "visualizacoes",
    "avaliacoes",
    "usuarios_seguidores"
TO "viewer";

GRANT SELECT ON ALL TABLES IN SCHEMA public TO "audit";

-- Menor privilégio também para a auditoria: dados cadastrais são visíveis (necessários para
-- investigações e LGPD), mas credenciais nunca. O grant por coluna exclui "senha_hash".
REVOKE SELECT ON "usuarios" FROM "audit";
GRANT SELECT (
    "id", "apelido", "primeiro_nome", "sobrenome",
    "email", "bio", "data_cadastro", "atualizado_em"
) ON "usuarios" TO "audit";

-- Colunas GENERATED ALWAYS AS IDENTITY usam sequences por baixo dos panos,
-- então roles que fazem INSERT precisam de USAGE nelas.
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO "editor", "viewer";

-- Subsistema principal, onde os usuários acessam o sistema
CREATE USER "app:main";

-- Subsistema dedicado para a equipe editorial da plataforma
CREATE USER "app:editorial";

-- Subsistema dedicado para a equipe de auditoria da plataforma, com maior nível de acesso
CREATE USER "app:audit";

GRANT "viewer" TO "app:main";
GRANT "editor" TO "app:editorial";
GRANT "audit" TO "app:audit";

-- Funções de autenticação com SECURITY DEFINER: executam com os privilégios do owner (superuser),
-- permitindo que o viewer cadastre e autentique usuários sem acesso direto à tabela "usuarios".

-- Cadastro: recebe os dados em texto plano, faz o hash internamente e retorna apenas o id criado.
CREATE OR REPLACE FUNCTION registrar_usuario(
    p_apelido       VARCHAR,
    p_primeiro_nome VARCHAR,
    p_sobrenome     VARCHAR,
    p_email         TEXT,
    p_senha         TEXT,
    p_bio           TEXT DEFAULT NULL
) RETURNS INT
LANGUAGE sql
SECURITY DEFINER
AS $$
    INSERT INTO "usuarios" ("apelido", "primeiro_nome", "sobrenome", "email", "senha_hash", "bio")
    VALUES (p_apelido, p_primeiro_nome, p_sobrenome, p_email,
            crypt(p_senha, gen_salt('bf')), p_bio)
    RETURNING "id"
$$;

-- Login: recebe credenciais, retorna id e apelido se válidas, nenhuma linha se inválidas.
-- A senha em texto plano nunca sai da função.
CREATE OR REPLACE FUNCTION autenticar_usuario(
    p_email TEXT,
    p_senha TEXT
) RETURNS TABLE("id" INT, "apelido" VARCHAR)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT u."id", u."apelido"
    FROM "usuarios" u
    WHERE u."email" = p_email
    AND u."senha_hash" = crypt(p_senha, u."senha_hash")
$$;

-- Apenas o viewer pode chamar as funções; ninguém mais precisa
REVOKE ALL ON FUNCTION registrar_usuario FROM PUBLIC;
REVOKE ALL ON FUNCTION autenticar_usuario FROM PUBLIC;
GRANT EXECUTE ON FUNCTION registrar_usuario TO "viewer";
GRANT EXECUTE ON FUNCTION autenticar_usuario TO "viewer";
