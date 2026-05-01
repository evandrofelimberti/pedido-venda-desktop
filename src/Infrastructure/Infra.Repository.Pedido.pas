unit Infra.Repository.Pedido;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  Core.Entidades,
  Core.Exceptions,
  Infra.Connection.Manager;

type
  TPedidoRepository = class
  private
    FConnection : TFDConnection;

    function  GetProximoNrPedido: Integer;
    procedure InserirPedido(const APedido: TPedido);
    procedure AtualizarPedido(const APedido: TPedido);
    procedure SalvarItensPedido(const APedido: TPedido);
  public
    constructor Create;

    procedure Gravar(const APedido: TPedido);
    function  Carregar(const ANrPedido: Integer): TPedido;
    procedure Excluir(const ANrPedido: Integer);
    function  Existe(const ANrPedido: Integer): Boolean;
  end;

implementation

uses
  System.SysUtils, System.DateUtils;

{ TPedidoRepository }

constructor TPedidoRepository.Create;
begin
  inherited;
  FConnection := TConnectionManager.GetInstance.GetConnection;
end;

function TPedidoRepository.GetProximoNrPedido: Integer;
var
  oFdQuery : TFDQuery;
begin
  oFdQuery := TFDQuery.Create(nil);
  try
    oFdQuery.Connection := FConnection;
    oFdQuery.SQL.Text   := 'SELECT COALESCE(MAX(nr_pedido), 0) + 1 AS proximo FROM pedidos';
    oFdQuery.Open;
    Result := oFdQuery.Fields[0].AsInteger;
  finally
    oFdQuery.Free;
  end;
end;

