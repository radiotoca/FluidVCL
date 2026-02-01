unit RoundedSpeedButton;

interface

uses
  System.Classes, System.UITypes, Vcl.Controls, Vcl.Graphics,
  Vcl.Buttons, Winapi.Windows, Winapi.Messages, System.Types,
  Vcl.Imaging.pngimage, Vcl.StdCtrls, Vcl.Themes, Vcl.Forms;

type
  TRoundedSpeedButton = class(TSpeedButton)
  private
    FBorderColor: TColor;
    FBorderWidth: Integer;
    FNormalColor: TColor;
    FHoverColor: TColor;
    FDownColor: TColor;
    FBorderRadius: Integer;
    FHasPicture: Boolean;
    FToolPicture: TPicture;

    FHovering: Boolean;

    // New field for ModalResult
    FModalResult: TModalResult;

    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderWidth(const Value: Integer);
    procedure SetNormalColor(const Value: TColor);
    procedure SetHoverColor(const Value: TColor);
    procedure SetDownColor(const Value: TColor);
    procedure SetBorderRadius(const Value: Integer);
    procedure SetToolPicture(const Value: TPicture); // New setter for the picture

    // New setter for ModalResult
    procedure SetModalResult(const Value: TModalResult);

    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;

    // Override Click to set the form's ModalResult
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override; // Destructor for proper memory management
  published
    property BorderColor: TColor read FBorderColor write SetBorderColor default clBlack;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 1;
    property Color: TColor read FNormalColor write SetNormalColor default clBtnFace;
    property HoverColor: TColor read FHoverColor write SetHoverColor default clHighlight;
    property DownColor: TColor read FDownColor write SetDownColor default clBtnShadow;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 8;
    property ToolPicture: TPicture read FToolPicture write SetToolPicture; // New published property

    // Published ModalResult property
    property ModalResult: TModalResult read FModalResult write SetModalResult default mrNone;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FluidVCL', [TRoundedSpeedButton]);
end;

{ TRoundedSpeedButton }

constructor TRoundedSpeedButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBorderColor := clBlack;
  FBorderWidth := 1;
  FNormalColor := clBtnFace;
  FHoverColor := clHighlight;
  FDownColor := clBtnShadow;
  FBorderRadius := 8;
  FHovering := False;
  Flat := True;
  FToolPicture := TPicture.Create; // Create the TPicture instance

  // Set default ModalResult
  FModalResult := mrNone;
end;

destructor TRoundedSpeedButton.Destroy;
begin
  FToolPicture.Free; // Free the TPicture instance
  inherited;
end;

procedure TRoundedSpeedButton.Click;
var
  LParentForm: TCustomForm;
begin
  inherited; // Call the ancestor method first

  // Set the parent form's ModalResult if it exists and is not mrNone
  LParentForm := GetParentForm(Self);
  if Assigned(LParentForm) and (FModalResult <> mrNone) then
    LParentForm.ModalResult := FModalResult;
end;

procedure TRoundedSpeedButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FHovering := True;
  Invalidate;
end;

procedure TRoundedSpeedButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHovering := False;
  Invalidate;
end;

procedure TRoundedSpeedButton.Paint;
var
  R: TRect;
  FillColor, FrameColor: TColor;
  ImageRect: TRect;
  TextRect: TRect;
  Pic: TGraphic;
begin
  R := ClientRect;

  // Decide background color based on state
  if FHovering then
    FillColor := FHoverColor
  else if Down then
    FillColor := FDownColor
  else
    FillColor := Color;

  // Border color
  FrameColor := FBorderColor;

  // Fill background with rounded corners
  Canvas.Brush.Color := FillColor;
  Canvas.Brush.Style := bsSolid;
  Canvas.Pen.Style := psClear;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FBorderRadius*2, FBorderRadius*2);

  // Draw rounded border
  if FBorderWidth > 0 then
  begin
    InflateRect(R, -FBorderWidth div 2, -FBorderWidth div 2);
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := FrameColor;
    Canvas.Pen.Width := FBorderWidth;
    Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FBorderRadius*2, FBorderRadius*2);
  end;

  // Check if a picture is loaded and draw it centered
  Pic := FToolPicture.Graphic;
  if Assigned(Pic) then
  begin
    ImageRect.Left := (Width - Pic.Width) div 2;
    ImageRect.Top := (Height - Pic.Height) div 2;
    ImageRect.Right := ImageRect.Left + Pic.Width;
    ImageRect.Bottom := ImageRect.Top + Pic.Height;

    Canvas.Draw(ImageRect.Left, ImageRect.Top, Pic);
  end;

  // Draw the button caption
  // Position it relative to the image if both are present
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Assign(Font);
  TextRect := ClientRect;
  DrawText(Canvas.Handle, PChar(Caption), -1, TextRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
end;

procedure TRoundedSpeedButton.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then
  begin
    FBorderColor := Value;
    Invalidate;
  end;
end;

procedure TRoundedSpeedButton.SetBorderWidth(const Value: Integer);
begin
  if FBorderWidth <> Value then
  begin
    FBorderWidth := Value;
    Invalidate;
  end;
end;

procedure TRoundedSpeedButton.SetNormalColor(const Value: TColor);
begin
  if FNormalColor <> Value then
  begin
    FNormalColor := Value;
    Invalidate;
  end;
end;

procedure TRoundedSpeedButton.SetHoverColor(const Value: TColor);
begin
  if FHoverColor <> Value then
  begin
    FHoverColor := Value;
    Invalidate;
  end;
end;

procedure TRoundedSpeedButton.SetDownColor(const Value: TColor);
begin
  if FDownColor <> Value then
  begin
    FDownColor := Value;
    Invalidate;
  end;
end;

procedure TRoundedSpeedButton.SetBorderRadius(const Value: Integer);
begin
  if FBorderRadius <> Value then
  begin
    FBorderRadius := Value;
    Invalidate;
  end;
end;

procedure TRoundedSpeedButton.SetToolPicture(const Value: TPicture);
begin
  FToolPicture.Assign(Value);
  Invalidate;
end;

procedure TRoundedSpeedButton.SetModalResult(const Value: TModalResult);
begin
  if FModalResult <> Value then
  begin
    FModalResult := Value;
  end;
end;

end.
