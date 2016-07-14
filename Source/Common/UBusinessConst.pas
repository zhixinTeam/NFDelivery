{*******************************************************************************
  作者: dmzn@163.com 2012-02-03
  描述: 业务常量定义

  备注:
  *.所有In/Out数据,最好带有TBWDataBase基数据,且位于第一个元素.
*******************************************************************************}
unit UBusinessConst;

interface

uses
  Classes, SysUtils, UBusinessPacker, ULibFun, USysDB;

const
  {*channel type*}
  cBus_Channel_Connection     = $0002;
  cBus_Channel_Business       = $0005;

  {*query field define*}
  cQF_Bill                    = $0001;

  {*business command*}
  cBC_GetSerialNO             = $0001;   //获取串行编号
  cBC_ServerNow               = $0002;   //服务器当前时间
  cBC_IsSystemExpired         = $0003;   //系统是否已过期
  cBC_IsTruckValid            = $0004;   //车牌是否有效
  cBC_UserLogin               = $0005;   //用户登录
  cBC_UserLogOut              = $0006;   //用户注销
  cBC_GetCardUsed             = $0007;   //获取卡片类型

  cBC_GetCustomerMoney        = $0010;   //获取客户可用金
  cBC_GetZhiKaMoney           = $0011;   //获取纸卡可用金

  cBC_SaveTruckInfo           = $0013;   //保存车辆信息
  cBC_GetStockBatcode         = $0014;   //获取物料批次
  cBC_GetTruckPoundData       = $0015;   //获取车辆称重数据
  cBC_SaveTruckPoundData      = $0016;   //保存车辆称重数据
  cBC_SaveStockBatcode        = $0017;   //保存物料批次

  cBC_GetOrderFHValue         = $0018;   //获取订单发货量
  cBC_GetOrderGYValue         = $0019;   //获取订单供应量
  cBC_SyncME25                = $0100;   //同步发货单到榜单
  cBC_SyncME03                = $0101;   //同步供应到磅单
  cBC_GetSQLQueryOrder        = $0102;   //查询订单语句
  cBC_GetSQLQueryCustomer     = $0103;   //查询客户语句
  cBC_GetSQLQueryDispatch     = $0104;   //查询调拨订单

  cBC_SaveBills               = $0020;   //保存交货单列表
  cBC_DeleteBill              = $0021;   //删除交货单
  cBC_ModifyBillTruck         = $0022;   //修改车牌号
  cBC_SaleAdjust              = $0023;   //销售调拨
  cBC_SaveBillCard            = $0024;   //绑定交货单磁卡
  cBC_LogoffCard              = $0025;   //注销磁卡
  cBC_DeleteOrder             = $0026;   //删除入厂明细

  cBC_GetPostBills            = $0030;   //获取岗位交货单
  cBC_SavePostBills           = $0031;   //保存岗位交货单

  cBC_SaveBillNew             = $0032;   //生成基础交货单
  cBC_DeleteBillNew           = $0033;   //删除基础交货单
  cBC_SaveBillNewCard         = $0034;   //绑定基础单磁卡
  cBC_LogoffCardNew           = $0035;   //注销磁卡
  cBC_SaveBillFromNew         = $0036;   //根据基础单据生成交货单

  cBC_ChangeDispatchMode      = $0053;   //切换调度模式
  cBC_GetPoundCard            = $0054;   //获取磅站卡号
  cBC_GetQueueData            = $0055;   //获取队列数据
  cBC_PrintCode               = $0056;
  cBC_PrintFixCode            = $0057;   //喷码
  cBC_PrinterEnable           = $0058;   //喷码机启停
  cBC_PrinterChinaEnable      = $0059;   //喷码机启停

  cBC_JSStart                 = $0060;
  cBC_JSStop                  = $0061;
  cBC_JSPause                 = $0062;
  cBC_JSGetStatus             = $0063;
  cBC_SaveCountData           = $0064;   //保存计数结果
  cBC_RemoteExecSQL           = $0065;

  cBC_IsTunnelOK              = $0075;
  cBC_TunnelOC                = $0076;

  cBC_GetSQLQueryWeixin       = $0081;   //获取微信信息查询语句
  cBC_SaveWeixinAccount       = $0082;   //保存微信账户
  cBC_DelWeixinAccount        = $0083;   //删除微信账户
  cBC_GetWeiXinReport         = $0084;   //获取微信报表
  cBC_GetWeiXinQueue          = $0085;   //获取微信报表

  cBC_GetTruckPValue          = $0091;   //获取车辆预置皮重
  cBC_SaveTruckPValue         = $0092;   //保存车辆预置皮重
  cBC_GetPoundBaseValue       = $0093;   //获取地磅表头跳动基数
