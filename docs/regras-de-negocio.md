# Regras de Negócio e Casos de Uso

Este documento descreve o **mini-mundo**, as **regras de negócio**, as **restrições de
integridade** e os **casos de uso** do sistema, derivados diretamente do schema definido em
[V1__init_schema.sql](../scripts/migrations/V1__init_schema.sql).

O sistema é uma rede social de catalogação de filmes inspirada no **Letterboxd**, na qual
usuários seguem outros usuários, montam listas, mantêm uma watchlist, registram filmes
assistidos (com nota e curtida) e, opcionalmente, escrevem reviews sobre cada sessão.

---

## 1. Descrição do mini-mundo

### 1.1. Quem são os usuários

- **Usuários finais (cinéfilos):** pessoas que se cadastram para registrar filmes que viram,
  atribuir notas, curtir, escrever reviews, organizar listas e seguir outros usuários.
- **Curadores de catálogo (administração):** responsáveis por manter o acervo de filmes,
  personalidades (atores/diretores), gêneros, países e idiomas. No schema atual não há uma
  entidade distinta de administrador; trata-se de um papel operacional sobre as tabelas de
  catálogo.

### 1.2. Que dados são armazenados

| Domínio | Tabelas | O que representa |
|---|---|---|
| Identidade e social | `usuarios`, `usuarios_seguidores` | Contas e o grafo de "quem segue quem". |
| Catálogo de filmes | `filmes`, `generos`, `filmes_generos`, `idiomas` | Obras, seus gêneros e idioma original. |
| Pessoas do cinema | `personalidades`, `paises`, `filmes_diretores`, `filmes_atores` | Atores e diretores, sua nacionalidade e participação nas obras. |
| Curadoria do usuário | `listas`, `listas_filmes`, `watchlist` | Listas ordenadas e a fila de "quero assistir". |
| Atividade | `visualizacoes`, `avaliacoes` | Sessões assistidas (com nota/curtida) e reviews textuais. |

---

## 2. Entidades e suas regras

### 2.1. `usuarios`
- Cada usuário possui um `apelido` **único** e obrigatório, além de `primeiro_nome`,
  `sobrenome` e `senha_hash` obrigatórios.
- A senha é armazenada **apenas como hash** (`senha_hash TEXT`); o sistema nunca persiste
  a senha em texto puro.
- `bio` é opcional.
- `data_cadastro` e `atualizado_em` são preenchidos automaticamente com o instante atual
  (`NOW()`).

### 2.2. `usuarios_seguidores` (relacionamento de seguir)
- Modela o auto-relacionamento N:N "usuário segue usuário".
- A chave primária é o par (`usuario_seguido`, `usuario_seguidor`), logo **um usuário só
  pode seguir outro uma única vez** (não há follow duplicado).
- `CHECK (usuario_seguido <> usuario_seguidor)`: **um usuário não pode seguir a si mesmo**.
- O relacionamento é **direcionado**: A seguir B não implica B seguir A.

### 2.3. `paises` e `idiomas` (tabelas de domínio)
- `paises`: `codigo CHAR(3)` como PK (padrão ISO 3166-1 alfa-3, ex.: `BRA`, `USA`) e `nome`
  único.
- `idiomas`: `codigo VARCHAR(5)` como PK (padrão BCP 47, ex.: `pt`, `pt-BR`, `en`) e `nome`
  único.
- São tabelas de referência: alimentam a nacionalidade das personalidades e o idioma
  original dos filmes.

### 2.4. `personalidades`
- Representa qualquer pessoa do cinema (ator e/ou diretor) de forma unificada.
- `nome`, `nacionalidade` (FK para `paises`) e `bio` são obrigatórios.
- **Uma mesma personalidade pode atuar como ator e como diretor** — inclusive no mesmo
  filme — pois ela é referenciada tanto por `filmes_diretores` quanto por `filmes_atores`.

### 2.5. `generos` e `filmes_generos`
- `generos.nome` é único.
- `filmes_generos` associa filmes a gêneros em N:N; a PK (`filme_id`, `genero_id`) impede
  duplicar o mesmo gênero num filme.

