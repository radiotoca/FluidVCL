unit MenuPanelUnit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics,
  Vcl.Menus, Winapi.Windows, Winapi.Messages, System.Math;

type
  TMenuPanel = class(TPanel)
  private
    FMainMenu: TMainMenu;
    FHoverIndex: Integer;
    FMenuX: Integer;
    FMenuY: Integer;

    // New properties for custom drawing and rounded corners.
    FMenuBackgroundColor: TColor;
    FMenuSelectionColor: TColor;
    FMenuTextColor: TColor;
    FBorderRadius: Integer;

    // A helper method for the MainMenu property setter.
    procedure SetMainMenu(const Value: TMainMenu);
    procedure SetMenuX(const Value: Integer);
    procedure SetMenuY(const Value: Integer);
    procedure SetMenuBackgroundColor(const Value: TColor);
    procedure SetMenuSelectionColor(const Value: TColor);
    procedure SetMenuTextColor(const Value: TColor);
    procedure SetBorderRadius(const Value: Integer);

    // Event handlers for when the mouse leaves or clicks on the panel.
    procedure DoMouseLeave(Sender: TObject);
    procedure DoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoPopup(Sender: TObject);
    procedure PopulateSubmenu(ParentMenuItem: TMenuItem; TargetMenu: TPopupMenu);
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    // MouseLeave is not an overridable method in TPanel, so we must use an event handler.
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property MainMenu: TMainMenu read FMainMenu write SetMainMenu;
    property MenuX: Integer read FMenuX write SetMenuX default 8;
    property MenuY: Integer read FMenuY write SetMenuY default 4;
    property MenuBackgroundColor: TColor read FMenuBackgroundColor write SetMenuBackgroundColor default clWhite;
    property MenuSelectionColor: TColor read FMenuSelectionColor write SetMenuSelectionColor default clHighlight;
    property MenuTextColor: TColor read FMenuTextColor write SetMenuTextColor default clBlack;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 0;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FluidVCL', [TMenuPanel]);
end;

{ TMenuPanel }

constructor TMenuPanel.Create(AOwner: TComponent);
begin
  inherited;
  FHoverIndex := -1;
  FMenuX := 8;
  FMenuY := 4;
  FMenuBackgroundColor := clWhite;
  FMenuSelectionColor := clHighlight;
  FMenuTextColor := clBlack;
  FBorderRadius := 0;
  OnMouseLeave := DoMouseLeave;
  OnMouseDown := DoMouseDown;
end;

destructor TMenuPanel.Destroy;
begin
  inherited;
end;

procedure TMenuPanel.SetMainMenu(const Value: TMainMenu);
begin
  if FMainMenu <> Value then
  begin
    FMainMenu := Value;
    Invalidate;
  end;
end;

procedure TMenuPanel.SetMenuX(const Value: Integer);
begin
  if FMenuX <> Value then
  begin
    FMenuX := Value;
    Invalidate;
  end;
end;

procedure TMenuPanel.SetMenuY(const Value: Integer);
begin
  if FMenuY <> Value then
  begin
    FMenuY := Value;
    Invalidate;
  end;
end;

procedure TMenuPanel.SetMenuBackgroundColor(const Value: TColor);
begin
  if FMenuBackgroundColor <> Value then
  begin
    FMenuBackgroundColor := Value;
    Invalidate;
  end;
end;

procedure TMenuPanel.SetMenuSelectionColor(const Value: TColor);
begin
  if FMenuSelectionColor <> Value then
  begin
    FMenuSelectionColor := Value;
    Invalidate;
  end;
end;

procedure TMenuPanel.SetMenuTextColor(const Value: TColor);
begin
  if FMenuTextColor <> Value then
  begin
    FMenuTextColor := Value;
    Invalidate;
  end;
end;

procedure TMenuPanel.SetBorderRadius(const Value: Integer);
begin
  if FBorderRadius <> Value then
  begin
    FBorderRadius := Value;
    Invalidate;
  end;
end;

procedure TMenuPanel.Paint;
var
  i: Integer;
  X: Integer;
  R: TRect;
  Item: TMenuItem;
begin
  inherited; // Call the inherited Paint method to draw the panel background.
  if Assigned(FMainMenu) and (FMainMenu.Items.Count > 0) then
  begin
    with Canvas do
    begin
      Brush.Color := Self.Color;
      FillRect(ClientRect);
      X := FMenuX;

      for i := 0 to FMainMenu.Items.Count - 1 do
      begin
        Item := FMainMenu.Items[i];
        R := Rect(X, 0, X + TextWidth(Item.Caption) + 24, Self.Height);
        if i = FHoverIndex then
        begin
          Brush.Color := FMenuSelectionColor;
          Pen.Style := psClear;
          RoundRect(R.Left, R.Top, R.Right, R.Bottom, FBorderRadius, FBorderRadius);
          Font.Color := FMenuTextColor;
        end
        else
        begin
          Brush.Color := Self.Color;
          FillRect(R);
          Font.Color := Self.Font.Color;
        end;

        Font.Style := [];
        Pen.Style := psSolid;
        DrawText(Handle, PChar(Item.Caption), -1, R, DT_SINGLELINE or DT_VCENTER or DT_CENTER);
        Inc(X, TextWidth(Item.Caption) + 24);
      end;
    end;
  end;
