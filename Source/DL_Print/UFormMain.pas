{*******************************************************************************
  作者: dmzn@163.com 2012-4-21
  描述: 远程打印服务程序
*******************************************************************************}
unit UFormMain;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  IdContext, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer,
  IdGlobal, UMgrRemotePrint, SyncObjs, UTrayIcon, StdCtrls, ExtCtrls,
  ComCtrls, DateUtils;

type
  TfFormMain = class(TForm)
    GroupBox1: TGroupBox;
    MemoLog: TMemo;
    StatusBar1: TStatusBar;
    CheckSrv: TCheckBox;
    EditPort: TLabeledEdit;
    IdTCPServer1: TIdTCPServer;
    CheckAuto: TCheckBox;
    CheckLoged: TCheckBox;
    Timer1: TTimer;
    BtnConn: TButton;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckSrvClick(Sender: TObject);
    procedure CheckLogedClick(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure BtnConnClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
    FTrayIcon: TTrayIcon;
    {*状态栏图标*}
    FIsBusy: Boolean;
    //打印状态
    FBillList: TStrings;
    FSyncLock: TCriticalSection;
    //同步锁
    FNoPrintLoad: Boolean;
    FNoPrint: TStrings;
    //无需打印
    procedure ShowLog(const nStr: string);
    //显示日志
    procedure DoExecute(const nContext: TIdContext);
    //执行动作
    function IsPrintStock(const nStock: string): Boolean;
    //是否打印
    function PrintOrderReport(const nOrder: string; var nHint: string;
      const nPrinter: string = ''; const nMoney: string = '0'): Boolean;
    function PrintPoundReport(const nPID: string; var nHint: string;
      const nPrinter: string = ''): Boolean;
    procedure PrintBill(var nBase: TRPDataBase;var nBuf: TIdBytes;nCtx: TIdContext);
    //打印单据 
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}
uses
  IniFiles, Registry, ULibFun, UDataModule, UDataReport, USysLoger, UFormConn,
  DB, USysDB;

var
  gPath: string;               //程序路径

resourcestring
  sHint               = '提示';
  sConfig             = 'Config.Ini';
  sForm               = 'FormInfo.Ini';
  sDB                 = 'DBConn.Ini';
  sAutoStartKey       = 'RemotePrinter';

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '打印服务主单元', nEvent);
end;

//------------------------------------------------------------------------------
procedure TfFormMain.FormCreate(Sender: TObject);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath+sConfig, gPath+sForm, gPath+sDB);
  
  gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  gSysLoger.LogEvent := ShowLog;

  FTrayIcon := TTrayIcon.Create(Self);
  FTrayIcon.Hint := Caption;
  FTrayIcon.Visible := True;

  FIsBusy   := False;
  FNoPrint  := TStringList.Create;
  FBillList := TStringList.Create;
  FSyncLock := TCriticalSection.Create;
  //new item

  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    EditPort.Text := nIni.ReadString('Config', 'Port', '8000');
    Timer1.Enabled := nIni.ReadBool('Config', 'Enabled', False);

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    CheckAuto.Checked := nReg.ValueExists(sAutoStartKey);
  finally
    nIni.Free;
    nReg.Free;
  end;

  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  //数据库连接
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    //nIni.WriteString('Config', 'Port', EditPort.Text);
    nIni.WriteBool('Config', 'Enabled', CheckSrv.Enabled);

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    if CheckAuto.Checked then
      nReg.WriteString(sAutoStartKey, Application.ExeName)
    else if nReg.ValueExists(sAutoStartKey) then
      nReg.DeleteValue(sAutoStartKey);
    //xxxxx
  finally
    nIni.Free;
    nReg.Free;
  end;

  FNoPrint.Free;
  FBillList.Free;
  FSyncLock.Free;
end;

procedure TfFormMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  CheckSrv.Checked := True;
end;

