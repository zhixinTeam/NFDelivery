{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-10-09
  ����: ��Ŀͨ�ó�,�������嵥Ԫ
*******************************************************************************}
unit USysConst;

interface

uses
  SysUtils, Classes, ComCtrls;

const
  cSBar_Date            = 0;                         //�����������
  cSBar_Time            = 1;                         //ʱ���������
  cSBar_User            = 2;                         //�û��������
  cRecMenuMax           = 5;                         //���ʹ�õ����������Ŀ��
  cItemIconIndex        = 11;                        //Ĭ�ϵ�������б�ͼ��
  
const
  {*Frame ID*}
  cFI_FrameSysLog       = $0001;                     //ϵͳ��־
  cFI_FrameViewLog      = $0002;                     //������־
  cFI_FrameAuthorize    = $0003;                     //ϵͳ��Ȩ

  cFI_FrameCustomer     = $0004;                     //�ͻ�����
  cFI_FrameTrucks       = $0010;                     //��������
  cFI_FrameShip         = $0011;                     //��ֻ����
  cFI_FrameWharf        = $0012;                     //��ͷ����
  cFI_FrameInventory    = $0013;                     //����
  cFI_FrameDeduct       = $0017;                     //���۹���
  cFI_FrameBatch        = $0018;                     //���ι���
  cFI_FrameMine         = $0019;                     //��㵵��
  cFI_FrameBatchQuery   = $0016;                     //���ι���

  cFI_FrameReqSale      = $0020;                     //��������
  cFI_FrameReqProvide   = $0021;                     //�ɹ�����
  cFI_FrameReqDispatch  = $0022;                     //������

  cFI_FrameBill         = $0030;                     //�������
  cFI_FrameBillQuery    = $0031;                     //������ѯ
  cFI_FrameMakeCard     = $0032;                     //����ſ�

  cFI_FrameLadingDai    = $0033;                     //��װ���
  cFI_FramePoundQuery   = $0034;                     //������ѯ
  cFI_FrameFangHuiQuery = $0035;                     //�ŻҲ�ѯ
  cFI_FrameZhanTaiQuery = $0036;                     //ջ̨��ѯ
  cFI_FrameZTDispatch   = $0037;                     //ջ̨����
  cFI_FramePoundManual  = $0038;                     //�ֶ�����
  cFI_FramePoundAuto    = $0039;                     //�Զ�����

  cFI_FrameTruckQuery   = $0050;                     //������ѯ
  cFI_FrameCusAccountQuery = $0051;                  //�ͻ��˻�
  cFI_FrameCusInOutMoney   = $0052;                  //�������ϸ
  cFI_FrameSaleTotalQuery  = $0053;                  //�ۼƷ���
  cFI_FrameSaleDetailQuery = $0054;                  //������ϸ
  cFI_FrameZhiKaDetail  = $0055;                     //ֽ����ϸ
  cFI_FrameDispatchQuery = $0056;                    //���Ȳ�ѯ

  cFI_FrameProvideDetailQuery = $0057;                  //��Ӧ��ϸ
  cFI_FrameDiapatchDetailQuery = $0058;                  //������ϸ

  cFI_FrameChineseBase  = $0062;                     //��������
  cFI_FrameChineseDict  = $0063;                     //�����ֵ�
  
  cFI_FrameProvider     = $0102;                     //��Ӧ
  cFI_FrameProvideLog   = $0105;                     //��Ӧ��־
  cFI_FrameMaterails    = $0106;                     //ԭ����

  cFI_FrameWXAccount    = $0110;                     //΢���˻�
  cFI_FrameWXSendLog    = $0111;                     //������־

  cFI_FrameProvBase     = $0120;                     //�ɹ��볧��
  cFI_FrameProvDetail   = $0121;                     //�ɹ�����ϸ
  cFI_FrameProvTruckQuery= $0122;                    //�ɹ�����ϸ

  cFI_FormMemo          = $1000;                     //��ע����
  cFI_FormBackup        = $1001;                     //���ݱ���
  cFI_FormRestore       = $1002;                     //���ݻָ�
  cFI_FormIncInfo       = $1003;                     //��˾��Ϣ
  cFI_FormChangePwd     = $1005;                     //�޸�����

  cFI_FormBaseInfo      = $1006;                     //������Ϣ
  cFI_FormAuthorize     = $1007;                     //��ȫ��֤
  cFI_FormCustomer      = $1008;                     //�ͻ�����

  cFI_FormTrucks        = $1010;                     //��������
  cFI_FormShip          = $1011;                     //��ֻ����
  cFI_FormWharf         = $1012;                     //��ͷ����
  cFI_FormInventory     = $1013;                     //����
  cFI_FormDeduct        = $1017;                     //���۹���
  cFI_FormBatch         = $1018;                     //���ι���
  cFI_FormMine          = $1019;                     //��㵵��
  cFI_FormBatchEdit     = $1016;                     //���ι���

  cFI_FormMakeBill      = $1020;                     //��������
  cFI_FormGetOrder      = $1021;                     //��ȡ����
  cFI_FormGetCustom     = $1022;                     //��ȡ�ͻ�
  cFI_FormGetTruck      = $1023;                     //��ȡ����
  cFI_FormGetNCStock    = $1024;                     //��ȡ����
  cFI_FormMakeCard      = $1025;                     //����ſ�
  cFI_FormMakeRFIDCard  = $1026;                     //������ӱ�ǩ
  cFI_FormMakeProvCard  = $1027;                     //����ſ�

  cFI_FormGetMine       = $1029;                     //��㵵��

  cFI_FormTruckIn       = $1031;                     //��������
  cFI_FormTruckOut      = $1032;                     //��������
  cFI_FormVerifyCard    = $1033;                     //�ſ���֤
  cFI_FormLadDai        = $1034;                     //��װ���
  cFI_FormLadSan        = $1035;                     //ɢװ���
  cFI_FormJiShuQi       = $1036;                     //��������

  cFI_FormZTLine        = $1040;                     //װ����
  cFI_FormDisPound      = $1041;                     //��վ����

  cFI_FormProvider      = $1051;                     //��Ӧ��
  cFI_FormMaterails     = $1052;                     //ԭ����

  cFI_FormChangeTunnel  = $1061;                     //����װ��
  cFI_FormChineseBase   = $1062;                     //��������
  cFI_FormChineseDict   = $1063;                     //�����ֵ�

  cFI_FormWXAccount     = $1091;                     //΢���˻�
  cFI_FormWXSendlog     = $1092;                     //΢����־

  cFI_FormProvBase      = $1120;                     //�ɹ��볧��

  {*Command*}
  cCmd_RefreshData      = $0002;                     //ˢ������
  cCmd_ViewSysLog       = $0003;                     //ϵͳ��־

  cCmd_ModalResult      = $1001;                     //Modal����
  cCmd_FormClose        = $1002;                     //�رմ���
  cCmd_AddData          = $1003;                     //�������
  cCmd_EditData         = $1005;                     //�޸�����
  cCmd_ViewData         = $1006;                     //�鿴����
  cCmd_GetData          = $1007;                     //ѡ������

