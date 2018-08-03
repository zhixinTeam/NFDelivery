unit UFrameMakeCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameBase, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, jpeg, Buttons;

type
  TfFrameMakeCard = class(TfFrameBase)
    ClientImage: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    class function FrameID: integer; override;
  end;

var
  fFrameMakeCard: TfFrameMakeCard;

implementation

{$R *.dfm}

uses
  ULibFun, USysLoger, UDataModule, UMgrControl, USelfHelpConst, UFormMain;

//------------------------------------------------------------------------------
//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameMakeCard, '���϶����ƿ�', nEvent);
end;


class function TfFrameMakeCard.FrameID: Integer;
begin
  Result := cFI_FrameMakeCard;
end;

procedure TfFrameMakeCard.OnCreateFrame;
begin
  DoubleBuffered := True;
end;

procedure TfFrameMakeCard.OnDestroyFrame;
begin

end;

initialization
  gControlManager.RegCtrl(TfFrameMakeCard, TfFrameMakeCard.FrameID);
end.
