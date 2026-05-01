unit Infra.Repository.Produto;

interface

uses
  FireDAC.Comp.Client,
  Core.Entidades,
  Core.Exceptions,
  Infra.Connection.Manager;

type
  TProdutoRepository = class
  private
    FConnection : TFDConnection;
  public
    constructor Create;

    function FindByCodigo(const ACodigo: Integer): TProduto;
  end;

implementation

uses
  System.SysUtils;

{ TProdutoRepository }

constructor TProdutoRepository.Create;
begin
  inherited;
  FConnection := TConnectionManager.GetInstance.GetConnection;
end;

function TProdutoRepository.FindByCodigo(const ACodigo: Integer): TProduto;
var
  oFdQuery : TFDQuery;
begin
  Result := nil;
  oFdQuery := TFDQuery.Create(nil);
  try
    oFdQuery.Connection := FConnection;
    oFdQuery.SQL.Text   :=
      'SELECT codigo, descricao, preco_venda ' +
      'FROM   produtos ' +
      'WHERE  codigo = :codigo';
    oFdQuery.ParamByName('codigo').AsInteger := ACodigo;
    oFdQuery.Open;

    if not oFdQuery.IsEmpty then
    begin
      Result            := TProduto.Create;
      Result.Codigo     := oFdQuery.FieldByName('codigo').AsInteger;
      Result.Descricao  := oFdQuery.FieldByName('descricao').AsString;
      Result.PrecoVenda := oFdQuery.FieldByName('preco_venda').AsCurrency;
    end;
  finally
    oFdQuery.Free;
  end;
end;

end.
