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
  dOPCDA, dOPC, Activex, StrUtils, USysConst;

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
    FCardUsed: string;            //卡片类型
    FUIData: TLadingBillItem;     //界面数据
    FOPCTunnel: PPTOPCItem;       //OPC通道
    FHasDone, FSetValue, FUseTime: Double;
    FDataLarge: Double;//放大倍数
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //设置界面数据
    procedure SetTunnel(const Value: PPTOPCItem);
    procedure WriteLog(const nEvent: string);
    procedure OnDatachange(Sender: TObject; ItemList: TdOPCItemList);
    procedure SyncReadValues(const FromCache: boolean);
    procedure Get_Card_Message(var Message: TMessage); message WM_HAVE_CARD ;
  public
    FrameId:Integer;              //PLC通道
    FIsBusy: Boolean;             //占用标识
    FSysLoger : TSysLoger;
    FCard: string;
    property OPCTunnel: PPTOPCItem read FOPCTunnel write SetTunnel;
    procedure LoadBillItems(const nCard: string);
    //读取交货单
    procedure StopPound;
  end;

implementation

{$R *.dfm}

uses
   USysBusiness, USysDB, UDataModule, UFormInputbox, UFormCtrl, main;

procedure TFrame1.Get_Card_Message(var Message: TMessage);
Begin
  EditBill.Text := FCard;
  LoadBillItems(EditBill.Text);
End ;

//Parm: 磁卡或交货单号
//Desc: 读取nCard对应的交货单
procedure TFrame1.LoadBillItems(const nCard: string);
var
  nStr,nTruck: string;
  nBills: TLadingBillItems;
  nRet,nHisMValueControl: Boolean;
  nIdx,nSendValue: Integer;
  nVal, nPreKD: Double;
  nEvent,nEID:string;
  nItem : TdOPCItem;
