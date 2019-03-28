unit UFrameQueryCard;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameBase, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel;

type
  TfFrameQueryCard = class(TfFrameBase)
    LabelTruck: TcxLabel;
    LabelBill: TcxLabel;
    LabelOrder: TcxLabel;
    LabelStock: TcxLabel;
    LabelTon: TcxLabel;
    LabelNum: TcxLabel;
    LabelHint: TcxLabel;
  private
    { Private declarations }
    FLastCard: string;
    FLastQuery: Int64;
    //�ϴβ�ѯ
    FListA: TStrings;
  public
    { Public declarations }
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    class function FrameID: integer; override;

    procedure QueryCard(const nCard: string);
    //��Ƭ��ѯ
    procedure QueryCardProvide(const nCard: string);
    //��Ƭ��ѯ
    function DealCommand(Sender: TObject; const nCmd: Integer;
      const nParamA: Pointer; const nParamB: Integer): Integer; override;
    {*��������*}
  end;

var
  fFrameQueryCard: TfFrameQueryCard;

implementation

{$R *.dfm}

uses
  ULibFun, USysLoger, UDataModule, UMgrControl, USelfHelpConst, USysDB,
  USysBusiness;

//------------------------------------------------------------------------------
//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameQueryCard, '������ѯ����', nEvent);
end;


class function TfFrameQueryCard.FrameID: Integer;
begin
  Result := cFI_FrameQueryCard;
end;

procedure TfFrameQueryCard.OnCreateFrame;
begin
  FLastCard := '';
  FLastQuery:= 0;
  FListA := TStringList.Create;
end;

procedure TfFrameQueryCard.OnDestroyFrame;
begin
  FListA.Free;
end;

procedure TfFrameQueryCard.QueryCard(const nCard: string);
var nVal: Double;
    nStr,nStock,nBill,nVip,nLine,nPoundQueue,nTruck, nStockFz, nStockList: string;
    nDate: TDateTime;
    nQueueMax: Integer;
