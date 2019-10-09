unit AWSUnit;

interface

uses varsUnit, System.Classes, System.JSON, System.sysutils, filesUnit, Winapi.ShellAPI;

//function SendToAWS(Job : TAllJobs) : TJSONObject;

implementation
{
function SendToAWS(Job : TAllJobs) : TJSONObject;
var
  path : string;
  outputShell : THandle;
  js_result : TJSONObject;
begin
  js_result := nil;
  js_result := TJSONObject.Create;
  path := '/C "C:\Delphi\progLib\consolka\Win32\Debug\consolka.exe"';
  ShellExecute(0, PChar('open'), 'cmd.exe', PChar(path),nil,5);
  ShellExecute(0, PChar('print'), 'cmd.exe', PChar(path),nil,5);
  js_result.AddPair('response_code', '0');
  js_result.AddPair('response_string','[Success]');
  Result := js_result;

end;
   }
end.
