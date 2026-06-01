-- =============================================================================
-- Seed de dados para o schema Letterboxd-like (V1__init_schema.sql)
-- Ordem de inserção respeita as dependências de chave estrangeira.
-- IDs gerados por IDENTITY são assumidos sequenciais a partir de 1
-- (banco recém-criado, sem inserts anteriores).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tabelas de domínio (sem dependências)
-- -----------------------------------------------------------------------------

-- paises (PK textual ISO 3166-1 alfa-3)
INSERT INTO "paises" ("codigo", "nome") VALUES
  ('USA', 'Estados Unidos'),
  ('BRA', 'Brasil'),
  ('GBR', 'Reino Unido'),
  ('FRA', 'França'),
  ('JPN', 'Japão'),
  ('NZL', 'Nova Zelândia'),
  ('ESP', 'Espanha'),
  ('IRL', 'Irlanda');

-- idiomas (PK textual BCP 47)
INSERT INTO "idiomas" ("codigo", "nome") VALUES
  ('en', 'Inglês'),
  ('pt-BR', 'Português (Brasil)'),
  ('fr', 'Francês'),
  ('ja', 'Japonês'),
  ('es', 'Espanhol');

-- generos
INSERT INTO "generos" ("nome") VALUES
  ('Drama'),       -- 1
  ('Ficção Científica'), -- 2
  ('Crime'),       -- 3
  ('Animação'),    -- 4
  ('Aventura'),    -- 5
  ('Suspense'),    -- 6
  ('Romance');     -- 7

-- -----------------------------------------------------------------------------
-- usuarios (tabela principal)
-- senha_hash são placeholders representando hashes bcrypt.
-- -----------------------------------------------------------------------------
INSERT INTO "usuarios" ("apelido", "primeiro_nome", "sobrenome", "email", "senha_hash", "bio") VALUES
  ('cinefilo_wk',  'Wendell',  'Kenneddy', 'wendell@example.com', '$2b$12$abcdefghijklmnopqrstuv01', 'Maratonando clássicos.'), -- 1
  ('jv_filmes',    'Jeremias', 'Victor',   'jeremias@example.com', '$2b$12$abcdefghijklmnopqrstuv02', 'Fã de ficção científica.'), -- 2
  ('ana.reviews',  'Ana',      'Souza',    'ana@example.com',      '$2b$12$abcdefghijklmnopqrstuv03', NULL),                       -- 3
  ('bruno_movies', 'Bruno',    'Lima',     'bruno@example.com',    '$2b$12$abcdefghijklmnopqrstuv04', 'Crítico amador.'),          -- 4
  ('carla_c',      'Carla',    'Mendes',   'carla@example.com',    '$2b$12$abcdefghijklmnopqrstuv05', 'Listas temáticas.'),        -- 5
  ('diego.f',      'Diego',    'Ferreira', 'diego@example.com',    '$2b$12$abcdefghijklmnopqrstuv06', NULL);                       -- 6

-- -----------------------------------------------------------------------------
-- usuarios_seguidores (associativa) - >= 10 tuplas
-- seguido <> seguidor; sem follow duplicado
-- -----------------------------------------------------------------------------
INSERT INTO "usuarios_seguidores" ("usuario_seguido", "usuario_seguidor") VALUES
  (1, 2),
  (1, 3),
  (1, 4),
  (2, 1),
  (2, 3),
  (3, 1),
  (3, 5),
  (4, 1),
  (4, 5),
  (5, 6),
  (6, 5),
  (2, 6);

