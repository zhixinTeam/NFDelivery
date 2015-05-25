{*******************************************************************************
  作者: dmzn@163.com 2010-10-17
  描述: 选择车牌号
*******************************************************************************}
unit UFormGetMine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxCheckBox, Menus,
  cxLabel, cxListView, cxTextEdit, cxMaskEdit, cxButtonEdit,
  dxLayoutControl, StdCtrls;

type
  TfFormGetMine = class(TfFormNormal)
    EditMine: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    ListMine: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    Check1: TcxCheckBox;
    dxLayout1Item3: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure ListMineKeyPress(Sender: TObject; var Key: Char);
    procedure EditCIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ListMineDblClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure Check1Click(Sender: TObject);
  private
    { Private declarations }
    function QueryMine(const nMine: string): Boolean;
    //查询矿点
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UFormBase, USysGrid, USysDB, USysConst,
  USysBusiness, UDataModule, UFormInputbox;

class function TfFormGetMine.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetMine.Create(Application) do
  begin
    Caption := '选择矿点';

    EditMine.Text := nP.FParamA;
    if QueryMine(EditMine.Text) then
    begin
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;

      if nP.FParamA = mrOK then
        nP.FParamB := ListMine.Items[ListMine.ItemIndex].Caption;
    end;  

    Free;
  end;
end;

class function TfFormGetMine.FormID: integer;
begin
  Result := cFI_FormGetMine;
end;

procedure TfFormGetMine.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListMine, nIni);
    Check1.Checked := nIni.ReadBool(Name, 'AllMine', False);
  finally
    nIni.Free;
  end;
end;

procedure TfFormGetMine.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListMine, nIni);
    nIni.WriteBool(Name, 'AllMine', Check1.Checked);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 查询矿点信息
function TfFormGetMine.QueryMine(const nMine: string): Boolean;
var nStr: string;
begin
  Result := False;
  if Trim(nMine) = '' then Exit;
  ListMine.Items.Clear;

  nStr := 'Select * From %s Where (M_PY Like ''%%%s%%'' or ' +
          'M_Mine Like ''%%%s%%'' or M_CusID=''%s'')';
  nStr := Format(nStr, [sTable_Mine, Trim(nMine), Trim(nMine), Trim(nMine)]);

  if not Check1.Checked then
    nStr := nStr + Format(' And (M_Valid Is Null or M_Valid<>''%s'') ', [sFlag_No]);
  nStr := nStr + ' Order By M_PY';

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      with ListMine.Items.Add do
      begin
        Caption := FieldByName('M_Mine').AsString;
        SubItems.Add(FieldByName('M_Owner').AsString);
        SubItems.Add(FieldByName('M_Phone').AsString);
        SubItems.Add(FieldByName('M_CusName').AsString);

        ImageIndex := 11;
        StateIndex := ImageIndex;
      end;

      Next;
    end;
  end else Exit;

  Result := ListMine.Items.Count > 0;
  if Result then
  begin
    ActiveControl := ListMine;
    ListMine.ItemIndex := 0;
    ListMine.ItemFocused := ListMine.TopItem;
  end;
end;

//Desc: 修改矿点联系人姓名
procedure TfFormGetMine.N1Click(Sender: TObject);
var nStr,nTmp: string;
begin
  if ListMine.ItemIndex < 0 then Exit;

  while True do
  begin
    nTmp := ListMine.Items[ListMine.ItemIndex].SubItems[0];
    if not ShowInputBox('请输入联系人姓名:', sHint, nTmp, 32) then Exit;

    nTmp := Trim(nTmp);
    if nTmp <> '' then Break;
  end;

  nStr := 'Update %s Set M_Owner=''%s'' Where M_Mine=''%s''';
  nStr := Format(nStr, [sTable_Mine, nTmp,
          ListMine.Items[ListMine.ItemIndex].Caption]);
  //xxxxx

  FDM.ExecuteSQL(nStr);
  ListMine.Items[ListMine.ItemIndex].SubItems[0] := nTmp;
  ShowMsg('更新成功', sHint);
end;

//Desc: 修改联系方式
procedure TfFormGetMine.N2Click(Sender: TObject);
var nStr,nTmp: string;
begin
  if ListMine.ItemIndex < 0 then Exit;

  while True do
  begin
    nTmp := ListMine.Items[ListMine.ItemIndex].SubItems[1];
    if not ShowInputBox('请输入矿点联系方式:', sHint, nTmp, 15) then Exit;

    nTmp := Trim(nTmp);
    if nTmp <> '' then Break;
  end;

  nStr := 'Update %s Set M_Phone=''%s'' Where M_Mine=''%s''';
  nStr := Format(nStr, [sTable_Mine, nTmp,
          ListMine.Items[ListMine.ItemIndex].Caption]);
  //xxxxx

  FDM.ExecuteSQL(nStr);
  ListMine.Items[ListMine.ItemIndex].SubItems[1] := nTmp;
  ShowMsg('更新成功', sHint);
end;

//Desc: 显/隐矿点
procedure TfFormGetMine.N4Click(Sender: TObject);
var nStr,nTmp: string;
begin
  if ListMine.ItemIndex < 0 then Exit;
  if Sender = N4 then
       nTmp := sFlag_No
  else nTmp := sFlag_Yes;

  nStr := 'Update %s Set M_Valid=''%s'' Where M_Mine=''%s''';
  nStr := Format(nStr, [sTable_Mine, nTmp,
          ListMine.Items[ListMine.ItemIndex].Caption]);
  //xxxxx

  FDM.ExecuteSQL(nStr);
  ShowMsg('更新成功', sHint);
end;

//------------------------------------------------------------------------------
procedure TfFormGetMine.EditCIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  QueryMine(EditMine.Text);
end;

procedure TfFormGetMine.ListMineKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;

    if ListMine.ItemIndex > -1 then
      ModalResult := mrOk;
    //xxxxx
  end;
end;

procedure TfFormGetMine.ListMineDblClick(Sender: TObject);
begin
  if ListMine.ItemIndex > -1 then
    ModalResult := mrOk;
  //xxxxx
end;

procedure TfFormGetMine.BtnOKClick(Sender: TObject);
begin
  if ListMine.ItemIndex > -1 then
       ModalResult := mrOk
  else ShowMsg('请在查询结果中选择', sHint);
end;

procedure TfFormGetMine.Check1Click(Sender: TObject);
begin
  inherited;
  QueryMine(EditMine.Text);
end;

initialization
  gControlManager.RegCtrl(TfFormGetMine, TfFormGetMine.FormID);
end.
