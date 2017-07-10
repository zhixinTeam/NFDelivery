{*******************************************************************************
����: fendou116688@163.com 2016/9/19
����: Webƽ̨�����ѯ
*******************************************************************************}
unit UWorkerBussinessWebchat;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, ADODB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerSelfRemote, NativeXml;

type
  TWebResponseBaseInfo = class(TObject)
  public
    FErrcode:Integer;
    FErrmsg:string;
    FPacker: TBusinessPackerBase;
    function ParseWebResponse(var nData:string):Boolean;virtual;
  end;

  stCustomerInfoItem = record
    Fphone:string;
    FBindcustomerid:string;
    FNamepinyin:string;
    FEmail:string;
  end;

  TWebResponse_CustomerInfo = class(TWebResponseBaseInfo)
  public
    items:array of stCustomerInfoItem;
    function ParseWebResponse(var nData:string):Boolean;override;
  end;

  TWebResponse_Bindfunc = class(TWebResponseBaseInfo)
  end;

  TWebResponse_send_event_msg=class(TWebResponseBaseInfo)
  end;

  TWebResponse_edit_shopclients=class(TWebResponseBaseInfo)
  end;

  TWebResponse_edit_shopgoods=class(TWebResponseBaseInfo)
  end;

  TWebResponse_complete_shoporders=class(TWebResponseBaseInfo)
  end;  

  stShopOrderItem = record
    FOrder_id:string;
    FOrderType: string;
    Ffac_order_no:string;
    FOrdernumber:string;
    FGoodsID:string;
    FGoodstype:string;
    FGoodsname:string;
    Ftracknumber:string;
    FData:string;
  end;
  
  TWebResponse_get_shoporders=class(TWebResponseBaseInfo)
  public
    items:array of stShopOrderItem;
    function ParseWebResponse(var nData:string):Boolean;override;
  end;

  TBusWorkerBusinessWebchat = class(TBusinessWorkerBase)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerWebChatData;
    FOut: TWorkerWebChatData;

    procedure BuildDefaultXMLPack;
    //��������Ĭ�ϱ���
    function UnPackIn(var nData: string): Boolean;
    //���뱨�Ľ��

    //-------------------��DL��Web�̳Ƿ����ѯ----------------------------------
    function SendEventMsg(var nData:string):boolean;
    //����ģ����Ϣ
    function GetCustomerInfo(var nData:string):boolean;
    //��ȡ�ͻ�ע����Ϣ
    function EditShopCustom(var nData:string):boolean;
    //����(�������)�̳��û�
    function GetShopOrdersByID(var nData:string):boolean;
    //����˾�����֤��ȡ������Ϣ
    function GetShopOrderByNO(var nData:string):boolean;
    //���ݶ����Ż�ȡ������Ϣ
    function EditShopOrderInfo(var nData:string):Boolean;
    //�޸Ķ�����Ϣ

    //-------------------��Web�̳���DL�����ѯ----------------------------------
    function GetOrderList(var nData:string):Boolean;
    //��ȡ���۶����б�
    function GetPurchaseList(var nData:string):Boolean;
    //��ȡ�ɹ������б�
    function VerifyPrintCode(var nData: string): Boolean;
    //��֤������Ϣ
    function GetWaitingForloading(var nData:string):Boolean;
    //������װ��ѯ
  public
    constructor Create; override;
    destructor destroy; override;
    //new free

    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
  end;

implementation
uses
  wechat_soap;
  
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TBusWorkerBusinessWebchat, 'Webƽ̨ҵ��' , nEvent);
end;

constructor TBusWorkerBusinessWebchat.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TBusWorkerBusinessWebchat.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

class function TBusWorkerBusinessWebchat.FunctionName: string;
begin
  Result := sBus_BusinessWebchat;
end;

function TBusWorkerBusinessWebchat.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessWebchat;
  end;
end;

//Desc: ��¼nEvent��־
procedure TBusWorkerBusinessWebchat.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TBusWorkerBusinessWebchat, 'Webƽ̨ҵ��' , nEvent);
end;

