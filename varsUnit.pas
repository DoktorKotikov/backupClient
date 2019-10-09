unit varsUnit;

interface

uses myconfig.ini, myconfig.Logs, IdFTP,IdTCPClient;

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
  secretKey   : string;
  nameClient  : string;

//  TCPClient   : TIdTCPClient;
 // IdTCPClient1: TIdTCPClient;

implementation

end.