### 2.6. `filmes`
- Atributos obrigatórios: `titulo`, `sinopse`, `idioma_original` (FK), `duracao_minutos`,
  `banner_url`, `ano_lancamento`.
- O idioma original deve existir em `idiomas`.

### 2.7. `filmes_diretores` e `filmes_atores`
- `filmes_diretores`: N:N entre filmes e personalidades, PK (`filme_id`, `diretor_id`).
  Um filme pode ter **mais de um diretor** e um diretor pode dirigir vários filmes.
- `filmes_atores`: PK (`ator_id`, `filme_id`, `personagem`) com `personagem` obrigatório.
  A presença do papel na chave permite que **o mesmo ator interprete mais de um personagem
  no mesmo filme** (cada papel é uma tupla distinta), mas impede registrar o mesmo ator com
  o mesmo personagem no mesmo filme duas vezes.

### 2.8. `listas` e `listas_filmes`
- Cada lista pertence a um usuário (`usuario_id`, FK), tem `titulo` obrigatório, `descricao`
  opcional e flag `publica` obrigatória (controla visibilidade).
- `listas_filmes` é o conteúdo ordenado da lista:
  - PK (`filme_id`, `lista_id`): **um filme não se repete dentro da mesma lista**.
  - `UNIQUE (lista_id, posicao)` **DEFERRABLE**: as posições são únicas por lista, mas a
    restrição pode ser checada no fim da transação, permitindo **reordenar/inserir itens**
    sem violar a unicidade durante operações intermediárias.

### 2.9. `watchlist`
- Fila de "quero assistir" por usuário; PK (`usuario_id`, `filme_id`) garante que **o mesmo
  filme aparece no máximo uma vez** na watchlist de um usuário.

### 2.10. `visualizacoes` (sessões assistidas)
- Registra que um usuário assistiu a um filme (`usuario_id`, `filme_id`).
- `nota NUMERIC(2,1)` é **opcional** e, quando presente, deve respeitar
  `CHECK (nota > 0 AND nota <= 5 AND MOD(nota, 0.5) = 0)` — isto é, valores de **0,5 a 5,0
  em incrementos de 0,5**. Nota 0 não é permitida (ausência de nota = `NULL`).
- `curtido BOOLEAN` tem default `FALSE`.
- `visto_em` registra o instante da sessão.
- **Não há restrição de unicidade** sobre (`usuario_id`, `filme_id`): intencionalmente o
  mesmo usuário pode registrar **múltiplas sessões** do mesmo filme (rewatches).

### 2.11. `avaliacoes` (reviews)
- Cada review referencia uma **sessão** (`visualizacao_id`, FK) e tem `review` (texto
  obrigatório), `avaliado_em` e `atualizado_em`.
- Como não há `UNIQUE` em `visualizacao_id`, **uma mesma sessão pode ter mais de uma
  review** — comportamento descrito intencionalmente no README.
- Toda review está vinculada a uma sessão; **não existe review "solta"** sem visualização.

---

## 3. Restrições de integridade (resumo)

### 3.1. Integridade de entidade (chaves primárias)
Todas as tabelas possuem PK. Tabelas associativas usam chaves compostas que definem a
granularidade do relacionamento (ver seção 2).

### 3.2. Integridade referencial (chaves estrangeiras)
- `usuarios_seguidores` → `usuarios` (duas vezes).
- `personalidades.nacionalidade` → `paises`.
- `filmes.idioma_original` → `idiomas`.
- `filmes_diretores`, `filmes_atores`, `filmes_generos`, `listas_filmes`, `watchlist`,
  `visualizacoes` → `filmes` / `personalidades` / `generos` conforme o caso.
- `listas.usuario_id`, `watchlist.usuario_id`, `visualizacoes.usuario_id` → `usuarios`.
- `avaliacoes.visualizacao_id` → `visualizacoes`.

