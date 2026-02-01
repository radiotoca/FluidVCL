unit DlgNotYet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, RoundedPanel, Vcl.StdCtrls,
  Vcl.Buttons, RoundedSpeedButton;

type
  TNotYet = class(TForm)
    RoundedPanel1: TRoundedPanel;
    pnlTop: TPanel;
    Label1: TLabel;
    RoundedSpeedButton7: TRoundedSpeedButton;
    Label2: TLabel;
    procedure FormPaint(Sender: TObject);
    procedure pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RoundedSpeedButton7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NotYet: TNotYet;

implementation

{$R *.dfm}

procedure TNotYet.FormPaint(Sender: TObject);
const
  CornerRadius = 27;
  BorderWidth = 1;
var
  Rgn: HRGN;
  RectBorder: TRect;
begin
  // --- Rounded Corners ---
  Rgn := CreateRoundRectRgn(0, 0, Width, Height, CornerRadius, CornerRadius);
  SetWindowRgn(Handle, Rgn, True);
end;

procedure TNotYet.pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  WM_NCLBUTTONDOWN = $00A1;
  HTCAPTION = 2;
begin
  if Button = mbLeft then
  begin
    ReleaseCapture;
    SendMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
  end;
end;

procedure TNotYet.RoundedSpeedButton7Click(Sender: TObject);
begin
  Close;
end;

end.
