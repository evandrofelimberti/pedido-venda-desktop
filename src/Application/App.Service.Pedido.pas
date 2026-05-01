unit App.Service.Pedido;

interface

uses
  Core.Entidades,
  Core.Exceptions,
  Infra.Repository.Cliente,
  Infra.Repository.Produto,
  Infra.Repository.Pedido;

type
  TPedidoService = class
  private
    FClienteRepo : TClienteRepository;
    FProdutoRepo : TProdutoRepository;
    FPedidoRepo  : TPedidoRepository;
  public
    constructor Create;
    destructor  Destroy; override;

    function  BuscarCliente(const ACodigo: Integer): TCliente;
    function  BuscarProduto(const ACodigo: Integer): TProduto;
    procedure GravarPedido(const APedido: TPedido);
    function  CarregarPedido(const ANrPedido: Integer): TPedido;
    procedure ExcluirPedido(const ANrPedido: Integer);
    function  PedidoExiste(const ANrPedido: Integer): Boolean;
    procedure ValidarPedido(const APedido: TPedido);
  end;

implementation

uses
  System.SysUtils;

{ TPedidoService }

constructor TPedidoService.Create;
begin
  inherited;
  FClienteRepo := TClienteRepository.Create;
  FProdutoRepo := TProdutoRepository.Create;
  FPedidoRepo  := TPedidoRepository.Create;
end;

destructor TPedidoService.Destroy;
begin
  FClienteRepo.Free;
  FProdutoRepo.Free;
  FPedidoRepo.Free;
  inherited;
end;

function TPedidoService.BuscarCliente(const ACodigo: Integer): TCliente;
begin
  if ACodigo <= 0 then
    raise EValidationException.Create('Informe o código do cliente.');
  Result := FClienteRepo.FindByCodigo(ACodigo);
  if not Assigned(Result) then
    raise EBusinessException.CreateFmt(
      'Cliente %d não encontrado.', [ACodigo]);
end;

function TPedidoService.BuscarProduto(const ACodigo: Integer): TProduto;
begin
  if ACodigo <= 0 then
    raise EValidationException.Create('Informe o código do produto.');
  Result := FProdutoRepo.FindByCodigo(ACodigo);
  if not Assigned(Result) then
    raise EBusinessException.CreateFmt(
      'Produto %d não encontrado.', [ACodigo]);
end;

procedure TPedidoService.ValidarPedido(const APedido: TPedido);
begin
  if APedido.CodCliente <= 0 then
    raise EValidationException.Create('Informe o cliente do pedido.');
  if APedido.Itens.Count = 0 then
    raise EValidationException.Create('Adicione ao menos um produto ao pedido.');
end;

procedure TPedidoService.GravarPedido(const APedido: TPedido);
begin
  ValidarPedido(APedido);
  APedido.CalcTotal;
  FPedidoRepo.Gravar(APedido);
end;

function TPedidoService.CarregarPedido(const ANrPedido: Integer): TPedido;
begin
  if ANrPedido <= 0 then
    raise EValidationException.Create('Informe o número do pedido.');
  Result := FPedidoRepo.Carregar(ANrPedido);
end;

procedure TPedidoService.ExcluirPedido(const ANrPedido: Integer);
begin
  if ANrPedido <= 0 then
    raise EValidationException.Create('Informe o número do pedido.');
  if not FPedidoRepo.Existe(ANrPedido) then
    raise EBusinessException.CreateFmt(
      'Pedido %d não encontrado.', [ANrPedido]);
  FPedidoRepo.Excluir(ANrPedido);
end;

function TPedidoService.PedidoExiste(const ANrPedido: Integer): Boolean;
begin
  Result := FPedidoRepo.Existe(ANrPedido);
end;

end.
