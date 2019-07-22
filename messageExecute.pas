unit messageExecute;

interface

uses varsUnit, System.Classes, System.JSON, System.sysutils, 
  functionsUnit, System.RegularExpressions, System.Generics.Collections
  , IdTCPConnection, IdTCPClient, filesUnit, System.Hash;


function newMessage(msg : string): Integer;//функция нового сообщения, которая видна всему проекту


implementation



function checkLoginAnswer(check : TJSONObject): Integer; //функция проверки логина к серву
begin
  if check.TryGetValue('result', result) = True then//если получили переменную result, то проверяем
  begin
    if Result <> 0 then//если result не равна 0
    begin
      terminatedAll := true; //соединение закрыто
      log.SaveLog('Result is bad'); //сохраняем в лог ошибку входа (не тот ключ)
    end;
  end else //либо
  begin
    terminatedAll := true;//соединение закрыто
    log.SaveLog('Result is Not Found'); //переменной result не было найдено
  end;

end;

procedure SendToServer(Job : TAllJobs);//процедура отправки файла на сервер
var
//  JSforFile : TJSONArray; //
  JSAction  : TJSONObject;//
  jsRead : TJSONObject;
  msgForJson : string;
  request : string;
  action : string;
  
  I, j, K    : Integer; //
  boofNmb : Int64;
  FileStr : TFileStream;
  boof    : Byte; // array [0 .. 0] of 
  TCPClient : TIdTCPClient;

  DirOut  : string;
  Arch    : Boolean;
  count   : integer;
  HashMD5 : THashMD5;
begin
  count := Job.GetCount();
  for I := 0 to count-1 do
  begin
