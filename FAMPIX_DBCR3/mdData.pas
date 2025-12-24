unit mdData;

interface

uses
  Classes, Contnrs, SysUtils
  //, SQLDB, SQLite3Conn
  , Dialogs
  //,frmPixEdit
  , Variants
 ,Data.DB
 , ZAbstractRODataset,
  ZAbstractDataset, ZDataset, ZAbstractConnection, ZTransaction, ZConnection

  ;
type

  { TTag }

  TTag = class
  private
     fCaption:string;
  protected

  public

    constructor Create; virtual;
    destructor Destroy; override;
  published
  end;

  { TTags }

  TTags = class(TObjectList)
  private
    function GetByIndex(Ind: integer): TTag;

  protected

  public
    property ByIndex[Ind:integer]:TTag read GetByIndex;
    constructor Create; virtual;
    destructor Destroy; override;
  published
  end;


  { TStory }
  TStory = class
  private
    fCode: integer;
    fCaption: string;
    fText: string;
    fToldBy: integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

  end;

  { TStories }

  TStories = class(TObjectList)
  private
    function GetStoryByCode(aCode: integer): TStory;
    function GetStoryByInd(Ind: integer): TStory;
  public
    property ByCode[aCode: integer]: TStory read GetStoryByCode;
    property ByIndex[Ind: integer]: TStory read GetStoryByInd;
    procedure AddEmptyStory;
    procedure SaveStory();
    procedure DetachStory(aCode: integer);
    procedure DeleteStory(aCode: integer);
    procedure Load;
    //destructor Destroy;override;
  end;


  { TPlaces }

  TPlaces = class(TStringList)
  private
    procedure LoadData;
  end;

  { TPerson }

  TPerson = class
    fStories: TStories;
    fPId: integer;
    fCaptionName: string;
    fBirthDate: string;
    fDeathDate: string;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TPic = class;

  { TPersons }

  TPersons = class(TObjectList)
  private

    function FindById(PInd: integer): TPerson;
    function GetPerson(Ind: integer): TPerson;
    procedure LoadFromVocab;
    procedure LoadFromLinkTable(aPic: TPic);
    procedure SetPerson(Ind: integer; AValue: TPerson);
  public
    property ByIndex[Ind: integer]: TPerson read GetPerson write SetPerson;
    function PersonFound(aPersInd: integer): boolean;
  end;


  { TPic }

  TPic = class
  private
    fCode: integer;
    fStories: TStories;

    fFileName: string;
    fDateBegin: string;
    fDateEnd: string;
    fDateExact: string;
    fPlaceId: string;
    fPlaceCaption: string;
    fPersons: TPersons;
    fBackSidePicId: integer;
    procedure AddData(Arr: array of variant);
    procedure ReadData(aFileName: string);
    function GetBackSidePicFileName: string;

  public
    property Code: integer read fCode;
    property FileName: string read fFileName write fFileName;
    property DateBegin: string read fDateBegin write fDateBegin;
    property DateEnd: string read fDateEnd write fDateEnd;
    property DateExact: string read fDateExact write fDateExact;
    property PlaceId: string read fPlaceId write fPlaceId;
    property PlaceCaption: string read fPlaceCaption write fPlaceCaption;
    property BackSidePicId: integer read fBackSidePicId write fBackSidePicId;
    property BackSidePicFileName: string read GetBackSidePicFileName;
    property Persons: TPersons read fPersons;
    procedure ReLoad;
    procedure SaveData;
    procedure AddEmptyStory;
    procedure SaveStory(StoryId: integer; StoryText: string);
    procedure CopyFromPic(aPic: TPic);
    constructor Create;
    destructor Destroy; override;
  end;

  { TPix }

  TPix = class(TObjectList)

  private
    function GetPicByInd(Ind: integer): TPic;
    function GetPicByFileName(aFileName: string): TPic;
    procedure ReadPixList;
    procedure SetPic(Ind: integer; AValue: TPic);
    function GetFiles: TStringList;
    function GetIndexOf(aFileName: string): integer;
    procedure SetPicByFileName(aFileName: string; AValue: TPic);
    function GetPicByCode(aCode: integer): TPic;

  public
    function FileNameFound(aFileName: string): boolean;
    procedure AddPicQuick(aFileName: string);
    procedure DeletePic(aFileName: string);
    property PixItems[i: integer]: TPic read GetPicByInd write SetPic;
    property PixByFileName[aFileName: string]: TPic
      read GetPicByFileName write SetPicByFileName;

    property PixFiles: TStringList read GetFiles;
    constructor Create;
    destructor Destroy; override;
  end;

