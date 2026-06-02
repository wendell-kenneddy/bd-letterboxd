-- Seed dos países
INSERT INTO "paises" ("codigo", "nome") VALUES
  ('USA', 'Estados Unidos'),
  ('BRA', 'Brasil'),
  ('GBR', 'Reino Unido'),
  ('FRA', 'França'),
  ('JPN', 'Japão'),
  ('NZL', 'Nova Zelândia'),
  ('ESP', 'Espanha'),
  ('IRL', 'Irlanda');

-- Seed dos idiomas
INSERT INTO "idiomas" ("codigo", "nome") VALUES
  ('en', 'Inglês'),
  ('pt-BR', 'Português (Brasil)'),
  ('fr', 'Francês'),
  ('ja', 'Japonês'),
  ('es', 'Espanhol');

-- Seed dos gêneros cinematográficos
INSERT INTO "generos" ("nome") VALUES
  ('Drama'),       
  ('Ficção Científica'),
  ('Crime'),
  ('Animação'),
  ('Aventura'),
  ('Suspense'),
  ('Romance');

-- Seed dos usuários. O campo de senha_hash "imita" um hash gerado pela biblioteca BCrypt.
INSERT INTO "usuarios" ("apelido", "primeiro_nome", "sobrenome", "email", "senha_hash", "bio") VALUES
  ('cinefilo_wk',  'Wendell',  'Kenneddy', 'wendell@example.com', '$2b$12$abcdefghijklmnopqrstuv01', 'Maratonando clássicos.'),
  ('jv_filmes',    'Jeremias', 'Victor',   'jeremias@example.com', '$2b$12$abcdefghijklmnopqrstuv02', 'Fã de ficção científica.'),
  ('ana.reviews',  'Ana',      'Souza',    'ana@example.com',      '$2b$12$abcdefghijklmnopqrstuv03', NULL),                      
  ('bruno_movies', 'Bruno',    'Lima',     'bruno@example.com',    '$2b$12$abcdefghijklmnopqrstuv04', 'Crítico amador.'),         
  ('carla_c',      'Carla',    'Mendes',   'carla@example.com',    '$2b$12$abcdefghijklmnopqrstuv05', 'Listas temáticas.'),       
  ('diego.f',      'Diego',    'Ferreira', 'diego@example.com',    '$2b$12$abcdefghijklmnopqrstuv06', NULL);                      

-- Seed dos relacionamentos de seguir e ser seguido
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

-- Seed de personalidades (atores e diretores, ou ambos)
INSERT INTO "personalidades" ("nome", "nacionalidade", "bio") VALUES
  ('Christopher Nolan',  'GBR', 'Diretor e roteirista britânico-americano.'),    
  ('Cillian Murphy',     'IRL', 'Ator irlandês, recorrente em filmes de Nolan.'),
  ('Quentin Tarantino',  'USA', 'Diretor e roteirista; às vezes atua.'),         
  ('Hayao Miyazaki',     'JPN', 'Diretor e animador do Studio Ghibli.'),         
  ('Fernanda Montenegro','BRA', 'Atriz brasileira premiada.'),                   
  ('Walter Salles',      'BRA', 'Diretor brasileiro.'),                          
  ('Peter Jackson',      'NZL', 'Diretor neozelandês.'),                         
  ('Marion Cotillard',   'FRA', 'Atriz francesa.'),                              
  ('Lana Wachowski',     'USA', 'Cineasta estadunidense; co-dirigiu Matrix.'),       
  ('Lilly Wachowski',    'USA', 'Cineasta estadunidense; co-dirigiu Matrix.'),
  ('Joel Coen',          'USA', 'Cineasta estadunidense; dupla com Ethan Coen.'),
  ('Ethan Coen',         'USA', 'Cineasta estadunidense; dupla com Joel Coen.'),
  ('Keanu Reeves',       'USA', 'Ator; protagonista de Matrix.'),
  ('John Travolta',      'USA', 'Ator estadunidense.'),
  ('Samuel L. Jackson',  'USA', 'Ator estadunidense.'),
  ('Tommy Lee Jones',    'USA', 'Ator estadunidense.'),
  ('Javier Bardem',      'ESP', 'Ator espanhol.');

-- Seed de filmes
INSERT INTO "filmes" ("titulo", "sinopse", "idioma_original", "duracao_minutos", "poster_url", "ano_lancamento") VALUES
  ('A Origem',              'Um ladrão que invade sonhos é incumbido de plantar uma ideia.', 'en',    148, 'https://cdn.example/inception.jpg',     2010), 
  ('Oppenheimer',           'A história do pai da bomba atômica.',                           'en',    180, 'https://cdn.example/oppenheimer.jpg',   2023), 
  ('Pulp Fiction',          'Histórias entrelaçadas do submundo de Los Angeles.',            'en',    154, 'https://cdn.example/pulpfiction.jpg',   1994), 
  ('A Viagem de Chihiro',   'Uma garota presa num mundo espiritual.',                        'ja',    125, 'https://cdn.example/chihiro.jpg',       2001), 
  ('Central do Brasil',     'Uma ex-professora ajuda um menino a procurar o pai.',           'pt-BR', 110, 'https://cdn.example/central.jpg',       1998), 
  ('O Senhor dos Anéis: A Sociedade do Anel', 'Um hobbit parte numa jornada para destruir um anel.', 'en', 178, 'https://cdn.example/lotr.jpg', 2001), 
  ('Diários de Motocicleta','A viagem que transformou o jovem Che Guevara.',                 'es',    126, 'https://cdn.example/diarios.jpg',       2004), 
  ('Matrix',                'Um hacker descobre a verdade sobre sua realidade simulada.',    'en',    136, 'https://cdn.example/matrix.jpg',        1999), 
  ('Onde os Fracos Não Têm Vez','Um caçador encontra dinheiro de um negócio de drogas e vira alvo.', 'en', 122, 'https://cdn.example/nocountry.jpg', 2007); 

