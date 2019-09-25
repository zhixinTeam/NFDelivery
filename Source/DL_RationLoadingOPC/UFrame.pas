unit UFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, StdCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, ULEDFont, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  cxTextEdit, cxLabel, cxMaskEdit, cxDropDownEdit, UMgrdOPCTunnels,
  ExtCtrls, IdTCPServer, IdContext, IdGlobal, UBusinessConst, ULibFun,
  Menus, cxButtons, UMgrSendCardNo, USysLoger, cxCurrencyEdit, dxSkinsCore,
  dxSkinsDefaultPainters, cxSpinEdit, DateUtils, dOPCIntf, dOPCComn,
  dOPCDA, dOPC, Activex;

type
  TFrame1 = class(TFrame)
    ToolBar1: TToolBar;
    ToolButton2: TToolButton;
    btnPause: TToolButton;
    ToolButton6: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton1: TToolButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    EditValue: TLEDFontNum;
    GroupBox3: TGroupBox;
    cxLabel4: TcxLabel;
    EditBill: TcxComboBox;
    cxLabel5: TcxLabel;
    EditTruck: TcxComboBox;
    cxLabel7: TcxLabel;
    EditCusID: TcxComboBox;
    cxLabel8: TcxLabel;
    EditStockID: TcxComboBox;
    cxLabel6: TcxLabel;
    EditMaxValue: TcxTextEdit;
    cxLabel1: TcxLabel;
    editPValue: TcxTextEdit;
    cxLabel2: TcxLabel;
    editZValue: TcxTextEdit;
    editNetValue: TLEDFontNum;
    editBiLi: TLEDFontNum;
    cxLabel3: TcxLabel;
    cxLabel9: TcxLabel;
    BtnStop: TButton;
    BtnStart: TButton;
    dOPCServer: TdOPCServer;
    StateTimer: TTimer;
    MemoLog: TMemo;
    cxLabel10: TcxLabel;
    EditUseTime: TcxTextEdit;
    DelayTimer: TTimer;
    procedure BtnStopClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure StateTimerTimer(Sender: TObject);
    procedure DelayTimerTimer(Sender: TObject);
  private
    { Private declarations }
    FCardUsed: string;            //��Ƭ����
    FUIData: TLadingBillItem;     //��������
    FOPCTunnel: PPTOPCItem;       //OPCͨ��
    FCard: string;
    FHasDone, FSetValue, FUseTime: Double;
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //���ý�������
    procedure SetTunnel(const Value: PPTOPCItem);
    procedure WriteLog(const nEvent: string);
    procedure OnDatachange(Sender: TObject; ItemList: TdOPCItemList);
    procedure SyncReadValues(const FromCache: boolean);
  public
    FrameId:Integer;              //PLCͨ��
    FIsBusy: Boolean;             //ռ�ñ�ʶ
    FSysLoger : TSysLoger;
    property OPCTunnel: PPTOPCItem read FOPCTunnel write SetTunnel;
    procedure LoadBillItems(const nCard: string);
    //��ȡ������
    procedure StopPound;
  end;

implementation

{$R *.dfm}

uses
   USysBusiness, USysDB, USysConst, UDataModule, UFormInputbox, UFormCtrl;

//Parm: �ſ��򽻻�����
//Desc: ��ȡnCard��Ӧ�Ľ�����
procedure TFrame1.LoadBillItems(const nCard: string);
var
  nStr: string;
  nBills: TLadingBillItems;
  nRet,nHisMValueControl: Boolean;
  nOPCServer: TdOPCServer;
  nGroup: TdOPCGroup;
  nIdx: Integer;
  nVal, nPreKD: Double;
  nEvent,nEID:string;
