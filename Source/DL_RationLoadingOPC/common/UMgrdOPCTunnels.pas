{*******************************************************************************
  ����: juner11212436@163.com 2018-07-04
  ����: OPCͨ��������
*******************************************************************************}
unit UMgrdOPCTunnels;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, CPort, CPortTypes, IdComponent,
  IdTCPConnection, IdTCPClient, IdGlobal, IdSocketHandle, NativeXml, ULibFun,
  UWaitItem, USysLoger;

type

  PPTOPCItem = ^TPTOPCItem;

  TPTOPCItem = record
    FID: string;                     //��ʶ
    FName: string;                   //����
    FEnable: string;                 //�Ƿ�����
    FServer: string;                 //������
    FComputer: string;               //���������ڼ����
    FStartTag: string;               //�������
    FStartOrder: string;             //��������
    FSetValTag: string;              //Ԥ��ֵ���
    FImpDataTag: string;             //ʵʱ���ݱ��
    FStopTag: string;                //ֹͣ���
    FStopOrder: string;              //ֹͣ����
    FUseTimeTag: string;             //װ���ۼ�ʱ����
    FUseTimeOrder: string;           //װ���ۼ�ʱ������
    FTruckTag: string;               //���ƺ�
    FOptions: TStrings;              //���Ӳ���
  end;

  TOPCTunnelManager = class(TObject)
  private
    FTunnels: TList;
    //ͨ���б�
  protected
    procedure ClearList(const nFree: Boolean);
    //������Դ
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��ȡ����
    function GetTunnel(const nID: string): PPTOPCItem;
    //��������
    property Tunnels: TList read FTunnels;
    //�������
  end;

var
  gOPCTunnelManager: TOPCTunnelManager = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TOPCTunnelManager, 'OPCͨ������', nEvent);
end;

constructor TOPCTunnelManager.Create;
begin
  FTunnels := TList.Create;
end;

destructor TOPCTunnelManager.Destroy;
begin
  ClearList(True);
  inherited;
end;

//Date: 2014-06-12
//Parm: �Ƿ��ͷ�
//Desc: �����б���Դ
procedure TOPCTunnelManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
    nTunnel: PPTOPCItem;
begin
  for nIdx:=FTunnels.Count - 1 downto 0 do
  begin
    nTunnel := FTunnels[nIdx];
    FreeAndNil(nTunnel.FOptions);

    Dispose(nTunnel);
    FTunnels.Delete(nIdx);
  end;

  if nFree then
  begin
    FTunnels.Free;
  end;
end;

//Date: 2014-06-12
//Parm: �����ļ�
//Desc: ����nFile����
procedure TOPCTunnelManager.LoadConfig(const nFile: string);
var nStr: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
    nTunnel: PPTOPCItem;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.FindNode('tunnels');
    for nIdx:=0 to nNode.NodeCount - 1 do
    with nNode.Nodes[nIdx] do
    begin
      New(nTunnel);
      FTunnels.Add(nTunnel);
      FillChar(nTunnel^, SizeOf(TPTOPCItem), #0);

      nStr := NodeByName('server').ValueAsString;
      if nStr = '' then
        raise Exception.Create(Format('ͨ��[ %s.server ]��Ч.', [nTunnel.FName]));
      //xxxxxx
      nTunnel.FServer := nStr;

      with nTunnel^ do
      begin
        FID := AttributeByName['id'];
        FName := AttributeByName['name'];
        FEnable := NodeByName('enable').ValueAsString;
        FComputer := NodeByName('computer').ValueAsString;
        FStartTag := NodeByName('starttag').ValueAsString;
        FStartOrder := NodeByName('startorder').ValueAsString;
        FSetValTag := NodeByName('setvaltag').ValueAsString;
        FImpDataTag := NodeByName('impdatatag').ValueAsString;
        FStopTag := NodeByName('stoptag').ValueAsString;
        FStopOrder := NodeByName('stoporder').ValueAsString;
        FUseTimeTag := NodeByName('usetimetag').ValueAsString;
        FUseTimeOrder := NodeByName('usetimeorder').ValueAsString;
        FTruckTag := '';
        nTmp := FindNode('options');
        if Assigned(nTmp) then
        begin
          FOptions := TStringList.Create;
          SplitStr(nTmp.ValueAsString, FOptions, 0, ';');
        end else FOptions := nil;

        if Assigned(FOptions) then
        begin
          FTruckTag := FOptions.Values['trucktag'];
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//Desc: ������ʶΪnID��ͨ��
function TOPCTunnelManager.GetTunnel(const nID: string): PPTOPCItem;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=FTunnels.Count - 1 downto 0 do
  if CompareText(nID, PPTOPCItem(FTunnels[nIdx]).FID) = 0 then
  begin
    Result := FTunnels[nIdx];
    Exit;
  end;
end;

initialization
  gOPCTunnelManager := nil;
finalization
  FreeAndNil(gOPCTunnelManager);
end.
