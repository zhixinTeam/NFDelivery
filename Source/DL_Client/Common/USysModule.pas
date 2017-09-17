{*******************************************************************************
  ����: dmzn@163.com 2009-6-25
  ����: ��Ԫģ��

  ��ע: ����ģ������ע������,ֻҪUsesһ�¼���.
*******************************************************************************}
unit USysModule;

{$I Link.Inc}
interface

uses
  UClientWorker, UMITPacker, UFormOptions,
  UFrameLog, UFrameSysLog, UFormIncInfo, UFormBackupSQL, UFormRestoreSQL,
  UFormPassword, UFrameAuthorize, UFormAuthorize, UFrameTrucks, UFormTruck,
  UFrameReqSale, UFrameReqProvide, UFrameReqDispatch, UFramePMaterails,
  UFormPMaterails,UFramePProvider, UFormPProvider, UFormGetTruck, UFormGetZhiKa,
  UFormGetCustom, UFormBill, UFrameBill, UFormTruckIn, UFormTruckOut,
  UFormLadingSan, UFormLadingDai, UFrameBillCard, UFormCard, UFramePoundManual,
  UFrameTruckQuery, UFrameQueryDiapatch, UFrameQuerySaleDetail, UFrameZTDispatch,
  UFormZTLine, UFramePoundQuery, UFormRFIDCard, UFormCustomer, UFrameCustomer,
  UFormChangeTunnel, UFrameDeduct, UFormDeduct, UFormGetNCStock, UFrameMine,
  UFormMine, UFormGetMine, UFormPoundDispatch, UFrameBatcodeQuery,
  UFormBatcodeEdit, UFramePoundAuto, UFrameQueryProvideDetail,
  UFrameQueryDiapatchDetail, UFormBillNew, UFrameBillNew,
  UFrameBatcodeJ, UFormBatcodeJ, UFormTodo, UFormTodoSend, UFrameTodo,

  UFormProvCard, UFormProvBase, UFrameProvBase, UFrameProvTruckDetail,
  UFrameQueryProvDetail, UFormPurchasing,
  UFormTransfer, UFormTransferCard, UFrameQueryTransferDetail,
  //ԭ���ƿ�����ʱҵ��

  UFramePoundStation, UFrameStationPQuery, UFrameStationPQueryImport,
  UFrameStationStandard, UFormStationStandard,
  //�𳵺�ҵ��

  UFrameCardProvide, UFormCardProvide, UFrameCardProPQuery, UFormCardInfo,
  UFrameCardTemp, UFormCardTemp, UFrameCardTmpPQuery,
  UFormReadCard,
  //��ͷҵ��
  UFormShipPound, UFormShipProvide,
  //�����밶��
  UFormpoundAdjust,
  //��������
  UFramePoundMtAuto,UFramePoundMtAutoItem,UFramePoundMtQuery,
  //��ͷץ����
  UFrameBillHaulBack, UFormBillHaulBack, UFormGetPoundHis
  {$IFDEF PrintChinese},
  UFrameChineseBase, UFormChineseBase, UFrameChineseDict ,UFormChineseDict,
  UFormGetAreaTo
  {$ENDIF};

procedure InitSystemObject;
procedure RunSystemObject;
procedure FreeSystemObject;

implementation

uses
  UMgrChannel, UChannelChooser, UDataModule, USysDB, USysMAC, SysUtils,
  USysLoger, USysConst, UMemDataPool, UMgrLEDDisp, UFormBase, UMgrRemotePrint;

//Desc: ��ʼ��ϵͳ����
procedure InitSystemObject;
begin
  if not Assigned(gSysLoger) then
    gSysLoger := TSysLoger.Create(gPath + sLogDir);
  //system loger

  if not Assigned(gMemDataManager) then
    gMemDataManager := TMemDataManager.Create;
  //Memory Manager

  gChannelManager := TChannelManager.Create;
  gChannelManager.ChannelMax := 20;
  gChannelChoolser := TChannelChoolser.Create('');
  gChannelChoolser.AutoUpdateLocal := False;
  //channel

  if FileExists(gPath + cDisp_Config) then
    gDisplayManager.LoadConfig(gPath + cDisp_Config);
  //LED DisPlay
