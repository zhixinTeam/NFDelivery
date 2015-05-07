program Weixin;

uses
  Forms,
  UFormMain in 'Forms\UFormMain.pas' {fFormMain},
  UDataModule in 'Forms\UDataModule.pas' {FDM: TDataModule},
  UFormSetAppData in 'Forms\UFormSetAppData.pas' {fFormSetApp},
  UFormTemplate in 'Forms\UFormTemplate.pas' {fFormTemplate},
  UFormBase in 'Forms\UFormBase.pas' {BaseForm},
  UFormParamDB in 'Forms\UFormParamDB.pas' {fFormParamDB},
  UWeiXinConst in 'Common\UWeiXinConst.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFDM, FDM);
  Application.CreateForm(TfFormMain, fFormMain);
  Application.CreateForm(TfFormSetApp, fFormSetApp);
  Application.CreateForm(TfFormTemplate, fFormTemplate);
  Application.Run;
end.
