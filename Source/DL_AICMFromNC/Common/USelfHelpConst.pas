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

  cFI_FramePurERPMakeCard   = $0006;                 //ERP采购单制卡
  cFI_FrameSaleMakeCard     = $0007;                 //ERP销售制卡

  {*Form ID*}
  cFI_FormReadCardID  = $0050;                       //读取身份证


  {*CMD ID*}
  cCmd_QueryCard      = $0001;                       //查询卡片
  cCmd_FrameQuit      = $0002;                       //退出窗口
  cCmd_MakeCard       = $0003;                       //制卡
  cCmd_SelectZhiKa    = $0004;                       //选择商城订单
  cCmd_MakeNCSaleCard = $0010;                       //NC订单制卡

  cSendWeChatMsgType_AddBill     = 1; //开提货单
  cSendWeChatMsgType_OutFactory  = 2; //车辆出厂
  cSendWeChatMsgType_Report      = 3; //报表
  cSendWeChatMsgType_DelBill     = 4; //删提货单

  c_WeChatStatusCreateCard       = 1; //订单已办卡
  c_WeChatStatusFinished         = 3; //订单已完成
  c_WeChatStatusIn               = 2;  //订单已进厂
  c_WeChatStatusDeleted          = 100;
type
  TSysParam = record
    FLocalIP    : string;                            //本机IP
    FLocalMAC   : string;                            //本机MAC
    FLocalName  : string;                            //本机名称
    FMITServURL : string;                            //业务服务
  end;
  //系统参数


  PMallPurchaseItem = ^stMallPurchaseItem;
  stMallPurchaseItem = record
    FOrder_Id : string;      //商城ID
    FProvID   : string;      //供应商ID
    FProvName : string;      //供应商名称
    FGoodsID  : string;      //物料编号
    FGoodsname: string;      //物料名称
    FData     : string;      //数量
    FMaxMum   : string;      //最大供应量
    FZhiKaNo  : string;      //合同编号
    FTrackNo  : string;      //车牌号
    FArea     : string;
  end;
    // 采购单

  TOrderInfoItem = record
    FZhiKaNo: string;
    FCusID: string;       //客户号
    FCusName: string;     //客户名
    FSaleMan: string;     //业务员
    FStockID: string;     //物料号
    FStockName: string;   //物料名

    FStockBrand: string;  //物料品牌
    FStockArea : string;  //产地，矿点

    FTruck: string;       //车牌号
    FBatchCode: string;   //批次号
    FOrders: string;      //订单号(可多张)
    FValue: Double;       //可用量
    FBm: string;          //喷码发送的中文编码
    FPd: string;
    FWxZhuId: string;
    FWxZiId: string;
    FSelect: Boolean;
  end;

  TOrderInfoItems = array of TOrderInfoItem;

resourcestring
  sImages     = 'Images\';
  sConfig     = 'Config.Ini';
  sForm       = 'FormInfo.Ini';
  sDB         = 'DBConn.Ini';
  sReportDir  = 'Report\';                  //报表目录

  sHint      = '提示';                      //对话框标题
  sWarn      = '警告';                      //==
  sAsk       = '询问';                      //询问对话框
  sError     = '未知错误';                  //错误对话框
  sUnCheck   = '□';
  sCheck     = '[√]';
var
  gPath: string;                 //系统路径
  gSysParam:TSysParam;           //程序环境参数
  gTimeCounter: Int64;           //计时器
  gNeedSearchPurOrder : Boolean;
  gNeedSearchSaleOrder : Boolean;

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