type
  PWorkerQueryFieldData = ^TWorkerQueryFieldData;
  TWorkerQueryFieldData = record
    FBase     : TBWDataBase;
    FType     : Integer;           //类型
    FData     : string;            //数据
  end;

  PWorkerBusinessCommand = ^TWorkerBusinessCommand;
  TWorkerBusinessCommand = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //命令
    FData     : string;            //数据
    FExtParam : string;            //参数
  end;

  TPoundStationData = record
    FStation  : string;            //磅站标识
    FValue    : Double;           //皮重
    FDate     : TDateTime;        //称重日期
    FOperator : string;           //操作员
  end;

  PLadingBillItem = ^TLadingBillItem;
  TLadingBillItem = record
    FID         : string;          //交货单号
    FZhiKa      : string;          //纸卡编号
    FCusID      : string;          //客户编号
    FCusName    : string;          //客户名称
    FTruck      : string;          //车牌号码

    FType       : string;          //品种类型
    FStockNo    : string;          //品种编号
    FStockName  : string;          //品种名称
    FValue      : Double;          //提货量
    FPrice      : Double;          //提货单价

    FCard       : string;          //磁卡号
    FIsVIP      : string;          //通道类型
    FStatus     : string;          //当前状态
    FNextStatus : string;          //下一状态

    FPData      : TPoundStationData; //称皮
    FMData      : TPoundStationData; //称毛
    FFactory    : string;          //工厂编号
    FOrigin     : string;          //来源,矿点
    FPModel     : string;          //称重模式
    FPType      : string;          //业务类型
    FPoundID    : string;          //称重记录

    FSelected   : Boolean;         //选中状态
    FLocked     : Boolean;         //锁定状态，更新预置皮重
    FPreTruckP  : Boolean;         //预置皮重；

    FYSValid    : string;          //验收结果
    FKZValue    : Double;          //扣杂量
    FSeal       : string;          //批次号
    FMemo       : string;          //备注
    FExtID_1    : string;          //额外编号
    FExtID_2    : string;          //额外编号
    FCardUse    : string;          //卡片类型

    FNCChanged  : Boolean;         //NC可用量变化
    FChangeValue: Double;          //NC 减少
  end;

  TLadingBillItems = array of TLadingBillItem;
  //交货单列表

  TWeiXinAccount = record
    FID       : string;           //微信ID
    FWXID     : string;           //微信开发者ID
    FWXName   : string;           //微信名称

    FWXFact   : string;           //微信帐号所属工厂编码
    FIsValid  : string;          //微信状态
    FComment  : string;           //备注信息

    FAttention: string;           //关注者编号
    FAttenType: string;           //关注者类型
  end;

  TPreTruckPItem = record
    FPreUse    :Boolean;           //使用预置
    FPrePMan   :string;            //预置司磅
    FPrePTime  :TDateTime;         //预置时间

    FPrePValue :Double;            //预置皮重
    FMinPVal   :Double;            //历史最小皮重
    FMaxPVal   :Double;            //历史最大皮重
    FPValue    :Double;            //有效皮重

    FPreTruck  :string;            //车牌号
  end;

procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
//解析由业务对象返回的交货单数据
function CombineBillItmes(const nItems: TLadingBillItems): string;
//合并交货单数据为业务对象能处理的字符串

procedure AnalyseWXAccountItem(const nData: string; var nItem: TWeiXinAccount);
//解析由业务对象返回的微信账户数据
function CombineWXAccountItem(const nItem: TWeiXinAccount): string;
//合并微信账户数据为业务对象能处理的字符串

function CombinePreTruckItem(const nItem: TPreTruckPItem): string;
//合并预置皮重数据为业务对象能处理的字符串
procedure AnalysePreTruckItem(const nData: string; var nItem: TPreTruckPItem);
//解析由业务对象返回的预置皮重数据

resourcestring
  {*PBWDataBase.FParam*}
  sParam_NoHintOnError        = 'NHE';                  //不提示错误

  {*plug module id*}
  sPlug_ModuleBus             = '{DF261765-48DC-411D-B6F2-0B37B14E014E}';
                                                        //业务模块
  sPlug_ModuleHD              = '{B584DCD6-40E5-413C-B9F3-6DD75AEF1C62}';
                                                        //硬件守护

  {*common function*}  
  sSys_BasePacker             = 'Sys_BasePacker';       //基本封包器

  {*business mit function name*}
  sBus_ServiceStatus          = 'Bus_ServiceStatus';    //服务状态
  sBus_GetQueryField          = 'Bus_GetQueryField';    //查询的字段

  sBus_BusinessSaleBill       = 'Bus_BusinessSaleBill'; //交货单相关
  sBus_BusinessProvide        = 'Bus_BusinessProvide';  //采购单相关
  sBus_BusinessCommand        = 'Bus_BusinessCommand';  //业务指令
  sBus_HardwareCommand        = 'Bus_HardwareCommand';  //硬件指令

  {*client function name*}
  sCLI_ServiceStatus          = 'CLI_ServiceStatus';    //服务状态
  sCLI_GetQueryField          = 'CLI_GetQueryField';    //查询的字段

  sCLI_BusinessSaleBill       = 'CLI_BusinessSaleBill'; //交货单业务
  sCLI_BusinessProvide        = 'CLI_BusinessProvide';  //采购单业务
  sCLI_BusinessCommand        = 'CLI_BusinessCommand';  //业务指令
  sCLI_HardwareCommand        = 'CLI_HardwareCommand';  //硬件指令

implementation