begin
  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['SendToPlc']) = sFlag_Yes) then
  begin
    WriteLog('非OPC启动,退出操作');
    Exit;
  end;
  if DelayTimer.Enabled then
  begin
    nStr := '请勿频繁刷卡';
    WriteLog(nStr);
    LineClose(FOPCTunnel.FID, sFlag_Yes);
    ShowLedText(FOPCTunnel.FID, nStr);
    SetUIData(True);
    Exit;
  end;
  FDataLarge := 1;

  if Assigned(FOPCTunnel.FOptions) And
       (IsNumber(FOPCTunnel.FOptions.Values['DataLarge'], True)) then
  begin
    FDataLarge := StrToFloat(FOPCTunnel.FOptions.Values['DataLarge']);
  end;

  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['ClearLj']) = sFlag_Yes) then
  begin
    if StrToFloatDef(EditValue.Text, 0) > 0.1 then
    begin
      nStr := '请清除累计量';
      WriteLog(nStr);
      LineClose(FOPCTunnel.FID, sFlag_Yes);
      ShowLedText(FOPCTunnel.FID, nStr);
      SetUIData(True);
      Exit;
    end;
  end;

  WriteLog('接收到卡号:' + nCard);
  FCard := nCard;

  nRet := GetLadingBills(nCard, sFlag_TruckBFP, nBills);

  if (not nRet) or (Length(nBills) < 1) then
  begin
    nStr := '读取磁卡信息失败,请联系管理员';
    WriteLog(nStr);
    SetUIData(True);
    Exit;
  end;

  //获取最大限载值
  //nBills[0].FMData.FValue := StrToFloatDef(GetLimitValue(nBills[0].FTruck),0);

  FUIData := nBills[0];

  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['NoHasDone']) = sFlag_Yes) then
    FHasDone := 0
  else
    FHasDone := ReadDoneValue(FUIData.FID, FUseTime);

  FSetValue := FUIData.FValue;

  nHisMValueControl := False;
  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['TruckHzValueControl']) = sFlag_Yes) then
    nHisMValueControl := True;

  if nHisMValueControl then
  begin
    nVal := GetTruckSanMaxLadeValue(FUIData.FTruck);
    if (nVal > 0) and (FUIData.FValue > nVal) then//开单量大于系统设定最大量
    begin
      EditMaxValue.Text := Format('%.2f', [nVal]);
      FSetValue := nVal;
      nEvent := '车辆[ %s ]交货单[ %s ],' +
                '开单量[ %.2f ]大于核载量[ %.2f ],调整后开单量[ %.2f ].';
      nEvent := Format(nEvent, [FUIData.FTruck, FUIData.FID,
                                FUIData.FValue, nVal, nVal]);
      WriteLog(nEvent);
    end;
  end;

  nVal := GetSanMaxLadeValue;
  if (nVal > 0) and (FUIData.FValue > nVal) then//开单量大于系统设定最大量
  begin
    EditMaxValue.Text := Format('%.2f', [nVal]);
    FSetValue := nVal;
    nEvent := '车辆[ %s ]交货单[ %s ],' +
              '开单量[ %.2f ]大于系统设定最大量[ %.2f ],调整后开单量[ %.2f ].';
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

    //生成事件
    if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['SendMsg']) = sFlag_Yes) then
    begin
      try
        nEID := FUIData.FID + 'H';
        nStr := 'Delete From %s Where E_ID=''%s''';
        nStr := Format(nStr, [sTable_ManualEvent, nEID]);

        FDM.ExecuteSQL(nStr);

        nEvent := '车辆[ %s ]交货单[ %s ]装车量已调整,历史最大毛重[ %.2f ],' +
                  '当前皮重[ %.2f ],开单量[ %.2f ],预扣量[ %.2f ],调整后装车量[ %.2f ].';
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
          WriteLog('保存事件失败:' + e.message);
        end;
      end;
    end;
  end
  else
  begin
    if (FUIData.FValue - nPreKD) > 0 then
    begin
      FSetValue := FSetValue - nPreKD;

      nEvent := '车辆[ %s ]交货单[ %s ],' +
                '开单量[ %.2f ],预扣量[ %.2f ],调整后装车量[ %.2f ].';
      nEvent := Format(nEvent, [FUIData.FTruck, FUIData.FID,
                                FUIData.FValue, nPreKD, FSetValue]);
      WriteLog(nEvent);
    end;
  end;

  if FHasDone >= FSetValue then
  begin
    nStr := '交货单[ %s ]设置量[ %.2f ],已装量[ %.2f ],无法继续装车';
    nStr := Format(nStr, [FUIData.FID, FSetValue, FHasDone]);
    WriteLog(nStr);
    LineClose(FOPCTunnel.FID, sFlag_Yes);
    ShowLedText(FOPCTunnel.FID, '装车量已达到设置量');
    SetUIData(True);
    Exit;
  end;

  EditValue.Text := Format('%.2f', [FHasDone]);
  SetUIData(False);

  try
    if FDataLarge > 0 then
    begin
      nSendValue := Round((FSetValue - FHasDone)/ FDataLarge);
      FormMain.gOPCServer.OPCGroups[FrameId].OPCItems[0].WriteSync(nSendValue);

      WriteLog(FOPCTunnel.FID +'发送提货量:'+ IntToStr(nSendValue));
    end
    else
    begin
      FormMain.gOPCServer.OPCGroups[FrameId].OPCItems[0].WriteSync(FSetValue - FHasDone);

      WriteLog(FOPCTunnel.FID +'发送提货量:'+ FloatToStr(FUIData.FValue - FHasDone));
    end;
    if Trim(FOPCTunnel.FTruckTag) <> '' then
    begin
      nItem := FormMain.gOPCServer.OPCGroups[FrameId].OPCItems.FindOPCItem(FOPCTunnel.FTruckTag);
      if nItem <> nil then
      begin
        nTruck := '';
        nStr := FUIData.FTruck;
        for nIdx := 1 to Length(nStr) do
        begin
          if IsNumber(nStr[nIdx], False) then
            nTruck := nTruck + nStr[nIdx];
        end;
        if nTruck <> '' then
        begin
          nItem.WriteSync(nTruck);
          WriteLog(FOPCTunnel.FID +'发送车牌号:'+ FUIData.FTruck + '格式化后:' + nTruck);
        end;
      end;
    end;

    if Trim(FOPCTunnel.FStartTag) <> '' then
    begin
      for nIdx := 1 to 30 do
      begin
        Sleep(100);
        Application.ProcessMessages;
      end;

      FormMain.gOPCServer.OPCGroups[FrameId].OPCItems[2].WriteSync(FOPCTunnel.FStartOrder);
      for nIdx := 1 to 30 do
      begin
        Sleep(100);
        Application.ProcessMessages;
      end;
      FormMain.gOPCServer.OPCGroups[FrameId].OPCItems[2].WriteSync(FOPCTunnel.FStopOrder);
    end;

    LineClose(FOPCTunnel.FID, sFlag_No);
    WriteLog(FOPCTunnel.FID +'发送启动命令成功');
    StateTimer.Tag := 0;
  except
    on E: Exception do
    begin
      StopPound;
      WriteLog(FOPCTunnel.FID +'启动失败,原因为:' + e.Message);
      ShowLedText(FOPCTunnel.FID, '启动失败,请重新刷卡');
    end;
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

    //EditMaxValue.Text := Format('%.2f', [FMData.FValue]);
    EditPValue.Text := Format('%.2f', [FPData.FValue]);
    EditZValue.Text := Format('%.2f', [FValue]);
  end;
end;

