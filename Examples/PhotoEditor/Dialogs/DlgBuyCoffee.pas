unit DlgBuyCoffee;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, RoundedPanel, Vcl.StdCtrls, ShellAPI,
  Vcl.Buttons, RoundedSpeedButton, Vcl.Imaging.GIFImg;

type
  TBuyCoffee = class(TForm)
    RoundedPanel1: TRoundedPanel;
    pnlTop: TPanel;
    DlgLabel: TLabel;
    RoundedSpeedButton7: TRoundedSpeedButton;
    Label2: TLabel;
    CoffeeLogo: TImage;
    btnCoffee: TRoundedSpeedButton;
    btnPayPal: TLabel;
    procedure FormPaint(Sender: TObject);
    procedure pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RoundedSpeedButton7Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCoffeeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPayPalClick(Sender: TObject);
    procedure btnPayPalMouseEnter(Sender: TObject);
    procedure btnPayPalMouseLeave(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BuyCoffee: TBuyCoffee;

implementation

{$R *.dfm}

procedure TBuyCoffee.FormCreate(Sender: TObject);
begin
  // Show a random quote in DlgLabel.Caption
end;

procedure TBuyCoffee.FormPaint(Sender: TObject);
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

procedure TBuyCoffee.FormShow(Sender: TObject);
const
  Quotes: array[0..11] of string = (
    'Your spare change keeps my coffee cup full.',
    'Support an indie dev � not a faceless corporation.',
    'Fuel my midnight coding sessions with your kindness.',
    'Every pixel gets sharper when you donate.',
    'Help me trade instant noodles for real food.',
    'This app was handcrafted, not mass-produced.',
    'One donation = one more bug fix I won�t dread.',
    'Art meets code.. and your support keeps them going.',
    'Owls hoot louder when you chip in.',
    'Your tip jar is my Research and Development department.',
    'Donations: the only subscription I like.',
    'Keep the updates rolling and the lights on.'
  );
begin
  // Quote
  Randomize;
  DlgLabel.Caption := Quotes[Random(Length(Quotes))];

  //CoffeeLogo
  if CoffeeLogo.Picture.Graphic is TGIFImage then
  begin
    (CoffeeLogo.Picture.Graphic as TGIFImage).Animate := True;
    //(CoffeeLogo.Picture.Graphic as TGIFImage).AnimationSpeed := 150; // Adjust speed (100 is normal)
    (CoffeeLogo.Picture.Graphic as TGIFImage).AnimateLoop := glEnabled; // Loop animation
  end;
end;

procedure TBuyCoffee.btnPayPalClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://paypal.me/vsevenapp', nil, nil, SW_SHOWNORMAL);
end;

procedure TBuyCoffee.btnPayPalMouseEnter(Sender: TObject);
begin
  btnPayPal.Font.Color := clWhite;
end;

procedure TBuyCoffee.btnPayPalMouseLeave(Sender: TObject);
begin
  btnPayPal.Font.Color := $0041403D;
end;

procedure TBuyCoffee.pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TBuyCoffee.btnCoffeeClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://buymeacoffee.com/ignuicould', nil, nil, SW_SHOWNORMAL);
end;

procedure TBuyCoffee.RoundedSpeedButton7Click(Sender: TObject);
begin
  Close;
end;

end.
