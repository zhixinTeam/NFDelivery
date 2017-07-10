{*******************************************************************************
  ����: dmzn@163.com 2008-08-07
  ����: ϵͳ���ݿⳣ������

  ��ע:
  *.�Զ�����SQL���,֧�ֱ���:$Inc,����;$Float,����;$Integer=sFlag_Integer;
    $Decimal=sFlag_Decimal;$Image,��������
*******************************************************************************}
unit USysDB;

{$I Link.inc}
interface

uses
  SysUtils, Classes;

const
  cSysDatabaseName: array[0..4] of String = (
     'Access', 'SQL', 'MySQL', 'Oracle', 'DB2');
  //db names

  cPrecision            = 100;
  {-----------------------------------------------------------------------------
   ����: ���㾫��
   *.����Ϊ�ֵļ�����,С��ֵ�Ƚϻ����������ʱ�������,���Ի��ȷŴ�,ȥ��
     С��λ������������.�Ŵ����ɾ���ֵȷ��.
  -----------------------------------------------------------------------------}

type
  TSysDatabaseType = (dtAccess, dtSQLServer, dtMySQL, dtOracle, dtDB2);
  //db types

  PSysTableItem = ^TSysTableItem;
  TSysTableItem = record
    FTable: string;
    FNewSQL: string;
  end;
  //ϵͳ����

var
  gSysTableList: TList = nil;                        //ϵͳ������
  gSysDBType: TSysDatabaseType = dtSQLServer;        //ϵͳ��������

//------------------------------------------------------------------------------
const
  //�����ֶ�
  sField_Access_AutoInc          = 'Counter';
  sField_SQLServer_AutoInc       = 'Integer IDENTITY (1,1) PRIMARY KEY';

  //С���ֶ�
  sField_Access_Decimal          = 'Float';
  sField_SQLServer_Decimal       = 'Decimal(15, 5)';

  //ͼƬ�ֶ�
  sField_Access_Image            = 'OLEObject';
  sField_SQLServer_Image         = 'Image';

  //�������
  sField_SQLServer_Now           = 'getDate()';

