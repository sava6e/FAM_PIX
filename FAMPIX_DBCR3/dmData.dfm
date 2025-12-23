object DM: TDM
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object ZConnection1: TZConnection
    ControlsCodePage = cCP_UTF16
    Catalog = ''
    DisableSavepoints = False
    HostName = ''
    Port = 0
    Database = ''
    User = ''
    Password = ''
    Protocol = ''
    Left = 264
    Top = 160
  end
  object ZTransaction1: TZTransaction
    AutoCommit = True
    Left = 264
    Top = 256
  end
  object ZQuery1: TZQuery
    Params = <>
    Left = 256
    Top = 344
  end
end