begin
  mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  //close screen saver

  if (nCard = FLastCard) and (GetTickCount - FLastQuery < 8 * 1000) then
  begin
    ShowMsg('�벻ҪƵ��ˢ��', sHint);
    Exit;
  end;

  try
    nStr := 'Select * From %s Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, nCard]);

    with FDM.SQLQuery(nStr) do
    begin
      if RecordCount < 1 then
      begin
        LabelHint.Caption := '�ſ�����Ч';
        Exit;
      end;

      nVal := 0;
      First;

      while not Eof do
      begin
        if FieldByName('L_Value').AsFloat > nVal then
        begin
          nBill := FieldByName('L_ID').AsString;
          nVal := FieldByName('L_Value').AsFloat;
        end;

        Next;
      end;

      First;
      while not Eof do
      begin
        if FieldByName('L_ID').AsString = nBill then
          Break;
        Next;
      end;

      nBill  := FieldByName('L_ID').AsString;
      nVip   := FieldByName('L_IsVip').AsString;
      nTruck := FieldByName('L_Truck').AsString;
      nStock := FieldByName('L_StockNo').AsString;

      LabelBill.Caption := '��������: ' + FieldByName('L_ID').AsString;
      LabelOrder.Caption := '�ͻ�����: ' + FieldByName('L_CusName').AsString;
      LabelTruck.Caption := '���ƺ���: ' + FieldByName('L_Truck').AsString;
      LabelStock.Caption := 'Ʒ������: ' + FieldByName('L_StockName').AsString
                             + '(' + FieldByName('L_StockBrand').AsString + ')';
      LabelTon.Caption := '�������: ' + FieldByName('L_Value').AsString + '��'
                             + '(�����ص�:' + FieldByName('L_StockArea').AsString + ')';
    end;

    //--------------------------------------------------------------------------
    nStr := 'Select Count(*) From %s ' +
            'Where Z_StockNo=''%s'' And Z_Valid=''%s'' And Z_VipLine=''%s''';
    nStr := Format(nStr, [sTable_ZTLines, nStock, sFlag_Yes,nVip]);

    with FDM.SQLQuery(nStr) do
    begin
      LabelNum.Caption := '���ŵ���: ' + Fields[0].AsString + '��';
    end;

    //--------------------------------------------------------------------------
    nStr := 'Select T_line,T_InTime,T_Valid From %s ZT ' +
             'Where T_HKBills like ''%%%s%%'' ';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);

    with FDM.SQLQuery(nStr) do
    begin
      if RecordCount < 1 then
      begin
        LabelHint.Caption := '���ĳ�������Ч.';
        Exit;
      end;

      if FieldByName('T_Valid').AsString <> sFlag_Yes then
      begin
        LabelHint.Caption := '���ѳ�ʱ����,�뵽������������������.';
        Exit;
      end;

      nDate := FieldByName('T_InTime').AsDateTime;
      //����ʱ��

      nLine := FieldByName('T_Line').AsString;
      //ͨ����
    end;

    {$IFDEF AutoGetLineGroup}
      {$IFDEF NoPointLine}
      if nLine <> '' then
      begin
        nStr := 'Select Z_Valid,Z_Name From %s Where Z_ID=''%s'' ';
        nStr := Format(nStr, [sTable_ZTLines, nLine]);

        with FDM.SQLQuery(nStr) do
        begin
          if FieldByName('Z_Valid').AsString = 'N' then
          begin
          LabelHint.Caption := '�����ڵ�ͨ���ѹرգ�����ϵ������Ա.';
          Exit;
          end else
          begin
          LabelHint.Caption := 'ϵͳ�����ĳ������볧,�뵽' + FieldByName('Z_Name').AsString + '���.';
          Exit;
          end;
        end;
      end;

      nStockFz := nStock;

      nStr := 'Select D_ParamB From %s Where D_Name=''%s'' and D_Value=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_BatStockGroup, nStock]);

      with FDM.SQLQuery(nStr) do
      begin
        if RecordCount > 0 then
        begin
          nStockFz := Fields[0].AsString;
        end;
      end;

      nStockList := '';

      nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_ParamB=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_BatStockGroup, nStockFz]);

      with FDM.SQLQuery(nStr) do
      begin
        if RecordCount > 0 then
        begin
          FListA.Clear;

          First;

          while not Eof do
          begin
            FListA.Add(Fields[0].AsString);
            Next;
          end;
          nStockList := AdjustListStrFormat2(FListA, '''', True, ',', False);
        end;
      end;

      if nStockList <> '' then
      begin
        nStr := 'Select Count(*) From %s ' +
                'Where Z_StockNo In (%s) And Z_Valid=''%s'' And Z_VipLine=''%s''';
        nStr := Format(nStr, [sTable_ZTLines, nStockList, sFlag_Yes,nVip]);

        with FDM.SQLQuery(nStr) do
        begin
          LabelNum.Caption := '���ŵ���: ' + Fields[0].AsString + '��';
        end;
      end;

      nStr := 'Select D_Value From $DT Where D_Memo = ''$PQ''';
      nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
              MI('$PQ', sFlag_PoundQueue)]);

      with FDM.SQLQuery(nStr) do
      begin
        if FieldByName('D_Value').AsString = 'Y' then
        nPoundQueue := 'Y';
      end;

      nStr := 'Select D_Value From $DT Where D_Memo = ''$DQ''';
      nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
              MI('$DQ', sFlag_DelayQueue)]);

      with FDM.SQLQuery(nStr) do
      begin
        if nStockList = '' then
        begin
          if  FieldByName('D_Value').AsString = 'Y' then
          begin
            if nPoundQueue <> 'Y' then
            begin
              nStr := 'Select Count(*) From $TB Where T_InFact Is Null And ' +
                      'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_InFact<''$IT'' And T_Vip=''$VIP''';
            end else
            begin
              nStr := ' Select Count(*) From $TB left join Sys_PoundLog on Sys_PoundLog.P_Bill=S_ZTTrucks.T_Bill ' +
                      ' Where T_InFact Is Null And ' +
                      ' T_Valid=''$Yes'' And T_StockNo=''$SN'' And P_PDate<''$IT'' And T_Vip=''$VIP''';
            end;
          end else
          begin
            nStr := 'Select Count(*) From $TB Where T_InFact Is Null And ' +
                    'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_InTime<''$IT'' And T_Vip=''$VIP''';
          end;

          nStr := MacroValue(nStr, [MI('$TB', sTable_ZTTrucks),
                MI('$Yes', sFlag_Yes), MI('$SN', nStock),
                MI('$IT', DateTime2Str(nDate)),MI('$VIP', nVip)]);
        end
        else
        begin
          if  FieldByName('D_Value').AsString = 'Y' then
          begin
            if nPoundQueue <> 'Y' then
            begin
              nStr := 'Select Count(*) From $TB Where T_InFact Is Null And ' +
                      'T_Valid=''$Yes'' And T_StockNo In ($SN) And T_InFact<''$IT'' And T_Vip=''$VIP''';
            end else
            begin
              nStr := ' Select Count(*) From $TB left join Sys_PoundLog on Sys_PoundLog.P_Bill=S_ZTTrucks.T_Bill ' +
                      ' Where T_InFact Is Null And ' +
                      ' T_Valid=''$Yes'' And T_StockNo In ($SN) And P_PDate<''$IT'' And T_Vip=''$VIP''';
            end;
          end else
          begin
            nStr := 'Select Count(*) From $TB Where T_InFact Is Null And ' +
                    'T_Valid=''$Yes'' And T_StockNo In ($SN) And T_InTime<''$IT'' And T_Vip=''$VIP''';
          end;

          nStr := MacroValue(nStr, [MI('$TB', sTable_ZTTrucks),
                MI('$Yes', sFlag_Yes), MI('$SN', nStockList),
                MI('$IT', DateTime2Str(nDate)),MI('$VIP', nVip)]);
        end;
      end;
      //xxxxx

      with FDM.SQLQuery(nStr) do
      begin
        if Fields[0].AsInteger < 1 then
        begin
          nStr := '�����ŵ�����,���ע��������׼������.';
          LabelHint.Caption := nStr;
        end else
        begin
          nStr := '��ǰ�滹�С� %d �������ȴ�����';
          LabelHint.Caption := Format(nStr, [Fields[0].AsInteger]);
        end;
      end;

      FLastQuery := GetTickCount;
      FLastCard := nCard;
      //�ѳɹ�����
      {$ELSE}
      if nLine = '' then
      begin
        LabelHint.Caption := '���ĳ���δ��ӣ�����ϵ������Ա.';
        Exit;
      end;

      nStr := 'Select Z_Valid,Z_Name,Z_QueueMax From %s Where Z_ID=''%s'' ';
      nStr := Format(nStr, [sTable_ZTLines, nLine]);

      with FDM.SQLQuery(nStr) do
      begin
        if FieldByName('Z_Valid').AsString = 'N' then
        begin
          LabelHint.Caption := '�����ڵ�ͨ���ѹرգ�����ϵ������Ա.';
          Exit;
        end else
        begin
          nQueueMax := FieldByName('Z_QueueMax').AsInteger;
        end;
      end;

      nStr := 'Select D_Value From $DT Where D_Memo = ''$PQ''';
      nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
              MI('$PQ', sFlag_PoundQueue)]);

      with FDM.SQLQuery(nStr) do
      begin
        if FieldByName('D_Value').AsString = 'Y' then
        nPoundQueue := 'Y';
      end;

      nStr := 'Select D_Value From $DT Where D_Memo = ''$DQ''';
      nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
              MI('$DQ', sFlag_DelayQueue)]);

      with FDM.SQLQuery(nStr) do
      begin
      if  FieldByName('D_Value').AsString = 'Y' then
        begin
          if nPoundQueue <> 'Y' then
          begin
            nStr := 'Select Count(*) From $TB Where T_InFact Is Null And ' +
                    'T_Valid=''$Yes'' And T_Line=''$SN'' And T_InFact<''$IT'' And T_Vip=''$VIP''';
          end else
          begin
            nStr := ' Select Count(*) From $TB left join Sys_PoundLog on Sys_PoundLog.P_Bill=S_ZTTrucks.T_Bill ' +
                    ' Where T_InFact Is Null And ' +
                    ' T_Valid=''$Yes'' And T_Line=''$SN'' And P_PDate<''$IT'' And T_Vip=''$VIP''';
          end;
        end else
        begin
          nStr := 'Select Count(*) From $TB Where T_InFact Is Null And ' +
                  'T_Valid=''$Yes'' And T_Line=''$SN'' And T_InTime<''$IT'' And T_Vip=''$VIP''';
        end;

        nStr := MacroValue(nStr, [MI('$TB', sTable_ZTTrucks),
              MI('$Yes', sFlag_Yes), MI('$SN', nLine),
              MI('$IT', DateTime2Str(nDate)),MI('$VIP', nVip)]);
      end;
      //xxxxx

      with FDM.SQLQuery(nStr) do
      begin
        if Fields[0].AsInteger < 1 then
        begin
          nStr := '�����ŵ�����,���ע��������׼������.';
          LabelHint.Caption := nStr;
        end else
        begin
          nStr := '������ͨ��ǰ�滹�С� %d �������ȴ�����';
          LabelHint.Caption := Format(nStr, [Fields[0].AsInteger]);
        end;
      end;

      FLastQuery := GetTickCount;
      FLastCard := nCard;
      //�ѳɹ�����
      {$ENDIF}
    {$ELSE}
    if nLine <> '' then
    begin
      nStr := 'Select Z_Valid,Z_Name From %s Where Z_ID=''%s'' ';
      nStr := Format(nStr, [sTable_ZTLines, nLine]);

      with FDM.SQLQuery(nStr) do
      begin
        if FieldByName('Z_Valid').AsString = 'N' then
        begin
        LabelHint.Caption := '�����ڵ�ͨ���ѹرգ�����ϵ������Ա.';
        Exit;
        end else
        begin
        LabelHint.Caption := 'ϵͳ�����ĳ������볧,�뵽' + FieldByName('Z_Name').AsString + '���.';
        Exit;
        end;
      end;
    end;

    nStr := 'Select D_Value From $DT Where D_Memo = ''$PQ''';
    nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
            MI('$PQ', sFlag_PoundQueue)]);

    with FDM.SQLQuery(nStr) do
    begin
      if FieldByName('D_Value').AsString = 'Y' then
      nPoundQueue := 'Y';
    end;

    nStr := 'Select D_Value From $DT Where D_Memo = ''$DQ''';
    nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
            MI('$DQ', sFlag_DelayQueue)]);

    with FDM.SQLQuery(nStr) do
    begin
    if  FieldByName('D_Value').AsString = 'Y' then
      begin
        if nPoundQueue <> 'Y' then
        begin
          nStr := 'Select Count(*) From $TB Where T_InFact Is Null And ' +
                  'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_InFact<''$IT'' And T_Vip=''$VIP''';
        end else
        begin
          nStr := ' Select Count(*) From $TB left join Sys_PoundLog on Sys_PoundLog.P_Bill=S_ZTTrucks.T_Bill ' +
                  ' Where T_InFact Is Null And ' +
                  ' T_Valid=''$Yes'' And T_StockNo=''$SN'' And P_PDate<''$IT'' And T_Vip=''$VIP''';
        end;
      end else
      begin
        nStr := 'Select Count(*) From $TB Where T_InFact Is Null And ' +
                'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_InTime<''$IT'' And T_Vip=''$VIP''';
      end;

      nStr := MacroValue(nStr, [MI('$TB', sTable_ZTTrucks),
            MI('$Yes', sFlag_Yes), MI('$SN', nStock),
            MI('$IT', DateTime2Str(nDate)),MI('$VIP', nVip)]);
    end;
    //xxxxx

    with FDM.SQLQuery(nStr) do
    begin
      if Fields[0].AsInteger < 1 then
      begin
        nStr := '�����ŵ�����,���ע��������׼������.';
        LabelHint.Caption := nStr;
      end else
      begin
        nStr := '��ǰ�滹�С� %d �������ȴ�����';
        LabelHint.Caption := Format(nStr, [Fields[0].AsInteger]);
      end;
    end;

    FLastQuery := GetTickCount;
    FLastCard := nCard;
    //�ѳɹ�����
    {$ENDIF}
  except
    on E: Exception do
    begin
      ShowMsg('��ѯʧ��', sHint);
      WriteLog(E.Message);
    end;
  end;

  FDM.ADOConn.Connected := False;
