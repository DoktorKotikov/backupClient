program backupClient;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  mainUnit in 'mainUnit.pas' {DataModule1: TDataModule},
  varsUnit in 'varsUnit.pas',
  messageExecute in 'messageExecute.pas',
  functionsUnit in 'functionsUnit.pas',
  filesUnit in 'filesUnit.pas';

begin
  try
    DataModule1 := TDataModule1.Create(nil);

    repeat
      Sleep(1000);
    until terminatedAll ;
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
