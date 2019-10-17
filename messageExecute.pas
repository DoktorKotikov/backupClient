unit messageExecute;

interface

uses varsUnit, System.Classes, System.JSON, System.sysutils,
  functionsUnit, System.RegularExpressions, System.Generics.Collections
  , IdTCPConnection, IdTCPClient, filesUnit, System.Hash, idftp, AWSUnit;


function newMessage(msg : string) : string;

type

  TNewMessage = class(TThread)
    public
      constructor Create(msg : string; TCPClient: TIdTCPClient);
    protected
      fmsg : string;
      fTCPClient  : TIdTCPClient;
      procedure Execute; override;
  end;


implementation


constructor TNewMessage.Create(msg : string; TCPClient: TIdTCPClient);
begin
  inherited Create(false);
  fmsg := msg;
  fTCPClient := TCPClient;
end;

procedure TNewMessage.Execute;
var
  resultCode : string;
begin
  resultCode := newMessage(fmsg);
  fTCPClient.Socket.WriteLn(resultCode);
end;

////////////////////////////////////////////////////////////////////////////////


function checkLoginAnswer(check : TJSONObject): Integer;
begin
  if check.TryGetValue('result', result) = True then
  begin
    if Result <> 0 then
    begin
      terminatedAll := true;
      log.SaveLog('[Error] Result is bad');
    end;
  end else
  begin
    terminatedAll := true;//соединение закрыто
    log.SaveLog('[Error] Result is Not Found');
  end;

end;



