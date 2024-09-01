unit frmPicPreview;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfmPicPreview }

  TfmPicPreview = class(TForm)
    Label1: TLabel;
  private

  public

  end;

  procedure ShowPreview(aMsg:string);

var
  fmPicPreview: TfmPicPreview;

implementation

procedure ShowPreview(aMsg:string);
begin
  if Assigned(fmPicPreview) then
  FreeAndNil(fmPicPreview);
  fmPicPreview: =TfmPicPreview.Create(nil);
  fmPicPreview.Label1.Caption:=aMsg;
end;

{$R *.lfm}

finalization
if Assigned(fmPicPreview) then
FreeAndNil(fmPicPreview);


end.

