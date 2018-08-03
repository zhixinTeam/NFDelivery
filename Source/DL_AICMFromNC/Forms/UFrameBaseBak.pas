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
//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameMakeCard, '网上订单制卡', nEvent);
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
