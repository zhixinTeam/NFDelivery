{*******************************************************************************
  ����: dmzn@163.com 2012-4-29
  ����: ��������
*******************************************************************************}
unit USysConst;

interface

uses
  Windows, Classes, SysUtils, UBusinessPacker, UBusinessWorker, UBusinessConst,
  UClientWorker, UMITPacker, UWaitItem, ULibFun, USysDB, USysLoger,
  UMgrChannel, UChannelChooser, U02NReader, UMgrLEDDisp,UDataModule, IniFiles;
{$DEFINE DEBUG}
type
  TStockMap = record
    FStockType   : string;
    FStockContext: string;
  end;
  TStockMaps = array of TStockMap;

  TSysParam = record
    FUserID     : string;                            //�û���ʶ
    FUserName   : string;                            //��ǰ�û�
    FUserPwd    : string;                            //�û�����
    FGroupID    : string;                            //������
    FIsAdmin    : Boolean;                           //�Ƿ����Ա
    FIsNormal   : Boolean;                           //�ʻ��Ƿ�����

    FLocalIP    : string;                            //����IP
    FLocalMAC   : string;                            //����MAC
    FLocalName  : string;                            //��������
    FHardMonURL : string;                            //Ӳ���ػ�

    FNoDaiQueue : Boolean;     //��װ���ö���
    FNoSanQueue : Boolean;     //ɢװ���ö���

    FStockFlag  : Boolean;
    FStockMaps  : TStockMaps;
  end;
  //ϵͳ����

  PZTLineItem = ^TZTLineItem;
  TZTLineItem = record
    FID       : string;      //���
    FName     : string;      //����
    FStock    : string;      //Ʒ��
    FWeight   : Integer;     //����
    FValid    : Boolean;     //�Ƿ���Ч
  end;

  PZTTruckItem = ^TZTTruckItem;
  TZTTruckItem = record
    FTruck    : string;      //���ƺ�
    FLine     : string;      //ͨ��
    FBill     : string;      //�����
    FValue    : Double;      //�����
    FDai      : Integer;     //����
    FTotal    : Integer;     //����
    FInFact   : Boolean;     //�Ƿ����
    FIsRun    : Boolean;     //�Ƿ�����    
  end;

  TZTLineItems = array of TZTLineItem;
  TZTTruckItems = array of TZTTruckItem;
//------------------------------------------------------------------------------
var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����

function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean = False): Boolean;
//��ȡ��������
function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//��ȡָ����λ�Ľ������б�

//Desc: ��ʼ��ϵͳ����
procedure InitSystemObject;
//Desc: ����ϵͳ����
procedure RunSystemObject;
//Desc: �ͷ�ϵͳ����
procedure FreeSystemObject;

procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
//------------------------------------------------------------------------------
resourceString
  sHint               = '��ʾ';                      //�Ի������
  sWarn               = '����';                      //==
  sAsk                = 'ѯ��';                      //ѯ�ʶԻ���
  sError              = 'δ֪����';                  //����Ի���

  sDate               = '����:��%s��';               //����������
  sTime               = 'ʱ��:��%s��';               //������ʱ��
  sUser               = '�û�:��%s��';               //�������û�

  sConfigFile         = 'Config.Ini';                //�������ļ�
  sConfigSec          = 'Config';                    //������С��
  sVerifyCode         = ';Verify:';                  //У������
  sFormConfig         = 'FormInfo.ini';              //��������

  sInvalidConfig      = '�����ļ���Ч���Ѿ���';    //�����ļ���Ч
  sCloseQuery         = 'ȷ��Ҫ�˳�������?';         //�������˳�

implementation