procedure TfFormMain.CheckSrvClick(Sender: TObject);
begin
  if not IdTCPServer1.Active then
    IdTCPServer1.DefaultPort := StrToInt(EditPort.Text);
  IdTCPServer1.Active := CheckSrv.Checked;

  BtnConn.Enabled := not CheckSrv.Checked;
  EditPort.Enabled := not CheckSrv.Checked;

  FSyncLock.Enter;
  try
    FNoPrint.Clear;
    FNoPrintLoad := False;
    
    FBillList.Clear;
    Timer2.Enabled := CheckSrv.Checked;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TfFormMain.CheckLogedClick(Sender: TObject);
begin
  gSysLoger.LogSync := CheckLoged.Checked;
end;

procedure TfFormMain.ShowLog(const nStr: string);
var nIdx: Integer;
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Lines.Insert(0, nStr);
    if MemoLog.Lines.Count > 100 then
     for nIdx:=MemoLog.Lines.Count - 1 downto 50 do
      MemoLog.Lines.Delete(nIdx);
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

//Desc: 测试nConnStr是否有效
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

//Desc: 数据库配置
procedure TfFormMain.BtnConnClick(Sender: TObject);
begin
  if ShowConnectDBSetupForm(ConnCallBack) then
  begin
    FDM.ADOConn.Close;
    FDM.ADOConn.ConnectionString := BuildConnectDBStr;
    //数据库连接
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormMain.IdTCPServer1Execute(AContext: TIdContext);
begin
  try
    DoExecute(AContext);
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

procedure TfFormMain.DoExecute(const nContext: TIdContext);
var nBuf: TIdBytes;
    nBase: TRPDataBase;
begin
  with nContext.Connection do
  begin
    Socket.ReadBytes(nBuf, cSizeRPBase, False);
    BytesToRaw(nBuf, nBase, cSizeRPBase);

    case nBase.FCommand of
     cRPCmd_PrintBill :
      begin
        PrintBill(nBase, nBuf, nContext);
        //print
      end;
    end;
  end;
end;

//Date: 2017-12-07
//Parm: 物料号
//Desc: 判断nStock是否需要打印
function TfFormMain.IsPrintStock(const nStock: string): Boolean;
var nStr: string;
begin
  if not FNoPrintLoad then
  begin
    FNoPrintLoad := True;
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NOPrintBill]);

    with FDM.SQLQuery(nStr, FDM.SQLTemp) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        nStr := Trim(Fields[0].AsString);
        FNoPrint.Add(nStr);
        Next;
      end;
    end;
  end;

  Result := (FNoPrint.Count < 1) or (FNoPrint.IndexOf(nStock) < 0);
  //不在无需打印列表
end;

//Date: 2012-4-1
//Parm: 采购单号;提示;数据对象;打印机
//Desc: 打印nOrder采购单号
function TfFormMain.PrintOrderReport(const nOrder: string; var nHint: string;
 const nPrinter: string; const nMoney: string): Boolean;
var nStr: string;
    nDS: TDataSet;
begin
  Result := False;
  nStr := 'Select * From %s Where D_ID=''%s''';
  nStr := Format(nStr, [sTable_ProvDtl, nOrder]);

  WriteLog('采购单号SQL:'+nStr);
  nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nHint := '采购单[ %s ] 已无效!!';
    nHint := Format(nHint, [nOrder]);
    Exit;
  end;

  nStr := gPath + 'Report\PurchaseOrder.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件';
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

function TfFormMain.PrintPoundReport(const nPID: string; var nHint: string;
 const nPrinter: string): Boolean;
var nStr: string;
    nDS: TDataSet;
