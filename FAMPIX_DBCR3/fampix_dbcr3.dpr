program fampix_dbcr3;

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {fmMain},
  mdData in 'mdData.pas';

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown:=true;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
