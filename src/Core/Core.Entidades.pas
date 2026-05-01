unit Core.Entidades;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type
  TCliente = class
  public
    Codigo : Integer;
    Nome   : string;
    Cidade : string;
    UF     : string;
  end;

  TProduto = class
  public
    Codigo     : Integer;
    Descricao  : string;
    PrecoVenda : Currency;
  end;

  TItemPedido = class
  public
    AutoIncrem  : Integer;
    NrPedido    : Integer;
    CodProduto  : Integer;
    DescProduto : string;
    Quantidade  : Double;
    VrUnitario  : Currency;
    VrTotal     : Currency;

    procedure CalcTotal;
  end;

  TPedido = class
  public
    NrPedido    : Integer;
    DtEmissao   : TDateTime;
    CodCliente  : Integer;
    NomeCliente : string;
    VrTotal     : Currency;
    Itens       : TObjectList<TItemPedido>;

    constructor Create;
    destructor  Destroy; override;
    procedure   CalcTotal;
  end;

implementation

{ TItemPedido }

procedure TItemPedido.CalcTotal;
begin
  VrTotal := Quantidade * VrUnitario;
end;

{ TPedido }

constructor TPedido.Create;
begin
  inherited;
  Itens     := TObjectList<TItemPedido>.Create(True);
  DtEmissao := Now;
end;

destructor TPedido.Destroy;
begin
  Itens.Free;
  inherited;
end;

procedure TPedido.CalcTotal;
var
  Item : TItemPedido;
begin
  VrTotal := 0;
  for Item in Itens do
    VrTotal := VrTotal + Item.VrTotal;
end;

end.
