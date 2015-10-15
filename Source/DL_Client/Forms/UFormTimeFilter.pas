{*******************************************************************************
  作者: dmzn@163.com 2009-6-5
  描述: 日期筛选框
*******************************************************************************}
unit UFormTimeFilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, StdCtrls, dxLayoutControl, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxCalendar, cxControls, cxGraphics,
  cxLookAndFeels, cxLookAndFeelPainters, cxSpinEdit, cxTimeEdit,
  cxButtonEdit, cxListBox, ComCtrls, cxListView;

type
  TTimeFilter = record
    FID    : string;         //编号

    FStart : TTime;          //起始时间
    FEnd   : TTime;          //结束时间

    FNew   : Boolean;        //新增
    FDelete: Boolean;        //删除
  end;
  TTimeFilters = array of TTimeFilter;

  TfFormTimeFilter = class(TForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnSave: TButton;
    dxLayoutControl1Item3: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    ItemID: TcxButtonEdit;
    dxLayoutControl1Item5: TdxLayoutItem;
    EditStart: TcxTimeEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    EditEnd: TcxTimeEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    dxLayoutControl2Group_Root: TdxLayoutGroup;
    dxLayoutControl2: TdxLayoutControl;
    ListInfo: TcxListView;
    dxLayoutControl2Item1: TdxLayoutItem;
    BtnAdd: TButton;
    dxLayoutControl1Item6: TdxLayoutItem;
    BtnDel: TButton;
    dxLayoutControl1Item7: TdxLayoutItem;
    procedure BtnSaveClick(Sender: TObject);
    procedure ItemIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure ListInfoClick(Sender: TObject);
    procedure EditStartPropertiesEditValueChanged(Sender: TObject);
  private
    { Private declarations }
    FTimeFilterList: TTimeFilters;
  public
    { Public declarations }
     procedure InitItemList(nFromDB: Boolean=False);
  end;

function ShowTimeFilterForm: Boolean;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, USysConst, USysBusiness, USysDB;

//Date: 2009-6-5
//Parm: 开始日期;结束日期
//Desc: 显示时间段筛选窗口
function ShowTimeFilterForm: Boolean;
begin
  with TfFormTimeFilter.Create(Application) do
  begin
    Caption := '暗扣时间段设置';

    SetLength(FTimeFilterList,0);
    InitItemList(True);

    Result := ShowModal = mrOK;
    Free;
  end;
end;

//Desc: 日期选择
procedure TfFormTimeFilter.BtnSaveClick(Sender: TObject);
var nIdx: Integer;
    nStr: string;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    for nIdx:=Low(FTimeFilterList) to High(FTimeFilterList) do
    with FTimeFilterList[nIdx] do
    begin
      if FNew then
      begin
        FNew := False;
        nStr := 'Insert Into $DB(D_Name,D_Memo,D_Value,D_ParamB,D_Desc) ' +
                'Values(''$PM'', ''$ID'', ''$FStart'', ''$FEnd'',''暗扣时间段'')';
      end else
      if FDelete then
      begin
        FDelete := False;
        nStr := 'Delete From $DB Where D_Name=''$PM'' and D_Memo=''$ID''';
      end else
      begin
        nStr := 'Update $DB Set D_Value=''$FStart'', D_ParamB=''$FEnd''' +
                'Where D_Name=''$PM'' and D_Memo=''$ID''';
      end;

      nStr := MacroValue(nStr , [MI('$DB', sTable_SysDict),
              MI('$PM', sFlag_DuctTimeItem), MI('$ID', FID),
              MI('$FStart', Time2Str(FStart)), MI('$FEnd', Time2Str(FEnd))]);
      nList.Add(nStr);
    end;

    FDM.ADOConn.BeginTrans;
    try
      for nIdx:=0 to nList.Count-1 do
        FDM.ExecuteSQL(nList[nIdx]);

      FDM.ADOConn.CommitTrans;

      ShowMsg('保存成功', sHint);
    except
      FDM.ADOConn.RollbackTrans;
      raise;
    end;
  finally
    FreeAndNil(nList);
  end;
end;

procedure TfFormTimeFilter.ItemIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = ItemID then
  begin
    if ItemID.Properties.ReadOnly then Exit;

    ItemID.Text := GetSerialNo(sFlag_BusGroup, sFlag_DuctTime, True);
    if ItemID.Text <> '' then ItemID.Properties.ReadOnly := True;
  end;
end;

procedure TfFormTimeFilter.InitItemList(nFromDB: Boolean=False);
var nStr: string;
    nIdx: Integer;
begin
  if nFromDB then
  begin
    nStr := 'Select D_Value, D_Memo, D_ParamB From $DB ' +
            'Where D_Name=''$PM''';
    nStr := MacroValue(nStr, [MI('$DB', sTable_SysDict),
            MI('$PM', sFlag_DuctTimeItem)]);
    //xxxxx

    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount<1 then Exit;

      SetLength(FTimeFilterList, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      with FTimeFilterList[nIdx] do
      begin
        FNew    := False;
        FDelete := False;

        FID     := FieldByName('D_Memo').AsString;  //编号
        FStart  := Str2Time(FieldByName('D_Value').AsString);
        FEnd    := Str2Time(FieldByName('D_ParamB').AsString);

        Inc(nIdx);
        Next;
      end;
    end;

    InitItemList;
  end
  else
  begin
    ListInfo.Items.Clear;
    for nIdx:=Low(FTimeFilterList) to High(FTimeFilterList) do
    with FTimeFilterList[nIdx] do
    begin
      if FDelete then Continue;

      with ListInfo.Items.Add do
      begin
        Caption     := FID;
        SubItems.Add(Time2Str(FStart));
        SubItems.Add(Time2Str(FEnd));
      end;
    end;

    ListInfo.ItemIndex:=0;
    ItemID.Text := '';
    ItemID.Properties.ReadOnly := False;
  end;
end;

procedure TfFormTimeFilter.BtnAddClick(Sender: TObject);
var nInt: Integer;
    nStr, nItemID: string;
begin
  nItemID := Trim(ItemID.Text);
  if nItemID = '' then
  begin
    nStr := '编号不能为空';
    ShowMsg(nStr, sHint);
    Exit;
  end;

  if EditEnd.Time < EditStart.Time then
  begin
    EditEnd.SetFocus;
    ShowMsg('结束时间不能小于开始时间', sHint);
    Exit;
  end;

  for nInt := Low(FTimeFilterList) to High(FTimeFilterList) do
  if CompareText(FTimeFilterList[nInt].FID, nItemID)=0 then
  begin
    if FTimeFilterList[nInt].FDelete then FTimeFilterList[nInt].FDelete:=False;

    Exit;
  end;

  nInt := Length(FTimeFilterList);
  SetLength(FTimeFilterList, nInt+1);
  with FTimeFilterList[nInt] do
  begin
    FID    := nItemID;
    FStart := EditStart.Time;
    FEnd   := EditEnd.Time;

    FNew    := True;
    FDelete := False;
  end;

  InitItemList;
end;

procedure TfFormTimeFilter.BtnDelClick(Sender: TObject);
var nInt: Integer;
    nStr, nItemID: string;
begin
  nItemID := Trim(ItemID.Text);
  if nItemID = '' then
  begin
    nStr := '编号不能为空';
    ShowDlg(nStr, sHint);
    Exit;
  end;

  for nInt := Low(FTimeFilterList) to High(FTimeFilterList) do
  with FTimeFilterList[nInt] do
  begin
    if CompareText(FID, nItemID)=0 then FDelete := True;
  end;

  InitItemList;
end;

procedure TfFormTimeFilter.ListInfoClick(Sender: TObject);
var nIdx: Integer;
begin
  if ListInfo.ItemIndex<0 then Exit;

  for nIdx := Low(FTimeFilterList) to High(FTimeFilterList) do
  with FTimeFilterList[nIdx] do
  begin
    if CompareText(FID, ListInfo.Selected.Caption)=0 then
    begin
      ItemID.Text := FID;
      EditStart.Time := FStart;
      EditEnd.Time   := FEnd;
    end;
  end;
end;

procedure TfFormTimeFilter.EditStartPropertiesEditValueChanged(
  Sender: TObject);
var nItemID: string;
    nIdx: Integer;
begin
  nItemID := Trim(ItemID.Text);
  if nItemID='' then Exit;

  for nIdx := Low(FTimeFilterList) to High(FTimeFilterList) do
  with FTimeFilterList[nIdx] do
  begin
    if CompareText(FID, nItemID)=0 then
    begin
      if Sender=EditStart then
        FStart := EditStart.Time;
      if Sender=EditEnd then
        FEnd   := EditEnd.Time;
      Break;
    end;
  end;
end;

end.
