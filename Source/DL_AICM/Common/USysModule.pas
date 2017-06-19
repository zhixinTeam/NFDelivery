{*******************************************************************************
  ����: dmzn@163.com 2009-6-25
  ����: ��Ԫģ��

  ��ע: ����ģ������ע������,ֻҪUsesһ�¼���.
*******************************************************************************}
unit USysModule;

interface

uses
  UClientWorker, UMITPacker, UMgrK720Reader, UMgrSDTReader,
  UFrameMain, UFrameQueryCard, UFrameMakeCard, UFrameInputCertificate;

procedure InitSystemObject;
procedure RunSystemObject;
procedure FreeSystemObject;

implementation

uses
  SysUtils, USysLoger, USelfHelpConst, ULibFun, UMgrChannel, UChannelChooser,
  UMemDataPool, USysMAC, USysDB, UDataModule;

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

  gMgrK720Reader := TK720ReaderManager.Create;
  gMgrK720Reader.LoadConfig(gPath + 'K720Reader.XML');

  gSDTReaderManager.LoadConfig(gPath + 'SDTReader.XML');
  gSDTReaderManager.TempDir := gPath + 'Temp\';
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

  gMgrK720Reader.StartReader;
  //����������

  gSDTReaderManager.StartReader;
  //�������֤������
end;

//Desc: �ͷ�ϵͳ����
procedure FreeSystemObject;
begin
  gMgrK720Reader.StopReader;
  //�رն�����

  gSDTReaderManager.StopReader;
  //�ر����֤������
  
  FreeAndNil(gSysLoger);
end;

end.
