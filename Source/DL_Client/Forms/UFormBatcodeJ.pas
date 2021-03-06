{*******************************************************************************
  作者: dmzn@163.com 2015-01-16
  描述: 批次档案管理
*******************************************************************************}
unit UFormBatcodeJ;

{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxCheckBox, cxTextEdit,
  dxLayoutControl, StdCtrls, cxMaskEdit, cxDropDownEdit, cxLabel;

type
  TfFormBatcode = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditPrefix: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    EditStock: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Item6: TdxLayoutItem;
    EditInc: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditBase: TcxTextEdit;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Item8: TdxLayoutItem;
    EditLen: TcxTextEdit;
    Check1: TcxCheckBox;
    dxLayout1Item10: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    EditLow: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditHigh: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    Check2: TcxCheckBox;
    dxLayout1Item13: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    cxLabel1: TcxLabel;
    dxLayout1Item14: TdxLayoutItem;
    dxLayout1Group7: TdxLayoutGroup;
    cxLabel2: TcxLabel;
    dxLayout1Item15: TdxLayoutItem;
    dxLayout1Group8: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item16: TdxLayoutItem;
    cxLabel3: TcxLabel;
    dxLayout1Item17: TdxLayoutItem;
    dxLayout1Group9: TdxLayoutGroup;
    EditWeek: TcxTextEdit;
    dxLayout1Item18: TdxLayoutItem;
    dxLayout1Group10: TdxLayoutGroup;
    cxLabel4: TcxLabel;
    dxLayout1Item19: TdxLayoutItem;
    dxLayout1Group11: TdxLayoutGroup;
    dxLayout1Group6: TdxLayoutGroup;
    EditType: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    EditBatcode: TcxTextEdit;
    dxLayout1Item20: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    cxLabel5: TcxLabel;
    dxLayout1Item21: TdxLayoutItem;
    dxLayout1Group12: TdxLayoutGroup;
    EditLineGroup: TcxComboBox;
    dxLayout1Item22: TdxLayoutItem;
    ChkValid: TcxCheckBox;
    dxLayout1Item23: TdxLayoutItem;
    EditBrand: TcxComboBox;
    dxLayout1Item24: TdxLayoutItem;
    EditKw: TcxTextEdit;
    dxLayout1Item25: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditStockPropertiesEditValueChanged(Sender: TObject);
  protected
    { Protected declarations }
    FRecordID: string;
    //记录编号
    FOldBase: string;
    //旧基数
    FUseBrand: Boolean;
    //使用品牌
    procedure LoadFormData(const nID: string);
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    //验证数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UAdjustForm, UFormCtrl, USysDB, USysConst,
  USysBusiness;

class function TfFormBatcode.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormBatcode.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '批次 - 添加';
      FRecordID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '批次 - 修改';
      FRecordID := nP.FParamA;
    end;

    LoadFormData(FRecordID);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBatcode.FormID: integer;
begin
  Result := cFI_FormBatch;
end;

procedure TfFormBatcode.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ReleaseCtrlData(Self);
end;

procedure TfFormBatcode.LoadFormData(const nID: string);
var nStr: string;
begin
  FUseBrand := False;

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_AutoBatBrand]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
      FUseBrand := FieldByName('D_Value').AsString = sFlag_Yes;
  end;

  nStr := 'D_ParamB=Select D_ParamB,D_Value From %s Where D_Name=''%s'' ' +
          'And D_Index>=0 Order By D_Index DESC';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  FDM.FillStringsData(EditStock.Properties.Items, nStr, 0, '.');
  AdjustCXComboBoxItem(EditStock, False);

  nStr := 'D_Value=Select D_Value,D_Memo From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_TiHuoTypeItem]);

  FDM.FillStringsData(EditType.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditType, False);

  {$IFDEF AutoGetLineGroup}
  dxLayout1Item22.Visible := True;
  nStr := 'D_Value=Select D_Value,D_Memo From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_ZTLineGroup]);

  FDM.FillStringsData(EditLineGroup.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditLineGroup, False);

  dxLayout1Item24.Visible := True;
  nStr := 'Select distinct D_ParamB From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_BatBrandGroup]);

  EditBrand.Properties.Items.Clear;

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;

    First;

    while not Eof do
    begin
        EditBrand.Properties.Items.Add(Fields[0].AsString);
      Next;
    end;
  end;
  {$ELSE}
  dxLayout1Item22.Visible := False;
  EditLineGroup.Text := '';
  //dxLayout1Item23.Visible := False;

  if FUseBrand then
  begin
    dxLayout1Item24.Visible := True;
    EditBrand.Properties.Items.Clear;

    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_Brands]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      SplitStr(Fields[0].AsString, EditBrand.Properties.Items, 0, ';');
    end;
  end
  else
  begin
    dxLayout1Item24.Visible := False;
    EditBrand.Text := '';
    //dxLayout1Item23.Visible := False;
  end;
  {$ENDIF}

  {$IFDEF BatCodeByLine}
  dxLayout1Item25.Visible := True;
  {$ELSE}
  dxLayout1Item25.Visible := False;
  EditKw.Text := '';
  {$ENDIF}

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Batcode, nID]);
    FDM.QueryTemp(nStr);

    with FDM.SqlTemp do
    begin
      nStr := FieldByName('B_Stock').AsString;
      SetCtrlData(EditStock, nStr);

      nStr := FieldByName('B_Type').AsString;
      SetCtrlData(EditType, nStr);

      EditName.Text := FieldByName('B_Name').AsString;
      EditBase.Text := FieldByName('B_Base').AsString;
      FOldBase := FieldByName('B_Base').AsString;
      EditLen.Text := FieldByName('B_Length').AsString;

      EditPrefix.Text := FieldByName('B_Prefix').AsString;
      EditInc.Text := FieldByName('B_Incement').AsString;
      Check1.Checked := FieldByName('B_UseDate').AsString = sFlag_Yes;

      EditBatcode.Text := FieldByName('B_Batcode').AsString;
      EditValue.Text := FieldByName('B_Value').AsString;
      EditLow.Text := FieldByName('B_Low').AsString;
      EditHigh.Text := FieldByName('B_High').AsString;
      EditWeek.Text := FieldByName('B_Interval').AsString;
      {$IFDEF AutoGetLineGroup}
      nStr := FieldByName('B_LineGroup').AsString;
      SetCtrlData(EditLineGroup, nStr);

      nStr := FieldByName('B_BrandGroup').AsString;
      SetCtrlData(EditBrand, nStr);
      ChkValid.Checked := FieldByName('B_Valid').AsString = sFlag_Yes;
      {$ELSE}
      if FUseBrand then
      begin
        nStr := FieldByName('B_BrandGroup').AsString;
        SetCtrlData(EditBrand, nStr);
      end;
      ChkValid.Checked := FieldByName('B_Valid').AsString = sFlag_Yes;
      {$ENDIF}
      {$IFDEF BatCodeByLine}
      EditKw.Text := FieldByName('B_Kw').AsString;
      {$ENDIF}
      Check2.Checked := FieldByName('B_AutoNew').AsString = sFlag_Yes;
    end;
  end;

  EditStock.SelLength := 0;
  EditStock.SelStart := 1;
  ActiveControl := EditPrefix;
