{*******************************************************************************
  作者: fendou116688@163.com 2015-05-13
  描述: 批次档案管理
*******************************************************************************}
unit UFormBatcodeEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxCheckBox, cxTextEdit,
  dxLayoutControl, StdCtrls, cxMaskEdit, cxDropDownEdit;

type
  TfFormBatcodeEdit = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditBatch: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditRund: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    EditStock: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Item6: TdxLayoutItem;
    EditInit: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditPlan: TcxTextEdit;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Item8: TdxLayoutItem;
    EditWarn: TcxTextEdit;
    dxLayout1Group4: TdxLayoutGroup;
    Check1: TcxCheckBox;
    dxLayout1Item10: TdxLayoutItem;
    EditBrand: TcxComboBox;
    dxLayout1Item11: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditStockPropertiesEditValueChanged(Sender: TObject);
  protected
    { Protected declarations }
    FRecordID: string;
    //记录编号
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
  ULibFun, UMgrControl, UDataModule, UAdjustForm, UFormCtrl, USysDB, USysConst;

class function TfFormBatcodeEdit.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormBatcodeEdit.Create(Application) do
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

class function TfFormBatcodeEdit.FormID: integer;
begin
  Result := cFI_FormBatchEdit;
end;

procedure TfFormBatcodeEdit.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ReleaseCtrlData(Self);
end;

procedure TfFormBatcodeEdit.LoadFormData(const nID: string);
var nStr: string;
begin
  nStr := 'D_ParamB=Select D_ParamB,D_Value From %s Where D_Name=''%s'' ' +
          'And D_Index>=0 Order By D_Index DESC';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  FDM.FillStringsData(EditStock.Properties.Items, nStr, 0, '.');
  AdjustCXComboBoxItem(EditStock, False);

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_BatcodeDoc, nID]);
    FDM.QueryTemp(nStr);

    with FDM.SqlTemp do
    begin
      nStr := FieldByName('D_Stock').AsString;
      SetCtrlData(EditStock, nStr);

      EditName.Text := FieldByName('D_Name').AsString;
      EditBatch.Text := FieldByName('D_ID').AsString;
      EditBatch.Properties.ReadOnly := True;
      EditBrand.Text := FieldByName('D_Brand').AsString;

      EditPlan.Text := Format('%.2f', [FieldByName('D_Plan').AsFloat]);
      EditInit.Text := Format('%.2f', [FieldByName('D_Init').AsFloat]);
      EditWarn.Text := Format('%.2f', [FieldByName('D_Warn').AsFloat]);
      EditRund.Text := Format('%.2f', [FieldByName('D_Rund').AsFloat]);
      Check1.Checked := FieldByName('D_Valid').AsString = sFlag_Yes;
    end;
  end;
end;

function TfFormBatcodeEdit.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditBatch then
  begin
    Result := EditBatch.Text <> '';
    nHint := '请输入批次号';
  end else

  if Sender = EditStock then
  begin
    Result := EditStock.ItemIndex >= 0;
    nHint := '请选择品种';
  end else

  if Sender = EditPlan then
  begin
    Result := IsNumber(EditPlan.Text, True);
    nHint := '请输入总量';
  end else

  if Sender = EditInit then
  begin
    Result := IsNumber(EditInit.Text, True);
    nHint := '请输入初始量';
  end else

  if Sender = EditRund then
  begin
    Result := IsNumber(EditRund.Text, True);
    nHint := '请输入退货量';
  end else

  if Sender = EditWarn then
  begin
    Result := IsNumber(EditWarn.Text, True);
    nHint := '请输预警量';
  end;
end;

//Desc: 保存
procedure TfFormBatcodeEdit.BtnOKClick(Sender: TObject);
var nStr,nU,nTime: string;
begin
  if not IsDataValid then Exit;
  //验证不通过

  if Check1.Checked then
  begin
    nU := sFlag_BatchInUse;
    nTime := SF('D_UseDate', sField_SQLServer_Now, sfVal);
  end else
  begin
    nU := sFlag_BatchOutUse;
    nTime := SF('D_LastDate', sField_SQLServer_Now, sfVal)
  end;

  if FRecordID = '' then
  begin
    nStr := 'Select D_ID from %s where D_ID=''%s'' and D_Valid<>''%s''';
    nStr := Format(nStr , [sTable_BatcodeDoc,
            Trim(EditBatch.Text), sFlag_BatchDel]);
    //xxxxx

    with FDM.QuerySQL(nStr) do
      if RecordCount > 0 then
      begin
        nStr := '批次号[%s]已存在';
        nStr := Format(nStr , [Trim(EditBatch.Text)]);

        ShowMsg(nStr, sHint);
        Exit;
      end;
  end;
  //判断批次号是否重复
  if FRecordID = '' then
       nStr := ''
  else nStr := SF('R_ID', FRecordID, sfVal);

  nStr := MakeSQLByStr([SF('D_ID', Trim(EditBatch.Text)),
          SF('D_Stock', GetCtrlData(EditStock)),
          SF('D_Name', EditName.Text),
          SF('D_Brand', EditBrand.Text),

          SF('D_Plan', EditPlan.Text, sfVal),
          SF('D_Init', EditInit.Text, sfVal),
          SF('D_Warn', EditWarn.Text, sfVal),
          SF('D_Rund', EditRund.Text, sfVal),

          SF('D_Valid', nU),
          nTime                     //时间
          ], sTable_BatcodeDoc, nStr, FRecordID = '');
  FDM.ExecuteSQL(nStr);

  if FRecordID = '' then
  begin
    nStr := SF('D_ID', EditBatch.Text);
    nStr := MakeSQLByStr([SF('D_Man', gSysParam.FUserID),
            SF('D_Date', sField_SQLServer_Now, sfVal)
            ], sTable_BatcodeDoc, nStr, False);
    FDM.ExecuteSQL(nStr);
  end;
  
  ModalResult := mrOk;
  ShowMsg('批次保存成功', sHint);
end;

procedure TfFormBatcodeEdit.EditStockPropertiesEditValueChanged(
  Sender: TObject);
var nPos: Integer;
    nStr: string;
begin
  inherited;

  nStr := Trim(EditStock.Text);
  nPos := Pos('.', nStr);
  Delete(nStr, 1, nPos);

  EditName.Text := nStr;
end;

initialization
  gControlManager.RegCtrl(TfFormBatcodeEdit, TfFormBatcodeEdit.FormID);
end.
