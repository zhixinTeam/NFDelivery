{*******************************************************************************
  作者: fendou116688@163.com 2017/6/2
  描述: 采购业务办卡(复磅模式)
*******************************************************************************}
unit UFormCardProvide;

{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  CPort, CPortTypes, UFormNormal, UFormBase, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls, cxGraphics, cxCheckBox, cxMaskEdit,
  cxButtonEdit, USysBusiness, cxDropDownEdit;

type
  TfFormCardProvide = class(TfFormNormal)
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item5: TdxLayoutItem;
    EditCard: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    ComPort1: TComPort;
    dxLayout1Group2: TdxLayoutGroup;
    EditCardType: TcxCheckBox;
    dxLayout1Item9: TdxLayoutItem;
    EditBack: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    EditMuilti: TcxCheckBox;
    dxLayout1Item8: TdxLayoutItem;
    EditPName: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditMName: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditOrder: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    EditOValue: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    EditMemo: TcxTextEdit;
    dxLayout1Item14: TdxLayoutItem;
    EditArea: TcxTextEdit;
    dxLayout1Item15: TdxLayoutItem;
    EditPre: TcxCheckBox;
    dxLayout1Item16: TdxLayoutItem;
    EditPoundStation: TcxComboBox;
    dxLayout1Item17: TdxLayoutItem;
    SnapTruck: TcxCheckBox;
    dxLayout1Item18: TdxLayoutItem;
    EditShip: TcxTextEdit;
    dxLayout1Item19: TdxLayoutItem;
    CheckELabel: TcxCheckBox;
    dxLayout1Item20: TdxLayoutItem;
    EditYLineName: TcxComboBox;
    dxLayout1Item21: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditCardKeyPress(Sender: TObject; var Key: Char);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure CheckELabelPropertiesChange(Sender: TObject);
  private
    { Private declarations }
    FBuffer: string;
    //接收缓冲
    FListA,FListB: TStrings;
    //列表对象
    FOrderItem: TOrderItemInfo;
    //订单信息
    procedure InitFormData(const nOrderData: string = '');
    procedure ActionComPort(const nStop: Boolean);
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
  IniFiles, ULibFun, UMgrControl, USmallFunc, USysConst, USysDB,
  UBusinessPacker, UAdjustForm, UDataModule;

type
  TReaderType = (ptT800, pt8142);
  //表头类型

  TReaderItem = record
    FType: TReaderType;
    FPort: string;
    FBaud: string;
    FDataBit: Integer;
    FStopBit: Integer;
    FCheckMode: Integer;
  end;

var
  gReaderItem: TReaderItem;
  //全局使用

class function TfFormCardProvide.FormID: integer;
begin
  Result := cFI_FormCardProvide;
end;

class function TfFormCardProvide.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nStr, nFilter, nCusID: string;
    nP: PFormCommandParam;
begin
  Result := nil;

  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else
  begin
    nP := nParam;
    nStr := nP.FParamA;
  end;

  if nStr = '' then
  try
    CreateBaseFormItem(cFI_FormGetCustom, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    nCusID := nP.FParamB;

    nFilter    := '';
    nP.FParamA := nCusID;
    CreateBaseFormItem(cFI_FormGetMine, '', nP);
    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK)
      and (nP.FParamB<>'') then nFilter:=nP.FParamB;
    //选择矿点

    nP.FParamA := nCusID;
    nP.FParamB := '';
    nP.FParamC := sFlag_Provide;
    if nFilter<>'' then nP.FParamD:=nFilter;

    CreateBaseFormItem(cFI_FormGetOrder, '', nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    nStr := nP.FParamB;
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormCardProvide.Create(Application) do
  try
    FListA := TStringList.Create;
    FListB := TStringList.Create;
    InitFormData(nStr);
    ActionComPort(False);

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;
    end else ShowModal;
  finally
    Free;
  end;
end;

procedure TfFormCardProvide.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ActionComPort(True);
  FListA.Free;
  FListB.Free;
end;

procedure TfFormCardProvide.InitFormData;
var nStr: string;
begin
  if nOrderData = '' then Exit;
  //无订单数据

  AnalyzeOrderInfo(nOrderData, FOrderItem);
  with FOrderItem do
  begin
    EditPName.Text := FCusName;
    EditMName.Text := FStockName;
    EditArea.Text  := FStockArea;

    EditOrder.Text := FOrders;
    EditOValue.Text:= FloatToStr(FValue);
  end;

  EditYLineName.Properties.Items.Clear;
  nStr := 'Select D_Value From %s where D_Name =''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_UnLodingPlace]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      try
        EditYLineName.Properties.BeginUpdate;

        First;

        while not Eof do
        begin
          if Fields[0].AsString = '' then
          begin
            Next;
            Continue;
          end;
          EditYLineName.Properties.Items.Add(Fields[0].AsString);
          Next;
        end;
      finally
        EditYLineName.Properties.EndUpdate;
      end;
    end;
  end;

  LoadPoundStation(EditPoundStation.Properties.Items);
  ActiveControl := EditTruck;
end;

//Desc: 串口操作
procedure TfFormCardProvide.ActionComPort(const nStop: Boolean);
var nInt: Integer;
    nIni: TIniFile;
begin
  if nStop then
  begin
    ComPort1.Close;
    Exit;
  end;

  with ComPort1 do
  begin
    with Timeouts do
    begin
      ReadTotalConstant := 100;
      ReadTotalMultiplier := 10;
    end;

    nIni := TIniFile.Create(gPath + 'Reader.Ini');
    with gReaderItem do
    try
      nInt := nIni.ReadInteger('Param', 'Type', 1);
      FType := TReaderType(nInt - 1);

      FPort := nIni.ReadString('Param', 'Port', '');
      FBaud := nIni.ReadString('Param', 'Rate', '4800');
      FDataBit := nIni.ReadInteger('Param', 'DataBit', 8);
      FStopBit := nIni.ReadInteger('Param', 'StopBit', 0);
      FCheckMode := nIni.ReadInteger('Param', 'CheckMode', 0);

      Port := FPort;
      BaudRate := StrToBaudRate(FBaud);

      case FDataBit of
       5: DataBits := dbFive;
       6: DataBits := dbSix;
       7: DataBits :=  dbSeven else DataBits := dbEight;
      end;

      case FStopBit of
       2: StopBits := sbTwoStopBits;
       15: StopBits := sbOne5StopBits
       else StopBits := sbOneStopBit;
      end;
    finally
      nIni.Free;
    end;

    if ComPort1.Port <> '' then
      ComPort1.Open;
    //xxxxx
  end;
end;

procedure TfFormCardProvide.ComPort1RxChar(Sender: TObject; Count: Integer);
var nStr,nCard: string;
    nIdx,nLen: Integer;
begin
  ComPort1.ReadStr(nStr, Count);
  FBuffer := FBuffer + nStr;

  nLen := Length(FBuffer);
  if nLen < 7 then Exit;

  for nIdx:=1 to nLen do
  begin
    if (FBuffer[nIdx] <> #$AA) or (nLen - nIdx < 6) then Continue;
    if (FBuffer[nIdx+1] <> #$FF) or (FBuffer[nIdx+2] <> #$00) then Continue;

    nStr := Copy(FBuffer, nIdx+3, 4);
    if not HasDriverCard(EditTruck.Text, nCard) then
      EditCard.Text := ParseCardNO(nStr, True)
    else
      EditCard.Text := nCard;

    FBuffer := '';
    Exit;
  end;
end;

procedure TfFormCardProvide.EditCardKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    BtnOK.Click;
  end else OnCtrlKeyPress(Sender, Key);
end;

function TfFormCardProvide.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nStr: string;
    nVal: Double;
begin
  Result := True;

  if Sender = EditOrder then
  begin
    Result := Length(EditOrder.Text) > 0;
    nHint := '采购订单不能为空';
  end else

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>=0);
    nHint := '请填写有效的办理量';
    if not Result then Exit;

    nVal := StrToFloat(EditValue.Text);
    Result := FloatRelation(nVal, FOrderItem.FValue, rtLE);
    nHint := '已超过可提货量';
  end else

  if Sender = EditCard then
  begin
    Result := Length(EditCard.Text) > 0;
    nHint := '请输入有效卡号';
  end else

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '车牌号长度应大于2位';
    if not Result then Exit;

    nStr := 'Select Count(*) From %s ' +
            'Where P_Truck=''%s'' And P_Card<>''''';
    nStr := Format(nStr, [sTable_CardProvide, EditTruck.Text]);

    with FDM.QueryTemp(nStr) do
    if Fields[0].AsInteger > 0 then
    begin
      nStr := '车辆[ %s ]已办理磁卡[ %d ]张,是否办理新卡?';
      nStr := Format(nStr, [EditTruck.Text, Fields[0].AsInteger]);

      Result := QueryDlg(nStr, sAsk);
      nHint := '';
    end;
  end;
end;  

//Desc: 保存磁卡
procedure TfFormCardProvide.BtnOKClick(Sender: TObject);
var nID, nStr: string;
    nPrint: Boolean;
begin
  if not IsDataValid then Exit;

  {$IFDEF AskUnLoad}
  if EditYLineName.Text = '' then
  if not QueryDlg('是否需要输入卸货地点?',sAsk) then Exit;
  {$ENDIF}

  LoadSysDictItem(sFlag_PrintPur, FListB);
  //需打印品种
  nPrint := FListB.IndexOf(FOrderItem.FStockID) >= 0;

  with FOrderItem, FListA do
  begin
    Clear;

    Values['Order']     := FOrders;
    Values['Origin']    := FStockArea;
    Values['Factory']   := gSysParam.FFactNum;
    Values['Truck']     := Trim(EditTruck.Text);

    Values['ProID']     := FCusID;
    Values['ProName']   := FCusName;

    Values['StockNO']   := FStockID;
    Values['StockName'] := FStockName;
    Values['Value']     := Trim(EditValue.Text);

    Values['Card']      := Trim(EditCard.Text);
    if CheckELabel.Checked then
      Values['UseELabel'] := sFlag_Yes
    else
      Values['UseELabel'] := sFlag_No;
    Values['Memo']      := Trim(EditMemo.Text);
    Values['Ship']      := Trim(EditShip.Text);

    if EditCardType.Checked then
         Values['CardType']:= sFlag_ProvCardG
    else Values['CardType']:= sFlag_ProvCardL;

    if EditMuilti.Checked then
         Values['Muilti']:= sFlag_Yes
    else Values['Muilti']:= sFlag_No;

    if EditBack.Checked then
         Values['TruckBack']:= sFlag_Yes
    else Values['TruckBack']:= sFlag_No;

    if EditPre.Checked then
         Values['TruckPre']:= sFlag_Yes
    else Values['TruckPre']:= sFlag_No;
    
    Values['PoundStation'] := GetCtrlData(EditPoundStation);
    Values['PoundName']    := EditPoundStation.Text;
    Values['UnLoad']    := EditYLineName.Text;
    if SnapTruck.Checked  then
         Values['SnapTruck'] := sFlag_Yes
    else Values['SnapTruck'] := sFlag_No;
  end;

  nID := SaveCardProvie(PackerEncodeStr(FListA.Text));
  if nID = '' then Exit;

  if nPrint then
  begin
    nStr := 'Select Top 1 R_ID From %s Where P_Card=''%s''';
    nStr := Format(nStr, [sTable_CardProvide, Trim(EditCard.Text)]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '未找到单据,无法打印';
        ShowMsg(nStr, sHint); Exit;
      end;
      PrintShipProReport(Fields[0].AsString, True);
    end;
  end;

  ModalResult := mrOk;
  ShowMsg('采购业务办卡成功', sHint);
  //done
end;

procedure TfFormCardProvide.EditTruckKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
    nCard: string;
begin
  inherited;
  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOk) then Exit;

    EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;

    if HasDriverCard(EditTruck.Text, nCard) then
      EditCard.Text := nCard;
  end;
end;

procedure TfFormCardProvide.FormCreate(Sender: TObject);
begin
  {$IFDEF RemoteSnap}
  dxLayout1Item18.Visible := True;
  {$ELSE}
  dxLayout1Item18.Visible := False;
  SnapTruck.Checked := False;
  {$ENDIF}
end;

procedure TfFormCardProvide.CheckELabelPropertiesChange(Sender: TObject);
var nStr: string;
begin
  if CheckELabel.Checked then
  begin
    nStr := 'Select top 1 T_Card,T_CardUse From %s ' +
            'Where T_Truck=''%s'' Order by R_ID DESC';
    nStr := Format(nStr, [sTable_Truck, EditTruck.Text]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount <= 0 then
      begin
        ShowMsg('请维护车辆档案并办理电子标签', sHint);
        Exit;
      end;
      if (Fields[0].AsString = '') or (Fields[1].AsString <> sFlag_Yes)  then
      begin
        nStr := '车辆[ %s ]未办理电子标签或电子标签未启用';
        nStr := Format(nStr, [EditTruck.Text]);
        ShowMsg(nStr, sHint);
        Exit;
      end;
      EditCard.Text := Fields[0].AsString;
    end;
  end
  else
    EditCard.Clear;
end;

initialization
  gControlManager.RegCtrl(TfFormCardProvide, TfFormCardProvide.FormID);

end.