//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(nEvent);
end;

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessSaleBill(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessSaleBill);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-10-01
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessHardware(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014-10-01
//Parm: ͨ��;����
//Desc: ��ȡ������������
function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean): Boolean;
var nIdx: Integer;
    nSLine,nSTruck: string;
    nListA,nListB: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    if nRefreshLine then
         nSLine := sFlag_Yes
    else nSLine := sFlag_No;

    Result := CallBusinessHardware(cBC_GetQueueData, nSLine, '', @nOut , False);
    if not Result then Exit;

    nListA.Text := PackerDecodeStr(nOut.FData);
    nSLine := nListA.Values['Lines'];
    nSTruck := nListA.Values['Trucks'];

    nListA.Text := PackerDecodeStr(nSLine);
    SetLength(nLines, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nLines[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FID       := Values['ID'];
      FName     := Values['Name'];
      FStock    := Values['Stock'];
      FValid    := Values['Valid'] <> sFlag_No;

      if IsNumber(Values['Weight'], False) then
           FWeight := StrToInt(Values['Weight'])
      else FWeight := 1;
    end;

    nListA.Text := PackerDecodeStr(nSTruck);
    SetLength(nTrucks, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nTrucks[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FTruck    := Values['Truck'];
      FLine     := Values['Line'];
      FBill     := Values['Bill'];

      if IsNumber(Values['Value'], True) then
           FValue := StrToFloat(Values['Value'])
      else FValue := 0;

      FInFact   := Values['InFact'] = sFlag_Yes;
      FIsRun    := Values['IsRun'] = sFlag_Yes;
           
      if IsNumber(Values['Dai'], False) then
           FDai := StrToInt(Values['Dai'])
      else FDai := 0;

      if IsNumber(Values['Total'], False) then
           FTotal := StrToInt(Values['Total'])
      else FTotal := 0;
    end;
  finally
    nListA.Free;
    nListB.Free;
  end;
end;


//Date: 2014-09-17
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut, False);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Desc: ��ʼ��ϵͳ����
procedure InitSystemObject;
begin
  if not Assigned(gSysLoger) then
    gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  //system loger

  gChannelManager := TChannelManager.Create;
  gChannelManager.ChannelMax := 20;
  gChannelChoolser := TChannelChoolser.Create('');
  gChannelChoolser.AutoUpdateLocal := False;
  //channel
end;

//Desc: ����ϵͳ����
procedure RunSystemObject;
var nStr: string;
begin
  //----------------------------------------------------------------------------
  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_MITSrvURL]);

  with FDM.SQLQuery(nStr, FDM.SQLQuery1) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      gChannelChoolser.AddChannelURL(Fields[0].AsString);
      Next;
    end;

    {$IFNDEF DEBUG}
    gChannelChoolser.StartRefresh;
    {$ENDIF}//update channel
  end;

  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_HardSrvURL]);

  with FDM.SQLQuery(nStr, FDM.SQLQuery1) do
  if RecordCount > 0 then
  begin
    gSysParam.FHardMonURL := Fields[0].AsString;
  end;

  //----------------------------------------------------------------------------

  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_NoDaiQueue]);

  with FDM.SQLQuery(nStr, FDM.SQLQuery1) do
  if RecordCount > 0 then
  begin
    gSysParam.FNoDaiQueue := Fields[0].AsString = sFlag_Yes;
  end;

  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_NoSanQueue]);

  with FDM.SQLQuery(nStr, FDM.SQLQuery1) do
  if RecordCount > 0 then
  begin
    gSysParam.FNoSanQueue := Fields[0].AsString = sFlag_Yes;
  end;
end;

//Desc: �ͷ�ϵͳ����
procedure FreeSystemObject;
begin
  FreeAndNil(gSysLoger);
end;

function GetStockType(nBill: string):string;
var nStr: string;
    nInt: Integer;
begin
  Result := '��ͨ';

  nStr := 'Select L_PackStyle From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  with FDM.SQLQuery(nStr, FDM.SQLQuery1) do
  if RecordCount > 0 then
    nStr := Trim(Fields[0].AsString);

  if gSysParam.FStockFlag then
  begin
    for nInt:=Low(gSysParam.FStockMaps) to High(gSysParam.FStockMaps) do
    if CompareText(nStr, gSysParam.FStockMaps[nInt].FStockType)=0 then
      Result := gSysParam.FStockMaps[nInt].FStockContext;
  end else
  begin
    if nStr = 'Z' then Result := 'ֽ��';
    if nStr = 'R' then Result := '��ǿ';
  end;
end;
//Date: 2015-01-14
//Parm: ���ƺ�;������
//Desc: ��ʽ��nBill��������Ҫ��ʾ�ĳ��ƺ�
function GetJSTruck(const nTruck,nBill: string): string;
var nStr: string;
    nLen: Integer;
begin
  Result := nTruck;
  if nBill = '' then Exit;

  {$IFDEF JSTruck}
  nStr := 'Select L_PackStyle From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  with FDM.SQLQuery(nStr, FDM.SQLQuery1) do
  if RecordCount > 0 then
  begin
    nStr := Trim(Fields[0].AsString);
    if (nStr = '') or (nStr = 'C') then Exit;
    //��ͨģʽ,����ȫ��

    nLen := cMultiJS_Truck - 2;
    Result := nStr + '-' + Copy(nTruck, Length(nTruck) - nLen + 1, nLen);
  end;
  {$ENDIF}
end;

function StockMatch(nBill:TLadingBillItem; nLine: TZTLineItem):Boolean;
var
  nStr, nLineGroupID, nBillGroupID: string;
begin
  Result := True;
  if (nBill.FStockNo = nLine.FStock) or (nBill.FStockName = nLine.FStock) then
    Exit;

  nStr := 'select M_Group from %s where M_ID=''%s'' and M_Status=''Y''';
  nStr := Format(nStr, [sTable_StockMatch, nLine.FStock]);
  with FDM.SQLQuery(nStr, FDM.SQLQuery1) do
  if RecordCount>0 then nLineGroupID := Fields[0].AsString;

  nStr := 'select M_Group from %s where (M_ID=''%s'' or M_ID=''%s''' +
          ') and M_Status=''Y''';
  nStr := Format(nStr, [sTable_StockMatch, nBill.FStockNo, nBill.FStockName]);
  with FDM.SQLQuery(nStr, FDM.SQLQuery1) do
  if RecordCount>0 then nBillGroupID := Fields[0].AsString;

  if (nLineGroupID <> '') and (nBillGroupID <> '') and
    (nLineGroupID = nBillGroupID) then Exit;

  Result := False;
