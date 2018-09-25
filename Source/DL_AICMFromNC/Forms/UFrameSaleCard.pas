unit UFrameSaleCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameBase, ComCtrls, ExtCtrls, Buttons, StdCtrls,
  USelfHelpConst, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxButtonEdit, cxDropDownEdit, dxGDIPlusClasses, jpeg ;

type

  TfFrameSaleCard = class(TfFrameBase)
    Pnl_OrderInfo: TPanel;
    lvOrders: TListView;
    BtnSave: TSpeedButton;
    procedure lvOrdersClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
  private
    { Private declarations }
    FListA, FListB, FListC: TStrings;
    FSaleOrderItems : array of TOrderInfoItem; //订单数组
    FSaleOrderItem : TOrderInfoItem;
  private
    procedure LoadNcSaleList(nSTDid, nPassword: string);
    procedure InitListView;
    procedure AddListViewItem(var nSaleOrderItem: TOrderInfoItem);
    procedure InitUIData(nSTDid, nPassword: string);
    //初始化信息
  public
    { Public declarations }
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;

    class function FrameID: integer; override;
    function DealCommand(Sender: TObject; const nCmd: Integer;
      const nParamA: Pointer; const nParamB: Integer): Integer; override;
    {*处理命令*}
  end;

var
  fFrameSaleCard: TfFrameSaleCard;

implementation

{$R *.dfm}

uses
    ULibFun, USysLoger, UDataModule, UMgrControl, USysBusiness, UMgrK720Reader,
    USysDB, UBase64;

//------------------------------------------------------------------------------
//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameSaleCard, 'ERP 销售制卡', nEvent);
end;

class function TfFrameSaleCard.FrameID: Integer;
begin
  Result := cFI_FrameSaleMakeCard;
end;

procedure TfFrameSaleCard.OnCreateFrame;
begin
  DoubleBuffered := True;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
end;

procedure TfFrameSaleCard.OnDestroyFrame;
begin
  FListA.Free;
  FListB.Free;
  FListC.Free;
end;

procedure TfFrameSaleCard.LoadNcSaleList(nSTDid, nPassword: string);
var nCount, i : Integer;
begin
  FListA.Clear;

  FListA.Text:= DecodeBase64(GetNcSaleList(nSTDid, nPassword));

  if FListA.Text='' then
  begin
    ShowMsg('未能查询到销售订单列表', sHint);
    Exit;
  end;

  try
    nCount := FListA.Count;
    SetLength(FSaleOrderItems, nCount);
    for i := 0 to nCount-1 do
    begin
      FListB.Text := DecodeBase64(FListA.Strings[i]);
      //***********************
      FSaleOrderItems[i].FOrders := FListB.Values['PK'];
      FSaleOrderItems[i].FZhiKaNo  := FListB.Values['ZhiKa'];
      FSaleOrderItems[i].FCusID   := FListB.Values['CusID'];
      FSaleOrderItems[i].FCusName := FListB.Values['CusName'];

      FSaleOrderItems[i].FStockID  := FListB.Values['StockNo'];
      FSaleOrderItems[i].FStockName:= FListB.Values['StockName'];

      FSaleOrderItems[i].FStockBrand  :=  FListB.Values['Brand'];
      FSaleOrderItems[i].FStockArea:=  FListB.Values['SaleArea'];

      FSaleOrderItems[i].FValue   := StrToFloatDef(FListB.Values['Maxnumber'],0);

      FSaleOrderItems[i].FTruck := FListB.Values['Truck'];
      FSaleOrderItems[i].FBm    := FListB.Values['Bm'];
      FSaleOrderItems[i].FPd    := FListB.Values['ispd'];
      FSaleOrderItems[i].FWxZhuId    := FListB.Values['wxzhuid'];
      FSaleOrderItems[i].FWxZiId    := FListB.Values['wxziid'];
      FSaleOrderItems[i].FSelect    := False;
      AddListViewItem(FSaleOrderItems[i]);
    end;
  finally
    FListB.Clear;
    FListA.Clear;
  end;
end;

procedure TfFrameSaleCard.InitListView;
var
  col:TListColumn;
