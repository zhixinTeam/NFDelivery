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
    FSaleOrderItems : array of TOrderInfoItem; //��������
    FSaleOrderItem : TOrderInfoItem;
  private
    procedure LoadNcSaleList(nSTDid, nPassword: string);
    procedure InitListView;
    procedure AddListViewItem(var nSaleOrderItem: TOrderInfoItem);
    procedure InitUIData(nSTDid, nPassword: string);
    //��ʼ����Ϣ
  public
    { Public declarations }
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;

    class function FrameID: integer; override;
    function DealCommand(Sender: TObject; const nCmd: Integer;
      const nParamA: Pointer; const nParamB: Integer): Integer; override;
    {*��������*}
  end;

var
  fFrameSaleCard: TfFrameSaleCard;

implementation

{$R *.dfm}

uses
    ULibFun, USysLoger, UDataModule, UMgrControl, USysBusiness, UMgrK720Reader,
    USysDB, UBase64;

//------------------------------------------------------------------------------
//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameSaleCard, 'ERP �����ƿ�', nEvent);
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
    ShowMsg('δ�ܲ�ѯ�����۶����б�', sHint);
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
  col.Caption := '�ͻ�����';
  col.Width := 260;
  col := lvOrders.Columns.Add;
  col.Caption := '��������';
  col.Width := 230;
  col := lvOrders.Columns.Add;
  col.Caption := '���ƺ���';
  col.Width := 150;
  col := lvOrders.Columns.Add;
  col.Caption := '����';
  col.Width := 70;
  col := lvOrders.Columns.Add;
  col.Caption := 'ƴ��';
  col.Width := 70;
  col := lvOrders.Columns.Add;
  col.Caption := 'ѡ��';
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
    nlistitem.SubItems.Add('��')
  else
    nlistitem.SubItems.Add('��');
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
        ShowMsg('�˶����Ѱ쿨,������ѡ��', sHint);
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
        if Pos('ɢ',FSaleOrderItems[lvOrders.Selected.Index].FStockName + ',' + nStockName) > 0 then
        begin
          ShowMsg('ɢװ�����޷�ƴ��,������ѡ��', sHint);
          Exit;
        end;
        if FSaleOrderItems[lvOrders.Selected.Index].FPd <> sFlag_Yes then
        begin
          ShowMsg('������ƴ���Ķ����޷�ƴ��,������ѡ��', sHint);
          Exit;
        end;
        if Pos(FSaleOrderItems[lvOrders.Selected.Index].FTruck, nTruck) <= 0 then
        begin
          ShowMsg('��ͬ���ƺ��޷�ƴ��,������ѡ��', sHint);
          Exit;
        end;
        nCanPd := nCanPd and (nInt < 2);
      end
      else
        nCanPd := True;

      if not nCanPd then
      begin
        ShowMsg('���֧��2����������ƴ��,������ѡ��', sHint);
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
    ShowMsg('������ѡ��1������', sHint);
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
      Values['Value'] := FloatToStr(FSaleOrderItems[nIdx].FValue);                                 //������
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
      nMsg := '�����������Ϣʧ��,����ϵ����Ա�����ֹ��ƿ�.';
      ShowMsg(nMsg, sHint);
      Exit;
    end;

    nRet := SaveBillCard(nStr, nCard);
    //SaveWebOrderMatch(nStr,FSaleOrderItems[nIdx].FOrders,sFlag_Sale);
  end;

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
    nMsg := '�����[ %s ]�����ɹ�,����[ %s ],���պ����Ŀ�Ƭ';
    nMsg := Format(nMsg, [nStr, nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end
  else begin
    gMgrK720Reader.RecycleCard;

    nMsg := '����[ %s ]��������ʧ��,�뵽��Ʊ�������¹���.';
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
