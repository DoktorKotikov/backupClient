unit mainUnit;

interface

uses
  System.SysUtils, System.Classes, myconfig.ini, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, varsUnit, myconfig.Logs, messageExecute;

type
  TDataModule1 = class(TDataModule)
    IdTCPClient1: TIdTCPClient;
    procedure DataModuleCreate(Sender: TObject);
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

procedure TDataModule1.DataModuleCreate(Sender: TObject);
var
  msg : string;
  trycoun   : integer;

begin
  terminatedAll := False;
  ini := TConfigs.Create('config.ini');
  log := TLogsSaveClasses.Create();
  secretKey := ini.GetValue('socket', 'key').AsString;
  nameClient := ini.GetValue_OrSetDefoult('socket', 'name', 'testClient').AsString;

//  IdTCPClient1 := TIdTCPClient.Create;//создаем TIdTCPClient

  IdTCPClient1.Host := ini.GetValue_OrSetDefoult('socket', 'ip', '127.0.0.1').AsString;//записываем хост клиента
  IdTCPClient1.Port := ini.GetValue_OrSetDefoult('socket', 'port', '80').AsInteger;//записываем порт клиента

  trycoun := 0; //определяем счетчик подкючений как ноль
  repeat//выполнеям пока соединение открыто
    try//пробуем выполнить try
      IdTCPClient1.Connect;//коннектимся к серверу
      IdTCPClient1.Socket.WriteLn('{"action":"login","key":"'+ secretKey +'","name":"'+nameClient+'"}');//отправляем сообщение в хост (посылаем секретный ключ для проверки)
      trycoun := 0; //определяем счетчик подкючений как ноль
      repeat //повторять пока соединение открыто
        msg := IdTCPClient1.Socket.ReadLn;//определяем msg как одну принятую строку
        if msg <> '' then newMessage(msg); //если строка ответа не пустая, то выполняем функцию newMessage

      until terminatedAll;
    except //выполняем, если словили ошибку в try
      Inc(trycoun);//прибавляем счетчик подключений
      Sleep(1000 * trycoun);//спим
   //   if trycoun > 100 then terminatedAll := True;

      try//отрубаемся от серва, чтобы не было повторного подключения
        IdTCPClient1.Disconnect;
      except
      end;
    end;
  until terminatedAll;


  IdTCPClient1.Disconnect;
  IdTCPClient1.Free;  //чистим клиента
end;

end.
