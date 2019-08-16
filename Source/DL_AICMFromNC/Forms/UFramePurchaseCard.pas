unit UFramePurchaseCard;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameBase, ComCtrls, ExtCtrls, Buttons, StdCtrls,
  USelfHelpConst, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxButtonEdit, cxDropDownEdit ;

type

  TfFramePurchaseCard = class(TfFrameBase)
    Pnl_OrderInfo: TPanel;
    lvOrders: TListView;
    lbl_2: TLabel;
    lbl_3: TLabel;
    lbl_TruckId: TLabel;
    btnSave: TSpeedButton;
    lbl_CusName: TLabel;
    lbl_StockName: TLabel;
    tmr1: TTimer;
    edt_TruckNo: TcxComboBox;
    Label1: TLabel;
    lbl_Area: TLabel;
    procedure lvOrdersClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure edt_TruckNoPropertiesChange(Sender: TObject);
  private
    { Private declarations }
    FListA, FListB, FListC: TStrings;
    FPurOrderItems : array of stMallPurchaseItem; //��������
    FPurchaseItem : stMallPurchaseItem;
  private
    procedure InitOrderInfo;
    procedure LoadNcPurchaseList;
    procedure InitListView;
    procedure AddListViewItem(var nPurOrderItem: stMallPurchaseItem);

  public
    { Public declarations }
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;

    class function FrameID: integer; override;
  end;

var
  fFramePurchaseCard: TfFramePurchaseCard;

implementation

{$R *.dfm}

uses
    ULibFun, USysLoger, UDataModule, UMgrControl, USysBusiness, UMgrTTCEDispenser,
    USysDB, UBase64;

//------------------------------------------------------------------------------
//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFramePurchaseCard, 'ERP �ɹ����ƿ�', nEvent);
end;

class function TfFramePurchaseCard.FrameID: Integer;
begin
  Result := cFI_FramePurERPMakeCard;
end;

procedure TfFramePurchaseCard.OnCreateFrame;
var nStr: string;
begin
  DoubleBuffered := True;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListC.Clear;

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_ParamB=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_AICMPurStock, gSysParam.FLocalIP]);

  with FDM.SQLQuery(nStr) do
  if RecordCount > 0 then
  begin
    First;
    while not Eof do
    begin
      FListC.Add(Fields[0].AsString);
      Next;
    end;
  end;
end;

procedure TfFramePurchaseCard.OnDestroyFrame;
begin
  FListA.Free;
  FListB.Free;
  FListC.Free;
end;

procedure TfFramePurchaseCard.LoadNcPurchaseList;
var nCount, i : Integer;
begin
  FListA.Clear;

  FListA.Text:= DecodeBase64(GetNcOrderList());
  //WriteLog('���յ��ķ����б�'+FListA.Text);
