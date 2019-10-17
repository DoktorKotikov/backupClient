object BackupAgent: TBackupAgent
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = 'BackupAgent'
  OnExecute = ServiceExecute
  Height = 150
  Width = 215
end