procedure TPedidoRepository.Gravar(const APedido: TPedido);
begin
  FConnection.StartTransaction;
  try
    if (APedido.NrPedido > 0) and Existe(APedido.NrPedido) then
      AtualizarPedido(APedido)
    else
      InserirPedido(APedido);

    FConnection.Commit;
  except
    on E: Exception do
    begin
      FConnection.Rollback;
      raise ERepositoryException.CreateFmt(
        'Erro ao gravar pedido.'#13#10'%s', [E.Message]);
    end;
  end;
end;

procedure TPedidoRepository.InserirPedido(const APedido: TPedido);
var
  oFdQuery : TFDQuery;
begin
  APedido.NrPedido := GetProximoNrPedido;

  oFdQuery := TFDQuery.Create(nil);
  try
    oFdQuery.Connection := FConnection;
    oFdQuery.SQL.Text :=
      'INSERT INTO pedidos (nr_pedido, dt_emissao, cod_cliente, vr_total) ' +
      'VALUES (:nr, :dt, :cli, :vt)';
    oFdQuery.ParamByName('nr').AsInteger  := APedido.NrPedido;
    oFdQuery.ParamByName('dt').AsDate     := APedido.DtEmissao;
    oFdQuery.ParamByName('cli').AsInteger := APedido.CodCliente;
    oFdQuery.ParamByName('vt').AsCurrency := APedido.VrTotal;
    oFdQuery.ExecSQL;
  finally
    oFdQuery.Free;
  end;

  SalvarItensPedido(APedido);
end;

procedure TPedidoRepository.AtualizarPedido(const APedido: TPedido);
var
  oFdQuery : TFDQuery;
begin
  oFdQuery := TFDQuery.Create(nil);
  try
    oFdQuery.Connection := FConnection;
    oFdQuery.SQL.Text :=
      'UPDATE pedidos ' +
      'SET dt_emissao = :dt, cod_cliente = :cli, vr_total = :vt ' +
      'WHERE nr_pedido = :nr';
    oFdQuery.ParamByName('nr').AsInteger  := APedido.NrPedido;
    oFdQuery.ParamByName('dt').AsDate     := APedido.DtEmissao;
    oFdQuery.ParamByName('cli').AsInteger := APedido.CodCliente;
    oFdQuery.ParamByName('vt').AsCurrency := APedido.VrTotal;
    oFdQuery.ExecSQL;
  finally
    oFdQuery.Free;
  end;

  FConnection.ExecSQL(
    'DELETE FROM pedido_itens WHERE nr_pedido = :nr', [APedido.NrPedido]);
  SalvarItensPedido(APedido);
end;

procedure TPedidoRepository.SalvarItensPedido(const APedido: TPedido);
var
  oFdQuery : TFDQuery;
  Item     : TItemPedido;
begin
  oFdQuery := TFDQuery.Create(nil);
  try
    oFdQuery.Connection := FConnection;
    oFdQuery.SQL.Text :=
      'INSERT INTO pedido_itens ' +
      '  (nr_pedido, cod_produto, quantidade, vr_unitario, vr_total) ' +
      'VALUES (:nr, :cp, :qt, :vu, :vt)';

    for Item in APedido.Itens do
    begin
      oFdQuery.ParamByName('nr').AsInteger  := APedido.NrPedido;
      oFdQuery.ParamByName('cp').AsInteger  := Item.CodProduto;
      oFdQuery.ParamByName('qt').AsFloat    := Item.Quantidade;
      oFdQuery.ParamByName('vu').AsCurrency := Item.VrUnitario;
      oFdQuery.ParamByName('vt').AsCurrency := Item.VrTotal;
      oFdQuery.ExecSQL;
    end;
  finally
    oFdQuery.Free;
  end;
end;

function TPedidoRepository.Carregar(const ANrPedido: Integer): TPedido;
var
  oFdQuery    : TFDQuery;
  Item : TItemPedido;
begin
  Result := nil;
  oFdQuery := TFDQuery.Create(nil);
  try
    oFdQuery.Connection := FConnection;

    oFdQuery.SQL.Text :=
      'SELECT p.nr_pedido, p.dt_emissao, p.cod_cliente, p.vr_total, ' +
      '       c.nome, c.cidade, c.uf ' +
      'FROM   pedidos p ' +
      '  INNER JOIN clientes c ON c.codigo = p.cod_cliente ' +
      'WHERE  p.nr_pedido = :nr';
    oFdQuery.ParamByName('nr').AsInteger := ANrPedido;
    oFdQuery.Open;

    if oFdQuery.IsEmpty then
      raise EBusinessException.CreateFmt(
        'Pedido %d não encontrado.', [ANrPedido]);

    Result             := TPedido.Create;
    Result.NrPedido    := oFdQuery.FieldByName('nr_pedido').AsInteger;
    Result.DtEmissao   := ISO8601ToDate(oFdQuery.FieldByName('dt_emissao').AsString);
    Result.CodCliente  := oFdQuery.FieldByName('cod_cliente').AsInteger;
    Result.NomeCliente := oFdQuery.FieldByName('nome').AsString;
    Result.VrTotal     := oFdQuery.FieldByName('vr_total').AsCurrency;
    oFdQuery.Close;

    oFdQuery.SQL.Text :=
      'SELECT pi.autoincrem, pi.cod_produto, pi.quantidade, ' +
      '       pi.vr_unitario, pi.vr_total, pr.descricao ' +
      'FROM   pedido_itens pi ' +
      '  INNER JOIN produtos pr ON pr.codigo = pi.cod_produto ' +
      'WHERE  pi.nr_pedido = :nr ' +
      'ORDER BY pi.autoincrem';
    oFdQuery.ParamByName('nr').AsInteger := ANrPedido;
    oFdQuery.Open;

    while not oFdQuery.EOF do
    begin
      Item             := TItemPedido.Create;
      Item.AutoIncrem  := oFdQuery.FieldByName('autoincrem').AsInteger;
      Item.NrPedido    := ANrPedido;
      Item.CodProduto  := oFdQuery.FieldByName('cod_produto').AsInteger;
      Item.DescProduto := oFdQuery.FieldByName('descricao').AsString;
      Item.Quantidade  := oFdQuery.FieldByName('quantidade').AsFloat;
      Item.VrUnitario  := oFdQuery.FieldByName('vr_unitario').AsCurrency;
      Item.VrTotal     := oFdQuery.FieldByName('vr_total').AsCurrency;
      Result.Itens.Add(Item);
      oFdQuery.Next;
    end;
  except
    on E: EBusinessException do
    begin
      FreeAndNil(Result);
      raise;
    end;
    on E: Exception do
    begin
      FreeAndNil(Result);
      raise ERepositoryException.CreateFmt(
        'Erro ao carregar pedido %d.'#13#10'%s', [ANrPedido, E.Message]);
    end;
  end;
end;

procedure TPedidoRepository.Excluir(const ANrPedido: Integer);
begin
  FConnection.StartTransaction;
  try
    FConnection.ExecSQL(
      'DELETE FROM pedido_itens WHERE nr_pedido = :nr', [ANrPedido]);
    FConnection.ExecSQL(
      'DELETE FROM pedidos WHERE nr_pedido = :nr', [ANrPedido]);
    FConnection.Commit;
  except
    on E: Exception do
    begin
      FConnection.Rollback;
      raise ERepositoryException.CreateFmt(
        'Erro ao excluir pedido %d.'#13#10'%s', [ANrPedido, E.Message]);
    end;
  end;
end;

function TPedidoRepository.Existe(const ANrPedido: Integer): Boolean;
var
  oFdQuery : TFDQuery;
begin
  oFdQuery := TFDQuery.Create(nil);
  try
    oFdQuery.Connection := FConnection;
    oFdQuery.SQL.Text   :=
      'SELECT COUNT(1) AS total FROM pedidos WHERE nr_pedido = :nr';
    oFdQuery.ParamByName('nr').AsInteger := ANrPedido;
    oFdQuery.Open;
    Result := oFdQuery.Fields[0].AsInteger > 0;
  finally
    oFdQuery.Free;
  end;
end;

end.
