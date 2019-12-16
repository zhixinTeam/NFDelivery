{*******************************************************************************
  作者: juner11212436@163.com 2019-04-16
  描述: 销售量控制
*******************************************************************************}
unit UFormTruckType;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxSpinEdit, cxTimeEdit;

type
  TfFormTruckType = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    ChkUseControl: TcxCheckBox;
    dxLayout1Item3: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditType: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FTruckID: string;
    procedure LoadFormData(const nID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst;

type
  TCusItem = record
    FID   : string;
    FName : string;
  end;

var
  gCusItems: array of TCusItem;
  gStockItems: array of TCusItem;
  //客户列表

class function TfFormTruckType.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormTruckType.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '车辆类型控制 - 添加';
      FTruckID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '车辆类型控制 - 修改';
      FTruckID := nP.FParamA;
    end;

    LoadFormData(FTruckID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormTruckType.FormID: integer;
begin
  Result := cFI_FormTruckType;
end;

procedure TfFormTruckType.LoadFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select * From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_TTControl]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      if FieldByName('D_Value').AsString = sFlag_Yes then
        ChkUseControl.Checked := True;
    end;
  end;

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where D_ID=%s';
    nStr := Format(nStr, [sTable_SysDict, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      Exit;
    end;

    EditType.Text := FieldByName('D_Value').AsString;
    EditValue.Text := FieldByName('D_ParamA').AsString;
  end;
end;

//Desc: 保存
procedure TfFormTruckType.BtnOKClick(Sender: TObject);
var nStr,nCID,nV,nVTotal: string;
begin
  if not IsNumber(EditValue.Text, True) then
  begin
    ActiveControl := EditValue;
    ShowMsg('限载量非法,请重新输入', sHint);
    Exit;
  end;

  if ChkUseControl.Checked then
       nVTotal := sFlag_Yes
  else nVTotal := sFlag_No;

  nStr := SF('D_Name', sFlag_TTControl);
  nStr := MakeSQLByStr([
          SF('D_Value', nVTotal)
          ], sTable_SysDict, nStr, False);

  if FDM.ExecuteSQL(nStr) <= 0 then
  begin
    nStr := MakeSQLByStr([
        SF('D_Name', sFlag_TTControl),
        SF('D_Value', nVTotal)
        ], sTable_SysDict, '', True);
    FDM.ExecuteSQL(nStr);
  end;

  if FTruckID = '' then
       nStr := ''
  else nStr := SF('D_ID', FTruckID, sfVal);

  nStr := MakeSQLByStr([
          SF('D_Name', sFlag_TruckType),
          SF('D_ParamA', EditValue.Text),
          SF('D_Value', EditType.Text)
          ], sTable_SysDict, nStr, FTruckID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('控制信息保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormTruckType, TfFormTruckType.FormID);
end.