var
  {SQLConnector1: TSQLConnection;
  qData: TSQLQuery;}
  //SQLTransaction1: TSQLTransaction;
  ZConnection1: TZConnection;
    ZTransaction1: TZTransaction;
    qData: TZQuery;

  Pix: TPix;
  Places: TPlaces;
  Persons: TPersons;
  Stories:TStories;

implementation

{ TTags }

function TTags.GetByIndex(Ind: integer): TTag;
begin
  result:=TTag(Items[Ind]);
end;


constructor TTags.Create;
begin
  inherited Create(True);
end;

destructor TTags.Destroy;
begin
  inherited Destroy;
end;

{ TTag }

constructor TTag.Create;
begin
  inherited Create;
end;

destructor TTag.Destroy;
begin
  inherited Destroy;
end;

{ TStory }

constructor TStory.Create;
begin
  inherited Create;
  Self.fCaption := '';
  Self.fCode := -1;
  Self.fText := '';
  Self.fToldBy := -1;
end;

destructor TStory.Destroy;
begin
  inherited Destroy;
end;

{ TStories }


function TStories.GetStoryByCode(aCode: integer): TStory;
var
  i: integer;
  aStory: TStory;
begin
  for i := 0 to Self.Count - 1 do
  begin
    aStory := GetStoryByInd(i);
    if aStory.fCode = aCode then
    begin
      Result := aStory;
      Exit;
    end;
  end;
end;

function TStories.GetStoryByInd(Ind: integer): TStory;
begin
  Result := TStory(Items[Ind]);
end;

procedure TStories.AddEmptyStory;
begin

end;

procedure TStories.SaveStory;
begin

end;

procedure TStories.DetachStory(aCode: integer);
begin

end;

procedure TStories.DeleteStory(aCode: integer);
var S:TStory;
begin
  S:=Self.GetStoryByCode(aCode);
  if S=nil then
  Exit;
  Self.Delete(S.fCode);
end;

procedure TStories.Load;
var S:TStory;
begin
  qData.Close;
  qData.SQL.Clear;
  qData.SQL.Text := format('select * from stories', []);
  qData.Open;
  while not qData.EOF do
  begin
    S := TStory.Create;
    S.fCode:=qData.Fields[0].AsInteger;
    S.fCaption:=qData.Fields[1].AsString;
    S.fText:=qData.Fields[2].AsString;
    S.fToldBy:=qData.Fields[3].AsInteger;
    Self.Add(S);
    qData.Next;
  end;
  qData.Close;
end;



{ TPerson }

constructor TPerson.Create;
begin
  inherited Create;
  Self.fStories := TStories.Create(False);
end;

destructor TPerson.Destroy;
begin
  FreeAndNil(Self.fStories);
  inherited Destroy;
end;

{ TPersons }

function TPersons.FindById(PInd: integer): TPerson;
var
  I: integer;
  P: TPerson;
begin
  Result := nil;
  for i := 0 to self.Count - 1 do
  begin
    P := TPerson(Self.Items[i]);
    if P.fPId = PInd then
    begin
      Result := P;
      Exit;
    end;
  end;
end;



procedure TPersons.LoadFromVocab;
var
  P: TPerson;
begin
  qData.Close;
  qData.SQL.Clear;
  qData.SQL.Text := format('select * from persons', []);
  qData.Open;
  while not qData.EOF do
  begin
    P := TPerson.Create;
    P.fPId := qData.Fields[0].AsInteger;
    P.fCaptionName := qData.Fields[1].AsString;
    P.fBirthDate := qData.Fields[2].AsString;
    P.fDeathDate := qData.Fields[3].AsString;
    Self.Add(P);
    qData.Next;
  end;
  qData.Close;
end;


procedure TPersons.LoadFromLinkTable(aPic: TPic);
var
  Ind: integer;
  P: TPerson;
begin
  qData.Close;
  qData.SQL.Clear;
  qData.SQL.Text := format('select * from pix_persons where pix_id=%d', [aPic.fCode]);
  qData.Open;
  Self.Clear;
  while not qData.EOF do
  begin
    Ind := qData.Fields[0].AsInteger;
    P := Persons.FindById(Ind);
    if P <> nil then Self.Add(P);
    qData.Next;
  end;
  qData.Close;
end;

function TPersons.GetPerson(Ind: integer): TPerson;
begin
  Result := TPerson(Items[Ind]);
end;

procedure TPersons.SetPerson(Ind: integer; AValue: TPerson);
begin
  Items[Ind] := AValue;