-- -----------------------------------------------------------------------------
-- personalidades (tabela principal) - nacionalidade -> paises
-- -----------------------------------------------------------------------------
INSERT INTO "personalidades" ("nome", "nacionalidade", "bio") VALUES
  ('Christopher Nolan',  'GBR', 'Diretor e roteirista britânico-americano.'),     -- 1
  ('Cillian Murphy',     'IRL', 'Ator irlandês, recorrente em filmes de Nolan.'), -- 2
  ('Quentin Tarantino',  'USA', 'Diretor e roteirista; às vezes atua.'),          -- 3
  ('Hayao Miyazaki',     'JPN', 'Diretor e animador do Studio Ghibli.'),          -- 4
  ('Fernanda Montenegro','BRA', 'Atriz brasileira premiada.'),                    -- 5
  ('Walter Salles',      'BRA', 'Diretor brasileiro.'),                           -- 6
  ('Peter Jackson',      'NZL', 'Diretor neozelandês.'),                          -- 7
  ('Marion Cotillard',   'FRA', 'Atriz francesa.'),                               -- 8
  ('Lana Wachowski',     'USA', 'Cineasta estadunidense; co-dirigiu Matrix.'),       -- 9
  ('Lilly Wachowski',    'USA', 'Cineasta estadunidense; co-dirigiu Matrix.'),       -- 10
  ('Joel Coen',          'USA', 'Cineasta estadunidense; dupla com Ethan Coen.'),    -- 11
  ('Ethan Coen',         'USA', 'Cineasta estadunidense; dupla com Joel Coen.'),     -- 12
  ('Keanu Reeves',       'USA', 'Ator; protagonista de Matrix.'),                    -- 13
  ('John Travolta',      'USA', 'Ator estadunidense.'),                              -- 14
  ('Samuel L. Jackson',  'USA', 'Ator estadunidense.'),                              -- 15
  ('Tommy Lee Jones',    'USA', 'Ator estadunidense.'),                              -- 16
  ('Javier Bardem',      'ESP', 'Ator espanhol.');                                   -- 17

-- -----------------------------------------------------------------------------
-- filmes (tabela principal) - idioma_original -> idiomas
-- -----------------------------------------------------------------------------
INSERT INTO "filmes" ("titulo", "sinopse", "idioma_original", "duracao_minutos", "banner_url", "ano_lancamento") VALUES
  ('A Origem',              'Um ladrão que invade sonhos é incumbido de plantar uma ideia.', 'en',    148, 'https://cdn.example/inception.jpg',     2010), -- 1
  ('Oppenheimer',           'A história do pai da bomba atômica.',                           'en',    180, 'https://cdn.example/oppenheimer.jpg',   2023), -- 2
  ('Pulp Fiction',          'Histórias entrelaçadas do submundo de Los Angeles.',            'en',    154, 'https://cdn.example/pulpfiction.jpg',   1994), -- 3
  ('A Viagem de Chihiro',   'Uma garota presa num mundo espiritual.',                        'ja',    125, 'https://cdn.example/chihiro.jpg',       2001), -- 4
  ('Central do Brasil',     'Uma ex-professora ajuda um menino a procurar o pai.',           'pt-BR', 110, 'https://cdn.example/central.jpg',       1998), -- 5
  ('O Senhor dos Anéis: A Sociedade do Anel', 'Um hobbit parte numa jornada para destruir um anel.', 'en', 178, 'https://cdn.example/lotr.jpg', 2001), -- 6
  ('Diários de Motocicleta','A viagem que transformou o jovem Che Guevara.',                 'es',    126, 'https://cdn.example/diarios.jpg',       2004), -- 7
  ('Matrix',                'Um hacker descobre a verdade sobre sua realidade simulada.',    'en',    136, 'https://cdn.example/matrix.jpg',        1999), -- 8
  ('Onde os Fracos Não Têm Vez','Um caçador encontra dinheiro de um negócio de drogas e vira alvo.', 'en', 122, 'https://cdn.example/nocountry.jpg', 2007); -- 9

-- -----------------------------------------------------------------------------
-- filmes_generos (associativa) - >= 10 tuplas
-- -----------------------------------------------------------------------------
INSERT INTO "filmes_generos" ("filme_id", "genero_id") VALUES
  (1, 2), (1, 6),          -- A Origem: FicCient, Suspense
  (2, 1), (2, 6),          -- Oppenheimer: Drama, Suspense
  (3, 3), (3, 1),          -- Pulp Fiction: Crime, Drama
  (4, 4), (4, 5),          -- Chihiro: Animação, Aventura
  (5, 1),                  -- Central do Brasil: Drama
  (6, 5), (6, 1),          -- LOTR: Aventura, Drama
  (7, 1), (7, 5),          -- Diários: Drama, Aventura
  (8, 2), (8, 5),          -- Matrix: FicCient, Aventura
  (9, 3), (9, 6);          -- Onde os Fracos Não Têm Vez: Crime, Suspense

