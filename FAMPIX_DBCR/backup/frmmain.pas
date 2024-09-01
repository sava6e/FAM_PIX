unit frmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DateUtils, Forms, Controls, Graphics, Dialogs,
  ShellCtrls, ExtCtrls, StdCtrls, ComCtrls, Menus, FileUtil
  , mdData
  , frmPixEdit,frmPicSetUpCard
  ,frmPicPreview;

type

  TViewStyle = (vsViewAllFiles,vsViewFilesInDB,vsViewFilesNotInDB,vsViewNone);
  { TfmMain }

  TfmMain = class(TForm)


    bSetPixData: TButton;
    bSetUpCard: TButton;
    cbFilesInDB: TCheckBox;
    cbFilesNotInDB: TCheckBox;
    lvPersons: TListView;
    lvTags: TListView;
    lvPlaces: TListView;
    lvStories: TListView;
    lvFiles: TListView;
    MenuItem1: TMenuItem;
    pcAppMenu: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    pmFolders: TPopupMenu;
    stvFolders: TShellTreeView;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    tsStories: TTabSheet;
    tsPlaces: TTabSheet;
    tsTags: TTabSheet;
    tsFiles: TTabSheet;
    tsPersons: TTabSheet;
    Timer1: TTimer;
    fPrevLIUnderCursor,fLIUnderCursor:TListItem;

    procedure bSetPixDataClick(Sender: TObject);
    procedure bSetUpCardClick(Sender: TObject);
    procedure cbFilesInDBChange(Sender: TObject);
    procedure cbFilesNotInDBChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvFilesClick(Sender: TObject);

    procedure lvFilesItemChecked(Sender: TObject; Item: TListItem);
    procedure lvFilesMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lvFilesResize(Sender: TObject);
    procedure lvFilesShowHint(Sender: TObject; HintInfo: PHintInfo);
    procedure MenuItem1Click(Sender: TObject);
   // procedure SetLVCheckBoxes;
    procedure stvFoldersChange(Sender: TObject; Node: TTreeNode);
    procedure stvFoldersMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure Timer1Timer(Sender: TObject);
  private
    fViewStyle:TViewStyle;
    procedure SetViewStyle;
    procedure FillFileList(aFolder:string);
  public

  end;

var
  fmMain: TfmMain;
  PixFolder: string;


implementation

{$R *.lfm}

{ TfmMain }

procedure TfmMain.FormCreate(Sender: TObject);
var
  SL
    //, slFiles
    : TStringList;
  S: string;
  i: integer;
begin
  SL := TStringList.Create;
  try
    S := ChangeFileExt(Application.ExeName, '');
    SL.LoadFromFile(S);
    PixFolder := SL[0];
  finally
    FreeAndNil(SL);
  end;
  PixFolder := IncludeTrailingPathDelimiter(PixFolder);
  //No need to create the stringlist; the function does that for you
  Self.stvFolders.Root := PixFolder;

  FillFileList(PixFolder);
end;
 {
procedure TfmMain.SetLVCheckBoxes;
var
  i, ind: integer;
  LI: TListItem;
  S: string;
  PF: TStringList;
begin
  try
    PF := Pix.PixFiles;
    for i := 0 to lvFiles.Items.Count - 1 do
    begin
      LI := lvFiles.Items[i];
      S := LI.Caption;
      LI.Checked := PF.Find(S, Ind);
    end;

  finally
    FreeAndNil(PF);
  end;
end;
  }
procedure TfmMain.FillFileList(aFolder:string);
var
  slFiles, SL: TStringList;
  S, Folder,FN: string;
  i,Ind: integer;
  FileInDB:boolean;
  LI:TListItem;
begin
  lvFiles.Items.Clear;
  slFiles := FindAllFiles(aFolder, '*.*', True);
  try
    SL:=Pix.PixFiles;
    for i := 0 to slFiles.Count - 1 do
    begin
      FN:=slFiles[i];
      FileInDB:=SL.Find(FN, Ind);
      if (Self.fViewStyle=vsViewAllFiles) or
      ((Self.fViewStyle=vsViewFilesInDB) and FileInDB) or
      ((Self.fViewStyle=vsViewFilesNotInDB) and (not FileInDB)) then
        begin
          LI:=lvFiles.Items.Add;
          LI.Caption:=FN;
          LI.Checked := FileInDB;
        end
    end;
  finally
    SL.Free;
    slFiles.Free;
  end;
end;

procedure TfmMain.stvFoldersChange(Sender: TObject; Node: TTreeNode);
begin
  FillFileList(Node.GetTextPath);
end;

procedure TfmMain.stvFoldersMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  i: integer;
  aNode: TTreeNode;
  R: TRect;
begin
  if not (Button = mbRight) then
    Exit;
  for i := 0 to stvFolders.Items.Count - 1 do
  begin
    aNode := stvFolders.Items[i];
    R := aNode.DisplayRect(False);
    if (Y > R.Top) and (Y < R.Bottom) then
      Break;
  end;
  stvFolders.Selected := aNode;
end;





procedure TfmMain.bSetPixDataClick(Sender: TObject);
var
  LI: TListItem;
  aPic: TPic;

begin
  if lvFiles.ItemIndex < 0 then
    Exit;
  if lvFiles.SelCount>1 then
  Exit;
  LI := lvFiles.Items[lvFiles.ItemIndex];
  aPic := Pix.PixByFileName[LI.Caption];

  fmPixEdit := TfmPixEdit.Create(nil);
  try
    if fmPixEdit.PicEdited(aPic) then
      fmPixEdit.UpdatePic(aPic);
  finally
    FreeAndNil(fmPixEdit);
  end;