begin
  Result := False;
  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, nPID]);

  nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nHint := '磅单[ %s ] 已无效!!';
    nHint := Format(nHint, [nPID]);
    Exit;
  end;

  nStr := nDS.FieldByName('P_MID').AsString;
  if not IsPrintStock(nStr) then
  begin
    nHint := '品种[ %s.%s]无需打印';
    nHint := Format(nHint, [nStr, nDS.FieldByName('P_MName').AsString]);
    Exit;
  end;

  nStr := gPath + 'Report\Pound.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件';
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-1
//Parm: 交货单号;提示;数据对象;打印机
//Desc: 打印nBill交货单号
function PrintBillReport(nBill: string; var nHint: string;
 const nPrinter: string = ''; const nMoney: string = '0'): Boolean;
var nStr,nIDs: string;
    nDS: TDataSet;
    nInt: Integer;
    nValue,nP,nM: Double;
    nParam: TReportParamItem;
begin
  Result := False;
  {$IFDEF CombinePrintBill}
  if Copy(nBill, 1, 1) <> '''' then
    nBill := '''' + nBill;
  if Copy(nBill, Length(nBill), 1) <> '''' then
    nBill := nBill + '''';
  //add flag

  nStr := 'Select * From %s b ' +
          ' Left Join %s p on b.L_ID=p.P_Bill ' +
          ' Left Join %s t on b.L_Truck=t.T_Truck ' +
          ' Where L_ID In (%s)';
  nStr := Format(nStr, [sTable_Bill, sTable_PoundLog, sTable_Truck, nBill]);
  {$ELSE}
  nStr := 'Select *,%s As L_ValidMoney From %s b ' +
          ' Left Join %s p on b.L_ID=p.P_Bill ' +
          ' Left Join %s t on b.L_Truck=t.T_Truck ' +
          ' Where L_ID=''%s''';
  nStr := Format(nStr, [nMoney, sTable_Bill, sTable_PoundLog, sTable_Truck, nBill]);
  {$ENDIF}

  WriteLog('交货单号SQL:'+nStr);
  nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nHint := '交货单[ %s ] 已无效!!';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;

  {$IFDEF DaiNoPrint}
  if nDS.FieldByName('L_Type').AsString = sFlag_Dai then
  begin
    nStr := '交货单[ %s ] 提货类型为袋装,无需打印交货单';
    nStr := Format(nStr, [nBill]);
    WriteLog(nStr);
    Exit;
  end;
  {$ENDIF}

  nStr := gPath + 'Report\LadingBill.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件';
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  nValue := 0;
  nIDs := '';
  nP := 0;
  nM := 0;

  {$IFDEF CombinePrintBill}
  with nDS do
  begin
    First;
    while not Eof do
    begin
      nValue := nValue + FieldByName('L_Value').AsFloat;
      //累计发货量
      nIDs := nIDs + FieldByName('L_ID').AsString;
      //拼接单据号

      if nP = 0 then
        nP := FieldByName('L_PValue').AsFloat;
      //皮重固定

      Next;
      if not Eof then
        nIDs := nIDs + ',';
      //xxxxx
    end;

    if nM = 0 then
      nM := nP + nValue;
    //合计毛重

    nInt := Pos(',', nBill);
    if nInt > 0 then
    begin
      nBill := Copy(nBill, 1, nInt - 1);
      //多张单据时取第一个

      nStr := 'Select * From %s b ' +
              ' Left Join %s t on b.L_Truck=t.T_Truck ' +
              ' Left Join %s p on b.L_ID=p.P_Bill Where L_ID In (%s)';
      nStr := Format(nStr, [sTable_Bill, sTable_Truck, sTable_PoundLog, nBill]);
      FDM.SQLQuery(nStr, FDM.SQLQuery1);
    end;
  end;
  {$ENDIF}

  nParam.FName := 'L_ID';
  nParam.FValue := nIDs;
  FDR.AddParamItem(nParam);

  nParam.FName := 'L_Value';
  nParam.FValue := nValue;
  FDR.AddParamItem(nParam);

  nParam.FName := 'L_PValue';
  nParam.FValue := nP;
  FDR.AddParamItem(nParam);

  nParam.FName := 'L_MValue';
  nParam.FValue := nM;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 获取nStock品种的报表文件
