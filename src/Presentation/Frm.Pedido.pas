unit Frm.Pedido;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Graphics,
  Core.Entidades,
  Core.Exceptions,
  App.Service.Pedido, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.Intf, FireDAC.Phys, FireDAC.Phys.SQLite;

type
  TfrmPedido = class(TForm)
    pnlCabecalho  : TPanel;
    gbCliente     : TGroupBox;
    lblNrPedido   : TLabel;
    edtNrPedido   : TEdit;
    lblEmissao    : TLabel;
    dtpEmissao    : TDateTimePicker;
    lblCodCliente : TLabel;
    edtCodCliente : TEdit;
    lblNome       : TLabel;
    edtNomeCliente: TEdit;
    lblCidade     : TLabel;
    edtCidade     : TEdit;
    lblUF         : TLabel;
    edtUF         : TEdit;
    pnlItem       : TPanel;
    gbProduto     : TGroupBox;
    lblCodProduto : TLabel;
    edtCodProduto : TEdit;
    edtDescProduto: TEdit;
    lblQtd        : TLabel;
    edtQuantidade : TEdit;
    lblVrUnit     : TLabel;
    edtVrUnitario : TEdit;
    btnInserir    : TButton;
    pnlRodape     : TPanel;
    lblTotalLabel : TLabel;
    lblVrTotal    : TLabel;
    btnGravar     : TButton;
    btnCarregar   : TButton;
    btnExcluir    : TButton;
    sgItens       : TStringGrid;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtCodClienteExit(Sender: TObject);
    procedure edtCodClienteKeyPress(Sender: TObject; var Key: Char);
    procedure edtCodClienteChange(Sender: TObject);
    procedure edtCodProdutoExit(Sender: TObject);
    procedure edtCodProdutoKeyPress(Sender: TObject; var Key: Char);
    procedure edtQuantidadeKeyPress(Sender: TObject; var Key: Char);
    procedure edtVrUnitarioKeyPress(Sender: TObject; var Key: Char);
    procedure btnInserirClick(Sender: TObject);
    procedure sgItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure sgItensDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure btnGravarClick(Sender: TObject);
    procedure btnCarregarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
  private
    FService          : TPedidoService;
    FItens            : TObjectList<TItemPedido>;
    FEditingRow       : Integer;
    FCodClienteAtual  : Integer;
    FCodProdutoAtual  : Integer;
    FDescProdutoAtual : string;
    FPrecoAtual       : Currency;
    FModoEdicao       : Boolean;

    procedure ConfigurarGrid;
    procedure LimparFormulario;
    procedure LimparCamposProduto;
    procedure BuscarCliente;
    procedure BuscarProduto;
    procedure AdicionarLinhaGrid(AItem: TItemPedido; ARow: Integer);
    procedure ReconstruirGrid;
    procedure AtualizarTotal;
    procedure AtualizarVisibilidadeBotoes;
    procedure EntrarModoEdicao(ARow: Integer);
    procedure SairModoEdicao;
    function  ValidarCamposItem: Boolean;
    function  StrParaFloat(const S: string): Double;
    function  FloatParaStr(const V: Double; const Decimais: Integer = 2): string;
  public
    { Public declarations }
  end;

var
  frmPedido: TfrmPedido;

implementation

{$R *.dfm}

uses
  System.StrUtils;

procedure TfrmPedido.FormCreate(Sender: TObject);
begin
  FService    := TPedidoService.Create;
  FItens      := TObjectList<TItemPedido>.Create(True);
  FEditingRow := -1;

  ConfigurarGrid;
end;

procedure TfrmPedido.FormDestroy(Sender: TObject);
begin
  FItens.Free;
  FService.Free;
end;


procedure TfrmPedido.ConfigurarGrid;
const
  HEADERS : array[0..5] of string = (
    'Seq', 'Cód.Produto', 'Descrição', 'Quantidade', 'Vr.Unitário', 'Vr.Total');
  WIDTHS  : array[0..5] of Integer = (40, 90, 300, 90, 105, 105);
var
  I : Integer;
begin
  sgItens.RowCount  := 2;
  sgItens.ColCount  := 6;
  sgItens.FixedRows := 1;
  sgItens.FixedCols := 0;
  sgItens.Options   := sgItens.Options + [goRowSelect] - [goEditing];
  sgItens.RowHeights[0] := 24;

  for I := 0 to 5 do
  begin
    sgItens.ColWidths[I] := WIDTHS[I];
    sgItens.Cells[I, 0]  := HEADERS[I];
  end;

  sgItens.RowCount := 2;
