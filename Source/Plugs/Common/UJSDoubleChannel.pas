unit UJSDoubleChannel;

interface

type
  PDoubleChannel = ^TDoubleChannel;
  TDoubleChannel  = record
    FTunnel     : string;      //װ��ͨ��
    FMutexTunnel: string;      //����ͨ��
    FBill       : string;      //��������
    FTruck      : string;      //���ƺ�
    FStockNo    : string;      //���Ϻ�
    FStockName  : string;      //Ʒ����
    FDaiNum     : Word;        //��װ����
    FHasDone    : Word;        //��װ����
    FIsRun      : Boolean;     //���б��
    FLastTime   : Int64;       //ʱ���
    FBanDaoNum  : Integer;     //�����
  end;

var
  gDoubleChannel: array of TDoubleChannel;
  //˫ͨ������

implementation

end.
