{*******************************************************************************
  ����: dmzn@163.com 2017-10-25
  ����: ΢�����ҵ������ݴ���
*******************************************************************************}
unit UWorkerBussinessWebchat;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, DB, ADODB, NativeXml, UBusinessWorker,
  UBusinessPacker, UBusinessConst, UMgrDBConn, UMgrParam, UFormCtrl, USysLoger,
  ZnMD5, ULibFun, USysDB, UMITConst, UMgrChannel, DateUtils,
  {$IFDEF WXChannelPool}Wechat_Intf{$ELSE}wechat_soap{$ENDIF},IdHTTP,Graphics,
  WebService_Intf, uROSOAPMessage;

type
  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //������
    FDBConn: PDBWorker;
    //����ͨ��
    {$IFDEF WXChannelPool}
    FWXChannel: PChannelItem;
    {$ELSE} //΢��ͨ��
    FWXChannel: ReviceWS;
    {$ENDIF}
    FNCChannel: PChannelItem;
    FDataIn,FDataOut: PBWDataBase;
    //��γ���
    FDataOutNeedUnPack: Boolean;
    //��Ҫ���
    FPackOut: Boolean;
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //�������
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //��֤���
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //����ҵ��
  public
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
  end;

  TBusWorkerBusinessWebchatNC = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerWebChatData;
    FOut: TWorkerWebChatData;
    //in out
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function UnPackIn(var nData: string): Boolean;
    procedure BuildDefaultXML;
    procedure SaveAuditTruck(nList: TStrings;nStatus:string);
    function ParseDefault(var nData: string): Boolean;
    function GetTruckByLine(nStockNo:string):string;
    //����ˮ��Ʒ�ֻ�ȡ������ǰװ������
    function GetStockName(nStockNo:string):string;
    //��ȡ��������
    function GetCusName(nCusID:string):string;
    //��ȡ�ͻ�����
    function GetCustomerValidMoney(nCustomer: string): Double;
    //��ȡ�ͻ����ý�
    function GetCustomerValidMoneyFromK3(nCustomer: string): Double;
    //��ȡ�ͻ����ý�(K3)
    function GetInOutValue(nBegin,nEnd,nType: string): string;
    //��ȡ����������ͳ����������
    function SaveDBImage(const nDS: TDataSet; const nFieldName: string;
             const nStream: TMemoryStream): Boolean;
    function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
    //��ȡϵͳ�ֵ���

    function GetCustomerInfo(var nData: string): Boolean;
    //��ȡ�ͻ�ע����Ϣ
    function edit_shopclients(var nData: string): Boolean;
    //���̳ǿͻ�
    function GetOrderList(var nData:string):Boolean;
    //��ȡ�����б�
    function GetOrderInfo(var nData:string):Boolean;
    //��ȡ������Ϣ
    function VerifyPrintCode(var nData: string): Boolean;
    //��֤������Ϣ
    function GetWaitingForloading(var nData:string):Boolean;
    //������װ��ѯ
    function GetPurchaseContractList(var nData:string):Boolean;
    //��ȡ�ɹ���ͬ�б����������µ�
    function Send_Event_Msg(var nData:string):boolean;
    //������Ϣ
    function Edit_Shopgoods(var nData:string):boolean;
    //�����Ʒ
    function complete_shoporders(var nData:string):Boolean;
    //�޸Ķ���״̬
    function Get_Shoporders(var nData:string):boolean;
    //��ȡ������Ϣ
    function get_shoporderByNO(var nData:string):boolean;
    //���ݶ����Ż�ȡ������Ϣ
    function GetCusMoney(var nData: string): Boolean;
    //��ȡ�ͻ��ʽ�
    function GetInOutFactoryTotal(var nData:string):Boolean;
    //����������ѯ���ɹ������������۳�������
    function getDeclareCar(var nData:string):Boolean;
    //���س��������Ϣ
    function UpdateDeclareCar(var nData: string): Boolean;
    //������˽���ϴ����󶨻������ڿ�����
    function DownLoadPic(var nData: string): Boolean;
    //����ͼƬ
    function get_shoporderByTruck(var nData:string):boolean;
    //���ݳ��ƺŻ�ȡ������Ϣ
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation

//Date: 2012-3-13
//Parm: ���������
//Desc: ��ȡ�������ݿ��������Դ
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;
  FWXChannel := nil;
  FNCChannel := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    {$IFDEF WXChannelPool}
    FWXChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(FWXChannel) then
    begin
      nData := '����΢�ŷ���ʧ��(Wechat Web Service No Channel).';
      Exit;
    end;

    with FWXChannel^ do
    begin
      if not Assigned(FChannel) then
        FChannel := CoReviceWSImplService.Create(FMsg, FHttp);
      FHttp.TargetUrl := gSysParam.FSrvRemote;
    end; //config web service channel
    {$ENDIF}

    FNCChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(FNCChannel) then
    begin
      nData := '����NC����ʧ��(NC Service No Channel).';
      Exit;
    end;

    with FNCChannel^ do
    begin
      (FMsg as TROSOAPMessage).SoapMode := sRPCEncoding;
      if not Assigned(FChannel) then
        FChannel := CoWebService.Create(FMsg, FHttp);
      FHttp.TargetUrl := gSysParam.FESBSrv;
    end; //config web service channel

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      if FPackOut then
      begin
        WriteLog('���');
        nData := FPacker.PackOut(FDataOut);
      end;

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
    {$IFDEF WXChannelPool}
    gChannelManager.ReleaseChannel(FWXChannel);
    {$ELSE}
    FWXChannel := nil;
    gChannelManager.ReleaseChannel(FNCChannel);
    {$ENDIF}
  end;
end;

//Date: 2012-3-22
//Parm: �������;���
//Desc: ����ҵ��ִ����Ϻ����β����
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: �������
//Desc: ��֤��������Ƿ���Ч
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: ��¼nEvent��־
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function TBusWorkerBusinessWebchatNC.FunctionName: string;
begin
  Result := sBus_BusinessWebchatNC;
end;

constructor TBusWorkerBusinessWebchatNC.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TBusWorkerBusinessWebchatNC.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TBusWorkerBusinessWebchatNC.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessWebchatNC;
  end;
end;

procedure TBusWorkerBusinessWebchatNC.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TBusWorkerBusinessWebchatNC.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerWebChatData;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessWebchatNC);
    nPacker.InitData(@nIn, True, False);
    //init

    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessWebchatNC);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

function TBusWorkerBusinessWebchatNC.UnPackIn(var nData: string): Boolean;
var nNode, nTmp: TXmlNode;
begin
  Result := False;
  try
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nData);

    //nNode := FPacker.XMLBuilder.Root.FindNode('Head');
    nNode := FPacker.XMLBuilder.Root;
    if not (Assigned(nNode) and Assigned(nNode.FindNode('Command'))) then
    begin
      nData := '��Ч�����ڵ�(Head.Command Null).';
      Exit;
    end;

    if not Assigned(nNode.FindNode('RemoteUL')) then
    begin
      nData := '��Ч�����ڵ�(Head.RemoteUL Null).';
      Exit;
    end;

    nTmp := nNode.FindNode('Command');
    FIn.FCommand := StrToIntDef(nTmp.ValueAsString, 0);

    nTmp := nNode.FindNode('RemoteUL');
    FIn.FRemoteUL:= nTmp.ValueAsString;

    nTmp := nNode.FindNode('Data');
    if Assigned(nTmp) then FIn.FData := nTmp.ValueAsString;

    if FIn.FCommand = cBC_WX_CreatLadingOrder then
    begin
      FListA.Clear;

      nTmp := nNode.FindNode('WebOrderID');
      if Assigned(nTmp) then FListA.Values['WebOrderID'] := nTmp.ValueAsString;

      nTmp := nNode.FindNode('Truck');
      if Assigned(nTmp) then FListA.Values['Truck'] := nTmp.ValueAsString;

      nTmp := nNode.FindNode('Value');
      if Assigned(nTmp) then FListA.Values['Value'] := nTmp.ValueAsString;

      nTmp := nNode.FindNode('Phone');
      if Assigned(nTmp) then FListA.Values['Phone'] := nTmp.ValueAsString;

      nTmp := nNode.FindNode('Unloading');
      if Assigned(nTmp) then FListA.Values['Unloading'] := nTmp.ValueAsString;

      nTmp := nNode.FindNode('IdentityID');
      if Assigned(nTmp) then FListA.Values['IdentityID'] := nTmp.ValueAsString;

    end
    else
    begin
      nTmp := nNode.FindNode('ExtParam');
      if Assigned(nTmp) then FIn.FExtParam := nTmp.ValueAsString;
    end;
  except

  end;
end;

