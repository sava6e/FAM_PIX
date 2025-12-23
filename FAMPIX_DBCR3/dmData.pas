unit dmData;

interface

uses
  System.SysUtils, System.Classes, Data.DB, ZAbstractRODataset,
  ZAbstractDataset, ZDataset, ZAbstractConnection, ZTransaction, ZConnection;

type
  TDM = class(TDataModule)
    ZConnection1: TZConnection;
    ZTransaction1: TZTransaction;
    ZQuery1: TZQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  {SQLConnection1 := TSQLConnection.Create(nil);
  qData := TSQLQuery.Create(nil);
  qData.SQLConnection:=SQLConnection1;  }
 // SQLTransaction1 := TSQLTransaction.Create(nil);
  {SQLConnection1.ConnectionName := 'C:\Users\SG\DEV\FAM_PIX\FAMPIX_DBCR\fampix1.db';
  SQLConnection1.DriverName := 'SQLite';
  SQLConnection1.Connected := True;
  SQLConnection1.Params.Add('User=""');
  SQLConnection1.Params.Add('Password=""');
  qData.SQLConnection:=SQLConnection1;}
end;

initialization
DM:=TDM.Create(nil);

finalization
FreeAndNil(DM);

end.
