{*******************************************************************************
  作者: dmzn@163.com 2017-09-15
  描述: 船运采购离岸磅单
*******************************************************************************}
unit UFormShipProvide;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, USysBusiness, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxButtonEdit,
  cxLabel, cxMaskEdit, cxDropDownEdit, cxTextEdit, dxLayoutControl,
  StdCtrls;

type
  TfFormShipProvide = class(TfFormNormal)
    EditBill: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditStock: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
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
    dxLayout1Group9: TdxLayoutGroup;
    EditShip: TcxTextEdit;
    dxLayout1Item22: TdxLayoutItem;
    dxLayout1Group10: TdxLayoutGroup;
    dxLayout1Group11: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item23: TdxLayoutItem;
    dxLayout1Group12: TdxLayoutGroup;
    EditCusName: TcxButtonEdit;
    dxLayout1Item24: TdxLayoutItem;
    dxLayout1Item21: TdxLayoutItem;
    EditDuiChang: TcxComboBox;
    procedure BtnOKClick(Sender: TObject);
    procedure EditCusNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  protected
    { Protected declarations }
    FBill: string;
    //提货单号
    FShip: string;
    //船运单记录
    FOrderItem: TOrderItemInfo;
    //订单信息
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

const
  cYuShuFile = 'YunShu.dat';
  //运输单位
  cDuiChangeFile = 'DuiChang.dat';
  //堆场数据
  
class function TfFormShipProvide.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else nP := nil;
  
  with TfFormShipProvide.Create(Application) do
  try
    Caption := '船运 - 采购单';
    if Assigned(nP) then
         FBill := nP.FParamA
    else FBill := '';

    LoadFormData(FBill);
    //init ui

    if Assigned(nP) then
    begin
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
    end else
    begin
      ShowModal;
    end;
  finally
    Free;
  end;
end;

class function TfFormShipProvide.FormID: integer;
begin
  Result := cFI_FormShipPoundCG;
end;

procedure TfFormShipProvide.LoadFormData(const nID: string);
var nStr: string;
begin
  BtnOK.Enabled := False;
  ActiveControl := EditCusName;

  if FileExists(gPath + cYuShuFile) then
    EditYuShu.Properties.Items.LoadFromFile(gPath + cYuShuFile);
  //xxxxx

  if FileExists(gPath + cDuiChangeFile) then
    EditDuiChang.Properties.Items.LoadFromFile(gPath + cDuiChangeFile);
  if nID = '' then Exit;

  nStr := 'Select ps.*,P_Order,P_CusName,P_Truck,P_MName,P_MStation From %s ps ' +
          '  Left Join %s pl On pl.P_ID=ps.S_Bill ' +
          'Where S_Bill=''%s''';
  nStr := Format(nStr, [sTable_PoundShip, sTable_PoundLog, nID]);

  with FDM.QueryTemp(nStr) do
  begin
    BtnOK.Enabled := RecordCount > 0;
    if not BtnOK.Enabled then
    begin
      ShowMsg('单据已不丢失', sHint);
      Exit;
    end;

    if FieldByName('P_MStation').AsString <> sFlag_TypeShip then
    begin
      ShowMsg('不是有效船运单据', sHint);
      Exit;
    end;

    EditCusName.Text := FieldByName('P_CusName').AsString;
    EditBill.Text    := FieldByName('P_Order').AsString;
    EditYuShu.Text   := FieldByName('S_YunShu').AsString;
    EditShip.Text    := FieldByName('P_Truck').AsString;
    EditStock.Text   := FieldByName('P_MName').AsString;
    EditValue.Text   := FieldByName('S_Value').AsString;

    EditDuiChang.Text := Trim(FieldByName('S_PiCi').AsString);
    EditFengQian.Text := FieldByName('S_FengQian').AsString; 
    EditMemo.Text := Trim(FieldByName('S_Memo').AsString);

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
    EditCusName.Enabled := False;
    //no change order when modify
  end;
end;

//Desc: 载入订单
procedure TfFormShipProvide.EditCusNamePropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var nStr,nFilter,nCusID: string;
    nP: TFormCommandParam;