//Date: 2012-3-22
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TBusWorkerBusinessWebchatNC.DoDBWork(var nData: string): Boolean;
begin
  UnPackIn(nData);
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;
  FPackOut := False;

  case FIn.FCommand of
   cBC_WX_VerifPrintCode       : Result := VerifyPrintCode(nData);
   cBC_WX_WaitingForloading    : Result := GetWaitingForloading(nData);
   cBC_WX_BillSurplusTonnage   : Result := True;
   cBC_WX_GetOrderInfo         : Result := GetOrderList(nData);
   cBC_WX_GetOrderList         : Result := GetOrderList(nData);
   cBC_WX_CreatLadingOrder     : Result := True;
   cBC_WX_GetPurchaseContract  : Result := GetPurchaseContractList(nData);
   cBC_WX_getCustomerInfo      :
                                begin
                                  FPackOut := True;
                                  Result := GetCustomerInfo(nData);
                                end;
//   cBC_WX_get_Bindfunc         : Result := BindCustomer(nData);
   cBC_WX_send_event_msg       :
                                begin
                                  FPackOut := True;
                                  Result := Send_Event_Msg(nData);
                                end;
   cBC_WX_edit_shopclients     :
                                begin
                                  FPackOut := True;
                                  Result := Edit_ShopClients(nData);
                                end;
   cBC_WX_edit_shopgoods       : Result := Edit_Shopgoods(nData);
   cBC_WX_get_shoporders       : Result := get_shoporders(nData);
   cBC_WX_complete_shoporders  :
                                begin
                                  FPackOut := True;
                                  Result := complete_shoporders(nData);
                                end;
   cBC_WX_get_shoporderbyNO    :
                                begin
                                  FPackOut := True;
                                  Result := get_shoporderByNO(nData);
                                end;
   cBC_WX_get_shopPurchasebyNO :
                                begin
                                  FPackOut := True;
                                  Result := get_shoporderByNO(nData);
                                end;
   cBC_WX_GetCusMoney          : Result := GetCusMoney(nData);
   cBC_WX_GetInOutFactoryTotal : Result := GetInOutFactoryTotal(nData);
   cBC_WX_GetAuditTruck        :
                                begin
                                  FPackOut := True;
                                  Result := getDeclareCar(nData);
                                end;
   cBC_WX_UpLoadAuditTruck     :
                                begin
                                  FPackOut := True;
                                  Result := UpdateDeclareCar(nData);
                                end;
   cBC_WX_DownLoadPic          :
                                begin
                                  FPackOut := True;
                                  Result := DownLoadPic(nData);
                                end;
   cBC_WX_get_shoporderbyTruck :
                                begin
                                  FPackOut := True;
                                  Result := get_shoporderByTruck(nData);
                                end;
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Code: %d Invalid Command).';
      nData := Format(nData, [FIn.FCommand]);
    end;
  end;
end;

//Date: 2017-10-28
//Desc: ��ʼ��XML����
procedure TBusWorkerBusinessWebchatNC.BuildDefaultXML;
begin
  with FPacker.XMLBuilder do
  begin
    Clear;
    VersionString := '1.0';
    EncodingString := 'utf-8';

    XmlFormat := xfCompact;
    Root.Name := 'DATA';
    //first node
  end;
end;

//Date: 2017-10-26
//Desc: ����Ĭ������
function TBusWorkerBusinessWebchatNC.ParseDefault(var nData: string): Boolean;
var nStr: string;
    nNode: TXmlNode;
begin
  with FPacker.XMLBuilder do
  begin
    Result := False;
    nNode := Root.FindNode('return');

    if not Assigned(nNode) then
    begin
      nData := '��Ч�����ڵ�(WebService-Response.return Is Null).';
      Exit;
    end;

    nStr := nNode.ValueAsString;
    if Pos('�ɹ�', nStr) <= 0 then
    begin
      nData := 'ҵ��ִ��ʧ��,����: %s';
      nData := Format(nData, [nStr]);
      Exit;
    end;

    Result := True;
    //done
  end;
end;

