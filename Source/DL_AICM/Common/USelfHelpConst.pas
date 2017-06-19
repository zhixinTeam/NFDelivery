unit USelfHelpConst;

interface

uses
  SysUtils, UDataModule;

const
  {*Frame ID*}
  cFI_FrameMain       = $0000;                       //主显示
  cFI_FrameQueryCard  = $0001;                       //磁卡查询
  cFI_FrameMakeCard   = $0002;                       //制卡
  cFI_FramePrint      = $0003;                       //打印

  cFI_FrameInputCertificate = $0004;                 //输入取卡凭证
  cFI_FrameReadCardID = $0005;                       //身份证号查询

  {*Form ID*}
  cFI_FormReadCardID  = $0050;                       //读取身份证


  {*CMD ID*}
  cCmd_QueryCard      = $0001;                       //查询卡片
  cCmd_FrameQuit      = $0002;                       //退出窗口
  cCmd_MakeCard       = $0003;                       //制卡
  cCmd_SelectZhiKa    = $0004;                       //选择商城订单

type
  TSysParam = record
    FLocalIP    : string;                            //本机IP
    FLocalMAC   : string;                            //本机MAC
    FLocalName  : string;                            //本机名称
    FMITServURL : string;                            //业务服务
  end;
  //系统参数

resourcestring
  sImages     = 'Images\';
  sConfig     = 'Config.Ini';
  sForm       = 'FormInfo.Ini';
  sDB         = 'DBConn.Ini';

  sHint      = '提示';                      //对话框标题
  sWarn      = '警告';                      //==
  sAsk       = '询问';                      //询问对话框
  sError     = '未知错误';                  //错误对话框

var
  gPath: string;                 //系统路径
  gSysParam:TSysParam;           //程序环境参数
  gTimeCounter: Int64;           //计时器

function GetIDCardNumCheckCode(nIDCardNum: string): string;
//身份证号校验算法
implementation

//Date: 2017/6/14
//Parm: 身份证号的前17位
//Desc: 获取身份证号校验码
function GetIDCardNumCheckCode(nIDCardNum: string): string;
const
  cWIArray: Array[0..16] of Integer = (7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2);
  cModCode: array [0..10] of string = ('1','0','X','9','8','7','6','5','4','3','2');
var
  nIdx, nSum, nModResult: Integer;
begin
  Result := '';

  if Length(nIDCardNum) < 17 then
    Exit;

  nSum := 0;
  for nIdx := 0 to Length(cWIArray) - 1 do
  begin
    nSum := nSum + StrToInt(nIDCardNum[nIdx + 1]) * cWIArray[nIdx];
  end;  
  nModResult := nSum mod 11;
  Result := cModCode[nModResult];
end;

end.
