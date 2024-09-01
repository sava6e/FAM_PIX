unit frmPixEdit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  mdData;

type

  { TfmPixEdit }

  TfmPixEdit = class(TForm)
    bAllLeft: TButton;
    bRight: TButton;
    bOk: TButton;
    bCancel: TButton;
    bLeft: TButton;
    bDelStory: TButton;
    bAddStory: TButton;
    bEditStory: TButton;
    cbPlaces: TComboBox;
    edDateBeg: TEdit;
    edDateExact: TEdit;
    edDatEnd: TEdit;
    edPicId: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lbAllPersons: TListBox;
    lbSelectedPersons: TListBox;
    lbStories: TListBox;
    Panel1: TPanel;
    procedure bAddStoryClick(Sender: TObject);
    procedure bAllLeftClick(Sender: TObject);
    procedure bLeftClick(Sender: TObject);
    procedure bRightClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure lbAllPersonsDblClick(Sender: TObject);
    procedure lbSelectedPersonsDblClick(Sender: TObject);
  private
    fFileName: string;
  public
    function PicEdited(aPic: TPic): boolean;
    procedure UpdatePic(aPic: TPic);

  end;

var
  fmPixEdit: TfmPixEdit;
  aPic2Edit:TPic;

implementation



{$R *.lfm}



{ TfmPixEdit }

procedure TfmPixEdit.bRightClick(Sender: TObject);
var
  P: TPerson;
  Ind: integer;
begin
  Ind := lbAllPersons.ItemIndex;
  if Ind < 0 then
    Exit;
  P := TPerson(lbAllPersons.Items.Objects[Ind]);

  lbAllPersons.Items.Delete(Ind);
  lbSelectedPersons.Items.AddObject(P.fCaptionName, P);
end;

procedure TfmPixEdit.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //FreeAndNil(aPic2Edit);
end;

procedure TfmPixEdit.lbAllPersonsDblClick(Sender: TObject);
begin
  Self.bRightClick(Sender);
end;

procedure TfmPixEdit.lbSelectedPersonsDblClick(Sender: TObject);
begin
  Self.bLeftClick(Sender);
end;


procedure TfmPixEdit.bAllLeftClick(Sender: TObject);
var
  I: integer;
  P: TPerson;
begin
  Self.lbSelectedPersons.Items.Clear;
  for i := 0 to Persons.Count - 1 do
  begin
    P := Persons.ByIndex[i];
    Self.lbAllPersons.Items.AddObject(P.fCaptionName, P);
  end;
end;

procedure TfmPixEdit.bAddStoryClick(Sender: TObject);
begin
  aPic2Edit.AddEmptyStory;
end;

procedure TfmPixEdit.bLeftClick(Sender: TObject);
var
  P: TPerson;
  Ind: integer;
begin
  Ind := Self.lbSelectedPersons.ItemIndex;
  if Ind < 0 then
    Exit;
  P := TPerson(Self.lbSelectedPersons.Items.Objects[Ind]);

  lbSelectedPersons.Items.Delete(Ind);
  lbAllPersons.Items.AddObject(P.fCaptionName, P);
end;

function TfmPixEdit.PicEdited(aPic: TPic): boolean;
var
  Ind, i, j, PInd: integer;
  P: TPerson;
  S, S0, S1, S2, S3: string;
  BackSidePicFileName:string;
begin
  aPic.ReLoad;
  aPic2Edit:=aPic;
  Self.fFileName := aPic.FileName;
  Self.edDateBeg.Text := aPic.DateBegin;
  Self.edDatEnd.Text := aPic.DateEnd;
  Self.edDateExact.Text := aPic.DateExact;
  cbPlaces.Items.AddStrings(Places);

  if aPic.PlaceId = '0' then
    cbPlaces.ItemIndex := 4 //not defined
  else
  begin
    Ind := Places.IndexOfName(aPic.PlaceId);
    cbPlaces.ItemIndex := Ind;
  end;

  Self.edPicId.Text:=IntToStr(aPic.Index);

  BackSidePicFileName:=aPic.BackSidePicFileName;
  if BackSidePicFileName<>'' then
  Self.Image1.Picture.LoadFromFile(BackSidePicFileName);

  for i := 0 to aPic.Persons.Count - 1 do
    Self.lbSelectedPersons.AddItem(aPic.Persons.ByIndex[i].fCaptionName,
      aPic.Persons.ByIndex[i]);

    for i := 0 to Persons.Count - 1 do
    begin
      P := Persons.ByIndex[i];
      if not aPic.Persons.PersonFound(P.fPId) then
          Self.lbAllPersons.AddItem(P.fCaptionName, P);
    end;

  Result := (ShowModal = mrOk);
end;



procedure TfmPixEdit.UpdatePic(aPic: TPic);
var
  Ind, I: integer;
  P: TPerson;
begin
  aPic.FileName := Self.fFileName;
  aPic.DateBegin := edDateBeg.Text;
  aPic.DateEnd := edDatEnd.Text;
  aPic.DateExact := edDateExact.Text;
  Ind := cbPlaces.ItemIndex;
  aPic.PlaceId := cbPlaces.Items.Names[Ind];
  aPic.Persons.Clear;
  for i := 0 to Self.lbSelectedPersons.Items.Count - 1 do
  begin
    P := TPerson(Self.lbSelectedPersons.Items.Objects[i]);
    aPic.Persons.Add(P);
  end;
  aPic.SaveData;
end;



end.