end;

procedure TfFrameQueryCard.QueryCardProvide(const nCard: string);
var nStr: string;
begin
  mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  //close screen saver

  if (nCard = FLastCard) and (GetTickCount - FLastQuery < 8 * 1000) then
  begin
    ShowMsg('�벻ҪƵ��ˢ��', sHint);
    Exit;
  end;

  try
    nStr := 'Select * From %s Where P_Card=''%s''';
    nStr := Format(nStr, [sTable_CardProvide, nCard]);

    with FDM.SQLQuery(nStr) do
    begin
      if RecordCount < 1 then
      begin
        LabelHint.Caption := '�ſ�����Ч';
        Exit;
      end;

      LabelBill.Caption := '�ɹ�����: ' + FieldByName('P_Order').AsString;
      LabelOrder.Caption := '�ͻ�����: ' + FieldByName('P_CusName').AsString;
      LabelTruck.Caption := '���ƺ���: ' + FieldByName('P_Truck').AsString;
      LabelStock.Caption := '��������: ' + FieldByName('P_MName').AsString;
      LabelTon.Caption := '�ɹ�����: ' + '��ж��Ϊ׼';
      LabelNum.Caption := '�������: ' + FieldByName('P_Origin').AsString;
    end;

    LabelHint.Caption := '�쿨�ɹ�,�����';

    FLastQuery := GetTickCount;
    FLastCard := nCard;
    //�ѳɹ�����
  except
    on E: Exception do
    begin
      ShowMsg('��ѯʧ��', sHint);
      WriteLog(E.Message);
    end;
  end;

  FDM.ADOConn.Connected := False;
end;

function TfFrameQueryCard.DealCommand(Sender: TObject; const nCmd: Integer;
  const nParamA: Pointer; const nParamB: Integer): Integer;
var nCardType, nCard: string;
begin
  Result := 0;
  if (nCmd = cCmd_QueryCard) And Assigned(nParamA) then
  begin
    nCard := PFrameCommandParam(nParamA).FParamA;
    nCardType := GetCardUsed(nCard);
    
    if nCardType = sFlag_ShipPro then
      QueryCardProvide(nCard)
    else
      QueryCard(nCard);
  end else

  if nCmd = cCmd_FrameQuit then
  begin
    Close;
  end;    
end;    

initialization
  gControlManager.RegCtrl(TfFrameQueryCard, TfFrameQueryCard.FrameID);
end.