//  FListA.Text:= 'UHJvdklEPTAzNDE4ODEwMDAzDQpQcm92TmFtZT2wsrvVyqHE/rn6ytDE/rumuNbH8tPQz965q8u+DQpQSz0xMDU2RjQxMDAwMDAwMDAwMkdUNQ0KWmhpS2E9TUUwMzEzMTIwNTAwMTENClpLRGF0ZT0yMDEzLTEyLTA1IDA3OjUxOjE0DQpTdG9ja05vPTA0MTQwMTAwMDMNClN0b2NrTmFtZT2437j1x/INCk1heG51bWJlcj04DQo='+#$D#$A+
//'UHJvdklEPTkxMjAyMDgNClByb3ZOYW1lPbOjyb3Ez7e9y67E4NPQz965q8u+DQpQSz0xMDU2RjQxMDAwMDAwMDAwOTM3Qw0KWmhpS2E9TUUwMzE3MDQwNTAwMTUNClpLRGF0ZT0yMDE3LTA0LTA1IDA4OjE5OjMwDQpTdG9ja05vPTAxMDIxMTAwMDENClN0b2NrTmFtZT3K7MHPKLyvzcXE2s3'+
//'iubqjqQ0KTWF4bnVtYmVyPTEwMDAwMDANCg=='+#$D#$A+
//'UHJvdklEPTAzNDEwMjIwMDY1DQpQcm92TmFtZT3Q3cT+z9jG69TGyb3O67zi0P7O5NHSyq/Bz7Ono6jG1c2ous+776OpDQpQSz0xMDU2QTMxMDAwMDAwMDA2MEYyMQ0KWmhpS2E9Q0QxNzA1MDQxMDgzDQpaS0RhdGU9MjAxNy0wNS0wNCAxNToyODoxMQ0KU3RvY2tObz0wMTAyMDYwMDg1DQp'+
//'TdG9ja05hbWU90P7O5NHSDQpNYXhudW1iZXI9MjkyNjcuNjgNCg=='+#$D#$A;

  if FListA.Text='' then
  begin
    ShowMsg('δ�ܲ�ѯ���ɹ����б�', sHint);
    Exit;
  end;
  btnSave.Enabled:= True;
             //Exit;
  try
    nCount := FListA.Count;
    SetLength(FPurOrderItems, nCount);
    for i := 0 to nCount-1 do
    begin
      FListB.Text := DecodeBase64(FListA.Strings[i]);
      //***********************
      if FListC.IndexOf(FListB.Values['StockNo']) < 0 then
        Continue;
      FPurOrderItems[i].FOrder_id := FListB.Values['PK'];
      FPurOrderItems[i].FZhiKaNo  := FListB.Values['ZhiKa'];
      FPurOrderItems[i].FProvID   := FListB.Values['ProvID'];
      FPurOrderItems[i].FProvName := FListB.Values['ProvName'];

      FPurOrderItems[i].FgoodsID  := FListB.Values['StockNo'];
      FPurOrderItems[i].FGoodsname:= FListB.Values['StockName'];
      FPurOrderItems[i].FMaxMum   := FListB.Values['Maxnumber'];

      FPurOrderItems[i].FData := FListB.Values['ZKDate'];
      FPurOrderItems[i].FTrackNo := FListB.Values['tracknumber'];
      FPurOrderItems[i].FArea    := FListB.Values['SaleArea'];

      AddListViewItem(FPurOrderItems[i]);
    end;
  finally
    FListB.Clear;
    FListA.Clear;
  end;
end;

procedure TfFramePurchaseCard.InitOrderInfo;
begin
  lbl_CusName.Caption := '';
  lbl_StockName.Caption := '';

  edt_TruckNo.Text:= '';
  btnSave.Enabled:= False;
end;

procedure TfFramePurchaseCard.InitListView;
var
  col:TListColumn;