{
//�������
<?xml version="1.0" encoding="utf-8"?>
<Head>
  <Command>1</Command>
  <Data>����</Data>
  <ExtParam>���Ӳ���</ExtParam>
  <RemoteUL>��������UL</RemoteUL>
</Head>

//��������
<?xml version="1.0" encoding="utf-8"?>
<DATA>
  <Items>
    <Item>
      .....
    </Item>
  </Items>
  <EXMG> ---�����������ɶ���
     < Item>
         < MsgResult> Y</ MsgResult > ---��Ϣ���ͣ�Y�ɹ���Nʧ�ܵ�
         < MsgCommand> 1</ MsgCommand >----��Ϣ����
		     < MsgTxt>����ʧ�ܣ�ָ����������Ч</ MsgTxt > ---��������
     < / Item >
  </EXMG>
</DATA>
}

function TBusWorkerBusinessWebchat.UnPackIn(var nData: string): Boolean;
var nNode, nTmp: TXmlNode;
begin
  Result := False;
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

  nTmp := nNode.FindNode('ExtParam');
  if Assigned(nTmp) then FIn.FExtParam := nTmp.ValueAsString;
end;

procedure TBusWorkerBusinessWebchat.BuildDefaultXMLPack;
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

function TBusWorkerBusinessWebchat.DoWork(var nData: string): Boolean;
begin
  UnPackIn(nData);

  case FIn.FCommand of
    cBC_WebChat_SendEventMsg     :Result := SendEventMsg(nData);                //΢��ƽ̨�ӿڣ�����ģ����Ϣ
    cBC_WebChat_GetCustomerInfo  :Result := GetCustomerInfo(nData);             //΢��ƽ̨�ӿڣ���ȡ�̳��˻�ע����Ϣ
    cBC_WebChat_EditShopCustom   :Result := EditShopCustom(nData);              //΢��ƽ̨�ӿڣ������̳��û�

    cBC_WebChat_GetShopOrdersByID:Result := GetShopOrdersByID(nData);           //΢��ƽ̨�ӿڣ�ͨ��˾�����֤�Ż�ȡ�̳Ƕ�����Ϣ
    cBC_WebChat_GetShopOrderByNO :Result := GetShopOrderByNO(nData);            //΢��ƽ̨�ӿڣ�ͨ����ά���ȡ�̳Ƕ�����Ϣ
    cBC_WebChat_EditShopOrderInfo:Result := EditShopOrderInfo(nData);           //΢��ƽ̨�ӿڣ��޸��̳Ƕ�����Ϣ

    cBC_WebChat_GetOrderList     :Result := GetOrderList(nData);                //΢��ƽ̨�ӿڣ���ȡ���۶����б�
    cBC_WebChat_GetPurchaseList  :Result := GetPurchaseList(nData);             //΢��ƽ̨�ӿڣ���ȡ�ɹ������б�
    cBC_WebChat_VerifPrintCode   :Result := VerifyPrintCode(nData);             //΢��ƽ̨�ӿڣ���ȡ��α����Ϣ
    cBC_WebChat_WaitingForloading:Result := GetWaitingForloading(nData);        //΢��ƽ̨�ӿڣ���ȡ�Ŷ���Ϣ
   else
    begin
      Result := False;
      nData := '��Ч��ָ�����(Invalid Command).';
    end;
  end;

  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;
end;

//������Ϣ
function TBusWorkerBusinessWebchat.SendEventMsg(var nData:string):boolean;
var
  nXmlStr:string;
  nService:ReviceWS;
  nResponse:string;
  nObj:TWebResponse_send_event_msg;
