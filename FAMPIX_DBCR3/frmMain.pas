unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls
  , IOUtils
  , System.Types
  ,mdData
  , GDIPlus, System.ImageList, Vcl.ImgList, VirtualTrees.BaseAncestorVCL,
  VirtualTrees.BaseTree, VirtualTrees.AncestorVCL, VirtualTrees,
  VirtualExplorerTree, MPCommonObjects, EasyListview,
  VirtualExplorerEasyListview, Vcl.ToolWin, Vcl.Grids, Vcl.ValEdit;

type

 TViewStyle = (vsViewAllFiles, vsViewFilesInDB, vsViewFilesNotInDB, vsViewNone);

  TfmMain = class(TForm)
    pcMain: TPageControl;
    tsFiles: TTabSheet;
    tsPeople: TTabSheet;
    tsPlaces: TTabSheet;
    tsStories: TTabSheet;
    Panel1: TPanel;
    tvFolders: TTreeView;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    imSelectedFile: TImage;
    ImageList1: TImageList;
    lvFiles: TVirtualExplorerEasyListview;
    ToolBar1: TToolBar;
    tsAdd: TToolButton;
    tsRemove: TToolButton;
    tsTags: TTabSheet;
    ImageList2: TImageList;
    ToolButton1: TToolButton;
    psImageDetails: TPageControl;
    tsPreView: TTabSheet;
    tsProperties: TTabSheet;
    vleImageProps: TValueListEditor;
    Panel2: TPanel;
    ToolBar2: TToolBar;
    ToolButton2: TToolButton;
    tsPix: TTabSheet;
    lvPix: TVirtualExplorerListview;
    tbTimeLine: TTrackBar;
    ToolBar3: TToolBar;
    procedure FormCreate(Sender: TObject);
    procedure lvFilesClick(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure lvFilesResize(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure lvFilesCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure tvFoldersClick(Sender: TObject);
    procedure psImageDetailsChange(Sender: TObject);
    procedure pcMainChange(Sender: TObject);
  private
    { Private declarations }
    fViewStyle: TViewStyle;
    fFolders:TStringList;
    procedure FillFileList(aFolder: string);
    procedure FillDirList(aFolder:string);
  public
    { Public declarations }
  end;

  TImageDisplayData = record
    Height, Width: integer;
    X, Y: integer;
  end;

var
  fmMain: TfmMain;
  PixFolder: string;

implementation

{$R *.dfm}

procedure TfmMain.FormCreate(Sender: TObject);
var
  SL
  //, slFiles
  : TStringList;
  S: string;
  i: integer;
begin
/// FDGFDGHFGHFGH TEST
  //vsIcon, vsSmallIcon, vsList, vsReport
  //Self.lvFiles.ViewStyle:=vsIcon;
  SL := TStringList.Create;
  fFolders:=TStringList.Create;
  try
    S := ChangeFileExt(Application.ExeName, '');
    SL.LoadFromFile(S);
    PixFolder := SL[0];
  finally
    FreeAndNil(SL);
  end;
  PixFolder := IncludeTrailingPathDelimiter(PixFolder);
  //No need to create the stringlist; the function does that for you
  //Self.stvFolders.Root := PixFolder;
  FillDirList(PixFolder);
  //lvFiles.RootFolder.:=PixFolder;
  FillFileList(PixFolder);

  if lvFiles.SelectedFiles.Count >0 then
    //lvFiles.selectedFile.ItemIndex:=0;
  Self.lvFilesClick(nil);
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fFolders);
end;

function GetImageDimensions(Image: IGPImage; Frame:TRect): TImageDisplayData;
var
  Ratio: real;
  X, Y: integer;
  Img:TRect;
begin
  Img:=TRect.Create(Point(0,0),Image.Width,Image.Height);

  if (Img.Height > Img.Width) then //Orientation = ioPortrait
  begin
    if Img.Height > Frame.Height then
      Ratio := Frame.Height / Img.Height
    else
      Ratio := 1;
    result.Height := Frame.Height;
    result.Width := Trunc(Img.Width * Ratio);
    result.X := (Frame.Width - result.Width) div 2;
    result.Y:=0;

  end
  else //landscape Img.Width >= Img.Height
    begin
    if Img.Width > Frame.Width then
      Ratio := Frame.Width / Img.Width
    else
      Ratio := 1;
    result.Width := Frame.Width;
    result.Height := Trunc(Img.Height * Ratio);
    result.Y := (Frame.Height - result.Height) div 2;
    result.X:=0;
  end;
 { Result.Height := result.Height-Y;
  Result.Width := result.Width-X;
  }

  {fmMain.Label2.caption:=Format('Image H=%d W=%d Display H=%d W=%d Ratio =%f Calc H=%d,W=%d',
    [H,W,H1,W1,Ratio,H2,W2]);}
end;

procedure TfmMain.lvFilesClick(Sender: TObject);
var
  S: string;
  LI: TListItem;
  Image: IGPImage;
  Graphics: IGPGraphics;
  Filler1: TGPRect;
  P:TPoint;
  R1:TRect;
  SolidBrush: IGPSolidBrush;
  ID: TImageDisplayData;
begin
  if lvFiles.SelectedFiles.Count<>1 then
  Exit;
  {if lvFiles.Items.Count < 0 then
    Exit;
  if lvFiles.Items.Count > 1 then
    Exit;}
  try
     Screen.Cursor := crHourGlass;

    SolidBrush := TGPSolidBrush.Create(TGPColor.Create(100, 255, 100, 100));

    //LI :=lvFiles.Items[lvFiles.ItemIndex];
    //S := LI.Caption;
    S:=lvFiles.SelectedPath;
    //imSelectedFile.Canvas.Clear;
    imSelectedFile.Picture:=nil;
    Image := TGPImage.Create(S);

    P:=TPoint.Create(imSelectedFile.Left,imSelectedFile.Top);
    R1:=TRect.Create(P,imSelectedFile.Width,imSelectedFile.Height);

    ID := GetImageDimensions(Image, R1);

    Graphics := TGPGraphics.Create(imSelectedFile.Canvas.Handle);
    Filler1.Initialize(0, 0, imSelectedFile.Width, imSelectedFile.Height);
    Graphics.FillRectangle(SolidBrush, Filler1);

    Graphics.DrawImage(Image, ID.X, ID.Y, ID.Width, ID.Height);

     {Label2.Caption:= Format(
      ' DEST W %d H %d |||||| SRC W %d H %d ||| CNT W %d H %d X=%d Y=%d',
      [imSelectedFile.Width, imSelectedFile.Height, Image.Width, Image.Height,
      ID.Width, ID.Height, ID.X, ID.Y]);
      }
  finally
    Screen.Cursor := crDefault;
    //FreeAndNil(Graphics);
    //FreeAndNil(Image);
  end;
end;

procedure TfmMain.lvFilesCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
  var
  s:string;
  Image, Thumbnail: IGPImage;
  Graphics: IGPGraphics;
  ID:TImageDisplayData;
  R:TRect;
  R1:TGPRect;
  Origin:TPoint;
  Filler1: TGPRect;
  SolidBrush: IGPSolidBrush;
begin
  S := Item.Caption;
  try
   {
    //R:=Item.DisplayRect(drBounds);
    Origin:=Item.DisplayRect(drBounds).Location;
    R:=TRect.Create(Origin,120,120);
    SolidBrush := TGPSolidBrush.Create(TGPColor.Create(100, 255, 100, 100));
  R1:=TGPRect.Create(R);


  Image := TGPImage.Create(S);
  ID:=GetImageDimensions(Image, R);


  //Thumbnail := Image.GetThumbnailImage(ID.Width, ID.Height, nil, nil);



  Graphics:=TGPGraphics.Create(Sender.Canvas.Handle);
  Filler1.Initialize(Origin.x, Origin.Y, 120, 120);
    Graphics.FillRectangle(SolidBrush, Filler1);
  Graphics.DrawImage(Image, R1);
    }
  finally
     {FreeAndNil(Graphics);
    FreeAndNil(Image);}
  end;
end;

procedure TfmMain.lvFilesResize(Sender: TObject);
begin
  //lvFiles.Columns[0].Width := lvFiles.Width;
end;

procedure TfmMain.Panel1Resize(Sender: TObject);
begin
  lvFilesClick(nil);
end;

procedure TfmMain.pcMainChange(Sender: TObject);
begin
  {if pcMain.ActivePage=tsPix then
    lvPix.}
end;

procedure TfmMain.psImageDetailsChange(Sender: TObject);
begin
  Self.vleImageProps.Strings.Clear;
  Self.vleImageProps.Strings.AddPair('id','');
  Self.vleImageProps.Strings.AddPair('Точная дата','');
  Self.vleImageProps.Strings.AddPair('Интервал.Начало','');
  Self.vleImageProps.Strings.AddPair('Интервал.Конец','');
  Self.vleImageProps.Strings.AddPair('Место съемки','');
  Self.vleImageProps.Strings.AddPair('Автор','');
  Self.vleImageProps.Strings.AddPair('Кто на фото','');
  Self.vleImageProps.Strings.AddPair('Тыльная сторона','');
  Self.vleImageProps.Strings.AddPair('Истории','');
end;

procedure TfmMain.Splitter1Moved(Sender: TObject);
begin
  lvFilesClick(nil);
end;

procedure TfmMain.tvFoldersClick(Sender: TObject);
var i:integer;
begin
  if tvFolders.Selected=nil then
  Exit;
  i:=tvFolders.Selected.Index;
  lvFiles.RootFolderCustomPath:=fFolders[i];
  //sdgsdfgdfg
end;

procedure TfmMain.FillDirList(aFolder: string);
var
  sr: TSearchRec;
  FileAttrs: Integer;
  theRootNode : tTreeNode;
  theNode : tTreeNode;

  procedure  AddDirectories(theNode: tTreeNode; cPath: string);
  var
  sr1: TSearchRec;
  FileAttrs1: Integer;
  theNewNode : tTreeNode;
begin
   FileAttrs1 := faDirectory;     // Only care about directories
   if FindFirst(cPath+'\*.*', FileAttrs1, sr1) = 0 then
    begin
      repeat
        if  ((sr1.Attr and FileAttrs1) = sr1.Attr) and (copy(sr1.Name,1,1) <> '.')
        then
        begin
            theNewNode := tvFolders.Items.AddChild(theNode,sr1.name);
            fFolders.Add(cPath+'\'+sr1.Name);
            AddDirectories(theNewNode,cPath+'\'+sr1.Name);
        end;
      until FindNext(sr1) <> 0;
      FindClose(sr1);
    end;
end;

begin
   FileAttrs := faDirectory;     // Only care about directories
   theRootNode := Self.tvFolders.Items.AddFirst(nil,aFolder);
   if FindFirst(aFolder+'\*.*', FileAttrs, sr) = 0 then
    begin
      repeat
        if ((sr.Attr and FileAttrs) = sr.Attr) and (copy(sr.Name,1,1) <> '.') then
        begin
            theNode := tvFolders.Items.AddChild(theRootNode,sr.name);
            fFolders.Add(aFolder+sr.Name);
            AddDirectories(theNode,aFolder+sr.Name);
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
    tvFolders.FullExpand;
end;

function FindAllFiles(const SearchPath: String): TStringList;
  var
  SL:TStringList;
  s:string;
  Cnt:integer;

  procedure AddFiles(const aFolder:string);
  var
  DL,FL:TStringDynArray;
  i:integer;
  begin
    DL:=TDirectory.GetDirectories(aFolder);
    FL:=TDirectory.GetFiles(aFolder);
    for i:=Low(FL) to High(FL) do
      SL.Add(FL[i]);
    for i:=Low(DL) to High(DL) do
      AddFiles(DL[i]);
  end;

{
  procedure AddFiles(const aFolder:string);
  var SR: TSearchRec;

  begin
    Inc(Cnt);
    S:=S+Format(' %d SR %s',[Cnt,aFolder]);
   if FindFirst(aFolder+'*.*', faAnyFile, SR) = 0 then
    begin
      repeat
        if (copy(SR.Name,1,1) <> '.') then
        begin
          if (SR.Attr and faDirectory) <> 0 then
          begin
            AddFiles(aFolder+SR.Name);

          end
          else
          begin
            SL.Add(SR.Name);
            S:=S+' FIL '+aFolder+SR.Name;
          end;
        end;

      until FindNext(SR) <> 0;
      FindClose(sr);
      fmMain.Label1.Caption:=S;
    end;
  end;
 }
begin
  Cnt:=0;
  SL := TStringList.Create;
   AddFiles(SearchPath);
   result:=SL;
end;


procedure TfmMain.FillFileList(aFolder: string);
var
  slFiles, SL: TStringList;
  S, Folder, FN: string;
  i, Ind: integer;
  FileInDB: boolean;
  LI: TListItem;
begin    {
  lvFiles.Items.Clear;
  slFiles := FindAllFiles(aFolder);//, '*.*', True);
  try
    SL := Pix.PixFiles;
    for i := 0 to slFiles.Count - 1 do
    begin
      FN := slFiles[i];
      FileInDB := SL.Find(FN, Ind);
      if (Self.fViewStyle = vsViewAllFiles) or
        ((Self.fViewStyle = vsViewFilesInDB) and FileInDB) or
        ((Self.fViewStyle = vsViewFilesNotInDB) and (not FileInDB)) then
      begin
        LI := lvFiles.Items.Add;
        LI.Caption := FN;
        LI.Checked := FileInDB;
      end;
    end;
  finally
    SL.Free;
    slFiles.Free;
  end;    }
end;


end.
