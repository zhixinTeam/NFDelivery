unit UFramePrintBill;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameBase, ComCtrls, ExtCtrls, Buttons, StdCtrls,
  USelfHelpConst, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxButtonEdit, cxDropDownEdit ;

type

  TfFramePrintBill = class(TfFrameBase)
    Pnl_OrderInfo: TPanel;
    lbl_2: TLabel;
    btnPrint: TSpeedButton;
    edt_TruckNo: TcxComboBox;
    Label1: TLabel;
    EditID: TLabel;
    Label2: TLabel;
    EditCusName: TLabel;
    Label4: TLabel;
    EditValue: TLabel;
    Label3: TLabel;
    EditDone: TLabel;
    SpeedButton1: TSpeedButton;
    Timer1: TTimer;
    procedure btnPrintClick(Sender: TObject);
    procedure edt_TruckNoPropertiesChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FListA, FListB, FListC: TStrings;
  private

  public
    { Public declarations }
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnShowFrame; override;

    class function FrameID: integer; override;
  end;

var
  fFramePrintBill: TfFramePrintBill;

implementation

{$R *.dfm}

uses
    ULibFun, USysLoger, UDataModule, UMgrControl, USysBusiness, UMgrK720Reader,
    USysDB, UBase64;

//------------------------------------------------------------------------------
//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFramePrintBill, '小票打印', nEvent);
end;

class function TfFramePrintBill.FrameID: Integer;
begin
  Result := cFI_FramePrintBill;
end;

procedure TfFramePrintBill.OnCreateFrame;
var nStr: string;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
end;

procedure TfFramePrintBill.OnDestroyFrame;
begin
  FListA.Free;
  FListB.Free;
  FListC.Free;
end;

procedure TfFramePrintBill.OnShowFrame;
begin
  edt_TruckNo.Text := '';
  edt_TruckNo.SetFocus;
end;

procedure TfFramePrintBill.btnPrintClick(Sender: TObject);
var nMsg, nStr, nID: string;
    nIdx: Integer;
begin
  nID := EditID.Caption;
  if nID = '' then
  begin
    ShowMsg('未查询单据,无法打印', sHint);
    Exit;
  end;
  if PrintBillReport(nID, False) then
  begin
    nStr := 'Update %s Set L_PrintCount=L_PrintCount + 1 ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nID]);
    FDM.ExecuteSQL(nStr);
  end;

  edt_TruckNo.Text := '';
  gTimeCounter := 0;
end;

procedure TfFramePrintBill.edt_TruckNoPropertiesChange(Sender: TObject);
var nIdx : Integer;
    nStr: string;
begin
  edt_TruckNo.Properties.Items.Clear;
  nStr := 'Select T_Truck From %s Where T_Truck like ''%%%s%%'' ';
  nStr := Format(nStr, [sTable_Truck, edt_TruckNo.Text]);

  nStr := nStr + Format(' And (T_Valid Is Null or T_Valid<>''%s'') ', [sFlag_No]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      try
        edt_TruckNo.Properties.BeginUpdate;

        First;

        while not Eof do
        begin
          edt_TruckNo.Properties.Items.Add(Fields[0].AsString);
          Next;
        end;
      finally
        edt_TruckNo.Properties.EndUpdate;
      end;
    end;
  end;
  for nIdx := 0 to edt_TruckNo.Properties.Items.Count - 1 do
  begin;
    if Pos(edt_TruckNo.Text,edt_TruckNo.Properties.Items.Strings[nIdx]) > 0 then
    begin
      edt_TruckNo.SelectedItem := nIdx;
      Break;
    end;
  end;
end;

procedure TfFramePrintBill.SpeedButton1Click(Sender: TObject);
var nStr, nTruck: string;
    nCount: Integer;
begin
  EditID.Caption := '';
  EditCusName.Caption := '';
  EditValue.Caption := '';
  EditDone.Caption := '';
  nTruck := Trim(edt_TruckNo.Text);
  if (nTruck = '')then
  begin
    ShowMsg('请填写车牌号信息', sHint);
    Exit;
  end;

  if edt_TruckNo.Properties.Items.IndexOf(nTruck) < 0 then
  begin
    ShowMsg('请选择车牌号或输入完整车牌号', sHint);
    Exit;
  end;

  nCount := 1;

  nStr := 'Select D_Value From %s Where D_Name= ''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_AICMBillPCount]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
      nCount := Fields[0].AsInteger;
  end;
  nStr := 'Select top 1 L_ID, L_CusName,L_Value,L_OutFact,L_PrintCount From %s Where L_Truck like ''%%%s%%'' order by R_ID desc';
  nStr := Format(nStr, [sTable_Bill, nTruck]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount < 1 then
    begin
      nStr := '未找到单据,无法打印';
      ShowMsg(nStr, sHint);
      edt_TruckNo.SetFocus;
      Exit;
    end;

    if FieldByName('L_PrintCount').AsInteger >= nCount then
    begin
      nStr := '超出设定打印次数,无法打印';
      ShowMsg(nStr, sHint);
      edt_TruckNo.SetFocus;
      Exit;
    end;

    EditID.Caption := Fields[0].AsString;
    EditCusName.Caption := Fields[1].AsString;
    EditValue.Caption := Fields[2].AsString;
    EditDone.Caption := Fields[3].AsString;
  end;
end;

procedure TfFramePrintBill.Timer1Timer(Sender: TObject);
begin
  if gNeedClear then
  begin
    gNeedClear := False;
    edt_TruckNo.Text := '';
    EditID.Caption := '';
    EditCusName.Caption := '';
    EditValue.Caption := '';
    EditDone.Caption := '';
  end;
end;

initialization
  gControlManager.RegCtrl(TfFramePrintBill, TfFramePrintBill.FrameID);

end.