end;


function TfrmPedido.StrParaFloat(const S: string): Double;
var
  Fmt   : TFormatSettings;
  Valor : Currency;
begin
  Fmt := TFormatSettings.Create('pt-BR');
  if TryStrToCurr(Trim(S), Valor, Fmt) then
    Result := Valor
  else
    Result := 0;
end;

function TfrmPedido.FloatParaStr(const V: Double; const Decimais: Integer): string;
begin
  Result := FormatFloat('#,##0.' + StringOfChar('0', Decimais), V);
end;

procedure TfrmPedido.LimparFormulario;
begin
  edtNrPedido.Text    := '(novo)';
  dtpEmissao.Date     := Date;
  edtCodCliente.Text  := '';
  edtNomeCliente.Text := '';
  edtCidade.Text      := '';
  edtUF.Text          := '';

  FCodClienteAtual    := 0;
  FEditingRow         := -1;
  FModoEdicao         := False;

  FItens.Clear;
  ReconstruirGrid;
  LimparCamposProduto;
  AtualizarTotal;
  AtualizarVisibilidadeBotoes;

  if edtCodCliente.CanFocus then  
    edtCodCliente.SetFocus;
end;

procedure TfrmPedido.LimparCamposProduto;
begin
  edtCodProduto.Text  := '';
  edtDescProduto.Text := '';
  edtQuantidade.Text  := '1';
  edtVrUnitario.Text  := '0,00';
  FCodProdutoAtual    := 0;
  FDescProdutoAtual   := '';
  FPrecoAtual         := 0;
end;

procedure TfrmPedido.AtualizarVisibilidadeBotoes;
var
  SemCliente : Boolean;
begin
  SemCliente          := Trim(edtCodCliente.Text) = '';
  btnCarregar.Visible := SemCliente;
  btnExcluir.Visible  := SemCliente;
end;

procedure TfrmPedido.AtualizarTotal;
var
  Total : Currency;
  Item  : TItemPedido;
begin
  Total := 0;
  for Item in FItens do
    Total := Total + Item.VrTotal;
  lblVrTotal.Caption := 'R$ ' + FloatParaStr(Total);
end;


procedure TfrmPedido.AdicionarLinhaGrid(AItem: TItemPedido; ARow: Integer);
begin
  sgItens.Cells[0, ARow] := ARow.ToString;
  sgItens.Cells[1, ARow] := AItem.CodProduto.ToString;
  sgItens.Cells[2, ARow] := AItem.DescProduto;
  sgItens.Cells[3, ARow] := FloatParaStr(AItem.Quantidade, 3);
  sgItens.Cells[4, ARow] := FloatParaStr(AItem.VrUnitario);
  sgItens.Cells[5, ARow] := FloatParaStr(AItem.VrTotal);
end;

procedure TfrmPedido.ReconstruirGrid;
var
  I : Integer;
begin
  if FItens.Count = 0 then
  begin
    sgItens.RowCount := 2;
    for I := 0 to 5 do
      sgItens.Cells[I, 1] := '';
    Exit;
  end;

  sgItens.RowCount := FItens.Count + 1;
  for I := 0 to FItens.Count - 1 do
    AdicionarLinhaGrid(FItens[I], I + 1);
end;

procedure TfrmPedido.sgItensDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  sTexto: string;  
begin
  sTexto := sgItens.Cells[ACol, ARow];

  if ARow = 0 then
  begin
    sgItens.Canvas.Brush.Color := $00404040;
    sgItens.Canvas.Font.Color  := clWhite;
    sgItens.Canvas.Font.Style  := [fsBold];
    sgItens.Canvas.FillRect(Rect);
    InflateRect(Rect, -2, 0);
    sgItens.Canvas.TextRect(Rect, sTexto,
      [tfSingleLine, tfVerticalCenter, tfCenter]);
  end
  else if gdSelected in State then
  begin
    sgItens.Canvas.Brush.Color := $00CC7700;
    sgItens.Canvas.Font.Color  := clWhite;
    sgItens.Canvas.Font.Style  := [];
    sgItens.Canvas.FillRect(Rect);
    InflateRect(Rect, -2, 0);
    sgItens.Canvas.TextRect(Rect, sTexto,
      [tfSingleLine, tfVerticalCenter]);
  end
  else
  begin
    if ARow mod 2 = 0 then
      sgItens.Canvas.Brush.Color := $00F0F0F0
    else
      sgItens.Canvas.Brush.Color := clWhite;
    sgItens.Canvas.Font.Color  := clBlack;
    sgItens.Canvas.Font.Style  := [];
    sgItens.Canvas.FillRect(Rect);
    InflateRect(Rect, -2, 0);
    sgItens.Canvas.TextRect(Rect, sTexto,
      [tfSingleLine, tfVerticalCenter]);
  end;
