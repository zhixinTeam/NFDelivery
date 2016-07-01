{*******************************************************************************
  作者: dmzn@ylsoft.com 2007-10-09
  描述: 项目通用常,变量定义单元
*******************************************************************************}
unit USysConst;

interface

uses
  SysUtils, Classes, ComCtrls;

const
  cSBar_Date            = 0;                         //日期面板索引
  cSBar_Time            = 1;                         //时间面板索引
  cSBar_User            = 2;                         //用户面板索引
  cRecMenuMax           = 5;                         //最近使用导航区最大条目数
  cItemIconIndex        = 11;                        //默认的提货单列表图标
  
const
  {*Frame ID*}
  cFI_FrameSysLog       = $0001;                     //系统日志
  cFI_FrameViewLog      = $0002;                     //本地日志
  cFI_FrameAuthorize    = $0003;                     //系统授权

  cFI_FrameCustomer     = $0004;                     //客户管理
  cFI_FrameTrucks       = $0010;                     //车辆档案
  cFI_FrameShip         = $0011;                     //船只档案
  cFI_FrameWharf        = $0012;                     //码头档案
  cFI_FrameInventory    = $0013;                     //存活档案
  cFI_FrameDeduct       = $0017;                     //暗扣规则
  cFI_FrameBatch        = $0018;                     //批次管理
  cFI_FrameMine         = $0019;                     //矿点档案
  cFI_FrameBatchQuery   = $0016;                     //批次管理

  cFI_FrameReqSale      = $0020;                     //销售申请
  cFI_FrameReqProvide   = $0021;                     //采购申请
  cFI_FrameReqDispatch  = $0022;                     //调拨单

  cFI_FrameBill         = $0030;                     //开提货单
  cFI_FrameBillQuery    = $0031;                     //开单查询
  cFI_FrameMakeCard     = $0032;                     //办理磁卡

  cFI_FrameLadingDai    = $0033;                     //袋装提货
  cFI_FramePoundQuery   = $0034;                     //磅房查询
  cFI_FrameFangHuiQuery = $0035;                     //放灰查询
  cFI_FrameZhanTaiQuery = $0036;                     //栈台查询
  cFI_FrameZTDispatch   = $0037;                     //栈台调度
  cFI_FramePoundManual  = $0038;                     //手动称重
  cFI_FramePoundAuto    = $0039;                     //自动称重

  cFI_FrameTruckQuery   = $0050;                     //车辆查询
  cFI_FrameCusAccountQuery = $0051;                  //客户账户
  cFI_FrameCusInOutMoney   = $0052;                  //出入金明细
  cFI_FrameSaleTotalQuery  = $0053;                  //累计发货
  cFI_FrameSaleDetailQuery = $0054;                  //发货明细
  cFI_FrameZhiKaDetail  = $0055;                     //纸卡明细
  cFI_FrameDispatchQuery = $0056;                    //调度查询

  cFI_FrameProvideDetailQuery = $0057;                  //供应明细
  cFI_FrameDiapatchDetailQuery = $0058;                  //调度明细

  cFI_FrameChineseBase  = $0062;                     //汉字喷码
  cFI_FrameChineseDict  = $0063;                     //喷码字典
  
  cFI_FrameProvider     = $0102;                     //供应
  cFI_FrameProvideLog   = $0105;                     //供应日志
  cFI_FrameMaterails    = $0106;                     //原材料

  cFI_FrameWXAccount    = $0110;                     //微信账户
  cFI_FrameWXSendLog    = $0111;                     //发送日志

  cFI_FrameProvBase     = $0120;                     //采购入厂单
  cFI_FrameProvDetail   = $0121;                     //采购单明细
  cFI_FrameProvTruckQuery= $0122;                    //采购单明细

  cFI_FormMemo          = $1000;                     //备注窗口
  cFI_FormBackup        = $1001;                     //数据备份
  cFI_FormRestore       = $1002;                     //数据恢复
  cFI_FormIncInfo       = $1003;                     //公司信息
  cFI_FormChangePwd     = $1005;                     //修改密码

  cFI_FormBaseInfo      = $1006;                     //基本信息
  cFI_FormAuthorize     = $1007;                     //安全验证
  cFI_FormCustomer      = $1008;                     //客户资料

  cFI_FormTrucks        = $1010;                     //车辆档案
  cFI_FormShip          = $1011;                     //船只档案
  cFI_FormWharf         = $1012;                     //码头档案
  cFI_FormInventory     = $1013;                     //存活档案
  cFI_FormDeduct        = $1017;                     //暗扣规则
  cFI_FormBatch         = $1018;                     //批次管理
  cFI_FormMine          = $1019;                     //矿点档案
  cFI_FormBatchEdit     = $1016;                     //批次管理

  cFI_FormMakeBill      = $1020;                     //开交货单
  cFI_FormGetOrder      = $1021;                     //获取订单
  cFI_FormGetCustom     = $1022;                     //获取客户
  cFI_FormGetTruck      = $1023;                     //获取车辆
  cFI_FormGetNCStock    = $1024;                     //获取物料
  cFI_FormMakeCard      = $1025;                     //办理磁卡
  cFI_FormMakeRFIDCard  = $1026;                     //办理电子标签
  cFI_FormMakeProvCard  = $1027;                     //办理磁卡

  cFI_FormGetMine       = $1029;                     //矿点档案

  cFI_FormTruckIn       = $1031;                     //车辆进厂
  cFI_FormTruckOut      = $1032;                     //车辆出厂
  cFI_FormVerifyCard    = $1033;                     //磁卡验证
  cFI_FormLadDai        = $1034;                     //袋装提货
  cFI_FormLadSan        = $1035;                     //散装提货
  cFI_FormJiShuQi       = $1036;                     //计数管理

  cFI_FormZTLine        = $1040;                     //装车线
  cFI_FormDisPound      = $1041;                     //磅站调度

  cFI_FormProvider      = $1051;                     //供应商
  cFI_FormMaterails     = $1052;                     //原材料

  cFI_FormChangeTunnel  = $1061;                     //定道装车
  cFI_FormChineseBase   = $1062;                     //汉字喷码
  cFI_FormChineseDict   = $1063;                     //喷码字典

  cFI_FormWXAccount     = $1091;                     //微信账户
  cFI_FormWXSendlog     = $1092;                     //微信日志

  cFI_FormProvBase      = $1120;                     //采购入厂单

  {*Command*}
  cCmd_RefreshData      = $0002;                     //刷新数据
  cCmd_ViewSysLog       = $0003;                     //系统日志

  cCmd_ModalResult      = $1001;                     //Modal窗体
  cCmd_FormClose        = $1002;                     //关闭窗口
  cCmd_AddData          = $1003;                     //添加数据
  cCmd_EditData         = $1005;                     //修改数据
  cCmd_ViewData         = $1006;                     //查看数据
  cCmd_GetData          = $1007;                     //选择数据

