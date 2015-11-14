{*******************************************************************************
  作者: dmzn@163.com 2013-12-05
  描述: 管理数据库参数
*******************************************************************************}
unit UFormParamDB;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UMgrDBConn, UFormBase, ExtCtrls, StdCtrls;

type
  TfFormParamDB = class(TBaseForm)
    ListParam: TListBox;
    BtnAdd: TButton;
    BtnDel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    EditID: TEdit;
    Label3: TLabel;
    EditName: TEdit;
    Bevel1: TBevel;
    BtnExit: TButton;
    BtnOK: TButton;
    Label4: TLabel;
    EditIP: TEdit;
    Label5: TLabel;
    EditPort: TEdit;
    Label6: TLabel;
    EditDB: TEdit;
    Label7: TLabel;
    EditUser: TEdit;
    Label8: TLabel;
    EditPwd: TEdit;
    Label9: TLabel;
    EditWorker: TEdit;
    Label10: TLabel;
    MemoConn: TMemo;
    BtnConnect: TButton;
    procedure ListParamClick(Sender: TObject);
    procedure EditIDChange(Sender: TObject);
    procedure EditIDKeyPress(Sender: TObject; var Key: Char);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FParams: array of TDBParam;
    //参数缓存
    procedure LoadParams;
    procedure InitFormData(const nID: string);
    //界面数据
    function IsParamValid(const nID: string): Boolean;
    //校正判定

    procedure InitDB(var nParam: TDBParam);
    //初始化数据库
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TFormCreateResult; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UWeiXinConst;

class function TfFormParamDB.CreateForm(const nPopedom: string;
  const nParam: Pointer): TFormCreateResult;
var nStr: string;
begin
  Result := inherited CreateForm(nPopedom, nParam);
  if Assigned(nParam) then
       nStr := PFormCommandParam(nParam).FParamA
  else nStr := '';

  with TfFormParamDB.Create(Application) do
  try
    BtnOK.Enabled := False;

    LoadParams;
    InitFormData(nStr);
    Result.FModalResult := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormParamDB.FormID: integer;
begin
  Result := cFI_FormDB;
end;

//------------------------------------------------------------------------------
procedure TfFormParamDB.LoadParams;
var nIdx, nInt, nLenFL, nLenDB: Integer;
    nDBItemsFL, nDBItemsDB: TDBParams;
begin
  LoadDBParamFromDB(nDBItemsDB);
  LoadDBParamFromFile(gWeiXinPath + sDBConfigFile, nDBItemsFL);

  nLenFL := Length(nDBItemsFL);
  nLenDB := Length(nDBItemsDB);
  SetLength(FParams, nLenFL+nLenDB);

  nInt := Low(FParams);
  for nIdx:=Low(nDBItemsFL) to High(nDBItemsFL) do
  begin
    FParams[nInt] := nDBItemsFL[nIdx];
    Inc(nInt);
  end;
  //文件中数据库参数

  for nIdx:=Low(nDBItemsDB) to High(nDBItemsDB) do
  begin
    FParams[nInt] := nDBItemsDB[nIdx];
    Inc(nInt);
  end;
  //数据库中数据库参数
end;

procedure TfFormParamDB.InitFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
begin
  ListParam.Clear;
  for nIdx:=Low(FParams) to High(FParams) do
  if FParams[nIdx].FEnable then
  begin
    nStr := Format('%d.%s', [ListParam.Items.Count+1, FParams[nIdx].FName]);
    ListParam.Items.AddObject(nStr, Pointer(nIdx));

    if FParams[nIdx].FID = nID then
    begin
      ListParam.ItemIndex := ListParam.Items.Count - 1;
      ListParamClick(nil);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormParamDB.EditIDKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in cParamIDCharacters) then
  begin
    Key := #0;
  end;
end;

procedure TfFormParamDB.ListParamClick(Sender: TObject);
var nIdx: Integer;
begin
  if ListParam.ItemIndex < 0 then Exit;
  nIdx := Integer(ListParam.Items.Objects[ListParam.ItemIndex]);

  with FParams[nIdx] do
  begin
    EditID.Text := FID;
    EditName.Text := FName;
    EditIP.Text := FHost;
    EditPort.Text := IntToStr(FPort);
    
    EditUser.Text := FUser;
    EditPwd.Text := FPwd;
    EditDB.Text := FDB;
    EditWorker.Text := IntToStr(FNumWorker);
    MemoConn.Text := FConn;
  end;
end;