//Date: 2017-10-25
//Desc: ��ȡ������΢���û��б�
function TBusWorkerBusinessWebchatNC.GetCustomerInfo(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nNode,nRoot: TXmlNode;
begin
  nStr := '<?xml version="1.0" encoding="UTF-8"?>' +
          '<DATA><head><Factory>%s</Factory></head></DATA>';
  nStr := Format(nStr, [gSysParam.FFactID]);

  WriteLog('΢���û��б����'+nStr);

  Result := False;
  FWXChannel := GetReviceWS(gSysParam.FSrvRemote);
  nStr := FWXChannel.mainfuncs('getCustomerInfo', nStr);

  WriteLog('΢���û��б����'+nStr);

  with FPacker.XMLBuilder do
  begin
    ReadFromString(nStr);
    if not ParseDefault(nData) then Exit;
    nRoot := Root.FindNode('items');

    if not Assigned(nRoot) then
    begin
      nData := '��Ч�����ڵ�(WebService-Response.items Is Null).';
      Exit;
    end;

    FListA.Clear;
    FListB.Clear;
    for nIdx:=0 to nRoot.NodeCount-1 do
    begin
      nNode := nRoot.Nodes[nIdx];
      if CompareText('item', nNode.Name) <> 0 then Continue;

      with FListB,nNode do
      begin
        Values['Phone']   := NodeByName('Phone').ValueAsString;
        Values['BindID']  := NodeByName('Bindcustomerid').ValueAsString;
        Values['Name']    := NodeByName('Namepinyin').ValueAsString;
      end;

      FListA.Add(PackerEncodeStr(FListB.Text));
      //new item
    end;
  end;

  Result := True;
  FOut.FData := FListA.Text;
  FOut.FBase.FResult := True;
end;

//Date: 2017-10-27
//Desc: ��or����̳��˻�����
function TBusWorkerBusinessWebchatNC.edit_shopclients(var nData: string): Boolean;
var nStr, nMemo,nName,nNum: string;
    nIdx: Integer;
    nNode,nRoot: TXmlNode;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  if FListA.Values['Memo'] = sFlag_Provide then
  begin
    nMemo := '<Customer/>' + '<Provider>%s</Provider>';
    nName := '<providername>%s</providername>';
    nNum  := '<providernumber>%s</providernumber>';
  end
  else
  begin
    nMemo := '<Customer>%s</Customer>';
    nName := '<clientname>%s</clientname>';
    nNum  := '<clientnumber>%s</clientnumber>';
  end;

  if FListA.Values['Action'] = 'add' then //bind
  begin
    nStr := '<?xml version="1.0" encoding="UTF-8" ?>' +
            '<DATA>' +
            '<head>' +
            '<Factory>%s</Factory>' +
            nMemo +
            '<type>add</type>' +
            '</head>' +
            '<Items>' +
            '<Item>' +
            nName +
            '<cash>0</cash>' +
            nNum +
            '</Item>' +
            '</Items>' +
            '<remark />' +
            '</DATA>';
    nStr := Format(nStr, [gSysParam.FFactID, FListA.Values['BindID'],
            FListA.Values['CusName'], FListA.Values['CusID']]);
    //xxxxx
  end else
  begin
    nStr := '<?xml version="1.0" encoding="UTF-8"?>' +
            '<DATA>' +
            '<head>' +
            '<Factory>%s</Factory>' +
            nMemo +
            '<type>del</type>' +
            '</head>' +
            '<Items>' +
            '<Item>' +
            nNum +
            '</Item></Items><remark/></DATA>';
    nStr := Format(nStr, [gSysParam.FFactID,
            FListA.Values['Account'], FListA.Values['CusID']]);
    //xxxxx
  end;
  WriteLog('�̳�'+FListA.Values['Memo']+'�˻��������'+nStr);

  FWXChannel := GetReviceWS(gSysParam.FSrvRemote);
  nStr := FWXChannel.mainfuncs('edit_shopclients', nStr);

  WriteLog('�̳�'+FListA.Values['Memo']+'�˻���������'+nStr);

  with FPacker.XMLBuilder do
  begin
    ReadFromString(nStr);
    if not ParseDefault(nData) then Exit;
  end;

  Result := True;
  FOut.FData := sFlag_Yes;
  FOut.FBase.FResult := True;
end;

//Date: 2017-10-28
//Parm: �ͻ����[FIn.FData]
//Desc: ��ȡ���ö����б�
function TBusWorkerBusinessWebchatNC.GetOrderList(var nData: string): Boolean;
var nStr, nType: string;
    nNode: TXmlNode;
    nValue,nMoney: Double;
begin
  Result := False;
  BuildDefaultXML;
  nMoney := 0 ;
  {$IFDEF UseCustomertMoney}
  nMoney := GetCustomerValidMoney(FIn.FData);
  {$ENDIF}

  {$IFDEF UseERP_K3}
  nMoney := GetCustomerValidMoneyFromK3(FIn.FData);
  {$ENDIF}

  nStr := 'select D_ZID,' +                     //���ۿ�Ƭ���
        '  D_Type,' +                           //����(��,ɢ)
        '  D_StockNo,' +                        //ˮ����
        '  D_StockName,' +                      //ˮ������
        '  D_Price,' +                          //����
        '  D_Value,' +                          //������
        '  Z_Man,' +                            //������
        '  Z_Date,' +                           //��������
        '  Z_Customer,' +                       //�ͻ����
        '  Z_Name,' +                           //�ͻ�����
        '  Z_Lading,' +                         //�����ʽ
        '  Z_CID ' +                            //��ͬ���
        'from %s a join %s b on a.Z_ID = b.D_ZID ' +
        'where Z_Verified=''%s'' and (Z_InValid<>''%s'' or Z_InValid is null) '+
        'and Z_Customer=''%s''';
        //��������� ��Ч
//  nStr := Format(nStr,[sTable_ZhiKa,sTable_ZhiKaDtl,sFlag_Yes,sFlag_Yes,
//                       FIn.FData]);
  WriteLog('��ȡ�����б�sql:'+nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr),FPacker.XMLBuilder do
  begin
    if RecordCount < 1 then
    begin
      nData := '�ͻ�(%s)û�ж���,���Ȱ���.';
      nData := Format(nData, [FIn.FData]);

      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;
      Exit;
    end;

    First;

    nNode := Root.NodeNew('head');
    with nNode do
    begin
      NodeNew('CusId').ValueAsString := FieldByName('Z_Customer').AsString;
      NodeNew('CusName').ValueAsString := GetCusName(FieldByName('Z_Customer').AsString);
      {$IFDEF WxShowCusMoney}
      NodeNew('CusMoney').ValueAsString := FloatToStr(nMoney);
      {$ENDIF}
    end;

    nNode := Root.NodeNew('Items');
    while not Eof do
    begin
      with nNode.NodeNew('Item') do
      begin
        if FieldByName('D_Type').AsString = 'D' then
             nType := '��װ'
        else nType := 'ɢװ';

        NodeNew('SetDate').ValueAsString    := FieldByName('Z_Date').AsString;
        NodeNew('BillNumber').ValueAsString := FieldByName('D_ZID').AsString;
        NodeNew('StockNo').ValueAsString    := FieldByName('D_StockNo').AsString;
        NodeNew('StockName').ValueAsString  := FieldByName('D_StockName').AsString;

        nValue := FieldByName('D_Value').AsFloat;
        {$IFDEF UseCustomertMoney}
        try
          nValue := nMoney / FieldByName('D_Price').AsFloat;
          nValue := Float2PInt(nValue, cPrecision, False) / cPrecision;
        except
          nValue := 0;
        end;
        {$ENDIF}
        {$IFDEF UseERP_K3}
        try
          nValue := nMoney / FieldByName('D_Price').AsFloat;
          nValue := Float2PInt(nValue, cPrecision, False) / cPrecision;
        except
          nValue := 0;
        end;
        {$ENDIF}
        NodeNew('MaxNumber').ValueAsString  := FloatToStr(nValue);
        NodeNew('SaleArea').ValueAsString   := '';
      end;

      Next;
    end;

    nNode := Root.NodeNew('EXMG');
    with nNode do
    begin
      NodeNew('MsgTxt').ValueAsString     := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('��ȡ�����б���:'+nData);
  Result := True;
end;

function TBusWorkerBusinessWebchatNC.GetOrderInfo(var nData: string): Boolean;
begin

end;

//Date: 2017-11-14
//Parm: ��α��[FIn.FData]
//Desc: ��α��У��
function TBusWorkerBusinessWebchatNC.VerifyPrintCode(var nData: string): Boolean;
var
  nStr,nCode,nBill_id: string;
  nDs:TDataSet;
  nSprefix:string;
  nIdx,nIdlen:Integer;
begin
  nSprefix := '';
  nidlen := 0;
  Result := False;
  nCode := FIn.FData;

  BuildDefaultXML;
  if nCode='' then
  begin
    nData := '��α��Ϊ��.';
    with FPacker.XMLBuilder.Root.NodeNew('EXMG') do
    begin
      NodeNew('MsgTxt').ValueAsString     := nData;
      NodeNew('MsgResult').ValueAsString  := sFlag_No;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
    nData := FPacker.XMLBuilder.WriteToString;
    Exit;
  end;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_BillNo]);
  nDs :=  gDBConnManager.WorkerQuery(FDBConn, nStr);

  if nDs.RecordCount>0 then
  begin
    nSprefix := nDs.FieldByName('B_Prefix').AsString;
    nIdlen := nDs.FieldByName('B_IDLen').AsInteger;
    nIdlen := nIdlen-length(nSprefix);
  end;

  //�����������
  nBill_id := nSprefix+Copy(nCode, 1, 6) + //YYMMDD
              Copy(nCode, 12, Length(nCode) - 11); //XXXX
  {$IFDEF CODECOMMON}
  //�����������
  nBill_id := nSprefix+Copy(nCode, 1, 6) + //YYMMDD
              Copy(nCode, 12, Length(nCode) - 11); //XXXX
  {$ENDIF}

  {$IFDEF UseERP_K3}
  nBill_id := nSprefix + Copy(nCode, Length(nCode) - nIdlen + 1, nIdlen);
  {$ENDIF}

  //��ѯ���ݿ�
  nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
      'L_StockName,L_Truck,L_Value,L_Price,L_ZKMoney,L_Status,' +
      'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue,l_project,l_area,'+
      'l_hydan,l_outfact From $Bill b ';
  nStr := nStr + 'Where L_ID=''$CD''';
  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', nBill_id)]);
  WriteLog('��α���ѯSQL:'+nStr);

  nDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
  if nDs.RecordCount<1 then
  begin
    nData := 'δ��ѯ�������Ϣ.';
    with FPacker.XMLBuilder.Root.NodeNew('EXMG') do
    begin
      NodeNew('MsgTxt').ValueAsString     := nData;
      NodeNew('MsgResult').ValueAsString  := sFlag_No;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
    nData := FPacker.XMLBuilder.WriteToString;
    Exit;
  end;

  with FPacker.XMLBuilder do
  begin
    with Root.NodeNew('Items') do
    begin

      nDs.First;

      while not nDs.eof do
      with NodeNew('Item') do
      begin
        NodeNew('BILL').ValueAsString := nDs.FieldByName('L_ID').AsString;

        NodeNew('PROJECT').ValueAsString := nDs.FieldByName('L_ZhiKa').AsString;

        NodeNew('CusID').ValueAsString := nDs.FieldByName('L_CusID').AsString;
        NodeNew('CUSNAME').ValueAsString := nDs.FieldByName('L_CusName').AsString;

        NodeNew('TRUCK').ValueAsString := nDs.FieldByName('L_Truck').AsString;
        NodeNew('StockNo').ValueAsString := nDs.FieldByName('L_StockNo').AsString;
        NodeNew('StockName').ValueAsString := nDs.FieldByName('L_StockName').AsString;

        NodeNew('WORKADDR').ValueAsString := nDs.FieldByName('L_Project').AsString;
        NodeNew('AREA').ValueAsString := nDs.FieldByName('l_area').AsString;
        NodeNew('HYDAN').ValueAsString := nDs.FieldByName('l_hydan').AsString;
        NodeNew('LVALUE').ValueAsString := nDs.FieldByName('L_Value').AsString;
        if Trim(nDs.FieldByName('l_outfact').AsString) = '' then
          NodeNew('OUTDATE').ValueAsString := 'δ����'
        else
          NodeNew('OUTDATE').ValueAsString := FormatDateTime('yyyy-mm-dd',
                nDs.FieldByName('l_outfact').AsDateTime);

        nDs.Next;
      end;
    end;

    with Root.NodeNew('EXMG') do
    begin
      NodeNew('MsgTxt').ValueAsString     := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('��α���ѯ����:'+nData);
  Result := True;
end;

