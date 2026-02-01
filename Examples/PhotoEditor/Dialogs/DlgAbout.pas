unit DlgAbout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, RoundedPanel, Vcl.StdCtrls, ShellAPI,
  Vcl.Buttons, RoundedSpeedButton, Vcl.Imaging.pngimage, IdHTTP, IdBaseComponent, IdGlobal;

type
  TAbout = class(TForm)
    RoundedPanel1: TRoundedPanel;
    pnlTop: TPanel;
    DlgLabel: TLabel;
    RoundedSpeedButton7: TRoundedSpeedButton;
    Label2: TLabel;
    CoffeeLogo: TImage;
    btnCoffee: TRoundedSpeedButton;
    btnCheckVersion: TLabel;
    Label1: TLabel;
    procedure FormPaint(Sender: TObject);
    procedure pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RoundedSpeedButton7Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCoffeeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCheckVersionClick(Sender: TObject);
    procedure btnCheckVersionMouseEnter(Sender: TObject);
    procedure btnCheckVersionMouseLeave(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  About: TAbout;

implementation

{$R *.dfm}

procedure TAbout.FormCreate(Sender: TObject);
begin
  // Show a random quote in DlgLabel.Caption
end;

procedure TAbout.FormPaint(Sender: TObject);
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

procedure TAbout.FormShow(Sender: TObject);
begin
  // show current version in the About dialog
end;

procedure TAbout.btnCheckVersionClick(Sender: TObject);
var
  LIdHTTP: TIdHTTP;
  LUrl: string;
  LContent: string;
begin
  LUrl := 'http://vseven.app/checkversion';
  LIdHTTP := TIdHTTP.Create(nil);
  try
    LIdHTTP.ReadTimeout := 5000;
    try
      LContent := LIdHTTP.Get(LUrl);
      if LContent <> '' then
        ShowMessage('Content retrieved from URL:' + sLineBreak + sLineBreak + LContent)
      else
        ShowMessage('The URL returned no content.');

    except
      on E: Exception do
      begin
        ShowMessage('An error occurred: ' + E.Message);
      end;
    end;
  finally
    LIdHTTP.Free;
  end;
end;

procedure TAbout.btnCheckVersionMouseEnter(Sender: TObject);
begin
  btnCheckVersion.Font.Color := clWhite;
end;

procedure TAbout.btnCheckVersionMouseLeave(Sender: TObject);
begin
  btnCheckVersion.Font.Color := $0041403D;
end;

procedure TAbout.pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TAbout.btnCoffeeClick(Sender: TObject);
begin
  Close;
end;

procedure TAbout.RoundedSpeedButton7Click(Sender: TObject);
begin
  Close;
end;

end.
