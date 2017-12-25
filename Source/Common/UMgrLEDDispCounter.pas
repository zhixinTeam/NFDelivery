unit UMgrLEDDispCounter;

{$I Link.Inc}
interface
uses
  Classes, IdTCPConnection, IdTCPClient, SyncObjs,UWaitItem,
  {$IFDEF MultiReplay}UMultiJS_Reply{$ELSE}UMultiJS{$ENDIF};
const
  cCounterDisp_ControlType_5e1 = '5e1';
  cCounterDisp_ControlType_5e2 = '5e2';
  cCounterDisp_ControlType_5mk1 = '5mk1';

  cCounterDisp_CardID_tdk = 'tdk';
  cCounterDisp_CardID_bzj = 'bzj';
  cCounterDisp_CardID_zcg = 'zcg';

  const_paper_package_pc325='0502010010';//32.5纸袋物料代码
  const_paper_package_po425='0502010014';//42.5纸袋物料代码
type
//  card节点
  PCardInfo = ^TCardInfo;
  TCardInfo = record
    FTunnelId:string;
    FCardId:string;
    FName:string;
    FIP:string;
    FPort:Integer;
    FAddr:Integer;
    FEnable:Boolean;
    FWidth:Integer;
    FHeight:Integer;
    FControlType:Integer;
    FFontSize:Integer;
    FSingleLine:Integer;
    FClient: TIdTCPClient;//数据链路
  end;

  PCounterDispContent = ^TCounterDispContent;
  TCounterDispContent = record
    FTunnelID:string;
    FCardID: string;
    FText: string;
    FWidth:Integer;
    FAddr:Integer;
    FHeigth:Integer;
    FIP:string;
    FPort:Integer;
    FControlType:Integer;
    FFontSize:Integer;
    FSingleLine:Integer;
  end;  

//  tunnel节点
  PCounterTunnel=^TCounterTunnel;
  TCounterTunnel = record
    FID:string;
    FName:string;
    FDesc:string;
    FStock:string;
    FCardInfoList:Tlist;//card列表
  end;

//  cards节点
  TCounterCards = record
    FEnabled:Boolean;
    FDefaultText:string;
    FCounterTunnelList:Tlist;//tunnel列表
  end;
  TMgrLEDDispCounterManager=class;

  TCounterDisplayControler = class(TThread)
  private
    FOwner: TMgrLEDDispCounterManager;
    //拥有者
    FBuffer: TList;
    //显示内容
    FWaiter: TWaitObject;
    //等待对象
//    FLedAPI:TLedAPI;

  protected
    procedure DoExuecte(const nCard: PCardInfo);
    procedure Execute; override;
    //执行线程
    procedure AddContent(const nContent: PCounterDispContent);
    //添加内容
//    function SendDynamicData(const nContent: PCounterDispContent): Boolean;    
  public
    constructor Create(AOwner: TMgrLEDDispCounterManager);
    destructor Destroy; override;
    //创建释放
    procedure WakupMe;
    //唤醒线程
    procedure StopMe;
    //停止线程
  end;
    
  TMgrLEDDispCounterManager = class(TObject)
  private
    FControler: TCounterDisplayControler;
    FCounterCards:TCounterCards;
    FSyncLock: TCriticalSection;
    FBuffData: TList;
    //FWinHandle:THandle;
    FPaperBagTunnel:TStrings;    
    procedure ClearTunnels(const nFree: Boolean = False);
    procedure ClearBuffer(const nList: TList; const nFree: Boolean = False);
  protected
  public
    function GetCounterTunnelItem(const nTunnel:string):PCounterTunnel;  
    procedure StartDisplay;
    procedure StopDisplay;  
    procedure LoadConfig(const nFile: string);
    procedure Display(const nTunnel,nCard,nText: string;const nLocked:Boolean=True);
    //constructor Create(const nHandle:THandle);
    constructor Create;
    destructor Destroy; override;
    procedure SendCounterLedDispInfo(const nTruck,nTunnel:string;const nDaiNum: Integer;const nStockname:string='');
    procedure OnSyncChange(const nTunnel: PMultiJSTunnel);//计数变动
    procedure SendFreeToLedDispInfo(const nTunnel: string);
    property CounterCards:TCounterCards read FCounterCards;
  end;

var
  gCounterDisplayManager: TMgrLEDDispCounterManager = nil;

implementation
uses
  NativeXml,SysUtils,Windows,ULibFun,USysLoger,IdGlobal,Forms;