//Date: 2017-11-15
//Desc: ������Ϣ
function TBusWorkerBusinessWebchatNC.Send_Event_Msg(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  nStr := '<?xml version="1.0" encoding="UTF-8"?>'
        +'<DATA>'
        +'<head>'
        +'<Factory>%s</Factory>'
        +'<ToUser>%s</ToUser>'
        +'<MsgType>%s</MsgType>'
        +'</head>'
        +'<Items>'
        +'	  <Item>'
        +'	      <BillID>%s</BillID>'
        +'	      <Card>%s</Card>'
        +'	      <Truck>%s</Truck>'
        +'	      <StockNo>%s</StockNo>'
        +'	      <StockName>%s</StockName>'
        +'	      <CusID>%s</CusID>'
        +'	      <CusName>%s</CusName>'
        +'	      <CusAccount>0</CusAccount>'
        +'	      <MakeDate></MakeDate>'
        +'	      <MakeMan></MakeMan>'
        +'	      <TransID></TransID>'
        +'	      <TransName></TransName>'
        +'	      <Searial></Searial>'
        +'	      <OutFact></OutFact>'
        +'	      <OutMan></OutMan>'
        +'        <NetWeight>%s</NetWeight>'
        +'	  </Item>	'
        +'</Items>'
        +'</DATA>';
  nStr := Format(nStr, [gSysParam.FFactID, FListA.Values['CusID'],
                  FListA.Values['MsgType'], FListA.Values['BillID'],
                  FListA.Values['Card'], FListA.Values['Truck'],
                  FListA.Values['StockNo'], FListA.Values['StockName'],
                  FListA.Values['CusID'], FListA.Values['CusName'],
                  FListA.Values['Value']]);
  WriteLog('�����̳�ģ����Ϣ���'+nStr);
  FWXChannel := GetReviceWS(gSysParam.FSrvRemote);
  nStr := FWXChannel.mainfuncs('send_event_msg', nStr);
  WriteLog('�����̳�ģ����Ϣ����'+nStr);
  with FPacker.XMLBuilder do
  begin
    ReadFromString(nStr);
    if not ParseDefault(nData) then
    begin
      WriteLog('����΢����Ϣʧ��:'+nData+'Ӧ��:'+nStr);
      Exit;
    end;
  end;

  Result := True;
  FOut.FData := sFlag_Yes;
  FOut.FBase.FResult := True;
end;

function TBusWorkerBusinessWebchatNC.complete_shoporders(
  var nData: string): Boolean;
var nStr, nSql: string;
    nDBConn: PDBWorker;
    nIdx, nQue, nLineCount:Integer;
    nNetWeight:Double;
    nWxZhuId, nWxZiId, nCreateTime, nInTime, nOutTime, nType, nStockNo, nTruck: string;
    nSeal, nPDate, nMDate, nLadeTime, nPID, nQueueMsg,nCompany,nOrder: string;
    nDaiQuickSync: Boolean;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  nNetWeight := 0;
  nDaiQuickSync := False;
  nDBConn := nil;

  with gParamManager.ActiveParam^ do
  begin
    try
      nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
      if not Assigned(nDBConn) then
      begin
        Exit;
      end;
      if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;

      nSql := 'select D_Value from %s where D_Name=''DaiQuickSync''';
      nSql := Format(nSql,[sTable_SysDict]);
      with gDBConnManager.WorkerQuery(nDBConn, nSql) do
      begin
        if RecordCount > 0 then
         nDaiQuickSync := Fields[0].AsString = sFlag_Yes;
      end;

      //���۾���
      nSql := 'select L_Value,L_WxZhuId,L_WxZiId,L_Type,L_StockNo, L_Truck,' +
              'L_Date,L_InTime,L_OutFact,L_Seal,L_PDate,L_MDate,L_LadeTime,' +
              'P_ID,L_Company,L_OrderNo from %s Left Join %s On P_Bill=L_ID where l_id=''%s''';
      nSql := Format(nSql,[sTable_Bill, sTable_PoundLog, FListA.Values['WOM_LID']]);
      with gDBConnManager.WorkerQuery(nDBConn, nSql) do
      begin
        if recordcount>0 then
        begin
          nNetWeight := FieldByName('L_Value').asFloat;
          nWxZhuId := FieldByName('L_WxZhuId').AsString;

          if Pos('.', nWxZhuId) > 0 then
            nWxZhuId := Copy(nWxZhuId, 1, Pos('.', nWxZhuId) - 1);
            
          nWxZiId := FieldByName('L_WxZiId').AsString;

          if FieldByName('L_Date').AsString <> '' then
          nCreateTime := DateTime2Str(IncHour(FieldByName('L_Date').AsDateTime, -8));

          if FieldByName('L_InTime').AsString <> '' then
          nInTime := DateTime2Str(IncHour(FieldByName('L_InTime').AsDateTime, -8));

          if FieldByName('L_OutFact').AsString <> '' then
          nOutTime := DateTime2Str(IncHour(FieldByName('L_OutFact').AsDateTime, -8));
          nType := FieldByName('L_Type').AsString;
          nStockNo := FieldByName('L_StockNo').AsString;
          nTruck := FieldByName('L_Truck').AsString;

          nSeal := FieldByName('L_Seal').AsString;

          if FieldByName('L_PDate').AsString <> '' then
          nPDate := DateTime2Str(IncHour(FieldByName('L_PDate').AsDateTime, -8));

          if FieldByName('L_MDate').AsString <> '' then
          nMDate := DateTime2Str(IncHour(FieldByName('L_MDate').AsDateTime, -8));

          if FieldByName('L_LadeTime').AsString <> '' then
          nLadeTime := DateTime2Str(IncHour(FieldByName('L_LadeTime').AsDateTime, -8));

          nPID := FieldByName('P_ID').AsString;
          nCompany := FieldByName('L_Company').AsString;

          if Assigned(FindField('L_OrderNo')) then
          begin
            nOrder := FieldByName('L_OrderNo').AsString;
          end
          else
            nOrder := '';
        end;
      end;

      nQue := 0;
      nSql := 'select T_Bill from %s where T_Type=''%s''' +
              ' and T_StockNo=''%s'' and T_Valid = ''%s'' order by T_InTime asc';
      nSql := Format(nSql,[sTable_ZTTrucks,nType,nStockNo,sFlag_Yes]);
      with gDBConnManager.WorkerQuery(nDBConn, nSql) do
      begin
        First;

        while not Eof do
        begin
          Inc(nQue);
          if FListA.Values['WOM_LID'] = Fields[0].AsString then
            Break;
          Next;
        end;
      end;

      nLineCount := 1;
      nSql := 'select Z_ID from %s where Z_StockType=''%s''' +
              ' and Z_StockNo=''%s'' and Z_Valid = ''%s''';
      nSql := Format(nSql,[sTable_ZTLines,nType,nStockNo,sFlag_Yes]);
      with gDBConnManager.WorkerQuery(nDBConn, nSql) do
      begin
        if RecordCount > 0 then
         nLineCount := RecordCount;
      end;

      nQue := Round(nQue / nLineCount);
    finally
      gDBConnManager.ReleaseConnection(nDBConn);
    end;
  end;

  if Trim(nWxZhuId) = '' then
  begin
    WriteLog(FListA.Values['WOM_LID']+ '������������...ִ�й���');
    Result := True;
    Exit;
  end;

  if FListA.Values['WOM_StatusType'] = '4' then
  begin
    nQueueMsg := FListA.Values['WOM_QueueMsg'];
  end
  else
  if FListA.Values['WOM_StatusType'] = '1' then
  begin
    nQueueMsg := '%s�ڵ�ǰ����λ���ź�:%d';
    nQueueMsg := Format(nQueueMsg, [nTruck, nQue]);
  end
  else
  if FListA.Values['WOM_StatusType'] = '2' then
  begin
    nQueueMsg := '%s���볧';
    nQueueMsg := Format(nQueueMsg, [nTruck]);
  end
  else
  begin
    nQueueMsg := '%s�ѳ���';
    nQueueMsg := Format(nQueueMsg, [nTruck]);
  end;

  if FListA.Values['WOM_StatusType'] = '3' then
  begin
    if nPDate = '' then
      nPDate := nCreateTime;

    if nDaiQuickSync and (nType = sFlag_Dai) then
    begin
      nMDate := nCreateTime;
    end
    else
    begin
      if nMDate = '' then
        nMDate := nOutTime;

      if nMDate = '' then
        nMDate := nCreateTime;
    end;

    if nLadeTime = '' then
      nLadeTime := nCreateTime;
  end;

  if (FListA.Values['WOM_StatusType'] = '1') or (FListA.Values['WOM_StatusType'] = '4') then
    FListA.Values['WOM_StatusType'] := '3'
  else
  if FListA.Values['WOM_StatusType'] = '2' then
    FListA.Values['WOM_StatusType'] := '4'
  else
    FListA.Values['WOM_StatusType'] := '5';

  if FListA.Values['WOM_StatusType'] = '5' then
  begin
    nStr := '{"data":"{'
        +'''datetime'':''%s'','
        +'''note'':''%s'','
        +'''item'':{'
        //+'''price'':''%s'','
        +'''qty'':''%s'','
        //+'''total'':''%.2f'','
        +'''real_date'':''%s'','
        +'''real_qty'':''%.2f'','
        +'''vdef1'':''%s'','
        +'''vdef2'':''%s'','
        +'''vdef3'':''%s'','
        +'''vdef4'':''%s'','
        +'''vdef5'':''%s'','
        +'''vdef6'':''%s''},'
        +'''state'':''%s'','
        +'''msgtype'':''%s'','
        +'''vbillno'':''%s''}'
        +'"}';
    nStr := Format(nStr,[nOutTime, nQueueMsg,
                         '',
                         nOutTime, nNetWeight, nSeal, nPID,
                         nPDate, nMDate, nLadeTime, nInTime,
                         FListA.Values['WOM_StatusType'],
                         '4',
                         nOrder]);
  end
  else
  if FListA.Values['WOM_StatusType'] = '4' then
  begin
    nStr := '{"data":"{'
        +'''datetime'':''%s'','
        +'''note'':''%s'','
        +'''item'':{'
        //+'''price'':''%s'','
        +'''qty'':''%s'','
        //+'''total'':''%.2f'','
        //+'''real_date'':''%s'','
        //+'''real_qty'':''%.2f'','
        +'''vdef1'':''%s'','
        +'''vdef2'':''%s'','
        +'''vdef3'':''%s'','
        +'''vdef4'':''%s'','
        +'''vdef5'':''%s'','
        +'''vdef6'':''%s''},'
        +'''state'':''%s'','
        +'''msgtype'':''%s'','
        +'''vbillno'':''%s''}'
        +'"}';
    nStr := Format(nStr,[nInTime, nQueueMsg,
                         '',
                         nSeal, nPID,
                         nPDate, nMDate, nLadeTime, nInTime,
                         FListA.Values['WOM_StatusType'],
                         '0',
                         nOrder]);
  end
  else
  begin
    nStr := '{"data":"{'
        +'''datetime'':''%s'','
        +'''note'':''%s'','
        +'''item'':{'
        //+'''price'':''%s'','
        +'''qty'':''%s'','
        //+'''total'':''%.2f'','
        //+'''real_date'':''%s'','
        //+'''real_qty'':''%.2f'','
        +'''vdef1'':''%s'','
        +'''vdef2'':''%s'','
        +'''vdef3'':''%s'','
        +'''vdef4'':''%s'','
        +'''vdef5'':''%s'','
        +'''vdef6'':''%s''},'
        +'''state'':''%s'','
        +'''msgtype'':''%s'','
        +'''vbillno'':''%s''}'
        +'"}';
    nStr := Format(nStr,[nCreateTime, nQueueMsg,
                         '',
                         nSeal, nPID,
                         nPDate, nMDate, nLadeTime, nInTime,
                         FListA.Values['WOM_StatusType'],
                         FListA.Values['WOM_StatusType'],
                         nOrder]);
  end;

  WriteLog('�޸Ķ���״̬���'+nStr);

  try
    nStr := IWebService(FNCChannel^.FChannel).order(nStr, nWxZhuId, gSysParam.FESBDB,
                                                    gSysParam.FESBLog, gSysParam.FESBPass);
  except
    on E: Exception do
    begin
      nStr := E.Message;
    end;
  end;
  WriteLog('�޸Ķ���״̬����'+nStr);

  if Pos('�ɹ�', nStr) <= 0 then
  begin
    nData := 'ҵ��ִ��ʧ��,����: %s';
    nData := Format(nData, [nStr]);
    Exit;
  end;

  Result := True;
  FOut.FData := sFlag_Yes;
  FOut.FBase.FResult := True;
end;


function TBusWorkerBusinessWebchatNC.Edit_Shopgoods(
  var nData: string): boolean;
begin
  Result := True;
  FOut.FData := sFlag_Yes;
  FOut.FBase.FResult := True;
end;

function TBusWorkerBusinessWebchatNC.Get_Shoporders(
  var nData: string): boolean;
var nStr: string;
    nNode, nRoot: TXmlNode;
    nInt: Integer;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  nStr := '<?xml version="1.0" encoding="UTF-8"?>'
      +'<DATA>'
      +'<head><Factory>%s</Factory>'
      +'<ID>%s</ID>'
      +'</head>'
      +'</DATA>';
  nStr := Format(nStr,[gSysParam.FFactID,FListA.Values['ID']]);

  FWXChannel := GetReviceWS(gSysParam.FSrvRemote);
  nStr := FWXChannel.mainfuncs('Get_Shoporders', nStr);

  with FPacker.XMLBuilder do
  begin
    ReadFromString(nStr);
    if not ParseDefault(nData) then Exit;

    nRoot := Root.FindNode('Items');
    if not (Assigned(nRoot)) then
    begin
      nData := '��Ч�����ڵ�(Items Null).';
      Exit;
    end;

    FListA.Clear;
    FListB.Clear;
    for nInt:=0 to nRoot.NodeCount-1 do
    begin
      nNode := nRoot.Nodes[nInt];
      if CompareText('item', nNode.Name) <> 0 then Continue;

      with FListB,nNode do
      begin
        Values['order_id']    := NodeByName('order_id').ValueAsString;
        Values['ordernumber'] := NodeByName('ordernumber').ValueAsString;
        Values['goodsID']     := NodeByName('goodsID').ValueAsString;
        Values['goodstype']   := NodeByName('goodstype').ValueAsString;
        Values['goodsname']   := NodeByName('goodsname').ValueAsString;
        Values['data']        := NodeByName('data').ValueAsString;
      end;

      FListA.Add(PackerEncodeStr(FListB.Text));
      //new item
    end;
    nData := PackerEncodeStr(FListA.Text);
  end;

  Result := True;
  FOut.FData := nData;
  FOut.FBase.FResult := True;
end;

function TBusWorkerBusinessWebchatNC.Get_ShoporderByNO(
  var nData: string): boolean;
var nStr, nWebOrder: string;
    nNode, nTmp: TXmlNode;
    nInt : Integer;
begin
  Result := False;
  nWebOrder := PackerDecodeStr(FIn.FData);

  nStr := '<?xml version="1.0" encoding="UTF-8"?>'
      +'<DATA>'
      +'<head><Factory>%s</Factory>'
      +'<NO>%s</NO>'
      +'</head>'
      +'</DATA>';
  nStr := Format(nStr,[gSysParam.FFactID,nWebOrder]);
  WriteLog('��ȡ������Ϣ���:'+nStr);

  FWXChannel := GetReviceWS(gSysParam.FSrvRemote);
  nStr := FWXChannel.mainfuncs('get_shoporderByNO', nStr);
  WriteLog('��ȡ������Ϣ���ν���ǰ:'+nStr);

  with FPacker.XMLBuilder do
  begin
    ReadFromString(nStr);
    if not ParseDefault(nData) then Exit;

    nNode := Root.FindNode('Items');
    if not (Assigned(nNode)) then
    begin
      nData := '��Ч�����ڵ�(Items Null).';
      Exit;
    end;

    FListA.Clear;
    FListB.Clear;
    for nInt := 0 to nNode.NodeCount - 1 do
    begin
      nTmp := nNode.Nodes[nInt];

      if not (Assigned(nTmp)) then
        Continue;

      if Assigned(nTmp.NodeByName('order_id')) then
        FListB.Values['order_id'] := nTmp.NodeByName('order_id').ValueAsString;

      if Assigned(nTmp.NodeByName('fac_order_no')) then
        FListB.Values['fac_order_no'] := nTmp.NodeByName('fac_order_no').ValueAsString;

      if Assigned(nTmp.NodeByName('ordernumber')) then
        FListB.Values['ordernumber'] := nTmp.NodeByName('ordernumber').ValueAsString;

      if Assigned(nTmp.NodeByName('goodsID')) then
        FListB.Values['goodsID'] := nTmp.NodeByName('goodsID').ValueAsString;

      if Assigned(nTmp.NodeByName('goodstype')) then
        FListB.Values['goodstype'] := nTmp.NodeByName('goodstype').ValueAsString;

      if Assigned(nTmp.NodeByName('goodsname')) then
        FListB.Values['goodsname'] := nTmp.NodeByName('goodsname').ValueAsString;

      if Assigned(nTmp.NodeByName('tracknumber')) then
        FListB.Values['tracknumber'] := nTmp.NodeByName('tracknumber').ValueAsString;

      if Assigned(nTmp.NodeByName('data')) then
        FListB.Values['data'] := nTmp.NodeByName('data').ValueAsString;

      if Assigned(nTmp.NodeByName('order_ls')) then
        FListB.Values['order_ls'] := nTmp.NodeByName('order_ls').ValueAsString;

      nStr := StringReplace(FListB.Text, '\n', #13#10, [rfReplaceAll]);

      {$IFDEF UseUTFDecode}
      nStr := UTF8Decode(nStr);
      {$ENDIF}
      WriteLog('��ȡ������Ϣ���ν����:'+nStr);

      FListA.Add(nStr);
    end;
    nData := PackerEncodeStr(FListA.Text);
  end;

  Result := True;
  FOut.FData := nData;
  FOut.FBase.FResult := True;
end;


//------------------------------------------------------------------------------
//Date: 2017-11-20
//Parm: ����
//Desc: ������װ��ѯ
function TBusWorkerBusinessWebchatNC.GetWaitingForloading(var nData:string):Boolean;
var nStr: string;
    nNode: TXmlNode;
begin
  Result := False;

  BuildDefaultXML;

  nStr := 'Select Z_StockNo, COUNT(*) as Num From %s Where Z_Valid=''%s'' group by Z_StockNo';
  nStr := Format(nStr, [sTable_ZTLines, sFlag_Yes]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),FPacker.XMLBuilder do
  begin
    if RecordCount < 1 then
    begin
      nData := '����(%s)δ������Чװ����.';
      nData := Format(nData, [gSysParam.FFactID]);
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;

      Exit;
    end;

    First;

    nNode := Root.NodeNew('Items');
    while not Eof do
    begin
      with nNode.NodeNew('Item') do
      begin
        NodeNew('StockName').ValueAsString  := GetStockName(
                                               FieldByName('Z_StockNo').AsString);
        NodeNew('LineCount').ValueAsString  := FieldByName('Num').AsString;
        NodeNew('TruckCount').ValueAsString := GetTruckByLine(
                                               FieldByName('Z_StockNo').AsString);
      end;

      Next;
    end;

    nNode := Root.NodeNew('EXMG');
    with nNode do
    begin
      NodeNew('MsgTxt').ValueAsString     := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  Result := True;
end;

//------------------------------------------------------------------------------
//Date: 2017-11-20
//Parm: ˮ������
//Desc: ��ȡ��ǰ��Ʒ��ˮ������װ������
function TBusWorkerBusinessWebchatNC.GetTruckByLine(
  nStockNo: string): string;
var nStr, nGroup, nSQL, nGroupID: string;
    nDBWorker: PDBWorker;
    nCount : Integer;
begin
  Result := '0';
  nCount := 0 ;

  nDBWorker := nil;
  try
    nStr := 'Select * From %s Where T_Valid=''%s'' And T_StockNo=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, sFlag_Yes, nStockNo]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      nCount := RecordCount;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

    if nCount <= 0 then//���ܴ�������ӳ��
    begin
      nGroup := '';
      nGroupID := '';

      nDBWorker := nil;
      try
        nStr := 'Select M_Group From %s Where M_Status=''%s'' And M_ID=''%s''';
        nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes, nStockNo]);

        with gDBConnManager.SQLQuery(nStr, nDBWorker) do
        begin
          if RecordCount > 0 then
            nGroupID := Fields[0].AsString;
        end;
      finally
        gDBConnManager.ReleaseConnection(nDBWorker);
      end;

      if Length(nGroupID) > 0 then
      begin
        nDBWorker := nil;
        try
          nStr := 'Select M_ID From %s Where M_Status=''%s'' And M_Group=''%s''';
          nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes, nGroupID]);

          with gDBConnManager.SQLQuery(nStr, nDBWorker) do
          begin

            First;
            while not Eof do
            begin
              nGroup := nGroup + Fields[0].AsString + ',';
              Next;
            end;
            if Copy(nGroup, Length(nGroup), 1) = ',' then
              System.Delete(nGroup, Length(nGroup), 1);
          end;
          nSQL := AdjustListStrFormat(nGroup, '''', True, ',', False);
        finally
          gDBConnManager.ReleaseConnection(nDBWorker);
        end;

        nDBWorker := nil;
        try
          nStr := 'Select * From %s Where T_Valid=''%s'' And T_StockNo In (%s)';
          nStr := Format(nStr, [sTable_ZTTrucks, sFlag_Yes, nSQL]);

          WriteLog('��ѯ������װSQL:'+ nStr);
          with gDBConnManager.SQLQuery(nStr, nDBWorker) do
          begin
            nCount := RecordCount;
          end;
        finally
          gDBConnManager.ReleaseConnection(nDBWorker);
        end;
      end;
    end;
    Result := IntToStr(nCount);
end;

//Date: 2017-10-01
//Parm: �ֵ���;�б�
//Desc: ��SysDict�ж�ȡnItem�������,����nList��
function TBusWorkerBusinessWebchatNC.LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
var nStr: string;
    nDBWorker: PDBWorker;
begin
    nDBWorker := nil;
  try
    nList.Clear;
    nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                        MI('$Name', nItem)]);

    Result := gDBConnManager.SQLQuery(nStr, nDBWorker);

    if Result.RecordCount > 0 then
    with Result do
    begin
      First;

      while not Eof do
      begin
        nList.Add(FieldByName('D_Value').AsString);
        Next;
      end;
    end else Result := nil;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2017-10-28
//Parm: �ͻ����[FIn.FData]
//Desc: ��ȡ���ö����б�
function TBusWorkerBusinessWebchatNC.GetPurchaseContractList(var nData: string): Boolean;
var nStr, nProID: string;
    nNode: TXmlNode;
begin
  Result := False;

  nProID := Trim(FIn.FData);
  BuildDefaultXML;

  nStr := 'Select *,(B_Value-B_SentValue-B_FreezeValue) As B_MaxValue From %s PB '
    +'left join %s PM on PM.M_ID = PB.B_StockNo ' 
    +'where ((B_Value-B_SentValue>0) or (B_Value=0)) And B_BStatus=''%s'' '
    +'and B_ProID=''%s''';
  //nStr := Format(nStr , [sTable_OrderBase, sTable_Materails, sFlag_Yes, nProID]);
  WriteLog('��ȡ�ɹ������б�sql:'+nStr);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),FPacker.XMLBuilder do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('δ��ѯ����Ӧ��[ %s ]��Ӧ�Ķ�����Ϣ.', [FIn.FData]);

      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;
      Exit;
    end;

    First;

    nNode := Root.NodeNew('head');
    with nNode do
    begin
      NodeNew('ProvId').ValueAsString := FieldByName('B_ProID').AsString;
      NodeNew('ProvName').ValueAsString := FieldByName('B_ProName').AsString;
    end;

    nNode := Root.NodeNew('Items');
    while not Eof do
    begin
      with nNode.NodeNew('Item') do
      begin
        NodeNew('SetDate').ValueAsString    := DateTime2Str(FieldByName('B_Date').AsDateTime);
        NodeNew('BillNumber').ValueAsString := FieldByName('B_ID').AsString;
        NodeNew('StockNo').ValueAsString    := FieldByName('B_StockNo').AsString;
        NodeNew('StockName').ValueAsString  := FieldByName('B_StockName').AsString;
        NodeNew('MaxNumber').ValueAsString  := FieldByName('B_MaxValue').AsString;
        {$IFDEF KuangFa}
        NodeNew('HasLs').ValueAsString      := FieldByName('M_HasLs').AsString;
        {$ELSE}
        NodeNew('HasLs').ValueAsString      := sFlag_No;
        {$ENDIF}
      end;

      Next;
    end;

    nNode := Root.NodeNew('EXMG');
    with nNode do
    begin
      NodeNew('MsgTxt').ValueAsString     := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('��ȡ�ɹ������б���:'+nData);
  Result := True;