end;

procedure TfFormBatcode.EditStockPropertiesEditValueChanged(Sender: TObject);
var nStr: string;
begin
  nStr := EditStock.Text;
  System.Delete(nStr, 1, Length(GetCtrlData(EditStock) + '.'));
  EditName.Text := nStr;
end;

function TfFormBatcode.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nStr: string;
begin
  Result := True;

  if Sender = EditStock then
  begin
    Result := EditStock.ItemIndex >= 0;
    nHint := '请选择物料';
    if not Result then Exit;

    {$IFDEF BatCodeByLine}
    nStr := 'Select R_ID From %s Where B_Stock=''%s'' And B_Type=''%s'' and B_Kw=''%s''';
    nStr := Format(nStr, [sTable_Batcode, GetCtrlData(EditStock),
            GetCtrlData(EditType), EditKw.Text]);
    {$ELSE}
      {$IFDEF AutoGetLineGroup}
      nStr := 'Select R_ID From %s Where B_Stock=''%s'' And B_Type=''%s'' ' +
              'And B_LineGroup = ''%s'' And B_BrandGroup=''%s''';
      nStr := Format(nStr, [sTable_Batcode, GetCtrlData(EditStock),
              GetCtrlData(EditType), GetCtrlData(EditLineGroup), GetCtrlData(EditBrand)]);
      {$ELSE}
      if FUseBrand then
      begin
        nStr := 'Select R_ID From %s Where B_Stock=''%s'' And B_Type=''%s'' ' +
                ' And B_BrandGroup=''%s''';
        nStr := Format(nStr, [sTable_Batcode, GetCtrlData(EditStock),
                GetCtrlData(EditType), GetCtrlData(EditBrand)]);
      end
      else
      begin
        nStr := 'Select R_ID From %s Where B_Stock=''%s'' And B_Type=''%s''';
        nStr := Format(nStr, [sTable_Batcode, GetCtrlData(EditStock),
                GetCtrlData(EditType)]);
      end;
      {$ENDIF}
    {$ENDIF}

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      Result := FRecordID = Fields[0].AsString;
      nHint := '该物料的编码规则已存在';
    end;
  end else

  if Sender = EditBase then
  begin
    Result := IsNumber(EditBase.Text, False);
    nHint := '请输入基数';
  end else

  if Sender = EditInc then
  begin
    Result := IsNumber(EditInc.Text, False);
    nHint := '请输入增量';
  end else

  if Sender = EditLen then
  begin
    Result := IsNumber(EditLen.Text, False);
    nHint := '请输入长度';
  end else

  if Sender = EditValue then
  begin
    Result := Check1.Checked or (IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text) > 0));
    nHint := '请输入检测量';
  end else

  if Sender = EditLow then
  begin
    Result := Check1.Checked or (IsNumber(EditLow.Text, True) and (StrToFloat(EditLow.Text) >= 0));
    nHint := '请输入超发提醒';
  end else

  if Sender = EditHigh then
  begin
    Result := Check1.Checked or (IsNumber(EditHigh.Text, True) and (StrToFloat(EditHigh.Text) >= 0));
    nHint := '请输入超发上限';
  end else

  if Sender = EditWeek then
  begin
    Result := Check1.Checked or (IsNumber(EditWeek.Text, False) and (StrToFloat(EditWeek.Text) >= 0));
    nHint := '请输入周期值';
  end else

  if Sender = EditKw then
  begin
    {$IFDEF BatCodeByLine}
    Result := Length(Trim(EditKw.Text)) > 0;
    nHint := '请输入库号,格式为:(1,2,3)';
    {$ENDIF}
  end;
