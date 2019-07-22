unit functionsUnit;

interface

uses
  System.SysUtils, System.Classes, varsUnit;


function foundFiles(dir: string) : TStringList;

implementation

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