begin
  if DelayTimer.Enabled then
  begin
    nStr := '����Ƶ��ˢ��';
    WriteLog(nStr);
    LineClose(FOPCTunnel.FID, sFlag_Yes);
    ShowLedText(FOPCTunnel.FID, nStr);
    SetUIData(True);
    Exit;
  end;

  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['ClearLj']) = sFlag_Yes) then
  begin
    if StrToFloatDef(EditValue.Text, 0) > 0.1 then
    begin
      nStr := '������ۼ���';
      WriteLog(nStr);
      LineClose(FOPCTunnel.FID, sFlag_Yes);
      ShowLedText(FOPCTunnel.FID, nStr);
      SetUIData(True);
      Exit;
    end;
  end;

  WriteLog('���յ�����:' + nCard);
  FCard := nCard;

  nRet := GetLadingBills(nCard, sFlag_TruckBFP, nBills);

  if (not nRet) or (Length(nBills) < 1) then
  begin
    nStr := '��ȡ�ſ���Ϣʧ��,����ϵ����Ա';
    WriteLog(nStr);
    SetUIData(True);
    Exit;
  end;

  //��ȡ�������ֵ
  //nBills[0].FMData.FValue := StrToFloatDef(GetLimitValue(nBills[0].FTruck),0);

  FUIData := nBills[0];

  FHasDone := ReadDoneValue(FUIData.FID, FUseTime);

  FSetValue := FUIData.FValue;

  nVal := GetSanMaxLadeValue;
  if (nVal > 0) and (FUIData.FValue > nVal) then//����������ϵͳ�趨�����
  begin
    FSetValue := nVal;
    nEvent := '����[ %s ]������[ %s ],' +
              '������[ %.2f ]����ϵͳ�趨�����[ %.2f ],�����󿪵���[ %.2f ].';
    nEvent := Format(nEvent, [FUIData.FTruck, FUIData.FID,
                              FUIData.FValue, nVal, nVal]);
    WriteLog(nEvent);
  end;

  nVal := ReadTruckHisMValueMax(FUIData.FTruck);
  nPreKD := GetSanPreKD;

  nHisMValueControl := False;
  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['HisMValueControl']) = sFlag_Yes) then
    nHisMValueControl := True;

  if nHisMValueControl and (nVal > 0) and
  ((FUIData.FPData.FValue + FUIData.FValue) > nVal) then
  begin
    FSetValue := nVal - FUIData.FPData.FValue - nPreKD;

    //�����¼�
    if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['SendMsg']) = sFlag_Yes) then
    begin
      try
        nEID := FUIData.FID + 'H';
        nStr := 'Delete From %s Where E_ID=''%s''';
        nStr := Format(nStr, [sTable_ManualEvent, nEID]);

        FDM.ExecuteSQL(nStr);

        nEvent := '����[ %s ]������[ %s ]װ�����ѵ���,��ʷ���ë��[ %.2f ],' +
                  '��ǰƤ��[ %.2f ],������[ %.2f ],Ԥ����[ %.2f ],������װ����[ %.2f ].';
        nEvent := Format(nEvent, [FUIData.FTruck, FUIData.FID, nVal,
                                  FUIData.FPData.FValue, FUIData.FValue,
                                  nPreKD, FSetValue]);
        WriteLog(nEvent);
        nStr := MakeSQLByStr([
            SF('E_ID', nEID),
            SF('E_Key', ''),
            SF('E_From', sFlag_DepJianZhuang),
            SF('E_Event', nEvent),
            SF('E_Solution', sFlag_Solution_OK),
            SF('E_Departmen', sFlag_DepDaTing),
            SF('E_Date', sField_SQLServer_Now, sfVal)
            ], sTable_ManualEvent, '', True);
        FDM.ExecuteSQL(nStr);
      except
        on E: Exception do
        begin
          WriteLog('�����¼�ʧ��:' + e.message);
        end;
      end;
    end;

  end
  else
  begin
    if (FUIData.FValue - nPreKD) > 0 then
    begin
      FSetValue := FUIData.FValue - nPreKD;

      nEvent := '����[ %s ]������[ %s ],' +
                '������[ %.2f ],Ԥ����[ %.2f ],������װ����[ %.2f ].';
      nEvent := Format(nEvent, [FUIData.FTruck, FUIData.FID,
                                FUIData.FValue, nPreKD, FSetValue]);
      WriteLog(nEvent);
    end;
  end;

  if FHasDone >= FSetValue then
  begin
    nStr := '������[ %s ]������[ %.2f ],��װ��[ %.2f ],�޷�����װ��';
    nStr := Format(nStr, [FUIData.FID, FSetValue, FHasDone]);
    WriteLog(nStr);
    LineClose(FOPCTunnel.FID, sFlag_Yes);
    ShowLedText(FOPCTunnel.FID, 'װ�����Ѵﵽ������');
    SetUIData(True);
    Exit;
  end;

  EditValue.Text := Format('%.2f', [FHasDone]);

  SetUIData(False);

  try
    CoInitialize(nil);
    nOPCServer := TdOPCServer.Create(nil);

    nOPCServer.ServerName  := FOPCTunnel.FServer;
    nOPCServer.ComputerName:= FOPCTunnel.FComputer;

    nGroup := nOPCServer.OPCGroups.Add('Group');         // make a new group
    nGroup.IsActive := False;

    nGroup.OPCItems.AddItem(FOPCTunnel.FSetValTag);

    nOPCServer.Active := true;

    nGroup.OPCItems[0].WriteSync(FSetValue - FHasDone);
    WriteLog(FOPCTunnel.FID +'���������:'+ FloatToStr(FSetValue - FHasDone));
    LineClose(FOPCTunnel.FID, sFlag_No);
    WriteLog(FOPCTunnel.FID +'������������ɹ�');
    StateTimer.Tag := 0;
  finally
    if Assigned(nOPCServer) then
      nOPCServer.Free;
    CoUninitialize;                        // !!!!!!!!!!!!!
  end;
