{*******************************************************************************
  ����: lih 2018-01-29
  ����: TTCEK720����������Ԫ
*******************************************************************************}
unit UMgrTTCEK720;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, IdTCPClient, IdGlobal,
  UWaitItem, USysLoger, ULibFun;

const
  cK720Reader_Wait_Short     = 1500;
  cK720Reader_Wait_Long      = 3 * 1000;
  cK720Reader_MaxThread      = 10;

  cTTCE_K720_ACK = $06;                      //�϶�Ӧ��
  cTTCE_K720_NAK = $15;                      //��Ӧ��
  cTTCE_K720_ENQ = $05;                      //ִ����������
  cTTCE_K720_EOT = $04;                      //ȡ������
  cTTCE_K720_STX = $02;                      //����ʼ�����̶�Ϊ��0X02
  cTTCE_K720_ETX = $03;                      //����������̶�Ϊ��0x03
  cTTCE_K720_ADDH = $30;                     //��ַH
  cTTCE_K720_ADDL = $30;                     //��ַL
  cTTCE_K720_Success = 'P';                  //=0x50����ʾ����ִ�гɹ�
  cTTCE_K720_Failure = 'N';                  //=0x4E����ʾ����ִ��ʧ��
  cTTCE_K720_Config = 'TTCEK720.XML';

  cTTCE_K720_SignFirst = 'S';               //��ѯ״̬������һ
  cTTCE_K720_SignSecond = 'F';              //��ѯ״̬�����Ƕ�
  cTTCE_K720_State1 = '30313332';           //��������
  cTTCE_K720_State2 = '$34$30$30$30';       //׼����ʧ��
  cTTCE_K720_State3 = '$32$30$30$30';       //����׼����
  cTTCE_K720_State4 = '$31$30$30$30';       //���ڷ���
  cTTCE_K720_State5 = '$30$38$30$30';       //�����տ�
  cTTCE_K720_State6 = '$30$34$30$30';       //��������
  cTTCE_K720_State7 = '$30$32$30$30';       //�տ�����
  cTTCE_K720_State8 = '$30$31$30$30';       //δ֪����1
  cTTCE_K720_State9 = '$30$30$38$30';       //δ֪����2
  cTTCE_K720_State10 = '$30$30$34$30';      //�ص���
  cTTCE_K720_State11 = '$30$30$32$30';      //������
  cTTCE_K720_State12 = '32303130';          //��Ԥ��
  cTTCE_K720_State13 = '30303138';          //����
  cTTCE_K720_State14 = '$30$30$30$34';      //���ڴ�����3λ��
  cTTCE_K720_State15 = '$30$30$30$32';      //���ڴ�����2λ��
  cTTCE_K720_State16 = '$30$30$30$31';      //���ڴ�����1λ��
  cTTCE_K720_State17 = '34303133';          //
  cTTCE_K720_State18 = '30323333';          //
  