### 3.3. Restrições de domínio e semântica (CHECK / UNIQUE / NOT NULL / DEFAULT)
| Restrição | Tabela | Regra de negócio garantida |
|---|---|---|
| `UNIQUE apelido` | `usuarios` | Apelido é identificador público único. |
| `CHECK (seguido <> seguidor)` | `usuarios_seguidores` | Ninguém segue a si mesmo. |
| `UNIQUE nome` | `paises`, `idiomas`, `generos` | Nomes de domínio não se repetem. |
| `CHECK` da `nota` | `visualizacoes` | Nota entre 0,5 e 5,0 em passos de 0,5. |
| `DEFAULT FALSE` em `curtido` | `visualizacoes` | Sessão não curtida por padrão. |
| `UNIQUE (lista_id, posicao)` deferrable | `listas_filmes` | Ordenação consistente, reordenável em transação. |
| Defaults `NOW()` | várias | Timestamps de auditoria automáticos. |

### 3.4. Limitações conhecidas / fora do escopo do schema
Estas regras **não** são impostas pelo banco e dependem da aplicação:
- A coerência entre `visualizacoes.usuario_id` e o autor da `avaliacao` não é forçada (a
  review herda o dono pela sessão; não há coluna de autor separada).
- A visibilidade de listas privadas (`publica = FALSE`) é decisão da camada de aplicação.
- Não há FK de `visualizacoes`/`watchlist` para garantir que o usuário não tenha sido
  removido em cascata (sem `ON DELETE` definido).

---

## 4. Casos de uso válidos

### CU-01 — Cadastrar usuário
**Ator:** visitante. **Fluxo:** informa apelido, nome, sobrenome e senha → o sistema grava
`senha_hash` e timestamps. **Regra:** apelido deve ser inédito.

### CU-02 — Seguir / deixar de seguir usuário
**Ator:** usuário autenticado. Insere/remove uma tupla em `usuarios_seguidores`.
**Regras:** não pode seguir a si mesmo; não pode seguir o mesmo usuário duas vezes.

### CU-03 — Manter catálogo de filmes
**Ator:** curador. Cadastra filme com idioma original válido, associa gêneros
(`filmes_generos`), diretores (`filmes_diretores`) e elenco com papéis (`filmes_atores`).
**Regras:** idioma/gênero/personalidade devem pré-existir; um ator pode ter vários papéis;
uma personalidade pode ser diretor e ator do mesmo filme.

### CU-04 — Criar e organizar listas
**Ator:** usuário. Cria lista (pública ou privada) e adiciona filmes em posições ordenadas.
**Regras:** sem filme duplicado na lista; posições únicas por lista (reordenação suportada
pela restrição deferrable).

### CU-05 — Gerenciar watchlist
**Ator:** usuário. Adiciona/remove filmes da própria watchlist. **Regra:** cada filme no
máximo uma vez por usuário.

### CU-06 — Registrar filme assistido
**Ator:** usuário. Cria uma `visualizacao` com `visto_em`, opcionalmente `nota` e `curtido`.
**Regras:** nota dentro da escala 0,5–5,0; múltiplas sessões do mesmo filme são permitidas
(rewatch).

### CU-07 — Escrever review
**Ator:** usuário. Cria uma `avaliacao` vinculada a uma sessão existente. **Regras:** texto
obrigatório; uma sessão pode receber mais de uma review.

### CU-08 — Consultar feed / descoberta
**Ator:** usuário. Consultas de leitura: filmes mais bem avaliados, listas públicas,
atividade de quem o usuário segue, médias de nota por filme/gênero, etc. (base para as
consultas exigidas no projeto).

---

## 5. Rastreabilidade Regra → Schema

| Regra de negócio | Mecanismo no schema |
|---|---|
| Apelido único | `usuarios.apelido UNIQUE NOT NULL` |
| Não seguir a si mesmo | `CHECK (usuario_seguido <> usuario_seguidor)` |
| Follow não duplicado | PK composta em `usuarios_seguidores` |
| Ator com múltiplos papéis | `personagem` na PK de `filmes_atores` |
| Diretor que também atua | `personalidades` referenciada por ambas as associativas |
| Nota válida | `CHECK` em `visualizacoes.nota` |
| Rewatch | Ausência de UNIQUE em `visualizacoes(usuario_id, filme_id)` |
| Múltiplas reviews por sessão | Ausência de UNIQUE em `avaliacoes.visualizacao_id` |
| Filme único por lista / posição única | PK + `UNIQUE(lista_id, posicao)` deferrable |
| Filme único na watchlist | PK `(usuario_id, filme_id)` |
