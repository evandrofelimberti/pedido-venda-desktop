program PedidoVenda;

uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  System.IOUtils,
  FireDAC.DApt,
  Infra.Connection.Manager  in 'src\Infrastructure\Infra.Connection.Manager.pas',
  Infra.ScriptVersao    in 'src\Infrastructure\Infra.ScriptVersao.pas',
  Infra.Repository.Cliente  in 'src\Infrastructure\Infra.Repository.Cliente.pas',
  Infra.Repository.Produto  in 'src\Infrastructure\Infra.Repository.Produto.pas',
  Infra.Repository.Pedido   in 'src\Infrastructure\Infra.Repository.Pedido.pas',
  Core.Exceptions           in 'src\Core\Core.Exceptions.pas',
  Core.Entidades             in 'src\Core\Core.Entidades.pas',
  App.Service.Pedido        in 'src\Application\App.Service.Pedido.pas',
  Frm.Pedido                in 'src\Presentation\Frm.Pedido.pas' {frmPedido};

{$R *.res}

var
  Config   : TConnectionConfig;
  oScriptVersao : TScriptExecucao;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  Config          := TConnectionManager.DefaultConfig;
  {Config.Host     := '127.0.0.1';
  Config.Port     := 3306;
  Config.Database := 'pedidos_db';
  Config.Username := 'root';
  Config.Password := '';           // <── altere aqui
  Config.CharSet  := 'utf8mb4';}

  Config.DatabaseFile := TConnectionManager.GetDataBaseFile;

  TConnectionManager.GetInstance.Configure(Config);

  try
    TConnectionManager.GetInstance.Connect;
  except
    on E: Exception do
    begin
      ShowMessage(
        'Não foi possível conectar ao banco de dados.'#13#10 +
        E.Message + #13#10#13#10 +
        'Verifique as configurações em PedidoVenda.dpr e tente novamente.');
      Exit;
    end;
  end;


  try
    oScriptVersao := TScriptExecucao.Create;
    try
      oScriptVersao.Executar;
    finally
      oScriptVersao.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Aviso na execução das migrations:'#13#10 + E.Message);
  end;

  Application.CreateForm(TfrmPedido, frmPedido);
  Application.Run;

  TConnectionManager.ReleaseInstance;
end.