end;

procedure TFrame1.SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
var
  nItem: TLadingBillItem;
begin
  if nReset then
  begin
    FillChar(nItem, SizeOf(nItem), #0);
    nItem.FFactory := gSysParam.FFactNum;

    FUIData := nItem;
    if nOnlyData then Exit;

    EditValue.Text := '0.00';
    editNetValue.Text := '0.00';
    editBiLi.Text := '0';
    EditUseTime.Text := '0';
    EditBill.Properties.Items.Clear;
  end;

  with FUIData do
  begin
    EditBill.Text := FID;
    EditTruck.Text := FTruck;
    EditStockID.Text := FStockName;
    EditCusID.Text := FCusName;

    EditMaxValue.Text := Format('%.2f', [FMData.FValue]);
    EditPValue.Text := Format('%.2f', [FPData.FValue]);
    EditZValue.Text := Format('%.2f', [FValue]);
  end;
end;

procedure TFrame1.WriteLog(const nEvent: string);
begin
  if MemoLog.Lines.Count > 100 then
    MemoLog.Clear;
  MemoLog.Lines.Add(nEvent);
  FSysLoger.AddLog(TFrame, '����װ��OPC����Ԫ', nEvent);
end;

procedure TFrame1.SetTunnel(const Value: PPTOPCItem);
begin
  FOPCTunnel := Value;
  SetUIData(true);
end;

procedure TFrame1.StopPound;
var
  nItemList: TdOPCItemList;
  nOPCServer: TdOPCServer;
  nGroup: TdOPCGroup;
  nIdx: Integer;
begin
  if DelayTimer.Enabled then
  begin
    Exit;
  end;
  DelayTimer.Tag := 0;
  DelayTimer.Enabled := True;

  SaveDoneValue(FUIData.FID, StrToFloatDef(EditValue.Text, 0)
                ,StrToFloatDef(EditUseTime.Text, 0));

  FHasDone := 0;
  FUseTime := 0;
  LineClose(FOPCTunnel.FID, sFlag_Yes);
  SetUIData(true);

  if Trim(FOPCTunnel.FStopTag) <> '' then
  begin
    try
      CoInitialize(nil);
      nOPCServer := TdOPCServer.Create(nil);

      nOPCServer.ServerName  := FOPCTunnel.FServer;
      nOPCServer.ComputerName:= FOPCTunnel.FComputer;

      nGroup := nOPCServer.OPCGroups.Add('Group');         // make a new group
      nGroup.IsActive := False;

      nGroup.OPCItems.AddItem(FOPCTunnel.FStopTag);

      nOPCServer.Active := true;

      nGroup.OPCItems[0].WriteSync(FOPCTunnel.FStopOrder);

      WriteLog(FOPCTunnel.FID +'����ֹͣ����ɹ�');
    finally
      if Assigned(nOPCServer) then
        nOPCServer.Free;
      CoUninitialize;                        // !!!!!!!!!!!!!
    end;
  end;
end;

procedure TFrame1.BtnStopClick(Sender: TObject);
begin
  try
    StopPound;
  except
    on E: Exception do
    begin
      WriteLog('ͨ��' + FOPCTunnel.FID + 'ֹͣ����ʧ��,ԭ��:' + e.Message);
    end;
  end;
end;

procedure TFrame1.BtnStartClick(Sender: TObject);
var nStr: string;
begin
  nStr := FCard;
  if not ShowInputBox('������ſ���:', '��ʾ', nStr) then Exit;
  try
    LoadBillItems(nStr);
  except
    on E: Exception do
    begin
      WriteLog('ͨ��' + FOPCTunnel.FID + '��������ʧ��,ԭ��:' + e.Message);
    end;
  end;
end;

procedure TFrame1.SyncReadValues(const FromCache: boolean);
var
  nItemList: TdOPCItemList;
  nOPCServer: TdOPCServer;
  nGroup: TdOPCGroup;
begin
  CoInitialize(nil);
  nOPCServer := TdOPCServer.Create(nil);
  try
    nOPCServer.ServerName  := FOPCTunnel.FServer;
    nOPCServer.ComputerName:= FOPCTunnel.FComputer;

    nGroup := nOPCServer.OPCGroups.Add('Group');         // make a new group

    nGroup.OPCItems.AddItem(FOPCTunnel.FImpDataTag);

    if FOPCTunnel.FUseTimeTag <> '' then
    nGroup.OPCItems.AddItem(FOPCTunnel.FUseTimeTag);

    nOPCServer.Active := true;

    nGroup.SyncRead(nil,FromCache);
    //nGroup.ASyncRead(nil);
    nItemList := TdOPCItemList.create(nGroup.OPCItems);
    try
      OnDatachange(self,nItemList);
    except

    end;
  finally
    if Assigned(nItemList) then
      nItemList.Free;
    if Assigned(nOPCServer) then
      nOPCServer.Free;
    CoUninitialize;                        // !!!!!!!!!!!!!
  end;
end;

procedure TFrame1.OnDatachange(Sender: TObject;
  ItemList: TdOPCItemList);
var
  nIdx: Integer;
  nValue: Double;
  nZValue, nBiLi : Double;
begin
  for nIdx := 0 to Itemlist.Count-1 do
  begin
    if Itemlist[nIdx].ItemId = FOPCTunnel.FImpDataTag then
    begin
      WriteLog(FOPCTunnel.FImpDataTag+':'+Itemlist[nIdx].ValueStr);
      if IsNumber(Itemlist[nIdx].ValueStr, True) then
      begin
        nValue := StrToFloat(Itemlist[nIdx].ValueStr) + FHasDone;
        EditValue.Text := Format('%.2f', [nValue]);
        if (Length(Trim(EditBill.Text)) > 0) and (nValue > 0) then
          ShowLedText(FOPCTunnel.FID, '��ǰ�ۼ�����:'+ EditValue.Text);

        nZValue := StrToFloatDef(editZValue.Text,0);    //Ʊ��

        nBiLi := 0;
        if nZValue > 0 then
          nBiLi := nValue/nZValue *100;                //��ɱ���

        editNetValue.Text := EditValue.Text;
        editBiLi.Text := Format('%.2f',[nBiLi]);
      end;
    end
    else
    if Itemlist[nIdx].ItemId = FOPCTunnel.FUseTimeTag then
    begin
      if IsNumber(Itemlist[nIdx].ValueStr, True) then
      begin
        nValue := StrToFloat(Itemlist[nIdx].ValueStr) + FUseTime;
        EditUseTime.Text := Format('%.2f', [nValue]);
      end;
    end;
  end;
end;

procedure TFrame1.StateTimerTimer(Sender: TObject);
begin
  StateTimer.Enabled := False;
  StateTimer.Tag := StateTimer.Tag + 1;
  try
    SyncReadValues(False);
  except
    on E: Exception do
    begin
      WriteLog('ͨ��' + fOPCTunnel.FID + '��ȡ�ۼ�����ʧ��,ԭ��:' + e.Message);
    end;
  end;
  StateTimer.Enabled := True;
end;

procedure TFrame1.DelayTimerTimer(Sender: TObject);
begin
  DelayTimer.Tag := DelayTimer.Tag + 1;
  if DelayTimer.Tag >= 10 then
  begin
    DelayTimer.Enabled := False;
  end;
end;

end.
