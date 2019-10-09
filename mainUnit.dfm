object DataModule1: TDataModule1
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 150
  Width = 215
  object TCPClient: TIdTCPClient
    OnStatus = TCPClientStatus
    OnDisconnected = TCPClientDisconnected
    OnWork = TCPClientWork
    OnConnected = TCPClientConnected
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 48
    Top = 24
  end
end