ResourceString     
  {*Ȩ����*}
  sPopedom_Read       = 'A';                         //���
  sPopedom_Add        = 'B';                         //���
  sPopedom_Edit       = 'C';                         //�޸�
  sPopedom_Delete     = 'D';                         //ɾ��
  sPopedom_Preview    = 'E';                         //Ԥ��
  sPopedom_Print      = 'F';                         //��ӡ
  sPopedom_Export     = 'G';                         //����
  sPopedom_ViewPrice  = 'H';                         //�鿴����
  sPopedom_ViewDai    = 'J';                         //�鿴��װ

  {*���ݿ��ʶ*}
  sFlag_DB_K3         = 'King_K3';                   //������ݿ�
  sFlag_DB_NC         = 'YonYou_NC';                 //�������ݿ�
  sFlag_DB_WX         = 'WeiXin_Serv';               //΢�����ݿ�
  
  {*��ر��*}
  sFlag_Yes           = 'Y';                         //��
  sFlag_No            = 'N';                         //��
  sFlag_Unknow        = 'U';                         //δ֪ 
  sFlag_Enabled       = 'Y';                         //����
  sFlag_Disabled      = 'N';                         //����
  sFlag_SHaulback     = 'P';                         //�ؿ�

  sFlag_Integer       = 'I';                         //����
  sFlag_Decimal       = 'D';                         //С��

  sFlag_ManualNo      = '%';                         //�ֶ�ָ��(��ϵͳ�Զ�)
  sFlag_NotMatter     = '@';                         //�޹ر��(�����Ŷ���)
  sFlag_ForceDone     = '#';                         //ǿ�����(δ���ǰ����)
  sFlag_FixedNo       = '$';                         //ָ�����(ʹ����ͬ���)

  sFlag_Provide       = 'P';                         //��Ӧ
  sFlag_Sale          = 'S';                         //����
  sFlag_Returns       = 'R';                         //�˻�
  sFlag_Other         = 'O';                         //����

  sFlag_DuanDao       = 'D';                         //�̵�
  sFlag_SaleNew       = 'N';                         //�̶�������

  sFlag_ShipPro       = 'A';                         //�����ɹ�
  sFlag_ShipTmp       = 'B';                         //������ʱ
  sFlag_Haulback      = 'C';                         //�ؿհ���

  sFlag_TiHuo         = 'T';                         //����
  sFlag_SongH         = 'S';                         //�ͻ�
  sFlag_XieH          = 'X';                         //��ж

  sFlag_Dai           = 'D';                         //��װˮ��
  sFlag_San           = 'S';                         //ɢװˮ��

  sFlag_BillNew       = 'N';                         //�µ�
  sFlag_BillEdit      = 'E';                         //�޸�
  sFlag_BillDel       = 'D';                         //ɾ��
  sFlag_BillLading    = 'L';                         //�����
  sFlag_BillPick      = 'P';                         //����
  sFlag_BillPost      = 'G';                         //����
  sFlag_BillDone      = 'O';                         //���

  sFlag_TypeShip      = 'S';                         //����
  sFlag_TypeZT        = 'Z';                         //ջ̨
  sFlag_TypeVIP       = 'V';                         //VIP
  sFlag_TypeCommon    = 'C';                         //��ͨ
  sFlag_TypeStation   = 'H';                         //��,��������

  sFlag_CardIdle      = 'I';                         //���п�
  sFlag_CardUsed      = 'U';                         //ʹ����
  sFlag_CardLoss      = 'L';                         //��ʧ��
  sFlag_CardInvalid   = 'N';                         //ע����
  sFlag_ProvCardL     = 'L';                         //��ʱ
  sFlag_ProvCardG     = 'G';                         //�̶�

  sFlag_TruckNone     = 'N';                         //��״̬����
  sFlag_TruckIn       = 'I';                         //��������
  sFlag_TruckOut      = 'O';                         //��������
  sFlag_TruckBFP      = 'P';                         //����Ƥ�س���
  sFlag_TruckBFM      = 'M';                         //����ë�س���
  sFlag_TruckSH       = 'S';                         //�ͻ�����
  sFlag_TruckFH       = 'F';                         //�Żҳ���
  sFlag_TruckZT       = 'Z';                         //ջ̨����
  sFlag_TruckXH       = 'X';                         //���ճ���
  sFlag_TruckWT       = 'W';                         //��ˮ����                           

  sFlag_PoundBZ       = 'B';                         //��׼
  sFlag_PoundPZ       = 'Z';                         //Ƥ��
  sFlag_PoundPD       = 'P';                         //���
  sFlag_PoundHK       = 'K';                         //�ؿ�
  sFlag_PoundCC       = 'C';                         //����(����ģʽ)
  sFlag_PoundLS       = 'L';                         //��ʱ

  sFlag_DeductFix     = 'F';                         //�̶�ֵ�ۼ�
  sFlag_DeductPer     = 'P';                         //�ٷֱȿۼ�

  sFlag_AttentionSale = 'S';                         //ҵ��Ա����
  sFlag_AttentionCust = 'C';                         //�ͻ�����
  sFlag_AttentionAdmin= 'G';                         //����Ա����

  sFlag_BatchInUse    = 'Y';                         //���κ���Ч
  sFlag_BatchOutUse   = 'N';                         //���κ��ѷ��
  sFlag_BatchDel      = 'D';                         //���κ���ɾ��

  sFlag_ManualA       = 'A';                         //Ƥ��Ԥ��(�����¼�����)
  sFlag_ManualB       = 'B';                         //Ƥ�س�����Χ
  sFlag_ManualC       = 'C';                         //���س�����Χ

  sFlag_SysParam      = 'SysParam';                  //ϵͳ����
  sFlag_EnableBakdb   = 'Uses_BackDB';               //���ÿ�
  sFlag_ValidDate     = 'SysValidDate';              //��Ч��
  sFlag_PrintBill     = 'PrintStockBill';            //���ӡ����
  sFlag_NFStock       = 'NoFaHuoStock';              //�ֳ����跢��
  sFlag_StockIfYS     = 'StockIfYS';                 //�ֳ��Ƿ�����
  sFlag_ViaBillCard   = 'ViaBillCard';               //ֱ���ƿ�
  sFlag_DispatchPound = 'PoundDispatch';             //��վ����
  sFlag_PSanWuChaStop = 'PoundSanWuChaStop';         //�������ֹͣҵ��
  sFlag_ForceAddWater = 'ForceAddWater';             //ǿ�Ƽ�ˮƷ��
  
  sFlag_PoundIfDai    = 'PoundIFDai';                //��װ�Ƿ����
  sFlag_PoundWuCha    = 'PoundWuCha';                //����������
  sFlag_PoundPWuChaZ  = 'PoundPWuChaZ';              //Ƥ�������
  sFlag_PoundPWuChaF  = 'PoundPWuChaF';              //Ƥ�ظ����
  sFlag_PDaiWuChaZ    = 'PoundDaiWuChaZ';            //��װ�����
  sFlag_PDaiWuChaF    = 'PoundDaiWuChaF';            //��װ�����
  sFlag_PDaiPercent   = 'PoundDaiPercent';           //�������������
  sFlag_PDaiWuChaStop = 'PoundDaiWuChaStop';         //���ʱֹͣҵ��
  sFlag_PSanWuChaF    = 'PoundSanWuChaF';            //ɢװ�����
  sFlag_PTruckPWuCha  = 'PoundTruckPValue';          //�ճ�Ƥ���

  sFlag_CommonItem    = 'CommonItem';                //������Ϣ
  sFlag_CardItem      = 'CardItem';                  //�ſ���Ϣ��
  sFlag_TruckItem     = 'TruckItem';                 //������Ϣ��
  sFlag_StockItem     = 'StockItem';                 //ˮ����Ϣ��
  sFlag_BillItem      = 'BillItem';                  //�ᵥ��Ϣ��
  sFlag_TruckQueue    = 'TruckQueue';                //��������
  sFlag_LadingItem    = 'LadingItem';                //�����ʽ��Ϣ��
  sFlag_OrderInFact   = 'OrderInFact';               //�����ɷ�������
  sFlag_FactoryItem   = 'FactoryItem';               //������Ϣ��
  sFlag_DuctTimeItem  = 'DuctTimeItem';              //����ʱ�����
  sFlag_TiHuoTypeItem = 'TiHuoTypeItem';             //�������
  sFlag_ZTLineGroup   = 'ZTLineGroup';               //ջ̨����
  sFlag_StockBrandShow= 'StockBrandShow';            //Ԥˢ��Ʒ����ʾ
  sFlag_PoundStation  = 'PoundStation';              //�ذ����ð�վ,����ָ������

  sFlag_InWHouse      = 'Warehouse';                 //���ɷ�(��)������
  sFlag_InWHID        = 'WarehouseID';               //�ֿ�ɷ�(��)������
  sFlag_InFact        = 'Factory';                   //�����ɷ�(��)������
  sFlag_InDepot       = 'Depot';                     //�����

  sFlag_CustomerItem  = 'CustomerItem';              //�ͻ���Ϣ��
  sFlag_ProviderItem  = 'ProviderItem';              //��Ӧ����Ϣ��
  sFlag_MaterailsItem = 'MaterailsItem';             //ԭ������Ϣ��   
  sFlag_BankItem      = 'BankItem';                  //������Ϣ��

  sFlag_HardSrvURL    = 'HardMonURL';
  sFlag_MITSrvURL     = 'MITServiceURL';             //�����ַ
            
  sFlag_AutoIn        = 'Truck_AutoIn';              //�Զ�����
  sFlag_AutoOut       = 'Truck_AutoOut';             //�Զ�����
  sFlag_OtherAutoIn   = 'Truck_OtherAutoIn';         //�Զ�����(������)
  sFlag_OtherAutoOut  = 'Truck_OtherAutoOut';        //�Զ�����(������)
  sFlag_InTimeout     = 'InFactTimeOut';             //������ʱ(����)
  sFlag_InAndBill     = 'InFactAndBill';             //�����������
  sFlag_SanMultiBill  = 'SanMultiBill';              //ɢװԤ���൥
  sFlag_NoDaiQueue    = 'NoDaiQueue';                //��װ���ö���
  sFlag_NoSanQueue    = 'NoSanQueue';                //ɢװ���ö���
  sFlag_DelayQueue    = 'DelayQueue';                //�ӳ��Ŷ�(����)
  sFlag_PoundQueue    = 'PoundQueue';                //�ӳ��Ŷ�(�������ݹ�Ƥʱ��)
  sFlag_BatchAuto     = 'Batch_Auto';                //�Զ��������κ�
  sFlag_BatchBrand    = 'Batch_Brand';               //��������Ʒ��
  sFlag_BatchValid    = 'Batch_Valid';               //�������ι���
  sFlag_PoundBaseValue= 'PoundBaseValue';            //������������
  sFlag_OutOfHaulBack = 'OutOfHaulBack';             //�˻�(�ؿ�)ʱ��
  sFlag_DefaultBrand  = 'DefaultBrand';              //Ĭ��Ʒ��
  sFlag_NetPlayVoice  = 'NetPlayVoice';              //ʹ������������

  sFlag_BusGroup      = 'BusFunction';               //ҵ�������
  sFlag_BillNo        = 'Bus_Bill';                  //��������
  sFlag_PoundID       = 'Bus_Pound';                 //���ؼ�¼
  sFlag_WeiXin        = 'Bus_WeiXin';                //΢��ӳ����
  sFlag_ForceHint     = 'Bus_HintMsg';               //ǿ����ʾ
  sFlag_Customer      = 'Bus_Customer';              //�ͻ����
  sFlag_DuctTime      = 'Bus_DuctTime';              //����ʱ��α��
  sFlag_ProvideBase   = 'Bus_ProvBase';              //�ɹ��볧����
  sFlag_ProvideDtl    = 'Bus_ProvDtl';               //�ɹ��볧��ϸ
  sFlag_Transfer      = 'Bus_Transfer';              //�̵�����
  sFlag_BillNewNO     = 'Bus_BillNew';
  sFlag_PStationNo    = 'Bus_PStation';              //�𳵺���ؼ�¼
  sFlag_BillHaulBack  = 'Bus_BillHaulBack';          //�ؿյ���
  
  {*���ݱ�*}
  sTable_Group        = 'Sys_Group';                 //�û���
  sTable_User         = 'Sys_User';                  //�û���
  sTable_Menu         = 'Sys_Menu';                  //�˵���
  sTable_Popedom      = 'Sys_Popedom';               //Ȩ�ޱ�
  sTable_PopItem      = 'Sys_PopItem';               //Ȩ����
  sTable_Entity       = 'Sys_Entity';                //�ֵ�ʵ��
  sTable_DictItem     = 'Sys_DataDict';              //�ֵ���ϸ

  sTable_SysDict      = 'Sys_Dict';                  //ϵͳ�ֵ�
  sTable_ExtInfo      = 'Sys_ExtInfo';               //������Ϣ
  sTable_SysLog       = 'Sys_EventLog';              //ϵͳ��־
  sTable_BaseInfo     = 'Sys_BaseInfo';              //������Ϣ
  sTable_SerialBase   = 'Sys_SerialBase';            //��������
  sTable_SerialStatus = 'Sys_SerialStatus';          //���״̬
  sTable_WorkePC      = 'Sys_WorkePC';               //��֤��Ȩ
  sTable_ManualEvent  = 'Sys_ManualEvent';           //�˹���Ԥ

  sTable_Order        = 'S_Order';                   //���۶���
  sTable_Card         = 'S_Card';                    //���۴ſ�
  sTable_Bill         = 'S_Bill';                    //�����
  sTable_BillBak      = 'S_BillBak';                 //��ɾ������
  sTable_StockMatch   = 'S_StockMatch';              //Ʒ��ӳ��
  sTable_BillNew      = 'S_BillNew';                 //������������
  sTable_BillNewBak   = 'S_BillNewBak';              //��ɾ����
  sTable_BillHaulBack = 'S_BillHaulBack';            //�ؿ�ҵ���
  sTable_BillHaulBak  = 'S_BillHaulBak';            //�ؿ�ҵ���

  sTable_Mine         = 'S_Mine';                    //����
  sTable_Truck        = 'S_Truck';                   //������
  sTable_Batcode      = 'S_Batcode';                 //���κ�
  sTable_ZTLines      = 'S_ZTLines';                 //װ����
  sTable_ZTTrucks     = 'S_ZTTrucks';                //��������
  sTable_Deduct       = 'S_PoundDeduct';             //��������
  sTable_BatcodeDoc   = 'S_BatcodeDoc';              //���κ�
  sTable_StationTruck = 'S_StationTruck';            //����
  sTable_Customer     = 'S_Customer';                //�ͻ���Ϣ
  
  sTable_PoundLog     = 'Sys_PoundLog';              //��������
  sTable_PoundBak     = 'Sys_PoundBak';              //��������
  sTable_Picture      = 'Sys_Picture';               //���ͼƬ
  sTable_PoundStation = 'Sys_PoundStation';          //�𳵺��������
  sTable_PoundStatBak = 'Sys_PoundStatBak';          //�𳵺���������
  sTable_PoundStatIMP = 'Sys_PoundStatIMP';          //�𳵺��������
  sTable_PoundStatIMPBak = 'Sys_PoundStatIMPBak';    //�𳵺���������

  sTable_Provider     = 'P_Provider';                //�ͻ���
  sTable_Materails    = 'P_Materails';               //���ϱ�
  sTable_ProvBase     = 'P_ProvideBase';             //�ɹ����붩��
  sTable_ProvBaseBak  = 'P_ProvideBaseBak';          //��ɾ���ɹ����붩��
  sTable_ProvDtl      = 'P_ProvideDtl';              //�ɹ�������ϸ
  sTable_ProvDtlBak   = 'P_ProvideDtlBak';           //�ɹ�������ϸ
  sTable_Transfer     = 'P_Transfer';                //�̵���ϸ��
  sTable_TransferBak  = 'P_TransferBak';             //�̵���ϸ��

  sTable_CardProvide  = 'P_CardProvide';             //��Ӧ����¼
  sTable_CardOther    = 'P_CardOther';               //��ʱ����
  sTable_CardProvideBak  = 'P_CardProvideBak';       //��Ӧ����¼
  sTable_CardOtherBak    = 'P_CardOtherBak';         //��ʱ����

  sTable_ChineseBase  = 'Sys_ChineseBase';           //���������
  sTable_ChineseDict  = 'Sys_ChineseDict';           //���ֱ����ֵ�

  sTable_WebOrderInfo = 'S_WebOrderInfo';            //΢�Ŷ�����Ϣ
  sTable_WebSyncStatus= 'S_WebSyncStatus';           //����״̬ͬ��
  sTable_WebSendMsgInfo = 'S_WebSendMsgInfo';        //����ģ����Ϣ