begin
  EditCusName.Text := Trim(EditCusName.Text);
  if EditCusName.Text = '' then
  begin
    ShowMsg('请输入供货单位', sHint);
    Exit;
  end;

  nP.FParamA := EditCusName.Text;
  CreateBaseFormItem(cFI_FormGetCustom, '', @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
  nCusID := nP.FParamB;

  nP.FParamA := nCusID;
  CreateBaseFormItem(cFI_FormGetMine, '', @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) and
     (nP.FParamB <> '') then nFilter := nP.FParamB;
  //选择矿点

  nP.FParamA := nCusID;
  nP.FParamB := '';
  nP.FParamC := sFlag_Provide;
  if nFilter <> '' then nP.FParamD := nFilter;

  CreateBaseFormItem(cFI_FormGetOrder, '', @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
  
  nStr := nP.FParamB;
  AnalyzeOrderInfo(nStr, FOrderItem);

  with FOrderItem do
  begin
    EditBill.Text := Trim(FOrders);
    EditCusName.Text := FCusName;
    EditStock.Text := FStockName;
  end;

  BtnOK.Enabled := True;
  ShowMsg('订单读取成功', sHint);
end;

procedure TfFormShipProvide.BtnOKClick(Sender: TObject);
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
  EditDuiChang.Text := Trim(EditDuiChang.Text);

  FDM.ADOConn.BeginTrans;
  try
    if FBill = '' then
      FBill := GetSerialNo(sFlag_BusGroup, sFlag_PoundID);
    //pound id

    nStr := MakeSQLByStr([SF('S_Bill', FBill),
            SF('S_YunShu', EditYuShu.Text),
            SF('S_Value', EditValue.Text, sfVal),
            SF('S_PiCi', EditDuiChang.Text),
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
            SF('S_Date', sField_SQLServer_Now, sfVal),
            SF('S_LeaveMan', gSysParam.FUserID),
            SF('S_LeaveDate', sField_SQLServer_Now, sfVal)
            ], sTable_PoundShip, nStr, nStr = '');
    FDM.ExecuteSQL(nStr);

    if FShip = '' then
    begin
      nStr := MakeSQLByStr([SF('P_ID', FBill),
              SF('P_Type', sFlag_ShipPro),
              SF('P_Order', EditBill.Text),
              SF('P_Truck', EditShip.Text),
              SF('P_CusID', FOrderItem.FCusID),
              SF('P_CusName', FOrderItem.FCusName),
              SF('P_MID', FOrderItem.FStockID),
              SF('P_MName', FOrderItem.FStockName),
              SF('P_MType', sFlag_San),
              SF('P_LimValue', FOrderItem.FValue),

              SF('P_FactID', gSysParam.FFactNum),
              SF('P_PStation', sFlag_TypeShip),
              SF('P_MStation', sFlag_TypeShip),
              SF('P_Direction', '进厂'),
              SF('P_PModel', sFlag_PoundPZ),
              SF('P_Status', sFlag_TruckBFM),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', '0', sfVal),

              SF('P_PValue', '0', sfVal),
              SF('P_PMan', gSysParam.FUserID),
              SF('P_PDate', sField_SQLServer_Now, sfVal),

              SF('P_MValue', EditValue.Text, sfVal),
              SF('P_MMan', gSysParam.FUserID),
              SF('P_MDate', sField_SQLServer_Now, sfVal)
              ], sTable_PoundLog, '', True);
      FDM.ExecuteSQL(nStr);
    end else
    begin
      nStr := MakeSQLByStr([
              SF('P_Truck', EditShip.Text),
              SF('P_MValue', EditValue.Text, sfVal),
              SF('P_MMan', gSysParam.FUserID),
              SF('P_MDate', sField_SQLServer_Now, sfVal)
              ], sTable_PoundLog, SF('P_ID', FBill), False);
      FDM.ExecuteSQL(nStr);
    end;

    FDM.ADOConn.CommitTrans;
    //save done
  except
    on nErr:Exception do
    begin
      FDM.ADOConn.RollbackTrans;
      ShowDlg(nErr.Message, sWarn);
      Exit;
    end;
  end;

  with EditYuShu.Properties do
  if (EditYuShu.Text <> '') and (Items.IndexOf(EditYuShu.Text) < 0) then
  begin
    Items.Add(EditYuShu.Text);
    Items.SaveToFile(gPath + cYuShuFile);
  end;

  with EditDuiChang.Properties do
  if (EditDuiChang.Text <> '') and (Items.IndexOf(EditDuiChang.Text) < 0) then
  begin
    Items.Add(EditDuiChang.Text);
    Items.SaveToFile(gPath + cDuiChangeFile);
  end;

  PrintShipLeaveCGReport(FBill, False);
  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormShipProvide, TfFormShipProvide.FormID);
end.
