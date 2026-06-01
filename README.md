# Projeto de BD 2026.1

Este repositório contém os artefatos do projeto de banco de dados para a disciplina de bancos de dados,
ministrada pelo professor Rodolfo Carneiro.

## Propósito

O schema descreve um projeto similar ao Letterboxd, permitindo com que usuários sigam outros usuários,criem e gerenciem listas de filmes, marquem filmes como assistidos e escrevam reviews opcionalmente. Além disso,dintencionalmente o sistema permite com que usuários escrevam mais de uma review para uma mesma "sessão" (tupla na tabela de filmes assistidos). O schema considera também os casos em que um diretor também pode ser ator num filme, e o caso de um mesmo ator interpretar mais de um papel.

## Requisitos

- O estudante escolhe uma aplicação do mundo real que tenha dados estruturados significativos. A aplicação deve envolver pelo menos 6 entidades distintas, relacionamentos variados e justificar o uso de um banco de dados relacional.
Descrição detalhada do mini-mundo: quem são os usuários, que dados serão armazenados, quais as regras de negócio, restrições de integridade e os principais casos de uso do sistema.
- Modelagem conceitual completa com diagrama ER. Deve incluir entidades, atributos (simples, compostos, multivalorados, derivados), relacionamentos com cardinalidade e participação, e especialização/generalização quando aplicável.
Mapeamento do diagrama ER para o modelo relacional: definição das tabelas, chaves primárias, chaves estrangeiras, normalização mínima até a 3FN e justificativa das decisões de projeto.
- Criação do banco de dados com CREATE TABLE, definição de tipos de dados apropriados, restrições (NOT NULL, UNIQUE, CHECK, DEFAULT), chaves primárias e estrangeiras
- População das tabelas com dados coerentes e representativos. Mínimo de 5 tuplas por tabela principal e 10 tuplas em tabelas de fato/associativas. Os dados devem cobrir casos de borda relevantes para as consultas planejadas.
- Desenvolvimento de no mínimo 10 consultas que demonstrem domínio progressivo: seleções simples, junções (INNER, LEFT, RIGHT), subconsultas correlacionadas e não-correlacionadas, funções de agregação com GROUP BY/HAVING, operadores de conjunto e ao menos uma view.

## Estrutura

- O diretório `scripts/migrations` possui os scripts SQL de criação e evolução do schema;
- O diretório `scripts/queries` possui os scripts SQL de demonstração do schema, como inserts e selects.
- O diretório `docs` possui artefatos que documentam o projeto, como diagramas e relatórios de decisão.

## Discentes

- Wendell Kenneddy
- Jeremias Victor