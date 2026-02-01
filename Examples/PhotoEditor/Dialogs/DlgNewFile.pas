unit DlgNewFile;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, RoundedPanel, Vcl.StdCtrls,
  Vcl.Buttons, RoundedSpeedButton;

type
  TNewFile = class(TForm)
    RoundedPanel1: TRoundedPanel;
    pnlTop: TPanel;
    RoundedSpeedButton7: TRoundedSpeedButton;
    LabelWidth: TLabel;
    EditWidth: TEdit;
    EditHeight: TEdit;
    LabelName: TLabel;
    EditName: TEdit;
    LabelBackgroundContents: TLabel;
    ComboBoxBackgroundContents: TComboBox;
    RoundedSpeedButton1: TRoundedSpeedButton;
    Label1: TLabel;
    procedure FormPaint(Sender: TObject);
    procedure pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RoundedSpeedButton7Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RoundedSpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewFile: TNewFile;

implementation

{$R *.dfm}

procedure TNewFile.FormPaint(Sender: TObject);
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

procedure TNewFile.FormShow(Sender: TObject);
begin
  EditName.SetFocus;
  EditName.SelectAll;
end;

procedure TNewFile.pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TNewFile.RoundedSpeedButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TNewFile.RoundedSpeedButton7Click(Sender: TObject);
begin
  Close;
end;

end.
