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

//  IdTCPClient1 := TIdTCPClient.Create;//������� TIdTCPClient

  IdTCPClient1.Host := ini.GetValue_OrSetDefoult('socket', 'ip', '127.0.0.1').AsString;//���������� ���� �������
  IdTCPClient1.Port := ini.GetValue_OrSetDefoult('socket', 'port', '80').AsInteger;//���������� ���� �������

  trycoun := 0; //���������� ������� ���������� ��� ����
  repeat//��������� ���� ���������� �������
    try//������� ��������� try
      IdTCPClient1.Connect;//����������� � �������
      IdTCPClient1.Socket.WriteLn('{"action":"login","key":"'+ secretKey +'","name":"'+nameClient+'"}');//���������� ��������� � ���� (�������� ��������� ���� ��� ��������)
      trycoun := 0; //���������� ������� ���������� ��� ����
      repeat //��������� ���� ���������� �������
        msg := IdTCPClient1.Socket.ReadLn;//���������� msg ��� ���� �������� ������
        if msg <> '' then newMessage(msg); //���� ������ ������ �� ������, �� ��������� ������� newMessage

      until terminatedAll;
    except //���������, ���� ������� ������ � try
      Inc(trycoun);//���������� ������� �����������
      Sleep(1000 * trycoun);//����
   //   if trycoun > 100 then terminatedAll := True;

      try//���������� �� �����, ����� �� ���� ���������� �����������
        IdTCPClient1.Disconnect;
      except
      end;
    end;
  until terminatedAll;


  IdTCPClient1.Disconnect;
  IdTCPClient1.Free;  //������ �������
end;

end.