type
  TSysParam = record
    FProgID     : string;                            //程序标识
    FAppTitle   : string;                            //程序标题栏提示
    FMainTitle  : string;                            //主窗体标题
    FHintText   : string;                            //提示文本
    FCopyRight  : string;                            //主窗体提示内容

    FUserID     : string;                            //用户标识
    FUserName   : string;                            //当前用户
    FUserPwd    : string;                            //用户口令
    FGroupID    : string;                            //所在组
    FIsAdmin    : Boolean;                           //是否管理员
    FIsNormal   : Boolean;                           //帐户是否正常

    FRecMenuMax : integer;                           //导航栏个数
    FIconFile   : string;                            //图标配置文件
    FUsesBackDB : Boolean;                           //使用备份库

    FLocalIP    : string;                            //本机IP
    FLocalMAC   : string;                            //本机MAC
    FLocalName  : string;                            //本机名称
    FHardMonURL : string;                            //硬件守护

    FFactNum    : string;                            //工厂编号
    FSerialID   : string;                            //电脑编号
    FIsManual   : Boolean;                           //手动过磅
    FAutoPound  : Boolean;                           //自动称重

    FPoundPZ    : Double;
    FPoundPF    : Double;                            //皮重误差
    FPoundDaiZ  : Double;
    FPoundDaiZ_1: Double;                            //袋装正误差
    FPoundDaiF  : Double;
    FPoundDaiF_1: Double;                            //袋装负误差
    FDaiPercent : Boolean;                           //按比例计算偏差
    FDaiWCStop  : Boolean;                           //不允许袋装偏差
    FPoundSanF  : Double;                            //散装负误差
    FPoundTruck : Double;                            //车皮误差
    FPicBase    : Integer;                           //图片索引
    FPicPath    : string;                            //图片目录
    FVoiceUser  : Integer;                           //语音计数
    FProberUser : Integer;                           //检测器计数
  end;
  //系统参数

  TModuleItemType = (mtFrame, mtForm);
  //模块类型

  PMenuModuleItem = ^TMenuModuleItem;
  TMenuModuleItem = record
    FMenuID: string;                                 //菜单名称
    FModule: integer;                                //模块标识
    FItemType: TModuleItemType;                      //模块类型
  end;

