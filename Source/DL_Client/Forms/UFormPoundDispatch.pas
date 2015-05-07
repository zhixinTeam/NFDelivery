{*******************************************************************************
  作者: dmzn 2015-05-07
  描述: 磅站调度
*******************************************************************************}
unit UFormPoundDispatch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, StdCtrls, ExtCtrls, dxLayoutControl, cxControls,
  cxContainer, cxEdit, cxTextEdit, UFormBase, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxMaskEdit, cxDropDownEdit;

type
  TPoundItem = record
    FName: string;            //地磅名称
    FPound: string;           //地磅标识
    FNowPC: string;           //当前主机
    FPCList: string;          //可用主机
  end;

  TPoundItems = array of TPoundItem;

  TfFormPoundDispatch = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item5: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    EditPound: TcxComboBox;
    dxLayoutControl1Item6: TdxLayoutItem;
    EditStation: TcxComboBox;
    dxLayoutControl1Item1: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditPoundPropertiesChange(Sender: TObject);
  private
    { Private declarations }
    FListA: TStrings;
    FPounds: TPoundItems;
    procedure InitFormData;
    //初始化
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UFramePoundManual, UFormMain;

//------------------------------------------------------------------------------
class function TfFormPoundDispatch.CreateForm;
begin
  Result := nil;

  with TfFormPoundDispatch.Create(Application) do
  begin
    FListA := TStringList.Create;
    InitFormData;
    ShowModal;

    FListA.Free;
    Free;
  end;
end;

class function TfFormPoundDispatch.FormID: integer;
begin
  Result := cFI_FormDisPound;
end;

procedure TfFormPoundDispatch.InitFormData;
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select * From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_DispatchPound]);

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FPounds, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      with FPounds[nIdx] do
      begin
        FName   := FieldByName('D_Desc').AsString;
        FPound  := FieldByName('D_Value').AsString;
        FNowPC  := UpperCase(FieldByName('D_Memo').AsString);
        FPCList := UpperCase(FieldByName('D_ParamB').AsString);

        EditPound.Properties.Items.Add(FName);
        //pound
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  if EditPound.Properties.Items.Count > 0 then
    EditPound.ItemIndex := 0;
  //选中首个
end;

procedure TfFormPoundDispatch.EditPoundPropertiesChange(Sender: TObject);
var nStr: string;
    nIdx: Integer;
begin
  FListA.Clear;
  EditStation.Clear;
  if EditPound.ItemIndex < 0 then Exit;

  with FPounds[EditPound.ItemIndex] do
  begin
    SplitStr(FPCList, FListA, 0, ';');
    //解析站点

    for nIdx:=0 to FListA.Count - 1 do
    begin
      nStr := FListA[nIdx];
      nStr := Copy(nStr, 1, Pos(':', nStr) - 1);
      EditStation.Properties.Items.Add(nStr);

      if Pos(FNowPC, FListA[nIdx]) > 0 then
        EditStation.ItemIndex := nIdx;
      //xxxxx
    end;
  end;   
end;

procedure TfFormPoundDispatch.BtnOKClick(Sender: TObject);
var nStr,nMAC: string;
    nIdx,nInt: Integer;
begin
  if EditPound.ItemIndex < 0 then
  begin
    ActiveControl := EditPound;
    ShowMsg('请选择地磅', sHint);
    Exit;
  end;

  if EditStation.ItemIndex < 0 then
  begin
    ActiveControl := EditStation;
    ShowMsg('请选择使用地点', sHint);
    Exit;
  end;

  with FPounds[EditPound.ItemIndex] do
  begin
    if (FNowPC <> '') and (CompareText(FNowPC, gSysParam.FLocalMAC) <> 0) then
    begin
      for nIdx:=0 to FListA.Count - 1 do
      if Pos(FNowPC, FListA[nIdx]) > 0 then
      begin
        nStr := FListA[nIdx];
        nStr := Copy(nStr, 1, Pos(':', nStr) - 1);
        nStr := Format('磅站[ %s ]当前在[ %s ]使用,您没有切换权限.', [FName, nStr]);
        
        ShowDlg(nStr, sHint);
        Exit;
      end;
    end;

    with fMainForm.wPage do
    begin
      for nIdx:=PageCount - 1 downto 0 do
       for nInt:=Pages[nIdx].ControlCount - 1 downto 0 do
        if Pages[nIdx].Controls[nInt] is TfFramePoundManual then
        begin
          nStr := '调整磅站时需要关闭称重业务,是否继续?';
          if not QueryDlg(nStr, sAsk) then Exit;

          (Pages[nIdx].Controls[nInt] as TfFramePoundManual).Close();
          //关闭称重界面
        end;
    end;

    for nIdx:=0 to FListA.Count - 1 do
    if Pos(EditStation.Text, FListA[nIdx]) > 0 then
    begin
      nStr := FListA[nIdx];
      System.Delete(nStr, 1, Pos(':', nStr));

      nMAC := nStr;
      Break;
    end else nMAC := '';

    nStr := 'Update %s Set D_Memo=''%s'' Where D_Name=''%s'' And D_Value=''%s''';
    nStr := Format(nStr, [sTable_SysDict, nMAC, sFlag_DispatchPound, FPound]);

    FDM.ExecuteSQL(nStr);
    ModalResult := mrOk;
    ShowMsg('磅站切换完毕', sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPoundDispatch, TfFormPoundDispatch.FormID);
end.