end;


procedure TfrmPedido.sgItensKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Row : Integer;
begin
  Row := sgItens.Row;
  if Row <= 0 then Exit;
  if (FItens.Count = 0) or (Row > FItens.Count) then Exit;

  case Key of
    VK_RETURN:
    begin
      EntrarModoEdicao(Row);
      Key := 0;
    end;

    VK_DELETE:
    begin
      if MessageDlg(
        Format('Deseja realmente excluir o produto "%s" (linha %d)?',
          [FItens[Row - 1].DescProduto, Row]),
        mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        FItens.Delete(Row - 1);
        ReconstruirGrid;
        AtualizarTotal;

        if FItens.Count > 0 then
        begin
          if Row > FItens.Count then
            sgItens.Row := FItens.Count
          else
            sgItens.Row := Row;
        end;
      end;
      Key := 0;
    end;
  end;
end;


procedure TfrmPedido.EntrarModoEdicao(ARow: Integer);
var
  Item : TItemPedido;
begin
  Item := FItens[ARow - 1];
  FEditingRow       := ARow;
  FModoEdicao       := True;
  FCodProdutoAtual  := Item.CodProduto;
  FDescProdutoAtual := Item.DescProduto;

  edtCodProduto.Text  := Item.CodProduto.ToString;
  edtDescProduto.Text := Item.DescProduto;
  edtQuantidade.Text  := FloatParaStr(Item.Quantidade, 3);
  edtVrUnitario.Text  := FloatParaStr(Item.VrUnitario);

  btnInserir.Caption := 'Confirmar Alteração';
  gbProduto.Caption  := Format('Editando linha %d – %s', [ARow, Item.DescProduto]);

  edtQuantidade.SetFocus;
  edtQuantidade.SelectAll;
end;

procedure TfrmPedido.SairModoEdicao;
begin
  FEditingRow        := -1;
  FModoEdicao        := False;
  btnInserir.Caption := 'Inserir Produto';
  gbProduto.Caption  := 'Informar Produto';
  LimparCamposProduto;
end;


procedure TfrmPedido.edtCodClienteKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8, #13]) then
    Key := #0;
  if Key = #13 then
  begin
    Key := #0;
    BuscarCliente;
  end;
end;

procedure TfrmPedido.edtCodClienteChange(Sender: TObject);
begin
  AtualizarVisibilidadeBotoes;
end;

procedure TfrmPedido.edtCodClienteExit(Sender: TObject);
begin
  if Trim(edtCodCliente.Text) <> '' then
    BuscarCliente;
end;

procedure TfrmPedido.BuscarCliente;
var
  Cliente : TCliente;
  Codigo  : Integer;
begin
  Codigo := StrToIntDef(Trim(edtCodCliente.Text), 0);
  if Codigo <= 0 then
  begin
    edtNomeCliente.Text := '';
    edtCidade.Text      := '';
    edtUF.Text          := '';
    FCodClienteAtual    := 0;
    AtualizarVisibilidadeBotoes;
    Exit;
  end;

  try
    Cliente := FService.BuscarCliente(Codigo);
    try
      FCodClienteAtual    := Cliente.Codigo;
      edtNomeCliente.Text := Cliente.Nome;
      edtCidade.Text      := Cliente.Cidade;
      edtUF.Text          := Cliente.UF;
    finally
      Cliente.Free;
    end;
    AtualizarVisibilidadeBotoes;
    edtCodProduto.SetFocus;
  except
    on E: EAppException do
    begin
      ShowMessage(E.Message);
      edtCodCliente.SetFocus;
      edtCodCliente.SelectAll;
    end;
    on E: Exception do
    begin
      ShowMessage('Erro ao buscar cliente: ' + E.Message);
      edtCodCliente.SetFocus;
      edtCodCliente.SelectAll;
    end;
  end;
end;


procedure TfrmPedido.edtCodProdutoKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8, #13]) then
    Key := #0;
  if Key = #13 then
  begin
    Key := #0;
    BuscarProduto;
  end;
end;

procedure TfrmPedido.edtCodProdutoExit(Sender: TObject);
begin
  if Trim(edtCodProduto.Text) <> '' then
    BuscarProduto;
end;

procedure TfrmPedido.BuscarProduto;
var
  Produto : TProduto;
  Codigo  : Integer;
begin
  Codigo := StrToIntDef(Trim(edtCodProduto.Text), 0);
  if Codigo <= 0 then Exit;

  if FModoEdicao then Exit;

  try
    Produto := FService.BuscarProduto(Codigo);
    try
      FCodProdutoAtual    := Produto.Codigo;
      FDescProdutoAtual   := Produto.Descricao;
      FPrecoAtual         := Produto.PrecoVenda;
      edtDescProduto.Text := Produto.Descricao;
      edtVrUnitario.Text  := FloatParaStr(Produto.PrecoVenda);
    finally
      Produto.Free;
    end;
    edtQuantidade.SetFocus;
    edtQuantidade.SelectAll;
  except
    on E: EAppException do
    begin
      ShowMessage(E.Message);
      edtCodProduto.SetFocus;
      edtCodProduto.SelectAll;
    end;
    on E: Exception do
    begin
      ShowMessage('Erro ao buscar produto: ' + E.Message);
      edtCodProduto.SetFocus;
      edtCodProduto.SelectAll;
    end;
  end;
end;


procedure TfrmPedido.edtQuantidadeKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', ',', '.', #8]) then
    Key := #0;
end;

procedure TfrmPedido.edtVrUnitarioKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', ',', '.', #8]) then
    Key := #0;
end;


function TfrmPedido.ValidarCamposItem: Boolean;
var
  Qtd : Double;
  Vr  : Currency;
begin
  Result := False;

  if FCodClienteAtual <= 0 then
  begin
    ShowMessage('Informe o cliente antes de adicionar produtos.');
    edtCodCliente.SetFocus;
    Exit;
  end;

  if (not FModoEdicao) and (FCodProdutoAtual <= 0) then
  begin
    ShowMessage('Informe o código do produto.');
    edtCodProduto.SetFocus;
    Exit;
  end;

  Qtd := StrParaFloat(edtQuantidade.Text);
  if Qtd <= 0 then
  begin
    ShowMessage('Informe uma quantidade válida (maior que zero).');
    edtQuantidade.SetFocus;
    edtQuantidade.SelectAll;
    Exit;
  end;

  Vr := StrParaFloat(edtVrUnitario.Text);
  if Vr <= 0 then
  begin
    ShowMessage('Informe um valor unitário válido (maior que zero).');
    edtVrUnitario.SetFocus;
    edtVrUnitario.SelectAll;
    Exit;
  end;

  Result := True;
end;


procedure TfrmPedido.btnInserirClick(Sender: TObject);
var
  Item : TItemPedido;
  Qtd  : Double;
  Vr   : Currency;
begin
  if not ValidarCamposItem then Exit;

  Qtd := StrParaFloat(edtQuantidade.Text);
  Vr  := StrParaFloat(edtVrUnitario.Text);

  if FModoEdicao and (FEditingRow >= 1) then
  begin
    Item            := FItens[FEditingRow - 1];
    Item.Quantidade := Qtd;
    Item.VrUnitario := Vr;
    Item.CalcTotal;

    AdicionarLinhaGrid(Item, FEditingRow);
    SairModoEdicao;
  end
  else
  begin
    Item             := TItemPedido.Create;
    Item.CodProduto  := FCodProdutoAtual;
    Item.DescProduto := FDescProdutoAtual;
    Item.Quantidade  := Qtd;
    Item.VrUnitario  := Vr;
    Item.CalcTotal;

    FItens.Add(Item);
    sgItens.RowCount := FItens.Count + 1;
    AdicionarLinhaGrid(Item, FItens.Count);
    sgItens.Row := FItens.Count;

    LimparCamposProduto;
    edtCodProduto.SetFocus;
  end;

  AtualizarTotal;
end;


procedure TfrmPedido.btnGravarClick(Sender: TObject);
var
  Pedido : TPedido;
  Item   : TItemPedido;
  I      : Integer;
begin
  if FCodClienteAtual <= 0 then
  begin
    ShowMessage('Informe o cliente do pedido.');
    edtCodCliente.SetFocus;
    Exit;
  end;

  if FItens.Count = 0 then
  begin
    ShowMessage('Adicione ao menos um produto ao pedido.');
    edtCodProduto.SetFocus;
    Exit;
  end;

  Pedido := TPedido.Create;
  try
    Pedido.NrPedido := StrToIntDef(edtNrPedido.Text, 0);
    Pedido.DtEmissao  := dtpEmissao.DateTime;
    Pedido.CodCliente := FCodClienteAtual;

    for I := 0 to FItens.Count - 1 do
    begin
      Item             := TItemPedido.Create;
      Item.CodProduto  := FItens[I].CodProduto;
      Item.DescProduto := FItens[I].DescProduto;
      Item.Quantidade  := FItens[I].Quantidade;
      Item.VrUnitario  := FItens[I].VrUnitario;
      Item.CalcTotal;
      Pedido.Itens.Add(Item);
    end;

    Pedido.CalcTotal;

    try
      FService.GravarPedido(Pedido);
      ShowMessage(Format(
        'Pedido nº %d gravado com sucesso!'#13#10 +
        'Cliente: %s'#13#10 +
        'Total: R$ %s',
        [Pedido.NrPedido,
         edtNomeCliente.Text,
         FloatParaStr(Pedido.VrTotal)]));

      edtNrPedido.Text := Pedido.NrPedido.ToString;
      LimparFormulario;
    except
      on E: EAppException do
        ShowMessage('Erro ao gravar pedido:'#13#10 + E.Message);
      on E: Exception do
        ShowMessage('Erro inesperado ao gravar pedido:'#13#10 + E.Message);
    end;
  finally
    Pedido.Free;
  end;
end;


procedure TfrmPedido.btnCarregarClick(Sender: TObject);
var
  NrStr  : string;
  Nr     : Integer;
  Pedido : TPedido;
  Item   : TItemPedido;
  Novo   : TItemPedido;
begin
  NrStr := InputBox('Carregar Pedido', 'Informe o número do pedido:', '');
  if Trim(NrStr) = '' then Exit;

  Nr := StrToIntDef(Trim(NrStr), 0);
  if Nr <= 0 then
  begin
    ShowMessage('Número de pedido inválido.');
    Exit;
  end;

  try
    Pedido := FService.CarregarPedido(Nr);
    try
      edtNrPedido.Text    := Pedido.NrPedido.ToString;
      dtpEmissao.Date     := Pedido.DtEmissao;
      edtCodCliente.Text  := Pedido.CodCliente.ToString;
      edtNomeCliente.Text := Pedido.NomeCliente;
      FCodClienteAtual    := Pedido.CodCliente;

      try
        var Cliente := FService.BuscarCliente(Pedido.CodCliente);
        try
          edtCidade.Text := Cliente.Cidade;
          edtUF.Text     := Cliente.UF;
        finally
          Cliente.Free;
        end;
      except end;

      FItens.Clear;
      for Item in Pedido.Itens do
      begin
        Novo             := TItemPedido.Create;
        Novo.CodProduto  := Item.CodProduto;
        Novo.DescProduto := Item.DescProduto;
        Novo.Quantidade  := Item.Quantidade;
        Novo.VrUnitario  := Item.VrUnitario;
        Novo.VrTotal     := Item.VrTotal;
        FItens.Add(Novo);
      end;

      ReconstruirGrid;
      AtualizarTotal;
      AtualizarVisibilidadeBotoes;
    finally
      Pedido.Free;
    end;
  except
    on E: EAppException do
      ShowMessage(E.Message);
    on E: Exception do
      ShowMessage('Erro ao carregar pedido:'#13#10 + E.Message);
  end;
end;


procedure TfrmPedido.btnExcluirClick(Sender: TObject);
var
  NrStr : string;
  Nr    : Integer;
begin
  NrStr := InputBox('Excluir Pedido', 'Informe o número do pedido a excluir:', '');
  if Trim(NrStr) = '' then Exit;

  Nr := StrToIntDef(Trim(NrStr), 0);
  if Nr <= 0 then
  begin
    ShowMessage('Número de pedido inválido.');
    Exit;
  end;

  if MessageDlg(
    Format('Confirma a exclusão do pedido nº %d?'#13#10 +
           'Esta ação não poderá ser desfeita.', [Nr]),
    mtWarning, [mbYes, mbNo], 0) <> mrYes then Exit;

  try
    FService.ExcluirPedido(Nr);
    ShowMessage(Format('Pedido nº %d excluído com sucesso!', [Nr]));
  except
    on E: EAppException do
      ShowMessage(E.Message);
    on E: Exception do
      ShowMessage('Erro ao excluir pedido:'#13#10 + E.Message);
  end;
end;

end.