procedure TfFormParamDB.EditIDChange(Sender: TObject);
var nIdx: Integer;
begin
  if ActiveControl <> Sender then Exit;
  if ListParam.ItemIndex < 0 then Exit;
  nIdx := Integer(ListParam.Items.Objects[ListParam.ItemIndex]);

  with FParams[nIdx] do
  begin
    if Sender = EditID then
    begin
      if EditID.Text = '' then Exit;
      FID := EditID.Text;
    end else

    if Sender = EditName then
    begin
      if EditName.Text = '' then Exit;
      FName := EditName.Text;
      InitFormData(FID);
    end else

    if Sender = EditIP then
    begin
      FHost := EditIP.Text;
    end else

    if Sender = EditPort then
    begin
      if not IsNumber(EditPort.Text, False) then Exit;
      FPort := StrToInt(EditPort.Text);
    end else

    if Sender = EditUser then
    begin
      FUser := EditUser.Text;
    end else

    if Sender = EditPwd then
    begin
      FPwd := EditPwd.Text;
    end else

    if Sender = EditDB then
    begin
      FDB := EditDB.Text;
    end else

    if Sender = EditWorker then
    begin
      if not IsNumber(EditWorker.Text, False) then Exit;
      FNumWorker := StrToInt(EditWorker.Text);
    end else

    if Sender = MemoConn then
    begin
      FConn := MemoConn.Text;
    end;

    BtnOK.Enabled := BtnAdd.Enabled;
  end;
end;

procedure TfFormParamDB.BtnAddClick(Sender: TObject);
var nIdx: Integer;
    nDB: TDBParam;
begin
  for nIdx:=Low(FParams) to High(FParams) do
   if FParams[nIdx].FEnable and (FParams[nIdx].FID = 'new_db') then Exit;
  //has exits

  InitDB(nDB);
  nDB.FID := 'new_db';
  nDB.FName := '新建数据库';

  nIdx := Length(FParams);
  SetLength(FParams, nIdx + 1);

  FParams[nIdx] := nDB;
  FParams[nIdx].FEnable := True;

  BtnOK.Enabled := True;
  InitFormData(nDB.FID);
end;

procedure TfFormParamDB.BtnDelClick(Sender: TObject);
var nStr: string;
    nIdx: Integer;
begin
  if ListParam.ItemIndex < 0 then Exit;
  nIdx := Integer(ListParam.Items.Objects[ListParam.ItemIndex]);

  nStr := Format('确定要删除[ %s ]数据库吗?', [FParams[nIdx].FName]);
  if QueryDlg(nStr, sAsk, Handle) then
  begin
    FParams[nIdx].FEnable := False;
    BtnOK.Enabled := True;

    Dec(nIdx);
    if nIdx >= Low(FParams) then
    begin
      InitFormData(FParams[nIdx].FID);
      Exit;
    end;

    Inc(nIdx, 2);
    if nIdx <= High(FParams) then
      InitFormData(FParams[nIdx].FID);
    //xxxxx
  end;
end;

//------------------------------------------------------------------------------
//Desc: 判定nID是否在FPacks中
function TfFormParamDB.IsParamValid(const nID: string): Boolean;
var nIdx: Integer;
begin
  for nIdx:=Low(FParams) to High(FParams) do
  if FParams[nIdx].FEnable and (FParams[nIdx].FID = nID) then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
end;

procedure TfFormParamDB.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    //gParamManager.LoadParam(nList, ptDB);
    for nIdx:=nList.Count - 1 downto 0 do
     if not IsParamValid(nList[nIdx]) then
     ; //gParamManager.DelDB(nList[nIdx]);
    //delete valid
  finally
    nList.Free;
  end;

  for nIdx:=Low(FParams) to High(FParams) do
   if FParams[nIdx].FEnable then
    ;//gParamManager.AddDB(FParams[nIdx]);
  ModalResult := mrOk;
end;

//Date: 2012-3-5
//Parm: 参数
//Desc: 初始化nParam参数
procedure TfFormParamDB.InitDB(var nParam: TDBParam);
begin
  with nParam do
  begin
    FHost := '127.0.0.1';
    FPort := 1433;
    FDB   := 'DBName';
    FUser := 'sa';
    FPwd  := '';
    FConn := 'Provider=SQLOLEDB.1;Password=$Pwd;Persist Security Info=True;' +
             'User ID=$User;Initial Catalog=$DBName;Data Source=$Host';
    FNumWorker := 20;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormParamDB, TfFormParamDB.FormID);
end.