//Date: 2014-09-17
//Parm: 交货单数据;解析结果
//Desc: 解析nData为结构化列表数据
procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
var nStr: string;
    nIdx,nInt: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := PackerDecodeStr(nData);
    //bill list
    nInt := 0;
    SetLength(nItems, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      //bill item

      with nListB,nItems[nInt] do
      begin
        FID         := Values['ID'];
        FZhiKa      := Values['ZhiKa'];
        FCusID      := Values['CusID'];
        FCusName    := Values['CusName'];
        FTruck      := Values['Truck'];
        FExtID_1    := Values['ExtID_1'];
        FExtID_2    := Values['ExtID_2'];

        FType       := Values['Type'];
        FStockNo    := Values['StockNo'];
        FStockName  := Values['StockName'];

        FCard       := Values['Card'];
        FIsVIP      := Values['IsVIP'];
        FCardUse    := Values['CType'];
        FStatus     := Values['Status'];
        FNextStatus := Values['NextStatus'];

        FFactory    := Values['Factory'];
        FOrigin     := Values['Origin'];
        FPModel     := Values['PModel'];
        FPType      := Values['PType'];
        FPoundID    := Values['PoundID'];
        FSelected   := Values['Selected'] = sFlag_Yes;

        FLocked     := Values['Locked'] = sFlag_Yes;
        FPreTruckP  := Values['PreTruckP'] = sFlag_Yes;
        FNCChanged  := Values['NCChanged'] = sFlag_Yes;

        with FPData do
        begin
          FStation  := Values['PStation'];
          FDate     := Str2DateTime(Values['PDate']);
          FOperator := Values['PMan'];

          nStr := Trim(Values['PValue']);
          if (nStr <> '') and IsNumber(nStr, True) then
               FPData.FValue := StrToFloat(nStr)
          else FPData.FValue := 0;
        end;

        with FMData do
        begin
          FStation  := Values['MStation'];
          FDate     := Str2DateTime(Values['MDate']);
          FOperator := Values['MMan'];

          nStr := Trim(Values['MValue']);
          if (nStr <> '') and IsNumber(nStr, True) then
               FMData.FValue := StrToFloat(nStr)
          else FMData.FValue := 0;
        end;

        nStr := Trim(Values['Value']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FValue := StrToFloat(nStr)
        else FValue := 0;

        nStr := Trim(Values['Price']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FPrice := StrToFloat(nStr)
        else FPrice := 0;

        nStr := Trim(Values['NCChangeValue']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FChangeValue := StrToFloat(nStr)
        else FChangeValue := 0;

        nStr := Trim(Values['KZValue']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FKZValue := StrToFloat(nStr)
        else FKZValue := 0;

        FYSValid:= Values['YSValid'];
        FMemo   := Values['Memo'];
        FSeal   := Values['Seal'];
      end;

      Inc(nInt);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;
end;

//Date: 2014-09-18
//Parm: 交货单列表
//Desc: 将nItems合并为业务对象能处理的
function CombineBillItmes(const nItems: TLadingBillItems): string;
var nIdx: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    Result := '';
    nListA.Clear;
    nListB.Clear;

    for nIdx:=Low(nItems) to High(nItems) do
    with nItems[nIdx] do
    begin
      if not FSelected then Continue;
      //ignored

      with nListB do
      begin
        Values['ID']         := FID;
        Values['ZhiKa']      := FZhiKa;
        Values['CusID']      := FCusID;
        Values['CusName']    := FCusName;
        Values['Truck']      := FTruck;
        Values['ExtID_1']    := FExtID_1;
        Values['ExtID_2']    := FExtID_2;

        Values['Type']       := FType;
        Values['StockNo']    := FStockNo;
        Values['StockName']  := FStockName;
        Values['Value']      := FloatToStr(FValue);
        Values['Price']      := FloatToStr(FPrice);

        Values['Card']       := FCard;
        Values['CType']      := FCardUse;
        Values['IsVIP']      := FIsVIP;
        Values['Status']     := FStatus;
        Values['NextStatus'] := FNextStatus;

        Values['Factory']    := FFactory;
        Values['Origin']     := FOrigin;
        Values['PModel']     := FPModel;
        Values['PType']      := FPType;
        Values['PoundID']    := FPoundID;

        with FPData do
        begin
          Values['PStation'] := FStation;
          Values['PValue']   := FloatToStr(FPData.FValue);
          Values['PDate']    := DateTime2Str(FDate);
          Values['PMan']     := FOperator;
        end;

        with FMData do
        begin
          Values['MStation'] := FStation;
          Values['MValue']   := FloatToStr(FMData.FValue);
          Values['MDate']    := DateTime2Str(FDate);
          Values['MMan']     := FOperator;
        end;

        if FSelected then
             Values['Selected'] := sFlag_Yes
        else Values['Selected'] := sFlag_No;

        
        if FLocked then
             Values['Locked'] := sFlag_Yes
        else Values['Locked'] := sFlag_No;

        
        if FPreTruckP then
             Values['PreTruckP'] := sFlag_Yes
        else Values['PreTruckP'] := sFlag_No;

        if FNCChanged then
             Values['NCChanged'] := sFlag_Yes
        else Values['NCChanged'] := sFlag_No;

        Values['NCChangeValue']  := FloatToStr(FChangeValue); 
        Values['KZValue']    := FloatToStr(FKZValue);
        Values['YSValid']    := FYSValid;
        Values['Memo']       := FMemo;
        Values['Seal']       := FSeal;
      end;

      nListA.Add(PackerEncodeStr(nListB.Text));
      //add bill
    end;

    Result := PackerEncodeStr(nListA.Text);
    //pack all
  finally
    nListB.Free;
    nListA.Free;
  end;
end;

//Date: 2015-04-17
//Parm: 微信帐号信息;解析结果
//Desc: 解析nData为结构化列表数据
procedure AnalyseWXAccountItem(const nData: string; var nItem: TWeiXinAccount);
var nListA: TStrings;
begin
  nListA := TStringList.Create;
  try
    nListA.Text := PackerDecodeStr(nData);
    with nListA, nItem do
    begin
      FID       := Values['ID'];
      FWXID     := Values['WXID'];
      FWXName   := Values['WXName'];
      FWXFact   := Values['WXFactory'];

      FIsValid  := Values['IsValid'];
      FComment  := Values['Comment'];
      
      FAttention:= Values['AttentionID'];
      FAttenType:= Values['AttentionTP'];
    end;
  finally
    nListA.Free;
  end;
end;

//Date: 2014-09-18
//Parm: 微信信息列表
//Desc: 将nItems合并为业务对象能处理的
function CombineWXAccountItem(const nItem: TWeiXinAccount): string;
var nListA: TStrings;
begin
  nListA := TStringList.Create;
  try
    Result := '';
    nListA.Clear;
    with nListA, nItem do
    begin
      Values['ID']         := FID;
      Values['WXID']       := FWXID;
      Values['WXName']     := FWXName;
      Values['WXFactory']  := FWXFact;

      Values['IsValid']    := FIsValid;
      Values['Comment']    := FComment;

      Values['AttentionID']:= FAttention;
      Values['AttentionTP']:= FAttenType;
    end;

    Result := PackerEncodeStr(nListA.Text);
    //pack all
  finally
    nListA.Free;
  end;
end;

//Date: 2015-04-17
//Parm: 预置皮重信息;解析结果
//Desc: 解析nData为结构化列表数据
procedure AnalysePreTruckItem(const nData: string; var nItem: TPreTruckPItem);
var nListA: TStrings;
begin
  nListA := TStringList.Create;
  try
    nListA.Text := PackerDecodeStr(nData);
    with nListA, nItem do
    begin
      FPreUse    := Values['FPreUse'] = sFlag_Yes;
      FPrePMan   := Values['FPrePMan'];
      FPrePTime  := Str2DateTime(Values['FPrePTime']);

      FPrePValue := StrToFloat(Values['FPrePValue']);
      FMinPVal   := StrToFloat(Values['FMinPVal']);
      FMaxPVal   := StrToFloat(Values['FMaxPVal']);
      FPValue    := StrToFloat(Values['FPValue']);

      FPreTruck     := Values['FPreTruck'];
    end;
  finally
    nListA.Free;
  end;
end;

//Date: 2014-09-18
//Parm: 微信信息列表
//Desc: 将nItems合并为业务对象能处理的
function CombinePreTruckItem(const nItem: TPreTruckPItem): string;
var nListA: TStrings;
    nUse : string;
begin
  nListA := TStringList.Create;
  try
    Result := '';
    nListA.Clear;
    with nListA, nItem do
    begin
      if FPreUse then
           nUse := sFlag_Yes
      else nUse := sFlag_No;

      Values['FPreUse']    := nUse;
      Values['FPrePMan']   := FPrePMan;
      Values['FPrePTime']  := DateTime2Str(FPrePTime);

      Values['FPrePValue'] := FloatToStr(FPrePValue);
      Values['FMinPVal']   := FloatToStr(FMinPVal);
      Values['FMaxPVal']   := FloatToStr(FMaxPVal);
      Values['FPValue']    := FloatToStr(FPValue);

      Values['FPreTruck']     := FPreTruck;
    end;

    Result := PackerEncodeStr(nListA.Text);
    //pack all
  finally
    nListA.Free;
  end;
end;

end.