end;

procedure TMenuPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i, PosX: Integer;
  Item: TMenuItem;
  NewHover: Integer;
begin
  inherited; // Call the inherited MouseMove method first.

  if Assigned(FMainMenu) and (FMainMenu.Items.Count > 0) then
  begin
    PosX := FMenuX;
    NewHover := -1;

    for i := 0 to FMainMenu.Items.Count - 1 do
    begin
      Item := FMainMenu.Items[i];

      if (X >= PosX) and (X <= PosX + Canvas.TextWidth(Item.Caption) + 24) and
         (Y >= 0) and (Y <= Self.Height) then
      begin
        NewHover := i;
        Break; // Found the item, no need to continue the loop.
      end;
      Inc(PosX, Canvas.TextWidth(Item.Caption) + 24);
    end;

    if NewHover <> FHoverIndex then
    begin
      FHoverIndex := NewHover;
      Invalidate;
    end;
  end;
end;

procedure TMenuPanel.DoMouseLeave(Sender: TObject);
begin
  if FHoverIndex <> -1 then
  begin
    FHoverIndex := -1;
    Invalidate; // Invalidate to redraw the panel without the hover effect.
  end;
end;

procedure TMenuPanel.DoPopup(Sender: TObject);
var
  Popup: TPopupMenu;
  Rgn: HRGN;
  i, MenuWidth, MenuHeight: Integer;
  Item: TMenuItem;
  ACanvas: TCanvas;
begin
  Popup := TPopupMenu(Sender);
  if (Assigned(Popup)) and (FBorderRadius > 0) then
  begin
    ACanvas := TCanvas.Create;
    try
      ACanvas.Handle := Popup.Handle;
      ACanvas.Font.Assign(Self.Font); // Use the font from our panel for consistent measurement

      MenuWidth := 0;
      MenuHeight := 0;

      for i := 0 to Popup.Items.Count - 1 do
      begin
        Item := Popup.Items[i];
        if Item.Caption <> '-' then // Account for separators.
        begin
          MenuWidth := Max(MenuWidth, ACanvas.TextWidth(Item.Caption) + 40);
          MenuHeight := MenuHeight + 24;
        end
        else
        begin
          MenuHeight := MenuHeight + 12;
        end;
      end;
      Inc(MenuWidth, 1);
      Rgn := CreateRoundRectRgn(0, 0, MenuWidth, MenuHeight, FBorderRadius, FBorderRadius);
      SetWindowRgn(Popup.Handle, Rgn, True);
      DeleteObject(Rgn);
    finally
      ACanvas.Free;
    end;
  end;
end;

procedure TMenuPanel.PopulateSubmenu(ParentMenuItem: TMenuItem; TargetMenu: TPopupMenu);
var
  SubItem, NewSubItem: TMenuItem;
  i: Integer;
begin
  for i := 0 to ParentMenuItem.Count - 1 do
  begin
    SubItem := ParentMenuItem.Items[i];
    NewSubItem := TMenuItem.Create(TargetMenu);
    with NewSubItem do
    begin
      Caption := SubItem.Caption;
      ShortCut := SubItem.ShortCut;
      OnClick := SubItem.OnClick;
      Hint := SubItem.Hint;
      Checked := SubItem.Checked;
      Enabled := SubItem.Enabled;
      RadioItem := SubItem.RadioItem;
      GroupIndex := SubItem.GroupIndex;
      ImageIndex := SubItem.ImageIndex;
    end;

    TargetMenu.Items.Add(NewSubItem);
    if SubItem.Count > 0 then
    begin
      //PopulateSubmenu(SubItem, NewSubItem.GetParentMenu as TPopupMenu);
    end;
  end;
end;

procedure TMenuPanel.DoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, PosX: Integer;
  Item: TMenuItem;
  SubMenu: TPopupMenu;
  Pt: TPoint;
begin
  if Assigned(FMainMenu) and (FMainMenu.Items.Count > 0) and (Button = mbLeft) then
  begin
    try
      PosX := FMenuX;
      for i := 0 to FMainMenu.Items.Count - 1 do
      begin
        Item := FMainMenu.Items[i];
        if (X >= PosX) and (X <= PosX + Canvas.TextWidth(Item.Caption) + 24) and
           (Y >= 0) and (Y <= Self.Height) then
        begin
          if Item.Count > 0 then
          begin
            SubMenu := TPopupMenu.Create(Self);
            SubMenu.AutoHotkeys := maManual;

            if FBorderRadius > 0 then
              SubMenu.OnPopup := DoPopup;
            PopulateSubmenu(Item, SubMenu);
            Pt := Self.ClientToScreen(Point(PosX, Self.Height));
            SubMenu.Popup(Pt.X, Pt.Y);
          end;
          Break;
        end;
        Inc(PosX, Canvas.TextWidth(Item.Caption) + 24);
      end;
    finally
      FHoverIndex := -1;
      Invalidate;
    end;
  end;
end;

end.

