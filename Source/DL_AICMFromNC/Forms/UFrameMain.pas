unit UFrameMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameBase, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, jpeg, StdCtrls;

type
  TfFrameMain = class(TfFrameBase)
    ClientImage: TImage;
    ShowWelcome: TStaticText;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnShowFrame; override;
    class function FrameID: integer; override;
  end;

var
  fFrameMain: TfFrameMain;

implementation

{$R *.dfm}

uses
  ULibFun, USysLoger, UDataModule, UMgrControl, USelfHelpConst, UFormMain;

//------------------------------------------------------------------------------
//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameMain, '展示窗体', nEvent);
end;


class function TfFrameMain.FrameID: Integer;
begin
  Result := cFI_FrameMain;
end;

procedure TfFrameMain.OnCreateFrame;
begin
  DoubleBuffered := True;
end;

procedure TfFrameMain.OnDestroyFrame;
begin

end;

procedure TfFrameMain.OnShowFrame;
var nStr: string;
    nList: TStrings;
begin
  nStr := gPath + 'Images\Background.jpg';
  if FileExists(nStr) then
    ClientImage.Picture.LoadFromFile(nStr);

  nStr := gPath + 'Images\Welcome.txt';
  if FileExists(nStr) then
  begin
    nList := TStringList.Create;
    try
      nList.LoadFromFile(nStr);
      ShowWelcome.Caption := nList.Text;
    finally
      nList.Free;
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameMain, TfFrameMain.FrameID);
end.
