unit Infra.Repository.Cliente;

interface

uses
  FireDAC.Comp.Client,
  Core.Entidades,
  Core.Exceptions,
  Infra.Connection.Manager;

type
  TClienteRepository = class
  private
    FConnection : TFDConnection;
  public
    constructor Create;

    function FindByCodigo(const ACodigo: Integer): TCliente;
  end;

implementation

uses
  System.SysUtils;

{ TClienteRepository }

constructor TClienteRepository.Create;
begin
  inherited;
  FConnection := TConnectionManager.GetInstance.GetConnection;
end;

function TClienteRepository.FindByCodigo(const ACodigo: Integer): TCliente;
var
  oFdQuery : TFDQuery;
begin
  Result := nil;
  oFdQuery := TFDQuery.Create(nil);
  try
    oFdQuery.Connection := FConnection;
    oFdQuery.SQL.Text   :=
      'SELECT codigo, nome, cidade, uf ' +
      'FROM   clientes ' +
      'WHERE  codigo = :codigo';
    oFdQuery.ParamByName('codigo').AsInteger := ACodigo;
    oFdQuery.Open;

    if not oFdQuery.IsEmpty then
    begin
      Result        := TCliente.Create;
      Result.Codigo := oFdQuery.FieldByName('codigo').AsInteger;
      Result.Nome   := oFdQuery.FieldByName('nome').AsString;
      Result.Cidade := oFdQuery.FieldByName('cidade').AsString;
      Result.UF     := oFdQuery.FieldByName('uf').AsString;
    end;
  finally
    oFdQuery.Free;
  end;
end;

end.
