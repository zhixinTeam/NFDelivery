{*******************************************************************************
  ×÷Õß: fendou116688@163.com 2017/4/8
  ÃèÊö: °õµ¥¿±Îó
*******************************************************************************}
unit UFormPoundVerify;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxButtonEdit, cxMemo,
  cxLabel;

type
  TfFormPoundVerify = class(TfFormNormal)
    EditPID: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditStockNO: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditLineGroup: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditMemo: TcxMemo;
    dxLayout1Item8: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item9: TdxLayoutItem;
    EditPValue: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    EditMValue: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FRecordID, FPoundTable: string;
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
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst, UAdjustForm;

class function TfFormPoundVerify.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormPoundVerify.Create(Application) do
  try
    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '°õµ¥ - ¿±Îó';
      FRecordID := nP.FParamA;
    end;

    if nP.FParamB = sFlag_TypeStation then
         FPoundTable := sTable_PoundStation
    else FPoundTable := sTable_PoundLog;

    LoadFormData(FRecordID);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    AdjustStringsItem(EditStockNO.Properties.Items, True);
    Free;
  end;
end;

class function TfFormPoundVerify.FormID: integer;
begin
  Result := cFI_FormPoundVerify;
end;

procedure TfFormPoundVerify.LoadFormData(const nID: string);
var nStr: string;
    nEx: TDynamicStrArray;
begin
  SetLength(nEx, 1);
  nStr := 'D_ParamB=Select D_ParamB,D_Value From %s Where D_Name=''%s'' ' +
          'And D_Index>=2 Order By D_Index DESC';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  nEx[0] := 'D_ParamB';
  FDM.FillStringsData(EditStockNO.Properties.Items, nStr, 0, '', nEx);
  AdjustCXComboBoxItem(EditStockNO, False);

  if nID <> '' then
  begin
    nStr := 'Select * From $Pound Where P_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$Pound', FPoundTable), MI('$ID', FRecordID)]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      SetCtrlData(EditStockNO, FieldByName('P_MID').AsString);

      EditLineGroup.Text := FieldByName('P_Order').AsString;
      EditTruck.Text     := FieldByName('P_Truck').AsString;

      EditPValue.Text := Format('%.2f', [FieldByName('P_PValue').AsFloat]);
      EditMValue.Text := Format('%.2f', [FieldByName('P_MValue').AsFloat]);
    end;
  end;
end;

//Desc: ±£´æ
procedure TfFormPoundVerify.BtnOKClick(Sender: TObject);
var nStr, nEvent: string;
begin
  nStr := MakeSQLByStr([SF('P_MID', GetCtrlData(EditStockNO)),
          SF('P_MName', EditStockNO.Text),
          SF('P_Order', EditLineGroup.Text),
          SF('P_Truck', EditTruck.Text)], FPoundTable, SF('P_ID', FRecordID), False);
  FDM.ExecuteSQL(nStr);

  nEvent := '°õµ¥±àºÅ[ %s ]ÒÑ¿±Îó';
  nEvent := Format(nEvent, [FRecordID]);
  FDM.WriteSysLog(sFlag_CommonItem, FRecordID, nEvent);


  ModalResult := mrOk;
  ShowMsg('°õµ¥¿±Îó³É¹¦', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormPoundVerify, TfFormPoundVerify.FormID);
end.