begin
  lvOrders.Columns.Clear;
  lvOrders.Items.Clear;
  FillChar(FPurchaseItem, SizeOf(stMallPurchaseItem), #0);

  lvOrders.ViewStyle := vsReport;
  col := lvOrders.Columns.Add;
  col.Caption := '�������';
  col.Width := 0;
  col := lvOrders.Columns.Add;
  col.Caption := '���';
  col.Width := 260;
  col := lvOrders.Columns.Add;
  col.Caption := '��Ӧ������';
  col.Width := 350;
  col := lvOrders.Columns.Add;
  col.Caption := '��������';
  col.Width := 270;
  col := lvOrders.Columns.Add;
  col.Caption := '���Ӧ��';
  col.Width := 150;
  col := lvOrders.Columns.Add;
  col.Caption := '����';
  col.Width := 0;
  col := lvOrders.Columns.Add;
  col.Caption := '��Ӧ��ID';
  col.Width := 0;
  col := lvOrders.Columns.Add;
  col.Caption := '����ID';
  col.Width := 0;
end;

procedure TfFramePurchaseCard.AddListViewItem(var nPurOrderItem: stMallPurchaseItem);
var
  nListItem:TListItem;
begin
  nListItem := lvOrders.Items.Add;
  nlistitem.Caption := nPurOrderItem.FOrder_id;

  nlistitem.SubItems.Add(nPurOrderItem.FArea);
  nlistitem.SubItems.Add(nPurOrderItem.FProvName);
  nlistitem.SubItems.Add(nPurOrderItem.FGoodsname);
  nlistitem.SubItems.Add(nPurOrderItem.FMaxMum);
  nlistitem.SubItems.Add(nPurOrderItem.FData);

  nlistitem.SubItems.Add(nPurOrderItem.FProvID);
  nlistitem.SubItems.Add(nPurOrderItem.FGoodsID);
end;

procedure TfFramePurchaseCard.lvOrdersClick(Sender: TObject);
begin
  if lvOrders.Selected <> nil then
  begin
    with lvOrders.Selected do
    begin
      lbl_CusName.Caption := SubItems[1];
      lbl_StockName.Caption := SubItems[2];
      lbl_Area.Caption := SubItems[0];

      FPurchaseItem.FOrder_Id:= Caption;
      FPurchaseItem.FProvID  := SubItems[5];
      FPurchaseItem.FProvName:= SubItems[1];
      FPurchaseItem.FGoodsID := SubItems[6];
      FPurchaseItem.FGoodsname:= SubItems[2];
      FPurchaseItem.FArea    := SubItems[0];
      FPurchaseItem.FMaxMum  := SubItems[3];
      FPurchaseItem.FData    := SubItems[4];

      edt_TruckNo.Text:= '';
    end;
  end;
end;

procedure TfFramePurchaseCard.tmr1Timer(Sender: TObject);
var nStr: string;
begin
  if gNeedSearchPurOrder then
  begin
    InitOrderInfo;
    InitListView;
    btnSave.Enabled:= False;
    LoadNcPurchaseList;
    gNeedSearchPurOrder:= False;

    edt_TruckNo.Properties.Items.Clear;
    nStr := 'Select T_Truck From %s Where 1=1 ';
    nStr := Format(nStr, [sTable_Truck]);

    nStr := nStr + Format(' And (T_Valid Is Null or T_Valid<>''%s'') ', [sFlag_No]);

    with FDM.SQLQuery(nStr) do
    begin
      if RecordCount > 0 then
      begin
        try
          edt_TruckNo.Properties.BeginUpdate;

          First;

          while not Eof do
          begin
            edt_TruckNo.Properties.Items.Add(Fields[0].AsString);
            Next;
          end;
        finally
          edt_TruckNo.Properties.EndUpdate;
        end;
      end;
    end;
  end;
end;

procedure TfFramePurchaseCard.btnSaveClick(Sender: TObject);
var nMsg, nStr, nCard, nHint: string;
    nIdx: Integer;
    nRet, nPrint: Boolean;
begin
  if (FPurchaseItem.FOrder_Id='')or(Trim(edt_TruckNo.Text)='')then  //or(StrToFloatDef(Trim(edt_Value.Text), 0)=0)
  begin
    ShowMsg('����д���ƺ���Ϣ', sHint);
    Exit;
  end;

  {$IFNDEF AICMNoVerifyTruck}
  if edt_TruckNo.Properties.Items.IndexOf(edt_TruckNo.Text) < 0 then
  begin
    ShowMsg('��ѡ���ƺŻ������������ƺ�', sHint);
    Exit;
  end;
  {$ENDIF}

  {$IFDEF BusinessOnly}
  if IFHasBill(edt_TruckNo.Text) then
  begin
    ShowMsg('��������δ��ɵ����������,�޷�����,����ϵ����Ա',sHint);
    Exit;
  end;
  {$ENDIF}

  if not IsPurTruckReady(edt_TruckNo.Text, nHint) then
  begin
    nStr := '����[%s]����δ��ɵĲɹ�����[%s],�޷��쿨';
    nStr := Format(nStr,[edt_TruckNo.Text, nHint]);
    ShowMsg(nStr, sHint);
    Exit;
  end;
  //***************************************************
//  if ShopOrderHasUsed(FListA.Values['WebShopID']) then
//  begin
//    nMsg := '������[ %s ]��ʹ��,����ѡ������.';
//    nMsg := Format(nMsg, [FListA.Values['WebShopID']]);
//    ShowMsg(nMsg, sHint);
//    Exit;
//  end;

  for nIdx:=0 to 3 do
  begin
    nCard := gDispenserManager.GetCardNo(gSysParam.FTTCEK720ID, nHint, False);
    if nCard <> '' then
      Break;
    Sleep(500);
  end;
  //�������ζ���,�ɹ����˳���

  if nCard = '' then
  begin
    nMsg := '�����쳣,��鿴�Ƿ��п�.';
    ShowMsg(nMsg, sWarn);
    Exit;
  end;

  WriteLog('��ȡ����Ƭ: ' + nCard);
  //������Ƭ
  if not IsCardValid(nCard) then
  begin
    gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);
    nMsg := '����' + nCard + '�Ƿ�,������,���Ժ�����ȡ��';
    WriteLog(nMsg);
    ShowMsg(nMsg, sWarn);
    Exit;
  end;

  nStr := GetCardUsed(nCard);
  if (nStr = sFlag_Sale) or (nStr = sFlag_SaleNew) then
    LogoutBillCard(nCard);
  //����ҵ��ע����Ƭ,����ҵ��������ע��

  LoadSysDictItem(sFlag_PrintPur, FListB);
  //���ӡƷ��
  nPrint := FListB.IndexOf(FPurchaseItem.FGoodsID) >= 0;

  begin
    with FListB do
    begin
      Clear;

      Values['Order']     := FPurchaseItem.FOrder_Id;
      Values['Origin']    := FPurchaseItem.FArea;
      Values['Truck']     := Trim(edt_TruckNo.Text);
      //Values['Factory']   := gSysParam.FFactNum;

      Values['ProID']     := FPurchaseItem.FProvID;
      Values['ProName']   := FPurchaseItem.FProvName;

      Values['StockNO']   := FPurchaseItem.FGoodsID;
      Values['StockName'] := FPurchaseItem.FGoodsname;
      Values['Value']     := '';

      Values['Card']      := nCard;
      Values['Memo']      := '';

      Values['CardType']  := sFlag_ProvCardL;
      Values['TruckBack'] := sFlag_No;
      Values['TruckPre']  := sFlag_No;
      Values['Muilti']    := sFlag_No;
      {$IFDEF RemoteSnap}
      Values['SnapTruck'] := sFlag_Yes;
      {$ELSE}
      Values['SnapTruck'] := sFlag_No;
      {$ENDIF}
    end;

    nStr := SaveCardProvie(EncodeBase64(FListB.Text));
    //call mit bus
    nRet := nStr <> '';
    //SaveShopOrderIn(FListA.Values['WebShopID'], nStr);
  end;

  if not nRet then
  begin
    nMsg := '����ſ�ʧ��,������.';
    ShowMsg(nMsg, sHint);
    Exit;
  end;

  nRet := gDispenserManager.SendCardOut(gSysParam.FTTCEK720ID, nHint);
  //����

  if nRet then
  begin
    nMsg := '�ɹ���[ %s ]�����ɹ�,����[ %s ],���պ����Ŀ�Ƭ';
    nMsg := Format(nMsg, [nStr, nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);

    if nPrint then
    begin
      nStr := 'Select Top 1 R_ID From %s Where P_Card=''%s''';
      nStr := Format(nStr, [sTable_CardProvide, nCard]);

      with FDM.SQLQuery(nStr) do
      begin
        if RecordCount < 1 then
        begin
          nStr := 'δ�ҵ�����,�޷���ӡ';
          ShowMsg(nStr, sHint); Exit;
        end;
        PrintShipProReport(Fields[0].AsString, False);
      end;
    end;
  end
  else begin
    gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);

    nMsg := '����[ %s ],����[ %s ]��������ʧ��,�뵽��Ʊ�������¹���.';
    nMsg := Format(nMsg, [FListA.Values['WebID'], nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end;

  gTimeCounter := 0;
end;

procedure TfFramePurchaseCard.edt_TruckNoPropertiesChange(Sender: TObject);
var nIdx : Integer;
    nStr: string;
begin
  edt_TruckNo.Properties.Items.Clear;
  nStr := 'Select T_Truck From %s Where T_Truck like ''%%%s%%'' ';
  nStr := Format(nStr, [sTable_Truck, edt_TruckNo.Text]);

  nStr := nStr + Format(' And (T_Valid Is Null or T_Valid<>''%s'') ', [sFlag_No]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      try
        edt_TruckNo.Properties.BeginUpdate;

        First;

        while not Eof do
        begin
          edt_TruckNo.Properties.Items.Add(Fields[0].AsString);
          Next;
        end;
      finally
        edt_TruckNo.Properties.EndUpdate;
      end;
    end;
  end;
  for nIdx := 0 to edt_TruckNo.Properties.Items.Count - 1 do
  begin;
    if Pos(edt_TruckNo.Text,edt_TruckNo.Properties.Items.Strings[nIdx]) > 0 then
    begin
      edt_TruckNo.SelectedItem := nIdx;
      Break;
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFramePurchaseCard, TfFramePurchaseCard.FrameID);

end.
