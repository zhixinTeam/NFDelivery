program DL_AICM;

uses
  Forms,
  UFormMain in 'UFormMain.pas' {fFormMain},                 
  UFormBase in 'Forms\UFormBase.pas' {BaseForm},
  UDataModule in 'Forms\UDataModule.pas' {FDM: TDataModule},
  UFrameBase in 'Forms\UFrameBase.pas' {fFrameBase: TFrame};

{$R *.res}

begin
  Application.Initialize;

  Application.CreateForm(TFDM, FDM);
  Application.CreateForm(TfFormMain, fFormMain);
  Application.Run;
end.
