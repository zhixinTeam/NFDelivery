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
    //上次查询
    FListA: TStrings;
  public
    { Public declarations }
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    class function FrameID: integer; override;

    procedure QueryCard(const nCard: string);
    //卡片查询
    procedure QueryCardProvide(const nCard: string);
    //卡片查询
    function DealCommand(Sender: TObject; const nCmd: Integer;
      const nParamA: Pointer; const nParamB: Integer): Integer; override;
    {*处理命令*}
  end;

var
  fFrameQueryCard: TfFrameQueryCard;

implementation

{$R *.dfm}

uses
  ULibFun, USysLoger, UDataModule, UMgrControl, USelfHelpConst, USysDB,
  USysBusiness;

//------------------------------------------------------------------------------
//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameQueryCard, '自助查询窗体', nEvent);
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
    ShowMsg('请不要频繁刷卡', sHint);
    Exit;
  end;

  try
    nStr := 'Select * From %s Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, nCard]);

    with FDM.SQLQuery(nStr) do
    begin
      if RecordCount < 1 then
      begin
        LabelHint.Caption := '磁卡号无效';
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

      LabelBill.Caption := '交货单号: ' + FieldByName('L_ID').AsString;
      LabelOrder.Caption := '客户名称: ' + FieldByName('L_CusName').AsString;
      LabelTruck.Caption := '车牌号码: ' + FieldByName('L_Truck').AsString;
      LabelStock.Caption := '品种名称: ' + FieldByName('L_StockName').AsString
                             + '(' + FieldByName('L_StockBrand').AsString + ')';
      LabelTon.Caption := '提货数量: ' + FieldByName('L_Value').AsString + '吨'
                             + '(到货地点:' + FieldByName('L_StockArea').AsString + ')';
    end;

    //--------------------------------------------------------------------------
    nStr := 'Select Count(*) From %s ' +
            'Where Z_StockNo=''%s'' And Z_Valid=''%s'' And Z_VipLine=''%s''';
    nStr := Format(nStr, [sTable_ZTLines, nStock, sFlag_Yes,nVip]);

    with FDM.SQLQuery(nStr) do
    begin
      LabelNum.Caption := '开放道数: ' + Fields[0].AsString + '个';
    end;

    //--------------------------------------------------------------------------
    nStr := 'Select T_line,T_InTime,T_Valid From %s ZT ' +
             'Where T_HKBills like ''%%%s%%'' ';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);

    with FDM.SQLQuery(nStr) do
    begin
      if RecordCount < 1 then
      begin
        LabelHint.Caption := '您的车辆已无效.';
        Exit;
      end;

      if FieldByName('T_Valid').AsString <> sFlag_Yes then
      begin
        LabelHint.Caption := '您已超时出队,请到服务大厅办理入队手续.';
        Exit;
      end;

      nDate := FieldByName('T_InTime').AsDateTime;
      //进队时间

      nLine := FieldByName('T_Line').AsString;
      //通道号
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
          LabelHint.Caption := '您所在的通道已关闭，请联系调度人员.';
          Exit;
          end else
          begin
          LabelHint.Caption := '系统内您的车辆已入厂,请到' + FieldByName('Z_Name').AsString + '提货.';
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
          LabelNum.Caption := '开放道数: ' + Fields[0].AsString + '个';
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
          nStr := '您已排到队首,请关注大屏调度准备进厂.';
          LabelHint.Caption := nStr;
        end else
        begin
          nStr := '您前面还有【 %d 】辆车等待进厂';
          LabelHint.Caption := Format(nStr, [Fields[0].AsInteger]);
        end;
      end;

      FLastQuery := GetTickCount;
      FLastCard := nCard;
      //已成功卡号
      {$ELSE}
      if nLine = '' then
      begin
        LabelHint.Caption := '您的车辆未入队，请联系调度人员.';
        Exit;
      end;

      nStr := 'Select Z_Valid,Z_Name,Z_QueueMax From %s Where Z_ID=''%s'' ';
      nStr := Format(nStr, [sTable_ZTLines, nLine]);

      with FDM.SQLQuery(nStr) do
      begin
        if FieldByName('Z_Valid').AsString = 'N' then
        begin
          LabelHint.Caption := '您所在的通道已关闭，请联系调度人员.';
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
          nStr := '您已排到队首,请关注大屏调度准备进厂.';
          LabelHint.Caption := nStr;
        end else
        begin
          nStr := '您所在通道前面还有【 %d 】辆车等待进厂';
          LabelHint.Caption := Format(nStr, [Fields[0].AsInteger]);
        end;
      end;

      FLastQuery := GetTickCount;
      FLastCard := nCard;
      //已成功卡号
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
        LabelHint.Caption := '您所在的通道已关闭，请联系调度人员.';
        Exit;
        end else
        begin
        LabelHint.Caption := '系统内您的车辆已入厂,请到' + FieldByName('Z_Name').AsString + '提货.';
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
        nStr := '您已排到队首,请关注大屏调度准备进厂.';
        LabelHint.Caption := nStr;
      end else
      begin
        nStr := '您前面还有【 %d 】辆车等待进厂';
        LabelHint.Caption := Format(nStr, [Fields[0].AsInteger]);
      end;
    end;

    FLastQuery := GetTickCount;
    FLastCard := nCard;
    //已成功卡号
    {$ENDIF}
  except
    on E: Exception do
    begin
      ShowMsg('查询失败', sHint);
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
    ShowMsg('请不要频繁刷卡', sHint);
    Exit;
  end;

  try
    nStr := 'Select * From %s Where P_Card=''%s''';
    nStr := Format(nStr, [sTable_CardProvide, nCard]);

    with FDM.SQLQuery(nStr) do
    begin
      if RecordCount < 1 then
      begin
        LabelHint.Caption := '磁卡号无效';
        Exit;
      end;

      LabelBill.Caption := '采购单号: ' + FieldByName('P_Order').AsString;
      LabelOrder.Caption := '客户名称: ' + FieldByName('P_CusName').AsString;
      LabelTruck.Caption := '车牌号码: ' + FieldByName('P_Truck').AsString;
      LabelStock.Caption := '物料名称: ' + FieldByName('P_MName').AsString;
      LabelTon.Caption := '采购数量: ' + '以卸货为准';
      LabelNum.Caption := '矿点名称: ' + FieldByName('P_Origin').AsString;
    end;

    LabelHint.Caption := '办卡成功,请进厂';

    FLastQuery := GetTickCount;
    FLastCard := nCard;
    //已成功卡号
  except
    on E: Exception do
    begin
      ShowMsg('查询失败', sHint);
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