end;

function TPersons.PersonFound(aPersInd: integer): boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to Self.Count - 1 do
    if Self.ByIndex[i].fPId = aPersInd then
    begin
      Result := True;
      Exit;
    end;
end;

{ TPlaces }

procedure TPlaces.LoadData;
var
  PlId: integer;
  PlName: string;
begin
  qData.Close;
  qData.SQL.Clear;
  qData.SQL.Text := format('select * from places', []);
  qData.Open;
  while not qData.EOF do
  begin
    PlId := qData.Fields[0].AsInteger;
    PlName := qData.Fields[1].AsString;
    Self.Add(Format('%d=%s', [PlId, PlName]));
    qData.Next;
  end;
  qData.Close;
end;

{ TPic }



constructor TPic.Create;
begin
  inherited;
  Self.fCode := -1;
  Self.fPersons := TPersons.Create(False);
  Self.fStories := TStories.Create(False);
end;

destructor TPic.Destroy;
begin
  FreeAndNil(fPersons);
  FreeAndNil(Self.fStories);
  inherited Destroy;
end;


procedure TPic.AddData(Arr: array of variant);
begin
  try
    if Arr[0] <> null then
      fCode := Arr[0]
    else
      raise Exception.Create('fail to read image index');
    if Arr[1] <> null then
      fFileName := Arr[1];
    if Arr[2] <> null then
      fDateBegin := Arr[2];
    if Arr[3] <> null then
      fDateEnd := Arr[3];
    if Arr[4] <> null then
      fDateExact := Arr[4];
    if Arr[5] <> null then
      fPlaceId := Arr[5];
    if Arr[6] <> null then
      fBackSidePicId := Arr[6];
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

procedure TPic.ReadData(aFileName: string);
begin
  qData.Close;
  qData.SQL.Clear;
  qData.SQL.Text := format('select * from pix where Pix_file="%s"', [aFileName]);
  qData.Open;
  if not qData.EOF then
    AddData([qData.Fields[0].AsInteger, qData.Fields[1].AsString,
      qData.Fields[2].AsString, qData.Fields[3].AsString,
      qData.Fields[4].AsString, qData.Fields[5].AsInteger, qData.Fields[6].AsInteger]);
  qData.Close;
end;

function TPic.GetBackSidePicFileName: string;
begin
  Result := '';
  if Self.fBackSidePicId <= 0 then Exit;
  Result := Pix.GetPicByCode(Self.fBackSidePicId).FileName;
end;

procedure TPic.ReLoad;
begin
  qData.Close;
  qData.SQL.Clear;
  qData.SQL.Text := format('select * from pix where Pix_file="%s"', [Self.fFileName]);
  qData.Open;
  if not qData.EOF then
    AddData([qData.Fields[0].AsInteger, qData.Fields[1].AsString,
      qData.Fields[2].AsString, qData.Fields[3].AsString,
      qData.Fields[4].AsString, qData.Fields[5].AsInteger,
      qData.Fields[6].AsInteger]);
  qData.Close;
  fPersons.LoadFromLinkTable(Self);
end;

procedure TPic.CopyFromPic(aPic: TPic);
var
  i: integer;
begin
  Self.fDateBegin := aPic.fDateBegin;
  Self.fDateEnd := aPic.fDateEnd;
  Self.fDateExact := aPic.fDateExact;
  Self.fPlaceId := aPic.fPlaceId;
  Self.fPlaceCaption := aPic.fPlaceCaption;
  for i := 0 to aPic.Persons.Count - 1 do
    if not Self.fPersons.PersonFound(aPic.Persons.ByIndex[i].fPId) then
      Self.fPersons.Add(aPic.Persons.ByIndex[i]);
  Self.SaveData;
end;

procedure TPic.SaveData;
var
  sDateBeg, sDateEnd, sDateExact, sPlaceId: string;
  sBackSidePicId: string;
  i: integer;
  P: TPerson;