procedure SendToServer(Job : TAllJobs);
var
//  JSforFile : TJSONArray; //
  JSAction  : TJSONObject;//
  jsRead : TJSONObject;
  msgForJson : string;
  request : string;
  action : string;

  I, j, K    : Integer;
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
      JSAction :=  TJSONObject.Create;
      JSAction.AddPair('action', 'sendfile');
      JSAction.AddPair('key', secretKey);
      JSAction.AddPair('outDir', DirOut);
      JSAction.AddPair('fileName', Job.GetJob(i).FileList[j].FileName);
      JSAction.AddPair('MD5', HashMD5.GetHashStringFromFile(Job.GetJob(i).FileList[j].FileDir +'\'+Job.GetJob(i).FileList[j].FileName));

      FileStr := TFileStream.Create(Job.GetJob(i).FileList[j].FileDir +'\'+Job.GetJob(i).FileList[j].FileName, fmOpenRead);
      JSAction.AddPair('fileSize', TJSONNumber.Create(FileStr.Size));



      TCPClient := TIdTCPClient.Create;
      TCPClient.Host := ini.GetValue_OrSetDefoult('socket', 'ip', '127.0.0.1').AsString;
      TCPClient.Port := ini.GetValue_OrSetDefoult('socket', 'port', '80').AsInteger;

      TCPClient.Connect;
     
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

      TCPClient.Connect;//коннектимс€ к серверу
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

function SendToFTP(Job : TAllJobs) : TJSONObject;
var
  jsRead : TJSONObject;
  msgForJson : string;
  request : string;
  action : string;

  I, j, K, p    : Integer;
  boofNmb : Int64;
  boof    : Byte; // array [0 .. 0] of
  //idftp   : TIdFTP;

  DirOut  : string;
  Arch    : Boolean;
  count   : integer;
  HashMD5 : THashMD5;
  FTP     : TIdFTP;
  FTPDirs : TStringList;
  tempDir : string;

  js_result : TJSONObject;

  templ_str : string;
  ftpfiles : TStringList;
begin
  FTP := nil;
  js_result := nil;
  result := nil;
  result:=TJSONObject.Create;
  js_result:=TJSONObject.Create;
  ftpfiles := TStringList.Create;

  try
    try
      FTP     := TIdFTP.create;
      FTP.Host:=Job.SendConfig.Host;
      FTP.Port:=Job.SendConfig.Port;
      FTP.DataPort:=Job.SendConfig.DataPort;
      FTP.Username := Job.SendConfig.Username;
      FTP.Password := Job.SendConfig.Password;

      count := Job.GetCount();
      for I := 0 to count-1 do
      begin
      //files := ;
        for j := 0 to Length(Job.GetJob(i).FileList)-1 do
        begin
          DirOut := Job.GetJob(i).GettDirOut;
          Arch   := Job.GetJob(i).GettArch;

          if FTP.Connected = false then
          try
            log.SaveLog('Attempt to connecting to FTPServer : ' + FTP.Host);
            FTP.Connect;
            FTP.Login;
            FTP.Passive := True;
            log.SaveLog('[Success] Connecting to FTPServer : ' + FTP.Host);
          except;
            log.SaveLog('[Error] Connecting to FTPServer : ' + FTP.Host);
            js_result.AddPair('response_code', '2');
            js_result.AddPair('response_string', 'Error connecting to FTP server : ' + FTP.Host);
            Result := js_result;
            Exit;
          end;
          FTPDirs := GetSubDirectories(DirOut);
          tempDir := '/';
          for k := 0 to FTPDirs.Count-1 do
          begin
            tempDir := tempDir + FTPDirs[k] +'/';
            try
              FTP.ChangeDir(tempDir);
            except on E: Exception do
              begin
                FTP.MakeDir(tempDir);
              end;
            end;
          end;
          //log.SaveLog('Attempt to transfer file to FTPServer ' + FTP.Host + ' : ' + ' ' + Job.GetJob(i).FileList[j].FileDir  +' '+Job.GetJob(i).FileList[j].FileName +' =>> '+ DirOut + Job.GetJob(i).FileList[j].FileName);
          FTP.List(ftpfiles, '', False);
          if ftp.DirectoryListing.Count <> 0 then
          begin
            for p := 0 to ftpfiles.Count - 1 do
            begin
              if ftpfiles.IndexOf(Job.GetJob(i).FileList[j].FileName) = -1 then
              begin
                FTP.Put(Job.GetJob(i).FileList[j].FileDir +'\'+Job.GetJob(i).FileList[j].FileName, '/'+ DirOut + Job.GetJob(i).FileList[j].FileName);
                templ_str:=templ_str+#10+#13+'[Success]: ' + Job.GetJob(i).FileList[j].FileDir  +' '+Job.GetJob(i).FileList[j].FileName +' =>> '+ DirOut + Job.GetJob(i).FileList[j].FileName + '; ';
                Break
              end else
              begin
                //log.SaveLog(Job.GetJob(i).FileList[j].FileName + ' already in server');
                Continue
              end;
            end;
          end else
          begin
            FTP.Put(Job.GetJob(i).FileList[j].FileDir +'\'+Job.GetJob(i).FileList[j].FileName, '/'+ DirOut + Job.GetJob(i).FileList[j].FileName);
            templ_str:=templ_str+#10+#13+'[Success]: ' + Job.GetJob(i).FileList[j].FileDir  +' '+Job.GetJob(i).FileList[j].FileName +' =>> '+ DirOut + Job.GetJob(i).FileList[j].FileName + '; '; //нужна проверка целостности отправл€емого файла
          end;
          //FTP.Put(Job.GetJob(i).FileList[j].FileDir +'\'+Job.GetJob(i).FileList[j].FileName, '/'+ DirOut + Job.GetJob(i).FileList[j].FileName); //нужна проверка целостности отправл€емого файла
          if FTP.SupportsVerification = true then
          if FTP.VerifyFile(Job.GetJob(i).FileList[j].FileDir +'\'+Job.GetJob(i).FileList[j].FileName, '/'+ DirOut + Job.GetJob(i).FileList[j].FileName) = False then
          begin
            js_result.AddPair('response_code', '2');
            js_result.AddPair('response_string','[Failed] ' + Job.GetJob(i).FileList[j].FileDir  +' '+Job.GetJob(i).FileList[j].FileName +' =>> '+ DirOut + Job.GetJob(i).FileList[j].FileName);
            log.SaveLog('[Failed] ' + Job.GetJob(i).FileList[j].FileDir  +' '+Job.GetJob(i).FileList[j].FileName +' =>> '+ DirOut + Job.GetJob(i).FileList[j].FileName);
            Result := js_result;
            Exit;
          end;
          //js_result.AddPair('response_code', '0');
          //js_result.AddPair('response_string','[Success] ' + Job.GetJob(i).FileList[j].FileDir  +' '+Job.GetJob(i).FileList[j].FileName +' =>> '+ DirOut + Job.GetJob(i).FileList[j].FileName);

          //log.SaveLog('[Success] ' + Job.GetJob(i).FileList[j].FileDir  +' '+Job.GetJob(i).FileList[j].FileName +' =>> '+ DirOut + Job.GetJob(i).FileList[j].FileName);





        end;
        log.SaveLog(templ_str);
      end;

      js_result.AddPair('response_code', '0')

    except on E: Exception do
      begin
        js_result.AddPair('response_code', '2');
        js_result.AddPair('response_string', '[Error] Problem with data for authorization to FTPServer ' + FTP.Host + ' : ' + E.Message);
        log.SaveLog('[Error] Problem with data for authorization to FTPServer ' + FTP.Host + ' : ' + E.Message);

      end;
    end;

    Result := js_result;

  finally
    if FTP <> nil then
    begin
      FTP.Disconnect;
      FTP.Free;
    end;
  end;
end;

function newJob(all_jobs : TJSONObject) : TJSONObject;
var
  JSArr : TJSONArray;
  i, j, k : Integer;
  dir, Pattern, dirout, archivate : string;
  filesList : Tstringlist;

  sendto: TJSONObject;

  archivate_bool  : Boolean;
  dirout_temp     : string;

  RegExp: TRegEx;
  RegExpReslt : TMatch;

  Job : TAllJobs;
  BoolResult : Integer;

  getDirect : TSearchRec;
  findRes   : Integer;

  senderType, FTP_Host, FTP_Username, FTP_Password : string;
  FTP_Port, FTP_DataPort : Integer;

  js_Result : TJSONObject;
begin
 // Result := TJSONObject.Create;
  js_result := nil;
  Job := TAllJobs.Create;
  js_Result := TJSONObject.Create;

// {"action":"newJob", "sendto":"server", "job":[{"dir":"c123123", "Pattern":"ddd*","dirout":"(1)jhgjj(2).zip","archivate":"true"},{"dir":"c123123", "Pattern":"ddd*","dirout":"(1)jhgjj(2).zip","archivate":"false"},{"dir":"c123123", "Pattern":"ddd*","dirout":"(1)jhgjj(2).zip","archivate":"false"}]}

  try
    all_jobs.TryGetValue('job', JSArr);
  except
    log.SaveLog('[Error] Problem with function newJob: <job> section not found');
    Exit;
  end;
  //log.SaveLog(all_jobs.ToJSON);

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
      log.savelog('[Error] Problem with function newJob : <dir> or <pattern> section not found');
    end;
    if DirectoryExists(dir)=False then
    begin
      log.SaveLog('[Error] Directory ' + dir + ' not found');
      exit
    end;


  end;

  if all_jobs.TryGetValue('sendTo', sendto)=true then
  begin
    if sendto.TryGetValue('type', senderType)=true then

  //  if sendto = 'server' then BoolResult := SendToFTP(Job);//SendToServer(Job);
    //if senderType = 'client' then  {function};
    if senderType = 'FTP' then
    begin

      if sendto.TryGetValue('Host', FTP_Host)
      and sendto.TryGetValue('Port', FTP_Port)
      and sendto.TryGetValue('DataPort', FTP_DataPort)
      and sendto.TryGetValue('Username', FTP_Username)
      and sendto.TryGetValue('Password', FTP_Password)
      then
      Job.SendConfig.Host := FTP_Host;
      Job.SendConfig.Port := FTP_Port;
      Job.SendConfig.DataPort := FTP_DataPort;
      Job.SendConfig.Username := FTP_Username;
      Job.SendConfig.Password := FTP_Password;
      js_Result :=  SendToFTP(Job);
      //js_Result.addpair('test1', SendToFTP(Job));
    end;
    {
    if senderType = 'AWS' then
    begin
      js_Result :=  SendToAWS(Job);
    end;
    }

    //Result := 0;
  end else
  begin
    log.SaveLog('[Error] Problem with function newJob: <sendTo> section not found');
  end;

  Result := js_Result;
  //Job.Free;
  //js_Result.Free;
end;

function newMessage(msg : string) : string;
var
  js, js_Result : TJSONObject;
  action : string;

begin
  js_result := nil;
  js_Result := TJSONObject.Create;
  js := nil;
  log.SaveLog('New message has come in function : "' + msg + '"');
  try
    js := TJSONObject.ParseJSONValue(msg) as TJSONObject;
    try
      js_Result.AddPair('request', js);
      if js.TryGetValue('action', action) = True then
      begin
        if action = 'newJob' then
        begin
          js_Result.AddPair('response', newJob(js));
        end;
        {
        if action = 'login'   then
        begin
          js_Result.AddPair('response', newJob(js));
        end;
        }

        if action = 'ping' then
        begin
          js_Result.AddPair('response', 'Online');
        end;
         //Result := 0;// Result :=  ; {*newFunction*}
        //if action = 'newJob3' then Result := 0; {*newFunction*}
        //if action = 'newJob4' then Result := 0; {*newFunction*}




      end else
      begin
        Log.SaveLog('[Error] Problem with function newMessage : <action> section not found');
        //Result := notFoundsActions;

      end;
    finally
      //js.Free;
    end;
    Result := js_Result.ToJSON;
    js_Result.Free;       {try excep ѕ–ќ—“ј¬»“№}
  except
    on E: Exception do
    begin
      Log.SaveLog('[Error] Problem with function newMessage : ' + E.Message);
      //Result := errorExcept;
    end;
  end;



end;



end.
