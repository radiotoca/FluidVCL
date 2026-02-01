unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.Buttons, System.TypInfo,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.ExtDlgs,
  RoundedPanel, MenuPanelUnit, DlgAbout, DlgNewFile, DlgBuyCoffee, DlgCapture, DlgNotYet, RoundedSpeedButton;

type
  TTool = (None, Select, Crop, Move, Draw, Erase, Dropper, Bucket, Text, Pen);
  TForm1 = class(TForm)
    ColorDialog1: TColorDialog;
    dlgOpenPicture: TOpenPictureDialog;
    GetColor: TColorDialog;
    MainMenu2: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    N1: TMenuItem;
    Capture1: TMenuItem;
    N29: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    SaveForWeb1: TMenuItem;
    PrepareforDisplay1: TMenuItem;
    N31: TMenuItem;
    Close1: TMenuItem;
    N2: TMenuItem;
    MenuItem4: TMenuItem;
    Edit1: TMenuItem;
    Undo1: TMenuItem;
    N3: TMenuItem;
    Cut1: TMenuItem;
    MenuItem5: TMenuItem;
    CopyMerged1: TMenuItem;
    MenuItem6: TMenuItem;
    AnalyzeClipboard1: TMenuItem;
    N4: TMenuItem;
    Fill1: TMenuItem;
    Stroke1: TMenuItem;
    N5: TMenuItem;
    FreeTransform1: TMenuItem;
    ransform1: TMenuItem;
    N22: TMenuItem;
    Preferences1: TMenuItem;
    MenuItem7: TMenuItem;
    Crop1: TMenuItem;
    rim1: TMenuItem;
    ImageSize1: TMenuItem;
    CanvasSize1: TMenuItem;
    ImageRotation1: TMenuItem;
    N10: TMenuItem;
    Canvas1801: TMenuItem;
    Canvas90CW1: TMenuItem;
    N90CCW1: TMenuItem;
    FlipCanvasHorizontal1: TMenuItem;
    FlipCanvasVertical1: TMenuItem;
    N28: TMenuItem;
    MetaInformation1: TMenuItem;
    GIFInformation1: TMenuItem;
    Adjustments1: TMenuItem;
    BrightnessContrast1: TMenuItem;
    Levels1: TMenuItem;
    Curves1: TMenuItem;
    Exposure1: TMenuItem;
    N23: TMenuItem;
    Vibrance1: TMenuItem;
    HueSaturation1: TMenuItem;
    ColorBalance1: TMenuItem;
    N7: TMenuItem;
    Scale1: TMenuItem;
    Rotate1: TMenuItem;
    Skew1: TMenuItem;
    Distort1: TMenuItem;
    Perspective1: TMenuItem;
    Warp1: TMenuItem;
    N8: TMenuItem;
    Desaturate1: TMenuItem;
    Invert1: TMenuItem;
    Layer1: TMenuItem;
    New2: TMenuItem;
    Layer2: TMenuItem;
    LayerfromBackground1: TMenuItem;
    Group1: TMenuItem;
    GroupFromLayers1: TMenuItem;
    N12: TMenuItem;
    LayerviaCopy1: TMenuItem;
    LayerviaCut1: TMenuItem;
    DuplicateLayer1: TMenuItem;
    Delete1: TMenuItem;
    Layer3: TMenuItem;
    HiddenLayers1: TMenuItem;
    N13: TMenuItem;
    LayerProperties1: TMenuItem;
    LayerStyle1: TMenuItem;
    BlendingOptions1: TMenuItem;
    N14: TMenuItem;
    DropShadow1: TMenuItem;
    InnerShadow1: TMenuItem;
    N16: TMenuItem;
    Rasterize1: TMenuItem;
    ype1: TMenuItem;
    Shape1: TMenuItem;
    N17: TMenuItem;
    Layer4: TMenuItem;
    AllLayers1: TMenuItem;
    N15: TMenuItem;
    MergeDown1: TMenuItem;
    MergeVisible1: TMenuItem;
    FlattenImage1: TMenuItem;
    N6: TMenuItem;
    Select1: TMenuItem;
    All1: TMenuItem;
    Deselect1: TMenuItem;
    Reselect1: TMenuItem;
    Inverse1: TMenuItem;
    N26: TMenuItem;
    ColorRange1: TMenuItem;
    N18: TMenuItem;
    Expand1: TMenuItem;
    Contract1: TMenuItem;
    N27: TMenuItem;
    LoadSelection1: TMenuItem;
    SaveSelection1: TMenuItem;
    Filter1: TMenuItem;
    LastFilter1: TMenuItem;
    N19: TMenuItem;
    Artistic1: TMenuItem;
    Blur1: TMenuItem;
    GaussianBlur1: TMenuItem;
    BrushStrokes1: TMenuItem;
    Distort2: TMenuItem;
    Noise1: TMenuItem;
    Pixelate1: TMenuItem;
    Mosiac1: TMenuItem;
    Render1: TMenuItem;
    Sharpen1: TMenuItem;
    UnsharpMask1: TMenuItem;
    Sketch1: TMenuItem;
    Stylize1: TMenuItem;
    Video1: TMenuItem;
    Other1: TMenuItem;
    N30: TMenuItem;
    AIInference1: TMenuItem;
    FacialRecognition1: TMenuItem;
    ObjectDetection1: TMenuItem;
    View1: TMenuItem;
    ZoomIn1: TMenuItem;
    ZoomOut1: TMenuItem;
    FitonScreen1: TMenuItem;
    ActualPixels1: TMenuItem;
    N21: TMenuItem;
    Rulers1: TMenuItem;
    LockGuides1: TMenuItem;
    ClearGuides1: TMenuItem;
    N32: TMenuItem;
    PixelGrid1: TMenuItem;
    ShowPixelGrid1: TMenuItem;
    PixelGridOptions1: TMenuItem;
    Window1: TMenuItem;
    Color1: TMenuItem;
    Layers1: TMenuItem;
    Navigator1: TMenuItem;
    N20: TMenuItem;
    Options1: TMenuItem;
    Tools1: TMenuItem;
    Help1: TMenuItem;
    BuyMeaCoffee1: TMenuItem;
    About1: TMenuItem;
    mnuCopyColor: TPopupMenu;
    Copy0000001: TMenuItem;
    Copyrgb0001: TMenuItem;
    Copyhsl3070801: TMenuItem;
    N33: TMenuItem;
    Copy0000002: TMenuItem;
    Copyrgb0002: TMenuItem;
    Copyhsl3070802: TMenuItem;
    PopupMenu1: TPopupMenu;
    New3: TMenuItem;
    Open2: TMenuItem;
    RoundedPanel1: TRoundedPanel;
    Splitter1: TSplitter;
    pnlCanvas: TPanel;
    Splitter2: TSplitter;
    RuleTop: TImage;
    RuleLeft: TImage;
    Panel1: TPanel;
    RoundedPanel6: TRoundedPanel;
    Image3: TImage;
    Panel5: TPanel;
    GridPanel1: TGridPanel;
    pnlRight: TPanel;
    pnlLayersSection: TRoundedPanel;
    pnlLayersTitle: TPanel;
    btnNewLayer: TRoundedSpeedButton;
    RoundedPanel3: TRoundedPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    pnlLayersToolbar: TPanel;
    RoundedSpeedButton14: TRoundedSpeedButton;
    RoundedSpeedButton15: TRoundedSpeedButton;
    RoundedSpeedButton16: TRoundedSpeedButton;
    RoundedPanel5: TRoundedPanel;
    Image2: TImage;
    Label3: TLabel;
    Label4: TLabel;
    LayersScrollBox: TScrollBox;
    RoundedPanel4: TRoundedPanel;
    Panel2: TPanel;
    RoundedPanel7: TRoundedPanel;
    LabelTool: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    LabelZoom: TLabel;
    LabelCanvasSize: TLabel;
    Panel6: TPanel;
    pnlTools: TPanel;
    shpForeground2: TShape;
    shpBackground2: TShape;
    RoundedSpeedButton1: TRoundedSpeedButton;
    RoundedSpeedButton2: TRoundedSpeedButton;
    RoundedSpeedButton3: TRoundedSpeedButton;
    RoundedSpeedButton4: TRoundedSpeedButton;
    RoundedSpeedButton5: TRoundedSpeedButton;
    RoundedSpeedButton8: TRoundedSpeedButton;
    RoundedSpeedButton11: TRoundedSpeedButton;
    RoundedSpeedButton12: TRoundedSpeedButton;
    RoundedSpeedButton10: TRoundedSpeedButton;
    RoundedSpeedButton13: TRoundedSpeedButton;
    pnlTop: TPanel;
    btnClose: TRoundedSpeedButton;
    Image4: TImage;
    btnMinimize: TRoundedSpeedButton;
    MenuPanel1: TMenuPanel;
    SubToolTimer: TTimer;
    Shape2: TShape;
    Shape3: TShape;
    procedure FormPaint(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnMinimizeClick(Sender: TObject);
    procedure DragForm(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SwitchTool(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure BuyMeaCoffee1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Capture1Click(Sender: TObject);
    procedure SorryNotYet(Sender: TObject);
    procedure Rulers1Click(Sender: TObject);
  private
    FCurrentTool: TTool;
    FShadowForm: TForm;
    procedure InvokeShadow;
    procedure RevokeShadow;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.InvokeShadow;
const
  CornerRadius = 25;
var
  Rgn: HRGN;
begin
  if not Assigned(FShadowForm) then
  begin
    FShadowForm := TForm.Create(nil);
    FShadowForm.BorderStyle := bsNone;
    FShadowForm.Color := TColor($000000);
    FShadowForm.AlphaBlend := True;
    FShadowForm.AlphaBlendValue := 128;
    FShadowForm.Position := poDesigned;
    Rgn := CreateRoundRectRgn(0, 0, Width, Height, CornerRadius, CornerRadius);
    SetWindowRgn(FShadowForm.Handle, Rgn, True);
    FShadowForm.SetBounds(Left, Top, Width, Height);
    FShadowForm.Show;
    FShadowForm.BringToFront;
  end;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
var
  NewWidth, NewHeight: Integer;
  BGColor: TColor;
  NewSize: TSize;
begin
  InvokeShadow;
  if NewFile.ShowModal = mrOK then
  begin
    if not TryStrToInt(NewFile.EditWidth.Text, NewWidth) then NewWidth := 100;
    if not TryStrToInt(NewFile.EditHeight.Text, NewHeight) then NewHeight := 100;

    NewSize.cx := NewWidth;
    NewSize.cy := NewHeight;

    case NewFile.ComboBoxBackgroundContents.ItemIndex of
      0: BGColor := clWhite; // White background
      1: BGColor := clBlack; // Black background
      2: BGColor := clNone;  // Transparent background
    end;

    ShowMessage('Create '+IntToStr(NewWidth)+' x '+IntToStr(NewHeight)+' image named "'+NewFile.EditName.Text+'"');
  end;
  RevokeShadow;
end;

procedure TForm1.RevokeShadow;
begin
  if Assigned(FShadowForm) then
  begin
    FShadowForm.Hide;
    FShadowForm.Free;
    FShadowForm := nil;
  end;
end;

procedure TForm1.Rulers1Click(Sender: TObject);
const
  RULER_WIDTH = 758;  // viewport size
  RULER_HEIGHT = 500; // Viewport size
  RULER_SCALE = 1;    // current zoom level
  // ^ Replace these with your Img properties.
var
  i: Integer;
  GridSize: Integer;
  LabelText: string;
begin
  With Sender as TMenuItem do
  begin
    if Checked = True then
    begin
      RuleTop.Visible := False;
      RuleLeft.Visible := False;
      Checked := False;
    end else begin
      RuleTop.Visible := True;
      RuleLeft.Visible := True;
      Checked := True;

      // Clear the canvases and set up pens
      RuleTop.Canvas.Brush.Color := $00272827;
      RuleTop.Canvas.FillRect(Rect(0, 0, RuleTop.Width, RuleTop.Height));
      RuleLeft.Canvas.Brush.Color := $00272827;
      RuleLeft.Canvas.FillRect(Rect(0, 0, RuleLeft.Width, RuleLeft.Height));

      RuleTop.Canvas.Pen.Color := clGray;
      RuleTop.Canvas.Pen.Width := 1;
      RuleLeft.Canvas.Pen.Color := clGray;
      RuleLeft.Canvas.Pen.Width := 1;

      // Horizontal Ruler (RuleTop)
      GridSize := Trunc(10 * RULER_SCALE);
      for i := 0 to RuleTop.Width div GridSize do
      begin
        RuleTop.Canvas.MoveTo((i * GridSize)+30, 0);
        RuleTop.Canvas.LineTo((i * GridSize)+30, 5);
      end;

      // Vertical Ruler (RuleLeft)
      GridSize := Trunc(10 * RULER_SCALE);
      for i := 0 to RuleLeft.Height div GridSize do
      begin
        RuleLeft.Canvas.MoveTo(0, i * GridSize);
        RuleLeft.Canvas.LineTo(5, i * GridSize);
      end;

      // Add labels every 50 pixels
      RuleTop.Canvas.Font.Color := clSilver;
      RuleLeft.Canvas.Font.Color := clSilver;

      // Horizontal Labels
      for i := 0 to Trunc(RULER_WIDTH / 50) do
      begin
        LabelText := IntToStr(i * 50);
        RuleTop.Canvas.TextOut(Trunc(((i * 50)+30) * RULER_SCALE) + 5, 10, LabelText);
      end;

      // Vertical Labels
      for i := 0 to Trunc(RULER_HEIGHT / 50) do
      begin
        LabelText := IntToStr(i * 50);
        RuleLeft.Canvas.TextOut(10, Trunc(i * 50 * RULER_SCALE) + 5, LabelText);
      end;
    end;
  end;
end;

procedure TForm1.About1Click(Sender: TObject);
begin
  InvokeShadow;
  About.ShowModal;
  RevokeShadow;
end;

procedure TForm1.btnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.btnMinimizeClick(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TForm1.SorryNotYet(Sender: TObject);
begin
  InvokeShadow;
  NotYet.ShowModal;
  RevokeShadow;
end;

procedure TForm1.BuyMeaCoffee1Click(Sender: TObject);
begin
  InvokeShadow;
  BuyCoffee.ShowModal;
  RevokeShadow;
end;

procedure TForm1.Capture1Click(Sender: TObject);
begin
  InvokeShadow;
  Capture.ShowModal;
  RevokeShadow;
end;

procedure TForm1.FormPaint(Sender: TObject);
const
  CornerRadius = 25;
  BorderWidth = 1;
var
  Rgn: HRGN;
  RectBorder: TRect;
begin
  // --- Rounded Corners ---
  Rgn := CreateRoundRectRgn(0, 0, Width, Height, CornerRadius, CornerRadius);
  SetWindowRgn(Handle, Rgn, True);

  // --- Draw Silver Border ---
  RectBorder := Rect(BorderWidth div 2, BorderWidth div 2, Width - BorderWidth div 2 -1, Height - BorderWidth div 2 -1);
  Canvas.Pen.Color := $00555555;
  Canvas.Pen.Width := BorderWidth;
  Canvas.Brush.Style := bsClear;
  Canvas.RoundRect(RectBorder.Left, RectBorder.Top, RectBorder.Right, RectBorder.Bottom, CornerRadius, CornerRadius);
end;

procedure TForm1.SwitchTool(Sender: TObject);
var
  i: Integer;
begin
  FCurrentTool := TTool(TSpeedButton(Sender).Tag);
  {case FCurrentTool of
    None:   ImgView32.Cursor := crDefault;
    Select: ImgView32.Cursor := crCross;
    Move:   ImgView32.Cursor := crSizeAll;
    Draw:   ImgView32.Cursor := TCursor(2);
    Erase:  ImgView32.Cursor := TCursor(4);
  else
    ImgView32.Cursor := crNo;
  end;}

  LabelTool.Caption := GetEnumName(TypeInfo(TTool), Ord(FCurrentTool));
end;

procedure TForm1.DragForm(Sender: TObject; Button: TMouseButton;
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

end.
