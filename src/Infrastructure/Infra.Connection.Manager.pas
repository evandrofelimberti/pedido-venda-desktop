unit Infra.Connection.Manager;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  Core.Exceptions,
  System.IOUtils;

type
  TConnectionConfig = record
  {  Host     : string;
    Port     : Integer;
    Database : string;
    Username : string;
    Password : string;
    CharSet  : string;}
    DatabaseFile : string;
  end;

  TConnectionManager = class
  private
    class var FInstance : TConnectionManager;
    FConnection         : TFDConnection;
    FDriverLink         : TFDPhysSQLiteDriverLink;
    FConfig             : TConnectionConfig;

    constructor CreatePrivate;
    procedure   BuildConnectionParams;
  public
    destructor Destroy; override;

    class function  GetInstance: TConnectionManager;
    class procedure ReleaseInstance;

    procedure Configure(const AConfig: TConnectionConfig);
    procedure Connect;
    procedure Disconnect;
    function  IsConnected: Boolean;
    function  GetConnection: TFDConnection;

    class function DefaultConfig: TConnectionConfig;
    class function GetDataBaseFile: string;
  end;

implementation

uses
  System.SysUtils;

{ TConnectionManager }

constructor TConnectionManager.CreatePrivate;
begin
  inherited Create;
  FConnection := TFDConnection.Create(nil);
  FDriverLink := TFDPhysSQLiteDriverLink.Create(nil);
end;

destructor TConnectionManager.Destroy;
begin
  Disconnect;
  FConnection.Free;
  FDriverLink.Free;
  inherited;
end;

class function TConnectionManager.GetInstance: TConnectionManager;
begin
  if not Assigned(FInstance) then
    FInstance := TConnectionManager.CreatePrivate;
  Result := FInstance;
end;

class procedure TConnectionManager.ReleaseInstance;
begin
  FreeAndNil(FInstance);
end;

class function TConnectionManager.DefaultConfig: TConnectionConfig;
begin
  {Result.Host     := 'localhost';
  Result.Port     := 3306;
  Result.Database := 'pedidos_db';
  Result.Username := 'root';
  Result.Password := '';
  Result.CharSet  := 'utf8mb4';}
  Result.DatabaseFile := GetDataBaseFile;
end;

procedure TConnectionManager.Configure(const AConfig: TConnectionConfig);
begin
  FConfig := AConfig;
end;

procedure TConnectionManager.BuildConnectionParams;
begin
{  FConnection.DriverName := 'MySQL';
  FConnection.Params.Clear;
  FConnection.Params.Add('DriverID=MySQL');
  FConnection.Params.Add('Server='       + FConfig.Host);
  FConnection.Params.Add('Port='         + FConfig.Port.ToString);
  FConnection.Params.Add('Database='     + FConfig.Database);
  FConnection.Params.Add('User_Name='    + FConfig.Username);
  FConnection.Params.Add('Password='     + FConfig.Password);
  FConnection.Params.Add('CharacterSet=' + FConfig.CharSet);}

   FConnection.DriverName := 'SQLite';
  FConnection.Params.Clear;
  FConnection.Params.Add('DriverID=SQLite');
  FConnection.Params.Add('Database=' + FConfig.DatabaseFile);

  FConnection.Params.Add('SQLiteAdvanced=foreign_keys=ON');
end;

procedure TConnectionManager.Connect;
begin
  BuildConnectionParams;
  try
    FConnection.Connected := True;
  except
    on E: Exception do
      raise EConnectionException.CreateFmt(
        'Falha ao conectar com o banco de dados.'#13#10'%s', [E.Message]);
  end;
end;

procedure TConnectionManager.Disconnect;
begin
  if Assigned(FConnection) and FConnection.Connected then
    FConnection.Connected := False;
end;

function TConnectionManager.IsConnected: Boolean;
begin
  Result := Assigned(FConnection) and FConnection.Connected;
end;

function TConnectionManager.GetConnection: TFDConnection;
begin
  if not IsConnected then
    raise EConnectionException.Create('Conexão com o banco não está ativa.');
  Result := FConnection;
end;

class function TConnectionManager.GetDataBaseFile: string;
var
  ExeDir, ProjectRoot: string;
begin
  ExeDir := ExtractFilePath(ParamStr(0));
  ProjectRoot := ExpandFileName(TPath.Combine(ExeDir, '..\..\'));

  Result := TPath.Combine(ProjectRoot, 'src\Data\pedidos.db');
  if FileExists(Result) then
    Exit;

  raise Exception.Create('Banco não encontrado. Tentativas:'#13#10 +
    TPath.Combine(ExeDir, 'pedidos.db') + #13#10 +
    TPath.Combine(ProjectRoot, 'src\Data\pedidos.db'));

end;

end.
