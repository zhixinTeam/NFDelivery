unit UFrameStationStandard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxTextEdit, cxMaskEdit,
  cxButtonEdit;

type
  TfFrameStationStandard = class(TfFrameNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
  protected
    { protected declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
    {*≤È—ØSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameStationStandard: TfFrameStationStandard;

implementation

{$R *.dfm}

uses USysConst, ULibFun, USysDB, UMgrControl, UFormBase;

//------------------------------------------------------------------------------
class function TfFrameStationStandard.FrameID: integer;
begin
  Result := cFI_FrameStationStandard;
end;

function TfFrameStationStandard.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From $StationTruck ';

  if nWhere <> '' then
    Result := Result + 'Where ' + nWhere;

  Result := MacroValue(Result, [MI('$StationTruck', sTable_StationTruck)]);
  //xxxxx
end;  

procedure TfFrameStationStandard.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormStationStandard, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

procedure TfFrameStationStandard.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('R_ID').AsString;
    CreateBaseFormItem(cFI_FormStationStandard, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameStationStandard, TfFrameStationStandard.FrameID);
end.
