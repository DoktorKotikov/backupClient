unit functionsUnit;

interface

uses
  System.SysUtils, System.Classes, varsUnit;


function foundFiles(dir: string) : TStringList;
function GetSubDirectories(Dir : string): TStringList;

implementation

function GetSubDirectories(Dir : string): TStringList;
var
  i : Integer;
  tempstr : string;
begin
  Result := TStringList.Create;
  Result.Clear;
  tempstr := '';
  for I := 1 to length(Dir) do
  begin
    if Dir[i] = '/' then
    begin
      Result.Add(tempstr);
      tempstr := '';
    end else
    begin
      tempstr := tempstr + Dir[i];
    end;
  end;
 // Result.Add(tempstr);
end;

function foundFiles(dir: string) : TStringList;
var
  SR: TSearchRec;
  FindRes: Integer;
begin

  result := TStringList.Create;
  result.Clear;
 // dir := 'C:\test\*.*';

  FindRes := FindFirst(dir + '\*.*', faAnyFile, SR);  // C:|D:\\(.+\\)*(.+)\.(.+)$
  while FindRes = 0 do
  begin

    if ((SR.Attr and faDirectory) = faDirectory) and ((SR.Name = '.') or (SR.Name = '..')) then
    begin
      FindRes := FindNext(SR);
      Continue;
    end;
    result.Add(SR.Name);
    FindRes := FindNext(SR);
  end;
  FindClose(SR);
//  RegExp := null;
end;

end.
