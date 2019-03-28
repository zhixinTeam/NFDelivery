unit UFramePrintHYDan;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameBase, ComCtrls, ExtCtrls, Buttons, StdCtrls,
  USelfHelpConst, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxButtonEdit, cxDropDownEdit ;

type

  TfFramePrintHYDan = class(TfFrameBase)
    Pnl_OrderInfo: TPanel;
    lbl_2: TLabel;
    btnPrint: TSpeedButton;
    EditID: TcxTextEdit;
    procedure btnPrintClick(Sender: TObject);
    procedure EditIDPropertiesChange(Sender: TObject);
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
  fFramePrintHYDan: TfFramePrintHYDan;

implementation

{$R *.dfm}

uses
    ULibFun, USysLoger, UDataModule, UMgrControl, USysBusiness, UMgrK720Reader,
    USysDB, UBase64;

//------------------------------------------------------------------------------
//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFramePrintHYDan, '化验单打印', nEvent);
end;

class function TfFramePrintHYDan.FrameID: Integer;
begin
  Result := cFI_FramePrint;
end;

procedure TfFramePrintHYDan.OnCreateFrame;
var nStr: string;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
end;

procedure TfFramePrintHYDan.OnDestroyFrame;
begin
  FListA.Free;
  FListB.Free;
  FListC.Free;
end;

procedure TfFramePrintHYDan.OnShowFrame;
begin
  EditID.Text := '';
  btnPrint.Enabled := False;
  EditID.SetFocus;
end;

procedure TfFramePrintHYDan.btnPrintClick(Sender: TObject);
var nMsg, nStr, nID, nSeal, nLastSeal: string;
    nIdx: Integer;
begin
  nID := Trim(EditID.Text);
  if nID = '' then
  begin
    ShowMsg('请输入准确提货单号', sHint);
    EditID.SetFocus;
    Exit;
  end;

  nStr := 'Select L_ID, L_Seal From %s Where L_ID like ''%%%s%%''';
  nStr := Format(nStr, [sTable_Bill, nID]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount < 1 then
    begin
      nStr := '未找到单据,无法打印';
      ShowMsg(nStr, sHint);
      EditID.SetFocus;
      Exit;
    end;

    if RecordCount > 1 then
    begin
      nStr := '未匹配到唯一单据,请输入准确单据号';
      EditID.SetFocus;
      Exit;
    end;

    nID := Fields[0].AsString;
    nSeal := Fields[1].AsString;
  end;

  {$IFDEF GetLastHYInfo}
  if nSeal = '' then
  begin
    ShowMsg('批次号为空,无法打印', sHint);
    Exit;
  end;

  nStr := 'Select * From %s Where R_SerialNo = ''%s''';
  nStr := Format(nStr, [sTable_StockRecord, nSeal]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      PrintHuaYanReport(nID, nMsg, gSysParam.FHYDanPrinter);
      if nMsg <> '' then
      begin
        ShowMsg(nMsg, sHint);
        EditID.SetFocus;
        Exit;
      end;
      EditID.Text := '';
      gTimeCounter := 0;
      Exit;
    end;
  end;

  nLastSeal := '';

  nStr := 'Select B_Prefix From %s ';
  nStr := Format(nStr, [sTable_Batcode]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      First;

      while not eof do
      begin
        if Pos(Fields[0].AsString, nSeal) > 0 then
        begin
          nLastSeal := Fields[0].AsString;
          Break;
        end;
        Next;
      end;

      if nLastSeal = '' then
      begin
        ShowMsg('查询最近批次号失败', sHint);
        Exit;
      end;
    end;
  end;

  nStr := 'Select top 1 L_Seal From %s a, %s b Where a.L_Seal = b.R_SerialNo ' +
  ' and b.R_SerialNo Like ''%%%s%%'' order by a.L_Date desc';
  nStr := Format(nStr, [sTable_Bill, sTable_StockRecord, nLastSeal]);

  WriteLog('查询最近批次号Sql:' + nStr);
  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount <= 0 then
    begin
      ShowMsg('查询最近批次号失败', sHint);
      Exit;
    end;
    PrintHuaYanReportEx(nID, Fields[0].AsString, nMsg, gSysParam.FHYDanPrinter);
  end;
  {$ELSE}
  PrintHuaYanReport(nID, nMsg, gSysParam.FHYDanPrinter);
  {$ENDIF}

  if nMsg <> '' then
  begin
    ShowMsg(nMsg, sHint);
    EditID.SetFocus;
    Exit;
  end;
  EditID.Text := '';
  gTimeCounter := 0;
end;

procedure TfFramePrintHYDan.EditIDPropertiesChange(Sender: TObject);
begin
  if Length(Trim(EditID.Text)) > 6 then
    btnPrint.Enabled := True
  else
    btnPrint.Enabled := False;
end;

initialization
  gControlManager.RegCtrl(TfFramePrintHYDan, TfFramePrintHYDan.FrameID);

end.
