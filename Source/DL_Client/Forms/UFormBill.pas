{*******************************************************************************
  作者: dmzn@163.com 2014-09-01
  描述: 开提货单
*******************************************************************************}
unit UFormBill;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, USysBusiness, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxMaskEdit,
  cxDropDownEdit, cxListView, cxTextEdit, cxMCListBox, dxLayoutControl,
  StdCtrls, cxButtonEdit, cxGraphics, cxCheckBox;

type
  TfFormBill = class(TfFormNormal)
    dxLayout1Item3: TdxLayoutItem;
    ListInfo: TcxMCListBox;
    EditTruck: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditLading: TcxComboBox;
    dxLayout1Item12: TdxLayoutItem;
    EditFQ: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Item6: TdxLayoutItem;
    EditType: TcxComboBox;
    dxLayout1Group3: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Item7: TdxLayoutItem;
    EditPack: TcxComboBox;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Group5: TdxLayoutGroup;
    EditBrand: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditLineGroup: TcxComboBox;
    dxLayout1Item10: TdxLayoutItem;
    EditMemo: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    dxLayout1Group6: TdxLayoutGroup;
    dxLayout1Group7: TdxLayoutGroup;
    EditPoundStation: TcxComboBox;
    dxLayout1Item13: TdxLayoutItem;
    dxLayout1Item14: TdxLayoutItem;
    PrintHY: TcxCheckBox;
    SnapTruck: TcxCheckBox;
    dxLayout1Item15: TdxLayoutItem;
    EditHisValueMax: TcxTextEdit;
    dxLayout1Item16: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
  protected
    { Protected declarations }
    FBuDanFlag: string;
    //补单标记
    FBills: string;
    //交货单号
    FOrder: TOrderItemInfo;
    //订单信息
    FListA,FListB: TStrings;
    //列表对象
    procedure LoadFormData(const nOrders: string);
    //载入数据
    function SetVipTruck(nTruck: String): Boolean;
    //VIP车道设置
    function GetStockPackStyle(const nStockID: string): string;
    //获取包装袋类型
    function VerifyTruckGPS(const nTruck: String=''): Boolean;
    //车辆是否安装GPS
    function GetGroupByBrand(const nBrand: string): string;
    //获取品牌分组
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, IniFiles, UMgrControl, UAdjustForm, UFormBase, UBusinessPacker,
  UDataModule, USysPopedom, USysDB, USysGrid, USysConst;

class function TfFormBill.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nStr: string;
    nBool: Boolean;
    nP: PFormCommandParam;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  if not Assigned(nParam) then
  begin
    nStr := '';
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else
  begin
    nP := nParam;
    nStr := nP.FParamA;
    //订单数据
  end;

  if nStr = '' then
  try
    nP.FParamC := sFlag_Sale;
    CreateBaseFormItem(cFI_FormGetOrder, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    nStr := nP.FParamB;
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormBill.Create(Application) do
  try
    Caption := '开交货单';
    nBool := not gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);
    EditLading.Properties.ReadOnly := nBool;

    if nPopedom = 'MAIN_D04' then //补单
         FBuDanFlag := sFlag_Yes
    else FBuDanFlag := sFlag_No;

    FBills := '';
    LoadFormData(nStr);
    //init ui

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;

      if FParamA = mrOK then
           FParamB := FBills
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBill.FormID: integer;
begin
  Result := cFI_FormMakeBill;
end;

procedure TfFormBill.FormCreate(Sender: TObject);
var nStr: string;
    nIni: TIniFile;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nStr := nIni.ReadString(Name, 'FQLabel', '');
    if nStr <> '' then
      dxLayout1Item5.Caption := nStr;
    //xxxxx

    PrintHY.Checked := nIni.ReadBool(Name, 'PrintHY', False);
    //随车开单
    LoadMCListBoxConfig(Name, ListInfo, nIni);
  finally
    nIni.Free;
  end;

  {$IFDEF PrintHYEach}
  dxLayout1Item14.Visible := True;
  {$ELSE}
  dxLayout1Item14.Visible := False;
  PrintHY.Checked := False;
  {$ENDIF}

  {$IFDEF RemoteSnap}
  dxLayout1Item15.Visible := True;
  {$ELSE}
  dxLayout1Item15.Visible := False;
  SnapTruck.Checked := False;
  {$ENDIF}

  {$IFDEF FixLoad}
  dxLayout1Item16.Visible := True;
  {$ELSE}
  dxLayout1Item16.Visible := False;
  {$ENDIF}

  {$IFDEF ManuSeal}
  EditFQ.Properties.ReadOnly := True;
  {$ENDIF}
  
  AdjustCtrlData(Self);
end;

procedure TfFormBill.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nIni.WriteBool(Name, 'PrintHY', PrintHY.Checked);
    SaveMCListBoxConfig(Name, ListInfo, nIni);
  finally
    nIni.Free;
  end;

  ReleaseCtrlData(Self);
  FListA.Free;
  FListB.Free;
end;