type
  TPackHeader = record
    FDstAddr: Integer;
    FSrcAddr: Integer;
    FReserved: array[0..5] of Byte;
    FDevType: Char;
    FProtocolVersion: Char;
  end;

  TAreaData = record
    AreaDataLen: Integer;

    AreaType: Byte;
    AreaX: Integer;
    AreaY: Integer;
    AreaWidth: Integer;
    AreaHeight: Integer;

    DynamicAreaLoc: Byte;
    Lines_sizes: Byte;
    RunMode: Byte;
    Timeout: Integer;

    Reserved: array[0..2] of char;
    SingleLine: Byte;
    NewLine: Byte;

    DisplayMode: Byte;
    ExitMode: Byte;
    Speed: Byte;
    StayTime: Byte;

    DataLen: Word;
    Data: string;
  end;

  TShowAreaData = record
    FDelAreaNum: Byte;
    FDeleteAreaId: array of Byte;

    FAreaNum: Byte;
    FAreaDataDymicA: array of TAreaData;
  end;
    
  TRequestData = record
    FCmdGroup: Byte;	//命令分组编号
    FCmd: Byte;	//命令编号

    FResponse: Byte;	//是否要求控制器回复。0x01——控制器必须回复;0x02——控制器不必回复
    FReserved: array[0..1] of Byte;	//保留	
	
    FData:string;	//发送的数据
  end;

  TResponseData = record
    FCmdGroup: Byte;	//命令分组编号
    FCmd: Byte;	//命令编号
	
    FCmdError: Byte;	//命令处理状态
    FReserved: array[0..1] of Byte;	//保留
	
    FData:string;	//发送的数据
  end;

  PBXDataRecord = ^TBXDataRecord;
  TBXDataRecord = record
    FPDHeader: array [0..7] of Byte;
    FPackHead: TPackHeader;
    FDataLen : Integer;

    FRequestData: TRequestData;
    FResponseData:TResponseData;
		
    FCRC: Int64;
    FEnd: Byte; //$5A
  end;

//Date: 2015/2/8
//Parm: 采用仰邦自带的CRC16表
//Desc:
const tabel: array [0..255] of ULONG = (
    $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
    $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
    $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40,
    $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
    $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
    $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
    $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641,
    $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
    $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
    $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
    $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
    $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
    $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
    $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
    $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
    $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
    $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
    $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
    $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
    $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
    $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
    $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
    $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
    $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
    $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
    $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
    $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40,
    $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
    $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
    $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
    $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
    $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040
    );

  //控制器类型
  CONTROLLER_TYPE_4M1               = $0142;
  CONTROLLER_TYPE_4M                = $0042;
  CONTROLLER_TYPE_5M1               = $0052;
  CONTROLLER_TYPE_5M2               = $0252;
  CONTROLLER_TYPE_5M3               = $0352;
  CONTROLLER_TYPE_5M4               = $0452;

  CONTROLLER_BX_5E1                 = $0154;
  CONTROLLER_BX_5E2                 = $0254;
  CONTROLLER_BX_5E3                 = $0354; //动态区域卡

//------------------------------------------------------------------------------
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMgrLEDDispCounterManager, '计数器LED显示服务', nEvent);
end;

//将整型转换为低字节在前，高字节在后字符串
function Int2LHStr(nInt: Integer): string;
begin
	Result := Chr(nInt mod 256) + Chr(nInt div 256);
end;

//将低字节在前，高字节在后的字符串转成整型
function LHStr2Int(nStr: string): Integer;
begin
	if Length(nStr) <> 2 then 
	begin	
		Result := 0;
		Exit;
	end;	
	Result := Ord(nStr[1]) + Ord(nStr[2]) * 256;
end;

function PackSendHeader(nPackHeader: TPackHeader):string;
var nIdx: Integer;
begin
	Result := '';
	with nPackHeader do
	begin
		Result := Result + Int2LHStr(FDstAddr);
		//屏地址		
		Result := Result + Int2LHStr(FSrcAddr);
		//源地址
		
		for nIdx:=Low(FReserved) to High(FReserved) do
			Result := Result + Chr(FReserved[nIdx]);
			
		Result := Result + Char(FDevType);
		Result := Result + Char(FProtocolVersion);
		//设备类型与协议版本
	end;
end;

function PackRequestData(nRequestData: TRequestData):string;
var nIdx: Integer;
begin
	Result := '';
	with nRequestData do
	begin
		Result := Result + Chr(FCmdGroup);
		//命令分组编号		
		Result := Result + Chr(FCmd);
		//命令编号		
		Result := Result + Chr(FResponse);
		//是否要求控制器回复

		for nIdx:=Low(FReserved) to High(FReserved) do
			Result := Result + Chr(FReserved[nIdx]);

    Result := Result + FData;
		//数据长度与数据本身
	end;
end;

//Date: 2015/2/8
//Parm: 源CRC;数据
//Desc: 仰邦CRC16校验算法
function YBCRC(const nCrc, nData: ULONG): ULONG;
begin
  Result := (nCrc shr 8) xor tabel[(nCrc xor nData) and $FF];
end;

