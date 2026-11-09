/// Esquema do banco de dados SQLite do TripWise (versão 1).
///
/// Cada comando é executado em ordem na criação do banco. As chaves
/// estrangeiras são ativadas em [DatabaseHelper] com `PRAGMA foreign_keys`.
const List<String> schemaV1 = [
  // Usuários do app (Create no cadastro, Read no login, Update no perfil,
  // Delete ao excluir a conta).
  '''
  CREATE TABLE usuarios (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    nome          TEXT    NOT NULL,
    email         TEXT    NOT NULL UNIQUE,
    senha_hash    TEXT    NOT NULL,
    cidade_origem TEXT,
    criado_em     TEXT    NOT NULL DEFAULT CURRENT_TIMESTAMP
  )''',

  // Estilos de viajante (catálogo fixo).
  '''
  CREATE TABLE estilos (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT    NOT NULL UNIQUE
  )''',

  // Relação N:N entre usuários e estilos.
  '''
  CREATE TABLE usuario_estilos (
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    estilo_id  INTEGER NOT NULL REFERENCES estilos(id)  ON DELETE CASCADE,
    PRIMARY KEY (usuario_id, estilo_id)
  )''',

  // Destinos que podem ser recomendados pelo Travel Match.
  '''
  CREATE TABLE destinos (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    nome            TEXT    NOT NULL,
    uf              TEXT    NOT NULL,
    categorias      TEXT    NOT NULL,
    info_transporte TEXT,
    descricao       TEXT,
    destaque        TEXT,
    match_base      INTEGER NOT NULL CHECK (match_base BETWEEN 0 AND 100)
  )''',

  // Custos de referência de cada destino, com a unidade de cálculo.
  '''
  CREATE TABLE custos_destino (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    destino_id INTEGER NOT NULL REFERENCES destinos(id) ON DELETE CASCADE,
    item       TEXT    NOT NULL,
    valor      REAL    NOT NULL CHECK (valor >= 0),
    unidade    TEXT    NOT NULL CHECK (unidade IN ('pessoa', 'noite', 'pessoa_dia'))
  )''',

  // Roteiro sugerido (modelo) de cada destino.
  '''
  CREATE TABLE roteiro_modelo (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    destino_id INTEGER NOT NULL REFERENCES destinos(id) ON DELETE CASCADE,
    dia        INTEGER NOT NULL,
    titulo     TEXT    NOT NULL,
    descricao  TEXT
  )''',

  // Histórico de buscas do Travel Match (respostas do questionário).
  '''
  CREATE TABLE buscas (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    origem     TEXT    NOT NULL,
    orcamento  REAL    NOT NULL,
    dias       INTEGER NOT NULL,
    pessoas    INTEGER NOT NULL,
    tipo       TEXT    NOT NULL,
    prioridade TEXT    NOT NULL,
    criado_em  TEXT    NOT NULL DEFAULT CURRENT_TIMESTAMP
  )''',

  // Viagens planejadas pelo usuário (CRUD completo na tela Minhas Viagens).
  '''
  CREATE TABLE viagens (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id     INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    destino_id     INTEGER NOT NULL REFERENCES destinos(id),
    data_ida       TEXT    NOT NULL,
    data_volta     TEXT    NOT NULL,
    pessoas        INTEGER NOT NULL CHECK (pessoas > 0),
    orcamento      REAL    NOT NULL,
    custo_estimado REAL    NOT NULL,
    match_percent  INTEGER NOT NULL,
    status         TEXT    NOT NULL DEFAULT 'Planejada'
                   CHECK (status IN ('Planejada', 'Confirmada', 'Concluída')),
    observacoes    TEXT,
    criado_em      TEXT    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em  TEXT
  )''',

  // Itens do roteiro de cada viagem (CRUD completo na tela da viagem).
  '''
  CREATE TABLE roteiro_itens (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    viagem_id INTEGER NOT NULL REFERENCES viagens(id) ON DELETE CASCADE,
    dia       INTEGER NOT NULL CHECK (dia > 0),
    titulo    TEXT    NOT NULL,
    descricao TEXT,
    concluido INTEGER NOT NULL DEFAULT 0 CHECK (concluido IN (0, 1))
  )''',

  // Destinos favoritados pelo usuário.
  '''
  CREATE TABLE favoritos (
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    destino_id INTEGER NOT NULL REFERENCES destinos(id) ON DELETE CASCADE,
    criado_em  TEXT    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, destino_id)
  )''',

  'CREATE INDEX idx_viagens_usuario ON viagens(usuario_id)',
  'CREATE INDEX idx_roteiro_viagem ON roteiro_itens(viagem_id, dia)',
];