type
  TSysParam = record
    FProgID     : string;                            //�����ʶ
    FAppTitle   : string;                            //�����������ʾ
    FMainTitle  : string;                            //���������
    FHintText   : string;                            //��ʾ�ı�
    FCopyRight  : string;                            //��������ʾ����

    FUserID     : string;                            //�û���ʶ
    FUserName   : string;                            //��ǰ�û�
    FUserPwd    : string;                            //�û�����
    FGroupID    : string;                            //������
    FIsAdmin    : Boolean;                           //�Ƿ����Ա
    FIsNormal   : Boolean;                           //�ʻ��Ƿ�����

    FRecMenuMax : integer;                           //����������
    FIconFile   : string;                            //ͼ�������ļ�
    FUsesBackDB : Boolean;                           //ʹ�ñ��ݿ�

    FLocalIP    : string;                            //����IP
    FLocalMAC   : string;                            //����MAC
    FLocalName  : string;                            //��������
    FHardMonURL : string;                            //Ӳ���ػ�

    FFactNum    : string;                            //�������
    FSerialID   : string;                            //���Ա��
    FIsManual   : Boolean;                           //�ֶ�����
    FAutoPound  : Boolean;                           //�Զ�����

    FPoundPZ    : Double;
    FPoundPF    : Double;                            //Ƥ�����
    FPoundDaiZ  : Double;
    FPoundDaiZ_1: Double;                            //��װ�����
    FPoundDaiF  : Double;
    FPoundDaiF_1: Double;                            //��װ�����
    FDaiPercent : Boolean;                           //����������ƫ��
    FDaiWCStop  : Boolean;                           //�������װƫ��
    FPoundSanF  : Double;                            //ɢװ�����
    FPoundTruck : Double;                            //��Ƥ���
    FPicBase    : Integer;                           //ͼƬ����
    FPicPath    : string;                            //ͼƬĿ¼
    FVoiceUser  : Integer;                           //��������
    FProberUser : Integer;                           //���������
  end;
  //ϵͳ����

  TModuleItemType = (mtFrame, mtForm);
  //ģ������

  PMenuModuleItem = ^TMenuModuleItem;
  TMenuModuleItem = record
    FMenuID: string;                                 //�˵�����
    FModule: integer;                                //ģ���ʶ
    FItemType: TModuleItemType;                      //ģ������
  end;