function GetReportFileByStock(const nStock: string; var nBrand: string): string;
begin
  Result := GetPinYinOfStr(nStock);

  {$IFNDEF GetReportByBrand}
  nBrand := '';
  {$ENDIF}

  if nBrand = '' then
  begin
    if Pos('dj', Result) > 0 then
      Result := gPath + 'Report\HuaYan42_DJ.fr3'
    else if Pos('gsysl', Result) > 0 then
      Result := gPath + 'Report\HuaYan_gsl.fr3'
    else if Pos('kzf', Result) > 0 then
      Result := gPath + 'Report\HuaYan_kzf.fr3'
    else if Pos('qz', Result) > 0 then
      Result := gPath + 'Report\HuaYan_qz.fr3'
    else if Pos('32', Result) > 0 then
      Result := gPath + 'Report\HuaYan32.fr3'
    else if Pos('42', Result) > 0 then
      Result := gPath + 'Report\HuaYan42.fr3'
    else if Pos('52', Result) > 0 then
      Result := gPath + 'Report\HuaYan42.fr3'
    else Result := '';
  end
  else
  begin
    if Pos('dj', Result) > 0 then
      Result := gPath + 'Report\HuaYan42_DJ' + nBrand +'.fr3'
    else if Pos('gsysl', Result) > 0 then
      Result := gPath + 'Report\HuaYan_gsl' + nBrand +'.fr3'
    else if Pos('kzf', Result) > 0 then
      Result := gPath + 'Report\HuaYan_kzf' + nBrand +'.fr3'
    else if Pos('qz', Result) > 0 then
      Result := gPath + 'Report\HuaYan_qz' + nBrand +'.fr3'
    else if Pos('32', Result) > 0 then
      Result := gPath + 'Report\HuaYan32' + nBrand +'.fr3'
    else if Pos('42', Result) > 0 then
      Result := gPath + 'Report\HuaYan42' + nBrand +'.fr3'
    else if Pos('52', Result) > 0 then
      Result := gPath + 'Report\HuaYan42' + nBrand +'.fr3'
    else Result := '';
  end;
end;

//Desc: 获取nStock品种的报表文件(从数据库获取模板名称)
function GetReportFileByStockFromDB(const nStock, nBrand: string): string;
var nStr, nWhere: string;
begin
  Result := '';
  if nBrand <> '' then
  begin
    nWhere := ' and D_ParamB = ''%s'' ';
    nWhere := Format(nWhere, [nBrand]);
  end
  else
    nWhere := '';

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo = ''%s'' %s order by D_ID desc';
  nStr := Format(nStr, [sTable_SysDict, sFlag_ReportFileMap, nStock, nWhere]);

  with FDM.SQLQuery(nStr, FDM.SqlTemp) do
  begin
    if RecordCount > 0 then
    begin
      Result := gPath + 'Report\' + Fields[0].AsString;
    end;
  end;
end;