//Desc: 回车键
procedure TfFormBill.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditLading then
      ActiveControl := EditTruck else
    if Sender = EditTruck then
      ActiveControl := EditValue else
    if Sender = EditValue then
         ActiveControl := BtnOK
    else Perform(WM_NEXTDLGCTL, 0, 0);
  end;

  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
    begin
      EditTruck.Text := nP.FParamB;
      SetVipTruck(EditTruck.Text);
    end;

    EditTruck.SelectAll;
  end;

  {$IFDEF FixLoad}
  if (Sender = EditTruck) and (Key = Char(VK_Return)) then
  begin
    EditHisValueMax.Text := Format('%.2f', [GetTruckHisValueMax(EditTruck.Text)]);
  end;
  {$ENDIF}

  {$IFDEF ManuSeal}
  if (Sender = EditFQ) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := FOrder.FStockID;
    CreateBaseFormItem(cFI_FormGetBatCode, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
    begin
      EditFQ.Text := nP.FParamB;
    end;

    EditFQ.SelectAll;
  end;
  {$ENDIF}
end;

//------------------------------------------------------------------------------
//Desc: 载入界面数据
procedure TfFormBill.LoadFormData(const nOrders: string);
begin
  AnalyzeOrderInfo(nOrders, FOrder);
  LoadOrderInfo(FOrder, ListInfo);

  EditBrand.Text:=FOrder.FStockBrand;
  EditBrand.Properties.ReadOnly := EditBrand.Text<>'';

  {$IFDEF ORDERVALUE}
  EditValue.Text := Format('%.2f', [FOrder.FValue]);
  {$ENDIF}
  EditFQ.Text := FOrder.FBatchCode;
  //xxxxx

  EditTruck.Text := FOrder.FTruck;
  {$IFDEF FixLoad}
  EditHisValueMax.Text := Format('%.2f', [GetTruckHisValueMax(FOrder.FTruck)]);
  {$ENDIF}
  SetCtrlData(EditPack, GetStockPackStyle(FOrder.FStockID));
  if EditPack.ItemIndex < 0 then EditPack.ItemIndex := 0;
  //包装类型

  SetVipTruck(FOrder.FTruck);
  if LoadZTLineGroup(EditLineGroup.Properties.Items) then
    EditLineGroup.ItemIndex := 0;

  {$IFDEF GROUPBYBRAND}
  SetCtrlData(EditLineGroup, GetGroupByBrand(FOrder.FStockBrand));
  {$ENDIF}

  LoadPoundStation(EditPoundStation.Properties.Items);
  ActiveControl := EditTruck;
end;

function TfFormBill.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nStr: string;
    nVal: Double;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    Result := Length(EditTruck.Text) > 2;

    nHint := '车牌号长度应大于2位';
    if not Result then Exit;

    nStr := 'Select L_ID From %s ' +
            'Where L_OutFact Is Null And L_Truck=''%s''';
    nStr := Format(nStr, [sTable_Bill, EditTruck.Text]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      nStr := '';
      First;

      while not Eof do
      begin
        nStr := Fields[0].AsString;
        Next;
        
        if not Eof then
          nStr := nStr + ',';
        //xxxxx
      end;

      nHint := '车辆[ %s ]已开交货单[ %s ],是否继续开新单?';
      Result := QueryDlg(Format(nHint, [EditTruck.Text, nStr]), sAsk);
      nHint := '';
    end;
  end else

  if Sender = EditLading then
  begin
    Result := EditLading.ItemIndex > -1;
    nHint := '请选择有效的提货方式';
  end else

  if Sender = EditPack then
  begin
    Result := EditPack.Text <> '';
    nHint := '请选择有效的包装类型';
  end;

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    {$IFDEF ValueLimit}
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0)
              and (StrToFloat(EditValue.Text) <= 200);
    {$ENDIF}
    nHint := '请填写有效的办理量';
    if not Result then Exit;

    nVal := StrToFloat(EditValue.Text);
    Result := FloatRelation(nVal, FOrder.FValue, rtLE);
    nHint := '已超过可提货量';
  end;
end;

//Desc: 保存
procedure TfFormBill.BtnOKClick(Sender: TObject);
var nPrint: Boolean;
    nStr, nCard: string;
begin
  if not IsDataValid then Exit;
  //check valid

  {$IFDEF FixLoad}
  {$IFNDEF FixLoadNoControlValue}
  if Trim(EditHisValueMax.Text) = '' then
    EditHisValueMax.Text := Format('%.2f', [GetTruckHisValueMax(EditTruck.Text)]);
  if Pos('散', FOrder.FStockName) > 0 then
  begin
    if (StrToFloat(EditHisValueMax.Text)>0) then
    begin
      if StrToFloat(EditValue.Text)> StrToFloat(EditHisValueMax.Text) then
      begin
        ShowMsg('提货量超出历史最大提货量', sHint);
        Exit;
      end;
    end
    else
    begin
      nStr := '车辆[ %s ]未获取到历史最大提货量,当前开单量[ %s ],是否继续?';
      nStr := Format(nStr, [EditTruck.Text, EditValue.Text]);
      if not QueryDlg(nStr, sAsk) then Exit;
    end;
  end;
  {$ENDIF}
  {$ENDIF}

  {$IFDEF ManuSeal}
  if Trim(EditFQ.Text) = '' then
  begin
    ShowMsg('请选择批次号', sHint);
    Exit
  end;
  {$ENDIF}

  if not VerifyTruckGPS then
  begin
    ModalResult := mrCancel;
    Exit;
  end;
  //Query Truck GPS

  nPrint := False;
  {$IFDEF PrintShipReport}
  nPrint := GetCtrlData(EditType) = sFlag_TypeShip;
  {$ENDIF}

  if not nPrint then
  begin
    LoadSysDictItem(sFlag_PrintBill, FListB);
    //需打印品种
    nPrint := FListB.IndexOf(FOrder.FStockID) >= 0;
  end;

  with FListA do
  begin
    Clear;
    Values['Orders'] := PackerEncodeStr(FOrder.FOrders);
    Values['Value'] := EditValue.Text;
    Values['Truck'] := EditTruck.Text;
    Values['Lading'] := GetCtrlData(EditLading);
    Values['IsVIP'] := GetCtrlData(EditType);
    Values['Pack'] := GetCtrlData(EditPack);
    Values['BuDan'] := FBuDanFlag;
    Values['Seal'] := EditFQ.Text;
    Values['Brand'] := EditBrand.Text;
    Values['StockArea'] := FOrder.FStockArea;

    Values['CusID'] := FOrder.FCusID;
    Values['CusName'] := FOrder.FCusName;
    {$IFDEF ForceLineGroup}
    Values['LineGroup'] := gSysParam.FFactNum;
    {$ELSE}
    Values['LineGroup'] := GetCtrlData(EditLineGroup);
    {$ENDIF}
    Values['Memo']     := Trim(EditMemo.Text);

    Values['PoundStation'] := GetCtrlData(EditPoundStation);
    Values['PoundName']    := EditPoundStation.Text;

    Values['bm'] := FOrder.FBm;
    Values['SpecialCus'] := FOrder.FSpecialCus;

    if PrintHY.Checked  then
         Values['PrintHY'] := sFlag_Yes
    else Values['PrintHY'] := sFlag_No;

    if SnapTruck.Checked  then
         Values['SnapTruck'] := sFlag_Yes
    else Values['SnapTruck'] := sFlag_No;
  end;

  FBills := SaveBill(PackerEncodeStr(FListA.Text));
  //call mit bus
  if FBills = '' then Exit;

  VipTruckForceLine(GetCtrlData(EditType), FOrder.FStockID, FBills);

  if FBuDanFlag <> sFlag_Yes then
  begin
    if HasDriverCard(EditTruck.Text, nCard) then
      SaveBillCard(FBills, nCard)
    else
      SetBillCard(FBills, EditTruck.Text, True);
    //办理磁卡
  end;

  if nPrint then
    PrintBillReport(FBills, True);
  //print report

  ModalResult := mrOk;
  ShowMsg('提货单保存成功', sHint);
end;


function TfFormBill.SetVipTruck(nTruck: String): Boolean;
var nStr, nVip: string;
begin
  nStr := 'Select T_VIPTruck From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, Trim(nTruck)]);

  nVip := '';
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nVip := Fields[0].AsString;

    if nVip <> '' then
      SetCtrlData(EditType, nVip);
  end;

  Result := nVip = sFlag_TypeVIP;
end;

function TfFormBill.GetStockPackStyle(const nStockID: string): string;
var nStr: string;
begin
  nStr := 'Select D_ParamC From %s Where (D_Name=''StockItem''' +
          ' and D_ParamB=''%s'')';
  nStr := Format(nStr, [sTable_SysDict, Trim(nStockID)]);

  Result := '';
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
     Result := Fields[0].AsString;

  if Result = '' then Result := 'C';
end;

function TfFormBill.VerifyTruckGPS(const nTruck: String=''): Boolean;
var nStr, nTmp: string;
    nUseGPS: Boolean;
begin
  Result := False;

  nUseGPS := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, 'UseGPS']);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nUseGPS := Fields[0].AsString=sFlag_Yes;
  end;

  if not nUseGPS then
  begin
    Result := True;
    Exit;
  end;

  if nTruck <> '' then
       nTmp := Trim(nTruck)
  else nTmp := Trim(EditTruck.Text);
  //xxxxx

  nStr := 'Select T_HasGPS From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTmp]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString=sFlag_Yes;
  end;

  if not Result then
  begin
    nStr := '车辆[ %s ]未安装GPS,是否继续开单';
    nStr := Format(nStr, [nTmp]);
    //xxxxx

    Result := QueryDlg(nStr, sWarn);
  end;
end;

function TfFormBill.GetGroupByBrand(const nBrand: string): string;
var nStr: string;
begin
  nStr := 'Select D_Value From %s Where (D_Name=''ZTLineGroup''' +
          ' and D_Memo=''%s'')';
  nStr := Format(nStr, [sTable_SysDict, Trim(nBrand)]);

  Result := '';
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
     Result := Fields[0].AsString;
end;

initialization
  gControlManager.RegCtrl(TfFormBill, TfFormBill.FormID);
end.
