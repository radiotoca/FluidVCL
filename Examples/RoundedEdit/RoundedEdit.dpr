program RoundedEdit;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  RoundedEditUnit in '..\..\RoundedEditUnit.pas',
  RoundedMemoUnit in '..\..\RoundedMemoUnit.pas',
  RoundedButtonUnit in '..\..\RoundedButtonUnit.pas',
  RoundedGroupBoxUnit in '..\..\RoundedGroupBoxUnit.pas',
  RoundedComboBox in '..\..\RoundedComboBox.pas',
  FluidEditUnit in '..\..\FluidEditUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