//Date: 2015/2/8
//Parm: 源数据；数据长度
//Desc: 仰邦CRC16校验算法
function YBCalcCRC16(nData: Pointer; nSize: Integer): ULONG;
var nIdx: Integer;
    nCrc: ULONG;
    nP:PAnsichar;
begin
  nCrc := 0;
  nP := nData;
  for nIdx:=0 to nSize-1 do
    nCrc := YBCRC(nCrc, Ord(nP[nIdx]));

  Result := nCrc;
end;


function PackSendData(const nBXDataRecord: TBXDataRecord):string;
var nIdx, nLen: Integer;
		nStrData: string;
  function StrEscape(const AStr: string;const nIndex:Integer=1):string;
  var
    i : Integer;
    ch:char;  
  begin
    Result:='';
    for i:=nIndex to length(AStr)  do
    begin
      ch:=AStr[i];
      
      if IntToHex(Ord(ch),2) = 'A6' then
      begin
        Result := Result + Chr($A6) + chr($01);
      end
      else if IntToHex(Ord(ch),2) = 'A5' then
      begin
        Result := Result + Chr($A6) + chr($02);
      end
      else if IntToHex(Ord(ch),2) = '5B' then
      begin
        Result := Result + Chr($5B) + chr($01);
      end
      else if IntToHex(Ord(ch),2) = '5A' then
      begin
        Result := Result + Chr($5B) + chr($02);
      end
      else begin
        Result := Result+ch;
      end;
    end;    
  end;
begin
	Result := '';
	
	with nBXDataRecord do
	begin
		for nIdx:=Low(FPDHeader) to High(FPDHeader) do
		 Result := Result + Chr(FPDHeader[nIdx]);
		//帧头；$A5(8个) 
		
		Result := Result + PackSendHeader(FPackHead);
		//数据头

		nStrData := PackRequestData(FRequestData);
		nLen := Length(nStrData);
		//数据长度
		
		Result := Result + Int2LHStr(nLen);	
		Result := Result + nStrData;
		//数据长度与数据本身
		
		Result := Result + Int2LHStr(YBCalcCRC16(@Result[9] , Length(Result)-8));
		Result := Copy(Result,1,8)+StrEscape(Result,9);
		Result := Result + Chr(FEnd);
	end;	
end;

function ShowDynamicAreaData(const nTxt: string; nAreaX:Integer=0;
    nAreaY: Integer=0; nAreaWidth: Integer=$18; nAreaHeight: Integer=$20;
    nDynamicAreaLoc: Byte=$00; nLines_sizes: Byte=$00; nRunMode: Byte=$00;
    nTimeout: Integer=2; nSingleLine: Byte=$02; nNewLine: Byte=$02;
    nDisplayMode: Byte=$01; nExitMode: Byte=$00; nSpeed: Byte=$04;
    nStayTime: Byte=$05): string;
var nInt: Integer;
    nStrArea: string;
    nShowAreaData:TShowAreaData;
begin
  Result := '';
  with nShowAreaData do
  begin
    FDelAreaNum := 0;
    SetLength(FDeleteAreaId, 0);

    FAreaNum := 1;
    SetLength(FAreaDataDymicA, 1);

    Result := Result + Chr(FDelAreaNum);
    Result := Result + Chr(FAreaNum);

    nStrArea := '';
    with FAreaDataDymicA[0] do
    begin
      AreaType := $00;
      AreaX := nAreaX;
      AreaY := nAreaY;

      nStrArea := nStrArea + Chr(AreaType);
      nStrArea := nStrArea + Int2LHStr(AreaX);
      nStrArea := nStrArea + Int2LHStr(AreaY);

      AreaWidth := nAreaWidth;
      AreaHeight := nAreaHeight;

      nStrArea := nStrArea + Int2LHStr(AreaWidth);
      nStrArea := nStrArea + Int2LHStr(AreaHeight);

      DynamicAreaLoc := nDynamicAreaLoc;
      Lines_sizes := nLines_sizes;
      RunMode := nRunMode;
      Timeout := nTimeout;

      nStrArea := nStrArea + Chr(DynamicAreaLoc);
      nStrArea := nStrArea + Chr(Lines_sizes);
      nStrArea := nStrArea + Chr(RunMode);
      nStrArea := nStrArea + Int2LHStr(Timeout);

      for nInt:=Low(Reserved) to High(Reserved) do
       nStrArea := nStrArea + Reserved[nInt];

      SingleLine := nSingleLine;
      NewLine := nNewLine;

      nStrArea := nStrArea + Chr(SingleLine);
      nStrArea := nStrArea + Chr(NewLine);

      DisplayMode := nDisplayMode;
      ExitMode := nExitMode;
      Speed := nSpeed;
      StayTime := nStayTime;

      nStrArea := nStrArea + Chr(DisplayMode);
      nStrArea := nStrArea + Chr(ExitMode);
      nStrArea := nStrArea + Chr(Speed);
      nStrArea := nStrArea + Chr(StayTime);

      DataLen := Length(nTxt);
      Data := nTxt;

      nStrArea := nStrArea + Int2LHStr(DataLen) + #00#00 ;
      nStrArea := nStrArea + Data;
    end;

    Result := Result + Int2LHStr(Length(nStrArea));
    Result := Result + nStrArea;
  end;