type
  PTTCE_K720_Send = ^TTTCE_K720_Send;
  TTTCE_K720_Send = record
    FSTX   : Char;                           //����ʼ�����̶�Ϊ��0X02
    FADDH  : Char;                           //��ַH
    FADDL  : Char;                           //��ַL
    FLen   : Integer;                        //���͵����ݰ��������ȶ����ֽ�
    FCM    : Char;                           //�������
    FPM    : Char;                           //�������
    FSE_DATAB : string;                      //���͵����ݰ�
    FETX   : Char;                           //����������̶�Ϊ��0x03
    FBCC   : Char;                           //���У��͡����㷽������STX������STX����ETX������ETX��֮���ÿ�����ݽ������
  end;

  PTTCE_K720_Recv = ^TTTCE_K720_Recv;
  TTTCE_K720_Recv = record
    FSTX   : Char;                           //����ʼ�����̶�Ϊ��0X02
    FADDH  : Char;                           //��ַH
    FADDL  : Char;                           //��ַL
    FLen   : Integer;                        //�������ݰ��������ȶ����ֽ�
    FACK   : Char;                           //�����룺'P':�����ɹ�;'N':����ʧ��
    FCM    : Char;                           //�������
    FPM    : Char;                           //�������
    FRE_DATAB : string;                      //���ص����ݰ�,���ߴ������
    FETX   : Char;                           //����������̶�Ϊ��0x03
    FBCC   : Char;                           //���У��͡����㷽������STX������STX����ETX������ETX��֮���ÿ�����ݽ������
  end;

  PK720ReaderItem = ^TK720ReaderItem;
  TK720ReaderItem = record
    FID     : string;          //��ͷ��ʶ
    FHost   : string;          //��ַ
    FPort   : Integer;         //�˿�

    FCard   : string;          //����
    FTunnel : string;          //ͨ����
    FEnable : Boolean;         //�Ƿ�����
    FLocked : Boolean;         //�Ƿ�����
    FLastActive: Int64;        //�ϴλ

    FKeepOnce: Integer;        //���α���
    FKeepPeer: Boolean;        //����ģʽ
    FKeepLast: Int64;          //�ϴλ
    FClient : TIdTCPClient;    //ͨ����·
    FErr    : string;          //����
  end;

  PELabelItem = ^TELabelItem;
  TELabelItem = record
    FCard: string;
    FTunnel: string;
  end;

  TK720ReaderThreadType = (ttAll, ttActive);
  //�߳�ģʽ: ȫ��;ֻ���

  TK720ReaderManager = class;
  TK720Reader = class(TThread)
  private
    FOwner: TK720ReaderManager;
    //ӵ����
    FWaiter: TWaitObject;
    //�ȴ�����
    FActiveReader: PK720ReaderItem;
    //��ǰ��ͷ
    FThreadType: TK720ReaderThreadType;
    //�߳�ģʽ
    //FSendItem: TTTCE_K720_Send;
    //FRecvItem: TTTCE_K720_Recv;
    //����&����ָ��
  protected
    procedure DoExecute;
    procedure Execute; override;
    //ִ���߳�
    procedure ScanActiveReader(const nActive: Boolean);
    //ɨ�����
    function ReadCard(const nReader: PK720ReaderItem): Boolean;
    //����Ƭ
    function IsCardValid(const nCard: string): Boolean;
    //У�鿨��
  public
    constructor Create(AOwner: TK720ReaderManager; AType: TK720ReaderThreadType);
    destructor Destroy; override;
    //�����ͷ�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  //----------------------------------------------------------------------------
  THYReaderProc = procedure (const nItem: PK720ReaderItem);
  THYReaderEvent = procedure (const nItem: PK720ReaderItem) of Object;

  TK720ReaderManager = class(TObject)
  private
    FEnable: Boolean;
    //�Ƿ�����
    FMonitorCount: Integer;
    FThreadCount: Integer;
    //�����߳�
    FReaderIndex: Integer;
    FReaderActive: Integer;
    //��ͷ����
    FReaders: TList;
    //��ͷ�б�
    FCardLength: Integer;
    FCardPrefix: TStrings;
    //���ű�ʶ
    FSyncLock: TCriticalSection;
    //ͬ������
    FThreads: array[0..cK720Reader_MaxThread-1] of TK720Reader;
    //��������
    FOnProc: THYReaderProc;
    FOnEvent: THYReaderEvent;
    //�¼�����
  protected
    procedure ClearReaders(const nFree: Boolean);
    //������Դ
    procedure CloseReader(const nReader: PK720ReaderItem);
    //�رն�ͷ

    function SendStandardCmdOne(var nData: String;
      nClient: TIdTCPClient=nil): Boolean;
    //���ͱ�׼ָ��1

    function SendStandardCmdTwo(var nData: String;
      nClient: TIdTCPClient=nil): Boolean;
    //���ͱ�׼ָ��2

    function QueryState(nCM,nPM: Word; var nErr: string; nClient: TIdTCPClient=nil):Boolean;
    //��ѯ״̬
    function ToReadCardPosition(nClient: TIdTCPClient=nil):Boolean;
    //����������λ��
    function FindCard(nClient: TIdTCPClient=nil):Boolean;
    //Ѱ��
    function GetCardSerial(nClient: TIdTCPClient=nil): string;
    //��ȡ�����к�
    function SendCard(nClient: TIdTCPClient=nil):Boolean;
    //����������
    function RecoveryCard(nClient: TIdTCPClient=nil):Boolean;
    //�տ�
    function ReaderCancel(nClient: TIdTCPClient=nil): Boolean;
    //ȡ������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��������
    procedure StartReader;
    procedure StopReader;
    //��ͣ��ͷ
    function GetCardNo(const nTunnel:string): string;
    //��ÿ���
    function SendCardOut(const nReader: PK720ReaderItem):Boolean;
    //����
    function SendCardOutF(const nTunnel:string):Boolean;
    //����
    function RecoveryCardF(const nTunnel:string):Boolean;
    //���տ�
    property OnCardProc: THYReaderProc read FOnProc write FOnProc;
    property OnCardEvent: THYReaderEvent read FOnEvent write FOnEvent;
    //�������
  end;

var
  gK720ReaderManager: TK720ReaderManager = nil;
  //ȫ��ʹ��
  gELabelItem: PELabelItem;
  gELabelFCard,gECard: string;
  gELabelFTunnel: string;
  gLastECard: string;
  gLastTime:Int64;

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TK720ReaderManager, '������', nEvent);
end;

constructor TK720ReaderManager.Create;
var nIdx: Integer;
begin
  FEnable := False;
  FThreadCount := 1;
  FMonitorCount := 1;  

  for nIdx:=Low(FThreads) to High(FThreads) do
    FThreads[nIdx] := nil;
  //xxxxx

  FCardLength := 0;
  FCardPrefix := TStringList.Create;
  
  FReaders := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TK720ReaderManager.Destroy;
begin
  StopReader;
  ClearReaders(True);

  FSyncLock.Free;
  inherited;
end;

procedure TK720ReaderManager.ClearReaders(const nFree: Boolean);
var nIdx: Integer;
    nItem: PK720ReaderItem;
begin
  for nIdx:=FReaders.Count - 1 downto 0 do
  begin
    nItem := FReaders[nIdx];
    nItem.FClient.Free;
    nItem.FClient := nil;
    
    Dispose(nItem);
    FReaders.Delete(nIdx);
  end;

  if nFree then
    FReaders.Free;
  //xxxxx
end;

procedure TK720ReaderManager.StartReader;
var nIdx,nNum: Integer;
    nType: TK720ReaderThreadType;
