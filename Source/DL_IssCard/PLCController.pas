unit PLCController;

interface
uses
  IdGlobal,IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient;
const
  //PLC地址
  Addr_PLC=$02;
  //modbus功能码
  mbfReadHoldingRegs = $03;//读取寄存器
  mbfWriteOneReg = $06;//写单个寄存器
  //ModBus偏移地址,指令码中偏移地址为此值减1
  Addr_Offset:array[0..18] of Word = (
    0001,	//控制（对每位含义见下）
    0002,	//反馈（对每位含义见下）
    0003,	//阀开度设定
    0004,	//阀开度反馈
    0005,  //保留
    0006,  //保留
    0007,  // 控制（对每位含义见下）
    0008,	//反馈（对每位含义见下）
    0009,	//阀开度设定
    0010,	//阀开度反馈
    0011,  //保留
    0012,  //保留
    0013,	//控制（对每位含义见下）
    0014,	//反馈（对每位含义见下）
    0015,	//阀开度设定
    0016,	//阀开度反馈
    0017,  //保留
    0018,  //保留
    0019   //保留
  );

  Control_UP:Word=$0001; //上升
  Control_DOWN:Word=$0002; //下降
  Control_Add:Word=$0004; //加料
  Control_Pause:Word=$0008; //暂停加料
  Control_Reset:Word=$0010; //故障复位

  Feedback_ready:Word=$0001;          //备妥信号
  Feedback_switch:Word=$0002;         //料位开关
  Feedback_FanStatus:Word=$0004;      //风机运行反馈
  Feedback_MaterialStatus:Word=$0008; //加料运行反馈

  Feedback_ErrUp:Word = $0016;        //提升故障
  Feedback_ErrMove:Word = $0032;      //移动故障
  Feedback_ErrSignal:Word = $0064;    //通信故障
  Feedback_ErrTotle:Word = $0128;     //系统总故障
  Feedback_ErrFan:Word = $0256;       //风机未备妥

  Const_instruction_size=8; //指令长度
type
  //otStart:开始
  //otPause:暂停
  //otStop:停止
  //otReset:复位
  //otUp:上移
  //otDown:下移
  //otQuery:查询
  //otUNPause:取消暂停
  //otUnUP:停止上升
  //otUnDown:停止下降
  //otUnReset:取消复位
  //otSetOpen：设定开度
  //otGetOpen:获取开度
  //otGetStatus:获取各道状态信息
  TOptionType = (otStart,otPause,otStop,otReset,otUp,otDown,otQuery,
    otUNPause,otUnUP,otUnDown,otUnReset,otSetOpen,otGetOpen,otGetStatus);
  TPLCController = class(TObject)
  private
    FErrCode:Integer;
    FErrMsg:string;
    FTcpCient:TIdTCPClient;
    FMasterAddr:Byte;
    FIndex:Integer;
    FOpenValue:Integer;         //阀度
    FUpDownKeepOpen: Boolean;  //上升下降时是否关闭放料口
    Finstructions:TIdBytes;
    FCurrentOpt:TOptionType;
    FStatusOrd:TIdBytes;
    function Initinstructions:Boolean;
    function CalculateCRC16ModBus(const Buffer: array of Byte; const nEnd:Integer=0):Word;
    function iIntToHex(n:Word):Byte;
  public
    constructor Create(nTcpClient:TIdTCPClient;const nMasterAddr:Byte=Addr_PLC);
    function Start(const nIdx:integer):Boolean;
    function Pause(const nIdx:integer):Boolean;
    function UnPause(const nIdx:Integer):boolean;
    function Stop(const nIdx:integer):Boolean;
    function Reset(const nIdx:integer):Boolean;
    function Up(const nIdx:integer; nData:Boolean):Boolean;
    function UnUp(const nIdx:integer; nData:Boolean):Boolean;
    function Down(const nIdx:integer; nData:Boolean):Boolean;
    function UnDown(const nIdx:Integer; nData:Boolean):Boolean;
    function Query(const nIdx:Integer;var nData:Word):Boolean;
    function UnReset(const nIdx:integer):Boolean;

    function SetOpening(const nIdx, nValue:integer):Boolean;
    function GetOpening(const nIdx, nValue:Integer):Integer;
    function GetStatus(const nIdx, nValue:Integer):Boolean;
    property ErrCode:Integer read FErrCode;
    property ErrMsg:string read FErrMsg;
    property StatusOrd:TIdBytes read FStatusOrd;
  end;

implementation
uses
  SysUtils;
{ TPLCController }

function TPLCController.CalculateCRC16ModBus(const Buffer: array of Byte;
  const nEnd: Integer): Word;
const
  GENP=$A001;//多项式公式X16+X15+X2+1（1100 0000 0000 0101）
