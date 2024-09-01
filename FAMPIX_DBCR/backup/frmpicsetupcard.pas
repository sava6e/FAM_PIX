unit frmPicSetupCard;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  mdData;

type

  { TfmPicSetupCard }

  TfmPicSetupCard = class(TForm)
    bOk: TButton;
    bCancel: TButton;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    rbSetUp2: TRadioButton;
    rbSetUp1: TRadioButton;
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure rbSetUp1Click(Sender: TObject);
    procedure rbSetUp2Click(Sender: TObject);
  private

  public
    function PicEdited(aPic1,aPic2: TPic): boolean;
    procedure UpdatePic(aPic: TPic);
  end;

var
  fmPicSetupCard: TfmPicSetupCard;
  aPic2Save:TPic;

implementation

{$R *.lfm}

{ TfmPicSetupCard }

procedure TfmPicSetupCard.Image1Click(Sender: TObject);
begin
  rbSetup1.Checked:=true;
end;

procedure TfmPicSetupCard.Image2Click(Sender: TObject);
begin
  rbSetup2.Checked:=true;
end;

procedure TfmPicSetupCard.rbSetUp1Click(Sender: TObject);
begin
  rbSetUp1.Caption:='фронт';
  rbSetUp2.Caption:='тыл';
end;

procedure TfmPicSetupCard.rbSetUp2Click(Sender: TObject);
begin
  rbSetUp2.Caption:='фронт';
  rbSetUp1.Caption:='тыл';
end;

function TfmPicSetupCard.PicEdited(aPic1, aPic2: TPic): boolean;
begin
  Self.Image1.Picture.LoadFromFile(aPic1.FileName);
  Self.Image2.Picture.LoadFromFile(aPic2.FileName);
  Result := (ShowModal = mrOk);
  if Self.rbSetUp1.Checked then
    begin
    aPic2Save:=aPic1;
    aPic2Save.BackSidePicId:=aPic2.Index;
    end
  else
    begin
    aPic2Save:=aPic2;
       aPic2Save.BackSidePicId:=aPic1.Index;
    end;
end;

procedure TfmPicSetupCard.UpdatePic(aPic: TPic);
begin
  aPic2Save.SaveData;
end;

end.