end;

//Desc: 保存
procedure TfFormBatcode.BtnOKClick(Sender: TObject);
var nStr,nU,nN, nV: string;
    nP,nTmp,nBatCode: string;
    nInt: Integer;
begin
  if not IsDataValid then Exit;
  //验证不通过

  if Check1.Checked then
       nU := sFlag_Yes
  else nU := sFlag_No;

  if Check2.Checked then
       nN := sFlag_Yes
  else nN := sFlag_No;

  if ChkValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if FRecordID = '' then
       nStr := ''
  else nStr := SF('R_ID', FRecordID, sfVal);

  if FUseBrand then
  begin
    nStr := MakeSQLByStr([SF('B_Stock', GetCtrlData(EditStock)),
            SF('B_Name', EditName.Text),
            SF('B_Prefix', EditPrefix.Text),
            SF('B_Base', EditBase.Text, sfVal),
            SF('B_Length', EditLen.Text, sfVal),
            SF('B_Incement', EditInc.Text, sfVal),
            SF('B_UseDate', nU),

            SF('B_AutoNew', nN),
            SF('B_Low', EditLow.Text, sfVal),
            SF('B_High', EditHigh.Text, sfVal),
            SF('B_Value', EditValue.Text, sfVal),
            SF('B_Interval', EditWeek.Text, sfVal),
            SF('B_LastDate', sField_SQLServer_Now, sfVal),
            SF('B_BrandGroup', GetCtrlData(EditBrand)),
            SF('B_Batcode', EditBatcode.Text),
            SF('B_Valid', nV),
            SF('B_Type', GetCtrlData(EditType))
            ], sTable_Batcode, nStr, FRecordID = '');
  end
  else
  begin
    nStr := MakeSQLByStr([SF('B_Stock', GetCtrlData(EditStock)),
            SF('B_Name', EditName.Text),
            SF('B_Prefix', EditPrefix.Text),
            SF('B_Base', EditBase.Text, sfVal),
            SF('B_Length', EditLen.Text, sfVal),
            SF('B_Incement', EditInc.Text, sfVal),
            SF('B_UseDate', nU),

            SF('B_AutoNew', nN),
            SF('B_Low', EditLow.Text, sfVal),
            SF('B_High', EditHigh.Text, sfVal),
            SF('B_Value', EditValue.Text, sfVal),
            SF('B_Interval', EditWeek.Text, sfVal),
            SF('B_LastDate', sField_SQLServer_Now, sfVal),
            {$IFDEF AutoGetLineGroup}
            SF('B_LineGroup', GetCtrlData(EditLineGroup)),
            SF('B_BrandGroup', GetCtrlData(EditBrand)),
            {$ENDIF}
            SF('B_Valid', nV),
            {$IFDEF BatCodeByLine}
            SF('B_Kw', EditKw.Text),
            {$ENDIF}
            SF('B_Batcode', EditBatcode.Text),
            SF('B_Type', GetCtrlData(EditType))
            ], sTable_Batcode, nStr, FRecordID = '');
  end;
  FDM.ExecuteSQL(nStr);

  {$IFDEF CSNF}
  if (FRecordID <> '') and (FOldBase <> EditBase.Text) then
  begin
    nP := EditPrefix.Text;
    nTmp := EditBase.Text;
    nInt := StrToIntDef(EditLen.Text,10);

    nInt := nInt - Length(nP + nTmp);
    if nInt > 0 then
         nBatCode := nP + StringOfChar('0', nInt) + nTmp
    else nBatCode := nP + nTmp;

    nStr := SF('R_ID', FRecordID, sfVal);

    nStr := MakeSQLByStr([
            SF('B_HasUse', 0, sfVal),
            SF('B_Batcode', nBatCode)
            ], sTable_Batcode, nStr, False);
    FDM.ExecuteSQL(nStr);
  end;
  {$ENDIF}

  ModalResult := mrOk;
  ShowMsg('批次保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormBatcode, TfFormBatcode.FormID);
end.
