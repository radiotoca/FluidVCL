unit RoundedComboBox;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Winapi.GDIPOBJ, Winapi.GDIPAPI, Vcl.StdCtrls, System.Types;

type
  TRoundedComboBox = class(TCustomControl)
  private
    FBorderColor: TColor;
    FBorderThickness: Single;
    FBorderRadius: Integer;
    FItems: TStringList;
    FItemIndex: Integer;
    FIsDroppedDown: Boolean;

    FDropdownColor: TColor;
    FDropdownBorderRadius: Integer;
    FDropdownMargin: Integer;
    FDropdownSelectedColor: TColor;
    FDropdownHoverColor: TColor;
    FHoverIndex: Integer;

    FListControl: TListBox;
    FListForm: TForm;
    FOnChange: TNotifyEvent;

    function ColorToGDIColor(vclColor: TColor): TGPColor;
    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderThickness(const Value: Single);
    procedure SetBorderRadius(const Value: Integer);
    procedure SetItems(const Value: TStringList);
    procedure SetItemIndex(const Value: Integer);

    procedure SetDropdownColor(const Value: TColor);
    procedure SetDropdownMargin(const Value: Integer);
    procedure SetDropdownBorderRadius(const Value: Integer);
    procedure SetDropdownSelectedColor(const Value: TColor);
    procedure SetDropdownHoverColor(const Value: TColor);

    procedure UpdateListBounds;
    procedure ListFormDeactivate(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
    procedure ListBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DrawRoundedPath(graphics: TGPGraphics; rect: TGPRectF; radius: Single; penColor: TColor; penWidth: Single; fillColor: TColor; fill: Boolean);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CreateWnd; override;
    procedure DoEnter; override;
    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DropDown;
    procedure CloseUp;
  published
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property BorderThickness: Single read FBorderThickness write SetBorderThickness;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius;

    property DropdownColor: TColor read FDropdownColor write SetDropdownColor;
    property DropdownMargin: Integer read FDropdownMargin write SetDropdownMargin;
    property DropdownBorderRadius: Integer read FDropdownBorderRadius write SetDropdownBorderRadius;
    property DropdownSelectedColor: TColor read FDropdownSelectedColor write SetDropdownSelectedColor;
    property DropdownHoverColor: TColor read FDropdownHoverColor write SetDropdownHoverColor;

    property Items: TStringList read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    property Color;
    property Font;
    property ParentColor;
    property ParentFont;
    property Width;
    property Height;
    property TabStop;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FluidVCL', [TRoundedComboBox]);
end;

constructor TRoundedComboBox.Create(AOwner: TComponent);
begin
  inherited;
  FItems := TStringList.Create;

  FBorderColor := clGray;
  FBorderThickness := 1.5;
  FBorderRadius := 8;

  FDropdownColor := clWhite;
  FDropdownMargin := 0;
  FDropdownBorderRadius := 8;
  FDropdownSelectedColor := $00F0D2B4;
  FDropdownHoverColor := $00F9E8D9;
  FHoverIndex := -1;

  FItemIndex := -1;
  FIsDroppedDown := False;

  Width := 145;
  Height := 25;
  DoubleBuffered := True;
end;

destructor TRoundedComboBox.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TRoundedComboBox.CreateWnd;
begin
  inherited;
  FListForm := TForm.CreateNew(Self);
  FListForm.BorderStyle := bsNone;
  FListForm.OnDeactivate := ListFormDeactivate;
  SetWindowLong(FListForm.Handle, GWL_EXSTYLE, GetWindowLong(FListForm.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);

  FListControl := TListBox.Create(FListForm);
  FListControl.Parent := FListForm;
  FListControl.Align := alClient;
  FListControl.BorderStyle := bsNone;
  FListControl.Style := lbOwnerDrawFixed;
  FListControl.OnDrawItem := ListBoxDrawItem;
  FListControl.OnClick := ListBoxClick;
  FListControl.OnKeyDown := ListBoxKeyDown;
  FListControl.OnMouseMove := ListBoxMouseMove;
  FListControl.ParentFont := True;
end;

function TRoundedComboBox.ColorToGDIColor(vclColor: TColor): TGPColor;
var
  rgbVal: LongInt;
begin
  rgbVal := ColorToRGB(vclColor);
  Result := MakeColor(255, GetRValue(rgbVal), GetGValue(rgbVal), GetBValue(rgbVal));
end;

procedure TRoundedComboBox.DrawRoundedPath(graphics: TGPGraphics; rect: TGPRectF; radius: Single; penColor: TColor; penWidth: Single; fillColor: TColor; fill: Boolean);
var
  path: TGPGraphicsPath;
  pen: TGPPen;
  brush: TGPSolidBrush;
  arcSize: Single;
begin
  if radius <= 0 then radius := 0.1;
  arcSize := radius * 2;

  if arcSize > rect.Width then arcSize := rect.Width;
  if arcSize > rect.Height then arcSize := rect.Height;

  path := TGPGraphicsPath.Create;
  try
    path.AddArc(rect.X, rect.Y, arcSize, arcSize, 180, 90);
    path.AddArc(rect.X + rect.Width - arcSize, rect.Y, arcSize, arcSize, 270, 90);
    path.AddArc(rect.X + rect.Width - arcSize, rect.Y + rect.Height - arcSize, arcSize, arcSize, 0, 90);
    path.AddArc(rect.X, rect.Y + rect.Height - arcSize, arcSize, arcSize, 90, 90);
    path.CloseFigure;

    if fill then
    begin
      brush := TGPSolidBrush.Create(ColorToGDIColor(fillColor));
      graphics.FillPath(brush, path);
      brush.Free;
    end;

    if penWidth > 0 then
    begin
      pen := TGPPen.Create(ColorToGDIColor(penColor), penWidth);
      pen.SetAlignment(PenAlignmentCenter);
      graphics.DrawPath(pen, path);
      pen.Free;
    end;
  finally
    path.Free;
  end;
end;

procedure TRoundedComboBox.DropDown;
begin
  if FIsDroppedDown or (FItems.Count = 0) then Exit;

  FListControl.Items.Assign(FItems);
  FListControl.Color := FDropdownColor;
  FListControl.ItemIndex := FItemIndex;
  FHoverIndex := -1;

  UpdateListBounds;

  FIsDroppedDown := True;
  FListForm.Visible := True;
  FListControl.SetFocus;
end;

procedure TRoundedComboBox.CloseUp;
begin
  if not FIsDroppedDown then Exit;
  FListForm.Visible := False;
  FIsDroppedDown := False;
  Invalidate;
end;

procedure TRoundedComboBox.UpdateListBounds;
var
  P: TPoint;
  NewHeight: Integer;
  Rgn, TempRgn: HRGN;
begin
  P := ClientToScreen(Point(0, Height));

  // Apply DropdownMargin: Shift X and shrink Width
  FListForm.Left := P.X + FDropdownMargin;
  FListForm.Top := P.Y + 1;
  FListForm.Width := Width - (FDropdownMargin * 2);

  NewHeight := (FListControl.ItemHeight * FItems.Count) + 2;
  if NewHeight > 300 then NewHeight := 300;
  FListForm.Height := NewHeight;

  // Create a region that only rounds the bottom corners
  // 1. Create a rectangular region for the top half
  Rgn := CreateRectRgn(0, 0, FListForm.Width, FListForm.Height - FDropdownBorderRadius);
  // 2. Create a rounded rectangular region for the bottom area
  TempRgn := CreateRoundRectRgn(0, FListForm.Height - (FDropdownBorderRadius * 2),
                               FListForm.Width, FListForm.Height,
                               FDropdownBorderRadius, FDropdownBorderRadius);
  // 3. Combine them to get sharp top corners and rounded bottom corners
  CombineRgn(Rgn, Rgn, TempRgn, RGN_OR);
  DeleteObject(TempRgn);

  SetWindowRgn(FListForm.Handle, Rgn, True);
end;

procedure TRoundedComboBox.ListBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Canvas: TCanvas;
  BgColor: TColor;
begin
  Canvas := FListControl.Canvas;
  BgColor := FDropdownColor;

  if (Index = FItemIndex) then
    BgColor := FDropdownSelectedColor
  else if (Index = FHoverIndex) then
    BgColor := FDropdownHoverColor;

  Canvas.Brush.Color := BgColor;
  Canvas.FillRect(Rect);

  Canvas.Font.Assign(Self.Font);
  if Index = FItemIndex then Canvas.Font.Style := [fsBold];

  Canvas.Brush.Style := bsClear;
  Rect.Left := Rect.Left + 8;
  DrawText(Canvas.Handle, PChar(FItems[Index]), -1, Rect, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
end;

procedure TRoundedComboBox.ListBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
begin
  Idx := FListControl.ItemAtPos(Point(X, Y), True);
  if Idx <> FHoverIndex then
  begin
    FHoverIndex := Idx;
    FListControl.Repaint;
  end;
end;

procedure TRoundedComboBox.Paint;
var
  graphics: TGPGraphics;
  gRect: TGPRectF;
  TxtHeight: Integer;
begin
  graphics := TGPGraphics.Create(Canvas.Handle);
  try
    graphics.SetSmoothingMode(SmoothingModeAntiAlias);

    gRect.X := FBorderThickness / 2;
    gRect.Y := FBorderThickness / 2;
    gRect.Width := Width - FBorderThickness;
    gRect.Height := Height - FBorderThickness;

    DrawRoundedPath(graphics, gRect, FBorderRadius, FBorderColor, FBorderThickness, Color, True);

    // Arrow
    var pen := TGPPen.Create(ColorToGDIColor(Font.Color), 1.5);
    graphics.DrawLine(pen, Width - 22, (Height / 2) - 2, Width - 17, (Height / 2) + 3);
    graphics.DrawLine(pen, Width - 17, (Height / 2) + 3, Width - 12, (Height / 2) - 2);
    pen.Free;

    if (FItemIndex >= 0) and (FItemIndex < FItems.Count) then
    begin
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Assign(Font);
      TxtHeight := Canvas.TextHeight('W');
      Canvas.TextOut(FBorderRadius + 4, (Height - TxtHeight) div 2, FItems[FItemIndex]);
    end;
  finally
    graphics.Free;
  end;
end;

procedure TRoundedComboBox.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then begin FBorderColor := Value; Invalidate; end;
end;

procedure TRoundedComboBox.SetBorderRadius(const Value: Integer);
begin
  if FBorderRadius <> Value then begin FBorderRadius := Value; Invalidate; end;
end;

procedure TRoundedComboBox.SetBorderThickness(const Value: Single);
begin
  if FBorderThickness <> Value then begin FBorderThickness := Value; Invalidate; end;
end;

procedure TRoundedComboBox.SetDropdownColor(const Value: TColor); begin FDropdownColor := Value; end;
procedure TRoundedComboBox.SetDropdownMargin(const Value: Integer); begin FDropdownMargin := Value; end;
procedure TRoundedComboBox.SetDropdownBorderRadius(const Value: Integer); begin FDropdownBorderRadius := Value; end;
procedure TRoundedComboBox.SetDropdownSelectedColor(const Value: TColor); begin FDropdownSelectedColor := Value; end;
procedure TRoundedComboBox.SetDropdownHoverColor(const Value: TColor); begin FDropdownHoverColor := Value; end;

procedure TRoundedComboBox.SetItemIndex(const Value: Integer);
begin
  if FItemIndex <> Value then
  begin
    FItemIndex := Value;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TRoundedComboBox.SetItems(const Value: TStringList);
begin
  FItems.Assign(Value);
end;

procedure TRoundedComboBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    if not Focused then SetFocus;
    if not FIsDroppedDown then DropDown else CloseUp;
  end;
end;

procedure TRoundedComboBox.ListFormDeactivate(Sender: TObject);
begin
  CloseUp;
end;

procedure TRoundedComboBox.ListBoxClick(Sender: TObject);
begin
  SetItemIndex(FListControl.ItemIndex);
  CloseUp;
end;

procedure TRoundedComboBox.ListBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then CloseUp
  else if Key = VK_RETURN then ListBoxClick(Sender);
end;

procedure TRoundedComboBox.DoEnter; begin inherited; Invalidate; end;
procedure TRoundedComboBox.DoExit; begin inherited; Invalidate; end;

end.
