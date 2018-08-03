program DL_IssCard;

uses
  Forms,
  main in 'main.pas' {FormMain},
  UFrame in 'UFrame.pas' {Frame1: TFrame},
  PLCController in 'PLCController.pas',
  UDataModule in 'UDataModule.pas' {FDM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFDM, FDM);
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