begin
  if Self.fCode < 0 then //this is a temp-fake pic
    Exit;
  qData.Close;
  qData.SQL.Clear;

  {if Self.fDateBegin = '' then
    sDateBeg := 'pix_date_beg=pix_date_beg'
  else }
  sDateBeg := Format('pix_date_beg="%s"', [fDateBegin]);

  {if Self.fDateEnd = '' then
    sDateEnd := 'pix_date_end=pix_date_end'
  else }
  sDateEnd := Format('pix_date_end="%s"', [fDateEnd]);

  {if Self.fDateExact = '' then
    sDateExact := 'pix_date_exact=pix_date_exact'
  else }
  sDateExact := Format('pix_date_exact="%s"', [fDateExact]);

  {if Self.fPlaceId = '' then
    sPlaceId := 'pix_place_id=pix_place_id'
  else }
  sPlaceId := Format('pix_place_id=%s', [fPlaceId]);

  sBackSidePicId := Format('pix_back_side_pic_id = %d', [fBackSidePicId]);


  qData.SQL.Text := format(
    'update pix set pix_id=pix_id,%s,%s,%s,%s,%s  where pix_file = "%s"',
    [sDateBeg, sDateEnd, sDateExact, sPlaceId, sBackSidePicId, Self.fFileName]);
  qData.ExecSQL;

  qData.Close;
  {SQLTransaction1.Commit;

  SQLTransaction1.StartTransaction;
  }qData.Close;
  qData.SQL.Clear;
  qData.SQL.Add(Format('delete from pix_persons  where  pix_id=%d', [Self.fCode]));
  qData.ExecSQL;
  qData.Close;

  for i := 0 to Self.Persons.Count - 1 do
  begin
    qData.Close;
    qData.SQL.Clear;
    P := TPerson(Self.Persons.Items[i]);
    qData.SQL.Add(Format('insert into pix_persons (p_id,pix_id) values (%d,%d)',
      [P.fPId, Self.fCode]));
    qData.ExecSQL;
    qData.Close;
  end;
  //SQLTransaction1.Commit;
end;

procedure TPic.AddEmptyStory;
var
  StoryId: integer;
begin
  {
  if SQLTransaction1.Active then
    SQLTransaction1.Commit;
  SQLTransaction1.StartTransaction;
   }
  qData.Close;
  qData.SQL.Clear;
  qData.SQL.Text := format(
    'insert into stories (story_text) values("enter text here") ', []);
  qData.ExecSQL;
  qData.Close;

  qData.SQL.Clear;
  qData.SQL.Text := format('select max(story_id) from stories', []);
  qData.Open;
  if not qData.EOF then
    StoryId := qData.Fields[0].AsInteger;
  qData.Close;

  qData.SQL.Clear;
  qData.SQL.Text := format('insert into stories_pix (story_id,pic_id) values(%d,%d) ',
    [StoryId, Self.Code]);
  qData.ExecSQL;
  qData.Close;
  {
  SQLTransaction1.Commit;
  SQLTransaction1.StartTransaction;
  }
end;

procedure TPic.SaveStory(StoryId: integer; StoryText: string);
begin

end;

{
procedure TPic.Edit;
var
  fmPixEdit:TfmPixEdit;
begin
  fmPixEdit:=TfmPixEdit.Create(nil);
  try
    fmPixEdit.FIllFormWithData(Self);
    if fmPixEdit.ShowModal=mrOk then
      fmPixEdit.SavePicData(Self);
  finally
    FreeAndNil(fmPixEdit);
  end;
end;
 }

{ TPix }
constructor TPix.Create;
begin
  inherited Create(True);

end;

destructor TPix.Destroy;
begin
  Self.Clear;
  inherited Destroy;
end;

function TPix.GetPicByInd(Ind: integer): TPic;
begin
  Result := nil;
  if (Ind < 0) or (Ind > Self.Count - 1) then
    Exit;
  Result := TPic(Self.Items[Ind]);
end;

function TPix.GetPicByFileName(aFileName: string): TPic;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Self.Count - 1 do
    if Self.PixItems[i].fFileName = aFileName then
    begin
      Result := Self.PixItems[i];
      Exit;
    end;
end;

procedure TPix.ReadPixList;
var
  aPic: TPic;
begin

  qData.Close;
  qData.SQL.Clear;
  qData.SQL.Text := 'select * from pix ';
  qData.Open;
  while not qData.EOF do
  begin
    aPic := TPic.Create;
    aPic.AddData([qData.Fields[0].AsInteger, qData.Fields[1].AsString,
      qData.Fields[2].AsString, qData.Fields[3].AsString,
      qData.Fields[4].AsString, qData.Fields[5].AsInteger,
      qData.Fields[6].AsInteger]);

    Self.Add(aPic);
    qData.Next;
  end;
  qData.Close;
end;

procedure TPix.SetPic(Ind: integer; AValue: TPic);
begin
  if (Ind < 0) or (Ind > Self.Count - 1) then
    Exit;
  Items[Ind] := aValue;
end;

function TPix.GetFiles: TStringList;
var
  i: integer;