end;

procedure InitBXData(var nBXDataRecord:TBXDataRecord);
begin
  with nBXDataRecord do
  begin
    FillChar(FPDHeader, Length(FPDHeader), $A5);

    with FPackHead do
    begin
      FDstAddr := 1; //默认屏号为1；
      FSrcAddr := $8000;
      FDevType := Chr($FE);
      FProtocolVersion := Chr($02);
      
      FillChar(FReserved, Length(FReserved), 0);
    end;

    with FRequestData do
    begin
      FillChar(FReserved, Length(FReserved), 0);
    end;

    with FResponseData do
    begin
      FillChar(FReserved, Length(FReserved), 0);
    end;

    FDataLen := 0;
    FEnd := $5A;
  end;  
end; 

function GetBXShowInfoAtTime(nTxt: string; nAddr: Integer=0): string;
var nStrSend: string;
    nBXDataRecord: TBXDataRecord;
begin
  InitBXData(nBXDataRecord);

  with nBXDataRecord do
  begin
    if nAddr <> 0 then FPackHead.FDstAddr := nAddr;

    with FRequestData do
    begin
      FCmd := $06;
      FCmdGroup := $A3;
      FResponse := $02;

      nStrSend:=StringReplace(nTxt,Chr($A5), Chr($A6)+Chr($02), [rfReplaceAll]);
      nStrSend:=StringReplace(nTxt,Chr($5A), Chr($5B)+Chr($02), [rfReplaceAll]);

      //nTxt := Copy(nTxt, 1, 24);
      FData := ShowDynamicAreaData(nTxt);
      FDataLen := Length(FData);
    end;
  end;

  Result := PackSendData(nBXDataRecord);
end; 