-- -----------------------------------------------------------------------------
-- filmes_diretores (associativa) - >= 10 tuplas
-- Inclui filme com mais de um diretor (filme 8 - Matrix, co-dirigido pelas Wachowski)
-- -----------------------------------------------------------------------------
INSERT INTO "filmes_diretores" ("filme_id", "diretor_id") VALUES
  (1, 1),   -- A Origem - Nolan
  (2, 1),   -- Oppenheimer - Nolan
  (3, 3),   -- Pulp Fiction - Tarantino
  (4, 4),   -- Chihiro - Miyazaki
  (5, 6),   -- Central do Brasil - Walter Salles
  (6, 7),   -- LOTR - Peter Jackson
  (7, 6),   -- Diários - Walter Salles
  (8, 9),   -- Matrix - Lana Wachowski
  (8, 10),  -- Matrix - Lilly Wachowski (co-direção real)
  (9, 11),  -- Onde os Fracos Não Têm Vez - Joel Coen
  (9, 12);  -- Onde os Fracos Não Têm Vez - Ethan Coen (co-direção real)

-- -----------------------------------------------------------------------------
-- filmes_atores (associativa) - >= 10 tuplas
-- personagem faz parte da PK.
-- Tarantino (3) aparece como diretor E ator (filme 3 - Pulp Fiction).
-- -----------------------------------------------------------------------------
INSERT INTO "filmes_atores" ("filme_id", "ator_id", "personagem") VALUES
  (1, 2,  'Robert Fischer'),          -- Cillian Murphy em A Origem
  (1, 8,  'Mal'),                     -- Marion Cotillard em A Origem
  (2, 2,  'J. Robert Oppenheimer'),   -- Cillian Murphy em Oppenheimer
  (2, 8,  'Kitty Oppenheimer'),       -- Marion Cotillard em Oppenheimer
  (3, 3,  'Jimmie Dimmick'),          -- Tarantino atuando em Pulp Fiction
  (3, 14, 'Vincent Vega'),            -- John Travolta em Pulp Fiction
  (3, 15, 'Jules Winnfield'),         -- Samuel L. Jackson em Pulp Fiction
  (5, 5,  'Dora'),                    -- Fernanda Montenegro em Central do Brasil
  (8, 13, 'Neo'),                     -- Keanu Reeves em Matrix
  (9, 16, 'Xerife Ed Tom Bell'),      -- Tommy Lee Jones em Onde os Fracos Não Têm Vez
  (9, 15, 'Anton Chigurh');           -- Javier Bardem em Onde os Fracos Não Têm Vez

-- -----------------------------------------------------------------------------
-- listas (tabela principal) - usuario_id -> usuarios
-- -----------------------------------------------------------------------------
INSERT INTO "listas" ("usuario_id", "titulo", "descricao", "publica") VALUES
  (1, 'Melhores do Nolan',        'Coletânea pessoal.',                 DEFAULT), -- 1
  (2, 'Ficção que mexe a cabeça', NULL,                                 DEFAULT), -- 2
  (3, 'Cinema brasileiro',        'Clássicos nacionais.',               DEFAULT), -- 3
  (4, 'Para rever no inverno',    'Lista privada.',                     FALSE),   -- 4
  (5, 'Animações atemporais',     'Sem idade para assistir.',           DEFAULT), -- 5
  (1, 'Watchlist secreta',        'Só pra mim.',                        FALSE);   -- 6

-- -----------------------------------------------------------------------------
-- listas_filmes (associativa) - >= 10 tuplas
-- posicao unica por lista; filme nao se repete na mesma lista
-- -----------------------------------------------------------------------------
INSERT INTO "listas_filmes" ("lista_id", "filme_id", "posicao") VALUES
  (1, 1, 1), (1, 2, 2),             -- Melhores do Nolan
  (2, 1, 1), (2, 4, 2), (2, 3, 3),  -- Ficção que mexe a cabeça
  (3, 5, 1), (3, 7, 2),             -- Cinema brasileiro
  (4, 6, 1), (4, 3, 2),             -- Para rever no inverno
  (5, 4, 1),                        -- Animações atemporais
  (6, 2, 1), (6, 6, 2);             -- Watchlist secreta