//Desc: 打印标识为nHID的化验单
function PrintHuaYanReport(const nBill: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
var nStr,nSR, nSeal,nDate3D,nDate28D,n28Ya1,nBrand,nStock,nReport: string;
    nDate: TDateTime;
begin
  nHint := '';
  Result := False;

  nStr := 'Select sb.L_Seal,sr.R_28Ya1,sb.L_PrintHY,sb.L_Type,sb.L_StockBrand,sb.L_StockName From %s sb ' +
          ' Left Join %s sr on sr.R_SerialNo=sb.L_Seal ' +
          ' Where sb.L_ID = ''%s''';
  nStr := Format(nStr, [sTable_Bill, sTable_StockRecord, nBill]);

  with FDM.SQLQuery(nStr, FDM.SqlTemp) do
  begin
    if RecordCount > 0 then
    begin
      nSeal := Fields[0].AsString;
      n28Ya1 := Fields[1].AsString;
      nBrand := Fields[4].AsString;
      nStock := Fields[5].AsString;
      if Fields[2].AsString <> sFlag_Yes then
      begin
        Result := True;
        nHint := '提货单[ %s ]无需打印化验单';
        nHint := Format(nHint, [nBill]);
        Exit;
      end;
    end;
  end;

  nReport := GetReportFileByStockFromDB(nStock, nBrand);

  nDate3D := FormatDateTime('YYYY-MM-DD HH:MM:SS', Now);
  nDate28D := nDate3D;
  nStr := 'Select top 1 L_Date From %s Where L_Seal = ''%s'' order by L_Date';
  nStr := Format(nStr, [sTable_Bill, nSeal]);

  with FDM.SQLQuery(nStr, FDM.SqlTemp) do
  begin
    if RecordCount > 0 then
    begin
      nDate3D := Fields[0].AsString;
      try
        nDate := StrToDateTime(nDate3D);
        if n28Ya1 <> '' then
          nDate := IncDay(nDate,29);
        nDate28D := FormatDateTime('YYYY-MM-DD HH:MM:SS', nDate);
      except
      end;
    end;
  end;
  
  nSR := 'Select * From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select hy.*,sr.*,b.*,C_Name,''$DD'' as R_Date3D,''$TD'' as R_Date28D From $HY hy ' +
          ' Left Join $Bill b On b.L_ID=hy.H_Bill ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          'Where H_Bill=''$ID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$DD', nDate3D), MI('$TD', nDate28D),
          MI('$HY', sTable_StockHuaYan), MI('$Bill', sTable_Bill),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nBill)]);
  //xxxxx
  WriteLog('化验单查询:'+nStr);

  if FDM.SQLQuery(nStr, FDM.SqlTemp).RecordCount < 1 then
  begin
    nHint := '提货单[ %s ]没有对应的化验单';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;

//  nStr := FDM.SqlTemp.FieldByName('P_Stock').AsString;
//  nStr := GetReportFileByStock(nStr, nBrand);

  if (nReport = '') or (not FDR.LoadReportFile(nReport)) then
  begin
    nHint := '无法正确加载报表文件: ' + nReport;
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
  if Result then
  begin
    nStr := 'Update %s Set L_HyPrintCount=L_HyPrintCount + 1 ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nBill]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Desc: 打印标识为nID的合格证
function PrintHeGeReport(const nBill: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
var nStr,nSR: string;
    nField: TField;
    nStockNo, nStockName: string;
begin
  nHint := '';
  Result := False;

  nStr := 'Select L_StockNo, L_StockName from %s b ' +
          'Where b.L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  with FDM.SQLQuery(nStr, FDM.SqlTemp) do
  begin
    if RecordCount < 1 then
    begin
      nHint := '提货单[ %s ]已无效';
      nHint := Format(nHint, [nBill]);
      Exit;
    end;
    nStockNo := Fields[0].AsString;
    nStockName := Fields[1].AsString;
  end;

  nStr := 'Select D_Value from %s ' +
          'Where D_Name=''%s'' and D_Memo =''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_NoPrintHeGe, nStockNo]);

  with FDM.SQLQuery(nStr, FDM.SqlTemp) do
  begin
    if RecordCount > 0 then
    begin
      if Fields[0].AsString = sFlag_Yes then
      begin
        nHint := '提货单[ %s ]物料[ %s ]无需打印合格证';
        nHint := Format(nHint, [nBill, nStockName]);
        Exit;
      end;
    end;
  end;

  {$IFDEF HeGeZhengSimpleData}
  nSR := 'Select * from %s b ' +
          ' Left Join %s sp On sp.P_Stock=b.L_StockName ' +
          'Where b.L_ID=''%s''';
  nStr := Format(nSR, [sTable_Bill, sTable_StockParam, nBill]);
  {$ELSE}
  nSR := 'Select R_SerialNo,P_Stock,P_Name,P_QLevel From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select hy.*,sr.*,C_Name From $HY hy ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          'Where H_Bill=''$ID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nBill)]);
  //xxxxx
  {$ENDIF}

  if FDM.SQLQuery(nStr, FDM.SqlTemp).RecordCount < 1 then
  begin
    nHint := '提货单[ %s ]没有对应的合格证';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;

