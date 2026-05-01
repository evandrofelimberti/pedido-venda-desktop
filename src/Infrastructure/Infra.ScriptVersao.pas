unit Infra.ScriptVersao;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  Infra.Connection.Manager;

type
  TScriptVersao = record
    Versao     : Integer;
    Descricao : string;
    SQL         : TArray<string>;
  end;

  TScriptExecucao = class
  private
    FConnection : TFDConnection;
    FScriptVersao : TList<TScriptVersao>;

    procedure CriaTabelaScriptVersao;
    function  GetUltimaVersao: Integer;
    procedure SalvarVersao(const pnVersao: Integer; const psDescricao: string);
    procedure SalvarScriptVersao;
    procedure ExecSQL(const sSQL: string);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Executar;
  end;

implementation

{ TScriptExecucao }

constructor TScriptExecucao.Create;
begin
  inherited;
  FConnection := TConnectionManager.GetInstance.GetConnection;
  FScriptVersao := TList<TScriptVersao>.Create;
  SalvarScriptVersao;
end;

destructor TScriptExecucao.Destroy;
begin
  FScriptVersao.Free;
  inherited;
end;

procedure TScriptExecucao.ExecSQL(const sSQL: string);
begin
  if Trim(sSQL) <> '' then
    FConnection.ExecSQL(sSQL);
end;

procedure TScriptExecucao.SalvarScriptVersao;
var
  oScriptVersao : TScriptVersao;
begin

  oScriptVersao.Versao     := 1;
  oScriptVersao.Descricao := 'Criacao tabela clientes';
  oScriptVersao.SQL := [
    'CREATE TABLE IF NOT EXISTS clientes (' +
    '  codigo  INTEGER NOT NULL,' +
    '  nome    TEXT    NOT NULL,' +
    '  cidade  TEXT    NOT NULL,' +
    '  uf      TEXT    NOT NULL,' +
    '  PRIMARY KEY (codigo AUTOINCREMENT)' +
    ')'
    ,
    'CREATE INDEX IF NOT EXISTS idx_clientes_nome ON clientes(nome)'
    ,
    'CREATE INDEX IF NOT EXISTS idx_clientes_uf   ON clientes(uf)'
  ];
  FScriptVersao.Add(oScriptVersao);

  oScriptVersao.Versao     := 2;
  oScriptVersao.Descricao := 'Criacao tabela produtos';
  oScriptVersao.SQL := [
    'CREATE TABLE IF NOT EXISTS produtos (' +
    '  codigo      INTEGER NOT NULL,' +
    '  descricao   TEXT    NOT NULL,' +
    '  preco_venda NUMERIC NOT NULL DEFAULT 0,' +
    '  PRIMARY KEY (codigo AUTOINCREMENT)' +
    ')'
    ,
    'CREATE INDEX IF NOT EXISTS idx_produtos_descricao ON produtos(descricao)'
  ];
  FScriptVersao.Add(oScriptVersao);


  oScriptVersao.Versao     := 3;
  oScriptVersao.Descricao := 'Criacao tabela pedidos';
  oScriptVersao.SQL := [
    'CREATE TABLE IF NOT EXISTS pedidos (' +
    '  nr_pedido   INTEGER NOT NULL,' +
    '  dt_emissao  TEXT    NOT NULL,' +
    '  cod_cliente INTEGER NOT NULL,' +
    '  vr_total    NUMERIC NOT NULL DEFAULT 0,' +
    '  PRIMARY KEY (nr_pedido),' +
    '  FOREIGN KEY (cod_cliente) REFERENCES clientes(codigo)' +
    '    ON UPDATE CASCADE ON DELETE RESTRICT' +
    ')'
    ,
    'CREATE INDEX IF NOT EXISTS idx_pedidos_cliente ON pedidos(cod_cliente)'
    ,
    'CREATE INDEX IF NOT EXISTS idx_pedidos_data    ON pedidos(dt_emissao)'
  ];
  FScriptVersao.Add(oScriptVersao);

  oScriptVersao.Versao     := 4;
  oScriptVersao.Descricao := 'Criacao tabela pedido_itens';
  oScriptVersao.SQL := [
    'CREATE TABLE IF NOT EXISTS pedido_itens (' +
    '  autoincrem  INTEGER NOT NULL,' +
    '  nr_pedido   INTEGER NOT NULL,' +
    '  cod_produto INTEGER NOT NULL,' +
    '  quantidade  NUMERIC NOT NULL,' +
    '  vr_unitario NUMERIC NOT NULL,' +
    '  vr_total    NUMERIC NOT NULL,' +
    '  PRIMARY KEY (autoincrem AUTOINCREMENT),' +
    '  FOREIGN KEY (nr_pedido)   REFERENCES pedidos(nr_pedido)' +
    '    ON UPDATE CASCADE ON DELETE CASCADE,' +
    '  FOREIGN KEY (cod_produto) REFERENCES produtos(codigo)' +
    '    ON UPDATE CASCADE ON DELETE RESTRICT' +
    ')'
    ,
    'CREATE INDEX IF NOT EXISTS idx_pitens_pedido  ON pedido_itens(nr_pedido)'
    ,
    'CREATE INDEX IF NOT EXISTS idx_pitens_produto ON pedido_itens(cod_produto)'
  ];
  FScriptVersao.Add(oScriptVersao);

  oScriptVersao.Versao     := 5;
  oScriptVersao.Descricao := 'Dados de teste clientes';
  oScriptVersao.SQL := [
    'INSERT OR IGNORE INTO clientes (codigo,nome,cidade,uf) VALUES' +
    ' (1,''Ana Paula Ferreira'',''São Paulo'',''SP''),' +
    ' (2,''Carlos Eduardo Lima'',''Rio de Janeiro'',''RJ''),' +
    ' (3,''Mariana Souza'',''Belo Horizonte'',''MG''),' +
    ' (4,''Pedro Henrique Costa'',''Curitiba'',''PR''),' +
    ' (5,''Fernanda Oliveira'',''Porto Alegre'',''RS''),' +
    ' (6,''Rafael Mendes'',''Salvador'',''BA''),' +
    ' (7,''Juliana Alves'',''Fortaleza'',''CE''),' +
    ' (8,''Lucas Ribeiro'',''Recife'',''PE''),' +
    ' (9,''Camila Gomes'',''Manaus'',''AM''),' +
    ' (10,''Diego Martins'',''Goiânia'',''GO''),' +
    ' (11,''Aline Barbosa'',''Florianópolis'',''SC''),' +
    ' (12,''Bruno Carvalho'',''Belém'',''PA''),' +
    ' (13,''Vanessa Rocha'',''Vitória'',''ES''),' +
    ' (14,''Eduardo Nascimento'',''Maceió'',''AL''),' +
    ' (15,''Patricia Dias'',''Natal'',''RN''),' +
    ' (16,''Rodrigo Pereira'',''Teresina'',''PI''),' +
    ' (17,''Isabela Santos'',''Campo Grande'',''MS''),' +
    ' (18,''Gustavo Cunha'',''João Pessoa'',''PB''),' +
    ' (19,''Tatiane Moreira'',''Aracaju'',''SE''),' +
    ' (20,''Fábio Teixeira'',''Porto Velho'',''RO'')'
  ];
  FScriptVersao.Add(oScriptVersao);

  oScriptVersao.Versao     := 6;
  oScriptVersao.Descricao := 'Dados de teste produtos';
  oScriptVersao.SQL := [
    'INSERT OR IGNORE INTO produtos (codigo,descricao,preco_venda) VALUES' +
    ' (1,''Notebook Dell Inspiron 15'',550.00),' +
    ' (2,''Mouse Sem Fio Logitech MX'',189.00),' +
    ' (3,''Teclado Mecânico Redragon'',299.00),' +
    ' (4,''Monitor LG 24 Full HD'',999.00),' +
    ' (5,''Headset Gamer HyperX Cloud'',459.00),' +
    ' (6,''SSD Kingston 480GB'',259.00),' +
    ' (7,''Memória RAM 16GB DDR4'',349.00),' +
    ' (8,''Webcam Full HD Logitech C920'',389.00),' +
    ' (9,''Cabo HDMI 2m'',29.00),' +
    ' (10,''Hub USB 7 Portas'',89.00),' +
    ' (11,''Impressora HP LaserJet'',799.00),' +
    ' (12,''Roteador Wi-Fi TP-Link AC1200'',219.00),' +
    ' (13,''No-Break APC 700VA'',449.00),' +
    ' (14,''Suporte Monitor Articulado'',159.00),' +
    ' (15,''Cadeira Ergonômica ThunderX3'',189.00),' +
    ' (16,''Mesa para Computador 120cm'',549.00),' +
    ' (17,''Pen Drive 64GB Kingston'',39.00),' +
    ' (18,''HD Externo 1TB Seagate'',299.00),' +
    ' (19,''Caixa de Som Bluetooth JBL'',349.00),' +
    ' (20,''Mousepad Gamer Grande XL'',79.00),' +
    ' (21,''Fonte ATX 600W Corsair'',389.00),' +
    ' (22,''Placa de Vídeo GTX 1660'',120.00),' +
    ' (23,''Processador Intel Core i5'',199.00),' +
    ' (24,''Cooler CPU Cooler Master'',129.00),' +
    ' (25,''Gabinete ATX Mid Tower'',279.00)'
  ];
  FScriptVersao.Add(oScriptVersao);