//------------------------------------------------------------------------------
var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����
  gStatusBar: TStatusBar;                            //ȫ��ʹ��״̬��
  gMenuModule: TList = nil;                          //�˵�ģ��ӳ���

//------------------------------------------------------------------------------
ResourceString
  sProgID             = 'DMZN';                      //Ĭ�ϱ�ʶ
  sAppTitle           = 'DMZN';                      //�������
  sMainCaption        = 'DMZN';                      //�����ڱ���

  sHint               = '��ʾ';                      //�Ի������
  sWarn               = '����';                      //==
  sAsk                = 'ѯ��';                      //ѯ�ʶԻ���
  sError              = 'δ֪����';                  //����Ի���

  sDate               = '����:��%s��';               //����������
  sTime               = 'ʱ��:��%s��';               //������ʱ��
  sUser               = '�û�:��%s��';               //�������û�

  sLogDir             = 'Logs\';                     //��־Ŀ¼
  sLogExt             = '.log';                      //��־��չ��
  sLogField           = #9;                          //��¼�ָ���

  sImageDir           = 'Images\';                   //ͼƬĿ¼
  sReportDir          = 'Report\';                   //����Ŀ¼
  sBackupDir          = 'Backup\';                   //����Ŀ¼
  sBackupFile         = 'Bacup.idx';                 //��������
  sCameraDir          = 'Camera\';                   //ץ��Ŀ¼

  sConfigFile         = 'Config.Ini';                //�������ļ�
  sConfigSec          = 'Config';                    //������С��
  sVerifyCode         = ';Verify:';                  //У������

  sFormConfig         = 'FormInfo.ini';              //��������
  sSetupSec           = 'Setup';                     //����С��
  sDBConfig           = 'DBConn.ini';                //��������
  sDBConfig_bk        = 'isbk';                      //���ݿ�

  sExportExt          = '.txt';                      //����Ĭ����չ��
  sExportFilter       = '�ı�(*.txt)|*.txt|�����ļ�(*.*)|*.*';
                                                     //������������ 

  sInvalidConfig      = '�����ļ���Ч���Ѿ���';    //�����ļ���Ч
  sCloseQuery         = 'ȷ��Ҫ�˳�������?';         //�������˳�

implementation

//------------------------------------------------------------------------------
//Desc: ��Ӳ˵�ģ��ӳ����
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

//Desc: �˵�ģ��ӳ���
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

//Desc: ����ģ���б�
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


