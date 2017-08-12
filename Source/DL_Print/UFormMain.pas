{*******************************************************************************
  ����: dmzn@163.com 2012-4-21
  ����: Զ�̴�ӡ�������
*******************************************************************************}
unit UFormMain;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  IdContext, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer,
  IdGlobal, UMgrRemotePrint, SyncObjs, UTrayIcon, StdCtrls, ExtCtrls,
  ComCtrls;

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
    {*״̬��ͼ��*}
    FIsBusy: Boolean;
    //��ӡ״̬
    FBillList: TStrings;
    FSyncLock: TCriticalSection;
    //ͬ����
    procedure ShowLog(const nStr: string);
    //��ʾ��־
    procedure DoExecute(const nContext: TIdContext);
    //ִ�ж���
    procedure PrintBill(var nBase: TRPDataBase;var nBuf: TIdBytes;nCtx: TIdContext);
    //��ӡ����
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
  gPath: string;               //����·��

resourcestring
  sHint               = '��ʾ';
  sConfig             = 'Config.Ini';
  sForm               = 'FormInfo.Ini';
  sDB                 = 'DBConn.Ini';
  sAutoStartKey       = 'RemotePrinter';

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '��ӡ��������Ԫ', nEvent);
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
  //���ݿ�����
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

  FBillList.Free;
  FSyncLock.Free;
  //lock
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

//Desc: ����nConnStr�Ƿ���Ч
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

//Desc: ���ݿ�����
procedure TfFormMain.BtnConnClick(Sender: TObject);
begin
  if ShowConnectDBSetupForm(ConnCallBack) then
  begin
    FDM.ADOConn.Close;
    FDM.ADOConn.ConnectionString := BuildConnectDBStr;
    //���ݿ�����
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

//Date: 2012-4-1
//Parm: �ɹ�����;��ʾ;���ݶ���;��ӡ��
//Desc: ��ӡnOrder�ɹ�����
function PrintOrderReport(const nOrder: string; var nHint: string;
 const nPrinter: string = ''; const nMoney: string = '0'): Boolean;
var nStr: string;
    nDS: TDataSet;
begin
  Result := False;
  nStr := 'Select * From %s Where D_ID=''%s''';
  nStr := Format(nStr, [sTable_ProvDtl, nOrder]);

  nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nHint := '�ɹ���[ %s ] ����Ч!!';
    nHint := Format(nHint, [nOrder]);
    Exit;
  end;

  nStr := gPath + 'Report\PurchaseOrder.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '�޷���ȷ���ر����ļ�';
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

function PrintPoundReport(const nPID: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
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
    nHint := '����[ %s ] ����Ч!!';
    nHint := Format(nHint, [nPID]);
    Exit;
  end;

  nStr := gPath + 'Report\Pound.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '�޷���ȷ���ر����ļ�';
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
//Parm: ��������;��ʾ;���ݶ���;��ӡ��
//Desc: ��ӡnBill��������
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
          'Left Join %s p on b.L_ID=p.P_Bill Where L_ID In (%s)';
  nStr := Format(nStr, [sTable_Bill, sTable_PoundLog, nBill]);
  {$ELSE}
  nStr := 'Select *,%s As L_ValidMoney From %s b ' +
          'Left Join %s p on b.L_ID=p.P_Bill Where L_ID=''%s''';
  nStr := Format(nStr, [nMoney, sTable_Bill, sTable_PoundLog, nBill]);
  {$ENDIF}

  nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nHint := '������[ %s ] ����Ч!!';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;

  nStr := gPath + 'Report\LadingBill.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '�޷���ȷ���ر����ļ�';
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
      //�ۼƷ�����
      nIDs := nIDs + FieldByName('L_ID').AsString;
      //ƴ�ӵ��ݺ�

      if nP = 0 then
        nP := FieldByName('L_PValue').AsFloat;
      //Ƥ�ع̶�

      Next;
      if not Eof then
        nIDs := nIDs + ',';
      //xxxxx
    end;

    if nM = 0 then
      nM := nP + nValue;
    //�ϼ�ë��

    nInt := Pos(',', nBill);
    if nInt > 0 then
    begin
      nBill := Copy(nBill, 1, nInt - 1);
      //���ŵ���ʱȡ��һ��

      nStr := 'Select * From %s b ' +
              'Left Join %s p on b.L_ID=p.P_Bill Where L_ID In (%s)';
      nStr := Format(nStr, [sTable_Bill, sTable_PoundLog, nBill]);
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

//Desc: ��ӡ����
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

  WriteLog(Format('��Ӵ�ӡ������: %s', [nStr]));
  //loged
end;

procedure TfFormMain.Timer2Timer(Sender: TObject);
var nPos: Integer;
    nBill,nHint,nPrinter,nMoney, nType: string;
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

      //bill #9 printer #8 money #7 CardType
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
      //δָ����ӡ�����ֹ��ӡ

      FIsBusy := True;
      try
        WriteLog('��ʼ��ӡ: ' + nBill);
        if (nType = sFlag_Provide) then
             PrintOrderReport(nBill, nHint, nPrinter) else
        if (nType = sFlag_Sale) or (nType = sFlag_SaleNew) then
             PrintBillReport(nBill, nHint, nPrinter, nMoney)
        else PrintPoundReport(nBill, nHint, nPrinter);
        WriteLog('��ӡ����.' + nHint);
      finally
        FIsBusy := False;
      end;
    end;
end;

end.