begin
  if not FEnable then Exit;
  FReaderIndex := 0;
  FReaderActive := 0;

  nNum := 0;
  //init
  
  for nIdx:=Low(FThreads) to High(FThreads) do
  begin
    if (nNum >= FThreadCount) or
       (nNum > FReaders.Count) then Exit;
    //�̲߳��ܳ���Ԥ��ֵ,�򲻶����ͷ����

    if nNum < FMonitorCount then
         nType := ttAll
    else nType := ttActive;

    if not Assigned(FThreads[nIdx]) then
      FThreads[nIdx] := TK720Reader.Create(Self, nType);
    Inc(nNum);
  end;
end;

procedure TK720ReaderManager.CloseReader(const nReader: PK720ReaderItem);
begin
  if Assigned(nReader) and Assigned(nReader.FClient) then
  begin
    ReaderCancel(nReader.FClient);
    //ȡ������������
    
    nReader.FClient.Disconnect;
    if Assigned(nReader.FClient.IOHandler) then
      nReader.FClient.IOHandler.InputBuffer.Clear;
    //xxxxx
  end;
end;

procedure TK720ReaderManager.StopReader;
var nIdx: Integer;
begin
  for nIdx:=Low(FThreads) to High(FThreads) do
   if Assigned(FThreads[nIdx]) then
    FThreads[nIdx].Terminate;
  //�����˳����

  for nIdx:=Low(FThreads) to High(FThreads) do
  begin
    if Assigned(FThreads[nIdx]) then
      FThreads[nIdx].StopMe;
    FThreads[nIdx] := nil;
  end;

  FSyncLock.Enter;
  try
    for nIdx:=FReaders.Count - 1 downto 0 do
      CloseReader(FReaders[nIdx]);
    //�رն�ͷ
  finally
    FSyncLock.Leave;
  end;
end;

procedure TK720ReaderManager.LoadConfig(const nFile: string);
var nIdx: Integer;
    nXML: TNativeXml;  
    nReader: PK720ReaderItem;
    nRoot,nNode,nTmp: TXmlNode;
begin
  FEnable := False;
  if not FileExists(nFile) then Exit;

  nXML := nil;
  try
    nXML := TNativeXml.Create;
    nXML.LoadFromFile(nFile);

    nRoot := nXML.Root.FindNode('config');
    if Assigned(nRoot) then
    begin
      nNode := nRoot.FindNode('enable');
      if Assigned(nNode) then
        Self.FEnable := nNode.ValueAsString <> 'N';
      //xxxxx

      nNode := nRoot.FindNode('cardlen');
      if Assigned(nNode) then
           FCardLength := nNode.ValueAsInteger
      else FCardLength := 0;

      nNode := nRoot.FindNode('cardprefix');
      if Assigned(nNode) then
           SplitStr(UpperCase(nNode.ValueAsString), FCardPrefix, 0, ',')
      else FCardPrefix.Clear;

      nNode := nRoot.FindNode('thread');
      if Assigned(nNode) then
           FThreadCount := nNode.ValueAsInteger
      else FThreadCount := 1;

      if (FThreadCount < 1) or (FThreadCount > cK720Reader_MaxThread) then
        raise Exception.Create('TTCE_M100 Reader Thread-Num Need Between 1-10.');
      //xxxxx

      nNode := nRoot.FindNode('monitor');
      if Assigned(nNode) then
           FMonitorCount := nNode.ValueAsInteger
      else FMonitorCount := 1;

      if (FMonitorCount < 1) or (FMonitorCount > FThreadCount) then
        raise Exception.Create(Format(
          'TTCE_K720 Reader Monitor-Num Need Between 1-%d.', [FThreadCount]));
      //xxxxx
    end;

    //--------------------------------------------------------------------------
    nRoot := nXML.Root.FindNode('readers');
    if not Assigned(nRoot) then Exit;
    ClearReaders(False);

    for nIdx:=0 to nRoot.NodeCount - 1 do
    begin
      nNode := nRoot.Nodes[nIdx];
      if CompareText(nNode.Name, 'reader') <> 0 then Continue;

      New(nReader);
      FReaders.Add(nReader);

      with nNode,nReader^ do
      begin
        FLocked := False;
        FKeepLast := 0;
        FLastActive := GetTickCount;

        FID := AttributeByName['id'];
        FHost := NodeByName('ip').ValueAsString;
        FPort := NodeByName('port').ValueAsInteger;
        FEnable := NodeByName('enable').ValueAsString <> 'N';

        nTmp := FindNode('tunnel');
        if Assigned(nTmp) then
          FTunnel := nTmp.ValueAsString;
        //ͨ����

        nTmp := FindNode('keeponce');
        if Assigned(nTmp) then
        begin
          FKeepOnce := nTmp.ValueAsInteger;
          FKeepPeer := nTmp.AttributeByName['keeppeer'] = 'Y';
        end else
        begin
          FKeepOnce := 0;
          //Ĭ�ϲ��ϲ�
        end;

        FClient := TIdTCPClient.Create;
        with FClient do
        begin
          Host := FHost;
          Port := FPort;
          ReadTimeout := 3 * 1000;
          ConnectTimeout := 3 * 1000;   
        end;  
      end;
    end;
  finally
    nXML.Free;
  end;
end;


