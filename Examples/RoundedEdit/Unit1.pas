unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, RoundedEditUnit,
  RoundedMemoUnit, RoundedButtonUnit, RoundedGroupBoxUnit, RoundedComboBox,
  Vcl.Imaging.pngimage, FluidEditUnit;

type
  TForm1 = class(TForm)
    RoundedEdit1: TRoundedEdit;
    RoundedMemo1: TRoundedMemo;
    RoundedButton1: TRoundedButton;
    RoundedGroupBox1: TRoundedGroupBox;
    RoundedComboBox1: TRoundedComboBox;
    FluidEdit1: TFluidEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

end.
