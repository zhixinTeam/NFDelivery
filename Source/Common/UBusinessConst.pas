{*******************************************************************************
  ����: dmzn@163.com 2012-02-03
  ����: ҵ��������

  ��ע:
  *.����In/Out����,��ô���TBWDataBase������,��λ�ڵ�һ��Ԫ��.
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
  cBC_GetSerialNO             = $0001;   //��ȡ���б��
  cBC_ServerNow               = $0002;   //��������ǰʱ��
  cBC_IsSystemExpired         = $0003;   //ϵͳ�Ƿ��ѹ���
  cBC_IsTruckValid            = $0004;   //�����Ƿ���Ч
  cBC_UserLogin               = $0005;   //�û���¼
  cBC_UserLogOut              = $0006;   //�û�ע��
  cBC_GetCardUsed             = $0007;   //��ȡ��Ƭ����

  cBC_GetCustomerMoney        = $0010;   //��ȡ�ͻ����ý�
  cBC_GetZhiKaMoney           = $0011;   //��ȡֽ�����ý�

  cBC_SaveTruckInfo           = $0013;   //���泵����Ϣ
  cBC_GetStockBatcode         = $0014;   //��ȡ��������
  cBC_GetTruckPoundData       = $0015;   //��ȡ������������
  cBC_SaveTruckPoundData      = $0016;   //���泵����������
  cBC_SaveStockBatcode        = $0017;   //������������

  cBC_GetOrderFHValue         = $0018;   //��ȡ����������
  cBC_GetOrderGYValue         = $0019;   //��ȡ������Ӧ��
  cBC_SyncME25                = $0100;   //ͬ������������
  cBC_SyncME03                = $0101;   //ͬ����Ӧ������
  cBC_GetSQLQueryOrder        = $0102;   //��ѯ�������
  cBC_GetSQLQueryCustomer     = $0103;   //��ѯ�ͻ����
  cBC_GetSQLQueryDispatch     = $0104;   //��ѯ��������

  cBC_SaveBills               = $0020;   //���潻�����б�
  cBC_DeleteBill              = $0021;   //ɾ��������
  cBC_ModifyBillTruck         = $0022;   //�޸ĳ��ƺ�
  cBC_SaleAdjust              = $0023;   //���۵���
  cBC_SaveBillCard            = $0024;   //�󶨽������ſ�
  cBC_LogoffCard              = $0025;   //ע���ſ�
  cBC_DeleteOrder             = $0026;   //ɾ���볧��ϸ

  cBC_GetPostBills            = $0030;   //��ȡ��λ������
  cBC_SavePostBills           = $0031;   //�����λ������

  cBC_SaveBillNew             = $0032;   //���ɻ���������
  cBC_DeleteBillNew           = $0033;   //ɾ������������
  cBC_SaveBillNewCard         = $0034;   //�󶨻������ſ�
  cBC_LogoffCardNew           = $0035;   //ע���ſ�
  cBC_SaveBillFromNew         = $0036;   //���ݻ����������ɽ�����

  cBC_ChangeDispatchMode      = $0053;   //�л�����ģʽ
  cBC_GetPoundCard            = $0054;   //��ȡ��վ����
  cBC_GetQueueData            = $0055;   //��ȡ��������
  cBC_PrintCode               = $0056;
  cBC_PrintFixCode            = $0057;   //����
  cBC_PrinterEnable           = $0058;   //�������ͣ
  cBC_PrinterChinaEnable      = $0059;   //�������ͣ

  cBC_JSStart                 = $0060;
  cBC_JSStop                  = $0061;
  cBC_JSPause                 = $0062;
  cBC_JSGetStatus             = $0063;
  cBC_SaveCountData           = $0064;   //����������
  cBC_RemoteExecSQL           = $0065;

  cBC_IsTunnelOK              = $0075;
  cBC_TunnelOC                = $0076;

  cBC_GetSQLQueryWeixin       = $0081;   //��ȡ΢����Ϣ��ѯ���
  cBC_SaveWeixinAccount       = $0082;   //����΢���˻�
  cBC_DelWeixinAccount        = $0083;   //ɾ��΢���˻�
  cBC_GetWeiXinReport         = $0084;   //��ȡ΢�ű���
  cBC_GetWeiXinQueue          = $0085;   //��ȡ΢�ű���

  cBC_GetTruckPValue          = $0091;   //��ȡ����Ԥ��Ƥ��
  cBC_SaveTruckPValue         = $0092;   //���泵��Ԥ��Ƥ��
  cBC_GetPoundBaseValue       = $0093;   //��ȡ�ذ���ͷ��������
type
  PWorkerQueryFieldData = ^TWorkerQueryFieldData;
  TWorkerQueryFieldData = record
    FBase     : TBWDataBase;
    FType     : Integer;           //����
    FData     : string;            //����
  end;

  PWorkerBusinessCommand = ^TWorkerBusinessCommand;
  TWorkerBusinessCommand = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //����
    FData     : string;            //����
    FExtParam : string;            //����
  end;

  TPoundStationData = record
    FStation  : string;            //��վ��ʶ
    FValue    : Double;           //Ƥ��
    FDate     : TDateTime;        //��������
    FOperator : string;           //����Ա
  end;

  PLadingBillItem = ^TLadingBillItem;
  TLadingBillItem = record
    FID         : string;          //��������
    FZhiKa      : string;          //ֽ�����
    FCusID      : string;          //�ͻ����
    FCusName    : string;          //�ͻ�����
    FTruck      : string;          //���ƺ���

    FType       : string;          //Ʒ������
    FStockNo    : string;          //Ʒ�ֱ��
    FStockName  : string;          //Ʒ������
    FValue      : Double;          //�����
    FPrice      : Double;          //�������

    FCard       : string;          //�ſ���
    FIsVIP      : string;          //ͨ������
    FStatus     : string;          //��ǰ״̬
    FNextStatus : string;          //��һ״̬

    FPData      : TPoundStationData; //��Ƥ
    FMData      : TPoundStationData; //��ë
    FFactory    : string;          //�������
    FOrigin     : string;          //��Դ,���
    FPModel     : string;          //����ģʽ
    FPType      : string;          //ҵ������
    FPoundID    : string;          //���ؼ�¼

    FSelected   : Boolean;         //ѡ��״̬
    FLocked     : Boolean;         //����״̬������Ԥ��Ƥ��
    FPreTruckP  : Boolean;         //Ԥ��Ƥ�أ�

    FYSValid    : string;          //���ս��
    FKZValue    : Double;          //������
    FSeal       : string;          //���κ�
    FMemo       : string;          //��ע
    FExtID_1    : string;          //������
    FExtID_2    : string;          //������
    FCardUse    : string;          //��Ƭ����

    FNCChanged  : Boolean;         //NC�������仯
    FChangeValue: Double;          //NC ����
  end;

  TLadingBillItems = array of TLadingBillItem;
  //�������б�

  TWeiXinAccount = record
    FID       : string;           //΢��ID
    FWXID     : string;           //΢�ſ�����ID
    FWXName   : string;           //΢������

    FWXFact   : string;           //΢���ʺ�������������
    FIsValid  : string;          //΢��״̬
    FComment  : string;           //��ע��Ϣ

    FAttention: string;           //��ע�߱��
    FAttenType: string;           //��ע������
  end;

  TPreTruckPItem = record
    FPreUse    :Boolean;           //ʹ��Ԥ��
    FPrePMan   :string;            //Ԥ��˾��
    FPrePTime  :TDateTime;         //Ԥ��ʱ��

    FPrePValue :Double;            //Ԥ��Ƥ��
    FMinPVal   :Double;            //��ʷ��СƤ��
    FMaxPVal   :Double;            //��ʷ���Ƥ��
    FPValue    :Double;            //��ЧƤ��

    FPreTruck  :string;            //���ƺ�
  end;

procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
//������ҵ����󷵻صĽ���������
function CombineBillItmes(const nItems: TLadingBillItems): string;
//�ϲ�����������Ϊҵ������ܴ�����ַ���

procedure AnalyseWXAccountItem(const nData: string; var nItem: TWeiXinAccount);
//������ҵ����󷵻ص�΢���˻�����
function CombineWXAccountItem(const nItem: TWeiXinAccount): string;
//�ϲ�΢���˻�����Ϊҵ������ܴ�����ַ���

function CombinePreTruckItem(const nItem: TPreTruckPItem): string;
//�ϲ�Ԥ��Ƥ������Ϊҵ������ܴ�����ַ���
procedure AnalysePreTruckItem(const nData: string; var nItem: TPreTruckPItem);
//������ҵ����󷵻ص�Ԥ��Ƥ������

resourcestring
  {*PBWDataBase.FParam*}
  sParam_NoHintOnError        = 'NHE';                  //����ʾ����

  {*plug module id*}
  sPlug_ModuleBus             = '{DF261765-48DC-411D-B6F2-0B37B14E014E}';
                                                        //ҵ��ģ��
  sPlug_ModuleHD              = '{B584DCD6-40E5-413C-B9F3-6DD75AEF1C62}';
                                                        //Ӳ���ػ�

  {*common function*}  
  sSys_BasePacker             = 'Sys_BasePacker';       //���������

  {*business mit function name*}
  sBus_ServiceStatus          = 'Bus_ServiceStatus';    //����״̬
  sBus_GetQueryField          = 'Bus_GetQueryField';    //��ѯ���ֶ�

  sBus_BusinessSaleBill       = 'Bus_BusinessSaleBill'; //���������
  sBus_BusinessProvide        = 'Bus_BusinessProvide';  //�ɹ������
  sBus_BusinessCommand        = 'Bus_BusinessCommand';  //ҵ��ָ��
  sBus_HardwareCommand        = 'Bus_HardwareCommand';  //Ӳ��ָ��

  {*client function name*}
  sCLI_ServiceStatus          = 'CLI_ServiceStatus';    //����״̬
  sCLI_GetQueryField          = 'CLI_GetQueryField';    //��ѯ���ֶ�

  sCLI_BusinessSaleBill       = 'CLI_BusinessSaleBill'; //������ҵ��
  sCLI_BusinessProvide        = 'CLI_BusinessProvide';  //�ɹ���ҵ��
  sCLI_BusinessCommand        = 'CLI_BusinessCommand';  //ҵ��ָ��
  sCLI_HardwareCommand        = 'CLI_HardwareCommand';  //Ӳ��ָ��

implementation

//Date: 2014-09-17
//Parm: ����������;�������
//Desc: ����nDataΪ�ṹ���б�����
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
//Parm: �������б�
//Desc: ��nItems�ϲ�Ϊҵ������ܴ����
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
//Parm: ΢���ʺ���Ϣ;�������
//Desc: ����nDataΪ�ṹ���б�����
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
//Parm: ΢����Ϣ�б�
//Desc: ��nItems�ϲ�Ϊҵ������ܴ����
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
//Parm: Ԥ��Ƥ����Ϣ;�������
//Desc: ����nDataΪ�ṹ���б�����
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
//Parm: ΢����Ϣ�б�
//Desc: ��nItems�ϲ�Ϊҵ������ܴ����
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


