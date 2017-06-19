unit USelfHelpConst;

interface

uses
  SysUtils, UDataModule;

const
  {*Frame ID*}
  cFI_FrameMain       = $0000;                       //����ʾ
  cFI_FrameQueryCard  = $0001;                       //�ſ���ѯ
  cFI_FrameMakeCard   = $0002;                       //�ƿ�
  cFI_FramePrint      = $0003;                       //��ӡ

  cFI_FrameInputCertificate = $0004;                 //����ȡ��ƾ֤
  cFI_FrameReadCardID = $0005;                       //���֤�Ų�ѯ

  {*Form ID*}
  cFI_FormReadCardID  = $0050;                       //��ȡ���֤


  {*CMD ID*}
  cCmd_QueryCard      = $0001;                       //��ѯ��Ƭ
  cCmd_FrameQuit      = $0002;                       //�˳�����
  cCmd_MakeCard       = $0003;                       //�ƿ�
  cCmd_SelectZhiKa    = $0004;                       //ѡ���̳Ƕ���

type
  TSysParam = record
    FLocalIP    : string;                            //����IP
    FLocalMAC   : string;                            //����MAC
    FLocalName  : string;                            //��������
    FMITServURL : string;                            //ҵ�����
  end;
  //ϵͳ����

resourcestring
  sImages     = 'Images\';
  sConfig     = 'Config.Ini';
  sForm       = 'FormInfo.Ini';
  sDB         = 'DBConn.Ini';

  sHint      = '��ʾ';                      //�Ի������
  sWarn      = '����';                      //==
  sAsk       = 'ѯ��';                      //ѯ�ʶԻ���
  sError     = 'δ֪����';                  //����Ի���

var
  gPath: string;                 //ϵͳ·��
  gSysParam:TSysParam;           //���򻷾�����
  gTimeCounter: Int64;           //��ʱ��

function GetIDCardNumCheckCode(nIDCardNum: string): string;
//���֤��У���㷨
implementation

//Date: 2017/6/14
//Parm: ���֤�ŵ�ǰ17λ
//Desc: ��ȡ���֤��У����
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
