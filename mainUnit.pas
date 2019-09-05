unit mainUnit;

interface

uses
  System.SysUtils, System.Classes, myconfig.ini, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, varsUnit, myconfig.Logs, messageExecute,
  IdExplicitTLSClientServerBase, IdFTP;

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
  f:TFileStream;
  FileNameFrom:string;
  PathTo:string;

begin
  FTP     := TIdFTP.create;
  terminatedAll := False;
  ini := TConfigs.Create('config.ini');
  log := TLogsSaveClasses.Create();
  secretKey := ini.GetValue('socket', 'key').AsString;
  nameClient := ini.GetValue_OrSetDefoult('socket', 'name', 'testClient').AsString;

  FTP.Host:=ini.GetValue_OrSetDefoult('FTPS', 'ip', '127.0.0.1').AsString;
  FTP.Port:=ini.GetValue_OrSetDefoult('FTPS', 'port', '20').AsInteger;
  FTP.DataPort:=ini.GetValue_OrSetDefoult('FTPS', 'dataport', '21').AsInteger;
  FTP.Username := ini.GetValue_OrSetDefoult('FTPS', 'username', 'username').AsString;
  FTP.Password := ini.GetValue_OrSetDefoult('FTPS', 'pass', 'password').AsString;

 trycoun := 0; //���������� ������� ���������� ��� ����
  repeat//��������� ���� ���������� �������
    try//������� ��������� try
      FTP.Connect;//����������� � �������
      FTP.Login;
      log.SaveLog('Connect to ' +FTP.Host);
      FTP.Put('','');
      trycoun := 0; //���������� ������� ���������� ��� ����

      repeat //��������� ���� ���������� �������
        msg := FTP.Socket.ReadLn;//���������� msg ��� ���� �������� ������
        log.SaveLog(msg);
        if msg <> '' then newMessage(msg); //���� ������ ������ �� ������, �� ��������� ������� newMessage
        {
      FileNameFrom:='C:\test\11121.txt';
      PathTo:= 'c:\';
      begin
          f:=TFileStream.Create(FileNameFrom,fmOpenRead);
           try
            IdFTP1.ChangeDir(PathTo);
            idftp1.Put(f,PathTo+ExtractFileName(FileNameFrom));
            log.SaveLog('File '+FileNameFrom+ ' will be put');
           except
            log.SaveLog('Error, file '+FileNameFrom+' dont put');
           end;
            f.Free;
      end;
      }

      until terminatedAll;

    except //���������, ���� ������� ������ � try
      Inc(trycoun);//���������� ������� �����������
      Sleep(1000 * trycoun);//����
   //   if trycoun > 100 then terminatedAll := True;

      try//���������� �� �����, ����� �� ���� ���������� �����������
        FTP.Disconnect;
      except
      end;
    end;
  until terminatedAll;
  FTP.Disconnect;
  FTP.Free;

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
        //msg := IdTCPClient1.Socket.ReadLn;//���������� msg ��� ���� �������� ������
        //if msg <> '' then newMessage(msg); //���� ������ ������ �� ������, �� ��������� ������� newMessage

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
  IdTCPClient1.Free;
    //������ �������
end;



end.
