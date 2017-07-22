{*******************************************************************************
  作者: dmzn@163.com 2017-07-19
  描述: 船运离岸磅单
*******************************************************************************}
unit UFormShipPound;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxLabel;

type
  TfFormShipPound = class(TfFormNormal)
    EditCusName: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditStock: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditPici: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditYuShu: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditFengQian: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditMemo: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item8: TdxLayoutItem;
    EditKW: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    EditKZ: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditKT: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Item13: TdxLayoutItem;
    cxLabel2: TcxLabel;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Item14: TdxLayoutItem;
    EditZLW: TcxTextEdit;
    dxLayout1Item15: TdxLayoutItem;
    EditZLZ: TcxTextEdit;
    dxLayout1Item16: TdxLayoutItem;
    EditZLT: TcxTextEdit;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Item17: TdxLayoutItem;
    EditZRT: TcxTextEdit;
    dxLayout1Item18: TdxLayoutItem;
    EditZRZ: TcxTextEdit;
    dxLayout1Item19: TdxLayoutItem;
    EditZRW: TcxTextEdit;
    dxLayout1Group6: TdxLayoutGroup;
    dxLayout1Group7: TdxLayoutGroup;
    dxLayout1Item20: TdxLayoutItem;
    cxLabel3: TcxLabel;
    dxLayout1Group8: TdxLayoutGroup;
    EditBill: TcxTextEdit;
    dxLayout1Item21: TdxLayoutItem;
    dxLayout1Group9: TdxLayoutGroup;
    EditShip: TcxTextEdit;
    dxLayout1Item22: TdxLayoutItem;
    dxLayout1Group10: TdxLayoutGroup;
    dxLayout1Group11: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item23: TdxLayoutItem;
    dxLayout1Group12: TdxLayoutGroup;
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FBill: string;
    //提货单号
    FShip: string;
    //船运单记录
    FPlanValue: Double;
    //计划量
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
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst,
  USysBusiness;

const
  cYuShuFile = 'YunShu.dat';
  //运输单位
  
class function TfFormShipPound.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormShipPound.Create(Application) do
  try
    Caption := '船运 - 发货单';
    FBill := nP.FParamA;

    LoadFormData(FBill);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormShipPound.FormID: integer;
begin
  Result := cFI_FormShipPound;
end;

procedure TfFormShipPound.LoadFormData(const nID: string);
var nStr: string;
begin
  if FileExists(gPath + cYuShuFile) then
    EditYuShu.Properties.Items.LoadFromFile(gPath + cYuShuFile);
  //xxxxx

  nStr := 'Select L_ID,L_CusName,L_StockName,L_Truck,L_Value,L_Seal,' +
          'L_Memo,L_IsVIP,s.* From %s b ' +
          ' Left Join %s s on s.S_Bill=b.L_ID ' +
          'Where b.L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, sTable_PoundShip, nID]);

  with FDM.QueryTemp(nStr) do
  begin
    BtnOK.Enabled := RecordCount > 0;
    if not BtnOK.Enabled then
    begin
      ShowMsg('单据已不丢失', sHint);
      Exit;
    end;

    if FieldByName('L_IsVIP').AsString <> sFlag_TypeShip then
    begin
      ShowMsg('不是有效船运单据', sHint);
      Exit;
    end;

    EditCusName.Text := FieldByName('L_CusName').AsString;
    EditBill.Text    := FieldByName('L_ID').AsString;
    EditYuShu.Text   := FieldByName('S_YunShu').AsString;
    EditShip.Text    := FieldByName('L_Truck').AsString;
    EditStock.Text   := FieldByName('L_StockName').AsString;
    EditValue.Text   := FieldByName('S_Value').AsString;

    EditPici.Text := Trim(FieldByName('S_PiCi').AsString);
    if EditPici.Text = '' then
      EditPici.Text := FieldByName('L_Seal').AsString;
    EditFengQian.Text := FieldByName('S_FengQian').AsString;

    EditMemo.Text := Trim(FieldByName('S_Memo').AsString);
    if EditMemo.Text = '' then
      EditMemo.Text := FieldByName('L_Memo').AsString;
    //xxxxx

    FPlanValue := FieldByName('S_Plan').AsFloat;
    if FPlanValue < 0.01 then
      FPlanValue := FieldByName('L_Value').AsFloat;
    //xxxxx

    EditKW.Text := FieldByName('S_KW').AsString;
    EditKZ.Text := FieldByName('S_KZ').AsString;
    EditKT.Text := FieldByName('S_KT').AsString;

    EditZLW.Text := FieldByName('S_ZLW').AsString;
    EditZLZ.Text := FieldByName('S_ZLZ').AsString;
    EditZLT.Text := FieldByName('S_ZLT').AsString;
    EditZRW.Text := FieldByName('S_ZRW').AsString;
    EditZRZ.Text := FieldByName('S_ZRZ').AsString;
    EditZRT.Text := FieldByName('S_ZRT').AsString;

    FShip := FieldByName('R_ID').AsString;
  end;
end;


procedure TfFormShipPound.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  if not IsNumber(EditValue.Text, True) then
  begin
    EditValue.SetFocus;
    ShowMsg('请输入有效净重', sHint);
    Exit;
  end;

  if FShip <> '' then
       nStr := SF('R_ID', FShip, sfVal)
  else nStr := '';

  EditYuShu.Text := Trim(EditYuShu.Text);
  //adjust

  nStr := MakeSQLByStr([SF('S_Bill', FBill),
          SF('S_YunShu', EditYuShu.Text),
          SF('S_Value', EditValue.Text, sfVal),
          SF('S_Plan', FPlanValue, sfVal),
          SF('S_PiCi', EditPici.Text),
          SF('S_FengQian', EditFengQian.Text),
          SF('S_Memo', EditMemo.Text),

          SF('S_KW', EditKW.Text),
          SF('S_KZ', EditKZ.Text),
          SF('S_KT', EditKT.Text),

          SF('S_ZLW', EditZLW.Text),
          SF('S_ZLZ', EditZLZ.Text),
          SF('S_ZLT', EditZLT.Text),
          SF('S_ZRW', EditZRW.Text),
          SF('S_ZRZ', EditZRZ.Text),
          SF('S_ZRT', EditZRT.Text),

          SF('S_Man', gSysParam.FUserID),
          SF('S_Date', sField_SQLServer_Now, sfVal)
          ], sTable_PoundShip, nStr, nStr = '');
  FDM.ExecuteSQL(nStr);

  nStr := 'Update %s Set L_Value=%s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, EditValue.Text, FBill]);
  FDM.ExecuteSQL(nStr);

  with EditYuShu.Properties do
  if (EditYuShu.Text <> '') and (Items.IndexOf(EditYuShu.Text) < 0) then
  begin
    Items.Add(EditYuShu.Text);
    Items.SaveToFile(gPath + cYuShuFile);
  end;

  PrintBillReport(FBill, False);
  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormShipPound, TfFormShipPound.FormID);
end.
