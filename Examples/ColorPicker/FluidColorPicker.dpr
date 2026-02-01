program FluidColorPicker;

uses
  Vcl.Forms,
  FluidColorPickerDialogUnit in 'FluidColorPickerDialogUnit.pas' {FluidColorPickerDialog},
  FluidColorBoxUnit in '..\..\FluidColorBoxUnit.pas',
  RoundedEditUnit in '..\..\RoundedEditUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFluidColorPickerDialog, FluidColorPickerDialog);
  Application.Run;
end.