/// Estilos de viajante oferecidos no cadastro.
const estilosSeed = [
  'Aventureiro',
  'Relax',
  'Cultural',
  'Gastronômico',
  'Econômico',
  'Natureza',
];

/// Dados iniciais dos destinos: (destino, custos, roteiro modelo).
///
/// Custos: passagem ida e volta por pessoa, hospedagem por noite (quarto
/// para até 2 pessoas), alimentação por pessoa/dia e passeios por pessoa.
const destinosSeed = [
  (
    nome: 'Porto Seguro',
    uf: 'BA',
    categorias: 'Praia',
    transporte: 'voo 1h50',
    descricao:
        'Praias tranquilas, clima quente o ano todo e boa estrutura pra quem busca economia sem abrir mão de conforto.',
    destaque: 'Voo direto de Belo Horizonte',
    matchBase: 94,
    custos: [490.0, 187.5, 42.0, 150.0],
    roteiro: [
      ('Chegada + passeio', 'Check-in e fim de tarde na Passarela do Álcool'),
      ('Praia + restaurante', 'Praia de Taperapuã e jantar com frutos do mar'),
      ('Passeio de barco', 'Recife de Fora e pôr do sol no rio Buranhém'),
      ('Atrações locais', 'Centro Histórico e compras no centro'),
      ('Retorno', 'Café da manhã e voo de volta'),
    ],
  ),
  (
    nome: "Arraial d'Ajuda",
    uf: 'BA',
    categorias: 'Praia',
    transporte: 'voo + balsa',
    descricao:
        'Clima mais tranquilo que Porto Seguro, praias de águas calmas e vida noturna mais discreta.',
    destaque: 'Pousadas com bom custo-benefício',
    matchBase: 89,
    custos: [490.0, 160.0, 40.0, 150.0],
    roteiro: [
      ('Chegada + balsa', 'Voo até Porto Seguro e travessia para Arraial'),
      ('Praia de Pitinga', 'Dia de praia e almoço pé na areia'),
      ('Trancoso', 'Quadrado de Trancoso e pôr do sol'),
      ('Centrinho', 'Rua do Mucugê e artesanato local'),
      ('Retorno', 'Balsa e voo de volta'),
    ],
  ),
  (
    nome: 'Salvador',
    uf: 'BA',
    categorias: 'Praia,Cultura',
    transporte: 'voo 1h30',
    descricao:
        'Centro histórico rico, gastronomia forte e boa opção pra combinar praia com cultura na mesma viagem.',
    destaque: 'Gastronomia baiana famosa',
    matchBase: 83,
    custos: [410.0, 162.5, 43.0, 125.0],
    roteiro: [
      ('Chegada + Barra', 'Farol da Barra e pôr do sol'),
      ('Pelourinho', 'Centro Histórico e Elevador Lacerda'),
      ('Praia do Flamengo', 'Dia de praia e acarajé no fim da tarde'),
      ('Rio Vermelho', 'Feirinha e restaurantes locais'),
      ('Retorno', 'Mercado Modelo e voo de volta'),
    ],
  ),
  (
    nome: 'Rio de Janeiro',
    uf: 'RJ',
    categorias: 'Cidade,Praia,Cultura',
    transporte: 'voo 1h',
    descricao:
        'Praias famosas, mirantes e vida cultural intensa em uma cidade grande.',
    destaque: 'Muitos voos diários saindo de BH',
    matchBase: 80,
    custos: [280.0, 220.0, 55.0, 120.0],
    roteiro: [
      ('Chegada + Copacabana', 'Check-in e calçadão no fim de tarde'),
      ('Cristo Redentor', 'Corcovado e Jardim Botânico'),
      ('Pão de Açúcar', 'Bondinho e praia da Urca'),
      ('Centro + Lapa', 'Museu do Amanhã e Escadaria Selarón'),
      ('Retorno', 'Ipanema pela manhã e voo de volta'),
    ],
  ),
  (
    nome: 'Florianópolis',
    uf: 'SC',
    categorias: 'Praia,Natureza',
    transporte: 'voo 1h35',
    descricao:
        'Ilha com mais de 40 praias, trilhas e lagoas, boa para quem gosta de natureza.',
    destaque: 'Trilhas e praias para todos os gostos',
    matchBase: 86,
    custos: [560.0, 210.0, 55.0, 140.0],
    roteiro: [
      ('Chegada + Centro', 'Ponte Hercílio Luz e Mercado Público'),
      ('Lagoa da Conceição', 'Passeio de barco e dunas'),
      ('Praias do norte', 'Jurerê e Santo Antônio de Lisboa'),
      ('Trilha', 'Lagoinha do Leste ou Praia do Gravatá'),
      ('Retorno', 'Café da manhã e voo de volta'),
    ],
  ),
  (
    nome: 'Gramado',
    uf: 'RS',
    categorias: 'Montanha,Cultura',
    transporte: 'voo + 2h de carro',
    descricao:
        'Serra gaúcha com clima ameno, arquitetura europeia e gastronomia de inverno.',
    destaque: 'Clima de serra e chocolates artesanais',
    matchBase: 85,
    custos: [620.0, 230.0, 60.0, 180.0],
    roteiro: [
      ('Chegada', 'Transfer de Porto Alegre e Rua Coberta'),
      ('Canela', 'Catedral de Pedra e Parque do Caracol'),
      ('Lago Negro', 'Passeio de pedalinho e Mini Mundo'),
      ('Vinícolas', 'Tour pelo Vale dos Vinhedos'),
      ('Retorno', 'Compras de chocolate e volta'),
    ],
  ),
  (
    nome: 'Bonito',
    uf: 'MS',
    categorias: 'Natureza',
    transporte: 'voo + 4h de carro',
    descricao:
        'Rios de água cristalina, grutas e flutuação: referência em ecoturismo no Brasil.',
    destaque: 'Flutuação em rios cristalinos',
    matchBase: 88,
    custos: [750.0, 200.0, 50.0, 400.0],
    roteiro: [
      ('Chegada', 'Transfer de Campo Grande e centrinho'),
      ('Rio da Prata', 'Flutuação em água cristalina'),
      ('Gruta do Lago Azul', 'Visita guiada pela manhã'),
      ('Buraco das Araras', 'Trilha e observação de aves'),
      ('Retorno', 'Balneário Municipal e volta'),
    ],
  ),
  (
    nome: 'Ouro Preto',
    uf: 'MG',
    categorias: 'Cultura,Montanha',
    transporte: 'ônibus 2h',
    descricao:
        'Cidade histórica mineira com igrejas barrocas, ladeiras e muita história.',
    destaque: 'Pertinho de BH e barato',
    matchBase: 82,
    custos: [80.0, 150.0, 45.0, 90.0],
    roteiro: [
      ('Chegada', 'Praça Tiradentes e Museu da Inconfidência'),
      ('Igrejas', 'São Francisco de Assis e Pilar'),
      ('Mina da Passagem', 'Passeio de trolley na mina'),
      ('Mariana', 'Centro histórico e trem da Vale'),
      ('Retorno', 'Feira de pedra-sabão e volta'),
    ],
  ),
];

/// Itens e unidades dos custos, na mesma ordem de `custos` em [destinosSeed].
const custosItens = [
  ('Passagens', 'pessoa'),
  ('Hospedagem', 'noite'),
  ('Alimentação', 'pessoa_dia'),
  ('Passeios', 'pessoa'),
];