end;

function TBusWorkerBusinessWebchatNC.GetCusName(nCusID: string): string;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := '';

  nDBWorker := nil;
  try
    nStr := 'Select C_Name From %s Where C_ID=''%s'' ';
    nStr := Format(nStr, [sTable_Customer, nCusID]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      Result := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2018-01-05
//Desc: ��ȡָ���ͻ��Ŀ��ý��
function TBusWorkerBusinessWebchatNC.GetCustomerValidMoney(nCustomer: string): Double;
begin
  Result := 0 ;
end;

//Date: 2018-01-05
//Desc: ��ȡָ���ͻ��Ŀ��ý��
function TBusWorkerBusinessWebchatNC.GetCustomerValidMoneyFromK3(nCustomer: string): Double;
begin
  Result := 0;
end;

//Date: 2018-01-11
//Parm: �ͻ���[FIn.FData]
//Desc: ��ȡ�ͻ��ʽ�
function TBusWorkerBusinessWebchatNC.GetCusMoney(var nData: string): Boolean;
var
  nMoney: Double;
begin
  Result := False;
  BuildDefaultXML;

  nMoney := 0 ;
  {$IFDEF UseCustomertMoney}
  nMoney := GetCustomerValidMoney(FIn.FData);
  {$ENDIF}

  {$IFDEF UseERP_K3}
  nMoney := GetCustomerValidMoneyFromK3(FIn.FData);
  {$ENDIF}

  with FPacker.XMLBuilder do
  begin
    with Root.NodeNew('Items') do
    begin
      with NodeNew('Item') do
      begin
        NodeNew('Money').ValueAsString := FloatToStr(nMoney);
      end;
    end;

    with Root.NodeNew('EXMG') do
    begin
      NodeNew('MsgTxt').ValueAsString     := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('�ͻ��ʽ��ѯ����:'+nData);
  Result := True;
end;

//����������ѯ���ɹ������������۳�������
function TBusWorkerBusinessWebchatNC.GetInOutFactoryTotal(var nData:string):Boolean;
var
  nStr,nExtParam:string;
  nType,nStartDate,nEndDate:string;
  nPos:Integer;
  nNode: TXmlNode;
  nStartTime,nEndTime:string;
  nDt : TDateTime;
begin
  Result := True;
  BuildDefaultXML;

  nType := Trim(fin.FData);
  nExtParam := Trim(FIn.FExtParam);
  with FPacker.XMLBuilder do
  begin
    if (nType='') or (nExtParam='') then
    begin
      nData := Format('��ѯ����������쳣:[ %s ].', [nType + ',' + nExtParam]);

      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;
      Exit;
    end;
  end;

  nPos := Pos('and',nExtParam);
  if nPos > 0 then
  begin
    nStartDate := Copy(nExtParam,1,nPos-1)+' 00:00:00';
    nEndDate := Copy(nExtParam,nPos+3,Length(nExtParam)-nPos-2)+' 23:59:59';
  end;

  WriteLog('��ѯ������ʱ������:' + '��ʼ:' + nStartDate + '����:' + nEndDate);

  FListA.Text := GetInOutValue(nStartDate,nEndDate,nType);

  nStr := 'EXEC SP_InOutFactoryTotal '''+nType+''','''+nStartDate+''','''+nEndDate+''' ';

  with gDBConnManager.WorkerQuery(FDBConn, nStr),FPacker.XMLBuilder do
  begin
    if RecordCount < 1 then
    begin
      nData := 'δ��ѯ�������Ϣ.';

      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
      nData := FPacker.XMLBuilder.WriteToString;
      Exit;
    end;

    First;

    nNode := Root.NodeNew('head');
    with nNode do
    begin
      NodeNew('DValue').ValueAsString := FListA.Values['DValue'];
      NodeNew('SValue').ValueAsString := FListA.Values['SValue'];
      NodeNew('TotalValue').ValueAsString := FListA.Values['TotalValue'];
    end;

    nNode := Root.NodeNew('Items');
    while not Eof do
    begin
      with nNode.NodeNew('Item') do
      begin
        NodeNew('StockName').ValueAsString := FieldByName('StockName').AsString;
        NodeNew('TruckCount').ValueAsString := FieldByName('TruckCount').AsString;
        NodeNew('StockValue').ValueAsString := FieldByName('StockValue').AsString;
      end;

      Next;
    end;

    nNode := Root.NodeNew('EXMG');
    with nNode do
    begin
      NodeNew('MsgTxt').ValueAsString     := 'ҵ��ִ�гɹ�';
      NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
      NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
    end;
  end;
  nData := FPacker.XMLBuilder.WriteToString;
  WriteLog('��ѯ������ͳ�Ʒ���:'+nData);
  Result := True;
end;

function TBusWorkerBusinessWebchatNC.GetInOutValue(nBegin,
  nEnd, nType: string): string;
var nStr, nTable: string;
    nDBWorker: PDBWorker;
    nDValue, nSValue, nTotalValue : Double;
begin
  Result := '';
  nDValue:= 0;
  nSValue:= 0;
  nTotalValue:= 0;

  nDBWorker := nil;
  try
    nStr := 'select distinct L_type as Stock_Type, SUM(L_Value) as Stock_Value from %s '
    +' where L_OutFact >= ''%s'' and L_OutFact <= ''%s'' group by L_Type ' ;

    if nType = 'SZ' then
      nStr := 'select distinct L_type as Stock_Type, SUM(L_Value) as Stock_Value from %s '
      +' where L_InTime >= ''%s'' and L_InTime <= ''%s'' and L_Status <> ''O'' group by L_Type '
    else
    if nType = 'P' then
      nStr := 'select distinct D_Type as Stock_Type ,SUM(D_Value) as Stock_Value from %s '
      +' where D_OutFact >= ''%s'' and D_OutFact <= ''%s'' group by D_Type '
    else
    if nType = 'PZ' then
    nStr := 'select distinct D_Type as Stock_Type ,SUM(D_Value) as Stock_Value from %s '
    +' where D_MDate >= ''%s'' and D_MDate <= ''%s'' and D_Status <> ''O'' group by D_Type ';
    if Pos('P',nType) > 0 then
      nTable := sTable_Bill
    else
      nTable := sTable_Bill;
    nStr := Format(nStr, [nTable, nBegin, nEnd]);

    WriteLog('��ѯ����ͳ��SQL:'+nStr);
    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      First;
      while not Eof do
      begin
        nTotalValue := nTotalValue + Fields[1].AsFloat;
        nStr := Fields[0].AsString;
        if nStr = sFlag_Dai then
          nDValue := Fields[1].AsFloat
        else
        if nStr = sFlag_San then
          nSValue := Fields[1].AsFloat;

        Next;
      end;
    end;
    FListB.Clear;
    FListB.Values['DValue'] := FormatFloat('0.00',nDValue);
    FListB.Values['SValue'] := FormatFloat('0.00',nSValue);
    FListB.Values['TotalValue'] := FormatFloat('0.00',nTotalValue);
    Result := FListB.Text;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

function TBusWorkerBusinessWebchatNC.GetStockName(nStockNo: string): string;
var nStr: string;
    nDBWorker: PDBWorker;
begin
  Result := '';

  nDBWorker := nil;
  try
    nStr := 'Select Z_Stock From %s Where Z_StockNo=''%s'' ';
    nStr := Format(nStr, [sTable_ZTLines, nStockNo]);

    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      Result := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2018-01-17
//Desc: ��ȡ�ֻ����ᱨ������Ϣ
function TBusWorkerBusinessWebchatNC.getDeclareCar(
  var nData: string): Boolean;
var nStr, nStatus: string;
    nIdx: Integer;
    nNode,nRoot: TXmlNode;
    nInit: Int64;
begin
  Result := False;
  nStatus := PackerDecodeStr(FIn.FData);

  nStr := '<?xml version="1.0" encoding="UTF-8"?>'
      +'<DATA>'
      +'<head><Factory>%s</Factory>'
      +'<Status>%s</Status>'
      +'</head>'
      +'</DATA>';
  nStr := Format(nStr,[gSysParam.FFactID,nStatus]);
  WriteLog('��ȡ�ᱨ������Ϣ���:'+nStr);

  Result := False;
  FWXChannel := GetReviceWS(gSysParam.FSrvRemote);
  nStr := FWXChannel.mainfuncs('getDeclareCar', nStr);

  WriteLog('��ȡ�ᱨ������Ϣ����:'+nStr);

  with FPacker.XMLBuilder do
  begin
    ReadFromString(nStr);
    if not ParseDefault(nData) then Exit;
    nRoot := Root.FindNode('items');

    if not Assigned(nRoot) then
    begin
      nData := '��Ч�����ڵ�(WebService-Response.items Is Null).';
      Exit;
    end;

    nInit := GetTickCount;
    FListA.Clear;
    FListB.Clear;
    for nIdx:=0 to nRoot.NodeCount-1 do
    begin
      nNode := nRoot.Nodes[nIdx];
      if CompareText('item', nNode.Name) <> 0 then Continue;

      with FListB,nNode do
      begin
        Values['uniqueIdentifier']   := NodeByName('uniqueIdentifier').ValueAsString;
        Values['serialNo']  := NodeByName('serialNo').ValueAsString;
        Values['carNumber']    := NodeByName('carNumber').ValueAsString;
        Values['drivingLicensePath']   := NodeByName('drivingLicensePath').ValueAsString;
        Values['custName']  := NodeByName('custName').ValueAsString;
        Values['custPhone']    := NodeByName('custPhone').ValueAsString;
        Values['tare']    := NodeByName('tare').ValueAsString;
      end;
      SaveAuditTruck(FlistB,nStatus);
      FListA.Add(PackerEncodeStr(FListB.Text));
      //new item
    end;
  end;
  WriteLog('���泵��������ݺ�ʱ: ' + IntToStr(GetTickCount - nInit) + 'ms');
  Result := True;
  FOut.FData := FListA.Text;
  FOut.FBase.FResult := True;
end;

procedure TBusWorkerBusinessWebchatNC.SaveAuditTruck(nList: TStrings;
  nStatus: string);
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Delete From %s Where A_ID=''%s'' ';
    //nStr := Format(nStr, [sTable_AuditTruck, nList.Values['uniqueIdentifier']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

//    nStr := MakeSQLByStr([
//              SF('A_ID', nList.Values['uniqueIdentifier']),
//              SF('A_Serial', nList.Values['serialNo']),
//              SF('A_Truck', nList.Values['carNumber']),
//              SF('A_WeiXin', nList.Values['custName']),
//              SF('A_Phone', nList.Values['custPhone']),
//              SF('A_LicensePath', nList.Values['drivingLicensePath']),
//              SF('A_Status', nStatus),
//              SF('A_Date', sField_SQLServer_Now, sfVal),
//              SF('A_PValue', nList.Values['tare'])
//              ], sTable_AuditTruck, '', True);
    //xxxxx

    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2009-7-4
//Parm: ���ݼ�;�ֶ���;ͼ������
//Desc: ��nImageͼ�����nDS.nField�ֶ�
function TBusWorkerBusinessWebchatNC.SaveDBImage(const nDS: TDataSet; const nFieldName: string;
  const nStream: TMemoryStream): Boolean;
var nField: TField;
    nBuf: array[1..MAX_PATH] of Char;
begin
  Result := False;
  nField := nDS.FindField(nFieldName);
  if not (Assigned(nField) and (nField is TBlobField)) then Exit;

  try
    if not Assigned(nStream) then
    begin
      nDS.Edit;
      TBlobField(nField).Clear;
      nDS.Post; Result := True; Exit;
    end;

    nDS.Edit;
    nStream.Position := 0;
    TBlobField(nField).LoadFromStream(nStream);

    nDS.Post;
    Result := True;
  except
    if nDS.State = dsEdit then nDS.Cancel;
  end;
end;

//Date: 2018-01-22
//Desc: ������˽���ϴ�����or������ڿ�����
function TBusWorkerBusinessWebchatNC.UpdateDeclareCar(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  nStr := '<?xml version="1.0" encoding="UTF-8"?>' +
          '<DATA>' +
          '<head>' +
          '<UniqueIdentifier>%s</UniqueIdentifier>' +
          '<AuditStatus>%s</AuditStatus>' +
          '<AuditRemark>%s</AuditRemark>' +
          '<AuditUserName>%s</AuditUserName>' +
          '<IsLongTermCar>%s</IsLongTermCar>' +
          '</head>' +
          '</DATA>';
  nStr := Format(nStr, [FListA.Values['ID'], FListA.Values['Status'],
          FListA.Values['Memo'], FListA.Values['Man'], FListA.Values['Type']]);
  //xxxxx

  WriteLog('��˽�����'+nStr);

  FWXChannel := GetReviceWS(gSysParam.FSrvRemote);
  nStr := FWXChannel.mainfuncs('updateDeclareCar', nStr);

  WriteLog('��˽������'+nStr);

  with FPacker.XMLBuilder do
  begin
    ReadFromString(nStr);
    if not ParseDefault(nData) then Exit;
  end;

  Result := True;
  FOut.FData := sFlag_Yes;
  FOut.FBase.FResult := True;
end;

//Date: 2018-01-22
//Desc: ����ͼƬ
function TBusWorkerBusinessWebchatNC.DownLoadPic(var nData: string): Boolean;
var nID,nStr: string;
    nIdx: Int64;
    nDS: TDataSet;
    nIdHTTP: TIdHTTP;
    nStream: TMemoryStream;
begin
  Result := False;
  nID := PackerDecodeStr(FIn.FData);

  nStr := 'Select * From %s Where A_ID=''%s'' ';
  //nStr := Format(nStr, [sTable_AuditTruck, nID]);

  nDS := gDBConnManager.WorkerQuery(FDBConn, nStr);

  if nDS.RecordCount < 1 then
  begin
    nStr := Format('δ��ѯ������%s�����Ϣ!', [nID]);
    WriteLog(nStr);
    Exit;
  end;

  if nDS.FieldByName('A_LicensePath').AsString = '' then
  begin
    nStr := Format('����%s��Ƭ·��Ϊ��!', [nID]);
    WriteLog(nStr);
    Exit;
  end;

  nIdx := GetTickCount;

  nIdHTTP := nil;
  nStream := nil;
  try
    nIdHTTP := TIdHTTP.Create;
    nStream := TMemoryStream.Create;

    nIdHTTP.Get(nDS.FieldByName('A_LicensePath').AsString, nStream);
    nStream.Position:=0;

    SaveDBImage(nDS, 'A_License', nStream);

    nIdHTTP.Free;
    nStream.Free;
  except
    if Assigned(nIdHTTP) then nIdHTTP.Free;
    if Assigned(nStream) then nStream.Free;
    Exit;
  end;
  WriteLog('���س���ͼƬ��ʱ: ' + IntToStr(GetTickCount - nIdx) + 'ms');

  Result := True;
  FOut.FData := sFlag_Yes;
  FOut.FBase.FResult := True;
end;

//Date: 2018-01-22
//Desc: ͨ�����ƺŻ�ȡ����
function TBusWorkerBusinessWebchatNC.Get_ShoporderByTruck(
  var nData: string): boolean;
var nStr, nTruck: string;
    nNode, nTmp: TXmlNode;
    nInt : Integer;
begin
  Result := False;
  nTruck := PackerDecodeStr(FIn.FData);

  nStr := '<?xml version="1.0" encoding="UTF-8"?>'
      +'<DATA>'
      +'<head><Factory>%s</Factory>'
      +'<CarNumber>%s</CarNumber>'
      +'</head>'
      +'</DATA>';
  nStr := Format(nStr,[gSysParam.FFactID,nTruck]);
  WriteLog('��ȡ������Ϣ���:'+nStr);

  FWXChannel := GetReviceWS(gSysParam.FSrvRemote);
  nStr := FWXChannel.mainfuncs('getShopOrderByDriverNumber', nStr);
  WriteLog('��ȡ������Ϣ���ν���ǰ:'+nStr);

  with FPacker.XMLBuilder do
  begin
    ReadFromString(nStr);
    if not ParseDefault(nData) then Exit;

    nNode := Root.FindNode('Items');
    if not (Assigned(nNode)) then
    begin
      nData := '��Ч�����ڵ�(Items Null).';
      Exit;
    end;

    FListA.Clear;
    FListB.Clear;
    for nInt := 0 to nNode.NodeCount - 1 do
    begin
      nTmp := nNode.Nodes[nInt];

      if not (Assigned(nTmp)) then
        Continue;

      if Assigned(nTmp.NodeByName('order_id')) then
        FListB.Values['order_id'] := nTmp.NodeByName('order_id').ValueAsString;

      if Assigned(nTmp.NodeByName('order_type')) then
        FListB.Values['order_type'] := nTmp.NodeByName('order_type').ValueAsString;

      if Assigned(nTmp.NodeByName('fac_order_no')) then
        FListB.Values['fac_order_no'] := nTmp.NodeByName('fac_order_no').ValueAsString;

      if Assigned(nTmp.NodeByName('ordernumber')) then
        FListB.Values['ordernumber'] := nTmp.NodeByName('ordernumber').ValueAsString;

      if Assigned(nTmp.NodeByName('goodsID')) then
        FListB.Values['goodsID'] := nTmp.NodeByName('goodsID').ValueAsString;

      if Assigned(nTmp.NodeByName('goodstype')) then
        FListB.Values['goodstype'] := nTmp.NodeByName('goodstype').ValueAsString;

      if Assigned(nTmp.NodeByName('goodsname')) then
        FListB.Values['goodsname'] := nTmp.NodeByName('goodsname').ValueAsString;

      if Assigned(nTmp.NodeByName('tracknumber')) then
        FListB.Values['tracknumber'] := nTmp.NodeByName('tracknumber').ValueAsString;

      if Assigned(nTmp.NodeByName('data')) then
        FListB.Values['data'] := nTmp.NodeByName('data').ValueAsString;

      nStr := StringReplace(FListB.Text, '\n', #13#10, [rfReplaceAll]);

      {$IFDEF UseUTFDecode}
      nStr := UTF8Decode(nStr);
      {$ENDIF}
      WriteLog('��ȡ������Ϣ���ν����:'+nStr);

      FListA.Add(nStr);
    end;
    nData := PackerEncodeStr(FListA.Text);
  end;

  Result := True;
  FOut.FData := nData;
  FOut.FBase.FResult := True;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerBusinessWebchatNC, sPlug_ModuleBus);
end.
