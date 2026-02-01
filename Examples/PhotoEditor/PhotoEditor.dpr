program PhotoEditor;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  GroupablePanelUnit in '..\..\GroupablePanelUnit.pas',
  MenuPanelUnit in '..\..\MenuPanelUnit.pas',
  RoundedPanel in '..\..\RoundedPanel.pas',
  DlgAbout in 'Dialogs\DlgAbout.pas' {About},
  DlgBuyCoffee in 'Dialogs\DlgBuyCoffee.pas' {BuyCoffee},
  DlgNewFile in 'Dialogs\DlgNewFile.pas' {NewFile},
  DlgNotYet in 'Dialogs\DlgNotYet.pas' {NotYet},
  DlgCapture in 'Dialogs\DlgCapture.pas' {Capture},
  RoundedSpeedButton in '..\..\RoundedSpeedButton.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TAbout, About);
  Application.CreateForm(TBuyCoffee, BuyCoffee);
  Application.CreateForm(TNewFile, NewFile);
  Application.CreateForm(TNotYet, NotYet);
  Application.CreateForm(TCapture, Capture);
  Application.Run;
end.
