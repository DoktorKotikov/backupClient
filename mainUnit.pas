unit mainUnit;

interface

uses
  System.SysUtils, System.Classes, myconfig.ini, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, varsUnit, myconfig.Logs, messageExecute,
  IdExplicitTLSClientServerBase, IdFTP, System.JSON;

type
  TDataModule1 = class(TDataModule)
    TCPClient: TIdTCPClient;
    procedure DataModuleCreate(Sender: TObject);
    procedure TCPClientConnected(Sender: TObject);
    procedure TCPClientDisconnected(Sender: TObject);
    procedure TCPClientStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure TCPClientWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}
procedure OnConnect1();
begin

end;


procedure TDataModule1.DataModuleCreate(Sender: TObject);
var
  JS  : TJSONObject;
  msg : string;
  trycoun   : integer;
  f:TFileStream;
  FileNameFrom:string;
  PathTo:string;
  action, jobId, resultate : string;

  JSparse : TJSONObject;

  resultCode : string;
  test : TNewMessage;
begin
  //TCPClient    := TIdTCPClient.Create;
  try
    log := TLogsSaveClasses.Create();
    log.SaveLog('Start');

    terminatedAll := False;
    ini := TConfigs.Create('config.ini');
    secretKey := ini.GetValue_OrSetDefoult('socket', 'key', 'socketkey').AsString;
    nameClient := ini.GetValue_OrSetDefoult('socket', 'name', 'testClient').AsString;


    TCPClient.Host := ini.GetValue_OrSetDefoult('socket', 'ip', '127.0.0.1').AsString;//записываем хост клиента
    TCPClient.Port := ini.GetValue_OrSetDefoult('socket', 'port', '80').AsInteger;//записываем порт клиента
    trycoun := 0; //определяем счетчик подкючений как ноль
    log.SaveLog('try connect to server ' + TCPClient.Host);
    TCPClient.Connect;//коннектимся к серверу
    log.SaveLog('connected');
   // Sleep(3000);
    repeat//выполнеям пока соединение открыто
  //    if TCPClient.Connected = false then TCPClient.Connect;
    //  Sleep(1000);//спим

      msg := TCPClient.Socket.ReadLn(#10, 5000);

      //определяем msg как одну принятую строку
      if msg <> '' then
      begin
        test := TNewMessage.Create(msg, TCPClient);
     {   resultCode := newMessage(msg); //если строка ответа не пустая, то выполняем функцию newMessage
        try
          jsparse := TJSONObject.ParseJSONValue(msg) as TJSONObject;
          JS := nil;

          try
            //JS := TJSONObject.Create;//  ParseJSONValue(msgForJson) as TJSONObject;
            //if jsparse.TryGetValue('action', action) then JS.AddPair('action', action);
            //if jsparse.TryGetValue('jobId', jobId) then JS.AddPair('jobId', 'jobResult');
            //JS.AddPair('result', TJSONNumber.Create(resultCode));
            //JS.AddPair('msg', msg);

            //log.SaveLog(JS.ToJSON);
            TCPClient.Socket.WriteLn(resultCode);
          finally
            if JS <> nil then JS.Free;
          end;
        finally
          jsparse.free;
        end;
               }
      end;

    until terminatedAll;

  except on E: Exception do
    begin
      log.SaveLog('Start error ' + e.Message);
      raise;
    end;
  end;

  TCPClient.Disconnect;
    //чистим клиента
end;



procedure TDataModule1.TCPClientConnected(Sender: TObject);
var
  msg : string;
  resultCode : integer;
  JS  : TJSONObject;//  ParseJSONValue(msgForJson) as TJSONObject;
begin

  TCPClient.Socket.WriteLn('{"action":"login","key":"'+ secretKey +'","name":"'+nameClient+'"}');//отправляем сообщение в хост (посылаем секретный ключ для проверки)
  msg := TCPClient.Socket.ReadLn;
  JS  := nil;
  try
    JS := TJSONObject.ParseJSONValue(msg) as TJSONObject;
    if (JS.TryGetValue('action', msg) = True) then
    if msg = 'login' then
    if (JS.TryGetValue('result', resultCode) = True) then
    log.SaveLog('Attempt to connecting to TCPServer : '+ TCPClient.Host);
    begin
      if resultCode = 0 then
      begin
        log.SaveLog('[Success] ТСРClient connecting to TCPServer : '+ TCPClient.Host);
      end else
      begin
        msg := '';
        JS.TryGetValue('error', msg);
        log.SaveLog('[Error] Connecting to TCPServer with code:' + resultCode.ToString +', '+ msg);
      end;
    end;
  finally
    if JS <> nil then JS.Free;
  end;
end;

procedure TDataModule1.TCPClientDisconnected(Sender: TObject);
begin
  log.SaveLog('[Attention] Disconnected to TCPServer: '+ TCPClient.Host);
  Sleep(3000);
  TCPClient.Connect;

end;

procedure TDataModule1.TCPClientStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
  Sleep(0);
end;

procedure TDataModule1.TCPClientWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  Sleep(0);
end;

end.