//  with FDM.SqlTemp do
//  begin
//    nField := FindField('L_PrintHY');
//    if Assigned(nField) and (nField.AsString <> sFlag_Yes) then
//    begin
//      nHint := '交货单[ %s ]无需打印合格证.';
//      nHint := Format(nHint, [nBill]);
//      Exit;
//    end;
//  end;

  nStr := gPath + 'Report\HeGeZheng.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件: ' + nStr;
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := nPrinter;
  
  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 打印单据
procedure TfFormMain.PrintBill(var nBase: TRPDataBase; var nBuf: TIdBytes;
  nCtx: TIdContext);
var nStr: WideString;
begin
  nCtx.Connection.Socket.ReadBytes(nBuf, nBase.FDataLen, False);
  nStr := Trim(BytesToString(nBuf));

  FSyncLock.Enter;
  try
    FBillList.Add(nStr);
  finally
    FSyncLock.Leave;
  end;

  WriteLog(Format('添加打印交货单: %s', [nStr]));
  //loged
end;

procedure TfFormMain.Timer2Timer(Sender: TObject);
var nPos: Integer;
    nBill,nHint,nPrinter,nMoney, nType, nHYPrinter: string;
begin
    if not FIsBusy then
    begin
      FSyncLock.Enter;
      try
        if FBillList.Count < 1 then Exit;
        nBill := FBillList[0];
        FBillList.Delete(0);
      finally
        FSyncLock.Leave;
      end;

      //bill #9 printer #8 money #7 CardType #6 HYPrinter
      nPos := Pos(#6, nBill);
      if nPos > 1 then
      begin
        nHYPrinter := nBill;
        nBill := Copy(nBill, 1, nPos - 1);
        System.Delete(nHYPrinter, 1, nPos);
      end else nHYPrinter := '';

      nPos := Pos(#7, nBill);
      if nPos > 1 then
      begin
        nType := nBill;
        nBill := Copy(nBill, 1, nPos - 1);
        System.Delete(nType, 1, nPos);
      end else nType := '';

      nPos := Pos(#8, nBill);
      if nPos > 1 then
      begin
        nMoney := nBill;
        nBill := Copy(nBill, 1, nPos - 1);
        System.Delete(nMoney, 1, nPos);

        if not IsNumber(nMoney, True) then
          nMoney := '0';
        //xxxxx
      end else nMoney := '0';

      nPos := Pos(#9, nBill);
      if nPos > 1 then
      begin
        nPrinter := nBill;
        nBill := Copy(nBill, 1, nPos - 1);
        System.Delete(nPrinter, 1, nPos);
      end else nPrinter := '';

      if Length(nPrinter) < 1 then Exit;
      //未指定打印机则禁止打印

      FIsBusy := True;
      try
        WriteLog('开始打印: ' + nBill);
        if (nType = sFlag_Provide) then
             PrintOrderReport(nBill, nHint, nPrinter) else
        if (nType = sFlag_Sale) or (nType = sFlag_SaleNew) then
        begin
          PrintBillReport(nBill, nHint, nPrinter, nMoney);
          if nHint <> '' then WriteLog(nHint);

          {$IFDEF PrintHuaYanDan}
          PrintHuaYanReport(nBill, nHint, nHYPrinter);
          if nHint <> '' then WriteLog(nHint);
          {$ENDIF}

          {$IFDEF PrintHeGeZheng}
          PrintHeGeReport(nBill, nHint, nHYPrinter);
          if nHint <> '' then WriteLog(nHint);
          {$ENDIF}
        end
        else PrintPoundReport(nBill, nHint, nPrinter);
        WriteLog('打印结束.' + nHint);
      finally
        FIsBusy := False;
      end;
    end;
end;

end.