//------------------------------------------------------------------------------
var
  gPath: string;                                     //程序所在路径
  gSysParam:TSysParam;                               //程序环境参数
  gStatusBar: TStatusBar;                            //全局使用状态栏
  gMenuModule: TList = nil;                          //菜单模块映射表

//------------------------------------------------------------------------------
ResourceString
  sProgID             = 'DMZN';                      //默认标识
  sAppTitle           = 'DMZN';                      //程序标题
  sMainCaption        = 'DMZN';                      //主窗口标题

  sHint               = '提示';                      //对话框标题
  sWarn               = '警告';                      //==
  sAsk                = '询问';                      //询问对话框
  sError              = '未知错误';                  //错误对话框

  sDate               = '日期:【%s】';               //任务栏日期
  sTime               = '时间:【%s】';               //任务栏时间
  sUser               = '用户:【%s】';               //任务栏用户

  sLogDir             = 'Logs\';                     //日志目录
  sLogExt             = '.log';                      //日志扩展名
  sLogField           = #9;                          //记录分隔符

  sImageDir           = 'Images\';                   //图片目录
  sReportDir          = 'Report\';                   //报表目录
  sBackupDir          = 'Backup\';                   //备份目录
  sBackupFile         = 'Bacup.idx';                 //备份索引
  sCameraDir          = 'Camera\';                   //抓拍目录

  sConfigFile         = 'Config.Ini';                //主配置文件
  sConfigSec          = 'Config';                    //主配置小节
  sVerifyCode         = ';Verify:';                  //校验码标记

  sFormConfig         = 'FormInfo.ini';              //窗体配置
  sSetupSec           = 'Setup';                     //配置小节
  sDBConfig           = 'DBConn.ini';                //数据连接
  sDBConfig_bk        = 'isbk';                      //备份库

  sExportExt          = '.txt';                      //导出默认扩展名
  sExportFilter       = '文本(*.txt)|*.txt|所有文件(*.*)|*.*';
                                                     //导出过滤条件 

  sInvalidConfig      = '配置文件无效或已经损坏';    //配置文件无效
  sCloseQuery         = '确定要退出程序吗?';         //主窗口退出

implementation

//------------------------------------------------------------------------------
//Desc: 添加菜单模块映射项
procedure AddMenuModuleItem(const nMenu: string; const nModule: Integer;
 const nType: TModuleItemType = mtFrame);
var nItem: PMenuModuleItem;
begin
  New(nItem);
  gMenuModule.Add(nItem);

  nItem.FMenuID := nMenu;
  nItem.FModule := nModule;
  nItem.FItemType := nType;
end;