//------------------------------------------------------------------------------
//Date: 2015-02-08
//Parm: �ַ�����Ϣ;�ַ�����
//Desc: �ַ���ת����
function Str2Buf(const nStr: string; var nBuf: TIdBytes): Integer;
var nIdx: Integer;
begin
  Result := Length(nStr);;
  SetLength(nBuf, Result);

  for nIdx:=1 to Result do
    nBuf[nIdx-1] := Ord(nStr[nIdx]);
  //xxxxx
end;

//Date: 2015-07-08
//Parm: Ŀ���ַ���;ԭʼ�ַ�����
//Desc: ����ת�ַ���
function Buf2Str(const nBuf: TIdBytes): string;
var nIdx,nLen: Integer;
begin
  nLen := Length(nBuf);
  SetLength(Result, nLen);

  for nIdx:=1 to nLen do
    Result[nIdx] := Char(nBuf[nIdx-1]);
  //xxxxx
end;

//Date: 2015-12-06
//Parm: �����ƴ�
//Desc: ��ʽ��nBinΪʮ�����ƴ�
function HexStr(const nBin: string): string;
var nIdx,nLen: Integer;
begin
  nLen := Length(nBin);
  SetLength(Result, nLen * 2);

  for nIdx:=1 to nLen do
    StrPCopy(@Result[2*nIdx-1], IntToHex(Ord(nBin[nIdx]), 2));
  //xxxxx
end;

//Date: 2016/4/22
//Parm: 
//Desc: BCC���У���㷨
function CalcStringBCC(const nData: string; const nLen: Integer=-1;
  const nInit: Word=0): Word;
var nIdx, nLenTemp: Integer;
begin
  Result := nInit;

  if nLen < 0 then
       nLenTemp := Length(nData)
  else nLenTemp := nLen;

  for nIdx := 1 to nLenTemp do
    Result := Result xor Ord(nData[nIdx]);
end;

//Date: 2018/01/30
//Parm:
//lih: ��װ������ָ��
function PackSendData(const nData:PTTCE_K720_Send): string;
var nBCC: Word;
begin
  Result := nData.FSTX +
            nData.FADDH +
            nData.FADDL +
            Chr(nData.FLen div 256) +
            Chr(nData.FLen mod 256) +
            nData.FCM +
            nData.FPM +
            nData.FSE_DATAB +
            nData.FETX;
  //len addr cmd data
  
  nBCC := CalcStringBCC(Result);
  Result := Result + Chr(nBCC);
end;


//Date: 2018-01-30
//Parm: Ŀ��ṹ;������
//lih: ��ѯ״̬ͨ��Э�����
function UnPackStateRecvData(const nItem:PTTCE_K720_Recv; const nData: string): Boolean;
var nInt,nLen: Integer;
    nBCC: Word;
    nBuf: TIdBytes;
begin
  Result := False;
  nInt := Length(nData);
  if nInt < 1 then Exit;

  nLen := Ord(nData[4]) * 256 + Ord(nData[5]);
  if nLen <> nInt-7 then Exit;
  //���ݳ��Ȳ���,

  nBCC := CalcStringBCC(nData);
  if nBCC <> 0 then Exit;
  //BCC error

  with nItem^ do
  begin
    FSTX     := nData[1];
    FADDH    := nData[2];
    FADDL    := nData[3];
    FLen     := nLen;

    //FACK     := '';
    FCM      := nData[6];
    FPM      := nData[7];

    FRE_DATAB:= Copy(nData, 8, nLen-2);
    FETX     := nData[nLen + 6];
    
    if (FCM = cTTCE_K720_SignFirst) and (FPM = cTTCE_K720_SignSecond) then Result := True;
    //correct command
  end;
end;

//Date: 2018-01-30
//Parm: Ŀ��ṹ;������
//lih: �����к�ͨ��Э�����
function UnPackRecvData(const nItem:PTTCE_K720_Recv; const nData: string): Boolean;
var nInt,nLen: Integer;
    nBCC: Word;
begin
  Result := False;
  nInt := Length(nData);
  if nInt < 1 then Exit;

  nLen := Ord(nData[4]) * 256 + Ord(nData[5]);
  if nLen <> nInt-7 then Exit;
  //���ݳ��Ȳ���,

  nBCC := CalcStringBCC(nData);
  if nBCC <> 0 then Exit;
  //BCC error

  with nItem^ do
  begin
    FSTX     := nData[1];
    FADDH    := nData[2];
    FADDL    := nData[3];
    FLen     := nLen;

    FACK     := nData[6];
    FCM      := nData[7];
    FPM      := nData[8];

    FRE_DATAB:= Copy(nData, 9, nLen-3);
    FETX     := nData[nLen + 6];

    Result   := FACK = cTTCE_K720_Success;
    //correct command
  end;
end;

function StateResolution(const nResData:string; const nLen:Integer; var nErr: string):Boolean;
var
  nDataLen:Integer;
  nBuf: TIdBytes;
  nStr: string;