begin
  nXmlStr := PackerDecodeStr(fin.FData);
  nObj := TWebResponse_send_event_msg.Create;
  nService := GetReviceWS(True, gSysParam.FWebSvrURL);
  try
    WriteLog('TBusWorkerBusinessWebchat.Send_Event_Msg request:'+#13+nXmlStr);
    nResponse := nService.mainfuncs('send_event_msg',nXmlStr);
    //nResponse := UTF8Decode(nResponse);
    WriteLog('TBusWorkerBusinessWebchat.Send_Event_Msg response:'+#13+nResponse);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    nObj.FPacker := FPacker;
    Result := nObj.ParseWebResponse(nResponse);
    if not Result then
    begin
      nData := nObj.FErrmsg;
      FOut.FBase.FErrDesc := nObj.FErrmsg;
      Exit;
    end;
  finally
    nObj.Free;
    nService := nil;
  end;  
end;

//��ȡ�ͻ�ע����Ϣ
function TBusWorkerBusinessWebchat.GetCustomerInfo(var nData:string):boolean;
var
  nXmlStr:string;
  nService:ReviceWS;
  nResponse:string;
  nObj:TWebResponse_CustomerInfo;
  function BuildResData:string;
  var
    i:Integer;
    nStr:string;
    nList:TStringList;
  begin
    nList := TStringList.Create;
    try
      for i := Low(nObj.items) to High(nObj.items) do
      begin
        nStr := 'phone=%s,Bindcustomerid=%s,Namepinyin=%s,Email=%s';
        nStr := Format(nStr,[nObj.items[i].Fphone, nObj.items[i].FBindcustomerid,
          nObj.items[i].FNamepinyin, nObj.items[i].FEmail]);
        //nStr := StringReplace(nStr, '\n', #13#10, [rfReplaceAll]);
        nlist.Add(nStr);
      end;
      Result := PackerEncodeStr(nlist.Text);
    finally
      nList.Free;
    end;
  end;
begin
  nXmlStr := PackerDecodeStr(fin.FData);
  nObj := TWebResponse_CustomerInfo.Create;
  nService := GetReviceWS(True, gSysParam.FWebSvrURL);
  try
    WriteLog('TBusWorkerBusinessWebchat.GetCustomerInfo request='+nXmlStr);
    nResponse := nService.mainfuncs('getCustomerInfo',nXmlStr);
    nResponse := UTF8Decode(nResponse);
    WriteLog('TBusWorkerBusinessWebchat.GetCustomerInfo response='+nResponse);
    FPacker.XMLBuilder.Clear;
    FPacker.XMLBuilder.ReadFromString(nResponse);
    nObj.FPacker := FPacker;
    Result := nObj.ParseWebResponse(nResponse);
    if not Result then
    begin
      nData := nObj.FErrmsg;
      FOut.FBase.FErrDesc := nObj.FErrmsg;
      Exit;
    end;
    nData := BuildResData;
    FOut.FData := nData;
  finally
    nObj.Free;
    nService := nil;
  end;  
end;

//�����̳��û�
function TBusWorkerBusinessWebchat.EditShopCustom(var nData:string):boolean;
var
  nXmlStr:string;
  nService:ReviceWS;
  nResponse:string;
  nObj:TWebResponse_edit_shopclients;
begin
  Result := False;
  try
    nXmlStr := PackerDecodeStr(fin.FData);
    nObj := TWebResponse_edit_shopclients.Create;
    nService := GetReviceWS(True, gSysParam.FWebSvrURL);
    try
      WriteLog('TBusWorkerBusinessWebchat.Edit_ShopClients request='+nXmlStr);
      nResponse := nService.mainfuncs('edit_shopclients',nXmlStr);
      nResponse := UTF8Decode(nResponse);
      WriteLog('TBusWorkerBusinessWebchat.Edit_ShopClients response='+nResponse);
      FPacker.XMLBuilder.Clear;
      FPacker.XMLBuilder.ReadFromString(nResponse);
      nObj.FPacker := FPacker;
      Result := nObj.ParseWebResponse(nResponse);
      if not Result then
      begin
        nData := nObj.FErrmsg;
        FOut.FBase.FErrDesc := nObj.FErrmsg;
        Exit;
      end;
    finally
      nObj.Free;
      nService := nil;
    end;
  except
    on E:Exception do
    begin
      WriteLog('TBusWorkerBusinessWebchat.Edit_ShopClients exception='+e.Message);
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2016-12-18
//Parm: �ͻ����
//Desc: ��ȡ�����б�,�������µ�ʱʹ��
function TBusWorkerBusinessWebchat.GetOrderList(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
    nIdx:Integer;
begin
  {$IFDEF DEBUG}
  WriteLog('TBusWorkerBusinessWebchat.GetOrderList Request=' + FIn.FData);
  {$ENDIF}

  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
            @nOut, cBC_WebChat_GetOrderList, Trim(FIn.FRemoteUL));
  if (not Result) or (nOut.FData = '') then
  begin
    WriteLog('��ȡ���ö����б�ʧ��.');
    Exit;
  end;

  BuildDefaultXMLPack;
  FListA.Text := PackerDecodeStr(nOut.FData);

  with FPacker.XMLBuilder do
  begin
    FListC.Text := PackerDecodeStr(FListA[0]);
    with Root.NodeNew('head'), FListC do
    begin
      NodeNew('CusId').ValueAsString := Values['CusID'];
      NodeNew('CusName').ValueAsString := Values['CusName'];
    end;

    with Root.NodeNew('Items') do
    begin
      for nIdx := 0 to FListA.Count - 1 do
      begin
        FListB.Clear;
        FListB.Text := PackerDecodeStr(FListA[nIdx]);
        if Length(FListB.Text) < 1 then Continue;

        with NodeNew('Item'), FListB do
        begin
          NodeNew('SetDate').ValueAsString    := Values['ZKDate'];
          NodeNew('BillNumber').ValueAsString := Values['ZhiKa'];
          NodeNew('StockNo').ValueAsString    := Values['StockNo'];
          NodeNew('StockName').ValueAsString  := Values['StockName'];
          NodeNew('MaxNumber').ValueAsString  := Values['MaxNumber'];
          NodeNew('SaleArea').ValueAsString   := Values['SaleArea'];
        end;
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

  {$IFDEF DEBUG}
  WriteLog('TBusWorkerBusinessWebchat.GetOrderList Response=' + nData);
  {$ENDIF}
end;

//��ȡ�ɹ���ͬ�б�
function TBusWorkerBusinessWebchat.GetPurchaseList(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
    nIdx: Integer;
begin
  {$IFDEF DEBUG}
  WriteLog('TBusWorkerBusinessWebchat.GetPurchaseList Request=' + FIn.FData);
  {$ENDIF}

  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
              @nOut, cBC_WebChat_GetPurchaseList, Trim(FIn.FRemoteUL));

  if (not Result) or (nOut.FData = '') then
  begin
    WriteLog('��ȡ�ɹ������б�ʧ��.');
    Exit;
  end;

  BuildDefaultXMLPack;
  FListA.Text := PackerDecodeStr(nOut.FData);

  with FPacker.XMLBuilder do
  begin
    FListC.Text := PackerDecodeStr(FListA[0]);
    with Root.NodeNew('head'), FListC do
    begin
      NodeNew('ProvId').ValueAsString := Values['ProvID'];
      NodeNew('ProvName').ValueAsString := Values['ProvName'];
    end;

    with Root.NodeNew('Items') do
    begin
      for nIdx := 0 to FListA.Count - 1 do
      begin
        FListB.Clear;
        FListB.Text := PackerDecodeStr(FListA[nIdx]);
        if Length(FListB.Text) < 1 then Continue;

        with NodeNew('Item'), FListB do
        begin
          NodeNew('SetDate').ValueAsString    := Values['ZKDate'];
          NodeNew('BillNumber').ValueAsString := Values['ZhiKa'];
          NodeNew('StockNo').ValueAsString    := Values['StockNo'];
          NodeNew('StockName').ValueAsString  := Values['StockName'];
          NodeNew('MaxNumber').ValueAsString  := Values['MaxNumber'];
        end;
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

  {$IFDEF DEBUG}
  WriteLog('TBusWorkerBusinessWebchat.GetPurchaseList Response=' + nData);
  {$ENDIF}
end;

//------------------------------------------------------------------------------
//Date: 2016-9-20
//Parm: ��α��
//Desc: ��α���ѯ
function TBusWorkerBusinessWebchat.VerifyPrintCode(var nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  {$IFDEF DEBUG}
  WriteLog('TBusWorkerBusinessWebchat.VerifyPrintCode Request=' + FIn.FData);
  {$ENDIF}

  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
            @nOut, cBC_WebChat_VerifPrintCode, Trim(FIn.FRemoteUL));
  //xxxxxx

  if (not Result) or (nOut.FData = '') then
  begin
    WriteLog('��ȡ��α����Ϣʧ��.');
    Exit;
  end;

  BuildDefaultXMLPack;
  //init

  FListA.Clear;
  FListA.Text := PackerDecodeStr(nOut.FData);
  with FPacker.XMLBuilder do
  begin
    with Root.NodeNew('Items') do
    begin
      with NodeNew('Item'), FListA do
      begin
        NodeNew('ID').ValueAsString := Values['ID'];
        NodeNew('CusID').ValueAsString := Values['CusID'];
        NodeNew('CusName').ValueAsString := Values['CusName'];

        NodeNew('Truck').ValueAsString := Values['Truck'];
        NodeNew('StockNo').ValueAsString := Values['StockNO'];
        NodeNew('StockName').ValueAsString := Values['StockName'];

        NodeNew('BILL').ValueAsString := Values['ID'];
        NodeNew('PROJECT').ValueAsString := Values['Project'];
        NodeNew('AREA').ValueAsString := Values['Area'];
        NodeNew('WORKADDR').ValueAsString := Values['WorkAddr'];
        NodeNew('TRANSNAME').ValueAsString := Values['TransName'];
        NodeNew('HYDAN').ValueAsString := Values['HYDan'];
        NodeNew('LVALUE').ValueAsString := Values['Value'];
        NodeNew('OUTDATE').ValueAsString := Values['OutFact'];
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
  
  {$IFDEF DEBUG}
  WriteLog('TBusWorkerBusinessWebchat.VerifyPrintCode Response=' + nData);
  {$ENDIF}
end;

//------------------------------------------------------------------------------
//Date: 2016-9-20
//Parm: ����
//Desc: ������װ��ѯ
function TBusWorkerBusinessWebchat.GetWaitingForloading(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
    nItems: TQueueListItems;
    nIdx: Integer;
begin
  Result := CallRemoteWorker(sCLI_BusinessCommand, FIn.FData, FIn.FExtParam,
            @nOut, cBC_WebChat_WaitingForloading, Trim(FIn.FRemoteUL));
  //xxxxxx

  BuildDefaultXMLPack;
  if Result then
  begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('Items') do
      begin
        AnalyseQueueListItems(nOut.FData, nItems);

        for nIdx := Low(nItems) to High(nItems) do
        with NodeNew('Item'), nItems[nIdx] do
        begin
          NodeNew('StockName').ValueAsString := FStockName;
          NodeNew('LineCount').ValueAsString := IntToStr(FLineCount);
          NodeNew('TruckCount').ValueAsString := IntToStr(FTruckCount);
        end;  
      end;

      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := 'ҵ��ִ�гɹ�';
        NodeNew('MsgResult').ValueAsString  := sFlag_Yes;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  end
  else begin
    with FPacker.XMLBuilder do
    begin
      with Root.NodeNew('EXMG') do
      begin
        NodeNew('MsgTxt').ValueAsString     := nOut.FData;
        NodeNew('MsgResult').ValueAsString  := sFlag_No;
        NodeNew('MsgCommand').ValueAsString := IntToStr(FIn.FCommand);
      end;
    end;
  end;  
  nData := FPacker.XMLBuilder.WriteToString;
end;

//Date: 2017/6/13
//Parm: ˾�����֤��
//Desc: ��ȡ˾�������̳Ƕ����б�
function TBusWorkerBusinessWebchat.GetShopOrdersByID(var nData:string):boolean;
var nIdx: Integer;
    nService:ReviceWS;
    nXmlStr, nResponse:string;
    nObj:TWebResponse_get_shoporders;
begin
  nXmlStr := PackerDecodeStr(FIn.FData);

  nObj := TWebResponse_get_shoporders.Create;
  nService := GetReviceWS(True, gSysParam.FWebSvrURL);
  try
    WriteLog('TBusWorkerBusinessWebchat.Get_Shoporders request:'+#13+nXmlStr);
    nResponse := nService.mainfuncs('get_shoporders',nXmlStr);
    nResponse := UTF8Decode(nResponse);
    WriteLog('TBusWorkerBusinessWebchat.Get_Shoporders response:'+#13+nResponse);

    nObj.FPacker := FPacker;
    //ָ�������
    Result := nObj.ParseWebResponse(nResponse);
    if not Result then
    begin
      nData := nObj.FErrmsg;
      FOut.FBase.FErrDesc := nObj.FErrmsg;
      Exit;
    end;

    FListA.Clear;
    for nIdx := Low(nObj.Items) to High(nObj.Items) do
    with nObj.Items[nIdx], FListB do
    begin
      Clear;
      Values['WebID']    := FOrder_id;                                          //Web�̳Ƕ���ΨһID
      Values['OrderType']:= FOrderType;                                         //Web�̳Ƕ�������
      Values['OrderNO']  := Ffac_order_no;                                      //���չ���������

      Values['WebShopID'] := FOrdernumber;                                      //Web�̳��������
      Values['StockNo']   := FGoodsID;                                          //���ϱ��
      Values['StockType'] := FGoodstype;                                        //��������
      Values['StockName'] := FGoodsname;                                        //��������

      Values['Truck'] := Ftracknumber;                                          //���ƺ���
      Values['Value']  := FData;                                                //Ԥ������

      FListA.Add(PackerEncodeStr(FListB.Text));
    end;

    FOut.FData := PackerEncodeStr(FListA.Text);
  finally
    nObj.Free;
    nService := nil;
  end;  
end;

//���ݶ����Ż�ȡ������Ϣ
function TBusWorkerBusinessWebchat.GetShopOrderByNO(var nData:string):boolean;
var nIdx: Integer;
    nService:ReviceWS;
    nXmlStr, nResponse:string;
    nObj:TWebResponse_get_shoporders;
begin
  nXmlStr := PackerDecodeStr(fIn.FData);

  nObj := TWebResponse_get_shoporders.Create;
  nService := GetReviceWS(True, gSysParam.FWebSvrURL);
  try
    WriteLog('TBusWorkerBusinessWebchat.GetShopOrderByNO request:'+#13+nXmlStr);
    nResponse := nService.mainfuncs('get_shoporderByNO',nXmlStr);
    //nResponse := UTF8Decode(nResponse);
    WriteLog('TBusWorkerBusinessWebchat.GetShopOrderByNO response:'+#13+nResponse);

    nObj.FPacker := FPacker;
    //ָ�������
    Result := nObj.ParseWebResponse(nResponse);
    if not Result then
    begin
      nData := nObj.FErrmsg;
      FOut.FBase.FErrDesc := nObj.FErrmsg;
      Exit;
    end;

    FListA.Clear;
    for nIdx := Low(nObj.Items) to High(nObj.Items) do
    with nObj.Items[nIdx], FListB do
    begin
      Clear;
      Values['WebID']    := FOrder_id;                                          //Web�̳Ƕ���ΨһID
      Values['OrderType']:= FOrderType;                                         //Web�̳Ƕ�������
      Values['OrderNO']  := Ffac_order_no;                                      //���չ���������

      Values['WebShopID'] := FOrdernumber;                                      //Web�̳��������
      Values['StockNo']   := FGoodsID;                                          //���ϱ��
      Values['StockType'] := FGoodstype;                                        //��������
      Values['StockName'] := FGoodsname;                                        //��������

      Values['Truck'] := Ftracknumber;                                          //���ƺ���
      Values['Value']  := FData;                                                //Ԥ������

      FListA.Add(PackerEncodeStr(FListB.Text));
    end;

    nData := PackerEncodeStr(FListA.Text);
    FOut.FData := '';
  finally
    nObj.Free;
    nService := nil;
  end;  
end;

//�޸Ķ���״̬
function TBusWorkerBusinessWebchat.EditShopOrderInfo(var nData:string):Boolean;
var
  nXmlStr:string;
  nService:ReviceWS;
  nResponse:string;
  nObj:TWebResponse_complete_shoporders;
begin
  nXmlStr := PackerDecodeStr(fin.FData);
  nObj := TWebResponse_complete_shoporders.Create;
  nService := GetReviceWS(True, gSysParam.FWebSvrURL);
  try
    WriteLog('TBusWorkerBusinessWebchat.complete_shoporders request'+#13+nXmlStr);
    nResponse := nService.mainfuncs('complete_shoporders',nXmlStr);
    //nResponse := UTF8Decode(nResponse);
    WriteLog('TBusWorkerBusinessWebchat.complete_shoporders response'+#13+nResponse);

    nObj.FPacker := FPacker;
    Result := nObj.ParseWebResponse(nResponse);
    if not Result then
    begin
      nData := nObj.FErrmsg;
      FOut.FBase.FErrDesc := nObj.FErrmsg;
      Exit;
    end;
  finally
    nObj.Free;
    nService := nil;
  end;  
end;


{ TWebResponseBaseInfo }
function TWebResponseBaseInfo.ParseWebResponse(var nData: string): Boolean;
var nNode, nTmp: TXmlNode;
begin
  Result := False;
  FPacker.XMLBuilder.Clear;
  FPacker.XMLBuilder.ReadFromString(nData);
  nNode := FPacker.XMLBuilder.Root.FindNode('Head');
  if not (Assigned(nNode) and Assigned(nNode.FindNode('errcode'))) then
  begin
    FErrmsg := '��Ч�����ڵ�(Head.errcode Null).';
    Exit;
  end;
  if not Assigned(nNode.FindNode('errmsg')) then
  begin
    FErrmsg := '��Ч�����ڵ�(Head.errmsg Null).';
    Exit;
  end;
  nTmp := nNode.FindNode('errcode');
  FErrcode := StrToIntDef(nTmp.ValueAsString, 0);

  nTmp := nNode.FindNode('errmsg');
  FErrmsg:= nTmp.ValueAsString;
  Result := FErrcode=0;  
end;

{ TWebResponse_CustomerInfo }
function TWebResponse_CustomerInfo.ParseWebResponse(
  var nData: string): Boolean;
var nNode, nTmp,nNodeTmp: TXmlNode;
  nIdx,nNodeCount:Integer;  
begin
  Result := inherited ParseWebResponse(nData);
  if Result then
  begin
    nNode := FPacker.XMLBuilder.Root.FindNode('Items');
    if not Assigned(nNode) then
    begin
      FErrmsg := '��Ч�����ڵ�(Items Null).';
      Result := False;
      Exit;
    end;
    if not (Assigned(nNode) and Assigned(nNode.FindNode('Item'))) then
    begin
      FErrmsg := '��Ч�����ڵ�(Items.Item Null).';
      Result := False;
      Exit;
    end;
    
    nNodeCount :=nNode.NodeCount;
    SetLength(items,nNodeCount);

    for nIdx := 0 to nNodeCount-1 do
    begin
      nNodeTmp := nNode.Nodes[nIdx];

      nTmp := nNodeTmp.FindNode('phone');
      items[nIdx].Fphone := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('Bindcustomerid');
      items[nIdx].FBindcustomerid := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('Namepinyin');
      items[nIdx].FNamepinyin := nTmp.ValueAsString;

      nTmp := nNodeTmp.FindNode('Email');
      if Assigned(nTmp) then
      begin
        items[nIdx].FEmail := nTmp.ValueAsString;
      end;
    end;
  end;  
end;

{ TWebResponse_get_shoporders }
function TWebResponse_get_shoporders.ParseWebResponse(
  var nData: string): Boolean;
var nNode, nTmp,nNodeTmp: TXmlNode;
  nIdx,nNodeCount:Integer;  
begin
  Result := inherited ParseWebResponse(nData);
  if Result then
  begin
    nNode := FPacker.XMLBuilder.Root.FindNode('Items');
    if not Assigned(nNode) then
    begin
      FErrmsg := '��Ч�����ڵ�(Items Null).';
      Result := False;
      Exit;
    end;
    if not (Assigned(nNode) and Assigned(nNode.FindNode('Item'))) then
    begin
      FErrmsg := '��Ч�����ڵ�(Items.Item Null).';
      Result := False;
      Exit;
    end;

    nNodeCount :=nNode.NodeCount;
    SetLength(items,nNodeCount);

    for nIdx := 0 to nNodeCount-1 do
    begin
      nNodeTmp := nNode.Nodes[nIdx];

      nTmp := nNodeTmp.FindNode('order_id');
      items[nIdx].FOrder_id := nTmp.ValueAsString;
      //Web�̳Ƕ���ID

      nTmp := nNodeTmp.FindNode('fac_order_no');
      items[nIdx].Ffac_order_no := nTmp.ValueAsString;
      //�������ն���ID

      nTmp := nNodeTmp.FindNode('order_type');
      if Assigned(nTmp) then
        items[nIdx].FOrderType := nTmp.ValueAsString;
      //��ֹδ��Ӹ��ֶ�
      //��������

      nTmp := nNodeTmp.FindNode('ordernumber');
      items[nIdx].FOrdernumber := nTmp.ValueAsString;
      //Web�̳��������

      nTmp := nNodeTmp.FindNode('goodsID');
      items[nIdx].FGoodsID := nTmp.ValueAsString;
      //���ϱ��

      nTmp := nNodeTmp.FindNode('goodsname');
      items[nIdx].FGoodsname := UTF8Decode(nTmp.ValueAsString);
      //��������

      nTmp := nNodeTmp.FindNode('tracknumber');
      items[nIdx].Ftracknumber := UTF8Decode(nTmp.ValueAsString);
      //���ƺ�

      nTmp := nNodeTmp.FindNode('data');
      items[nIdx].FData := nTmp.ValueAsString;
      //Ԥ����
    end;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerBusinessWebchat, sPlug_ModuleBus);
end.