end;

procedure TScriptExecucao.CriaTabelaScriptVersao;
begin
  ExecSQL(
    'CREATE TABLE IF NOT EXISTS script_versao (' +
    '  versao     INT          NOT NULL,' +
    '  descricao VARCHAR(200) NOT NULL,' +
    '  data_criacao  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
    '  PRIMARY KEY (versao)' +
    ')'
  );
end;

function TScriptExecucao.GetUltimaVersao: Integer;
var
  oFdQuery : TFDQuery;
begin
  Result := 0;
  oFdQuery := TFDQuery.Create(nil);
  try
    oFdQuery.Connection := FConnection;
    oFdQuery.SQL.Text   := 'SELECT COALESCE(MAX(versao),0) AS v FROM script_versao';
    oFdQuery.Open;
    Result := oFdQuery.Fields[0].AsInteger;
  finally
    oFdQuery.Free;
  end;
end;

procedure TScriptExecucao.SalvarVersao(const pnVersao: Integer;
  const psDescricao: string);
begin
  FConnection.ExecSQL(
    'INSERT INTO script_versao (versao, descricao) VALUES (:v, :d)',
    [pnVersao, psDescricao]
  );
end;

procedure TScriptExecucao.Executar;
var
  nUltimaVersao : Integer;
  oScriptVersao : TScriptVersao;
  sSQL : string;
begin
  CriaTabelaScriptVersao;
  nUltimaVersao := GetUltimaVersao;

  for oScriptVersao in FScriptVersao do
  begin
    if oScriptVersao.Versao > nUltimaVersao then
    begin
      for sSQL in oScriptVersao.SQL do
        ExecSQL(sSQL);
      SalvarVersao(oScriptVersao.Versao, oScriptVersao.Descricao);
    end;
  end;
end;

end.
