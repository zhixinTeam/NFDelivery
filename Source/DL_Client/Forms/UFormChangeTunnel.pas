{*******************************************************************************
  ����: fendou116688@163.com 2015/1/17
  ����: ����װ��
*******************************************************************************}
unit UFormChangeTunnel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, USysBusiness, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, ComCtrls, cxContainer, cxEdit, cxTextEdit,
  cxListView, cxMCListBox, dxLayoutControl, StdCtrls, UFormNormal;

type
  TfFormChangeTunnel = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    ListInfo: TcxMCListBox;
    dxLayout1Item3: TdxLayoutItem;
    ListZTLines: TcxListView;
    dxLayout1Item7: TdxLayoutItem;
    EditTName: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditTunnel: TcxTextEdit;
    LayItem1: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListZTLinesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListInfoClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FParam: PFormCommandParam;
    FZTTunnelID: string;
    //ջ�����

    procedure InitFormData;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

function ShowSelectZTLineForm(var nNewLine: string): Boolean;
//��ں���

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UFormInputbox, USysGrid, UBusinessConst,
  USysDB, USysConst, UDataModule;

var
  gZTLines: TZTLineItems;

function ShowSelectZTLineForm(var nNewLine: string): Boolean;
begin
  with TfFormChangeTunnel.Create(Application) do
  try
    FZTTunnelID := nNewLine;
    InitFormData;

    Result := ShowModal = mrOk;
    nNewLine := FZTTunnelID;
  finally
    Free;
  end;
end;

class function TfFormChangeTunnel.FormID: integer;
begin
  Result := cFI_FormChangeTunnel;
end;

class function TfFormChangeTunnel.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;

  if not Assigned(nParam) then Exit;

  with TfFormChangeTunnel.Create(Application) do
  try
    FParam := nParam;
    FZTTunnelID := FParam.FParamA;
    InitFormData;

    FParam.FCommand := cCmd_ModalResult;
    FParam.FParamA  := ShowModal;
    FParam.FParamB  := Trim(FZTTunnelID);
  finally
    Free;
  end;                                 
end;

procedure TfFormChangeTunnel.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  ModalResult := mrCancel;
  dxGroup1.AlignVert := avTop;
  dxLayout1Item3.AlignVert := avClient;
  //client align

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadMCListBoxConfig(Name, ListInfo, nIni);
    LoadcxListViewConfig(Name, ListZTLines, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormChangeTunnel.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SaveMCListBoxConfig(Name, ListInfo, nIni);
    SavecxListViewConfig(Name, ListZTLines, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormChangeTunnel.InitFormData;
var nType: string;
    nIdx, nSelect: Integer;
    nTrucks: TZTTruckItems;
begin
  if not LoadTruckQueue(gZTLines, nTrucks) then Exit;

  nSelect := -1;
  ListZTLines.Clear;
  
  for nIdx:=Low(gZTLines) to High(gZTLines) do
  begin
    with ListZTLines.Items.Add, gZTLines[nIdx] do
    begin
      if FID = FZTTunnelID then nSelect:=Index;

      Caption := FID; //ͨ�����
      SubItems.Add(FName);  //ͨ������

      if FIsVip = sFlag_TypeVIP  then nType := 'Vip' else
      if FIsVip = sFlag_TypeZT   then nType := 'ջ̨' else
      if FIsVip = sFlag_TypeShip then nType := '����' else
      if FIsVip = sFlag_TypeCommon then nType := '��ͨ' else nType:='';
      SubItems.Add(nType);

      if FValid then nType := '����'
      else nType := '�ر�';
      SubItems.Add(nType);

      SubItems.Add(FStock);
      //ˮ��Ʒ������

      ImageIndex := 11;
      Data := Pointer(nIdx);
    end;
  end;

  ListZTLines.ItemIndex := nSelect;
end;

procedure TfFormChangeTunnel.ListZTLinesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var nIdx: Integer;
    nType: string;
begin
  if Selected and Assigned(Item) then
  begin
    nIdx := Integer(Item.Data);

    with ListInfo.Items, gZTLines[nIdx] do
    begin
      Clear;

      Add(Format('ջ̨���:%s %s', [Delimiter, FID]));
      Add(Format('ջ̨����:%s %s', [Delimiter, FName]));

      if FIsVip = sFlag_TypeVIP  then nType := 'Vip' else
      if FIsVip = sFlag_TypeZT   then nType := 'ջ̨' else
      if FIsVip = sFlag_TypeShip then nType := '����' else
      if FIsVip = sFlag_TypeCommon then nType := '��ͨ' else nType:='';
      Add(Format('ջ̨����:%s %s', [Delimiter, nType]));

      if FValid then nType := '����'
      else nType := '�ر�';
      Add(Format('ջ̨״̬:%s %s', [Delimiter, nType]));
      Add(Format('Ʒ������:%s %s', [Delimiter, FStock]));
    end;

    EditTunnel.Text := gZTLines[nIdx].FID;
    EditTName.Text  := gZTLines[nIdx].FName;
  end;
end;

procedure TfFormChangeTunnel.ListInfoClick(Sender: TObject);
var nStr: string;
    nPos: Integer;
begin
  if ListInfo.ItemIndex > -1 then
  begin
    nStr := ListInfo.Items[ListInfo.ItemIndex];
    nPos := Pos(':', nStr);
    if nPos < 1 then Exit;

    LayItem1.Caption := Copy(nStr, 1, nPos);
    nPos := Pos(ListInfo.Delimiter, nStr);

    System.Delete(nStr, 1, nPos);
    EditTunnel.Text := Trim(nStr);
  end;
end;

procedure TfFormChangeTunnel.BtnOKClick(Sender: TObject);
begin
  FZTTunnelID := EditTunnel.Text;
  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormChangeTunnel, TfFormChangeTunnel.FormID);
end.
