unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FluidRangeUnit, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    lblHeader: TLabel;
    lblDual: TLabel;
    RangeDual: TFluidRange;
    lblTicks: TLabel;
    RangeTicks: TFluidRange;
    lblRect: TLabel;
    RangeRect: TFluidRange;
    lblMinimal: TLabel;
    RangeSlim: TFluidRange;
    lblWarning: TLabel;
    RangeWarning: TFluidRange;
    FluidRange1: TFluidRange;
    FluidRange2: TFluidRange;
    Label1: TLabel;
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