//    files := ;
    for j := 0 to Length(Job.GetJob(i).FileList)-1 do
    begin
      DirOut := Job.GetJob(i).GettDirOut;
      Arch   := Job.GetJob(i).GettArch;

      HashMD5 := THashMD5.Create;
      JSAction :=  TJSONObject.Create;//
      JSAction.AddPair('action', 'sendfile');//
      JSAction.AddPair('key', secretKey);
      JSAction.AddPair('outDir', DirOut);
      JSAction.AddPair('fileName', Job.GetJob(i).FileList[j].FileName);
      JSAction.AddPair('MD5', HashMD5.GetHashStringFromFile(Job.GetJob(i).FileList[j].FileDir +'\'+Job.GetJob(i).FileList[j].FileName));

      FileStr := TFileStream.Create(Job.GetJob(i).FileList[j].FileDir +'\'+Job.GetJob(i).FileList[j].FileName, fmOpenRead);
      JSAction.AddPair('fileSize', TJSONNumber.Create(FileStr.Size));
      
         

      TCPClient := TIdTCPClient.Create;//создаем TCPClient
      TCPClient.Host := ini.GetValue_OrSetDefoult('socket', 'ip', '127.0.0.1').AsString;//записываем хост клиента
      TCPClient.Port := ini.GetValue_OrSetDefoult('socket', 'port', '80').AsInteger;//записываем порт клиента

      TCPClient.Connect;//коннектимся к серверу
     
      TCPClient.Socket.WriteLn(JSAction.ToJSON);


      log.SaveLog(Job.GetJob(i).FileList[j].FileDir  +' '+Job.GetJob(i).FileList[j].FileName +' =>> '+ DirOut); 
      boofNmb := 0;

      while FileStr.Position <> FileStr.Size do
      begin      
        inc(boofNmb);
        FileStr.ReadBuffer(boof, SizeOf(boof));
        TCPClient.Socket.Write(boof);  
      end;
      msgForJson := TCPClient.Socket.ReadLn();
      jsRead := nil;
      jsRead := TJSONObject.ParseJSONValue(msgForJson) as TJSONObject;
      try
        if jsRead.TryGetValue('action', action) = True then
        begin
          if (action = 'getRequestOfFileSending') then
            begin
            if jsRead.TryGetValue('request', request) = True then
              begin
                if request = 'true'  then
                begin
                   //return?
                end;
                if request = 'false' then
                begin
                log.SaveLog('Error send File: file not send ' + job.GetJob(i).FileList[j].FileName);
                end;
              end;
            end;
           
        end else
        begin
          Log.SaveLog('Error SendToServer : Action not found');
        end;
      finally
      jsRead.Free;

      end;
   //   TCPClient.Disconnect;
   //   TCPClient.Free;  
    end;    
  end;
    
(*  for Pattern in outDirs.Keys do
  begin
    outDirs.TryGetValue(Pattern, files);
    for I := 0 to files.Count-1 do
    begin
      TCPClient := TIdTCPClient.Create;//создаем TCPClient
      TCPClient.Host := ini.GetValue_OrSetDefoult('socket', 'ip', '127.0.0.1').AsString;//записываем хост клиента
      TCPClient.Port := ini.GetValue_OrSetDefoult('socket', 'port', '80').AsInteger;//записываем порт клиента

      TCPClient.Connect;//коннектимся к серверу
      TCPClient.Socket.WriteLn('{"action":"sendfile","key":"'+ secretKey +'"}');

      log.SaveLog(Pattern +' '+files[i]); 
      boofNmb := 0;
      FileStr := TFileStream.Create(files[i], fmOpenRead);
      while FileStr.Position <> FileStr.Size do
      begin      
        inc(boofNmb);
        FileStr.ReadBuffer(boof, SizeOf(boof));
        TCPClient.Socket.Write(boof);  
      end;

   //   TCPClient.Disconnect;
   //   TCPClient.Free;  
    end;
  end;
  *)

  Sleep(0);
end;

function newJob(all_jobs : TJSONObject): Integer;  //функция новая задача
var
  JSArr : TJSONArray;//добавляем переменную JsARR как массив джсон
  i, j, k : Integer; // i  как интеджер
  dir, Pattern, dirout, archivate, sendto : string;  //дир и регексп как строковый
  filesList : Tstringlist;  //файллист как список

  archivate_bool  : Boolean;
  dirout_temp     : string;
  
  RegExp: TRegEx;
  RegExpReslt : TMatch; 

  Job : TAllJobs;
begin
  Job := TAllJobs.Create;
// {"action":"newJob", "sendto":"server", "job":[{"dir":"c123123", "Pattern":"ddd*","dirout":"(1)jhgjj(2).zip","archivate":"true"},{"dir":"c123123", "Pattern":"ddd*","dirout":"(1)jhgjj(2).zip","archivate":"false"},{"dir":"c123123", "Pattern":"ddd*","dirout":"(1)jhgjj(2).zip","archivate":"false"}]}
  all_jobs.TryGetValue('job', JSArr);//в all_jobs
  log.SaveLog(all_jobs.ToJSON);
  
  for I := 0 to JSArr.Count-1 do
  begin  
    if JSArr.Items[i].TryGetValue('archivate', archivate) = true then
    begin
      if (archivate.ToLower = 'true') or (archivate = '1') then archivate_bool := True else archivate_bool := False;
    end else
    begin
      archivate_bool := false;
    end;
  
    if JSArr.Items[i].TryGetValue('dir', dir) 
      and JSArr.Items[i].TryGetValue('Pattern', Pattern)
      and JSArr.Items[i].TryGetValue('dirout', dirout) then      
    begin
      RegExp:= TRegEx.Create(Pattern);  
      filesList := foundFiles(dir);
      for j := filesList.Count-1 downto 0 do
      begin
        RegExpReslt := RegExp.Match(filesList[j]);
        if RegExpReslt.Success = true then
        begin
          dirout_temp := dirout;
          for k := 1 to RegExpReslt.Groups.Count-1 do
          begin           
            dirout_temp := StringReplace(dirout_temp, '($'+k.ToString+')', RegExpReslt.Groups.Item[k].Value, [rfReplaceAll]);
          end;
          Job.AddNewFile(dir, filesList[j], dirout_temp, archivate_bool);
        end;
      end;
            
    end else
    begin
      log.savelog('Error newJob: Not found value of dir or pattern');// error log
    end;
  end;

  if all_jobs.TryGetValue('sendto', sendto) then
  begin
    if sendto = 'server' then SendToServer(Job);
    if sendto = 'client' then 
    if sendto = 'FTP' then 
    
        
  end else
  begin
    log.savelog('Error newJob: Not found Send function');// error log
  end;
  Job.Free;
end;

function newMessage(msg : string): Integer; //функция нового сообщения, которая не видна проекту, а только этому юниту
var
  js : TJSONObject;//новая переменная js как json объект
  action : string;  //переменная action
begin
  Result := 0;  //задаем result значение 0
  js := nil;  //обнуляем js
  log.SaveLog('new msg : ' + msg);  //сохраняем в лог новое пришедшее сообщение
  try
    js := TJSONObject.ParseJSONValue(msg) as TJSONObject;//переопределяем js как распаршеное сообщение msg
    try
      if js.TryGetValue('action', action) = True then //если в msg есть action
      begin
        if action = 'newJob' then Result := newJob(js); //если action ссылается на newJob, то выполняем функцию newJob
        if action = 'login' then Result := checkLoginAnswer(js);//если action ссылается на login, то выполняем функцию checkLoginAnswer
        if action = 'newJob2' then Result := 0; {*newFunction*}
        if action = 'newJob3' then Result := 0; {*newFunction*}
        if action = 'newJob4' then Result := 0; {*newFunction*}




      end else
      begin
        Log.SaveLog('Error newMessage : Action not found'); //усли action не найдет, то пишем в лог ошибку
        Result := notFoundsActions;//переопределяем result

      end;
    finally
      js.Free; //освобождаем js
    end;

  except
    on E: Exception do
    begin
      Log.SaveLog('Error newMessage :' + E.Message);
      Result := errorExcept;
    end;
  end;



end;

end.
