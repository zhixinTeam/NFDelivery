{*******************************************************************************
  ����: fendou116688@163.com 2017/6/7
  ����: ΢���Զ�ͬ��
*******************************************************************************}
unit UWebChatUploader;

interface

uses
  Windows, Classes, SysUtils, UBusinessWorker, UBusinessPacker, UBusinessConst,
  UMgrDBConn, UWaitItem, ULibFun, USysDB, UMITConst, USysLoger,
  UWorkerClientWebChat, UWorkerBusinessCommand;

type
  TWebChatUploader = class;
  TWebChatUploadThread = class(TThread)
  private
    FOwner: TWebChatUploader;
    //ӵ����
    FDB: string;
    FDBConn: PDBWorker;
    //���ݶ���
    FListA,FListB,FListC: TStrings;
    //�б����
    FNumUploadWebCustomer: Integer;
    //��ʱ����:ͬ���̳��˻�
    FNumUpLoadWebOrderStatus: Integer;
    //��ʱ����:ͬ���̳Ƕ���״̬
    FNumWebSendMsgEvent: Integer;
    //��ʱ����:����ģ����Ϣ
    FWaiter: TWaitObject;
    //�ȴ�����
    FSyncLock: TCrossProcWaitObject;
    //ͬ������
  protected
    procedure DoSyncWebCustomers;
    //ͬ��Web�̳��˻���Ϣ
    procedure DoSyncWebOrderStatus;
    //ͬ��Web�̳Ƕ���״̬
    procedure DoSendMsgEvent;
    //����ģ����Ϣ
    procedure Execute; override;
    //ִ���߳�
  public
    constructor Create(AOwner: TWebChatUploader);
    destructor Destroy; override;
    //�����ͷ�
    procedure Wakeup;
    procedure StopMe;
    //��ֹ�߳�
  end;

  TWebChatUploader = class(TObject)
  private
    FDB: string;
    //���ݱ�ʶ
    FThread: TWebChatUploadThread;
    //ɨ���߳�
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure Start(const nDB: string = '');
    procedure Stop;
    //��ͣ�ϴ�
  end;

var
  gWebChatUploader: TWebChatUploader = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TWebChatUploader, 'WebChat������ʱͬ��', nMsg);
end;

constructor TWebChatUploadThread.Create(AOwner: TWebChatUploader);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FDB := FOwner.FDB;
  
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 60 * 1000;
  //1 minute

  FSyncLock := TCrossProcWaitObject.Create('BusMIT_WebChatUpload_Sync');
  //process sync
end;

destructor TWebChatUploadThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;
  FListC.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TWebChatUploadThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TWebChatUploadThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TWebChatUploadThread.Execute;
var nErr: Integer;
    nInit: Int64;