//Desc: 菜单模块映射表
procedure InitMenuModuleList;
begin
  gMenuModule := TList.Create;

  AddMenuModuleItem('MAIN_A01', cFI_FormIncInfo, mtForm);
  AddMenuModuleItem('MAIN_A02', cFI_FrameSysLog);
  AddMenuModuleItem('MAIN_A03', cFI_FormBackup, mtForm);
  AddMenuModuleItem('MAIN_A04', cFI_FormRestore, mtForm);
  AddMenuModuleItem('MAIN_A05', cFI_FormChangePwd, mtForm);
  AddMenuModuleItem('MAIN_A07', cFI_FrameAuthorize);

  AddMenuModuleItem('MAIN_B01', cFI_FrameTrucks);
  AddMenuModuleItem('MAIN_B02', cFI_FrameShip);
  AddMenuModuleItem('MAIN_B03', cFI_FrameWharf);
  AddMenuModuleItem('MAIN_B04', cFI_FrameInventory);
  AddMenuModuleItem('MAIN_B05', cFI_FrameDeduct);
  AddMenuModuleItem('MAIN_B06', cFI_FrameBatch);
  AddMenuModuleItem('MAIN_B07', cFI_FrameReqProvide);
  AddMenuModuleItem('MAIN_B08', cFI_FrameReqSale);
  AddMenuModuleItem('MAIN_B09', cFI_FrameReqDispatch);
  AddMenuModuleItem('MAIN_B11', cFI_FrameBatchQuery);
  AddMenuModuleItem('MAIN_B12', cFI_FrameChineseBase);
  AddMenuModuleItem('MAIN_B13', cFI_FrameChineseDict);

  AddMenuModuleItem('MAIN_D02', cFI_FrameMakeCard);
  AddMenuModuleItem('MAIN_D03', cFI_FormMakeBill, mtForm);
  AddMenuModuleItem('MAIN_D06', cFI_FrameBill);

  AddMenuModuleItem('MAIN_E01', cFI_FramePoundManual);
  AddMenuModuleItem('MAIN_E02', cFI_FormDisPound, mtForm);
  AddMenuModuleItem('MAIN_E03', cFI_FramePoundQuery);
  AddMenuModuleItem('MAIN_E05', cFI_FramePoundAuto);

  AddMenuModuleItem('MAIN_F01', cFI_FormLadDai, mtForm);
  AddMenuModuleItem('MAIN_F03', cFI_FrameZhanTaiQuery);
  AddMenuModuleItem('MAIN_F04', cFI_FrameZTDispatch);

  AddMenuModuleItem('MAIN_G01', cFI_FormLadSan, mtForm);
  AddMenuModuleItem('MAIN_G02', cFI_FrameFangHuiQuery);

  AddMenuModuleItem('MAIN_L01', cFI_FrameTruckQuery);
  AddMenuModuleItem('MAIN_L02', cFI_FrameCusAccountQuery);
  AddMenuModuleItem('MAIN_L03', cFI_FrameCusInOutMoney);
  AddMenuModuleItem('MAIN_L05', cFI_FrameDispatchQuery);
  AddMenuModuleItem('MAIN_L06', cFI_FrameSaleDetailQuery);
  AddMenuModuleItem('MAIN_L07', cFI_FrameSaleTotalQuery);
  AddMenuModuleItem('MAIN_L08', cFI_FrameZhiKaDetail);
  AddMenuModuleItem('MAIN_L10', cFI_FrameProvideDetailQuery);
  AddMenuModuleItem('MAIN_L11', cFI_FrameDiapatchDetailQuery);
  AddMenuModuleItem('MAIN_L12', cFI_FrameProvDetail);

  AddMenuModuleItem('MAIN_H01', cFI_FormTruckIn, mtForm);
  AddMenuModuleItem('MAIN_H02', cFI_FormTruckOut, mtForm);
  AddMenuModuleItem('MAIN_H03', cFI_FrameTruckQuery);
  
  AddMenuModuleItem('MAIN_M01', cFI_FrameProvider);
  AddMenuModuleItem('MAIN_M02', cFI_FrameMaterails);
  AddMenuModuleItem('MAIN_M04', cFI_FrameProvideLog);
  AddMenuModuleItem('MAIN_M05', cFI_FrameProvBase);
  AddMenuModuleItem('MAIN_M06', cFI_FrameProvTruckQuery);
  AddMenuModuleItem('MAIN_M07', cFI_FrameMine);

  AddMenuModuleItem('MAIN_W01', cFI_FrameWXAccount);
  AddMenuModuleItem('MAIN_W02', cFI_FrameWXSendLog);
  AddMenuModuleItem('MAIN_W03', cFI_FrameCustomer);
end;

//Desc: 清理模块列表
procedure ClearMenuModuleList;
var nIdx: integer;
begin
  for nIdx:=gMenuModule.Count - 1 downto 0 do
  begin
    Dispose(PMenuModuleItem(gMenuModule[nIdx]));
    gMenuModule.Delete(nIdx);
  end;

  FreeAndNil(gMenuModule);
end;

initialization
  InitMenuModuleList;
finalization
  ClearMenuModuleList;
end.