var
  crc:Word;
  i:Integer;
  tmp:Byte;
  nfinalValue :Integer;

  //计算1个字节的校验码
  procedure CalOneByte(AByte:Byte);
  var
    j:Integer;
  begin
    crc:=crc xor AByte;//将数据与CRC寄存器的低8位进行异或
    for j:=0 to 7 do //对每一位进行校验
    begin
      tmp:=crc and 1;//取出最低位
      crc:=crc shr 1;//寄存器向右移一位
      crc:=crc and $7FFF;//将最高位置0
      if tmp=1 then//检测移出的位，如果为1，那么与多项式异或
      begin
        crc:=crc xor GENP;
      end;
      crc:=crc and $FFFF;
    end;
  end;
begin
  nfinalValue := High(Buffer);
  if nEnd>0 then
  begin
    nfinalValue := nEnd;
  end;
  crc:=$FFFF;             //将余数设定为FFFF
  for i:=Low(Buffer) to nfinalValue do   //对每一个字节进行校验
  begin
    CalOneByte(Buffer[i]);
  end;
  Result:=crc;
end;

constructor TPLCController.Create(nTcpClient:TIdTCPClient;const nMasterAddr: Byte);
begin
  inherited create;
  FErrCode := 0;
  FErrMsg := '';
  FTcpCient := nTcpClient;
  FMasterAddr := nMasterAddr;
end;