begin
  Result := False;
  nErr := '';
  
  nDataLen := nLen - 2;
  if nDataLen = 3 then
  begin
    //Ԥ��
  end else
  if nDataLen = 4 then
  begin
    Str2Buf(nResData, nBuf);
    nStr := ToHex(nBuf);
    
    if nStr = '30303134' then
    begin
      Result := True;
    end else
    if nStr = '30303133' then
    begin
      Result := True;
    end else
    if nStr = '30313334' then
    begin
      Result := True;
    end else
    if nStr = '30303034' then
    begin
      Result := True;
    end else
    if nStr = '30303033' then
    begin
      Result := True;
    end else
    if nStr = '30323334' then
    begin
      Result := True;
    end else
    begin
      nErr := nStr;
    end;
  end;
end;

//Date: 2018/01/30
//Parm: 
//Desc: ���Ͷ�����ָ��
function TK720ReaderManager.SendStandardCmdOne(var nData: String;
  nClient: TIdTCPClient): Boolean;
var nLen: Integer;
    nByteBuf: TIdBytes;
    nStr, nSend: string;
begin
  Result := False;

  if not Assigned(nClient) then Exit;

  with nClient do
  try
    if Assigned(IOHandler) then
      IOHandler.InputBuffer.Clear;
    //Clear Input Buffer

    if not Connected then Connect;
    //xxxxx

    nSend := nData;

    nLen  := Str2Buf(nSend, nByteBuf);
    Socket.Write(nByteBuf, nLen, 0);
    //Send Command

    nData := '';
    //Init Result

    SetLength(nByteBuf, 0);
    Socket.ReadBytes(nByteBuf, 3, False);
    nStr := BytesToString(nByteBuf, en8Bit);

    if nStr = Chr(cTTCE_K720_EOT) + Chr(cTTCE_K720_ADDH) + Chr(cTTCE_K720_ADDL) then
    begin
      nData := 'ȡ����������ɹ�';

      WriteLog(nData);
      Exit;
    end else
    //Cancel Operation

    if nStr = Chr(cTTCE_K720_NAK) + Chr(cTTCE_K720_ADDH) + Chr(cTTCE_K720_ADDL) then
    begin
      nData := '������У��BCCʧ��';

      WriteLog(nData);
      Exit;
    end;
    //BCC Error

    if nStr <> Chr(cTTCE_K720_ACK) + Chr(cTTCE_K720_ADDH) + Chr(cTTCE_K720_ADDL) then Exit;
    //If not ACK
    
    nStr := Chr(cTTCE_K720_ENQ) + Chr(cTTCE_K720_ADDH) + Chr(cTTCE_K720_ADDL);
    nLen := Str2Buf(nStr, nByteBuf);
    Socket.Write(nByteBuf, nLen, 0);
    //Send ENQ

    while True do
    begin
      if not Connected then Exit;

      SetLength(nByteBuf, 0);
      Socket.ReadBytes(nByteBuf, 3, False);
      nStr := BytesToString(nByteBuf, en8Bit);
      if nStr = Chr(cTTCE_K720_STX) + Chr(cTTCE_K720_ADDH) + Chr(cTTCE_K720_ADDL) then Break;
    end;
    // Get STX

    nData := nData + nStr;
    //STX

    SetLength(nByteBuf, 0);
    Socket.ReadBytes(nByteBuf, 2, False);
    nStr := ToHex(nByteBuf);
    nLen := StrToInt('$' + nStr);
    //Get Length

    nData := nData + BytesToString(nByteBuf, en8Bit);
    //Length

    SetLength(nByteBuf, 0);
    Socket.ReadBytes(nByteBuf, nLen+2, False);
    //Get Data

    nData := nData + BytesToString(nByteBuf, en8Bit);
    //Data

    nLen := CalcStringBCC(nData, Length(nData), 0);
    if nLen <> 0 then
    begin
      nData := nData + nStr;

      WriteLog('���������͵�����BCCУ��ʧ��');
      Exit;
    end;  
    //Check BCC
    
    Result := True;
  except
    on E: Exception do
    begin
      if Connected then
      begin
        Disconnect;
        if Assigned(IOHandler) then
          IOHandler.InputBuffer.Clear;
      end;

      WriteLog(E.Message);
    end;  
  end;
end;

//Date: 2018/01/30
//Parm: 
//Desc: ���Ͷ�����ָ��
function TK720ReaderManager.SendStandardCmdTwo(var nData: String;
  nClient: TIdTCPClient): Boolean;
var nLen: Integer;
    nByteBuf: TIdBytes;
    nStr, nSend: string;
begin
  Result := False;
  if not Assigned(nClient) then Exit;

  with nClient do
  try
    if Assigned(IOHandler) then
      IOHandler.InputBuffer.Clear;
    //Clear Input Buffer

    if not Connected then Connect;
    //xxxxx

    nSend := nData;
    nLen  := Str2Buf(nSend, nByteBuf);
    Socket.Write(nByteBuf, nLen, 0);
    //Send Command

    nData := '';
    //Init Result

    SetLength(nByteBuf, 0);
    Socket.ReadBytes(nByteBuf, 3, False);
    nStr := BytesToString(nByteBuf, en8Bit);

    if nStr = Chr(cTTCE_K720_EOT) then
    begin
      nData := 'ȡ����������ɹ�';

      WriteLog(nData);
      Exit;
    end else
    //Cancel Operation

    if nStr = Chr(cTTCE_K720_NAK) then
    begin
      nData := '������У��BCCʧ��';

      WriteLog(nData);
      Exit;
    end;
    //BCC Error

    if nStr <> Chr(cTTCE_K720_ACK) + Chr(cTTCE_K720_ADDH) + Chr(cTTCE_K720_ADDL) then Exit;
    //If not ACK

    nStr := Chr(cTTCE_K720_ENQ) + Chr(cTTCE_K720_ADDH) + Chr(cTTCE_K720_ADDL);
    nLen := Str2Buf(nStr, nByteBuf);
    Socket.Write(nByteBuf, nLen, 0);
    //Send ENQ
    
    Result := True;
  except
    on E: Exception do
    begin
      if Connected then
      begin
        Disconnect;
        if Assigned(IOHandler) then
          IOHandler.InputBuffer.Clear;
      end;

      WriteLog(E.Message);
    end;  
  end;
