unit varsUnit;

interface

uses myconfig.ini, myconfig.Logs;

const
  allOk = 0;
  notFoundsActions = 1;
  errorExcept = 2;

type
  TStrArray = array of string;

var
  ini : TConfigs;
  log : TLogsSaveClasses;
  terminatedAll : boolean = false;
  secretKey : string;
  nameClient : string;
 // IdTCPClient1: TIdTCPClient;

implementation

end.