{ TMgrLEDDispCounter }
procedure TMgrLEDDispCounterManager.ClearBuffer(const nList: TList;
  const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx := nList.Count - 1 downto 0 do
  begin
    Dispose(PCounterDispContent(nList[nIdx]));
    nList.Delete(nIdx);
  end;

  if nFree then
    nList.Free;
  //xxxxx
end;

procedure TMgrLEDDispCounterManager.ClearTunnels(const nFree: Boolean = False);
var
  i,j:Integer;
  nItem1:PCounterTunnel;
  nItem2:PCardInfo;
begin
  for i := FCounterCards.FCounterTunnelList.Count-1 downto 0 do
  begin
    nItem1 := PCounterTunnel(FCounterCards.FCounterTunnelList.Items[i]);
    for j := nitem1.FCardInfoList.Count-1 downto 0 do
    begin
      nItem2 := PCardInfo(nitem1.FCardInfoList.Items[j]);

      nItem2.FClient.Disconnect;
      nItem2.FClient.Free;
      nItem2.FClient := nil;

      Dispose(nItem2);
    end;
    nItem1.FCardInfoList.clear;
    if nFree then
    begin
      nItem1.FCardInfoList.Free;
      nItem1.FCardInfoList := nil;
    end;    
    Dispose(nItem1);
  end;
  FCounterCards.FCounterTunnelList.clear;
  if nFree then
  begin
    FCounterCards.FCounterTunnelList.Free;
    FCounterCards.FCounterTunnelList := nil;
  end;
end;

//constructor TMgrLEDDispCounterManager.Create(const nHandle:THandle);
constructor TMgrLEDDispCounterManager.Create;
begin
  inherited Create;
  //FWinHandle := nHandle;
  FCounterCards.FCounterTunnelList := TList.Create;
  FSyncLock := TCriticalSection.Create;
  FBuffData := TList.Create;
  FPaperBagTunnel := TStringList.Create;
end;

destructor TMgrLEDDispCounterManager.Destroy;
begin
  StopDisplay;
  ClearBuffer(FBuffData, True);
  ClearTunnels(True);
  FSyncLock.Free;
  FPaperBagTunnel.Free;
  inherited;
end;

procedure TMgrLEDDispCounterManager.Display(const nTunnel, nCard,nText: string;const nLocked:Boolean);
var
  nIdx:Integer;
  nTunnelItem:PCounterTunnel;
  ncardItem:PCardInfo;
  nItem: PCounterDispContent;
begin
  nTunnelItem := GetCounterTunnelItem(nTunnel);
  if Assigned(nTunnelItem) then
  begin
    for nIdx := 0 to nTunnelItem.FCardInfoList.Count-1 do
    begin
      ncardItem := PCardInfo(nTunnelItem.FCardInfoList.Items[nIdx]);
      if ncardItem.FCardId<>nCard then Continue;

      if not Assigned(FControler) then Exit;

      //WriteLog('TMgrLEDDispCounterManager.Display(nTunnel='''+nTunnel+''', nCard='''+nCard+''', nText='''+nText+''')');
      if nLocked then FSyncLock.Enter;
      try
        New(nItem);
        nItem.FControlType := ncardItem.FControlType;

        FBuffData.Add(nItem);
        nItem.FTunnelID := nCardItem.FTunnelId;
        nItem.FCardID := nCardItem.FCardID;
        nItem.FWidth := nCardItem.FWidth;
        nItem.FHeigth := nCardItem.FHeight;
        nItem.FAddr := nCardItem.FAddr;
        nItem.FIP := nCarditem.FIP;
        nitem.FPort := nCardItem.FPort;
        nItem.FText := nText;
        nItem.FSingleLine := nCardItem.FSingleLine;
        nItem.FFontSize := nCardItem.FFontSize;
        FControler.WakupMe;
      finally
        if nLocked then FSyncLock.Leave;
      end;        
    end;
  end;
end;

function TMgrLEDDispCounterManager.GetCounterTunnelItem(
  const nTunnel: string): PCounterTunnel;
var
  nidx:Integer;
  nItem:PCounterTunnel;
begin
  Result := nil;
  for nidx := 0 to FCounterCards.FCounterTunnelList.Count-1 do
  begin
    nItem := PCounterTunnel(FCounterCards.FCounterTunnelList.Items[nidx]);
    if nItem.FID=nTunnel then
    begin
      Result := nItem;
      Break;
    end;
  end;
end;

procedure TMgrLEDDispCounterManager.LoadConfig(const nFile: string);
var
  nIdx,j: Integer;
  nXML: TNativeXml;
  nNode: TXmlNode;
  nTunnelItem:PCounterTunnel;
  nCardItem:PCardInfo;
  nCardNode:TXmlNode;
  nStr:string;
begin
  nXML := TNativeXml.Create;
  try
    try
      ClearTunnels;
      nXML.LoadFromFile(nFile);
      nNode := nXML.Root.NodeByName('config');
      FCounterCards.FEnabled := nNode.NodeByName('enable').ValueAsString = '1';
      FCounterCards.FDefaultText := nNode.NodeByName('default').ValueAsString;
      for nIdx := 0 to nXML.Root.NodeCount-1 do
      begin
        nNode := nXML.Root.Nodes[nIdx];
        if CompareText(nNode.Name, 'tunnel') <> 0 then Continue;
        New(nTunnelItem);

        nTunnelItem.FID := nNode.AttributeByName['id'];
        nTunnelItem.FName := nNode.AttributeByName['name'];
        nTunnelItem.FDesc := nNode.AttributeByName['desc'];
        nTunnelItem.FStock := nNode.AttributeByName['stock'];
        nTunnelItem.FCardInfoList := TList.Create;

        for j := 0 to nNode.NodeCount-1 do
        begin
          nCardNode := nNode.Nodes[j];
          New(nCardItem);
          nCardItem.FTunnelId := nTunnelItem.FID;
          nCardItem.FCardId := LowerCase(nCardNode.AttributeByName['id']);
          nCardItem.FName := nCardNode.AttributeByName['name'];
          nCardItem.FIP := nCardNode.NodeByName('ip').ValueAsString;
          nCardItem.FPort := nCardNode.NodeByName('port').ValueAsInteger;
          nCardItem.FAddr := nCardNode.NodeByName('addr').ValueAsInteger;
          nCardItem.FEnable := nCardNode.NodeByName('enable').ValueAsInteger = 1;
          nCardItem.FWidth := nCardNode.NodeByName('screenwidth').ValueAsInteger;
          nCardItem.FHeight := nCardNode.NodeByName('screenheight').ValueAsInteger;
          nCardItem.FFontSize := nCardNode.NodeByName('fontsize').ValueAsInteger;
          nStr := LowerCase(nCardNode.NodeByName('controltype').ValueAsString);
          if nStr=cCounterDisp_ControlType_5e1 then
          begin
            nCardItem.FControlType := CONTROLLER_BX_5E1
          end
          else if nStr=cCounterDisp_ControlType_5e2 then
          begin
            nCardItem.FControlType := CONTROLLER_BX_5E2
          end
          else if nStr=cCounterDisp_ControlType_5mk1 then
          begin
            nCardItem.FControlType := 0
          end;

          nCardItem.FSingleLine := 0;
          nstr := LowerCase(nCardNode.NodeByName('singleline').ValueAsString);
          if nStr='true' then
          begin
            nCardItem.FSingleLine := 1;
          end;

          nCardItem.FClient := TIdTCPClient.Create;

          nCardItem.FClient.Host := nCardItem.FIP;
          nCardItem.FClient.Port := nCardItem.FPort;
          nCardItem.FClient.ReadTimeout := 5 * 1000;
          nCardItem.FClient.ConnectTimeout := 5 * 1000;
          nTunnelItem.FCardInfoList.Add(nCardItem);
        end;
        FCounterCards.FCounterTunnelList.Add(nTunnelItem);
      end;
    except
      on E: Exception do
      begin
        WriteLog('TMgrLEDDispCounterManager.LoadConfig Error:'+E.Message);
      end;
    end;
  finally
    nXML.Free;
  end;
end;

procedure TMgrLEDDispCounterManager.OnSyncChange(
  const nTunnel: PMultiJSTunnel);
var
  nStr:string;
  nTunnelItem:PCounterTunnel;
  nTruck:string;
  nIdx:Integer;
  nLocked:Boolean;

  function toString(const ATunnel: PMultiJSTunnel):string;
  begin
    try
      with ATunnel^ do
      begin
        Result := 'FID=%s,FName=%s,FTunnel=%d,FDelay=%d,FGroup=%s,FReader=%s,FTruck=%s,FDaiNum=%s,FHasDone=%s,FIsRun=%s,FLastBill=%s,FLastSaveDai=%d';
        Result := Format(Result,[FID,FName,FTunnel,FDelay,FGroup,FReader,FTruck,FDaiNum,FHasDone,BoolToStr(FIsRun),FLastBill,FLastSaveDai]);
      end;
    except
      on E:Exception do
      begin
        Result := 'TMgrLEDDispCounterManager.OnSyncChange.toString--发生异常['+e.Message+']';
      end;
    end;
  end;
begin  
  try
    FSyncLock.Enter;
    //lock first
    nLocked := False;
    try
      nTunnelItem := GetCounterTunnelItem(nTunnel.FID);
      if not Assigned(nTunnelItem) then
      begin
        nStr := 'TMgrLEDDispCounterManager.OnSyncChange--通道号[%s]不存在';
        nStr := Format(nStr,[nTunnel.FID]);
        WriteLog(nStr);
        Exit;
      end;

      nIdx := FPaperBagTunnel.IndexOf(nTunnel.FID);
      nTruck := nTunnel.FTruck;
      if nIdx<>-1 then
      begin
        if pos('纸',nTunnelItem.FStock)=0 then
        begin
          nTunnelItem.FStock := '纸'+nTunnelItem.FStock;
        end;
      end;

      if not nTunnel.FIsRun then
      begin
        nStr := '%s 空闲';
        nStr := Format(nStr,[nTunnelItem.FDesc]);
        Display(nTunnel.FID,cCounterDisp_CardID_tdk,nStr,nLocked);
        Display(nTunnel.FID,cCounterDisp_CardID_bzj,nStr,nLocked);
        Display(nTunnel.FID,cCounterDisp_CardID_zcg,nStr,nLocked);
      end
      else begin
        nStr := '%s %s 装车 %s %0.4d/%0.4d';
        nStr := Format(nStr,[nTunnelItem.FDesc, nTruck, nTunnelItem.FStock, nTunnel.FHasDone, ntunnel.FDaiNum]);
        Display(nTunnel.FID,cCounterDisp_CardID_tdk,nStr,nLocked);

        nStr := '%s %s %0.4d/%0.4d';
        nStr := Format(nStr,[nTunnelItem.FDesc, nTunnelItem.FStock, nTunnel.FHasDone, ntunnel.FDaiNum]);
        Display(nTunnel.FID,cCounterDisp_CardID_bzj,nStr,nLocked);

        nStr := '%s %s %0.4d/%0.4d';
        nStr := Format(nStr,[nTunnelItem.FDesc, nTruck, nTunnel.FHasDone, ntunnel.FDaiNum]);
        Display(nTunnel.FID,cCounterDisp_CardID_zcg,nStr,nLocked);
      end;
    except
      on E:Exception do
      begin
        nStr := 'TMgrLEDDispCounterManager.OnSyncChange(nTunnel=%s)--发生异常：[%s]';
        nStr := Format(nStr,[toString(nTunnel),e.Message]);
        WriteLog(nStr);
      end;
    end;
  finally
    FSyncLock.Leave;
  end;              
end;

procedure TMgrLEDDispCounterManager.SendCounterLedDispInfo(const nTruck,
   nTunnel: string; const nDaiNum: Integer;const nStockname:string);
var
  nStr:string;
  nTunnelItem:PCounterTunnel;
  nIdx:Integer;
  nLocked:Boolean;
begin
  try
    FSyncLock.Enter;
    //lock first
    nLocked := False;
    try
      nTunnelItem := GetCounterTunnelItem(nTunnel);
      if not Assigned(nTunnelItem) then
      begin
        nStr := 'SendLedDispCounterInfo--通道号[%s]不存在';
        nStr := Format(nStr,[nTunnel]);
        WriteLog(nStr);
        Exit;
      end;
      nIdx := FPaperBagTunnel.IndexOf(nTunnel);
      if nIdx<>-1 then
      begin
        FPaperBagTunnel.Delete(nIdx);
      end;
  
      if Pos('纸',nStockname)<>0 then
      begin
        FPaperBagTunnel.Add(nTunnel);
        if Pos('纸',nTunnelItem.FStock)=0 then
        begin
          nTunnelItem.FStock := '纸'+nTunnelItem.FStock;
        end;
      end;
  
      if nDaiNum>0 then
      begin
        nStr := '%s%s 装车 %s %0.4d/%0.4d';
        nStr := Format(nStr,[nTunnelItem.FDesc, nTruck, nTunnelItem.FStock, 0, nDaiNum]);
        Display(nTunnel, cCounterDisp_CardID_tdk, nStr,nLocked);

        nStr := '%s %s %0.4d/%0.4d';
        nStr := Format(nStr,[nTunnelItem.FDesc, nTunnelItem.FStock, 0, nDaiNum]);
        Display(nTunnel, cCounterDisp_CardID_bzj, nStr,nLocked);

        nStr := '%s %s %0.4d/%0.4d';
        nStr := Format(nStr,[nTunnelItem.FDesc, nTruck, 0, nDaiNum]);
        Display(nTunnel, cCounterDisp_CardID_zcg, nStr,nLocked);
      end
      else begin
        nStr := '%s 空闲';
        nStr := Format(nStr,[nTunnelItem.FDesc]);
        Display(nTunnel, cCounterDisp_CardID_tdk, nStr,nLocked);
        Display(nTunnel, cCounterDisp_CardID_bzj, nStr,nLocked);
        Display(nTunnel, cCounterDisp_CardID_zcg, nStr,nLocked);
      end;
    except
      on E:Exception do
      begin
        nStr := 'TMgrLEDDispCounterManager.SendCounterLedDispInfo(nTruck=%s,nTunnel=%s,nDaiNum=%d,nStockname=%s)--发生异常[%s]';
        nStr := Format(nStr,[nTruck,nTunnel,nDaiNum,nStockname,e.Message]);
        WriteLog(nStr);    
      end;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TMgrLEDDispCounterManager.SendFreeToLedDispInfo(const nTunnel: string);
var
  nStr:string;
  nTunnelItem:PCounterTunnel;
  nIdx:Integer;
  nLocked:Boolean;
begin
  try
    FSyncLock.Enter;
    //lock first
    nLocked := False;
    try
      nTunnelItem := GetCounterTunnelItem(nTunnel);
      if not Assigned(nTunnelItem) then
      begin
        nStr := 'SendFreeToLedDispInfo--通道号[%s]不存在';
        nStr := Format(nStr,[nTunnel]);
        WriteLog(nStr);
        Exit;
      end;
      nIdx := FPaperBagTunnel.IndexOf(nTunnel);
      if nIdx<>-1 then
      begin
        FPaperBagTunnel.Delete(nIdx);
      end;

      nStr := '%s 空闲';
      nStr := Format(nStr,[nTunnelItem.FDesc]);
      Display(nTunnel, cCounterDisp_CardID_tdk, nStr,nLocked);
    except
      on E:Exception do
      begin
        nStr := 'TMgrLEDDispCounterManager.SendFreeToLedDispInfo(nTunnel=%s)--发生异常[%s]';
        nStr := Format(nStr,[nTunnel,e.Message]);
        WriteLog(nStr);    
      end;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TMgrLEDDispCounterManager.StartDisplay;
begin
  if (FCounterCards.FEnabled) and (FCounterCards.FCounterTunnelList.Count>0) then
  begin
    if not Assigned(FControler) then
      FControler := TCounterDisplayControler.Create(Self);
    FControler.WakupMe;
  end;
end;

procedure TMgrLEDDispCounterManager.StopDisplay;
begin
  if Assigned(FControler) then
    FControler.StopMe;
  FControler := nil;
end;

{ TCounterDisplayControler }

procedure TCounterDisplayControler.AddContent(
  const nContent: PCounterDispContent);
var nIdx: Integer;
    nItem: PCounterDispContent;  
begin
  for nIdx:=FBuffer.Count - 1 downto 0 do
  begin
    nItem := FBuffer[nIdx];
    if (nItem.FTunnelID = nContent.FTunnelID) and (nItem.FCardID=nContent.FCardID) then
    begin
      Dispose(nItem);
      FBuffer.Delete(nIdx);
    end;
  end;

  FBuffer.Add(nContent);
end;

constructor TCounterDisplayControler.Create(
  AOwner: TMgrLEDDispCounterManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;

  FBuffer := TList.Create;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2000;

//  FLedApi := TLedAPI.Create(AOwner.FWinHandle);
end;

destructor TCounterDisplayControler.Destroy;
begin
  FOwner.ClearBuffer(FBuffer, True);
  FWaiter.Free;
//  FLedApi.Free;
  inherited;
end;

//Date: 2015/2/8
//Parm: 字符串信息;字符数组
//Desc:
function AsciConvertBuf(const nTxt: string; var nBuf: TIdBytes): Integer;
var nIdx: Integer;
    nC: char;
begin
  Result := 0;
  for nIdx:=1 to Length(nTxt) do
  begin
    SetLength(nBuf, Result + 1);

    nC := nTxt[nIdx];

    nBuf[Result] := Ord(nC);
    Inc(Result);
  end;
end;

procedure TCounterDisplayControler.DoExuecte(const nCard: PCardInfo);
var nIdx: Integer;
    nBuf: TIdBytes;
    nStrSend: string;
    nContent: PCounterDispContent;
begin
  if not Terminated then
  begin
    try
      for nIdx:=FBuffer.Count - 1 downto 0 do
      begin
        nContent := FBuffer[nIdx];
        if CompareText(nContent.FTunnelID, nCard.FTunnelId) <> 0 then Continue;
        if CompareText(nContent.FCardID, nCard.FCardId) <> 0 then Continue;

        if nContent.FControlType=0 then
        begin
          nStrSend := GetBXShowInfoAtTime(nContent.FText, nCard.FAddr);
          AsciConvertBuf(nStrSend, nBuf);

          try
            if not nCard.FClient.Connected then
              nCard.FClient.Connect;
            //xxxxxx
          except
            on E: Exception do
            begin
              WriteLog(Format('连接屏幕[ %s.%s ]异常:[ %s ].', [nCard.FCardID,nCard.FName, E.Message]));
            end;
          end;

          nCard.FClient.Socket.Write(nBuf);
        end
        else begin
//          nStrSend := FLedAPI.Display(nCard.FIp, nCard.FPort, ncard.FAddr,
//            nCard.FWidth,nCard.FHeight,nContent.FControlType,
//            nContent.FText,nContent.FFontSize,nContent.FSingleLine);
//          if nStrSend<>'' then
//          begin
//            WriteLog(nStrSend);
//          end;
        end;
      end;
    except
      on E: Exception do
      begin
        WriteLog(Format('屏幕[ %s.%s ]异常:[ %s ].', [nCard.FCardID,
          nCard.FName, E.Message]));
        //loged

        nCard.FClient.Disconnect;
        if Assigned(nCard.FClient.IOHandler) then
          nCard.FClient.IOHandler.InputBuffer.Clear;
        //close connection
      end;
    end;
  end;
end;

procedure TCounterDisplayControler.Execute;
var nStr: string;
    nIdx,j: Integer;
    nContent: PCounterDispContent;
  nTunnelItem:PCounterTunnel;
  nCardItem:PCardInfo;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FOwner.FSyncLock.Enter;
    try
      for nIdx:=0 to FOwner.FBuffData.Count - 1 do
        AddContent(FOwner.FBuffData[nIdx]);
      FOwner.FBuffData.Clear;
    finally
      FOwner.FSyncLock.Leave;
    end;

    if FBuffer.Count > 0 then
    try
      for nIdx:=0 to FOwner.FCounterCards.FCounterTunnelList.Count-1 do
      begin
        nTunnelItem := PCounterTunnel(FOwner.FCounterCards.FCounterTunnelList.Items[nIdx]);
        for j := 0 to nTunnelItem.FCardInfoList.Count-1 do
        begin
          nCardItem := nTunnelItem.FCardInfoList.Items[j];
          DoExuecte(nCardItem);
        end;
      end;
      //send contents
    finally
      FOwner.ClearBuffer(FBuffer);
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//function TCounterDisplayControler.SendDynamicData(
//  const nContent: PCounterDispContent): Boolean;
//var
//  nStr:string;
//begin
//  Result := False;
//  try
//    if not FLedApi.DllLoaded then
//    begin
//      WriteLog(FLedApi.ErrorMsg);
//      Exit;
//    end;
//    if not FLedApi.InitializeSuccess then
//    begin
//      WriteLog(FLedApi.ErrorMsg);
//      Exit;
//    end;
//    nstr := FLedApi.Display(nContent.FIP,nContent.FPort,nContent.FAddr,nContent.FWidth,nContent.FHeigth,nContent.FControlType,nContent.FText);
//    if nStr<>'' then
//    begin
//      WriteLog(nstr);
//      Result := True;
//    end;
//  except
//    On E:Exception do
//    begin
//      WriteLog(E.Message);
//    end;
//  end;
//end;

procedure TCounterDisplayControler.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TCounterDisplayControler.WakupMe;
begin
  FWaiter.Wakeup;
end;

initialization
  gCounterDisplayManager := nil;
finalization
  FreeAndNil(gCounterDisplayManager);

end.