end;

//lih 2018-01-30
//��ѯ״̬
function TK720ReaderManager.QueryState(nCM,nPM: Word; var nErr:string; nClient: TIdTCPClient): Boolean;
var nCmd: string;
    nSendItem: TTTCE_K720_Send;
    nRecvItem: TTTCE_K720_Recv;
    nStr: string;
    nBuf: TIdBytes;
begin
  Result := False;
  nErr := '';
  //Init Result

  with nSendItem do
  begin
    FSTX := Chr(cTTCE_K720_STX);
    FETX := Chr(cTTCE_K720_ETX);

    FADDH := Char(cTTCE_K720_ADDH);
    FADDL := Char(cTTCE_K720_ADDL);

    FCM  := Chr(nCM);
    FPM  := Chr(nPM);

    FSE_DATAB:= '';
    FLen := 2 + Length(FSE_DATAB);
  end;

  nCmd := PackSendData(@nSendItem);

  if not SendStandardCmdOne(nCmd, nClient) then Exit;

  if not UnPackStateRecvData(@nRecvItem, nCmd) then Exit;

  if not StateResolution(nRecvItem.FRE_DATAB, nRecvItem.FLen, nErr) then Exit;

  Result := True;
end;

//lih 2018-01-30
//����������λ��
function TK720ReaderManager.ToReadCardPosition(nClient: TIdTCPClient=nil):Boolean;
var nCmd: string;
begin
  Result := False;
  //Init Result

  nCmd := Chr(cTTCE_K720_STX) +
          Chr(cTTCE_K720_ADDH) +
          Chr(cTTCE_K720_ADDL) +
          Chr($00) +
          Chr($03) +
          Chr($46) +
          Chr($43) +
          Chr($37) +
          Chr(cTTCE_K720_ETX);
  nCmd := nCmd + Chr(CalcStringBCC(nCmd));
  Result := SendStandardCmdTwo(nCmd, nClient); 
end;

//lih 2018-01-30
//Ѱ��
function TK720ReaderManager.FindCard(nClient: TIdTCPClient=nil):Boolean;
var nCmd: string;
    nSendItem: TTTCE_K720_Send;
    nRecvItem: TTTCE_K720_Recv;
begin
  Result := False;
  //Init Result

  with nSendItem do
  begin
    FSTX := Chr(cTTCE_K720_STX);
    FETX := Chr(cTTCE_K720_ETX);

    FADDH := Char(cTTCE_K720_ADDH);
    FADDL := Char(cTTCE_K720_ADDL);

    FCM  := Chr($3C);
    FPM  := Chr($30);

    FSE_DATAB:= '';
    FLen := 2 + Length(FSE_DATAB);
  end;
  
  nCmd := PackSendData(@nSendItem);
  if not SendStandardCmdOne(nCmd, nClient) then Exit;

  Result := UnPackRecvData(@nRecvItem, nCmd);
end;

//Date: 2012-4-22
//Parm: 16λ��������
//Desc: ��ʽ��nCardΪ��׼����
function ParseCardNO(const nCard: string; const nHex: Boolean): string;
var nInt: Int64;
    nIdx: Integer;
begin
  if nHex then
  begin
    Result := '';
    for nIdx:=Length(nCard) downto 1 do
      Result := Result + IntToHex(Ord(nCard[nIdx]), 2);
    //xxxxx
  end else Result := nCard;

  nInt := StrToInt64('$' + Result);
  Result := IntToStr(nInt);
  Result := StringOfChar('0', 12 - Length(Result)) + Result;
end;

//lih 2018-01-30
//��ȡ�����к�
function TK720ReaderManager.GetCardSerial(nClient: TIdTCPClient=nil): string;
var nCmd: string;
    nSendItem: TTTCE_K720_Send;
    nRecvItem: TTTCE_K720_Recv;
    nCardNo: string;
begin
  Result := '';
  with nSendItem do
  begin
    FSTX := Chr(cTTCE_K720_STX);
    FETX := Chr(cTTCE_K720_ETX);
    
    FADDH := Char(cTTCE_K720_ADDH);
    FADDL := Char(cTTCE_K720_ADDL);

    FCM  := Chr($3C);
    FPM  := Chr($31);
    FSE_DATAB:= '';
    FLen := 2 + Length(FSE_DATAB);
  end;

  nCmd := PackSendData(@nSendItem);
  if not SendStandardCmdOne(nCmd, nClient) then Exit;
  if not UnPackRecvData(@nRecvItem, nCmd) then Exit;

  nCardNo := Copy(nRecvItem.FRE_DATAB,1,4);
  Result := ParseCardNO(nCardNo, True);
