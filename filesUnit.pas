unit filesUnit;

interface

uses System.Generics.Collections, System.Classes, varsUnit;

type

  TFileDirAndName = record
    FileDir, FileName : string;
  end;
  TAFileDirAndName = array of TFileDirAndName;

  TSendConfig = record
    Host, Username, Password : string;
    Port, DataPort : Integer;
  end;

  TJobConf = class
  private
    fdirout  : string;
    farchivate : boolean;
  public
    FileList : TAFileDirAndName;
    constructor Create(dirout : string; archivate : boolean);
    procedure AddFile2List(Dir, FileName : string);
 //   function  GetAllFiles() : TAFileDirAndName;
    function  GettDirOut(): string;
    function  GettArch(): boolean;

  end;



  TAllJobs = class
  private
    Jobs : TDictionary<string, TJobConf>;

  public
    SendConfig : TSendConfig;
    constructor Create();
    procedure AddNewFile(Dir, FileName : string; dirout : string; archivate : boolean);
    function  GetCount : integer;
    function  GetJob(index : integer) : TJobConf;
  end;



//var
 // AllJobs : TAllJobs;


implementation

constructor TJobConf.Create(dirout : string; archivate : boolean);
begin
  SetLength(FileList, 0);
  fdirout     := dirout;
  farchivate  := archivate;
end;

procedure TJobConf.AddFile2List(Dir, FileName : string);
begin
  SetLength(FileList, Length(FileList)+1);
  FileList[Length(FileList)-1].FileDir  := Dir;
  FileList[Length(FileList)-1].FileName := FileName;
end;
 {
function  TJobConf.GetAllFiles() : TAFileDirAndName;
begin
  Result := FileList;
end; }

function  TJobConf.GettDirOut(): string;
begin
  Result := fdirout;
end;

function  TJobConf.GettArch(): boolean;
begin
  Result := farchivate;
end;

////////////////////////////////////////////////////////////////////////////////

constructor TAllJobs.Create();
begin
  Jobs := TDictionary<string, TJobConf>.Create();
end;


procedure TAllJobs.AddNewFile(Dir, FileName : string; dirout : string; archivate : boolean);
var
  Job : TJobConf;
begin
  if Jobs.TryGetValue(dirout, Job) then
  begin
    Job.AddFile2List(Dir, FileName);
  end else
  begin
    Job := TJobConf.Create(dirout, archivate);
    Job.AddFile2List(Dir, FileName);
    Jobs.Add(dirout, Job);
  end;
end;

function  TAllJobs.GetCount : integer;
begin
  Result := Jobs.Count;
end;

function  TAllJobs.GetJob(index : integer) : TJobConf;
begin
  Result := Jobs.Values.ToArray[index]  ;
end;

end.
