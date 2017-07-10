{*******************************************************************************
  ����: fendou116688@163.com 2017/4/11
  ����: ΢��ҵ���ѯ
*******************************************************************************}
unit UWorkerClientWebChat;

interface

uses
  Windows, SysUtils, Classes, UMgrChannel, UChannelChooser, UBusinessWorker,
  UBusinessConst, UBusinessPacker, ULibFun;

type
  TClient2WebChatWorker = class(TBusinessWorkerBase)
  protected
    FListA,FListB: TStrings;
    //�ַ��б�
    procedure WriteLog(const nEvent: string);
    //��¼��־
    function ErrDescription(const nCode,nDesc: string;
      const nInclude: TDynamicStrArray): string;
    //��������
    function MITWork(var nData: string): Boolean;
    //ִ��ҵ��
    function GetFixedServiceURL: string; virtual;
    //�̶���ַ
  public
    constructor Create; override;
    destructor destroy; override;
    //�����ͷ�
    function DoWork(const nIn, nOut: Pointer): Boolean; override;
    //ִ��ҵ��
  end;

  TClientBusinessWebChat = class(TClient2WebChatWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function GetFixedServiceURL: string; override;
  end;

function CallRemoteWorker(const nCLIWorkerName: string; const nData,nExt: string;
 const nOut: PWorkerBusinessCommand; const nCmd: Integer;const nRemoteUL: string=''): Boolean;
//����Զ�̷������ 
implementation

uses
  UFormWait, Forms, USysLoger, UMITConst, MIT_Service_Intf;

//Date: 2014-09-15
//Parm: ����;����;����;����;���
//Desc: ���ص���ҵ�����
function CallRemoteWorker(const nCLIWorkerName: string; const nData,nExt: string;
 const nOut: PWorkerBusinessCommand; const nCmd: Integer;const nRemoteUL: string=''): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FBase.FParam := nRemoteUL;

    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nWorker := gBusinessWorkerManager.LockWorker(nCLIWorkerName);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-3-11
//Parm: ��־����
//Desc: ��¼��־
procedure TClient2WebChatWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(ClassType, '�ͻ�ҵ�����', nEvent);
end;

constructor TClient2WebChatWorker.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  inherited;
end;

destructor TClient2WebChatWorker.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  inherited;
end;

//Date: 2012-3-11
//Parm: ���;����
//Desc: ִ��ҵ�񲢶��쳣������
function TClient2WebChatWorker.DoWork(const nIn, nOut: Pointer): Boolean;
var nStr: string;
begin
  nStr := '<?xml version="1.0" encoding="utf-8"?>'
          +'<Head>'
          +'  <Command>%d</Command>'
          +'  <Data>%s</Data>'
          +'  <ExtParam>%s</ExtParam>'
          +'  <RemoteUL></RemoteUL>'
          +'</Head>';

  with PWorkerBusinessCommand(nIn)^ do
  nStr := Format(nStr, [FCommand, FData, FExtParam]);

  Result := MITWork(nStr);

  with PWorkerBusinessCommand(nOut)^ do
  begin
    FData := nStr;
  end;
end;

//Date: 2012-3-20
//Parm: ����;����
//Desc: ��ʽ����������
function TClient2WebChatWorker.ErrDescription(const nCode, nDesc: string;
  const nInclude: TDynamicStrArray): string;
var nIdx: Integer;
begin
  FListA.Text := StringReplace(nCode, #9, #13#10, [rfReplaceAll]);
  FListB.Text := StringReplace(nDesc, #9, #13#10, [rfReplaceAll]);

  if FListA.Count <> FListB.Count then
  begin
    Result := '��.����: ' + nCode + #13#10 +
              '   ����: ' + nDesc + #13#10#13#10;
  end else Result := '';

  for nIdx:=0 to FListA.Count - 1 do
  if (Length(nInclude) = 0) or (StrArrayIndex(FListA[nIdx], nInclude) > -1) then
  begin
    Result := Result + '��.����: ' + FListA[nIdx] + #13#10 +
                       '   ����: ' + FListB[nIdx] + #13#10#13#10;
  end;
end;

//Desc: ǿ��ָ�������ַ
function TClient2WebChatWorker.GetFixedServiceURL: string;
begin
  Result := '';
end;

//Date: 2012-3-9
//Parm: �������
//Desc: ����MITִ�о���ҵ��
function TClient2WebChatWorker.MITWork(var nData: string): Boolean;
var nChannel: PChannelItem;
begin
  Result := False;
  nChannel := nil;
  try
    nChannel := gChannelManager.LockChannel(cBus_Channel_Business);
    if not Assigned(nChannel) then
    begin
      nData := '����MIT����ʧ��(BUS-MIT No Channel).';
      Exit;
    end;

    with nChannel^ do
    while True do
    try
      if not Assigned(FChannel) then
        FChannel := CoSrvWebchat.Create(FMsg, FHttp);
      //xxxxx

      if GetFixedServiceURL = '' then
           Exit
      else FHttp.TargetURL := GetFixedServiceURL;

      Result := ISrvWebChat(FChannel).Action(GetFlagStr(cWorker_GetMITName),
                                              nData);
      //call mit funciton
      Break;
    except
      on E:Exception do
      begin
        if (GetFixedServiceURL <> '') or
           (gChannelChoolser.GetChannelURL = FHttp.TargetURL) then
        begin
          nData := Format('%s.', [E.Message]);
          WriteLog('Function:[ ' + FunctionName + ' ]' + E.Message);
          Exit;
        end;
      end;
    end;
  finally
    gChannelManager.ReleaseChannel(nChannel);
  end;
end;

//------------------------------------------------------------------------------
class function TClientBusinessWebChat.FunctionName: string;
begin
  Result := sCLI_BusinessWebchat;
end;

function TClientBusinessWebChat.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_BusinessWebchat;
  end;
end;

function TClientBusinessWebChat.GetFixedServiceURL: string;
begin
  Result := gSysParam.FGPWSURL;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TClientBusinessWebChat, sPlug_ModuleBus);
end.