end;

//lih 2018-01-30
//����������
function TK720ReaderManager.SendCard(nClient: TIdTCPClient=nil):Boolean;
var nCmd: string;
begin
  Result := False;
  //Init Result

  nCmd := Chr(cTTCE_K720_STX) +
          Chr(cTTCE_K720_ADDH) +
          Chr(cTTCE_K720_ADDL) +
          Chr($00) +
          Chr($03) +
          Chr($46) +
          Chr($43) +
          Chr($30) +
          Chr(cTTCE_K720_ETX);
  nCmd := nCmd + Chr(CalcStringBCC(nCmd));
  Result := SendStandardCmdTwo(nCmd, nClient); 
end;

//lih 2018-01-30
//�տ�
function TK720ReaderManager.RecoveryCard(nClient: TIdTCPClient=nil):Boolean;
var nCmd: string;
begin
  Result := False;
  //Init Result

  nCmd := Chr(cTTCE_K720_STX) +
          Chr(cTTCE_K720_ADDH) +
          Chr(cTTCE_K720_ADDL) +
          Chr($00) +
          Chr($02) +
          Chr($43) +
          Chr($50) +
          Chr(cTTCE_K720_ETX);
  nCmd := nCmd + Chr(CalcStringBCC(nCmd));
  Result := SendStandardCmdTwo(nCmd, nClient); 
end;

//lih 2018-01-30
//ȡ������
function TK720ReaderManager.ReaderCancel(nClient: TIdTCPClient): Boolean;
var nCmd :string;
begin
  nCmd := Chr(cTTCE_K720_EOT) + Chr(cTTCE_K720_ADDH) + Chr(cTTCE_K720_ADDL);
  Result := SendStandardCmdTwo(nCmd, nClient);
end;

//��ÿ���
function TK720ReaderManager.GetCardNo(const nTunnel:string): string;
var
  nIdx: Integer;
  nReader: PK720ReaderItem;
begin
  FSyncLock.Enter;
  try
    for nIdx := 0 to FReaders.Count -1 do
    begin
      nReader := FReaders[nIdx];
      if CompareText(nTunnel, nReader.FTunnel) <> 0 then Continue;

      Result := nReader.FCard;
      Exit;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

function TK720ReaderManager.SendCardOutF(const nTunnel:string):Boolean;
var
  nIdx: Integer;
  nReader: PK720ReaderItem;
begin
  FSyncLock.Enter;
  try
    for nIdx := 0 to FReaders.Count -1 do
    begin
      nReader := FReaders[nIdx];
      if CompareText(nTunnel, nReader.FTunnel) <> 0 then Continue;

      Result := SendCard(nReader.FClient);
      Exit;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//lih 2018-01-30
//����
function TK720ReaderManager.SendCardOut(const nReader: PK720ReaderItem):Boolean;
begin
  Result := SendCard(nReader.FClient);
end;

//lih 2018-03-22
//���տ�
function TK720ReaderManager.RecoveryCardF(const nTunnel:string):Boolean;
var
  nIdx: Integer;
  nReader: PK720ReaderItem;
begin
  FSyncLock.Enter;
  try
    for nIdx := 0 to FReaders.Count -1 do
    begin
      nReader := FReaders[nIdx];
      if CompareText(nTunnel, nReader.FTunnel) <> 0 then Continue;

      Result := RecoveryCard(nReader.FClient);
      Exit;
    end;
  finally
    FSyncLock.Leave;
  end;
end;    

//------------------------------------------------------------------------------
constructor TK720Reader.Create(AOwner: TK720ReaderManager;
  AType: TK720ReaderThreadType);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FThreadType := AType;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cK720Reader_Wait_Short;
end;

destructor TK720Reader.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TK720Reader.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TK720Reader.Execute;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FActiveReader := nil;
    try
      DoExecute;
    finally
      if Assigned(FActiveReader) then
      begin
        FOwner.FSyncLock.Enter;
        FActiveReader.FLocked := False;
        FOwner.FSyncLock.Leave;
      end;
    end;
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
      Sleep(500);
    end;
  end;
end;

//Date: 2015-12-06
//Parm: �&�����ͷ
//Desc: ɨ��nActive��ͷ,�����ô���FActiveReader.
procedure TK720Reader.ScanActiveReader(const nActive: Boolean);
var nIdx: Integer;
    nReader: PK720ReaderItem;
begin
  if nActive then //ɨ����ͷ
  with FOwner do
  begin
    if FReaderActive = 0 then
         nIdx := 1
    else nIdx := 0; //��0��ʼΪ����һ��

    while True do
    begin
      if FReaderActive >= FReaders.Count then
      begin
        FReaderActive := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //ɨ��һ��,��Ч�˳�
      end;

      nReader := FReaders[FReaderActive];
      Inc(FReaderActive);
      if nReader.FLocked or (not nReader.FEnable) then Continue;

      if nReader.FLastActive > 0 then 
      begin
        FActiveReader := nReader;
        FActiveReader.FLocked := True;
        Break;
      end;
    end;
  end else

  with FOwner do //ɨ�費���ͷ
  begin
    if FReaderIndex = 0 then
         nIdx := 1
    else nIdx := 0; //��0��ʼΪ����һ��

    while True do
    begin
      if FReaderIndex >= FReaders.Count then
      begin
        FReaderIndex := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //ɨ��һ��,��Ч�˳�
      end;

      nReader := FReaders[FReaderIndex];
      Inc(FReaderIndex);
      if nReader.FLocked or (not nReader.FEnable) then Continue;

      if nReader.FLastActive = 0 then 
      begin
        FActiveReader := nReader;
        FActiveReader.FLocked := True;
        Break;
      end;
    end;
  end;