-- Seed de gêneros de cada filme
INSERT INTO "filmes_generos" ("filme_id", "genero_id") VALUES
  (1, 2), (1, 6),           
  (2, 1), (2, 6),          
  (3, 3), (3, 1),          
  (4, 4), (4, 5),           
  (5, 1),                  
  (6, 5), (6, 1),           
  (7, 1), (7, 5),           
  (8, 2), (8, 5),          
  (9, 3), (9, 6);          

-- Seed de diretor(es) de cada filme
INSERT INTO "filmes_diretores" ("filme_id", "diretor_id") VALUES
  (1, 1),
  (2, 1),
  (3, 3),
  (4, 4),
  (5, 6),
  (6, 7),
  (7, 6),
  (8, 9),
  (8, 10),
  (9, 11),
  (9, 12);

-- Seed de atores de cada filme
INSERT INTO "filmes_atores" ("filme_id", "ator_id", "personagem") VALUES
  (1, 2,  'Robert Fischer'),          
  (1, 8,  'Mal'),                    
  (2, 2,  'J. Robert Oppenheimer'),
  (3, 3,  'Jimmie Dimmick'),          
  (3, 14, 'Vincent Vega'),            
  (3, 15, 'Jules Winnfield'),         
  (5, 5,  'Dora'),                    
  (8, 13, 'Neo'),                     
  (9, 16, 'Xerife Ed Tom Bell'),      
  (9, 15, 'Anton Chigurh');           

-- Seed de listas temáticas de filmes
INSERT INTO "listas" ("usuario_id", "titulo", "descricao", "publica") VALUES
  (1, 'Melhores do Nolan',        'Coletânea pessoal.',                 DEFAULT), 
  (2, 'Ficção que mexe a cabeça', NULL,                                 DEFAULT),
  (3, 'Cinema brasileiro',        'Clássicos nacionais.',               DEFAULT),
  (4, 'Para rever no inverno',    'Lista privada.',                     FALSE),
  (5, 'Animações atemporais',     'Sem idade para assistir.',           DEFAULT), 
  (1, 'Watchlist secreta',        'Só pra mim.',                        FALSE);

-- Seed de filmes de cada lista
INSERT INTO "listas_filmes" ("lista_id", "filme_id", "posicao") VALUES
  (1, 1, 1), (1, 2, 2),
  (2, 1, 1), (2, 4, 2), (2, 3, 3), 
  (3, 5, 1), (3, 7, 2),
  (4, 6, 1), (4, 3, 2),
  (5, 4, 1),
  (6, 2, 1), (6, 6, 2);

-- Seed de filmes que um usuário deseja assisti
INSERT INTO "watchlist" ("usuario_id", "filme_id") VALUES
  (1, 3), (1, 7),
  (2, 4), (2, 5),
  (3, 1), (3, 6),
  (4, 2),
  (5, 1), (5, 3),
  (6, 4), (6, 7);

-- Seed de filmes assistidos por um usuário
INSERT INTO "visualizacoes" ("usuario_id", "filme_id", "nota", "curtido", "visto_em") VALUES
  (1, 1, 5.0, TRUE,  '2024-01-15 21:00:00-03'),   
  (1, 2, 4.5, TRUE,  '2024-03-02 19:30:00-03'),   
  (1, 1, 4.5, TRUE,  '2025-02-10 22:00:00-03'),   
  (2, 1, 5.0, TRUE,  '2024-02-20 20:00:00-03'),   
  (2, 4, 5.0, TRUE,  '2024-05-11 16:00:00-03'), 
  (3, 5, 4.0, TRUE,  '2024-06-01 18:00:00-03'), 
  (3, 7, 3.5, FALSE, '2024-07-09 21:15:00-03'), 
  (4, 3, 4.5, TRUE,  '2024-08-21 23:00:00-03'), 
  (4, 6, NULL, FALSE,'2024-09-30 17:00:00-03'),
  (5, 4, 5.0, TRUE,  '2024-10-12 14:00:00-03'),   
  (5, 1, 4.0, FALSE, '2024-11-03 20:30:00-03'),   
  (6, 2, 4.5, TRUE,  '2025-01-05 21:45:00-03');   

-- Seed de reviews de filmes assistidos
INSERT INTO "avaliacoes" ("visualizacao_id", "review", "avaliado_em") VALUES
  (1,  'Obra-prima sobre sonhos. Final ambíguo perfeito.',          '2024-01-15 23:10:00-03'),
  (1,  'Revisitando minha resenha: ainda acho o melhor do Nolan.',  '2024-01-20 10:00:00-03'),
  (2,  'Cinebiografia tensa, atuação impecável.',                   '2024-03-03 09:00:00-03'),
  (3,  'No rewatch percebi detalhes que passei batido.',            '2025-02-11 08:30:00-03'),
  (4,  'Entendi o hype. Roteiro impecável.',                        '2024-02-21 12:00:00-03'),
  (5,  'Ghibli no auge. Visualmente deslumbrante.',                 '2024-05-12 11:00:00-03'),
  (6,  'Fernanda Montenegro entrega uma atuação histórica.',        '2024-06-02 19:00:00-03'),
  (7,  'Bonito, mas ritmo arrastado em alguns trechos.',            '2024-07-10 08:00:00-03'),
  (8,  'Diálogos afiados, montagem genial.',                        '2024-08-22 09:30:00-03'),
  (10, 'Assisti com minha filha, encantou todo mundo.',             '2024-10-12 22:00:00-03'),
  (12, 'Segunda metade prende demais.',                             '2025-01-06 08:00:00-03');