procedure TFrame1.WriteLog(const nEvent: string);
begin
  if MemoLog.Lines.Count > 100 then
    MemoLog.Clear;
  MemoLog.Lines.Add(nEvent);
  FSysLoger.AddLog(TFrame, '定置装车OPC主单元', nEvent);
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
  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['SendToPlc']) = sFlag_Yes) then
  begin
    WriteLog('非OPC启动,退出操作');
    Exit;
  end;
  if DelayTimer.Enabled then
  begin
    Exit;
  end;
  DelayTimer.Tag := 0;
  DelayTimer.Enabled := True;

  FHasDone := 0;
  FUseTime := 0;
  LineClose(FOPCTunnel.FID, sFlag_Yes);
  SetUIData(true);

  if Trim(FOPCTunnel.FStopTag) <> '' then
  begin
    FormMain.gOPCServer.OPCGroups[FrameId].OPCItems[3].WriteSync(FOPCTunnel.FStartOrder);
    for nIdx := 1 to 30 do
    begin
      Sleep(100);
      Application.ProcessMessages;
    end;
    FormMain.gOPCServer.OPCGroups[FrameId].OPCItems[3].WriteSync(FOPCTunnel.FStopOrder);

    WriteLog(FOPCTunnel.FID +'发送停止命令成功');
  end;
end;

procedure TFrame1.BtnStopClick(Sender: TObject);
begin
  try
    StopPound;
  except
    on E: Exception do
    begin
      WriteLog('通道' + FOPCTunnel.FID + '停止称重失败,原因:' + e.Message);
    end;
  end;
end;

procedure TFrame1.BtnStartClick(Sender: TObject);
var nStr: string;
begin
  nStr := FCard;
  if not ShowInputBox('请输入磁卡号:', '提示', nStr) then Exit;
  try
    LoadBillItems(nStr);
  except
    on E: Exception do
    begin
      WriteLog('通道' + FOPCTunnel.FID + '启动称重失败,原因:' + e.Message);
    end;
  end;
end;

procedure TFrame1.SyncReadValues(const FromCache: boolean);
var
  nItemList: TdOPCItemList;
begin
  nItemList := TdOPCItemList.create(FormMain.gOPCServer.OPCGroups[FrameId].OPCItems);
  try
    FormMain.gOPCServer.OPCGroups[FrameId].SyncRead(nil,FromCache);
    //nGroup.ASyncRead(nil);
    Application.ProcessMessages;
    try
      OnDatachange(self,nItemList);
    except

    end;
  finally
    if Assigned(nItemList) then
      nItemList.Free;                       // !!!!!!!!!!!!!
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
        nValue := (StrToFloat(Itemlist[nIdx].ValueStr) + FHasDone) * FDataLarge;
        EditValue.Text := Format('%.2f', [nValue]);
        if (Length(Trim(EditBill.Text)) > 0) and (nValue > 0) then
        begin
          SaveDoneValue(FUIData.FID, StrToFloatDef(EditValue.Text, 0)
                ,StrToFloatDef(EditUseTime.Text, 0));
          ShowLedText(FOPCTunnel.FID, '当前累计重量:'+ EditValue.Text);
        end;

        nZValue := StrToFloatDef(editZValue.Text,0);    //票重

        nBiLi := 0;
        if nZValue > 0 then
          nBiLi := nValue/nZValue *100;                //完成比例

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
var nInfo: string;
    nList: TStrings;
    nItem : TdOPCItem;
begin
  StateTimer.Enabled := False;
  StateTimer.Tag := StateTimer.Tag + 1;
  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['SendToPlc']) = sFlag_Yes) then
  begin
    try
      WriteLog('读取库底计量');
      if not ReadBaseWeight(FOPCTunnel.FID, nInfo) then
      begin
        StateTimer.Enabled := True;
        Exit;
      end;
      WriteLog('库底计量:' + nInfo);
      nList := TStringList.Create;
      try
        nList.Text := nInfo;
        EditBill.Text := nList.Values['Bill'];
        editPValue.Text := nList.Values['PValue'];
        EditValue.Text := nList.Values['ValueMax'];
        editZValue.Text := nList.Values['Value'];

        if EditBill.Text <> '' then
        begin
          FormMain.gOPCServer.OPCGroups[FrameId].OPCItems[0].WriteSync(editZValue.Text);

          WriteLog(FOPCTunnel.FID +'发送提货量:'+ editZValue.Text);

          FormMain.gOPCServer.OPCGroups[FrameId].OPCItems[1].WriteSync(EditValue.Text);

          WriteLog(FOPCTunnel.FID +'发送地磅重量:'+ EditValue.Text);

          if Trim(FOPCTunnel.FTruckTag) <> '' then
          begin
            nItem := FormMain.gOPCServer.OPCGroups[FrameId].OPCItems.FindOPCItem(FOPCTunnel.FTruckTag);
            if nItem <> nil then
            begin
              nItem.WriteSync(editPValue.Text);
              WriteLog(FOPCTunnel.FID +'发送皮重:'+ editPValue.Text);
            end;
          end;
        end;
      finally
        nList.Free;
      end;
    except
      on E: Exception do
      begin
        WriteLog(e.Message);
      end;
    end;
  end
  else
  begin
    try
      SyncReadValues(False);
    except
      on E: Exception do
      begin
        WriteLog('通道' + fOPCTunnel.FID + '读取累计数据失败,原因:' + e.Message);
      end;
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