end;

procedure TK720Reader.DoExecute;
begin
  FOwner.FSyncLock.Enter;
  try
    if FThreadType = ttAll then
    begin
      ScanActiveReader(False);
      //����ɨ�費���ͷ

      if not Assigned(FActiveReader) then
        ScanActiveReader(True);
      //����ɨ����
    end else

    if FThreadType = ttActive then //ֻɨ��߳�
    begin
      ScanActiveReader(True);
      //����ɨ����ͷ

      if Assigned(FActiveReader) then
      begin
        FWaiter.Interval := cK720Reader_Wait_Short;
        //�л��ͷ,����
      end else
      begin
        FWaiter.Interval := cK720Reader_Wait_Long;
        //�޻��ͷ,����
        ScanActiveReader(False);
        //����ɨ�費���
      end;
    end;
  finally
    FOwner.FSyncLock.Leave;
  end;

  if Assigned(FActiveReader) and (not Terminated) then
  try
    if ReadCard(FActiveReader) then
    begin
      if FThreadType = ttActive then
        FWaiter.Interval := cK720Reader_Wait_Short;
      FActiveReader.FLastActive := GetTickCount;
    end else
    begin
      if (FActiveReader.FLastActive > 0) and
         (GetTickCount - FActiveReader.FLastActive >= 5 * 1000) then
        FActiveReader.FLastActive := 0;
      //�޿�Ƭʱ,�Զ�תΪ���
    end;
  except
    on E:Exception do
    begin
      FActiveReader.FLastActive := 0;
      //��Ϊ���

      WriteLog(Format('Reader:[ %s:%d ] Msg: %s', [FActiveReader.FHost,
        FActiveReader.FPort, E.Message]));
      //xxxxx

      FOwner.CloseReader(FActiveReader);
      //focus reconnect
    end;
  end;
end;

//Date: 2015-12-07
//Parm: ����
//Desc: ��֤nCard�Ƿ���Ч
function TK720Reader.IsCardValid(const nCard: string): Boolean;
var nIdx: Integer;
begin
  with FOwner do
  begin
    Result := False;
    nIdx := Length(Trim(nCard));
    if (nIdx < 1) or ((FCardLength > 0) and (nIdx < FCardLength)) then Exit;
    //leng verify

    Result := FCardPrefix.Count = 0;
    if Result then Exit;

    for nIdx:=FCardPrefix.Count - 1 downto 0 do
     if Pos(FCardPrefix[nIdx], nCard) = 1 then
     begin
       Result := True;
       Exit;
     end;
  end;
end;

function TK720Reader.ReadCard(const nReader: PK720ReaderItem): Boolean;
var nCard, nErr: string;
begin
  Result := False;
  nReader.FErr := '';
  //Init Result

  with FOwner, nReader^ do
  try
    //WriteLog('IP: ' + FClient.Host + ' port: ' + IntToStr(FClient.Port));
    if not FClient.Connected then FClient.Connect;
    if not QueryState($41, $50, nErr, FClient) then
    begin
      WriteLog('QueryState: ' + nErr);
      if nErr = cTTCE_K720_State1 then WriteLog('��������');
      if nErr = cTTCE_K720_State12 then WriteLog('��Ԥ��');
      if nErr = cTTCE_K720_State13 then WriteLog('����');

      if (nErr = cTTCE_K720_State17) then RecoveryCard(FClient);
      nReader.FErr := nErr;
      Exit;
    end;

    if FindCard(FClient) then
    begin
      nCard := GetCardSerial(FClient);
      if nCard = '' then
      begin
        RecoveryCard(FClient);
        Exit;
      end;
      //����ʧ��,����տ�
    end else

    begin
      ToReadCardPosition(FClient);
      Exit;
      //���û�п�Ƭ,���ͷ���������λָ��
    end;

    if (not Terminated) then
    begin
      Result := True;
      //read success
    
      if nReader.FKeepOnce > 0 then
      begin
        if CompareText(nCard, nReader.FCard) = 0 then
        begin
          if GetTickCount - nReader.FKeepLast < nReader.FKeepOnce then
          begin
            if not nReader.FKeepPeer then
              nReader.FKeepLast := GetTickCount;
            Exit;
          end;
        end;

        nReader.FKeepLast := GetTickCount;
        //ͬ������ˢѹ��
      end;

      nReader.FCard := nCard;
      //multi card
    
      if Assigned(FOwner.FOnProc) then
        FOwner.FOnProc(nReader);
      //xxxxx

      if Assigned(FOwner.FOnEvent) then
        FOwner.FOnEvent(nReader);
      //xxxxx
    end;
  except
    on E: Exception do
    begin
      FClient.Disconnect;
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      //xxxxx

      WriteLog('Error:' + E.Message);
    end;
  end;
end;

initialization
  gK720ReaderManager := nil;
finalization
  FreeAndNil(gK720ReaderManager);
end.
