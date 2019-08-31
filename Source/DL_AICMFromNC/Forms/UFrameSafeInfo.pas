unit UFrameSafeInfo;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameBase, ComCtrls, ExtCtrls, Buttons, StdCtrls,
  USelfHelpConst, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxButtonEdit, cxDropDownEdit ;

type

  TfFrameSafeInfo = class(TfFrameBase)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Button1: TButton;
    Button2: TButton;
    ShowSafeInfo: TStaticText;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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
  fFrameSafeInfo: TfFrameSafeInfo;

implementation

{$R *.dfm}

uses
    ULibFun, USysLoger, UDataModule, UMgrControl, USysBusiness, UMgrK720Reader,
    USysDB, UBase64;

//------------------------------------------------------------------------------
//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameSafeInfo, '安全须知', nEvent);
end;

class function TfFrameSafeInfo.FrameID: Integer;
begin
  Result := cFI_FrameSafeInfo;
end;

procedure TfFrameSafeInfo.OnCreateFrame;
begin

end;

procedure TfFrameSafeInfo.OnDestroyFrame;
begin

end;

procedure TfFrameSafeInfo.OnShowFrame;
var nStr: string;
    nList: TStrings;
begin
  nStr := gPath + 'Images\SafeInfo.txt';
  if FileExists(nStr) then
  begin
    nList := TStringList.Create;
    try
      nList.LoadFromFile(nStr);
      ShowSafeInfo.Caption := nList.Text;
    finally
      nList.Free;
    end;
  end;
  StaticText3.Caption := gSysParam.FSafeInfoFoot;
end;

procedure TfFrameSafeInfo.Button1Click(Sender: TObject);
begin
  inherited;
  gAgree := True;
  gTimeCounter := 0;
end;

procedure TfFrameSafeInfo.Button2Click(Sender: TObject);
begin
  inherited;
  gTimeCounter := 0;
end;

initialization
  gControlManager.RegCtrl(TfFrameSafeInfo, TfFrameSafeInfo.FrameID);

end.