begin
  FNumUpLoadWebOrderStatus := 0;
  FNumUploadWebCustomer := 0;
  FNumWebSendMsgEvent := 0;
  //init counter

  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Inc(FNumUpLoadWebOrderStatus);
    Inc(FNumUploadWebCustomer);
    Inc(FNumWebSendMsgEvent);
    //inc counter

    if FNumUpLoadWebOrderStatus >= 1 then
       FNumUpLoadWebOrderStatus :=0 ;
    //�����̳Ƕ���״̬: 60��/Сʱ

    if FNumUploadWebCustomer >= 3 then
       FNumUploadWebCustomer :=0 ;
    //ͬ��Web�ͻ���Ϣ�� 20��/Сʱ

    if FNumWebSendMsgEvent >= 3 then
       FNumWebSendMsgEvent :=0 ;
    //ͬ��Web�ͻ���Ϣ�� 20��/Сʱ

    if (FNumUpLoadWebOrderStatus <> 0) and
       (FNumUploadWebCustomer <> 0) and
       (FNumWebSendMsgEvent <> 0)
    then
      Continue;
    //��ҵ�����

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //������������ִ��

    FDBConn := nil;
    try
      FDBConn := gDBConnManager.GetConnection(FDB, nErr);
      if not Assigned(FDBConn) then Continue;

      if not FDBConn.FConn.Connected then
        FDBConn.FConn.Connected := True;

      if FNumUpLoadWebOrderStatus = 0 then
      try
        WriteLog('ͬ��Web�̳Ƕ���״̬��Ϣ...');                   //2017-06-18
        nInit := GetTickCount;
        DoSyncWebOrderStatus;
        WriteLog('ͬ��Web�̳Ƕ���״̬��Ϣ,��ʱ: ' + IntToStr(GetTickCount - nInit));
      finally

      end;

      if FNumUploadWebCustomer = 0 then
      try
        WriteLog('ͬ��Web�̳��˻���Ϣ...');                   //2017-06-07
        nInit := GetTickCount;
        DoSyncWebCustomers;
        WriteLog('ͬ��Web�̳��˻���Ϣ,��ʱ: ' + IntToStr(GetTickCount - nInit));
      finally

      end;

      if FNumWebSendMsgEvent = 0 then
      try
        WriteLog('�����̳�ģ����Ϣ...');                   //2017-06-18
        nInit := GetTickCount;
        DoSendMsgEvent;
        WriteLog('�����̳�ģ����Ϣ,��ʱ: ' + IntToStr(GetTickCount - nInit));
      finally

      end;
    finally
      FSyncLock.SyncLockLeave();
      gDBConnManager.ReleaseConnection(FDBConn);
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Date: 2017/6/18
//Parm: ��
//Desc: ͬ���̳Ƕ���״̬
procedure TWebChatUploadThread.DoSyncWebOrderStatus;
var nIdx: Integer;
    nSQL, nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nSQL := 'Select ws.R_ID, ws.S_Status, ws.S_Value, wi.W_WebID,wi.W_DLID ' +
          'From %s ws Left Join %s wi on W_DLID=S_ID ' +
          'Where S_Upload <> ''%s'' And S_UpCount < 5 Order By ws.R_ID ';
  nSQL := Format(nSQL, [sTable_WebSyncStatus, sTable_WebOrderInfo, sFlag_Yes]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then Exit;

    First;
    FListA.Clear;
    FListC.Clear;

    while not Eof do
    try
      with FListB do
      begin
        Clear;

        if FieldByName('W_WebID').AsString = '' then
        begin
          FListC.Add(FieldByName('R_ID').AsString);
          Continue;
        end;

        Values['RID']   := FieldByName('R_ID').AsString;
        Values['DLID']  := FieldByName('W_DLID').AsString;
        Values['WebID'] := FieldByName('W_WebID').AsString;
        Values['Status']:= IntToStr(FieldByName('S_Status').AsInteger);
        Values['Value'] := FloatToStr(FieldByName('S_Value').AsFloat);
      end;

      FListA.Add(PackerEncodeStr(FListB.Text));
    finally
      Next;
    end;
  end;

  if FListC.Count > 0 then
  begin
    nStr := AdjustListStrFormat2(FListC, '''', True, ',', False, False);
    nSQL := 'Delete From %s Where R_ID In (%s)';
    nSQL := Format(nSQL, [sTable_WebSyncStatus, nStr]);
    gDBConnManager.WorkerExec(FDBConn, nSQL);
  end;
  //ɾ�����̳Ƕ�����¼

  FListC.Clear;
  if FListA.Count > 0 then
  begin
    for nIdx := 0 to FListA.Count - 1 do
    begin
      FListB.Text := PackerDecodeStr(FListA[nIdx]);

      if TWorkerBusinessCommander.CallMe(cBC_WebChat_EditShopOrderInfo, FListA[nIdx],
        '', @nOut) then
      begin
        nSQL := 'Update %s Set S_Upload=''%s'' Where R_ID=%s';
        nSQL := Format(nSQL, [sTable_WebSyncStatus, sFlag_Yes, FListB.Values['RID']]);
        FListC.Add(nSQL);
      end else

      begin
        nSQL := 'Update %s Set S_UpCount=S_UpCount + 1 Where R_ID=%s';
        nSQL := Format(nSQL, [sTable_WebSyncStatus, FListB.Values['RID']]);
        FListC.Add(nSQL);
      end;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    for nIdx := 0 to FListC.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);

    FDBConn.FConn.CommitTrans;
  except
    FDBConn.FConn.RollbackTrans;
  end;
end;

//Date: 2017/6/7
//Parm:
//Desc: ͬ�������̳��˻�
procedure TWebChatUploadThread.DoSyncWebCustomers;
begin

end;

//Date: 2017/6/18
//Parm: ��
//Desc: ����ģ����Ϣ
procedure TWebChatUploadThread.DoSendMsgEvent;
var nIdx: Integer;
    nSQL: string;
    nOut: TWorkerBusinessCommand;
begin
  nSQL := 'Select * From %s Where E_Upload <> ''%s'' And E_UpCount < 5 Order By R_ID';
  nSQL := Format(nSQL, [sTable_WebSendMsgInfo, sFlag_Yes]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then Exit;

    First;
    FListA.Clear;
    FListC.Clear;

    while not Eof do
    try
      with FListB do
      begin
        Clear;
        Values['RID']   := FieldByName('R_ID').AsString;
        Values['BillID']  := FieldByName('E_DLID').AsString;
        Values['Card'] := FieldByName('E_Card').AsString;
        Values['MsgType']:= IntToStr(FieldByName('E_MsgType').AsInteger);
        Values['Value'] := FloatToStr(FieldByName('E_Value').AsFloat);

        Values['Truck'] := FieldByName('E_Truck').AsString;
        Values['StockNO']:= FieldByName('E_StockNO').AsString;
        Values['StockName']:= FieldByName('E_StockName').AsString;
        Values['CusID']:= FieldByName('E_CusID').AsString;
        Values['CusName']:= FieldByName('E_CusName').AsString;
      end;

      FListA.Add(PackerEncodeStr(FListB.Text));
    finally
      Next;
    end;
  end;

  FListC.Clear;
  if FListA.Count > 0 then
  begin
    for nIdx := 0 to FListA.Count - 1 do
    begin
      FListB.Text := PackerDecodeStr(FListA[nIdx]);

      if TWorkerBusinessCommander.CallMe(cBC_WebChat_SendEventMsg, FListA[nIdx],
        '', @nOut) then
      begin
        nSQL := 'Update %s Set E_Upload=''%s'' Where R_ID=%s';
        nSQL := Format(nSQL, [sTable_WebSendMsgInfo, sFlag_Yes, FListB.Values['RID']]);
        FListC.Add(nSQL);
      end else

      begin
        nSQL := 'Update %s Set E_UpCount=E_UpCount + 1 Where R_ID=%s';
        nSQL := Format(nSQL, [sTable_WebSendMsgInfo, FListB.Values['RID']]);
        FListC.Add(nSQL);
      end;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    for nIdx := 0 to FListC.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);

    FDBConn.FConn.CommitTrans;
  except
    FDBConn.FConn.RollbackTrans;
  end;
end;


//------------------------------------------------------------------------------
constructor TWebChatUploader.Create;
begin
  FThread := nil;
end;

destructor TWebChatUploader.Destroy;
begin
  Stop;
  inherited;
end;

procedure TWebChatUploader.Start(const nDB: string);
begin
  if nDB = '' then
  begin
    if Assigned(FThread) then
      FThread.Wakeup;
    //start upload
  end else
  if not Assigned(FThread) then
  begin
    FDB := nDB;
    FThread := TWebChatUploadThread.Create(Self);
  end;
end;

procedure TWebChatUploader.Stop;
begin
  if Assigned(FThread) then
  begin
    FThread.StopMe;
    FThread := nil;
  end;
end;

initialization
  gWebChatUploader := TWebChatUploader.Create;
finalization
  FreeAndNil(gWebChatUploader);
end.
