{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
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
    //错误码
    FDBConn: PDBWorker;
    //数据通道
    FDataIn,FDataOut: PBWDataBase;
    //入参出参
    FDataOutNeedUnPack: Boolean;
    //需要解包
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //出入参数
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //验证入参
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //数据业务
  public
    function DoWork(var nData: string): Boolean; override;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
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
    //切换调度模式
    function PoundCardNo(var nData: string): Boolean;
    //读取磅站卡号
    function PoundReaderInfo(var nData: string): Boolean;
    //读取磅站读卡器岗位、部门
    function LoadQueue(var nData: string): Boolean;
    //读取车辆队列
    function ExecuteSQL(var nData: string): Boolean;
    //执行SQL语句
    function SaveDaiNum(var nData: string): Boolean;
    //保存计数数据
    function PrintCode(var nData: string): Boolean;
    function PrintFixCode(var nData: string): Boolean;
    //喷码机打印编码
    function PrinterEnable(var nData: string): Boolean;
    function PrinterChinaEnable(var nData: string): Boolean;
    //启停喷码机
    function StartJS(var nData: string): Boolean;
    function PauseJS(var nData: string): Boolean;
    function StopJS(var nData: string): Boolean;
    function JSStatus(var nData: string): Boolean;
    //计数器业务
    function TruckProbe_IsTunnelOK(var nData: string): Boolean;
    function TruckProbe_TunnelOC(var nData: string): Boolean;
    function TruckProbe_ShowTxt(var nData: string): Boolean;
    //车辆检测控制器业务
    function OpenDoorByReader(var nData: string): Boolean;
    //通过读卡器打开道闸
    function PlayNetVoice(var nData: string): Boolean;
    //网络语音播放
    function RemoteSnap_DisPlay(var nData: string): Boolean;
    //抓拍小屏显示
    function ShowLedText(var nData: string): Boolean;
    //定制放灰调用小屏显示
    function LineClose(var nData: string): Boolean;
    //定制放灰
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
//Parm: 如参数护具
//Desc: 获取连接数据库所需的资源
function THardwareDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '连接数据库失败(DBConn Is Null).';
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
//Parm: 输出数据;结果
//Desc: 数据业务执行完毕后的收尾操作
function THardwareDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: 入参数据
//Desc: 验证入参数据是否有效
function THardwareDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: 记录nEvent日志
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
//Parm: 输入数据
//Desc: 执行nData业务指令
function THardwareCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
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
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//Date: 2014-10-07
//Parm: 调度模式[FIn.FData]
//Desc: 切换系统调度模式
function THardwareCommander.ChangeDispatchMode(var nData: string): Boolean;
var nStr,nSQL: string;
begin
  Result := True;
  nSQL := 'Update %s Set D_Value=''%s'' Where D_Name=''%s'' And D_Memo=''%s''';

  if FIn.FData = '1' then
  begin
    nStr := Format(nSQL, [sTable_SysDict, sFlag_No, sFlag_SysParam,
            sFlag_SanMultiBill]);
    gDBConnManager.WorkerExec(FDBConn, nStr); //关闭散装预开

    nStr := Format(nSQL, [sTable_SysDict, '20', sFlag_SysParam,
            sFlag_InTimeout]);
    gDBConnManager.WorkerExec(FDBConn, nStr); //缩短进厂超时

    gTruckQueueManager.RefreshParam;
    //使用新调度参数
  end else

  if FIn.FData = '2' then
  begin
    nStr := Format(nSQL, [sTable_SysDict, sFlag_Yes, sFlag_SysParam,
            sFlag_SanMultiBill]);
    gDBConnManager.WorkerExec(FDBConn, nStr); //启用散装预开

    nStr := Format(nSQL, [sTable_SysDict, '1440', sFlag_SysParam,
            sFlag_InTimeout]);
    gDBConnManager.WorkerExec(FDBConn, nStr); //延长进厂超时

    gTruckQueueManager.RefreshParam;
    //使用新调度参数
  end;
end;

//Date: 2014-10-01
//Parm: 磅站号[FIn.FData];取卡号标记当标记为'Y'时，返回读卡器读到卡号
//Desc: 获取指定磅站读卡器上的磁卡号
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
    //将远距离卡号对应的近距离卡号绑定
  end;
end;

//Date: 2014-10-01
//Parm: 是否刷新[FIn.FData]
//Desc: 读取队列数据
function THardwareCommander.LoadQueue(var nData: string): Boolean;
var nVal: Double;
    i,nIdx: Integer;
    nLine: PLineItem;
    nTruck: PTruckItem;
begin
  gTruckQueueManager.RefreshTrucks(FIn.FData = sFlag_Yes);
  Sleep(320);
  //刷新数据

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
      //判断是否VIP

      if nLine.FIsValid then
           FListB.Values['Valid'] := sFlag_Yes
      else FListB.Values['Valid'] := sFlag_No;

      if gCodePrinterManager.IsPrinterEnable(nLine.FLineID) then
           FListB.Values['Printer'] := sFlag_Yes
      else FListB.Values['Printer'] := sFlag_No;

      FListB.Values['LineGroup'] := nLine.FLineGroup;

      FListC.Add(PackerEncodeStr(FListB.Text));
      //单线数据
    end;

    FListA.Values['Lines'] := PackerEncodeStr(FListC.Text);
    //通道列表
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
        //单线数据
      end;
    end;

    FListA.Values['Trucks'] := PackerEncodeStr(FListC.Text);
    //车辆列表
    FOut.FData := PackerEncodeStr(FListA.Text);
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2015/1/22
//Parm: 源字符串；指定长度；左补字符;补充方式
//Desc: 将源字符串(nStr)"左(Fasle)/右(True)"补(Length(nStr)-nLen)个字符(nFillStr),
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
//Parm: 交货单[FIn.FData];通道号[FIn.FExtParam]
//Desc: 在指定通道上喷码
function THardwareCommander.PrintCode(var nData: string): Boolean;
var nStr,nBill,nCode,nArea,nCusCode,nSeal,nTruck,nBm,nPCCode,nCusBz: string;
    nPrefixLen, nIDLen: Integer;
    nEvent,nEID:string;
begin
  Result := True;
  if not gCodePrinterManager.EnablePrinter then Exit;

  nStr := '向通道[ %s ]发送交货单[ %s ]防违流码.';
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
    //固定喷码
  end else
  begin
    if (nPrefixLen<0) or (nIDLen<0) then Exit;
    //无提货单配置

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
        FErrDesc := Format('交货单[ %s ]已无效.', [FIn.FData]); Exit;
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
      //protocol: 汉字喷码+客户代码(区域码) + 交货单号(末3位) + 批次号;
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
                   '@2    '; //换行
          //如果有汉字,则换行处理
          nPCCode := '@6' + Fields[0].AsString ;
        end;
      end;

      if nCode = '' then
        nCode := Copy(nBill, nPrefixLen + 1, nIDLen - nPrefixLen);
      //如果为空,则喷流水号

      nCode := nCode + FillString(nCusCode, 2, ' ');
      nCode := nCode + FillString(nSeal, 6, '0');
      {$ELSE}
      //protocol: yymmdd(开单时间) + 批次号 + 客户代码(区域码) + 交货单号(末3位);
      nCode := nCode + Copy(nBill, nPrefixLen + 1, 6);
      nCode := nCode + FillString(nSeal, 6, '0');
      nCode := nCode + FillString(nCusCode, 2, ' ');
      nCode := nCode + Copy(nBill, nPrefixLen + 7, nIDLen-nPreFixLen-6);
      {$ENDIF}

      {$IFDEF JLNF}
      //崇左、金鲤喷码规则：水泥批次号+客户代码(bd_cumandoc.def30)+车号后四位
      nCode := nSeal + FillString(nCusCode, 2, ' ');
      nCode := nCode + Copy(nTruck, Length(nTruck) - 3, 4);
      {$ENDIF}

      {$IFDEF CZNF}
      //崇左、金鲤喷码规则：水泥批次号+客户代码(bd_cumandoc.def30)+车号后四位
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
      nCode := nPCCode + '@7' + nCusBz + nSeal + '@2    '; //换行
      //如果有汉字,则换行处理
      nCode := nCode + FormatDateTime('YYYY',Now)
                 + Copy(nBill, nPrefixLen + 3, 4) ;
      {$ENDIF}

      {$IFDEF HSNF}
      //黄山喷码规则：中文编码(vdef9)+日期+水泥批次号
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
          FErrDesc := Format('交货单[ %s ]编码[ %s ]不符合规则.', [FIn.FData, nBm]);
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
    //生成事件
    try
      nEID := FIn.FData + sFlag_ManualF;
      nStr := 'Delete From %s Where E_ID=''%s''';
      nStr := Format(nStr, [sTable_ManualEvent, nEID]);

      gDBConnManager.WorkerExec(FDBConn, nStr);

      nEvent := '向通道[ %s ]发送交货单[ %s ]防违流码[ %s ]失败,请检查喷码机网络.';
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
        WriteLog('保存事件失败:' + e.message);
      end;
    end;
    Exit;
  end;

  nStr := '向通道[ %s ]发送防违流码[ %s ]成功.';
  nStr := Format(nStr, [FIn.FExtParam, nCode]);
  WriteLog(nStr);
end;

//Date: 2014-10-01
//Parm: 通道号[FIn.FData];是否启用[FIn.FExtParam]
//Desc: 启停指定通道的喷码机
function THardwareCommander.PrinterEnable(var nData: string): Boolean;
begin
  Result := True;
  gCodePrinterManager.PrinterEnable(FIn.FData, FIn.FExtParam = sFlag_Yes);
end;

//Date: 2015/10/16
//Parm: 通道号[FIn.FData];是否启用[FIn.FExtParam]
//Desc: 启停指定通道的喷码机(汉字)
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
//Parm: 装车数据[FIn.FData]
//Desc: 保存装车数据
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
      //队列信息

      nVal := FieldByName('T_Value').AsFloat;
      nPeer := FieldByName('T_PeerWeight').AsInteger;

      nDai := StrToInt(Values['Dai']);
      nTotal := FieldByName('T_Total').AsInteger + nDai;

      if nPeer < 1 then nPeer := 1;
      nDai := Trunc(nVal / nPeer * 1000);
      //应装袋数

      if nDai >= nTotal then
      begin
        nInt := 0;
        nDai := nTotal;
      end else //未装完
      begin
        nInt := nTotal - nDai;
      end; //已装超
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

//Desc: 执行SQL语句
function THardwareCommander.ExecuteSQL(var nData: string): Boolean;
var nInt: Integer;
begin
  Result := True;
  nInt := gDBConnManager.WorkerExec(FDBConn, PackerDecodeStr(FIn.FData));
  FOut.FData := IntToStr(nInt);
end;

//Desc: 启动计数器
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
    nData := '启动计数器失败';
  //xxxxx
end;

//Desc: 暂停计数器
function THardwareCommander.PauseJS(var nData: string): Boolean;
begin
  Result := gMultiJSManager.PauseJS(FIn.FData);
  if not Result then
    nData := '暂停计数器失败';
  //xxxxx
end;

//Desc: 停止计数器
function THardwareCommander.StopJS(var nData: string): Boolean;
begin
  Result := gMultiJSManager.DelJS(FIn.FData);
  if not Result then
    nData := '停止计数器失败';
  //xxxxx
  {$IFDEF JSLED}
  if Result then
    gCounterDisplayManager.SendFreeToLedDispInfo(FIn.FData);
  {$ENDIF}
end;

//Desc: 计数器状态
function THardwareCommander.JSStatus(var nData: string): Boolean;
begin
  gMultiJSManager.GetJSStatus(FListA);
  FOut.FData := FListA.Text;
  Result := True;
end;

//Date: 2014-10-01
//Parm: 通道号[FIn.FData]
//Desc: 获取指定通道的光栅状态
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
//Parm: 通道号[FIn.FData];开合[FIn.FExtParam]
//Desc: 开合指定通道
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
//Parm: 读卡器编号[FIn.FData];读卡器类型[FIn.FExtParam]
//Desc: 读卡器打开道闸
function THardwareCommander.OpenDoorByReader(var nData: string): Boolean;
var nReader,nIn: string;
    nIdx, nInt: Integer;
    nRItem: PHYReaderItem;
begin
  Result := True;
  {$IFNDEF HYRFID201}
  Exit;
  //未启用电子标签读卡器
  {$ENDIF}

  nIn := StringReplace(FIn.FData, 'V', 'H', [rfReplaceAll]);
  //如果是虚拟读卡器，则替换成对应的真实读卡器

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
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
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
//Parm: 通道号[FIn.FData] 发送内容[FIn.FExt]
//Desc: 向指定通道的显示屏发送内容
function THardwareCommander.TruckProbe_ShowTxt(var nData: string): Boolean;
begin
  Result := True;
  if not Assigned(gProberManager) then Exit;

  gProberManager.ShowTxt(FIn.FData,FIn.FExtParam);

  nData := Format('ShowTxt -> %s:%s', [FIn.FData, FIn.FExtParam]);
  WriteLog(nData);
end;

//Date: 2018-08-03
//Parm: 读卡器ID[FIn.FData];
//Desc: 获取指定磅站读卡器上的岗位、部门
function THardwareCommander.PoundReaderInfo(var nData: string): Boolean;
var nStr, nPoundID: string;
    nIdx: Integer;
begin
  Result := True;

  FOut.FData := gHardwareHelper.GetReaderInfo(FIn.FData, FOut.FExtParam);
end;


//Date: 2018-08-14
//Parm: 岗位[FIn.FData] 发送内容[FIn.FExt]
//Desc: 向指定通道的显示屏发送内容
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
