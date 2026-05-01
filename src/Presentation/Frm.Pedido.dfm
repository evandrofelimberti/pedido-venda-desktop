object frmPedido: TfrmPedido
  Left = 0
  Top = 0
  Caption = 'Pedido de Venda'
  ClientHeight = 687
  ClientWidth = 976
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlCabecalho: TPanel
    Left = 0
    Top = 0
    Width = 976
    Height = 120
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 972
    object gbCliente: TGroupBox
      Left = 6
      Top = 4
      Width = 968
      Height = 112
      Caption = ' Dados do Pedido '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object lblNrPedido: TLabel
        Left = 12
        Top = 26
        Width = 57
        Height = 15
        Caption = 'N'#186' Pedido:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblEmissao: TLabel
        Left = 170
        Top = 26
        Width = 46
        Height = 15
        Caption = 'Emiss'#227'o:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCodCliente: TLabel
        Left = 12
        Top = 64
        Width = 82
        Height = 15
        Caption = 'C'#243'digo Cliente:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblNome: TLabel
        Left = 204
        Top = 64
        Width = 36
        Height = 15
        Caption = 'Nome:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCidade: TLabel
        Left = 574
        Top = 64
        Width = 40
        Height = 15
        Caption = 'Cidade:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblUF: TLabel
        Left = 854
        Top = 64
        Width = 17
        Height = 15
        Caption = 'UF:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtNrPedido: TEdit
        Left = 82
        Top = 22
        Width = 72
        Height = 23
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        Text = '(novo)'
      end
      object dtpEmissao: TDateTimePicker
        Left = 224
        Top = 22
        Width = 130
        Height = 23
        Date = 46141.000000000000000000
        Time = 0.669585057868971500
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object edtCodCliente: TEdit
        Left = 116
        Top = 60
        Width = 72
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnChange = edtCodClienteChange
        OnExit = edtCodClienteExit
        OnKeyPress = edtCodClienteKeyPress
      end
      object edtNomeCliente: TEdit
        Left = 248
        Top = 60
        Width = 310
        Height = 23
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 3
      end
      object edtCidade: TEdit
        Left = 618
        Top = 60
        Width = 220
        Height = 23
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 4
      end
      object edtUF: TEdit
        Left = 878
        Top = 60
        Width = 46
        Height = 23
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 5
      end
    end
  end
  object pnlItem: TPanel
    Left = 0
    Top = 120
    Width = 976
    Height = 78
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 972
    object gbProduto: TGroupBox
      Left = 6
      Top = 2
      Width = 968
      Height = 72
      Caption = ' Informar Produto '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object lblCodProduto: TLabel
        Left = 12
        Top = 28
        Width = 74
        Height = 15
        Caption = 'C'#243'd. Produto:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblQtd: TLabel
        Left = 510
        Top = 28
        Width = 23
        Height = 15
        Caption = 'Qtd:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblVrUnit: TLabel
        Left = 634
        Top = 28
        Width = 42
        Height = 15
        Caption = 'Vr.Unit.:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtCodProduto: TEdit
        Left = 96
        Top = 24
        Width = 72
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnExit = edtCodProdutoExit
        OnKeyPress = edtCodProdutoKeyPress
      end
      object edtDescProduto: TEdit
        Left = 178
        Top = 24
        Width = 318
        Height = 23
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 1
      end
      object edtQuantidade: TEdit
        Left = 540
        Top = 24
        Width = 80
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        Text = '1'
        OnKeyPress = edtQuantidadeKeyPress
      end
      object edtVrUnitario: TEdit
        Left = 690
        Top = 24
        Width = 104
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        Text = '0,00'
        OnKeyPress = edtVrUnitarioKeyPress
      end
      object btnInserir: TButton
        Left = 810
        Top = 20
        Width = 148
        Height = 34
        Caption = 'Inserir Produto'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 4
        OnClick = btnInserirClick
      end
    end
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 637
    Width = 976
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    Color = 4210752
    ParentBackground = False
    TabOrder = 2
    ExplicitTop = 636
    ExplicitWidth = 972
    object lblTotalLabel: TLabel
      Left = 14
      Top = 16
      Width = 121
      Height = 17
      Caption = 'TOTAL DO PEDIDO:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblVrTotal: TLabel
      Left = 144
      Top = 12
      Width = 66
      Height = 25
      Caption = 'R$ 0,00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnGravar: TButton
      Left = 494
      Top = 10
      Width = 150
      Height = 30
      Caption = 'Gravar Pedido'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnGravarClick
    end
    object btnCarregar: TButton
      Left = 656
      Top = 10
      Width = 150
      Height = 30
      Caption = 'Carregar Pedido'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnCarregarClick
    end
    object btnExcluir: TButton
      Left = 818
      Top = 10
      Width = 150
      Height = 30
      Caption = 'Excluir Pedido'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnExcluirClick
    end
  end
  object sgItens: TStringGrid
    Left = 0
    Top = 198
    Width = 976
    Height = 439
    Align = alClient
    ColCount = 6
    DefaultColWidth = 90
    DefaultRowHeight = 22
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goDrawFocusSelected, goRowSelect]
    TabOrder = 3
    OnDrawCell = sgItensDrawCell
    OnKeyDown = sgItensKeyDown
    ExplicitWidth = 972
    ExplicitHeight = 438
    ColWidths = (
      40
      90
      300
      90
      105
      105)
  end
end
