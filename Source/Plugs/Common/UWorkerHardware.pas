{*******************************************************************************
  ����: dmzn@163.com 2013-12-04
  ����: ģ��ҵ�����
*******************************************************************************}
unit UWorkerHardware;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UMgrRFID102, UMgrRemoteVoice, UMgrVoiceNet;

type
  THardwareDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //������
    FDBConn: PDBWorker;
    //����ͨ��
    FDataIn,FDataOut: PBWDataBase;
    //��γ���
    FDataOutNeedUnPack: Boolean;
    //��Ҫ���
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //�������
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //��֤���
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //����ҵ��
  public
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
  end;

  THardwareCommander = class(THardwareDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function ChangeDispatchMode(var nData: string): Boolean;
    //�л�����ģʽ
    function PoundCardNo(var nData: string): Boolean;
    //��ȡ��վ����
    function PoundReaderInfo(var nData: string): Boolean;
    //��ȡ��վ��������λ������
    function LoadQueue(var nData: string): Boolean;
    //��ȡ��������
    function ExecuteSQL(var nData: string): Boolean;
    //ִ��SQL���
    function SaveDaiNum(var nData: string): Boolean;
    //�����������
    function PrintCode(var nData: string): Boolean;
    function PrintFixCode(var nData: string): Boolean;
    //�������ӡ����
    function PrinterEnable(var nData: string): Boolean;
    function PrinterChinaEnable(var nData: string): Boolean;
    //��ͣ�����
    function StartJS(var nData: string): Boolean;
    function PauseJS(var nData: string): Boolean;
    function StopJS(var nData: string): Boolean;
    function JSStatus(var nData: string): Boolean;
    //������ҵ��
    function TruckProbe_IsTunnelOK(var nData: string): Boolean;
    function TruckProbe_TunnelOC(var nData: string): Boolean;
    function TruckProbe_ShowTxt(var nData: string): Boolean;
    //������������ҵ��
    function OpenDoorByReader(var nData: string): Boolean;
    //ͨ���������򿪵�բ
    function PlayNetVoice(var nData: string): Boolean;
    //������������
    function RemoteSnap_DisPlay(var nData: string): Boolean;
    //ץ��С����ʾ
    function ShowLedText(var nData: string): Boolean;
    //���ƷŻҵ���С����ʾ
    function LineClose(var nData: string): Boolean;
    //���ƷŻ�
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation

uses
  {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}
  UMgrHardHelper, UMgrCodePrinter, UMgrQueue, UTaskMonitor,
  UMgrTruckProbe, UMgrLEDDispCounter, UMgrRemoteSnap, UMgrERelay;

//Date: 2012-3-13
//Parm: ���������
//Desc: ��ȡ�������ݿ��������Դ
function THardwareDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      nData := FPacker.PackOut(FDataOut);

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: �������;���
//Desc: ����ҵ��ִ����Ϻ����β����
function THardwareDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: �������
//Desc: ��֤��������Ƿ���Ч
function THardwareDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: ��¼nEvent��־
procedure THardwareDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(THardwareDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function THardwareCommander.FunctionName: string;
begin
  Result := sBus_HardwareCommand;
end;

constructor THardwareCommander.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor THardwareCommander.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function THardwareCommander.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure THardwareCommander.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2012-3-22
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function THardwareCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_ChangeDispatchMode   : Result := ChangeDispatchMode(nData);
   cBC_GetPoundCard         : Result := PoundCardNo(nData);
   cBC_GetPoundReaderInfo   : Result := PoundReaderInfo(nData);
   cBC_GetQueueData         : Result := LoadQueue(nData);
   cBC_SaveCountData        : Result := SaveDaiNum(nData);
   cBC_RemoteExecSQL        : Result := ExecuteSQL(nData);
   cBC_PrintCode            : Result := PrintCode(nData);
   cBC_PrintFixCode         : Result := PrintFixCode(nData);
   cBC_PrinterEnable        : Result := PrinterEnable(nData);
   cBC_PrinterChinaEnable   : Result := PrinterChinaEnable(nData);

   cBC_JSStart              : Result := StartJS(nData);
   cBC_JSStop               : Result := StopJS(nData);
   cBC_JSPause              : Result := PauseJS(nData);
   cBC_JSGetStatus          : Result := JSStatus(nData);

   cBC_IsTunnelOK           : Result := TruckProbe_IsTunnelOK(nData);
   cBC_TunnelOC             : Result := TruckProbe_TunnelOC(nData);
   cBC_OpenDoorByReader     : Result := OpenDoorByReader(nData);
   cBC_PlayVoice            : Result := PlayNetVoice(nData);
   cBC_ShowTxt              : Result := TruckProbe_ShowTxt(nData);
   cBC_RemoteSnapDisPlay    : Result := RemoteSnap_DisPlay(nData);

   cBC_ShowLedTxt           : Result := ShowLedText(nData);
   cBC_LineClose            : Result := LineClose(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

//Date: 2014-10-07
//Parm: ����ģʽ[FIn.FData]
//Desc: �л�ϵͳ����ģʽ
function THardwareCommander.ChangeDispatchMode(var nData: string): Boolean;
var nStr,nSQL: string;
begin
  Result := True;
  nSQL := 'Update %s Set D_Value=''%s'' Where D_Name=''%s'' And D_Memo=''%s''';

  if FIn.FData = '1' then
  begin
    nStr := Format(nSQL, [sTable_SysDict, sFlag_No, sFlag_SysParam,
            sFlag_SanMultiBill]);
    gDBConnManager.WorkerExec(FDBConn, nStr); //�ر�ɢװԤ��

    nStr := Format(nSQL, [sTable_SysDict, '20', sFlag_SysParam,
            sFlag_InTimeout]);
    gDBConnManager.WorkerExec(FDBConn, nStr); //���̽�����ʱ

    gTruckQueueManager.RefreshParam;
    //ʹ���µ��Ȳ���
  end else

  if FIn.FData = '2' then
  begin
    nStr := Format(nSQL, [sTable_SysDict, sFlag_Yes, sFlag_SysParam,
            sFlag_SanMultiBill]);
    gDBConnManager.WorkerExec(FDBConn, nStr); //����ɢװԤ��

    nStr := Format(nSQL, [sTable_SysDict, '1440', sFlag_SysParam,
            sFlag_InTimeout]);
    gDBConnManager.WorkerExec(FDBConn, nStr); //�ӳ�������ʱ

    gTruckQueueManager.RefreshParam;
    //ʹ���µ��Ȳ���
  end;
end;

//Date: 2014-10-01
//Parm: ��վ��[FIn.FData];ȡ���ű�ǵ����Ϊ'Y'ʱ�����ض�������������
//Desc: ��ȡָ����վ�������ϵĴſ���
function THardwareCommander.PoundCardNo(var nData: string): Boolean;
var nStr, nPoundID: string;
    nIdx: Integer;
begin
  Result := True;
  if FIn.FExtParam = sFlag_Yes then
  begin
    FListA.Clear;
    FListB.Clear;
    if not SplitStr(FIn.FData, FListA, 0, ',') then Exit;

    for nIdx:=0 to FListA.Count - 1 do
    begin
      nPoundID := FListA[nIdx];
      FListB.Values[nPoundID] := gHardwareHelper.GetPoundCard(nPoundID, FOut.FExtParam);
    end;

    FOut.FData := FListB.Text;
    Exit;
  end;

  FOut.FData := gHardwareHelper.GetPoundCard(FIn.FData, FOut.FExtParam);
  if FOut.FData = '' then Exit;

  nStr := 'Select C_Card From $TB Where C_Card=''$CD'' or ' +
          'C_Card2=''$CD'' or C_Card3=''$CD''';
  nStr := MacroValue(nStr, [MI('$TB', sTable_Card), MI('$CD', FOut.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FOut.FData := Fields[0].AsString;
    gHardwareHelper.SetPoundCardExt(FIn.FData, FOut.FData);
    //��Զ���뿨�Ŷ�Ӧ�Ľ����뿨�Ű�
  end;
end;

//Date: 2014-10-01
//Parm: �Ƿ�ˢ��[FIn.FData]
//Desc: ��ȡ��������
function THardwareCommander.LoadQueue(var nData: string): Boolean;
var nVal: Double;
    i,nIdx: Integer;
    nLine: PLineItem;
    nTruck: PTruckItem;
begin
  gTruckQueueManager.RefreshTrucks(FIn.FData = sFlag_Yes);
  Sleep(320);
  //ˢ������

  with gTruckQueueManager do
  try
    SyncLock.Enter;
    Result := True;

    FListB.Clear;
    FListC.Clear;

    for nIdx:=0 to Lines.Count - 1 do
    begin
      nLine := Lines[nIdx];
      FListB.Values['ID'] := nLine.FLineID;
      FListB.Values['Name'] := nLine.FName;
      FListB.Values['Stock'] := nLine.FStockNo;
      FListB.Values['Weight'] := IntToStr(nline.FPeerWeight);

      FListB.Values['VIP']  := nLine.FIsVIP;
      //�ж��Ƿ�VIP

      if nLine.FIsValid then
           FListB.Values['Valid'] := sFlag_Yes
      else FListB.Values['Valid'] := sFlag_No;

      if gCodePrinterManager.IsPrinterEnable(nLine.FLineID) then
           FListB.Values['Printer'] := sFlag_Yes
      else FListB.Values['Printer'] := sFlag_No;

      FListB.Values['LineGroup'] := nLine.FLineGroup;

      FListC.Add(PackerEncodeStr(FListB.Text));
      //��������
    end;

    FListA.Values['Lines'] := PackerEncodeStr(FListC.Text);
    //ͨ���б�
    FListC.Clear;

    for nIdx:=0 to Lines.Count - 1 do
    begin
      nLine := Lines[nIdx];
      FListB.Clear;

      for i:=0 to nLine.FTrucks.Count - 1 do
      begin
        nTruck := nLine.FTrucks[i];
        FListB.Values['Truck'] := nTruck.FTruck;
        FListB.Values['Line'] := nLine.FLineID;
        FListB.Values['Bill'] := nTruck.FBill;
        FListB.Values['HKBills'] := nTruck.FHKBills;
        FListB.Values['QueueBills'] := nTruck.FQueueBills;
        FListB.Values['Value'] := FloatToStr(nTruck.FValue);

        if nLine.FPeerWeight > 0 then
        begin
          nVal := nTruck.FValue * 1000;
          nTruck.FDai := Trunc(nVal / nLine.FPeerWeight);
        end else nTruck.FDai := 0;
        
        FListB.Values['Dai'] := IntToStr(nTruck.FDai);
        FListB.Values['Total'] := IntToStr(nTruck.FNormal + nTruck.FBuCha);

        if nTruck.FStarted then
             FListB.Values['IsRun'] := sFlag_Yes
        else FListB.Values['IsRun'] := sFlag_No;

        if nTruck.FInFact then
             FListB.Values['InFact'] := sFlag_Yes
        else FListB.Values['InFact'] := sFlag_No;

        FListC.Add(PackerEncodeStr(FListB.Text));
        //��������
      end;
    end;

    FListA.Values['Trucks'] := PackerEncodeStr(FListC.Text);
    //�����б�
    FOut.FData := PackerEncodeStr(FListA.Text);
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2015/1/22
//Parm: Դ�ַ�����ָ�����ȣ����ַ�;���䷽ʽ
//Desc: ��Դ�ַ���(nStr)"��(Fasle)/��(True)"��(Length(nStr)-nLen)���ַ�(nFillStr),
function FillString(const nStr: string; nLen: Integer;
  nFillStr: Char; nRight: Boolean=False): string;
var nTmp: string;
begin
  nTmp := Trim(nStr);
  if Length(nTmp) > nLen then
  begin
    Result:=nTmp;
    Exit;
  end;

  case nRight of
  True:Result:= nTmp + StringOfChar(nFillStr, nLen - Length(nTmp));
  False:Result:= StringOfChar(nFillStr, nLen - Length(nTmp)) + nTmp;
  end;
end;

//Date: 2014-10-01
//Parm: ������[FIn.FData];ͨ����[FIn.FExtParam]
//Desc: ��ָ��ͨ��������
function THardwareCommander.PrintCode(var nData: string): Boolean;
var nStr,nBill,nCode,nArea,nCusCode,nSeal,nTruck,nBm,nPCCode,nCusBz: string;
    nPrefixLen, nIDLen: Integer;
    nEvent,nEID:string;
begin
  Result := True;
  if not gCodePrinterManager.EnablePrinter then Exit;

  nStr := '��ͨ��[ %s ]���ͽ�����[ %s ]��Υ����.';
  nStr := Format(nStr, [FIn.FExtParam, FIn.FData]);
  WriteLog(nStr);

  nStr := 'Select B_Prefix,B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase,sFlag_BusGroup, sFlag_BillNo]);
  //xxxxx
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
   if RecordCount>0 then
   begin
     nPrefixLen := Length(Fields[0].AsString);
     nIDLen     := Fields[1].AsInteger;
   end else begin
     nPrefixLen := -1;
     nIDLen     := -1;
   end;
  //xxxxx

  if Pos('@', FIn.FData) = 1 then
  begin
    nCode := Copy(FIn.FData, 2, Length(FIn.FData) - 1);
    //�̶�����
  end else
  begin
    if (nPrefixLen<0) or (nIDLen<0) then Exit;
    //�����������

    {$IFDEF BMPrintCode}
    nStr := 'Select L_ID,L_Seal,L_CusCode,L_Area,L_Truck,L_Bm From %s ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    {$ELSE}
    nStr := 'Select L_ID,L_Seal,L_CusCode,L_Area,L_Truck,C_Memo From %s ' +
            ' left join %s on L_CusName = C_Name ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, sTable_Customer, FIn.FData]);
    {$ENDIF}

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      with FOut.FBase do
      begin
        FResult := False;
        FErrCode := 'E.00';
        FErrDesc := Format('������[ %s ]����Ч.', [FIn.FData]); Exit;
      end;

      nCode     := '';
      nBill     := FieldByName('L_ID').AsString;
      nArea     := FieldByName('L_Area').AsString;
      nSeal     := FieldByName('L_Seal').AsString;
      nCusCode  := FieldByName('L_CusCode').AsString;
      nTruck    := FieldByName('L_Truck').AsString;
      {$IFDEF BMPrintCode}
      nBm       := FieldByName('L_Bm').AsString;
      {$ELSE}
      nCusBz    := FieldByName('C_Memo').AsString;
      if nCusBz = '' then
        nCusBz := '00';
      {$ENDIF}
      //xxxxx

      {$IFDEF PrintChinese}
      //protocol: ��������+�ͻ�����(������) + ��������(ĩ3λ) + ���κ�;
      if (nArea <> '') and
        gCodePrinterManager.IsPrinterChinaEnable(FIn.FExtParam) then
      begin
        nStr := 'Select B_PrintCode From %s Where B_Source=''%s'' and ' +
                'B_Valid=''%s''';
        nStr := Format(nStr, [sTable_ChineseBase, nArea, sFlag_Yes]);
        //xxxxx

        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        if RecordCount>0 then
        begin
          nCode := nCode + '@6' + Fields[0].AsString + '@7' +
                   Copy(nBill, nPrefixLen + 1, nIDLen - nPrefixLen) +
                   '@2    '; //����
          //����к���,���д���
          nPCCode := '@6' + Fields[0].AsString ;
        end;
      end;

      if nCode = '' then
        nCode := Copy(nBill, nPrefixLen + 1, nIDLen - nPrefixLen);
      //���Ϊ��,������ˮ��

      nCode := nCode + FillString(nCusCode, 2, ' ');
      nCode := nCode + FillString(nSeal, 6, '0');
      {$ELSE}
      //protocol: yymmdd(����ʱ��) + ���κ� + �ͻ�����(������) + ��������(ĩ3λ);
      nCode := nCode + Copy(nBill, nPrefixLen + 1, 6);
      nCode := nCode + FillString(nSeal, 6, '0');
      nCode := nCode + FillString(nCusCode, 2, ' ');
      nCode := nCode + Copy(nBill, nPrefixLen + 7, nIDLen-nPreFixLen-6);
      {$ENDIF}

      {$IFDEF JLNF}
      //���󡢽����������ˮ�����κ�+�ͻ�����(bd_cumandoc.def30)+���ź���λ
      nCode := nSeal + FillString(nCusCode, 2, ' ');
      nCode := nCode + Copy(nTruck, Length(nTruck) - 3, 4);
      {$ENDIF}

      {$IFDEF CZNF}
      //���󡢽����������ˮ�����κ�+�ͻ�����(bd_cumandoc.def30)+���ź���λ
      nCode := nSeal + FillString(nCusCode, 2, ' ');
      nCode := nCode + Copy(nTruck, Length(nTruck) - 3, 4);
      {$ENDIF}

      {$IFDEF XKNF}
      if Pos('-', nSeal) > 0 then
        nSeal := Copy(nSeal, 1, Pos('-', nSeal) - 1);
      nCode := nPCCode + nSeal + FormatDateTime('YYYY',Now)
                 + Copy(nBill, nPrefixLen + 3, 4) ;
      {$ENDIF}

      {$IFDEF XGNF}
      nCode := nSeal + '/' + FormatDateTime('YYYY',Now) + '/'
                 + Copy(nBill, nPrefixLen + 3, 2) + '/'
                 + Copy(nBill, nPrefixLen + 5, 2) + '/' + nCusBz;
      {$ENDIF}

      {$IFDEF JANF}
      nCode := nSeal + FormatDateTime('YYYY',Now)
                 + Copy(nBill, nPrefixLen + 3, 4) ;
      {$ENDIF}

      {$IFDEF LXNF}
      nCode := nSeal + ' ' + FormatDateTime('YYYY',Now)
                 + Copy(nBill, nPrefixLen + 3, 2)
                 + Copy(nBill, nPrefixLen + 5, 2) + ' ' + nCusBz;
      {$ENDIF}

      {$IFDEF YSNF}
      nCode := nPCCode + '@7' + nCusBz + nSeal + '@2    '; //����
      //����к���,���д���
      nCode := nCode + FormatDateTime('YYYY',Now)
                 + Copy(nBill, nPrefixLen + 3, 4) ;
      {$ENDIF}

      {$IFDEF HSNF}
      //��ɽ����������ı���(vdef9)+����+ˮ�����κ�
      if Length(nBm) = 4 then
      begin
        nCode := '@6@R' + Copy(nBm,1,2) + '@R' + Copy(nBm,3,2);
        nCode := nCode + FormatDateTime('YYYY',Now)
                 + Copy(nBill, nPrefixLen + 3, 4) + nSeal;
      end
      else
      begin
        with FOut.FBase do
        begin
          FResult := False;
          FErrCode := 'E.00';
          FErrDesc := Format('������[ %s ]����[ %s ]�����Ϲ���.', [FIn.FData, nBm]);
          Exit;
        end;
      end;
      {$ENDIF}
    end;
  end;

  if not gCodePrinterManager.PrintCode(FIn.FExtParam, nCode, nStr) then
  begin
    with FOut.FBase do
    begin
      FResult := False;
      FErrCode := 'E.00';
      FErrDesc := nStr;
    end;
    //�����¼�
    try
      nEID := FIn.FData + sFlag_ManualF;
      nStr := 'Delete From %s Where E_ID=''%s''';
      nStr := Format(nStr, [sTable_ManualEvent, nEID]);

      gDBConnManager.WorkerExec(FDBConn, nStr);

      nEvent := '��ͨ��[ %s ]���ͽ�����[ %s ]��Υ����[ %s ]ʧ��,�������������.';
      nEvent := Format(nEvent, [FIn.FExtParam, FIn.FData, nCode]);
      nStr := MakeSQLByStr([
          SF('E_ID', nEID),
          SF('E_Key', ''),
          SF('E_From', sFlag_DepJianZhuang),
          SF('E_Event', nEvent),
          SF('E_Solution', sFlag_Solution_OK),
          SF('E_Departmen', sFlag_DepJianZhuang),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    except
      on E: Exception do
      begin
        WriteLog('�����¼�ʧ��:' + e.message);
      end;
    end;
    Exit;
  end;

  nStr := '��ͨ��[ %s ]���ͷ�Υ����[ %s ]�ɹ�.';
  nStr := Format(nStr, [FIn.FExtParam, nCode]);
  WriteLog(nStr);
end;

//Date: 2014-10-01
//Parm: ͨ����[FIn.FData];�Ƿ�����[FIn.FExtParam]
//Desc: ��ָͣ��ͨ���������
function THardwareCommander.PrinterEnable(var nData: string): Boolean;
begin
  Result := True;
  gCodePrinterManager.PrinterEnable(FIn.FData, FIn.FExtParam = sFlag_Yes);
end;

//Date: 2015/10/16
//Parm: ͨ����[FIn.FData];�Ƿ�����[FIn.FExtParam]
//Desc: ��ָͣ��ͨ���������(����)
function THardwareCommander.PrinterChinaEnable(var nData: string): Boolean;
begin
  Result := True;
  gCodePrinterManager.PrinterChinaEnable(FIn.FData, FIn.FExtParam = sFlag_Yes);
end;

function THardwareCommander.PrintFixCode(var nData: string): Boolean;
begin
  Result := True;
end;

//Date: 2014-10-01
//Parm: װ������[FIn.FData]
//Desc: ����װ������
function THardwareCommander.SaveDaiNum(var nData: string): Boolean;
var nStr,nLine,nTruck: string;
    nTask: Int64;
    nVal: Double;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nInt,nPeer,nDai,nTotal: Integer;
begin
  nTask := gTaskMonitor.AddTask('BusinessCommander.SaveDaiNum', cTaskTimeoutLong);
  //to mon

  Result := True;
  FListA.Text := PackerDecodeStr(FIn.FData);

  with FListA do
  begin
    nStr := 'Select * From %s Where T_Bill=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, Values['Bill']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then Exit;
      //not valid

      nLine := FieldByName('T_Line').AsString;
      nTruck := FieldByName('T_Truck').AsString;
      //������Ϣ

      nVal := FieldByName('T_Value').AsFloat;
      nPeer := FieldByName('T_PeerWeight').AsInteger;

      nDai := StrToInt(Values['Dai']);
      nTotal := FieldByName('T_Total').AsInteger + nDai;

      if nPeer < 1 then nPeer := 1;
      nDai := Trunc(nVal / nPeer * 1000);
      //Ӧװ����

      if nDai >= nTotal then
      begin
        nInt := 0;
        nDai := nTotal;
      end else //δװ��
      begin
        nInt := nTotal - nDai;
      end; //��װ��
    end;

    nStr := 'Update %s Set T_Normal=%d,T_BuCha=%d,T_Total=%d Where T_Bill=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nDai, nInt, nTotal, Values['Bill']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;

  gTaskMonitor.DelTask(nTask);
  nTask := gTaskMonitor.AddTask('BusinessCommander.SaveDaiNum2', cTaskTimeoutLong);

  with gTruckQueueManager do
  try
    SyncLock.Enter;
    nInt := GetLine(nLine);

    if nInt < 0 then Exit;
    nPLine := Lines[nInt];
    nInt := TruckInLine(nTruck, nPLine.FTrucks);

    if nInt < 0 then Exit;
    nPTruck := nPLine.FTrucks[nInt];

    nPTruck.FNormal := nDai;
    nPTruck.FBuCha  := nInt;
    nPTruck.FIsBuCha := nDai > 0;
  finally
    SyncLock.Leave;
    gTaskMonitor.DelTask(nTask);
  end;
end;

//Desc: ִ��SQL���
function THardwareCommander.ExecuteSQL(var nData: string): Boolean;
var nInt: Integer;
begin
  Result := True;
  nInt := gDBConnManager.WorkerExec(FDBConn, PackerDecodeStr(FIn.FData));
  FOut.FData := IntToStr(nInt);
end;

//Desc: ����������
function THardwareCommander.StartJS(var nData: string): Boolean;
begin
  FListA.Text := FIn.FData;
  Result := gMultiJSManager.AddJS(FListA.Values['Tunnel'],
            FListA.Values['Truck'], FListA.Values['Bill'],
            StrToInt(FListA.Values['DaiNum']), True);
  //xxxxx
  {$IFDEF JSLED}
  if Result then
    gCounterDisplayManager.SendCounterLedDispInfo(FListA.Values['Truck'],
                                                  FListA.Values['Tunnel'],
                                                  StrToInt(FListA.Values['DaiNum']),
                                                  FListA.Values['StockName']);
  {$ENDIF}
  if not Result then
    nData := '����������ʧ��';
  //xxxxx
end;

//Desc: ��ͣ������
function THardwareCommander.PauseJS(var nData: string): Boolean;
begin
  Result := gMultiJSManager.PauseJS(FIn.FData);
  if not Result then
    nData := '��ͣ������ʧ��';
  //xxxxx
end;

//Desc: ֹͣ������
function THardwareCommander.StopJS(var nData: string): Boolean;
begin
  Result := gMultiJSManager.DelJS(FIn.FData);
  if not Result then
    nData := 'ֹͣ������ʧ��';
  //xxxxx
  {$IFDEF JSLED}
  if Result then
    gCounterDisplayManager.SendFreeToLedDispInfo(FIn.FData);
  {$ENDIF}
end;

//Desc: ������״̬
function THardwareCommander.JSStatus(var nData: string): Boolean;
begin
  gMultiJSManager.GetJSStatus(FListA);
  FOut.FData := FListA.Text;
  Result := True;
end;

//Date: 2014-10-01
//Parm: ͨ����[FIn.FData]
//Desc: ��ȡָ��ͨ���Ĺ�դ״̬
function THardwareCommander.TruckProbe_IsTunnelOK(var nData: string): Boolean;
begin
  Result := True;
  if not Assigned(gProberManager) then
  begin
    FOut.FData := sFlag_Yes;
    Exit;
  end;

  {$IFNDEF TruckProberEx}
  if gProberManager.IsTunnelOK(FIn.FData) then
  {$ELSE}
  if gProberManager.IsTunnelOKEx(FIn.FData) then
  {$ENDIF}
       FOut.FData := sFlag_Yes
  else FOut.FData := sFlag_No;

  nData := Format('IsTunnelOK -> %s:%s', [FIn.FData, FOut.FData]);
  WriteLog(nData);
end;

//Date: 2014-10-01
//Parm: ͨ����[FIn.FData];����[FIn.FExtParam]
//Desc: ����ָ��ͨ��
function THardwareCommander.TruckProbe_TunnelOC(var nData: string): Boolean;
begin
  Result := True;
  if not Assigned(gProberManager) then Exit;

  if FIn.FExtParam = sFlag_Yes then
       gProberManager.OpenTunnel(FIn.FData)
  else gProberManager.CloseTunnel(FIn.FData);

  nData := Format('TunnelOC -> %s:%s', [FIn.FData, FIn.FExtParam]);
  WriteLog(nData);
end;

//Date: 2017/2/8
//Parm: ���������[FIn.FData];����������[FIn.FExtParam]
//Desc: �������򿪵�բ
function THardwareCommander.OpenDoorByReader(var nData: string): Boolean;
var nReader,nIn: string;
    nIdx, nInt: Integer;
    nRItem: PHYReaderItem;
begin
  Result := True;
  {$IFNDEF HYRFID201}
  Exit;
  //δ���õ��ӱ�ǩ������
  {$ENDIF}

  nIn := StringReplace(FIn.FData, 'V', 'H', [rfReplaceAll]);
  //�������������������滻�ɶ�Ӧ����ʵ������

  nInt := -1;
  for nIdx:=gHYReaderManager.Readers.Count-1 downto 0 do
  begin
    nRItem :=  gHYReaderManager.Readers[nIdx];

    if CompareText(nRItem.FID, nIn) = 0 then
    begin
      nInt := nIdx;
      Break;
    end;
  end;

  if nInt < 0 then Exit;
  //reader not exits

  nReader:= '';
  nRItem := gHYReaderManager.Readers[nInt];
  if FIn.FExtParam = sFlag_No then
  begin
    if Assigned(nRItem.FOptions) then
       nReader := nRItem.FOptions.Values['ExtReader'];
  end
  else nReader := nIn;

  if Trim(nReader) <> '' then
    gHYReaderManager.OpenDoor(Trim(nReader));
end;

function THardwareCommander.PlayNetVoice(var nData: string): Boolean;
begin
  Result := True;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if gTruckQueueManager.IsNetPlayVoice and Assigned(gNetVoiceHelper) then
       gNetVoiceHelper.PlayVoice(FListA.Values['Text'], FListA.Values['Card'], FListA.Values['Content'])
  else gVoiceHelper.PlayVoice(FListA.Values['Text']);

  WriteLog('PlayNetVoice:::' + FListA.Text);
end;

//Date: 2017/7/5
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function THardwareCommander.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nPacker.InitData(@nIn, True, False);
    //init

    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2018-02-27
//Parm: ͨ����[FIn.FData] ��������[FIn.FExt]
//Desc: ��ָ��ͨ������ʾ����������
function THardwareCommander.TruckProbe_ShowTxt(var nData: string): Boolean;
begin
  Result := True;
  if not Assigned(gProberManager) then Exit;

  gProberManager.ShowTxt(FIn.FData,FIn.FExtParam);

  nData := Format('ShowTxt -> %s:%s', [FIn.FData, FIn.FExtParam]);
  WriteLog(nData);
end;

//Date: 2018-08-03
//Parm: ������ID[FIn.FData];
//Desc: ��ȡָ����վ�������ϵĸ�λ������
function THardwareCommander.PoundReaderInfo(var nData: string): Boolean;
var nStr, nPoundID: string;
    nIdx: Integer;
begin
  Result := True;

  FOut.FData := gHardwareHelper.GetReaderInfo(FIn.FData, FOut.FExtParam);
end;


//Date: 2018-08-14
//Parm: ��λ[FIn.FData] ��������[FIn.FExt]
//Desc: ��ָ��ͨ������ʾ����������
function THardwareCommander.RemoteSnap_DisPlay(var nData: string): Boolean;
var nInt: Integer;
begin
  Result := True;
  if not Assigned(gHKSnapHelper) then Exit;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FExtParam);

  if FListA.Values['succ'] = sFlag_No then
         nInt := 3
  else nInt := 2;

  gHKSnapHelper.Display(FIn.FData,FListA.Values['text'], nInt);

  nData := Format('RemoteSnapDisPlay -> %s:%s:%s', [FIn.FData,
                                                    FListA.Values['text'],
                                                    FListA.Values['succ']]);
  WriteLog(nData);
end;

function THardwareCommander.ShowLedText(var nData: string): Boolean;
var
  nTunnel, nStr:string;
begin
  nTunnel := FIn.FData;
  nStr := fin.FExtParam;
  gERelayManager.ShowTxt(nTunnel, nStr);
  Result := True;
end;

function THardwareCommander.LineClose(var nData: string): Boolean;
var
  nTunnel:string;
begin
  nTunnel := FIn.FData;
  if FIn.FExtParam = sFlag_No then
    gERelayManager.LineOpen(nTunnel)
  else
    gERelayManager.LineClose(nTunnel);
  Result := True;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(THardwareCommander, sPlug_ModuleHD);
end.
