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
    //�б���Ϣ

    procedure InitUIData(nOrderInfo: string = '');
    //��ʼ����Ϣ
  public
    { Public declarations }
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnShowFrame; override;

    class function FrameID: integer; override;
    function DealCommand(Sender: TObject; const nCmd: Integer;
      const nParamA: Pointer; const nParamB: Integer): Integer; override;
    {*��������*}
  end;

var
  fFrameMakeCard: TfFrameMakeCard;

implementation

{$R *.dfm}

uses
  ULibFun, USysLoger, UDataModule, UMgrControl, USelfHelpConst,
  USysBusiness, UMgrK720Reader, USysDB, UBase64;

//------------------------------------------------------------------------------
//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameMakeCard, '���϶����ƿ�', nEvent);
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
    ShowMsg('�޶�����Ϣ', sHint);
    gTimeCounter := 0;
    Exit;
  end;

  FListA.Text := nOrderInfo;
  with FListA do
  begin
    LabelOrder.Caption := '�������:' + Values['OrderNO'];
    LabelCusName.Caption := '�ͻ�����:' + Values['CusName'];
    LabelStockName.Caption := '��������:' + Values['StockName'];

    LabelTruck.Caption := '���ƺ���:' + Values['Truck'];
    LabelTon.Caption   := '��������:' + Values['Value'];
    LabelMemo.Caption  := '��ע��Ϣ:' + Values['SendArea'];
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
    nMsg := '������[ %s ]��ʹ��,����ѡ������.';
    nMsg := Format(nMsg, [FListA.Values['WebShopID']]);
    ShowMsg(nMsg, sHint);
    Exit;
  end;

  for nIdx:=0 to 3 do
  if gMgrK720Reader.ReadCard(nCard) then Break
  else Sleep(500);
  //�������ζ���,�ɹ����˳���

  if nCard = '' then
  begin
    nMsg := '�����쳣,��鿴�Ƿ��п�.';
    ShowMsg(nMsg, sWarn);
    Exit;
  end;

  nCard := gMgrK720Reader.ParseCardNO(nCard);
  WriteLog('��ȡ����Ƭ: ' + nCard);
  //������Ƭ

  nStr := GetCardUsed(nCard);
  if (nStr = sFlag_Sale) or (nStr = sFlag_SaleNew) then
    LogoutBillCard(nCard);
  //����ҵ��ע����Ƭ,����ҵ��������ע��

  if FListA.Values['OrderType'] = sFlag_Sale then
  begin
    with FListB do
    begin
      Clear;
      Values['Orders'] := EncodeBase64(FListA.Values['Orders']);
      Values['Value'] := FListA.Values['Value'];                                 //������
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
      nMsg := '�����������Ϣʧ��,����ϵ����Ա�����ֹ��ƿ�.';
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
    nMsg := '����ſ�ʧ��,������.';
    ShowMsg(nMsg, sHint);
    Exit;
  end;

  for nIdx := 0 to 3 do
  begin
    nRet := gMgrK720Reader.SendReaderCmd('FC0');
    if nRet then Break;

    Sleep(500);
  end;
  //����

  if nRet then
  begin
    nMsg := '΢�Ŷ���[ %s ]�����ɹ�,����[ %s ],���պ����Ŀ�Ƭ';
    nMsg := Format(nMsg, [FListA.Values['WebID'], nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end
  else begin
    gMgrK720Reader.RecycleCard;

    nMsg := '΢�Ŷ���[ %s ],����[ %s ]��������ʧ��,�뵽��Ʊ�������¹���.';
    nMsg := Format(nMsg, [FListA.Values['WebID'], nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end;

  gTimeCounter := 0;
end;

initialization
  gControlManager.RegCtrl(TfFrameMakeCard, TfFrameMakeCard.FrameID);
end.