end;

procedure TfmMain.bSetUpCardClick(Sender: TObject);
var
    LI: TListItem;
    aPic1,aPic2: TPic;
    i,cnt:integer;
begin
  if lvFiles.SelCount<>2 then
  Exit;
  Cnt:=0;
  for i:=0 to Self.lvFiles.Items.Count-1 do
  begin
    LI := lvFiles.Items[i];
    if LI.Selected then
    begin
      if Cnt=0 then
      begin
      aPic1 := Pix.PixByFileName[LI.Caption];
      Inc(Cnt);
      end
      else
        begin
          aPic2 := Pix.PixByFileName[LI.Caption];
          Break;
        end;
    end
  end;
    fmPicSetupCard := TfmPicSetupCard.Create(nil);
    try
      if fmPicSetupCard.PicEdited(aPic1,aPic2) then
      begin
        if aPic1.BackSidePicId<0 then
        fmPicSetupCard.UpdatePic(aPic2)
        else
          fmPicSetupCard.UpdatePic(aPic1);
      end;
    finally
      FreeAndNil(fmPicSetupCard);
    end;
  end;

procedure TfmMain.cbFilesInDBChange(Sender: TObject);
begin                           //vsViewAllFiles,vsViewFilesInDB,vsViewFilesNotInDB
  SetViewStyle;
  FillFileList(Self.stvFolders.Root);
end;

procedure TfmMain.cbFilesNotInDBChange(Sender: TObject);
begin
  SetViewStyle;
  FillFileList(Self.stvFolders.Root);
end;



procedure TfmMain.SetViewStyle;
begin
  if Self.cbFilesInDB.Checked then
  begin
  if Self.cbFilesNotInDB.Checked then
    Self.fViewStyle:=vsViewAllFiles
  else
    Self.fViewStyle:=vsViewFilesInDB;
  end
  else
  begin
    if Self.cbFilesNotInDB.Checked then
    Self.fViewStyle:=vsViewFilesNotInDB
  else
    Self.fViewStyle:=vsViewNone;
  end
end;



procedure TfmMain.lvFilesClick(Sender: TObject);
var
  i:integer;
  S: string;
  LI: TListItem;
  T1,T2:System.TDateTime;
begin
  if lvFiles.ItemIndex < 0 then
    Exit;
  if lvFiles.SelCount>1 then
  begin
    //for i:=0 to Self.lvFiles.Items.Count-1 do
    //;
    Exit;

  end;
  try
    Cursor := crHourGlass;
    Self.Repaint;
    LI := lvFiles.Items[lvFiles.ItemIndex];
    S := LI.Caption;

    T1:=Now;
    //imSelectedFile.Picture.LoadFromFile(S);
    T2:=Now;
    //ShowMessage(Format('loaded in %d',[MilliSecondsBetween(T1,T2)]));
  finally
    Cursor := crDefault;
  end;
end;



procedure TfmMain.lvFilesItemChecked(Sender: TObject; Item: TListItem);
begin
  if Item = nil then
    Exit;
  if lvFiles.SelCount>1 then
  Exit;
  if Item.Checked then
    Pix.AddPicQuick(Item.Caption)
  else
    Pix.DeletePic(Item.Caption);
end;

procedure TfmMain.lvFilesMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var i:integer;
  LI:TListItem;
  P:TPoint;
  R:TRect;
begin
  Timer1.Enabled:=true;
  for i:=0 to Self.lvFiles.Items.Count-1 do
  begin
    LI:=Self.lvFiles.Items[i];//(drBounds, drIcon, drLabel, drSelectBounds)
    P:=TPoint.Create(X,Y);
    R:=LI.DisplayRect(drBounds);
    if R.Contains(P) then
      begin
        fLIUnderCursor:=LI;
      end;
  end;
end;

procedure TfmMain.Timer1Timer(Sender: TObject);
var S:string;
begin
  if (fPrevLIUnderCursor=Self.fLIUnderCursor)or (fPrevLIUnderCursor=nil) then
    begin
      Timer1.Enabled:=false;
      fPrevLIUnderCursor:=nil;
      fLIUnderCursor:=nil;
      S:=fLIUnderCursor.Caption;
   ShowPreview(S);
    end;
end;

procedure TfmMain.lvFilesResize(Sender: TObject);
begin
  lvFiles.Columns[0].Width := lvFiles.Width;
end;

procedure TfmMain.lvFilesShowHint(Sender: TObject; HintInfo: PHintInfo);
begin

end;

procedure TfmMain.MenuItem1Click(Sender: TObject);
var
  LI: TListItem;
  aPic, aPic2Copy: TPic;
  aFolder: string;
  slFiles: TStringList;
  i: integer;
begin
  if stvFolders.Selected = nil then
    Exit;

  aPic2Copy := TPic.Create;
  fmPixEdit := TfmPixEdit.Create(nil);
  try
    if fmPixEdit.PicEdited(aPic2Copy) then
    begin
      fmPixEdit.UpdatePic(aPic2Copy);
    end;
  finally
    FreeAndNil(fmPixEdit);
  end;

  aFolder := PixFolder + stvFolders.Selected.Text + '\';

  slFiles := FindAllFiles(aFolder, '*.*', True);
  try
    for i := 0 to slFiles.Count - 1 do
    begin
      if Pix.FileNameFound(slFiles[i]) then
      begin
        aPic := Pix.PixByFileName[slFiles[i]];
        aPic.CopyFromPic(aPic2Copy);
      end;
    end;
  finally
    slFiles.Free;
    FreeAndNil(aPic2Copy);
  end;

end;






end.
