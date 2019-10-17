unit serviceUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, mainUnit;

type
  TBackupAgent = class(TService)
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceExecute(Sender: TService);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  BackupAgent: TBackupAgent;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  BackupAgent.Controller(CtrlCode);
end;

function TBackupAgent.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TBackupAgent.ServiceCreate(Sender: TObject);
begin
  DataModule1:= TDataModule1.create(nil);
end;

procedure TBackupAgent.ServiceExecute(Sender: TService);
begin
  While terminated = false  do
  begin
    WaitMessage;
    ServiceThread.ProcessRequests(False);
  end;
end;

end.
