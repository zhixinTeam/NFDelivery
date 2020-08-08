unit UFrameSaleCard;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameBase, ComCtrls, ExtCtrls, Buttons, StdCtrls,
  USelfHelpConst, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxButtonEdit, cxDropDownEdit, dxGDIPlusClasses, jpeg, cxCheckBox, IdHttp,
  uSuperObject;

const
  cHttpTimeOut          = 10;

type

  TfFrameSaleCard = class(TfFrameBase)
    Pnl_OrderInfo: TPanel;
    lvOrders: TListView;
    BtnSave: TSpeedButton;
    PrintHY: TcxCheckBox;
    procedure lvOrdersClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
  private
    { Private declarations }
    FListA, FListB, FListC, FListD: TStrings;
    FSaleOrderItems : array of TOrderInfoItem; //��������
    FSaleOrderItem : TOrderInfoItem;
    FLastQuery: Int64;
    //�ϴβ�ѯ
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
    ULibFun, USysLoger, UDataModule, UMgrControl, USysBusiness, UMgrTTCEDispenser,
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
  FLastQuery:= 0;
  {$IFDEF PrintHYEach}
  PrintHY.Checked := False;
  PrintHY.Visible := True;
  {$ELSE}
  PrintHY.Checked := False;
  PrintHY.Visible := False;
  {$ENDIF}
  DoubleBuffered := True;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
end;

procedure TfFrameSaleCard.OnDestroyFrame;
begin
  FListA.Free;
  FListB.Free;
  FListC.Free;
  FListD.Free;
end;

procedure TfFrameSaleCard.LoadNcSaleList(nSTDid, nPassword: string);
var nCount, i : Integer;
    nAutoPD: string;
begin
  FListA.Clear;

  FListA.Text:= DecodeBase64(GetNcSaleList(nSTDid, nPassword));

  if FListA.Text='' then
  begin
    ShowMsg('δ�ܲ�ѯ�����۶����б�', sHint);
    Exit;
  end;
  nAutoPD := GetPDModelFromDB;
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
      if nAutoPD = sFlag_Yes then
      begin
        if Pos('ɢ',FListB.Values['StockName']) > 0 then
          FSaleOrderItems[i].FPd := ''
        else
          FSaleOrderItems[i].FPd := sFlag_Yes;
      end
      else
        FSaleOrderItems[i].FPd    := FListB.Values['ispd'];
      FSaleOrderItems[i].FWxZhuId    := FListB.Values['wxzhuid'];
      FSaleOrderItems[i].FWxZiId    := FListB.Values['wxziid'];
      FSaleOrderItems[i].FPhy    := FListB.Values['isphy'];
      FSaleOrderItems[i].FTransType    := FListB.Values['transtype'];
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
  col.Caption := 'Ʒ��';
  col.Width := 100;
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
  col.Caption := '�����ص�';
  col.Width := 100;
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
  nlistitem.SubItems.Add(nSaleOrderItem.FStockBrand);
  nlistitem.SubItems.Add(nSaleOrderItem.FTruck);
  nlistitem.SubItems.Add(FloatToStr(nSaleOrderItem.FValue));
  if nSaleOrderItem.FPd = sFlag_Yes then
    nlistitem.SubItems.Add('��')
  else
    nlistitem.SubItems.Add('��');
  nlistitem.SubItems.Add(nSaleOrderItem.FStockArea);
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
      if SubItems[6] = sCheck then
      begin
        SubItems[6] := sUnCheck;
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
        nCanPd := nCanPd and (nInt < gSysParam.FAICMPDCount);
      end
      else
        nCanPd := True;

      if not nCanPd then
      begin
        ShowMsg('���֧��' + IntToStr(gSysParam.FAICMPDCount) +'����������ƴ��,������ѡ��', sHint);
        Exit;
      end;
      SubItems[6] := sCheck;
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

    {$IFDEF PrintHYEach}
    if nCanSave then
    begin
      for nIdx := Low(FSaleOrderItems) to High(FSaleOrderItems) do
      begin
        if FSaleOrderItems[nIdx].FPhy = sFlag_Yes then
        begin
          PrintHY.Checked := True;
        end;
      end;
    end
    else
      PrintHY.Checked := False;
    {$ENDIF}
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
var nMsg, nStr, nCard, nHint: string;
    nIdx, nInt, nNum: Integer;
    nRet, nPrint, nForce, nDriverCard: Boolean;
    nTruck: string;
    nHzValue: Double;
    nIdHttp: TIdHTTP;
    wParam: TStrings;
    ReStream: TStringStream;
    ReJo, OneJo : ISuperObject;
    ArrsJa: TSuperArray;