end;

function IsTruckInQueue(nBill: TLadingBillItem; nZTTrucks: TZTTruckItems;
  nTunnel: string=''):Boolean;
var nIdx: Integer;
    nStrLog: string;
    nTruck: TZTTruckItem;
begin
  Result := True;
  if gSysParam.FNoDaiQueue then Exit;

  {$IFDEF DEBUG}
  nStrLog := 'ˢ����Ϣ: �������[%s]�����ƺ�[%s]';
  nStrLog := Format(nStrLog, [nTunnel, nBill.FTruck]);
  WriteLog(nStrLog);
  {$ENDIF}

  for nIdx:=Low(nZTTrucks) to High(nZTTrucks) do
  begin
    nTruck := nZTTrucks[nIdx];

    {$IFDEF DEBUG}
    nStrLog := '��ǰ������Ϣ: �������[%s]�����ƺ�[%s]';
    nStrLog := Format(nStrLog, [nTruck.FLine, nTruck.FTruck]);
    WriteLog(nStrLog);
    {$ENDIF}

    if (0=CompareStr(UpperCase(nTruck.FLine), UpperCase(nTunnel)))
      and (0=CompareStr(UpperCase(nTruck.FTruck), UpperCase(nBill.FTruck)))
    then Exit;
  end;

  Result := False;
end;

function PrepareShowInfo(const nCard:string; nTunnel: string=''):string;
var
  nStr: string;
  nDai: Double;
  nIdx, nInt, nHas: Integer;
  nLines: TZTLineItems;
  nZTTrucks: TZTTruckItems;
  nBills: TLadingBillItems;
begin
  Result := '';

  if not GetLadingBills(nCard, sFlag_TruckZT, nBills) then
  begin
    Result := '�ſ�����Ϣ.';
    Result := Format(Result, [nCard]);

    WriteLog(Result);
    Exit;
  end;

  if Length(nBills) < 1 then
  begin
    Result := '�ſ�û����Ҫջ̨�������.';
    Result := Format(Result, [nCard]);

    WriteLog(Result);
    Exit;
  end;

  if not LoadTruckQueue(nLines, nZTTrucks, False) then Exit;

  nInt := 0;
  for nIdx:=Low(nLines) to High(nLines) do
  begin
    if (nLines[nIdx].FID = nTunnel) then
    begin
      nInt := nIdx;
      Break;
    end;
  end;

  if nIdx>High(nLines) then
  begin
    Result := 'װ����%s��Ч';
    Result := Format(Result, [nLines[nInt].FID]);
    WriteLog(Result);
    Exit;
  end;

  if not IsTruckInQueue(nBills[0], nZTTrucks, nTunnel) then
  begin
    Result:= '�복��%s����װ��';
    Result:= format(Result, [nBills[0].FTruck]);
    WriteLog(Result);
    Exit;
  end; 

  nHas := 0;
  for nIdx:=Low(nBills) to High(nBills) do
  begin
    if ((nBills[nIdx].FStatus = sFlag_TruckZT) or (
      nBills[nIdx].FNextStatus= sFlag_TruckZT)) then
    begin
      if  StockMatch(nBills[nIdx], nLines[nInt]) then
      begin
        nDai := Int(nBills[nIdx].FValue * 1000) / nLines[nInt].FWeight;

        nStr := GetStockType(nBills[nIdx].FID);
        Result := Result + nStr + StringOfChar(' ' , 7 - Length(nStr));

        nStr := FormatFloat('00000' , nDai);
        Result := Result + StringOfChar('0' , 5 - Length(nStr)) + nStr;

        Inc(nHas);
      end;
    end;
  end;

  {$IFDEF DEBUG}
  WriteLog(Result);
  {$ENDIF}

  if nHas < 1 then
  begin
    Result:= '����%s��ʱ�޷�װ��';
    Result:= format(Result, [nBills[0].FTruck]);
    WriteLog(Result);
  end;
end;

//�ֳ���ͷ���¿���
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
var nTxt, nStrLog: string;
    nPrepare: Boolean;
begin
  {$IFDEF DEBUG}
  nStrLog := '������Ϣ: �������[%s]������[%s]';
  nStrLog := Format(nStrLog, [nHost.FTunnel, nCard]);
  WriteLog(nStrLog);
  {$ENDIF}
  nTxt := PrepareShowInfo(nCard, nHost.FTunnel);
  if nTxt<>'' then gDisplayManager.Display(nHost.FID, nTxt);
end;

procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
begin
  gDisplayManager.Display(nHost.FID, nHost.FLEDText);
  Sleep(100);
  Exit;
end;

end.