begin
  lvOrders.Columns.Clear;
  lvOrders.Items.Clear;
  FillChar(FSaleOrderItem, SizeOf(TOrderInfoItem), #0);

  lvOrders.ViewStyle := vsReport;

  col := lvOrders.Columns.Add;
  col.Caption := '客户名称';
  col.Width := 260;
  col := lvOrders.Columns.Add;
  col.Caption := '物料名称';
  col.Width := 230;
  col := lvOrders.Columns.Add;
  col.Caption := '车牌号码';
  col.Width := 150;
  col := lvOrders.Columns.Add;
  col.Caption := '数量';
  col.Width := 70;
  col := lvOrders.Columns.Add;
  col.Caption := '拼单';
  col.Width := 70;
  col := lvOrders.Columns.Add;
  col.Caption := '选择';
  col.Width := 70;
  col.Alignment := taCenter;
end;

procedure TfFrameSaleCard.AddListViewItem(var nSaleOrderItem: TOrderInfoItem);
var
  nListItem:TListItem;
begin
  nListItem := lvOrders.Items.Add;
  nlistitem.Caption := nSaleOrderItem.FCusName;

  nlistitem.SubItems.Add(nSaleOrderItem.FStockName);
  nlistitem.SubItems.Add(nSaleOrderItem.FTruck);
  nlistitem.SubItems.Add(FloatToStr(nSaleOrderItem.FValue));
  if nSaleOrderItem.FPd = sFlag_Yes then
    nlistitem.SubItems.Add('是')
  else
    nlistitem.SubItems.Add('否');
  nlistitem.SubItems.Add(sUncheck);
end;

procedure TfFrameSaleCard.lvOrdersClick(Sender: TObject);
var nIdx, nInt: Integer;
    nCanSave, nCanPd: Boolean;
    nTruck, nStockName: string;
begin
  if lvOrders.Selected <> nil then
  begin
    with lvOrders.Selected do
    begin
      if SubItems[4] = sCheck then
      begin
        SubItems[4] := sUnCheck;
        FSaleOrderItems[lvOrders.Selected.Index].FSelect := False;

        nCanSave := False;
        for nIdx := Low(FSaleOrderItems) to High(FSaleOrderItems) do
        begin
          if FSaleOrderItems[nIdx].FSelect then
          begin
            nCanSave := True;
            Break;
          end;
        end;
        btnSave.Visible := nCanSave = True;
        Exit;
      end;

      if not IsOrderCanLade(FSaleOrderItems[lvOrders.Selected.Index].FOrders) then
      begin
        ShowMsg('此订单已办卡,请重新选择', sHint);
        Exit;
      end;

      nInt := 0;
      nCanPd := True;
      nTruck := '';
      nStockName := '';
      for nIdx := Low(FSaleOrderItems) to High(FSaleOrderItems) do
      begin
        if FSaleOrderItems[nIdx].FSelect then
        begin
          nCanPd := nCanPd and (FSaleOrderItems[nIdx].FPd = sFlag_Yes);
          nTruck := nTruck + FSaleOrderItems[nIdx].FTruck + ',';
          nStockName := nStockName + FSaleOrderItems[nIdx].FStockName + ',';
          Inc(nInt);
        end;
      end;

      if nInt > 0 then
      begin
        if Pos('散',FSaleOrderItems[lvOrders.Selected.Index].FStockName + ',' + nStockName) > 0 then
        begin
          ShowMsg('散装订单无法拼单,请重新选择', sHint);
          Exit;
        end;
        if FSaleOrderItems[lvOrders.Selected.Index].FPd <> sFlag_Yes then
        begin
          ShowMsg('不允许拼单的订单无法拼单,请重新选择', sHint);
          Exit;
        end;
        if Pos(FSaleOrderItems[lvOrders.Selected.Index].FTruck, nTruck) <= 0 then
        begin
          ShowMsg('不同车牌号无法拼单,请重新选择', sHint);
          Exit;
        end;
        nCanPd := nCanPd and (nInt < 2);
      end
      else
        nCanPd := True;

      if not nCanPd then
      begin
        ShowMsg('最多支持2个订单进行拼单,请重新选择', sHint);
        Exit;
      end;
      SubItems[4] := sCheck;
      FSaleOrderItems[lvOrders.Selected.Index].FSelect := True;
    end;

    nCanSave := False;
    for nIdx := Low(FSaleOrderItems) to High(FSaleOrderItems) do
    begin
      if FSaleOrderItems[nIdx].FSelect then
      begin
        nCanSave := True;
        Break;
      end;
    end;
    btnSave.Visible := nCanSave = True;
  end;
end;

procedure TfFrameSaleCard.InitUIData(nSTDid, nPassword: string);
begin
  InitListView;
  btnSave.Visible:= False;
  LoadNcSaleList(nSTDid, nPassword);
end;

procedure TfFrameSaleCard.BtnSaveClick(Sender: TObject);
var nMsg, nStr, nCard: string;
    nIdx, nInt: Integer;
    nRet: Boolean;
begin
  nInt := 0;

  for nIdx := Low(FSaleOrderItems) to High(FSaleOrderItems) do
  begin
    if FSaleOrderItems[nIdx].FSelect then
    begin
      Inc(nInt);
    end;
  end;

  if nInt = 0 then
  begin
    ShowMsg('请至少选择1个订单', sHint);
    Exit;
  end;

  for nIdx:=0 to 3 do
  if gMgrK720Reader.ReadCard(nCard) then Break
  else Sleep(500);
  //连续三次读卡,成功则退出。

  if nCard = '' then
  begin
    nMsg := '卡箱异常,请查看是否有卡.';
    ShowMsg(nMsg, sWarn);
    Exit;
  end;

  nCard := gMgrK720Reader.ParseCardNO(nCard);
  WriteLog('读取到卡片: ' + nCard);
  //解析卡片

  nStr := GetCardUsed(nCard);
  if (nStr = sFlag_Sale) or (nStr = sFlag_SaleNew) then
    LogoutBillCard(nCard);
  //销售业务注销卡片,其它业务则无需注销
  nInt := 0;
  for nIdx := Low(FSaleOrderItems) to High(FSaleOrderItems) do
  begin
    if not FSaleOrderItems[nIdx].FSelect then
      Continue;

    nInt := nInt + 1;

    with FListB do
    begin
      Clear;

      Values['Orders'] := EncodeBase64(FSaleOrderItems[nIdx].FOrders);
      Values['Value'] := FloatToStr(FSaleOrderItems[nIdx].FValue);                                 //订单量
      Values['Truck'] := FSaleOrderItems[nIdx].FTruck;
      Values['Lading'] := sFlag_TiHuo;
      Values['IsVIP'] := sFlag_TypeCommon;
      Values['Pack'] := GetStockPackStyle(FSaleOrderItems[nIdx].FStockID);
      Values['BuDan'] := sFlag_No;
      Values['CusID'] := FSaleOrderItems[nIdx].FCusID;
      Values['CusName'] := FSaleOrderItems[nIdx].FCusName;
      Values['Brand'] := FSaleOrderItems[nIdx].FStockBrand;
      Values['StockArea'] := FSaleOrderItems[nIdx].FStockArea;
      Values['bm'] := FSaleOrderItems[nIdx].FBm;
      Values['wxzhuid'] := FSaleOrderItems[nIdx].FWxZhuId;
      Values['wxziid'] := FSaleOrderItems[nIdx].FWxZiId;
      Values['PrintHY'] := sFlag_Yes;
    end;

    nStr := SaveBill(EncodeBase64(FListB.Text));
    //call mit bus
    nRet := nStr <> '';
    if not nRet then
    begin
      nMsg := '生成提货单信息失败,请联系管理员尝试手工制卡.';
      ShowMsg(nMsg, sHint);
      Exit;
    end;

    nRet := SaveBillCard(nStr, nCard);
    //SaveWebOrderMatch(nStr,FSaleOrderItems[nIdx].FOrders,sFlag_Sale);
  end;

  if not nRet then
  begin
    nMsg := '办理磁卡失败,请重试.';
    ShowMsg(nMsg, sHint);
    Exit;
  end;

  for nIdx := 0 to 3 do
  begin
    nRet := gMgrK720Reader.SendReaderCmd('FC0');
    if nRet then Break;

    Sleep(500);
  end;
  //发卡

  if nRet then
  begin
    nMsg := '提货单[ %s ]发卡成功,卡号[ %s ],请收好您的卡片';
    nMsg := Format(nMsg, [nStr, nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end
  else begin
    gMgrK720Reader.RecycleCard;

    nMsg := '卡号[ %s ]关联订单失败,请到开票窗口重新关联.';
    nMsg := Format(nMsg, [nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end;

  gTimeCounter := 0;
end;

function TfFrameSaleCard.DealCommand(Sender: TObject; const nCmd: Integer;
  const nParamA: Pointer; const nParamB: Integer): Integer;
begin
  Result := 0;
  if nCmd = cCmd_FrameQuit then
  begin
    Close;
  end else

  if nCmd = cCmd_MakeNCSaleCard then
  begin
    if not Assigned(nParamA) then Exit;
    InitUIData(PFrameCommandParam(nParamA).FParamA,
               PFrameCommandParam(nParamA).FParamB);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameSaleCard, TfFrameSaleCard.FrameID);

end.