-- -----------------------------------------------------------------------------
-- watchlist (associativa) - >= 10 tuplas
-- filme unico por usuario
-- -----------------------------------------------------------------------------
INSERT INTO "watchlist" ("usuario_id", "filme_id") VALUES
  (1, 3), (1, 7),
  (2, 4), (2, 5),
  (3, 1), (3, 6),
  (4, 2),
  (5, 1), (5, 3),
  (6, 4), (6, 7);

-- -----------------------------------------------------------------------------
-- visualizacoes (tabela de fato) - >= 10 tuplas
-- nota opcional (NULL = sem nota); escala 0,5..5,0 passo 0,5.
-- Inclui rewatch: mesmo usuario+filme mais de uma vez.
-- -----------------------------------------------------------------------------
INSERT INTO "visualizacoes" ("usuario_id", "filme_id", "nota", "curtido", "visto_em") VALUES
  (1, 1, 5.0, TRUE,  '2024-01-15 21:00:00-03'),   -- 1
  (1, 2, 4.5, TRUE,  '2024-03-02 19:30:00-03'),   -- 2
  (1, 1, 4.5, TRUE,  '2025-02-10 22:00:00-03'),   -- 3  rewatch de A Origem
  (2, 1, 5.0, TRUE,  '2024-02-20 20:00:00-03'),   -- 4
  (2, 4, 5.0, TRUE,  '2024-05-11 16:00:00-03'),   -- 5
  (3, 5, 4.0, TRUE,  '2024-06-01 18:00:00-03'),   -- 6
  (3, 7, 3.5, FALSE, '2024-07-09 21:15:00-03'),   -- 7
  (4, 3, 4.5, TRUE,  '2024-08-21 23:00:00-03'),   -- 8
  (4, 6, NULL, FALSE,'2024-09-30 17:00:00-03'),   -- 9  assistido sem nota
  (5, 4, 5.0, TRUE,  '2024-10-12 14:00:00-03'),   -- 10
  (5, 1, 4.0, FALSE, '2024-11-03 20:30:00-03'),   -- 11
  (6, 2, 4.5, TRUE,  '2025-01-05 21:45:00-03');   -- 12

-- -----------------------------------------------------------------------------
-- avaliacoes (tabela de fato) - >= 10 tuplas
-- review vinculada a uma visualizacao; uma sessao pode ter +1 review.
-- -----------------------------------------------------------------------------
INSERT INTO "avaliacoes" ("visualizacao_id", "review", "avaliado_em") VALUES
  (1,  'Obra-prima sobre sonhos. Final ambíguo perfeito.',          '2024-01-15 23:10:00-03'),
  (1,  'Revisitando minha resenha: ainda acho o melhor do Nolan.',  '2024-01-20 10:00:00-03'),  -- 2ª review da MESMA sessão
  (2,  'Cinebiografia tensa, atuação impecável.',                   '2024-03-03 09:00:00-03'),
  (3,  'No rewatch percebi detalhes que passei batido.',            '2025-02-11 08:30:00-03'),
  (4,  'Entendi o hype. Roteiro impecável.',                        '2024-02-21 12:00:00-03'),
  (5,  'Ghibli no auge. Visualmente deslumbrante.',                 '2024-05-12 11:00:00-03'),
  (6,  'Fernanda Montenegro entrega uma atuação histórica.',        '2024-06-02 19:00:00-03'),
  (7,  'Bonito, mas ritmo arrastado em alguns trechos.',            '2024-07-10 08:00:00-03'),
  (8,  'Diálogos afiados, montagem genial.',                        '2024-08-22 09:30:00-03'),
  (10, 'Assisti com minha filha, encantou todo mundo.',             '2024-10-12 22:00:00-03'),
  (12, 'Segunda metade prende demais.',                             '2025-01-06 08:00:00-03');
