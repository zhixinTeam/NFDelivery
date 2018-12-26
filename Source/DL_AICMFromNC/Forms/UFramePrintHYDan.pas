unit UFramePrintHYDan;

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
var nMsg, nStr, nID: string;
    nIdx: Integer;
begin
  nID := Trim(EditID.Text);
  if nID = '' then
  begin
    ShowMsg('请输入准确提货单号', sHint);
    EditID.SetFocus;
    Exit;
  end;

  nStr := 'Select L_ID From %s Where L_ID like ''%%%s%%''';
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
  end;

  PrintHuaYanReport(nID, nMsg, gSysParam.FHYDanPrinter);

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