begin
  Result := TStringList.Create;
  Result.CaseSensitive := False;
  Result.Sorted := True;
  for i := 0 to Self.Count - 1 do
    Result.Add(Self.PixItems[i].fFileName);
end;

function TPix.GetIndexOf(aFileName: string): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to Self.Count - 1 do
    if Self.PixItems[i].fFileName = aFileName then
    begin
      Result := i;
      Exit;
    end;
end;

procedure TPix.SetPicByFileName(aFileName: string; AValue: TPic);
var
  Ind: integer;
begin
  Ind := Self.GetIndexOf(aFileName);
  if (Ind < 0) or (Ind > Self.Count - 1) then
    Exit;
  Items[Ind] := aValue;
end;

function TPix.GetPicByCode(aCode: integer): TPic;
var
  i: integer;
  aPic: TPic;
begin
  Result := nil;
  for i := 0 to Self.Count - 1 do
  begin
    aPic := Self.GetPicByInd(i);
    if aPic.Code = aCode then
    begin
      Result := aPic;
      Exit;
    end;
  end;
end;

function TPix.FileNameFound(aFileName: string): boolean;
begin
  Result := (0 >= PixFiles.IndexOf(aFileName));
end;



procedure TPix.AddPicQuick(aFileName: string);
var
  aPic: TPic;
begin
  qData.Close;
  qData.SQL.Clear;
  qData.SQL.Text := format('insert into pix (pix_file) values("%s") ', [aFileName]);
  qData.ExecSQL;
  //SQLTransaction1.Commit;
  qData.Close;
  aPic := TPic.Create;
  aPic.ReadData(aFileName);
  Self.Add(aPic);
end;

procedure TPix.DeletePic(aFileName: string);
var
  aPic: TPic;
begin
  aPic := Self.GetPicByFileName(aFileName);
  if aPic = nil then
    Exit;
  {
  SQLTransaction1.Commit;
  SQLTransaction1.StartTransaction;
   }
  qData.Close;
  qData.SQL.Clear;
  qData.SQL.Text := format('delete from pix_persons where pix_id = %d', [aPic.fCode]);
  qData.ExecSQL;

  qData.Close;
  qData.SQL.Clear;
  qData.SQL.Text := format('delete from pix where pix_id = %d', [aPic.fCode]);
  qData.ExecSQL;
  qData.Close;
  {
  SQLTransaction1.Commit;
  SQLTransaction1.StartTransaction;
   }
  Self.Delete(Self.IndexOf(aPic));
end;



initialization

  //SQLConnector1 := TSQLConnection.Create(nil);
  //qData := TSQLQuery.Create(nil);
  //qData.SQLConnection:=SQLConnector1;
 // SQLTransaction1 := TSQLTransaction.Create(nil);
  {SQLConnector1.ConnectionName := 'C:\Users\SG\DEV\FAM_PIX\FAMPIX_DBCR\fampix.db';
  SQLConnector1.DriverName := 'SQLite';
  SQLConnector1.Connected := True;
  SQLConnector1.Params.Add('User=""');
  SQLConnector1.Params.Add('Password=""');}
  {SQLTransaction1.DataBase := SQLConnector1;
  SQLTransaction1.Active := True;
  qData.DataBase := SQLConnector1;
  qData.Transaction := SQLTransaction1;
   }

  ZConnection1:=TZConnection.Create(nil);
  ZConnection1.Database:='C:\Users\SG\DEV\FAM_PIX\FAMPIX_DBCR3\fampix1.db';
  ZConnection1.Protocol:='sqlite';
  ZConnection1.Connected:=true;

  ZTransaction1:=TZTransaction.Create(nil);
  ZTransaction1.Connection:=ZConnection1;


  qData:=TZQuery.Create(nil);
  qData.Transaction:=ZTransaction1;
  qData.Connection:=ZConnection1;


  Places := TPlaces.Create;
  Places.LoadData;

  Persons := TPersons.Create(True);
  Persons.LoadFromVocab;

  Stories:=TStories.Create(true);
  Stories.Load;

  Pix := TPix.Create;
  Pix.ReadPixList;


finalization
  qData.Close;
  {SQLTransaction1.Commit;
  SQLTransaction1.Active := False;
  SQLConnector1.Connected := False;

  FreeAndNil(SQLConnector1);
  FreeAndNil(qData);        }
  //FreeAndNil(SQLTransaction1);

  FreeAndNil(ZConnection1);
  FreeAndNil(ZTransaction1);
  FreeAndNil(qData);


  FreeAndNil(Places);
  FreeAndNil(Persons);
  FreeAndNil(Stories);
  FreeAndNil(Pix);
end.