begin
  if GetTickCount - FLastQuery < 5 * 1000 then
  begin
    ShowMsg('�벻ҪƵ������', sHint);
    Exit;
  end;
  nInt := 0;
  BtnSave.Visible := False;
  nDriverCard := HasDriverCard(nTruck, nCard);
  for nIdx := Low(FSaleOrderItems) to High(FSaleOrderItems) do
  begin
    if FSaleOrderItems[nIdx].FSelect then
    begin
      Inc(nInt);
      nTruck := FSaleOrderItems[nIdx].FTruck;

      if IFHasSaleOrder(FSaleOrderItems[nIdx].FOrders) then
      begin
        ShowMsg('������ʹ��,�޷�����,����ϵ����Ա',sHint);
        Exit;
      end;

      {$IFDEF BusinessOnly}
      if not IsPurTruckReady(nTruck, nHint) then
      begin
        nStr := '����[%s]����δ��ɵĲɹ�����[%s],�޷��쿨';
        nStr := Format(nStr,[nTruck, nHint]);
        ShowMsg(nStr, sHint);
        Exit;
      end;
      {$ENDIF}

      if Pos('ɢ',FSaleOrderItems[nIdx].FStockName) > 0 then
      begin
        if IFHasBill(nTruck) then
        begin
          ShowMsg('��������δ��ɵ������,�޷�����,����ϵ����Ա',sHint);
          Exit;
        end;
        nHzValue := GetTruckSanMaxLadeValue(nTruck, nForce);
        if nForce and (nHzValue <= 0) then
        begin
          ShowMsg('������' + FloatToStr(nHzValue) + 'δά��,�޷�����,����ϵ����Ա',sHint);
          Exit;
        end;
      end
      else
      begin
        if gSysParam.FAICMPDCount <= 1 then
        begin
          if IFHasBill(nTruck) then
          begin
            ShowMsg('��������δ��ɵ������,�޷�����,����ϵ����Ա',sHint);
            Exit;
          end;
        end;
      end;
    end;
  end;

  if nInt = 0 then
  begin
    ShowMsg('������ѡ��1������', sHint);
    Exit;
  end;

  try
    {$IFDEF AICMVerifyGPS}
    for nIdx := Low(FSaleOrderItems) to High(FSaleOrderItems) do
    begin
      if not FSaleOrderItems[nIdx].FSelect then
        Continue;

      if not IsTruckGPSValid(FSaleOrderItems[nIdx].FTruck) then
      begin
        ShowMsg(FSaleOrderItems[nIdx].FTruck + 'δ����GPS,����ϵ����Ա', sHint);
        Exit;
      end;
    end;
    {$ENDIF}

    {$IFDEF VerifyGPSByPost}
    nStr := GetGPSUrl(nTruck, nHint);

    if nHint = sFlag_Yes then
    begin
      nidHttp := TIdHTTP.Create(nil);
      nidHttp.ConnectTimeout := cHttpTimeOut * 1000;
      nidHttp.ReadTimeout := cHttpTimeOut * 1000;
      nidHttp.Request.Clear;
      nidHttp.Request.Accept         := 'application/json, text/javascript, */*; q=0.01';
      nidHttp.Request.AcceptLanguage := 'zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3';
      nidHttp.Request.ContentType    := 'application/json;Charset=UTF-8';
      nidHttp.Request.Connection     := 'keep-alive';

      wParam   := TStringList.Create;
      ReStream := TStringstream.Create('');
      try
        nidHttp.Post(nStr, wParam, ReStream);
        nStr := UTF8Decode(ReStream.DataString);
        WriteLog('GPSУ�����:' + nStr);

        ReJo := SO(nStr);
        if ReJo = nil then Exit;

        if ReJo.I['resultCode'] <> 200 then
        begin
          ArrsJa := ReJo['data'].AsArray;
          for nIdx := 0 to ArrsJa.Length - 1 do
          begin
            OneJo := SO(ArrsJa[nIdx].AsString);
            nStr := OneJo.S['info'];
            Break;
          end;
          ShowMsg('����' + nTruck + 'GPSУ��ʧ��:[ ' + nStr + ' ]', sHint);
          Exit;
        end
        else
        begin
          ArrsJa := ReJo['data'].AsArray;
          for nIdx := 0 to ArrsJa.Length - 1 do
          begin
            OneJo := SO(ArrsJa[nIdx].AsString);
            if not OneJo.B['inFence'] then
            begin
              nStr := OneJo.S['info'];
              ShowMsg('����' + nTruck + 'GPSУ��ʧ��:[ ' + nStr + ' ]', sHint);
              Exit;
            end;
          end;
        end;
      finally
        FreeAndNil(nidHttp);
        ReStream.Free;
        wParam.Free;
      end;
    end
    else
    begin
      WriteLog('GPSǩ�������ѹر�');
    end;
    {$ENDIF}

    {$IFDEF AutoGetLineGroup}
    for nIdx := Low(FSaleOrderItems) to High(FSaleOrderItems) do
    begin
      if not FSaleOrderItems[nIdx].FSelect then
        Continue;

      if not IfHasLine(FSaleOrderItems[nIdx].FStockID, sFlag_TypeCommon,
                       FSaleOrderItems[nIdx].FStockBrand, nHint) then
      begin
        ShowMsg(nHint, sHint);
        Exit;
      end;
    end;
    {$ENDIF}

    if not nDriverCard then
    begin
      for nIdx:=0 to 3 do
      begin
        nCard := gDispenserManager.GetCardNo(gSysParam.FTTCEK720ID, nHint, False);
        if nCard <> '' then
          Break;
        Sleep(500);
      end;
      //�������ζ���,�ɹ����˳���
    end;
    if nCard = '' then
    begin
      nMsg := '�����쳣,��鿴�Ƿ��п�.';
      ShowMsg(nMsg, sWarn);
      Exit;
    end;

    WriteLog('��ȡ����Ƭ: ' + nCard);
    //������Ƭ
    if not nDriverCard then
    begin
      if not IsCardValid(nCard) then
      begin
        gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);
        nMsg := '����' + nCard + '�Ƿ�,������,���Ժ�����ȡ��';
        WriteLog(nMsg);
        ShowMsg(nMsg, sWarn);
        Exit;
      end;
    end;

    nStr := GetCardUsed(nCard);
    if (nStr = sFlag_Sale) or (nStr = sFlag_SaleNew) then
      LogoutBillCard(nCard);
    //����ҵ��ע����Ƭ,����ҵ��������ע��
    FLastQuery := GetTickCount;
    FListC.Clear;

    nInt := 0;
    for nIdx := Low(FSaleOrderItems) to High(FSaleOrderItems) do
    begin
      if not FSaleOrderItems[nIdx].FSelect then
        Continue;

      nInt := nInt + 1;

      LoadSysDictItem(sFlag_PrintBill, FListD);
      //���ӡƷ��
      nPrint := FListD.IndexOf(FSaleOrderItems[nIdx].FStockID) >= 0;

      with FListB do
      begin
        Clear;

        Values['Orders'] := EncodeBase64(FSaleOrderItems[nIdx].FOrders);
        Values['Value'] := FloatToStr(FSaleOrderItems[nIdx].FValue);                                 //������
        Values['Truck'] := FSaleOrderItems[nIdx].FTruck;
        Values['Lading'] := sFlag_TiHuo;
        Values['IsVIP'] := GetTransType(FSaleOrderItems[nIdx].FTransType);
        {$IFDEF AICMPackFromDict}
        Values['Pack'] := GetStockPackStyleEx(FSaleOrderItems[nIdx].FStockID,
                                              FSaleOrderItems[nIdx].FStockBrand);
        {$ELSE}
        Values['Pack'] := GetStockPackStyle(FSaleOrderItems[nIdx].FStockID);
        {$ENDIF}
        Values['BuDan'] := sFlag_No;
        Values['CusID'] := FSaleOrderItems[nIdx].FCusID;
        Values['CusName'] := FSaleOrderItems[nIdx].FCusName;
        Values['Brand'] := FSaleOrderItems[nIdx].FStockBrand;
        Values['StockArea'] := FSaleOrderItems[nIdx].FStockArea;
        Values['bm'] := FSaleOrderItems[nIdx].FBm;
        Values['wxzhuid'] := FSaleOrderItems[nIdx].FWxZhuId;
        Values['wxziid'] := FSaleOrderItems[nIdx].FWxZiId;
        if PrintHY.Checked  then
             Values['PrintHY'] := sFlag_Yes
        else Values['PrintHY'] := sFlag_No;
        {$IFDEF RemoteSnap}
        Values['SnapTruck'] := sFlag_Yes;
        {$ELSE}
        Values['SnapTruck'] := sFlag_No;
        {$ENDIF}
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

      nRet := False;

      nRet := SaveBillCard(nStr, nCard);

      for nNum := 0 to 2 do
      begin
        if GetBillCard(nStr) = nCard then
        begin
          nRet := True;
          Break;
        end;

        Sleep(200);
        nRet := False;

        nRet := SaveBillCard(nStr, nCard);
      end;
      if nRet and nPrint then
        FListC.Add(nStr);
      //SaveWebOrderMatch(nStr,FSaleOrderItems[nIdx].FOrders,sFlag_Sale);
    end;

    if not nRet then
    begin
      nMsg := '����ſ�ʧ��,������.';
      ShowMsg(nMsg, sHint);
      Exit;
    end;

    if not nDriverCard then
    nRet := gDispenserManager.SendCardOut(gSysParam.FTTCEK720ID, nHint);
    //����

    if nRet then
    begin
      nMsg := '�����[ %s ]�����ɹ�,����[ %s ],���պ����Ŀ�Ƭ';
      nMsg := Format(nMsg, [nStr, nCard]);

      WriteLog(nMsg);
      ShowMsg(nMsg,sWarn);

      for nIdx := 0 to FListC.Count - 1 do
      begin
        PrintBillReport(FListC.Strings[nIdx], False);
        Sleep(200);
      end;

      {$IFDEF PrintHyOnSaveBill}
      for nIdx := 0 to FListC.Count - 1 do
      begin
        PrintHuaYanReportWhenSaveBill(FListC.Strings[nIdx], nMsg, gSysParam.FHYDanPrinter);

        if nMsg <> '' then
          ShowMsg(nMsg, sHint);
        Sleep(200);
      end;
      {$ENDIF}
    end
    else begin
      if not nDriverCard then
      gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);

      nMsg := '����[ %s ]��������ʧ��,�뵽��Ʊ�������¹���.';
      nMsg := Format(nMsg, [nCard]);

      WriteLog(nMsg);
      ShowMsg(nMsg,sWarn);
    end;

    gTimeCounter := 0;
  finally
    BtnSave.Visible := True;
  end;
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