function TPLCController.UnPause(const nIdx:integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otUNPause;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 30000;
        FErrMsg := '取消暂停指令执行失败';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 39999;
      FErrMsg := '取消暂停指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := True;  
end;

function TPLCController.Down(const nIdx:integer; nData:Boolean): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otDown;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 80000;
        FErrMsg := '下移指令执行失败';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 89999;
      FErrMsg := '下移指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.Initinstructions: Boolean;
var
  nCrc:Word;
  noffset:word;
  nCrcStr:string;
  nUnPauseInstruct,nUnUpInstruct,nUnDownInstruct,nUnResetInstruct:Word;
  nOrder:string;
begin
  nUnPauseInstruct := $0004;  //not Control_Pause;
  nUnUpInstruct    := $0000;  //not Control_UP;
  nUnDownInstruct  := $0000;  //not Control_DOWN;
  nUnResetInstruct := $0000;  //not Control_Reset;
  case FCurrentOpt of
    otSetOpen:   noffset := Addr_Offset[(FIndex-1)*6]+1;
    otGetOpen:   noffset := Addr_Offset[(FIndex-1)*6]+2;
    otGetStatus: noffset := Addr_Offset[0]-1;
    otUp, otUnUP:begin
      if FUpDownKeepOpen then
        noffset := Addr_Offset[(FIndex-1)*6]+3   //上升下降时放料口保持开启
      else
        noffset := Addr_Offset[(FIndex-1)*6]-1;
    end;
    otDown,otUnDown:begin
      if FUpDownKeepOpen then
        noffset := Addr_Offset[(FIndex-1)*6]+4   //上升下降时放料口保持开启
      else
        noffset := Addr_Offset[(FIndex-1)*6]-1;
    end;
  else
    noffset := Addr_Offset[(FIndex-1)*6]-1;
  end;

  SetLength(Finstructions,Const_instruction_size);
  FillBytes(Finstructions,Const_instruction_size,0);

  Finstructions[0] := FMasterAddr;
  case FCurrentOpt of
    otStart:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := Control_Add shr 8;
      Finstructions[5] := Control_Add and $0F;
    end;
    otPause:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := Control_pause shr 8;
      Finstructions[5] := Control_pause and $0F;
    end;
    otUnPause:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := 0;//nUnPauseInstruct shr 8;
      Finstructions[5] := 0;//nUnPauseInstruct and $0F;
    end;    
    otStop:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := 0;
      Finstructions[5] := 0;
    end;
    otReset:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := Control_Reset shr 8;
      Finstructions[5] := Control_Reset;
    end;
    otUnReset:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := nUnResetInstruct shr 8;
      Finstructions[5] := nUnResetInstruct and $0F;
    end;
    otUp:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := Control_UP shr 8;
      Finstructions[5] := Control_UP and $0F;
    end;
    otUnUP:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := nUnUpInstruct shr 8;
      Finstructions[5] := nUnUpInstruct and $0F;    
    end;
    otDown:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      if FUpDownKeepOpen then
      begin
        Finstructions[4] := Control_UP shr 8;
        Finstructions[5] := Control_UP and $0F;
      end
      else
      begin
        Finstructions[4] := Control_DOWN shr 8;
        Finstructions[5] := Control_DOWN and $0F;
      end;
    end;
    otUnDown:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := nUnDownInstruct shr 8;
      Finstructions[5] := nUnDownInstruct and $0F;
    end;  
    otQuery:begin
      Finstructions[1] := mbfReadHoldingRegs;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := 0;
      Finstructions[5] := 1;
    end;
    otSetOpen:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := $00;
      Finstructions[5] := Word(FOpenValue);
    end;
    otGetOpen:begin
      Finstructions[1] := mbfReadHoldingRegs;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := $00;
      Finstructions[5] := Word(FOpenValue);
    end;
    otGetStatus:begin
      Finstructions[1] := mbfReadHoldingRegs;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := $00;
      Finstructions[5] := Word(20);
    end;
  else;
  end;
  nCrc := CalculateCRC16ModBus(Finstructions,5);
  nCrcStr := IntToHex(nCrc,2);
  if Length(nCrcStr)=3 then nCrcStr := '0'+nCrcStr;
  Finstructions[6] := StrToInt('$'+Copy(nCrcStr,3,2));
  Finstructions[7] := StrToInt('$'+Copy(nCrcStr,1,2));
end;

function TPLCController.Pause(const nIdx:integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otPause;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 20000;
        FErrMsg := '暂停指令执行失败';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 29999;
      FErrMsg := '暂停指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := True;  
end;

function TPLCController.Query(const nIdx:Integer;var nData:Word): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
  iretSize:Integer;
begin
  nData := 0;
  Result := False;
  FCurrentOpt := otStart;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    nData := nRecvBuffer[3] shl 8 +nRecvBuffer[4];
  except
    on E:Exception do
    begin
      FErrCode := 109999;
      FErrMsg := '查询指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
end;

function TPLCController.Reset(const nIdx:integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otReset;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 50000;
        FErrMsg := '复位指令执行失败';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 59999;
      FErrMsg := '取消复位指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.Start(const nIdx:integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otStart;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 10000;
        FErrMsg := '启动指令执行失败';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 19999;
      FErrMsg := '启动指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.Stop(const nIdx:integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otStop;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 40000;
        FErrMsg := '停止指令执行失败';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 49999;
      FErrMsg := '停止指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := True;  
end;

function TPLCController.Up(const nIdx:integer; nData:Boolean): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otUp;
  FIndex := nIdx;
  FUpDownKeepOpen := nData ;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 60000;
        FErrMsg := '上移指令执行失败';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 69999;
      FErrMsg := '上移指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.UnUp(const nIdx: integer;nData:Boolean): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otUnUP;
  FIndex := nIdx;
  FUpDownKeepOpen:= nData;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 70000;
        FErrMsg := '取消上移指令执行失败';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 79999;
      FErrMsg := '取消上移指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.UnDown(const nIdx: Integer; nData:Boolean): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otUnDown;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 90000;
        FErrMsg := '取消下移指令执行失败';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 99999;
      FErrMsg := '取消下移指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.UnReset(const nIdx: integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otUnReset;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 110000;
        FErrMsg := '取消暂停指令执行失败';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 119999;
      FErrMsg := '取消暂停指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.SetOpening(const nIdx, nValue: integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i: integer;
begin
  Result := False;
  FCurrentOpt := otSetOpen;
  FIndex := nIdx;
  FOpenValue := nvalue;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 120000;
        FErrMsg := '设置阀位开度指令执行失败';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 129999;
      FErrMsg := '设置阀位开度指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.GetOpening(const nIdx, nValue:integer): Integer;
var
  nRecvBuffer:TIdBytes;
  i: integer;
begin
  Result := -1;
  FCurrentOpt := otGetOpen;
  FIndex := nIdx;
  FOpenValue := nValue;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 130000;
        FErrMsg := '读取阀位开度指令执行失败';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 139999;
      FErrMsg := '读取阀位开度指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := 0;
end;

function TPLCController.GetStatus(const nIdx, nValue: Integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i: integer;
begin
  Result := False;
  FCurrentOpt := otGetStatus;
  FIndex := nIdx;
  FOpenValue := nValue;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    FStatusOrd := nRecvBuffer;
  except
    on E:Exception do
    begin
      FErrCode := 149999;
      FErrMsg := '读取阀位开度指令执行失败,发生未知异常:'+e.Message;
      Exit;
    end;
  end;
  Result := true;
end;

function TPLCController.iIntToHex(n: Word): Byte;
begin
  if n < 10 then
  begin
    Result := n;
    exit;
  end;
  case n of
    10:Result := $0A;
    11:Result := $0B;
    12:Result := $0C;
    13:Result := $0D;
    14:Result := $0E;
    15:Result := $0F;
  end;
end;

end.
