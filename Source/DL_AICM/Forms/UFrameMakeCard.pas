unit UFrameMakeCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameBase, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, jpeg, Buttons,
  StdCtrls;

type
  TfFrameMakeCard = class(TfFrameBase)
    PanelClient: TPanel;
    BtnOK: TSpeedButton;
    LabelCusName: TcxLabel;
    LabelOrder: TcxLabel;
    LabelTruck: TcxLabel;
    LabelStockName: TcxLabel;
    LabelTon: TcxLabel;
    LabelMemo: TcxLabel;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FListA, FListB, FListC: TStrings;
    //列表信息

    procedure InitUIData(nOrderInfo: string = '');
    //初始化信息
  public
    { Public declarations }
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnShowFrame; override;

    class function FrameID: integer; override;
    function DealCommand(Sender: TObject; const nCmd: Integer;
      const nParamA: Pointer; const nParamB: Integer): Integer; override;
    {*处理命令*}
  end;

var
  fFrameMakeCard: TfFrameMakeCard;

implementation

{$R *.dfm}

uses
  ULibFun, USysLoger, UDataModule, UMgrControl, USelfHelpConst,
  USysBusiness, UMgrK720Reader, USysDB, UBase64;

//------------------------------------------------------------------------------
//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameMakeCard, '网上订单制卡', nEvent);
end;

class function TfFrameMakeCard.FrameID: Integer;
begin
  Result := cFI_FrameMakeCard;
end;

function TfFrameMakeCard.DealCommand(Sender: TObject; const nCmd: Integer;
  const nParamA: Pointer; const nParamB: Integer): Integer;
begin
  Result := 0;
  if nCmd = cCmd_FrameQuit then
  begin
    Close;
  end else

  if nCmd = cCmd_MakeCard then
  begin
    if not Assigned(nParamA) then Exit;
    InitUIData(PFrameCommandParam(nParamA).FParamA);
  end;
end;

procedure TfFrameMakeCard.OnCreateFrame;
begin
  DoubleBuffered := True;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
end;

procedure TfFrameMakeCard.OnDestroyFrame;
begin
  FListA.Free;
  FListB.Free;
  FListC.Free;
end;

procedure TfFrameMakeCard.OnShowFrame;
begin

end;

procedure TfFrameMakeCard.InitUIData(nOrderInfo: string);
begin
  if nOrderInfo = '' then
  begin
    ShowMsg('无订单信息', sHint);
    gTimeCounter := 0;
    Exit;
  end;

  FListA.Text := nOrderInfo;
  with FListA do
  begin
    LabelOrder.Caption := '订单编号:' + Values['OrderNO'];
    LabelCusName.Caption := '客户名称:' + Values['CusName'];
    LabelStockName.Caption := '物料名称:' + Values['StockName'];

    LabelTruck.Caption := '车牌号码:' + Values['Truck'];
    LabelTon.Caption   := '订单数量:' + Values['Value'];
    LabelMemo.Caption  := '备注信息:' + Values['SendArea'];
  end;

  gTimeCounter := 30;
end;

procedure TfFrameMakeCard.BtnOKClick(Sender: TObject);
var nMsg, nStr, nCard: string;
    nIdx: Integer;
    nRet: Boolean;
begin
  inherited;
  if ShopOrderHasUsed(FListA.Values['WebShopID']) then
  begin
    nMsg := '订单号[ %s ]已使用,请重选订单号.';
    nMsg := Format(nMsg, [FListA.Values['WebShopID']]);
    ShowMsg(nMsg, sHint);
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

  if FListA.Values['OrderType'] = sFlag_Sale then
  begin
    with FListB do
    begin
      Clear;
      Values['Orders'] := EncodeBase64(FListA.Values['Orders']);
      Values['Value'] := FListA.Values['Value'];                                 //订单量
      Values['Truck'] := FListA.Values['Truck'];
      Values['Lading'] := sFlag_TiHuo;
      Values['IsVIP'] := sFlag_TypeCommon;
      Values['Pack'] := FListA.Values['StockType'];
      Values['BuDan'] := sFlag_No;
      Values['CusID'] := FListA.Values['CusID'];
      Values['CusName'] := FListA.Values['CusName'];
      Values['Brand'] := FListA.Values['Brand'];
      Values['StockArea'] := FListA.Values['StockArea'];
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
    SaveShopOrderIn(FListA.Values['WebShopID'], nStr);
  end else

  if FListA.Values['OrderType'] = sFlag_Provide then
  begin
    with FListB do
    begin
      Clear;

      Values['Order']     := FListA.Values['OrderNO'];
      Values['Origin']    := FListA.Values['Origin'];
      Values['Truck']     := FListA.Values['Truck'];

      Values['ProID']     := FListA.Values['CusID'];
      Values['ProName']   := FListA.Values['CusName'];

      Values['StockNO']   := FListA.Values['StockNO'];
      Values['StockName'] := FListA.Values['StockName'];
      Values['Value']     := FListA.Values['Value'];

      Values['Card']      := nCard;
      Values['Memo']      := FListA.Values['Data'];

      Values['CardType']  := sFlag_ProvCardL;
      Values['TruckBack'] := sFlag_No;
      Values['TruckPre']  := sFlag_No;
      Values['Muilti']    := sFlag_No;
    end;

    nStr := SaveCardProvie(EncodeBase64(FListB.Text));
    //call mit bus
    nRet := nStr <> '';
    SaveShopOrderIn(FListA.Values['WebShopID'], nStr);
  end else nRet := False;

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
    nMsg := '微信订单[ %s ]发卡成功,卡号[ %s ],请收好您的卡片';
    nMsg := Format(nMsg, [FListA.Values['WebID'], nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end
  else begin
    gMgrK720Reader.RecycleCard;

    nMsg := '微信订单[ %s ],卡号[ %s ]关联订单失败,请到开票窗口重新关联.';
    nMsg := Format(nMsg, [FListA.Values['WebID'], nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end;

  gTimeCounter := 0;
end;

initialization
  gControlManager.RegCtrl(TfFrameMakeCard, TfFrameMakeCard.FrameID);
end.