end;

//Desc: ����ϵͳ����
procedure RunSystemObject;
var nStr: string;
begin
  with gSysParam do
  begin
    FLocalMAC   := MakeActionID_MAC;
    GetLocalIPConfig(FLocalName, FLocalIP);
  end;

  nStr := 'Select W_Factory,W_Serial,W_Departmen,W_HardUrl,W_MITUrl From %s ' +
          'Where W_MAC=''%s'' And W_Valid=''%s''';
  nStr := Format(nStr, [sTable_WorkePC, gSysParam.FLocalMAC, sFlag_Yes]);

  with FDM.QueryTemp(nStr),gSysParam do
  if RecordCount > 0 then
  begin
    FFactNum := Fields[0].AsString;
    FSerialID := Fields[1].AsString;

    FDepartment := Fields[2].AsString;
    FHardMonURL := Trim(Fields[3].AsString);
    FMITServURL := Trim(Fields[4].AsString);
  end;

  //----------------------------------------------------------------------------
  with gSysParam do
  begin
    FPoundDaiZ := 0;
    FPoundDaiF := 0;
    FPoundSanF := 0;
    FPoundTruck:= 0;

    FPoundPZ := 0;
    FPoundPF := 0;
    FDaiWCStop := False;
    FDaiPercent := False;
  end;

  nStr := 'Select D_Value,D_Memo From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundWuCha]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := Fields[1].AsString;
      if nStr = sFlag_PDaiWuChaZ then
        gSysParam.FPoundDaiZ := Fields[0].AsFloat;
      //xxxxx

      if nStr = sFlag_PDaiWuChaF then
        gSysParam.FPoundDaiF := Fields[0].AsFloat;
      //xxxxx

      if nStr = sFlag_PDaiPercent then
        gSysParam.FDaiPercent := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if nStr = sFlag_PDaiWuChaStop then
        gSysParam.FDaiWCStop := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if nStr = sFlag_PSanWuChaF then
        gSysParam.FPoundSanF := Fields[0].AsFloat;
      //xxxxx

      if nStr = sFlag_PoundPWuChaZ then
        gSysParam.FPoundPZ := Fields[0].AsFloat;
      //xxxxx

      if nStr = sFlag_PoundPWuChaF then
        gSysParam.FPoundPF := Fields[0].AsFloat;

      if nStr = sFlag_PTruckPWuCha then
        gSysParam.FPoundTruck := Fields[0].AsFloat;

      Next;
    end;

    with gSysParam do
    begin
      FPoundDaiZ_1 := FPoundDaiZ;
      FPoundDaiF_1 := FPoundDaiF;
      //backup wucha value
    end;
  end;

  //----------------------------------------------------------------------------
  if gSysParam.FMITServURL = '' then  //ʹ��Ĭ��URL
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_MITSrvURL]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        gChannelChoolser.AddChannelURL(Fields[0].AsString);
        Next;
      end;

      {$IFNDEF DEBUG}
      //gChannelChoolser.StartRefresh;
      {$ENDIF}//update channel
    end;
  end else
  begin
    gChannelChoolser.AddChannelURL(gSysParam.FMITServURL);
    //����ר��URL
  end;

  if gSysParam.FHardMonURL = '' then //����ϵͳĬ��Ӳ���ػ�
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_HardSrvURL]);

    with FDM.QueryTemp(nStr) do
     if RecordCount > 0 then
      gSysParam.FHardMonURL := Fields[0].AsString;
    //xxxxx
  end;

  CreateBaseFormItem(cFI_FormTodo);
  //����������

  {$IFNDEF DEBUG}
  gDisplayManager.StartDisplay;
  //������ʾ

  if FileExists(gPath + 'Printer.xml') then
  begin
    gRemotePrinter.LoadConfig(gPath + 'Printer.xml');
    gRemotePrinter.StartPrinter;
  end;
  {$ENDIF}
end;

//Desc: �ͷ�ϵͳ����
procedure FreeSystemObject;
begin
  FreeAndNil(gSysLoger);
  gDisplayManager.StopDisplay;
end;

end.