const
  sFlag_Departments   = 'Departments';               //�����б�
  sFlag_DepDaTing     = '����';                      //�������
  sFlag_DepJianZhuang = '��װ';                      //��װ
  sFlag_DepBangFang   = '����';                      //����
  sFlag_Solution_YN   = 'Y=ͨ��;N=��ֹ';
  sFlag_Solution_YNI  = 'Y=ͨ��;N=��ֹ;I=����';

  sFlag_Solution_NP   = 'P=�ؿ�;N=��ֹ';
  sFlag_Solution_YNP  = 'Y=ͨ��;P=�ؿ�;N=��ֹ';

  {*�½���*}
  sSQL_NewSysDict = 'Create Table $Table(D_ID $Inc, D_Name varChar(32),' +
       'D_Desc varChar(64), D_Value varChar(50), D_Memo varChar(128),' +
       'D_ParamA $Float, D_ParamB varChar(50), D_ParamC VarChar(50),' +
       'D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   ϵͳ�ֵ�: SysDict
   *.D_ID: ���
   *.D_Name: ����
   *.D_Desc: ����
   *.D_Value: ȡֵ
   *.D_Memo: �����Ϣ
   *.D_ParamA: �������
   *.D_ParamB: �ַ�����
   *.D_ParamC: �ַ�����
   *.D_Index: ��ʾ����
  -----------------------------------------------------------------------------}
  
  sSQL_NewExtInfo = 'Create Table $Table(I_ID $Inc, I_Group varChar(20),' +
       'I_ItemID varChar(20), I_Item varChar(30), I_Info varChar(500),' +
       'I_ParamA $Float, I_ParamB varChar(50), I_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   ��չ��Ϣ��: ExtInfo
   *.I_ID: ���
   *.I_Group: ��Ϣ����
   *.I_ItemID: ��Ϣ��ʶ
   *.I_Item: ��Ϣ��
   *.I_Info: ��Ϣ����
   *.I_ParamA: �������
   *.I_ParamB: �ַ�����
   *.I_Memo: ��ע��Ϣ
   *.I_Index: ��ʾ����
  -----------------------------------------------------------------------------}

  sSQL_NewSysLog = 'Create Table $Table(L_ID $Inc, L_Date DateTime,' +
       'L_Man varChar(32),L_Group varChar(20), L_ItemID varChar(20),' +
       'L_KeyID varChar(20), L_Event varChar(220))';
  {-----------------------------------------------------------------------------
   ϵͳ��־: SysLog
   *.L_ID: ���
   *.L_Date: ��������
   *.L_Man: ������
   *.L_Group: ��Ϣ����
   *.L_ItemID: ��Ϣ��ʶ
   *.L_KeyID: ������ʶ
   *.L_Event: �¼�
  -----------------------------------------------------------------------------}

  sSQL_NewBaseInfo = 'Create Table $Table(B_ID $Inc, B_Group varChar(15),' +
       'B_Text varChar(100), B_Py varChar(25), B_Memo varChar(50),' +
       'B_PID Integer, B_Index Float)';
  {-----------------------------------------------------------------------------
   ������Ϣ��: BaseInfo
   *.B_ID: ���
   *.B_Group: ����
   *.B_Text: ����
   *.B_Py: ƴ����д
   *.B_Memo: ��ע��Ϣ
   *.B_PID: �ϼ��ڵ�
   *.B_Index: ����˳��
  -----------------------------------------------------------------------------}

  sSQL_NewSerialBase = 'Create Table $Table(R_ID $Inc, B_Group varChar(15),' +
       'B_Object varChar(32), B_Prefix varChar(25), B_IDLen Integer,' +
       'B_Base Integer, B_Date DateTime)';
  {-----------------------------------------------------------------------------
   ���б�Ż�����: SerialBase
   *.R_ID: ���
   *.B_Group: ����
   *.B_Object: ����
   *.B_Prefix: ǰ׺
   *.B_IDLen: ��ų�
   *.B_Base: ����
   *.B_Date: �ο�����
  -----------------------------------------------------------------------------}

  sSQL_NewSerialStatus = 'Create Table $Table(R_ID $Inc, S_Object varChar(32),' +
       'S_SerailID varChar(32), S_PairID varChar(32), S_Status Char(1),' +
       'S_Date DateTime)';
  {-----------------------------------------------------------------------------
   ����״̬��: SerialStatus
   *.R_ID: ���
   *.S_Object: ����
   *.S_SerailID: ���б��
   *.S_PairID: ��Ա��
   *.S_Status: ״̬(Y,N)
   *.S_Date: ����ʱ��
  -----------------------------------------------------------------------------}

  sSQL_NewWorkePC = 'Create Table $Table(R_ID $Inc, W_Name varChar(100),' +
       'W_MAC varChar(32), W_Factory varChar(32), W_Serial varChar(32),' +
       'W_Departmen varChar(32), W_ReqMan varChar(32), W_ReqTime DateTime,' +
       'W_RatifyMan varChar(32), W_RatifyTime DateTime,' +
       'W_PoundID varChar(50), W_MITUrl varChar(128), W_HardUrl varChar(128),' +
       'W_Valid Char(1))';
  {-----------------------------------------------------------------------------
   ������Ȩ: WorkPC
   *.R_ID: ���
   *.W_Name: ��������
   *.W_MAC: MAC��ַ
   *.W_Factory: �������
   *.W_Departmen: ����
   *.W_Serial: ���
   *.W_ReqMan,W_ReqTime: ��������
   *.W_RatifyMan,W_RatifyTime: ��׼
   *.W_PoundID:��վ���
   *.W_MITUrl:ҵ�����
   *.W_HardUrl:Ӳ������
   *.W_Valid: ��Ч(Y/N)
  -----------------------------------------------------------------------------}

  sSQL_NewManualEvent = 'Create Table $Table(R_ID $Inc, E_ID varChar(32),' +
       'E_From varChar(32), E_Key varChar(32), E_Event varChar(200), ' +
       'E_Solution varChar(100), E_Result varChar(12),E_Departmen varChar(32),' +
       'E_Date DateTime, E_ManDeal varChar(32), E_DateDeal DateTime, ' +
       'E_ParamA Integer, E_ParamB varChar(128), E_Memo varChar(512))';
  {-----------------------------------------------------------------------------
   �˹���Ԥ�¼�: ManualEvent
   *.R_ID: ���
   *.E_ID: ��ˮ��
   *.E_From: ��Դ
   *.E_Key: ��¼��ʶ
   *.E_Event: �¼�
   *.E_Solution: ������(��ʽ��: Y=ͨ��;N=��ֹ) 
   *.E_Result: ������(Y/N)
   *.E_Departmen: ������
   *.E_Date: ����ʱ��
   *.E_ManDeal,E_DateDeal: ������
   *.E_ParamA: ���Ӳ���, ����
   *.E_ParamB: ���Ӳ���, �ַ���
   *.E_Memo: ��ע��Ϣ
  -----------------------------------------------------------------------------}

  sSQL_NewCustomer = 'Create Table $Table(R_ID $Inc, C_ID varChar(15), ' +
       'C_Name varChar(80), C_PY varChar(80), C_Addr varChar(100), ' +
       'C_FaRen varChar(50), C_LiXiRen varChar(50), C_WeiXin varChar(15),' +
       'C_Phone varChar(15), C_Fax varChar(15), C_Tax varChar(32),' +
       'C_Bank varChar(35), C_Account varChar(18), C_SaleMan varChar(15),' +
       'C_Param varChar(32), C_Memo varChar(50), C_XuNi Char(1))';
  {-----------------------------------------------------------------------------
   �ͻ���Ϣ��: Customer
   *.R_ID: ��¼��
   *.C_ID: ���
   *.C_Name: ����
   *.C_PY: ƴ����д
   *.C_Addr: ��ַ
   *.C_FaRen: ����
   *.C_LiXiRen: ��ϵ��
   *.C_Phone: �绰
   *.C_WeiXin: ΢��
   *.C_Fax: ����
   *.C_Tax: ˰��
   *.C_Bank: ������
   *.C_Account: �ʺ�
   *.C_SaleMan: ҵ��Ա
   *.C_Param: ���ò���
   *.C_Memo: ��ע��Ϣ
   *.C_XuNi: ����(��ʱ)�ͻ�
  -----------------------------------------------------------------------------}

  sSQL_NewStockMatch = 'Create Table $Table(R_ID $Inc, M_Group varChar(8),' +
       'M_ID varChar(20), M_Name varChar(80), M_Status Char(1), M_LineNo varChar(20))';
  {-----------------------------------------------------------------------------
   ����Ʒ��ӳ��: StockMatch
   *.R_ID: ��¼���
   *.M_Group: ����
   *.M_ID: ���Ϻ�
   *.M_Name: ��������
   *.M_Status: ״̬
  -----------------------------------------------------------------------------}

  sSQL_NewOrder = 'Create Table $Table(R_ID $Inc, B_ID varChar(20),' +
       'B_Freeze $Float, B_HasDone $Float)';
  {-----------------------------------------------------------------------------
   ������: Order
   *.R_ID: ��¼���
   *.B_ID: ������
   *.B_Freeze: ������
   *.B_HasDone: �����
  -----------------------------------------------------------------------------}

  sSQB_NewBillNew = 'Create Table $Table(R_ID $Inc, B_ID varChar(20),' +
       'B_Card varChar(32), B_CType Char(1), B_CardSerial varChar(16),' +
       'B_CusID varChar(20), B_CusName varChar(80),' +
       'B_CusPY varChar(80), B_CusCode varChar(15),' +
       'B_SaleID varChar(20), B_SaleMan varChar(32),B_SalePY varChar(32),' +
       'B_Type Char(1), B_StockNo varChar(20), B_StockName varChar(80),' +
       'B_Value $Float, B_Price $Float,' +
       'B_Truck varChar(15), B_IsUsed Char(1), B_LID varChar(20),' +
       'B_Man varChar(32), B_Date DateTime,' +
       'B_Lading Char(1), B_PackStyle Char(1), B_IsVIP Char(1),' +
       'B_DelMan varChar(32), B_DelDate DateTime, B_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   ������������: BillNew
   *.R_ID: ���
   *.B_ID: �������
   *.B_Card, B_CardSerial: �ſ��ţ������к�
   *.B_CusID,B_CusName,B_CusPY:�ͻ�
   *.B_CusCode:�ͻ�����
   *.B_SaleID,B_SaleMan:ҵ��Ա
   *.B_Type: ����(��,ɢ)
   *.B_StockNo: ���ϱ��
   *.B_StockName: �������� 
   *.B_Value: �����
   *.B_Truck: ������
   *.B_Lading: �����ʽ(����,�ͻ�)
   *.B_IsUsed,B_LID: ��ռ��(Y,��;N,��),��ǰ��ϸ
   *.B_Man:������
   *.B_Date:����ʱ��
   *.B_DelMan: ������ɾ����Ա
   *.B_DelDate: ������ɾ��ʱ��
   *.B_Memo: ������ע
  -----------------------------------------------------------------------------}

  sSQL_NewBill = 'Create Table $Table(R_ID $Inc, L_ID varChar(20),' +
       'L_Card varChar(16), L_ZhiKa varChar(20), L_Project varChar(100),' +
       'L_Area varChar(50), L_CusID varChar(20), L_CusName varChar(80),' +
       'L_CusPY varChar(80), L_CusCode varChar(15),' +
       'L_SaleID varChar(20), L_SaleMan varChar(32),' +
       'L_Type Char(1), L_StockNo varChar(20), L_StockName varChar(80),' +
       'L_StockArea varChar(120), L_StockBrand varChar(120),' +
       'L_Value $Float, L_Price $Float, L_PackStyle Char(1),' +
       'L_Truck varChar(15), L_Status Char(1), L_NextStatus Char(1),' +
       'L_InTime DateTime, L_InMan varChar(32),' +
       'L_PValue $Float, L_PDate DateTime, L_PMan varChar(32),' +
       'L_MValue $Float, L_MDate DateTime, L_MMan varChar(32),' +
       'L_LadeTime DateTime, L_LadeMan varChar(32), ' +
       'L_LadeLine varChar(15), L_LineName varChar(32), L_LineGroup varChar(15),' +
       'L_WTMan varChar(32), L_WTTime DateTime, L_WTLine varChar(50),' +
       'L_DaiTotal Integer , L_DaiNormal Integer, L_DaiBuCha Integer,' +
       'L_OutFact DateTime, L_OutMan varChar(32), ' +
       'L_PoundStation varChar(32), L_PoundName varChar(32), ' +
       'L_Lading Char(1), L_IsVIP varChar(1), L_Seal varChar(100),' +
       'L_HYDan varChar(15), L_Man varChar(32), L_Date DateTime,' +
       'L_DelMan varChar(32), L_DelDate DateTime, L_Memo VarChar(500))';
  {-----------------------------------------------------------------------------
   ��������: Bill
   *.R_ID: ���
   *.L_ID: �ᵥ��
   *.L_Card: �ſ���
   *.L_ZhiKa: ֽ����
   *.L_Area: ����
   *.L_CusID,L_CusName,L_CusPY:�ͻ�
   *.L_CusCode:�ͻ�����
   *.L_SaleID,L_SaleMan:ҵ��Ա
   *.L_Type: ����(��,ɢ)
   *.L_StockNo: ���ϱ��
   *.L_StockName: �������� 
   *.L_Value: �����
   *.L_Price: �������
   *.L_PackStyle: ��װ����(ֽ����)
   *.L_Truck: ������
   *.L_Status,L_NextStatus:״̬����
   *.L_InTime,L_InMan: ��������
   *.L_PValue,L_PDate,L_PMan: ��Ƥ��
   *.L_MValue,L_MDate,L_MMan: ��ë��
   *.L_LadeTime,L_LadeMan: ����ʱ��,������
   *.L_LadeLine,L_LineName, L_LineGroup: ����ͨ��
   *.L_DaiTotal,L_DaiNormal,L_DaiBuCha:��װ,����,����
   *.L_WTMan:��ˮ��
   *.L_WTTime:��ˮʱ��
   *.L_WTLine:��ˮ��
   *.L_OutFact,L_OutMan: ��������
   *.L_PoundStation, L_PoundName��ָ����վ�͵ذ���
   *.L_Lading: �����ʽ(����,�ͻ�)
   *.L_IsVIP:VIP��
   *.L_Seal: ��ǩ��
   *.L_HYDan: ���鵥
   *.L_Man:������
   *.L_Date:����ʱ��
   *.L_DelMan: ������ɾ����Ա
   *.L_DelDate: ������ɾ��ʱ��
   *.L_Memo: ������ע
  -----------------------------------------------------------------------------}

  sSQL_NewBillHaulback = 'Create Table $Table(R_ID $Inc, H_ID varChar(20),' +
       'H_Card varChar(20),H_LID varChar(20),H_LPID varChar(20),H_LOutFact DateTime,' +
       'H_CusID varChar(15),H_CusName varChar(80),H_CusPY varChar(80),' +
       'H_SaleID varChar(15),H_SaleMan varChar(32),' +
       'H_ZKType Char(1),H_ZhiKa varChar(20),H_CusType Char(1),' +
       'H_Type Char(1),H_StockNo varChar(20),H_StockName varChar(80),' +
       'H_LimValue $Float,H_Value $Float,H_Price $Float,' +
       'H_Truck varChar(15),H_Status Char(1),H_NextStatus Char(1),' +
       'H_InTime DateTime,H_InMan varChar(32),' +
       'H_PValue $Float,H_PDate DateTime,H_PMan varChar(32),' +
       'H_MValue $Float,H_MDate DateTime,H_MMan varChar(32),' +
       'H_LadeTime DateTime,H_LadeMan varChar(32), ' +
       'H_LadeLine varChar(15),H_LineName varChar(32),' +
       'H_OutFact DateTime,H_OutMan varChar(32),' +
       'H_PoundStation varChar(32), H_PoundName varChar(32), ' +
       'H_Man varChar(32),H_Date DateTime,' +
       'H_DelMan varChar(32),H_DelDate DateTime)';
  {-----------------------------------------------------------------------------
   �˻���(�ؿ�)��: NewBillHaulback
   *.R_ID: ���
   *.H_ID: �˻�����
   *.H_Card: �ſ���
   *.H_LID: �˻�����Ӧ�������
   *.H_LPID: �˻�����Ӧ��ԭʼ����
   *.H_LOutFact: �������ʱ��
   *.H_CusID,H_CusName,H_CusPY,H_CusType:�ͻ�
   *.H_SaleID,H_SaleMan:ҵ��Ա
   *.H_ZhiKa: �������
   *.H_ZKType: ��������
   *.H_Type: ����(��,ɢ)
   *.H_StockNo: ���ϱ��
   *.H_StockName: ��������
   *.H_LimValue: �����ԭʼ�����
   *.H_Value: �˻���
   *.H_Price: �˻�����
   *.H_Truck: ������
   *.H_Status,H_NextStatus:״̬����
   *.H_InTime,H_InMan: ��������
   *.H_PValue,H_PDate,H_PMan: ��Ƥ��
   *.H_MValue,H_MDate,H_MMan: ��ë��
   *.H_LadeTime,H_LadeMan: ж��ʱ��,ж����
   *.H_LadeLine,H_LineName: ж��ͨ��
   *.H_OutFact,H_OutMan: ��������
   *.H_Man:������
   *.H_Date:����ʱ��
   *.H_DelMan: �˻���ɾ����Ա
   *.H_DelDate: �˻���ɾ��ʱ��
  -----------------------------------------------------------------------------}

  sSQL_NewCard = 'Create Table $Table(R_ID $Inc, C_Card varChar(16),' +
       'C_Card2 varChar(32), C_Card3 varChar(32), C_Group varChar(32), ' +
       'C_Owner varChar(15), C_TruckNo varChar(15), C_Status Char(1),' +
       'C_Freeze Char(1), C_Used Char(1), C_UseTime Integer Default 0,' +
       'C_Man varChar(32), C_Date DateTime, C_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   �ſ���:Card
   *.R_ID:��¼���
   *.C_Card:������
   *.C_Card2,C_Card3:������
   *.C_Owner:�����˱�ʶ
   *.C_TruckNo:�������
   *.C_Group:��Ƭ����
   *.C_Used:��;(��Ӧ,����)
   *.C_UseTime:ʹ�ô���
   *.C_Status:״̬(����,ʹ��,ע��,��ʧ)
   *.C_Freeze:�Ƿ񶳽�
   *.C_Man:������
   *.C_Date:����ʱ��
   *.C_Memo:��ע��Ϣ
  -----------------------------------------------------------------------------}

  sSQL_NewTruck = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15), ' +
       'T_PY varChar(15), T_Owner varChar(32), T_Phone varChar(15), ' +
       'T_PrePValue $Float, T_PrePMan varChar(32), T_PrePTime DateTime, ' +
       'T_PrePUse Char(1), T_MinPVal $Float, T_MaxPVal $Float, ' +
       'T_PValue $Float Default 0, T_PTime Integer Default 0,' +
       'T_PlateColor varChar(12),T_Type varChar(12), T_LastTime DateTime, ' +
       'T_PoundLastTime DateTime, T_PoundValue $Float Default 0,' +
       'T_Card varChar(32), T_CardUse Char(1), T_NoVerify Char(1),' +
       'T_MatePID varChar(32), T_MateID varChar(32), T_MateName varChar(80),' +
       'T_SrcAddr varChar(150), T_DestAddr varChar(150),' +
       'T_Valid Char(1), T_VIPTruck Char(1), T_HasGPS Char(1))';
  {-----------------------------------------------------------------------------
   ������Ϣ:Truck
   *.R_ID: ��¼��
   *.T_Truck: ���ƺ�
   *.T_PY: ����ƴ��
   *.T_Owner: ����
   *.T_Phone: ��ϵ��ʽ
   *.T_PrePValue: Ԥ��Ƥ��
   *.T_PrePMan: Ԥ��˾��
   *.T_PrePTime: Ԥ��ʱ��
   *.T_PrePUse: ʹ��Ԥ��
   *.T_MinPVal: ��ʷ��СƤ��
   *.T_MaxPVal: ��ʷ���Ƥ��
   *.T_PValue: ��ЧƤ��
   *.T_PTime: ��Ƥ����
   *.T_PlateColor: ������ɫ
   *.T_Type: ����
   *.T_LastTime: �ϴλ
   *.T_Card: ���ӱ�ǩ
   *.T_CardUse: ʹ�õ���ǩ(Y/N)
   *.T_NoVerify: ��У��ʱ��
   *.T_Valid: �Ƿ���Ч
   *.T_VIPTruck:�Ƿ�VIP
   *.T_HasGPS:��װGPS(Y/N)

   //---------------------------�̵�ҵ��������Ϣ--------------------------------
   *.T_MatePID:�ϸ����ϱ��
   *.T_MateID:���ϱ��
   *.T_MateName: ��������
   *.T_SrcAddr:������ַ
   *.T_DestAddr:�����ַ
   ---------------------------------------------------------------------------//

   ��Чƽ��Ƥ���㷨:
   T_PValue = (T_PValue * T_PTime + ��Ƥ��) / (T_PTime + 1) 
  -----------------------------------------------------------------------------}

  sSQL_NewStationTruck = 'Create Table $Table(R_ID $Inc, S_Stock varChar(32),' +
       'S_StockName varChar(80), S_CusID varChar(32), S_CusName varChar(80),' +
       'S_Value $Float, S_TruckPreFix varChar(20), S_Valid Char(1))';
  {-----------------------------------------------------------------------------
   ���ᵵ����: StationTruck
   *.R_ID: ���
   *.S_Stock: ���Ϻ�
   *.S_StockName: ������
   *.S_CusID: �ͻ���
   *.S_CusName: �ͻ���
   *.S_Value: ȡֵ
   *.S_TruckPreFix: ����ǰ׺
   *.S_Valid: �Ƿ���Ч(Y/N)
  -----------------------------------------------------------------------------}

  sSQL_NewPoundLog = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Type varChar(1), P_Order varChar(20), P_Card varChar(16),' +
       'P_Bill varChar(20), P_Truck varChar(15), P_CusID varChar(32),' +
       'P_CusName varChar(80), P_MID varChar(32),P_MName varChar(80),' +
       'P_MType varChar(10), P_LimValue $Float, P_KZValue $Float Default 0,' +
       'P_PValue $Float, P_PDate DateTime, P_PMan varChar(32), ' +
       'P_MValue $Float, P_MDate DateTime, P_MMan varChar(32), ' +
       'P_PValue2 $Float, P_PDate2 DateTime, P_PMan2 varChar(32), ' +
       'P_MValue2 $Float, P_MDate2 DateTime, P_MMan2 varChar(32), ' +
       'P_FactID varChar(32), P_Origin varChar(80),' +
       'P_PStation varChar(10), P_MStation varChar(10),' +
       'P_PStation2 varChar(10), P_MStation2 varChar(10),' +
       'P_YMan varChar(32), P_YTime DateTime, ' +
       'P_YSResult Char(1), P_YLineName varChar(50), P_KZComment varChar(128),' +
       'P_WTMan varChar(32), P_WTTime DateTime, P_WTLine varChar(50),' +
       'P_Direction varChar(10), P_PModel varChar(10), P_Status Char(1),' +
       'P_Valid Char(1), P_PrintNum Integer Default 1, P_Memo varChar(128),' +
       'P_DelMan varChar(32), P_DelDate DateTime)';
  {-----------------------------------------------------------------------------
   ������¼: PoundLog
   *.P_ID: ���
   *.P_Type: ����(����,��Ӧ,��ʱ)
   *.P_Order: ������,�𳵺����ʱ����ֿ���
   *.P_Bill: ������,�𳵺����ʱ�������κ�
   *.P_Truck: ����
   *.P_CusID: �ͻ���
   *.P_CusName: ������
   *.P_MID: ���Ϻ�
   *.P_MName: ������
   *.P_MType: ��,ɢ��
   *.P_LimValue: Ʊ��
   *.P_PValue,P_PDate,P_PMan: Ƥ��
   *.P_MValue,P_MDate,P_MMan: ë��
   *.P_FactID: �������
   *.P_Origin: ��Դ,����,�𳵺����ʱ����ֿ�����
   *.P_PStation,P_MStation: ���ذ�վ
   *.P_Direction: ��������(��,��)
   *.P_PModel: ����ģʽ(��׼,��Ե�)
   *.P_YMan:������
   *.P_YTime:����ʱ��
   *.P_YSResult: ���ս��
   *.P_YLineName: ���յ�
   *.P_KZComment: ���ձ�ע
   *.P_WTMan:��ˮ��
   *.P_WTTime:��ˮʱ��
   *.P_WTLine:��ˮ��
   *.P_Status: ��¼״̬
   *.P_Valid: �Ƿ���Ч
   *.P_PrintNum: ��ӡ����
   *.P_DelMan,P_DelDate: ɾ����¼
  -----------------------------------------------------------------------------}

  sSQL_NewPicture = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Name varChar(32), P_Mate varChar(80), P_Date DateTime, P_Picture Image)';
  {-----------------------------------------------------------------------------
   ͼƬ: Picture
   *.P_ID: ���
   *.P_Name: ����
   *.P_Mate: ����
   *.P_Date: ʱ��
   *.P_Picture: ͼƬ
  -----------------------------------------------------------------------------}

  sSQL_NewZTLines = 'Create Table $Table(R_ID $Inc, Z_ID varChar(15),' +
       'Z_Name varChar(32), Z_StockNo varChar(20), Z_Stock varChar(80),' +
       'Z_StockType Char(1), Z_PeerWeight Integer, Z_Group varChar(15),' +
       'Z_QueueMax Integer, Z_VIPLine Char(1), Z_Valid Char(1), Z_Index Integer)';
  {-----------------------------------------------------------------------------
   װ��������: ZTLines
   *.R_ID: ��¼��
   *.Z_ID: ���
   *.Z_Name: ����
   *.Z_StockNo: Ʒ�ֱ��
   *.Z_Stock: Ʒ��
   *.Z_StockType: ����(��,ɢ)
   *.Z_PeerWeight: ����
   *.Z_QueueMax: ���д�С
   *.Z_VIPLine: VIPͨ��
   *.Z_Valid: �Ƿ���Ч
   *.Z_Index: ˳������
  -----------------------------------------------------------------------------}

  sSQL_NewZTTrucks = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15),' +
       'T_StockNo varChar(20), T_Stock varChar(80), T_Type Char(1),' +
       'T_Line varChar(15), T_LineGroup varChar(15), T_Index Integer, ' +
       'T_InTime DateTime, T_InFact DateTime, T_InQueue DateTime,' +
       'T_InLade DateTime, T_VIP Char(1), T_Valid Char(1), T_Bill varChar(15),' +
       'T_Value $Float, T_PeerWeight Integer, T_Total Integer Default 0,' +
       'T_Normal Integer Default 0, T_BuCha Integer Default 0,' +
       'T_PDate DateTime, T_IsPound Char(1),T_HKBills varChar(200))';
  {-----------------------------------------------------------------------------
   ��װ������: ZTTrucks
   *.R_ID: ��¼��
   *.T_Truck: ���ƺ�
   *.T_StockNo: Ʒ�ֱ��
   *.T_Stock: Ʒ������
   *.T_Type: Ʒ������(D,S)
   *.T_Line: ���ڵ�
   *.T_LineGroup: ͨ������
   *.T_Index: ˳������
   *.T_InTime: ���ʱ��
   *.T_InFact: ����ʱ��
   *.T_InQueue: ����ʱ��
   *.T_InLade: ���ʱ��
   *.T_VIP: ��Ȩ
   *.T_Bill: �ᵥ��
   *.T_Valid: �Ƿ���Ч
   *.T_Value: �����
   *.T_PeerWeight: ����
   *.T_Total: ��װ����
   *.T_Normal: ��������
   *.T_BuCha: �������
   *.T_PDate: ����ʱ��
   *.T_IsPound: �����(Y/N)
   *.T_HKBills: �Ͽ��������б�
  -----------------------------------------------------------------------------}

  sSQL_NewProvider = 'Create Table $Table(R_ID $Inc, P_ID varChar(32),' +
       'P_Name varChar(80),P_PY varChar(80), P_Phone varChar(20),' +
       'P_WeiXin varChar(32), P_Saler varChar(32),P_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ��Ӧ��: Provider
   *.P_ID: ���
   *.P_Name: ����
   *.P_PY: ƴ����д
   *.P_Phone: ��ϵ��ʽ
   *.P_Weixin: �̳��˺�
   *.P_Saler: ҵ��Ա
   *.P_Memo: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewMaterails = 'Create Table $Table(R_ID $Inc, M_ID varChar(32),' +
       'M_Name varChar(80),M_PY varChar(80),M_Unit varChar(20),M_Price $Float,' +
       'M_PrePValue Char(1), M_PrePTime Integer, M_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ���ϱ�: Materails
   *.M_ID: ���
   *.M_Name: ����
   *.M_PY: ƴ����д
   *.M_Unit: ��λ
   *.M_PrePValue: Ԥ��Ƥ��
   *.M_PrePTime: Ƥ��ʱ��(��)
   *.M_Memo: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewProvBase = 'Create Table $Table(R_ID $Inc, P_ID varChar(20),' +
       'P_BID varChar(20),P_DID varChar(20),' +
       'P_Card varChar(32), P_CType varChar(1),P_UsePre Char(1),' +
       'P_Value $Float,P_Area varChar(50), P_Project varChar(100),' +
       'P_Factory varChar(100), P_Origin varChar(100),' +
       'P_ProType Char(1), P_ProID varChar(32), ' +
       'P_ProName varChar(80), P_ProPY varChar(80),' +
       'P_SaleID varChar(32), P_SaleMan varChar(80), P_SalePY varChar(80),' +
       'P_Type Char(1), P_StockNo varChar(32), P_StockName varChar(80),' +
       'P_PValue $Float, P_PDate DateTime, P_PMan varChar(32),' +
       'P_MValue $Float, P_MDate DateTime, P_MMan varChar(32),' +
       'P_Status Char(1), P_NextStatus Char(1), P_IsUsed Char(1),' +
       'P_Truck varChar(15), P_Man varChar(32), P_Date DateTime,' +
       'P_DelMan varChar(32), P_DelDate DateTime, P_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   �ɹ�������: NewProvBase
   *.R_ID: ���
   *.P_ID: ��������
   *.P_BID: �ɹ����뵥�ݺ�
   *.P_DID: �볧��ϸ����
   *.P_Card,P_CType: �ſ���,�ſ�����(L����ʱ��;G���̶���)
   *.P_UsePre: ʹ��Ԥ��Ƥ��
   *.P_Value:��������
   *.P_OStatus: ����״̬
   *.P_Area,P_Project: ����,��Ŀ
   *.P_ProType,P_ProID,P_ProName,P_ProPY:��Ӧ��
   *.P_SaleID,P_SaleMan:ҵ��Ա
   *.P_Type: ����(��,ɢ)
   *.P_StockNo: ԭ���ϱ��
   *.P_StockName: ԭ��������
   *.P_PValue,P_PDate,P_PMan: ��Ƥ��
   *.P_MValue,P_MDate,P_MMan: ��ë��
   *.P_Status: ��ǰ����״̬
   *.P_NextStus: ��һ״̬
   *.P_IsUsed: �����Ƿ�ռ��(Y������ʹ��;N��δռ��)
   *.P_Truck: ������
   *.P_Man:������
   *.P_Date:����ʱ��
   *.P_DelMan: �ɹ���ɾ����Ա
   *.P_DelDate: �ɹ���ɾ��ʱ��
   *.P_Memo: ������ע
  -----------------------------------------------------------------------------}

  sSQL_NewProvDtl = 'Create Table $Table(R_ID $Inc, D_ID varChar(20),' +
       'D_OID varChar(20), D_PID varChar(20), D_Card varChar(32), ' +
       'D_Area varChar(50), D_Project varChar(100),D_Truck varChar(15), ' +
       'D_ProType Char(1), D_ProID varChar(32), D_XuNi Char(1),' +
       'D_ProName varChar(80), D_ProPY varChar(80),' +
       'D_SaleID varChar(32), D_SaleMan varChar(80), D_SalePY varChar(80),' +
       'D_Type Char(1), D_StockNo varChar(32), D_StockName varChar(80),' +
       'D_DStatus Char(1), D_Status Char(1), D_NextStatus Char(1),' +
       'D_InTime DateTime, D_InMan varChar(32),' +
       'D_PValue $Float, D_PDate DateTime, D_PMan varChar(32),' +
       'D_MValue $Float, D_MDate DateTime, D_MMan varChar(32),' +
       'D_YTime DateTime, D_YMan varChar(32), ' +
       'D_Value $Float,D_KZValue $Float, D_AKValue $Float,' +
       'D_YLine varChar(15), D_YLineName varChar(32), ' +
       'D_DelMan varChar(32), D_DelDate DateTime, D_YSResult Char(1), ' +
       'D_OutFact DateTime, D_OutMan varChar(32), D_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   �ɹ�������ϸ��: ProvDetail
   *.R_ID: ���
   *.D_ID: �ɹ���ϸ��
   *.D_OID: �ɹ�����
   *.D_PID: ������
   *.D_Card: �ɹ��ſ���
   *.D_DStatus: ����״̬
   *.D_Area,D_Project: ����,��Ŀ
   *.D_ProType,D_ProID,D_ProName,D_ProPY:��Ӧ��
   *.D_XuNi: ������ϸ
   *.D_SaleID,D_SaleMan:ҵ��Ա
   *.D_Type: ����(��,ɢ)
   *.D_StockNo: ԭ���ϱ��
   *.D_StockName: ԭ��������
   *.D_Truck: ������
   *.D_Status,D_NextStatus: ״̬
   *.D_InTime,D_InMan: ��������
   *.D_PValue,D_PDate,D_PMan: ��Ƥ��
   *.D_MValue,D_MDate,D_MMan: ��ë��
   *.D_YTime,D_YMan: �ջ�ʱ��,������,
   *.D_Value,D_KZValue,D_AKValue: �ջ���,���տ۳�(����),����
   *.D_YLine,D_YLineName: �ջ�ͨ��
   *.D_YSResult: ���ս��
   *.D_OutFact,D_OutMan: ��������
  -----------------------------------------------------------------------------}

  sSQL_NewTransfer = 'Create Table $Table(R_ID $Inc, T_ID varChar(20),' +
       'T_Card varChar(16), T_Truck varChar(15), T_PID varChar(15),' +
       'T_SrcAddr varChar(160), T_DestAddr varChar(160),' +
       'T_Type Char(1), T_StockNo varChar(32), T_StockName varChar(160),' +
       'T_PValue $Float, T_PDate DateTime, T_PMan varChar(32),' +
       'T_MValue $Float, T_MDate DateTime, T_MMan varChar(32),' +
       'T_Value $Float, T_Man varChar(32), T_Date DateTime,' +
       'T_DelMan varChar(32), T_DelDate DateTime, T_Memo varChar(500),' +
       'T_SyncNum Integer Default 0, T_SyncDate DateTime, T_SyncMemo varChar(500))';
  {-----------------------------------------------------------------------------
   �볧��: Transfer
   *.R_ID: ���
   *.T_ID: �̵�ҵ���
   *.T_PID: �������
   *.T_Card: �ſ���
   *.T_Truck: ���ƺ�
   *.T_SrcAddr:�����ص�
   *.T_DestAddr:����ص�
   *.T_Type: ����(��,ɢ)
   *.T_StockNo: ���ϱ��
   *.T_StockName: ��������
   *.T_PValue,T_PDate,T_PMan: ��Ƥ��
   *.T_MValue,T_MDate,T_MMan: ��ë��
   *.T_Value: �ջ���
   *.T_Man,T_Date: ������Ϣ
   *.T_DelMan,T_DelDate: ɾ����Ϣ
   *.T_SyncNum, T_SyncDate, T_SyncMemo: ͬ������; ͬ�����ʱ��; ͬ����Ϣ
  -----------------------------------------------------------------------------}

  sSQL_NewCardProvide = 'Create Table $Table(R_ID $Inc, P_Card varChar(16),' +
       'P_Order varChar(20), P_Truck varChar(15),' +
       'P_CusID varChar(32), P_CusPY varChar(120), P_CusName varChar(120), ' +
       'P_Origin varChar(128), P_MID varChar(32), P_MName varChar(80), ' +
       'P_MType varChar(10), P_LimVal $Float, P_Pound varChar(20),' +
       'P_Status Char(1), P_NextStatus Char(1),' +
       'P_InTime DateTime, P_InMan varChar(32),' +
       'P_OutTime DateTime, P_OutMan varChar(32),' +
       'P_BFPTime DateTime, P_BFPMan varChar(32), P_BFPValue $Float Default 0,' +
       'P_BFMTime DateTime, P_BFMMan varChar(32), P_BFMValue $Float Default 0,' +
       'P_BFPTime2 DateTime, P_BFPMan2 varChar(32), P_BFPValue2 $Float Default 0,' +
       'P_BFMTime2 DateTime, P_BFMMan2 varChar(32), P_BFMValue2 $Float Default 0,' +
       'P_KeepCard varChar(1), P_OneDoor Char(1), P_MuiltiPound Char(1), ' +
       'P_PoundStation varChar(32), P_PoundName varChar(32), ' +
       'P_Man varChar(32), P_Date DateTime, P_UsePre Char(1),' +
       'P_DelMan varChar(32), P_DelDate DateTime, P_Memo varChar(128))';
  {-----------------------------------------------------------------------------
   ��Ӧ�ſ�:CardProvide
   *.R_ID:��¼���
   *.P_Card:����
   *.P_Truck: ����
   *.P_Order:�ɹ�����
   *.P_Origin: ���
   *.P_CusID,P_CusName:��Ӧ��
   *.P_MID,P_MName:����
   *.P_MType:��,ɢ��
   *.P_LimVal:Ʊ��
   *.P_Pound: �񵥱��
   *.P_Status,P_NextStatus: �г�״̬
   *.P_InTime,P_InMan:����ʱ��,������
   *.P_OutTime,P_OutMan:����ʱ��,������
   *.P_BFPTime,P_BFPMan,P_BFPValue:Ƥ��ʱ��,������,Ƥ��
   *.P_BFMTime,P_BFMMan,P_BFMValue:ë��ʱ��,������,ë��
   *.P_KeepCard: ˾����(Y/N),����ʱ������
   *.P_OneDoor: �������
   *.P_MuiltiPound: ϵͳ����
   *.P_UsePre: Ԥ��Ƥ��
   *.P_Man,P_Date:�ƿ���
   *.P_DelMan,P_DelDate: ɾ����
  -----------------------------------------------------------------------------}

  sSQL_NewCardOther = 'Create Table $Table(R_ID $Inc, O_Card varChar(16),' +
       'O_Truck varChar(15), O_CusID varChar(32), O_CusName varChar(80),' +
       'O_CusPY varChar(80), O_MID varChar(32), O_MName varChar(80), ' +
       'O_MType varChar(10), O_Origin varChar(80), O_LimVal $Float, ' +
       'O_Status Char(1), O_NextStatus Char(1),O_Pound varChar(20),' +
       'O_InTime DateTime, O_InMan varChar(32),' +
       'O_OutTime DateTime, O_OutMan varChar(32),' +
       'O_BFPTime DateTime, O_BFPMan varChar(32), O_BFPValue $Float Default 0,' +
       'O_BFMTime DateTime, O_BFMMan varChar(32), O_BFMValue $Float Default 0,' +
       'O_BFPTime2 DateTime, O_BFPMan2 varChar(32), O_BFPValue2 $Float Default 0,' +
       'O_BFMTime2 DateTime, O_BFMMan2 varChar(32), O_BFMValue2 $Float Default 0,' +
       'O_KeepCard varChar(1), O_MuiltiPound Char(1), O_Man varChar(32), O_Date DateTime,' +
       'O_UsePValue Char(1) Default ''N'', O_OneDoor Char(1) Default ''N'', ' +
       'O_PoundStation varChar(32), O_PoundName varChar(32), ' +
       'O_UsePre Char(1), ' +
       'O_DelMan varChar(32), O_DelDate DateTime, O_Memo varChar(128))';
  {-----------------------------------------------------------------------------
   ��ʱ�ſ�:CardOther
   *.R_ID:��¼���
   *.O_Card:����
   *.O_Truck: ����
   *.O_CusID,O_CusName:��Ӧ��
   *.O_Orgin: ���
   *.O_MID,O_MName:����
   *.O_MType:��,ɢ��
   *.O_LimVal:Ʊ��
   *.O_Status,O_NextStatus: �г�״̬
   *.O_InTime,O_InMan:����ʱ��,������
   *.O_OutTime,O_OutMan:����ʱ��,������
   *.O_BFPTime,O_BFPMan,T_BFPValue:Ƥ��ʱ��,������,Ƥ��
   *.O_BFMTime,O_BFMMan,T_BFMValue:ë��ʱ��,������,ë��
   *.O_KeepCard: ˾����(Y/N),����ʱ������
   *.O_Man,O_Date:�ƿ���
   *.O_UsePValue: �Կճ�ΪƤ��
   *.O_OneDoor: �������
   *.O_MuiltiPound: ϵͳ����
   *.O_UsePre: Ԥ��Ƥ��
   *.O_DelMan,O_DelDate: ɾ����
  -----------------------------------------------------------------------------}

  sSQL_NewBatcode = 'Create Table $Table(R_ID $Inc, B_Stock varChar(32),' +
       'B_Name varChar(80), B_Prefix varChar(15), B_Base Integer,' +
       'B_Incement Integer, B_Length Integer, B_Type Char(1),' +
       'B_Value $Float, B_Low $Float, B_High $Float, B_Interval Integer,' +
       'B_AutoNew Char(1), B_UseDate Char(1), B_FirstDate DateTime,' +
       'B_LastDate DateTime, B_HasUse $Float Default 0, B_Batcode varChar(32))';
  {-----------------------------------------------------------------------------
   ���α����: Batcode
   *.R_ID: ���
   *.B_Stock: ���Ϻ�
   *.B_Name: ������
   *.B_Prefix: ǰ׺
   *.B_Base: ��ʼ����(����)
   *.B_Incement: �������
   *.B_Length: ��ų���
   *.B_Type: �������(H����;Q������;N����ͨ)
   *.B_Value:�����
   *.B_Low,B_High:������(%)
   *.B_Interval: �������(��)
   *.B_AutoNew: Ԫ������(Y/N)
   *.B_UseDate: ʹ�����ڱ���
   *.B_FirstDate: �״�ʹ��ʱ��
   *.B_LastDate: �ϴλ�������ʱ��
   *.B_HasUse: ��ʹ��
   *.B_Batcode: ��ǰ���κ�
  -----------------------------------------------------------------------------}
  
  sSQL_NewBatcodeDoc = 'Create Table $Table(R_ID $Inc, D_ID varChar(32),' +
       'D_Stock varChar(32),D_Name varChar(80), D_Brand varChar(32), ' +
       'D_Plan $Float, D_Sent $Float Default 0, D_Rund $Float, D_Init $Float, D_Warn $Float, ' +
       'D_Man varChar(32), D_Date DateTime, D_DelMan varChar(32), D_DelDate DateTime, ' +
       'D_UseDate DateTime, D_LastDate DateTime, D_Valid char(1))';
  {-----------------------------------------------------------------------------
   ���α����: Batcode
   *.R_ID: ���
   *.D_ID: ���κ�
   *.D_Stock: ���Ϻ�
   *.D_Name: ������
   *.D_Brand: ˮ��Ʒ��
   *.D_Plan: �ƻ�����
   *.D_Sent: �ѷ���
   *.D_Rund: �˻���
   *.D_Init: ��ʼ��
   *.D_Warn: Ԥ����
   *.D_Man:  ������
   *.D_Date: ����ʱ��
   *.D_DelMan: ɾ����
   *.D_DelDate: ɾ��ʱ��
   *.D_UseDate: ����ʱ��
   *.D_LastDate: ��ֹʱ��
   *.D_Valid: �Ƿ�����(N�����;Y�����ã�D��ɾ��)
  -----------------------------------------------------------------------------}

  sSQL_NewDeduct = 'Create Table $Table(R_ID $Inc, D_Stock varChar(32),' +
       'D_Name varChar(80), D_CusID varChar(32), D_CusName varChar(80),' +
       'D_Value $Float, D_Type Char(1), D_Valid Char(1))';
  {-----------------------------------------------------------------------------
   ���α����: Batcode
   *.R_ID: ���
   *.D_Stock: ���Ϻ�
   *.D_Name: ������
   *.D_CusID: �ͻ���
   *.D_CusName: �ͻ���
   *.D_Value: ȡֵ
   *.D_Type: ����(F,�̶�ֵ;P,�ٷֱ�)
   *.D_Valid: �Ƿ���Ч(Y/N)
  -----------------------------------------------------------------------------}

  sSQL_NewMine = 'Create Table $Table(R_ID $Inc, M_Mine varChar(30), ' +
       'M_PY varChar(15), M_Owner varChar(32), M_Phone varChar(15), ' +
       'M_Stock varChar(32), M_StockName varChar(80), ' +
       'M_CusID varChar(32), M_CusName varChar(80), M_Area varChar(80), ' +
       'M_Valid Char(1))';
  {-----------------------------------------------------------------------------
   �����Ϣ:Mine
   *.R_ID: ��¼��
   *.M_Mine: �������
   *.M_PY: ���ƴ��
   *.M_Owner: �����
   *.M_Phone: ��ϵ��ʽ
   *.M_Stock: ���ϱ��
   *.M_StockName: ��������
   *.M_CusID: �ͻ�ID
   *.M_CusName: �ͻ�����
   *.M_Area: ������
   *.M_Valid: �Ƿ���Ч(Y/N)
  -----------------------------------------------------------------------------}

  sSQL_NewChineseBase = 'Create Table $Table(R_ID $Inc, B_Name varChar(15), ' +
       'B_PY varChar(15), B_Source varChar(50), B_Value varChar(15), ' +
       'B_PrintCode varChar(50), B_Valid Char(1), B_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ����������Ϣ:ChineseBase
   *.R_ID: ��¼��
   *.B_Name: ����
   *.B_PY: ƴ��
   *.B_Source��������Դ
   *.B_Value����������
   *.B_PrintCode������ֵ
   *.B_Valid���Ƿ���Ч(Y/N)
   *.B_Memo����ע
  -----------------------------------------------------------------------------}

  sSQL_NewChineseDict = 'Create Table $Table(R_ID $Inc, D_Name varChar(15), ' +
       'D_PY varChar(15), D_Prefix varChar(32), D_Code varChar(15), ' +
       'D_Value varChar(32), D_Valid Char(1), D_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ���������ֵ���Ϣ:NewChineseDict
   *.R_ID: ��¼��
   *.D_Name: ����
   *.D_PY: ƴ��
   *.D_Prefix������ǰ׺
   *.D_Code��������
   *.D_Value������ֵ
   *.D_Valid���Ƿ���Ч(Y/N)
   *.D_Memo����ע
  -----------------------------------------------------------------------------}

  sSQL_NewWebOrderInfo = 'Create Table $Table(R_ID $Inc, W_WebID varChar(32),' +
       'W_DLID varChar(15), W_Date DateTime, W_Man varChar(80),' +
       'W_Memo varChar(80))';
  {-----------------------------------------------------------------------------
   �̳Ƕ���ӳ���: WebOrderInfo
   *.R_ID: ���
   *.W_WebID: �̳Ƕ���ID
   *.W_DLID: DLϵͳID
   *.W_Date: ����ʱ��
   *.W_Man: ������
   *.W_Memo: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewWebSyncStatus = 'Create Table $Table(R_ID $Inc, ' +
       'S_ID varChar(15), S_Status Integer, S_Value $Float, S_Type Char(1),' +
       'S_Upload Char(1), S_UpCount Integer Default 0, ' +
       'S_Date DateTime, S_Man varChar(80), S_Memo varChar(80))';
  {-----------------------------------------------------------------------------
   �̳Ƕ���״̬ͬ����: WebSyncStatus
   *.R_ID: ���
   *.S_ID: DLϵͳID
   *.S_Status: ����״̬
   *.S_Value: ������
   *.S_Type: ��������
   *.S_Upload: ����ͬ��״̬
   *.S_Date: ����ʱ��
   *.S_Man: ������
   *.S_Memo: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewWebSendMsgInfo = 'Create Table $Table(R_ID $Inc, ' +
       'E_Value $Float, E_DLID varChar(20), E_MsgType Integer, ' +
       'E_Card varChar(32), E_Truck varChar(15), E_StockNO varChar(20),' +
       'E_StockName varChar(128), E_CusID varChar(20), E_CusName varChar(128),'+
       'E_Upload Char(1), E_UpCount Integer Default 0, ' +
       'E_Date DateTime, E_Man varChar(80), E_Memo varChar(80))';
  {-----------------------------------------------------------------------------
   �̳Ƿ���ģ����Ϣ��: WebSendMsgInfo
   *.R_ID: ���
   *.E_ID: DLϵͳID
   *.E_MsgType: ����״̬
   *.E_Value: ������
   *.E_Type: ��������
   *.E_Upload: ����ͬ��״̬
   *.E_UpCount: ͬ������
   *.E_Date: ����ʱ��
   *.E_Man: ������
   *.E_Memo: ��ע
  -----------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// ���ݲ�ѯ
//------------------------------------------------------------------------------
  sQuery_SysDict = 'Select D_ID, D_Value, D_Memo, D_ParamA, ' +
         'D_ParamB From $Table Where D_Name=''$Name'' Order By D_Index ASC';
  {-----------------------------------------------------------------------------
   �������ֵ��ȡ����
   *.$Table:�����ֵ��
   *.$Name:�ֵ�������
  -----------------------------------------------------------------------------}

  sQuery_ExtInfo = 'Select I_ID, I_Item, I_Info From $Table Where ' +
         'I_Group=''$Group'' and I_ItemID=''$ID'' Order By I_Index Desc';
  {-----------------------------------------------------------------------------
   ����չ��Ϣ���ȡ����
   *.$Table:��չ��Ϣ��
   *.$Group:��������
   *.$ID:��Ϣ��ʶ
  -----------------------------------------------------------------------------}

function CardStatusToStr(const nStatus: string): string;
//�ſ�״̬
function TruckStatusToStr(const nStatus: string): string;
//����״̬
function BillTypeToStr(const nType: string): string;
//��������
function PostTypeToStr(const nPost: string): string;
//��λ����
function BusinessToStr(const nBus: string): string;
//ҵ������

implementation

//Desc: ��nStatusתΪ�ɶ�����
function CardStatusToStr(const nStatus: string): string;
begin
  if nStatus = sFlag_CardIdle then Result := '����' else
  if nStatus = sFlag_CardUsed then Result := '����' else
  if nStatus = sFlag_CardLoss then Result := '��ʧ' else
  if nStatus = sFlag_CardInvalid then Result := 'ע��' else Result := 'δ֪';
end;

//Desc: ��nStatusתΪ��ʶ�������
function TruckStatusToStr(const nStatus: string): string;
begin
  if nStatus = sFlag_TruckIn then Result := '����' else
  if nStatus = sFlag_TruckOut then Result := '����' else
  if nStatus = sFlag_TruckBFP then Result := '��Ƥ��' else
  if nStatus = sFlag_TruckBFM then Result := '��ë��' else
  if nStatus = sFlag_TruckSH then Result := '�ͻ���' else
  if nStatus = sFlag_TruckXH then Result := '���մ�' else
  if nStatus = sFlag_TruckFH then Result := '�ŻҴ�' else
  if nStatus = sFlag_TruckWT then Result := '��ˮ' else
  if nStatus = sFlag_TruckZT then Result := 'ջ̨' else Result := 'δ����';
end;

//Desc: ����������תΪ��ʶ������
function BillTypeToStr(const nType: string): string;
begin
  if nType = sFlag_TypeShip then Result := '����' else
  if nType = sFlag_TypeZT   then Result := 'ջ̨' else
  if nType = sFlag_TypeVIP  then Result := 'VIP' else Result := '��ͨ';
end;

//Desc: ����λתΪ��ʶ������
function PostTypeToStr(const nPost: string): string;
begin
  if nPost = sFlag_TruckIn   then Result := '��������' else
  if nPost = sFlag_TruckOut  then Result := '��������' else
  if nPost = sFlag_TruckBFP  then Result := '������Ƥ' else
  if nPost = sFlag_TruckBFM  then Result := '��������' else
  if nPost = sFlag_TruckFH   then Result := 'ɢװ�Ż�' else
  if nPost = sFlag_TruckZT   then Result := '��װջ̨' else Result := '����';
end;

//Desc: ҵ������תΪ��ʶ������
function BusinessToStr(const nBus: string): string;
begin
  if nBus = sFlag_Sale       then Result := '����' else
  if nBus = sFlag_Provide    then Result := '��Ӧ' else
  if nBus = sFlag_DuanDao    then Result := '�ڵ�' else
  if nBus = sFlag_Returns    then Result := '�˻�' else
  if nBus = sFlag_ShipPro    then Result := '��Ӧ' else
  if nBus = sFlag_ShipTmp    then Result := 'ת��' else
  if nBus = sFlag_HaulBack   then Result := '�ؿ�' else
  if nBus = sFlag_Other      then Result := '����';
end;

//------------------------------------------------------------------------------
//Desc: ���ϵͳ����
procedure AddSysTableItem(const nTable,nNewSQL: string);
var nP: PSysTableItem;
begin
  New(nP);
  gSysTableList.Add(nP);

  nP.FTable := nTable;
  nP.FNewSQL := nNewSQL;
end;

//Desc: ϵͳ��
procedure InitSysTableList;
begin
  gSysTableList := TList.Create;

  AddSysTableItem(sTable_SysDict, sSQL_NewSysDict);
  AddSysTableItem(sTable_ExtInfo, sSQL_NewExtInfo);
  AddSysTableItem(sTable_SysLog, sSQL_NewSysLog);

  AddSysTableItem(sTable_BaseInfo, sSQL_NewBaseInfo);
  AddSysTableItem(sTable_SerialBase, sSQL_NewSerialBase);
  AddSysTableItem(sTable_SerialStatus, sSQL_NewSerialStatus);
  AddSysTableItem(sTable_StockMatch, sSQL_NewStockMatch);
  AddSysTableItem(sTable_WorkePC, sSQL_NewWorkePC);
  AddSysTableItem(sTable_ManualEvent, sSQL_NewManualEvent);

  AddSysTableItem(sTable_Order, sSQL_NewOrder);
  AddSysTableItem(sTable_Customer, sSQL_NewCustomer);

  AddSysTableItem(sTable_Card, sSQL_NewCard);
  AddSysTableItem(sTable_Bill, sSQL_NewBill);
  AddSysTableItem(sTable_BillBak, sSQL_NewBill);
  AddSysTableItem(sTable_BillNew, sSQB_NewBillNew);
  AddSysTableItem(sTable_BillNewBak, sSQB_NewBillNew);
  AddSysTableItem(sTable_BillHaulBak, sSQL_NewBillHaulback);
  AddSysTableItem(sTable_BillHaulBack, sSQL_NewBillHaulback);

  AddSysTableItem(sTable_Truck, sSQL_NewTruck);
  AddSysTableItem(sTable_ZTLines, sSQL_NewZTLines);
  AddSysTableItem(sTable_ZTTrucks, sSQL_NewZTTrucks);
  AddSysTableItem(sTable_Batcode, sSQL_NewBatcode);
  AddSysTableItem(sTable_BatcodeDoc, sSQL_NewBatcodeDoc);
  AddSysTableItem(sTable_Deduct, sSQL_NewDeduct);
  AddSysTableItem(sTable_Mine, sSQL_NewMine);
  AddSysTableItem(sTable_StationTruck, sSQL_NewStationTruck);

  AddSysTableItem(sTable_PoundLog, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundBak, sSQL_NewPoundLog);
  AddSysTableItem(sTable_Picture, sSQL_NewPicture);
  AddSysTableItem(sTable_PoundStation, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundStatBak, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundStatIMP, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundStatIMPBak, sSQL_NewPoundLog);

  AddSysTableItem(sTable_Provider, ssql_NewProvider);
  AddSysTableItem(sTable_Materails, sSQL_NewMaterails);
  AddSysTableItem(sTable_ProvBase, sSQL_NewProvBase);
  AddSysTableItem(sTable_ProvBaseBak, sSQL_NewProvBase);
  AddSysTableItem(sTable_ProvDtl, sSQL_NewProvDtl);
  AddSysTableItem(sTable_ProvDtlBak, sSQL_NewProvDtl);
  AddSysTableItem(sTable_Transfer, sSQL_NewTransfer);
  AddSysTableItem(sTable_TransferBak, sSQL_NewTransfer);

  AddSysTableItem(sTable_CardProvideBak, sSQL_NewCardProvide);
  AddSysTableItem(sTable_CardOtherBak, sSQL_NewCardOther);
  AddSysTableItem(sTable_CardProvide, sSQL_NewCardProvide);
  AddSysTableItem(sTable_CardOther, sSQL_NewCardOther);

  AddSysTableItem(sTable_ChineseBase, sSQL_NewChineseBase);
  AddSysTableItem(sTable_ChineseDict, sSQL_NewChineseDict);
  AddSysTableItem(sTable_WebOrderInfo, sSQL_NewWebOrderInfo);
  AddSysTableItem(sTable_WebSyncStatus, sSQL_NewWebSyncStatus);
  AddSysTableItem(sTable_WebSendMsgInfo, sSQL_NewWebSendMsgInfo);
end;

//Desc: ����ϵͳ��
procedure ClearSysTableList;
var nIdx: integer;
begin
  for nIdx:= gSysTableList.Count - 1 downto 0 do
  begin
    Dispose(PSysTableItem(gSysTableList[nIdx]));
    gSysTableList.Delete(nIdx);
  end;

  FreeAndNil(gSysTableList);
end;

initialization
  InitSysTableList;
finalization
  ClearSysTableList;
end.


