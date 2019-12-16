{*******************************************************************************
  ����: dmzn@163.com 2009-6-25
  ����: ��Ԫģ��

  ��ע: ����ģ������ע������,ֻҪUsesһ�¼���.
*******************************************************************************}
unit USysModule;

interface

uses
  UClientWorker, UMITPacker, UMgrTTCEDispenser, UMgrSDTReader,
  UFrameMain, UFrameQueryCard, UFrameMakeCard, UFrameInputCertificate,
  UFramePurchaseCard, UFrameSaleCard, UFramePrintHYDan, UFrameSafeInfo,
  UFramePrintBill;

procedure InitSystemObject;
procedure RunSystemObject;
procedure FreeSystemObject;

implementation

uses
  SysUtils, USysLoger, USelfHelpConst, ULibFun, UMgrChannel, UChannelChooser,
  UMemDataPool, USysMAC, USysDB, UDataModule, IniFiles;

//Desc: ��ʼ��ϵͳ����
procedure InitSystemObject;
begin
  InitGlobalVariant(gPath, gPath+sConfig, gPath+sForm, gPath+sDB);
  //��ʼ�������ļ�

  gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  gSysLoger.LogSync := False;
  //system loger

  if not Assigned(gMemDataManager) then
    gMemDataManager := TMemDataManager.Create;
  //Memory Manager

  gChannelManager := TChannelManager.Create;
  gChannelManager.ChannelMax := 20;
  gChannelChoolser := TChannelChoolser.Create('');
  gChannelChoolser.AutoUpdateLocal := False;
  //channel

  gDispenserManager := TDispenserManager.Create;
  gDispenserManager.LoadConfig(gPath + 'TTCE_K720.xml');

  gSDTReaderManager.LoadConfig(gPath + 'SDTReader.XML');
  gSDTReaderManager.TempDir := gPath + 'Temp\';
end;

//Desc: ����ϵͳ����
procedure RunSystemObject;
var nStr: string;
    nTmp: TIniFile;
begin
  nTmp := TIniFile.Create(gPath + sConfig);
  with gSysParam, nTmp do
  begin
    FProgID := ReadString(sConfigSec, 'ProgID', 'ZXSOFT');
    //�����ʶ�����������в���
    FLocalMAC   := MakeActionID_MAC;
    GetLocalIPConfig(FLocalName, FLocalIP);

    FHYDanPrinter := ReadString(FProgID,'hydanprinter','');
    FCardPrinter  := ReadString(FProgID,'cardprinter','');
    FTTCEK720ID   := ReadString(FProgID,'TTCEK720ID','');
    FSafeInfoFoot := ReadString(FProgID,'SafeInfoFoot','��Ϫ����Ϸ�ˮ�����޹�˾�� ');
  end;

  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_MITSrvURL]);

  with FDM.SQLQuery(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      gChannelChoolser.AddChannelURL(Fields[0].AsString);
      Next;
    end;

    gChannelChoolser.StartRefresh;
    //update channel
  end;

  gSysParam.FAICMPDCount := 2;

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_AICMPDCount]);

  with FDM.SQLQuery(nStr) do
  if RecordCount > 0 then
  begin
    gSysParam.FAICMPDCount := Fields[0].AsInteger;
  end;

  gDispenserManager.StartDispensers;
  //����������

  gSDTReaderManager.StartReader;
  //�������֤������
  if Assigned(nTmp) then nTmp.Free;
end;

//Desc: �ͷ�ϵͳ����
procedure FreeSystemObject;
begin
  gDispenserManager.StopDispensers;
  //�رն�����

  gSDTReaderManager.StopReader;
  //�ر����֤������
  
  FreeAndNil(gSysLoger);
end;

end.
