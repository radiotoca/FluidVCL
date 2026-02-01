unit DlgCapture;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, RoundedPanel, Vcl.StdCtrls,
  Vcl.Buttons, RoundedSpeedButton, ActiveX, DirectShow9, ComObj,  Vcl.WinXCtrls;

const
  IID_IPropertyBag: TGUID = '{55272A00-42CB-11CE-8135-00AA004BB851}';
  OVF_True: LongBool = True;
  OVF_False: LongBool = False;

type
  // Record to store detailed format information for display and selection
  TFormatInfo = record
    Width: Integer;
    Height: Integer;
    BitCount: Integer;
    FrameRate: Double; // In frames per second
    CompressionCode: DWord; // FourCC code like 'MJPG', 'YUY2'
    OriginalStreamCapsIndex: Integer; // Original index from GetStreamCaps
    ListInternalIndex: Integer; // NEW: The actual index in FDeviceFormatsList
    // Store the raw AM_MEDIA_TYPE as a pointer to allow setting it directly
    // WARNING: This means you MUST CoTaskMemFree pMediaType when done
    pMediaType: PAMMediaType;
  end;
  PFormatInfo = ^TFormatInfo;

  // Helper class to safely store IMoniker objects in the TComboBox.Objects
  TMonikerWrapper = class(TObject)
  private
    FMoniker: IMoniker;
  public
    // Constructor takes an IMoniker and automatically increments its reference count
    constructor Create(AMoniker: IMoniker);
    // Property to access the wrapped IMoniker
    property Moniker: IMoniker read FMoniker;
  end;

  // NEW: A simple class to wrap an integer, allowing it to be stored reliably as a TObject
  TIntegerObject = class(TObject)
  private
    FValue: Integer;
  public
    constructor Create(AValue: Integer);
    property Value: Integer read FValue;
  end;

  TCapture = class(TForm)
    RoundedPanel1: TRoundedPanel;
    pnlTop: TPanel;
    RoundedSpeedButton7: TRoundedSpeedButton;
    Label2: TLabel;
    PanelVideo: TRoundedPanel;
    btnCapture: TRoundedSpeedButton;
    ComboBoxDevices: TComboBox;
    ComboBoxFormats: TComboBox;
    LabelStatus: TLabel;
    LabelResolution: TLabel;
    TimerVideoUpdate: TTimer;
    Button1: TButton;
    procedure FormPaint(Sender: TObject);
    procedure pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RoundedSpeedButton7Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ComboBoxFormatsChange(Sender: TObject);
    procedure ComboBoxDevicesChange(Sender: TObject);
    procedure btnCaptureClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations for DirectShow interfaces and helper methods }
    FIsCapturing: Boolean;
    // Core DirectShow interfaces
    FGraphBuilder: IGraphBuilder;           // Manages the filter graph
    FCaptureGraphBuilder: ICaptureGraphBuilder2; // Helps build common capture graphs
    FMediaControl: IMediaControl;           // Controls the graph's state (run, pause, stop)
    FVideoWindow: IVideoWindow;             // Controls the video rendering window
    FVideoStreamConfig: IAMStreamConfig;     // New: Interface to configure the video stream
    FCaptureFilter: IBaseFilter;            // Field to hold the main video capture filter
    FSampleGrabber: IBaseFilter;         // NEW: The sample grabber interface
    FSampleGrabberFilter: IBaseFilter;      // NEW: The sample grabber filter
    FMediaType: TAMMediaType;               // NEW: The media type of the stream we are grabbing

    // NEW fields for ISampleGrabber approach
    FSampleGrabberIntf: ISampleGrabber;
    FNullRenderer: IBaseFilter;
    // NEW: Camera Control Interfaces (Zoom, Focus)
    FHasZoomControl: Boolean;               // Flag if zoom control is available
    FHasFocusControl: Boolean;              // Flag if focus control is available
    // private fields for format management
    FDeviceFormatsList: TList;              // Stores TFormatInfo records for the current device
    FCurrentMoniker: IMoniker;              // Stores the moniker of the currently selected device
    FSelectedFormatInfo: PFormatInfo;       // Pointer to the currently selected format info from ComboBoxFormats
    // Helper procedures
    procedure ListVideoCaptureDevices;      // Populates the ComboBox with available devices
    procedure ListFormatsForSelectedDevice; // New: Populates the ComboBoxFormats for the selected device
    procedure StartPreview;                 // Starts the video capture and display
    procedure StopPreview;                  // Stops the video capture and releases resources
    procedure HandleError(const Msg: string; HR: HRESULT = S_OK); // Displays status/error messages
  public
    CapturedBitmap1: TBitmap;
    procedure CaptureScreenshotToBitmap(var ABitmap: TBitmap; const ARect: TRect);
  end;

var
  Capture: TCapture;

implementation

{$R *.dfm}

{ TMonikerWrapper }

constructor TMonikerWrapper.Create(AMoniker: IMoniker);
begin
  inherited Create;
  // When an IMoniker is assigned to another interface variable (FMoniker),
  // Delphi's Automatic Reference Counting (ARC) automatically calls _AddRef.
  // When this TMonikerWrapper object is freed, ARC will call _Release on FMoniker.
  FMoniker := AMoniker;
end;

{ TIntegerObject }

constructor TIntegerObject.Create(AValue: Integer);
begin
  inherited Create;
  FValue := AValue;
end;

{ TCapture }

procedure TCapture.CaptureScreenshotToBitmap(var ABitmap: TBitmap; const ARect: TRect);
var
  hr: HRESULT;
  OriginalOwner: OAHWND;
  OriginalLeft, OriginalTop, OriginalWidth, OriginalHeight: Longint;
  hDC: Winapi.Windows.HDC;
  hVideoWnd: OAHWND;
  MemDC: Winapi.Windows.HDC;
  hBitmap: Winapi.Windows.HBITMAP;
  hOldBitmap: Winapi.Windows.HBITMAP;
begin
  // Ensure we have a video window to work with
  if not Assigned(FVideoWindow) then
  begin
    ShowMessage('Video window interface is not assigned.');
    Exit;
  end;

  // Get the original window position and owner to restore them later
  FVideoWindow.get_Owner(OriginalOwner);
  FVideoWindow.GetWindowPosition(OriginalLeft, OriginalTop, OriginalWidth, OriginalHeight);

  try
    // Temporarily hide the video window and set its owner to the desktop
    FVideoWindow.put_Visible(OVF_False);
    FVideoWindow.put_Owner(0);
    // Put it at the top-left corner
    FVideoWindow.SetWindowPosition(0, 0, FSelectedFormatInfo.Width, FSelectedFormatInfo.Height);
    FVideoWindow.put_Visible(OVF_True);

    // Get the Device Context for the video window
    // CORRECTED: Use get_Handle method instead of a non-existent property
    hr := FVideoWindow.get_Owner(hVideoWnd);
//    if hVideoWnd = 0 then
//    begin
//      ShowMessage('Failed to get video window handle.');
//      Exit;
//    end;

    hDC := GetWindowDC(0);
    if hDC = 0 then
    begin
      ShowMessage('Failed to get window DC.');
      Exit;
    end;

    // Create a compatible DC and a bitmap to hold the screenshot
    MemDC := CreateCompatibleDC(hDC);
    hBitmap := CreateCompatibleBitmap(hDC, ARect.Width, ARect.Height);
    hOldBitmap := SelectObject(MemDC, hBitmap);
    sleep(33);

    // Use BitBlt to copy the pixels from the video window to the memory bitmap
    BitBlt(MemDC, 0, 0, ARect.Width, ARect.Height, hDC, ARect.Left, ARect.Top, SRCCOPY);

    // Assign the captured bitmap to the TBitmap object
    if not Assigned(ABitmap) then
      ABitmap := TBitmap.Create;

    // We can't simply assign the handle because the TBitmap will try to destroy it
    // and we still need it for SelectObject. So we load it from a handle instead.
    ABitmap.Handle := hBitmap;
    ABitmap.PixelFormat := pf24bit;

    // The handle is now managed by the TBitmap, so we don't need to delete it.
    // We still need to clean up the DCs.
    SelectObject(MemDC, hOldBitmap);
    DeleteDC(MemDC);
    ReleaseDC(hVideoWnd, hDC);
  finally
    // Always restore the original window settings
    if Assigned(FVideoWindow) then
    begin
      FVideoWindow.put_Visible(OVF_False);
      FVideoWindow.put_Owner(OriginalOwner);
      FVideoWindow.SetWindowPosition(OriginalLeft, OriginalTop, OriginalWidth, OriginalHeight);
      FVideoWindow.put_Visible(OVF_True);
    end;
  end;
end;

procedure TCapture.Button1Click(Sender: TObject);
var
  CapturedBitmap: TBitmap;
  CaptureRect: TRect;
  hVideoWnd: OAHWND;
  hr: HRESULT;
begin
  // First, check if the video window handle is valid
  if not Assigned(FVideoWindow) then
  begin
    ShowMessage('Video window is not ready for capture.');
    Exit;
  end;

  // Check if the handle is valid after the sleep
  hr := FVideoWindow.get_Owner(hVideoWnd);
//  if (hVideoWnd = 0) or Failed(hr) then
//  begin
//    ShowMessage('Could not obtain a valid video window handle. Please try again.');
//    Exit;
//  end;

  // Set the capture area to the full size of the video feed
  CaptureRect := Rect(0, 0, FSelectedFormatInfo.Width, FSelectedFormatInfo.Height);

  // Call the screenshot procedure
  CapturedBitmap := nil; // Initialize the variable
  CaptureScreenshotToBitmap(CapturedBitmap, CaptureRect);

  if Assigned(CapturedBitmap) then
  begin
    try
      // Save the bitmap to a file for demonstration
      CapturedBitmap.SaveToFile('C:\tmp\screenshot.bmp');
      ShowMessage('Screenshot saved successfully!');
    finally
      // Free the bitmap to prevent a memory leak
      CapturedBitmap.Free;
    end;
  end;
end;

procedure TCapture.btnCaptureClick(Sender: TObject);
var
  CapturedBitmap: TBitmap;
  CaptureRect: TRect;
  hVideoWnd: OAHWND;
  hr: HRESULT;
begin
  // First, check if the video window handle is valid
  if not Assigned(FVideoWindow) then
  begin
    ShowMessage('Video window is not ready for capture.');
    Exit;
  end;

  // Check if the handle is valid after the sleep
  hr := FVideoWindow.get_Owner(hVideoWnd);
//  if (hVideoWnd = 0) or Failed(hr) then
//  begin
//    ShowMessage('Could not obtain a valid video window handle. Please try again.');
//    Exit;
//  end;

  // Set the capture area to the full size of the video feed
  CaptureRect := Rect(0, 0, FSelectedFormatInfo.Width, FSelectedFormatInfo.Height);

  // Call the screenshot procedure
  CapturedBitmap := nil; // Initialize the variable
  CaptureScreenshotToBitmap(CapturedBitmap1, CaptureRect);

  if Assigned(CapturedBitmap1) then
  begin
    try
      // Save the bitmap to a file for demonstration
      //CapturedBitmap.SaveToFile('C:\tmp\screenshot.bmp');
      //ShowMessage('Screenshot saved successfully!');
      //CapturedBitmap1.Assign(CapturedBitmap);
    finally
      // Free the bitmap to prevent a memory leak
      CapturedBitmap.Free;
    end;
  end;

  ModalResult := mrOk;
end;

procedure TCapture.HandleError(const Msg: string; HR: HRESULT = S_OK);
begin
  // Displays status and error messages in the LabelStatus
  if HR <> S_OK then
    LabelStatus.Caption := Format('%s (HRESULT: %x)', [Msg, HR])
  else
    LabelStatus.Caption := Msg;
  // Also outputs to IDE's debug log for easier debugging
  OutputDebugString(PChar(LabelStatus.Caption));
end;

procedure TCapture.ListVideoCaptureDevices;
var
  DevEnum: ICreateDevEnum;
  EnumMoniker: IEnumMoniker;
  Moniker: IMoniker;
  PropBag: IPropertyBag;
  Fetched: ULONG;
  Name: OleVariant;
  HR: HRESULT;
  i: Integer; // Loop counter for manual freeing
begin
  // Ensure any active preview is stopped
  StopPreview;

  // --- Manual freeing of existing TMonikerWrapper objects from ComboBoxDevices.Items ---
  // IMPORTANT: Since TComboBox.Items.FreeObjects is not available in this environment,
  // we must manually free the TMonikerWrapper objects before clearing the ComboBox.
  // Iterate backwards for safe freeing when removing items from a list.
  for i := ComboBoxDevices.Items.Count - 1 downto 0 do
  begin
    if Assigned(ComboBoxDevices.Items.Objects[i]) then
    begin
      TMonikerWrapper(ComboBoxDevices.Items.Objects[i]).Free;
      ComboBoxDevices.Items.Objects[i] := nil; // Clear the reference
    end;
  end;
  // --- End of manual freeing ---

  ComboBoxDevices.Clear; // Now it's safe to clear the list
  ComboBoxFormats.Clear; // Clear formats too
  ComboBoxFormats.Enabled := False; // Disable format selection until device is chosen
  //ButtonStart.Enabled := False; // Disable Start until a valid device is selected

  // Add a placeholder item. Index 0 will be "Select a device".
  ComboBoxDevices.Items.AddObject('Select a device', nil);
  ComboBoxDevices.ItemIndex := 0;

  // Initialize COM interface variables to nil (good practice, though ARC helps)
  DevEnum := nil;
  EnumMoniker := nil;
  Moniker := nil;

  try
    // 1. Create the System Device Enumerator (CLSID_SystemDeviceEnum)
    OutputDebugString('ListVideoCaptureDevices: Calling CoCreateInstance for CLSID_SystemDeviceEnum.');
    HR := CoCreateInstance(CLSID_SystemDeviceEnum, nil, CLSCTX_INPROC_SERVER,
                           IID_ICreateDevEnum, DevEnum);
    if Failed(HR) then
    begin
      HandleError('Failed to create system device enumerator (CoCreateInstance).', HR);
      Exit;
    end;
    OutputDebugString('ListVideoCaptureDevices: CoCreateInstance successful.');

    // 2. Create an enumerator for video input devices (CLSID_VideoInputDeviceCategory)
    OutputDebugString('ListVideoCaptureDevices: Calling CreateClassEnumerator for CLSID_VideoInputDeviceCategory.');
    HR := DevEnum.CreateClassEnumerator(CLSID_VideoInputDeviceCategory, EnumMoniker, 0);
    // S_OK means at least one device, S_FALSE means no devices found in category
    if (HR <> S_OK) then
    begin
      if HR = S_FALSE then
        HandleError('No video capture devices found (CreateClassEnumerator returned S_FALSE).')
      else
        HandleError('Failed to create class enumerator for video devices (CreateClassEnumerator).', HR);
      Exit;
    end;
    OutputDebugString('ListVideoCaptureDevices: CreateClassEnumerator successful. Enumerating devices...');

    // 3. Enumerate devices one by one
    while EnumMoniker.Next(1, Moniker, @Fetched) = S_OK do
    begin
      PropBag := nil; // Reset PropBag for each iteration
      try
        // 4. Bind the Moniker to its IPropertyBag interface to read properties
        OutputDebugString('ListVideoCaptureDevices: Binding Moniker to IPropertyBag.');
        HR := Moniker.BindToStorage(nil, nil, IID_IPropertyBag, PropBag);
        if Succeeded(HR) and Assigned(PropBag) then
        begin
          try
            Name := ''; // Initialize OleVariant
            // 5. Read the 'FriendlyName' property
            OutputDebugString('ListVideoCaptureDevices: Reading FriendlyName.');
            HR := PropBag.Read('FriendlyName', Name, nil);
            if Succeeded(HR) then
            begin
              OutputDebugString(PChar(Format('ListVideoCaptureDevices: Found device: %s', [String(Name)])));
              // Add device name to ComboBox.
              // Store a TMonikerWrapper object containing the Moniker.
              // TMonikerWrapper handles the IMoniker's reference counting.
              ComboBoxDevices.Items.AddObject(String(Name), TMonikerWrapper.Create(Moniker));
            end
            else
            begin
              HandleError('Failed to read FriendlyName from device property bag (PropBag.Read).', HR);
            end;
          except
            on E: Exception do
              HandleError('Exception during PropBag.Read: ' + E.Message);
          end;
        end
        else
        begin
          HandleError('Failed to bind moniker to storage or PropBag is nil (BindToStorage).', HR);
        end;
      except
        on E: Exception do
          HandleError('Exception during BindToStorage: ' + E.Message);
      end;
      // Delphi's ARC handles PropBag and Moniker release here.
      // Explicitly setting to nil to clarify immediate release in loop.
      PropBag := nil;
      Moniker := nil;
    end;
  finally
    // DevEnum and EnumMoniker are also released by ARC when exiting the procedure.
  end;
  // This status message should only appear if devices were actually added, or if no errors occurred
  if ComboBoxDevices.Items.Count > 1 then // Greater than 1 because of "Select a device" placeholder
  begin
    HandleError(Format('Found %d video capture device(s). Select one.', [ComboBoxDevices.Items.Count - 1]));
    OutputDebugString(PChar(Format('ListVideoCaptureDevices: Populated %d devices.', [ComboBoxDevices.Items.Count - 1])));
  end
  else
  begin
    HandleError('No video capture devices found.');
    OutputDebugString('ListVideoCaptureDevices: No devices found.');
  end;
end;

procedure TCapture.ListFormatsForSelectedDevice;
var
  HR: HRESULT;
  CaptureFilter: IBaseFilter;
  PinEnum: IEnumPins;
  Pin: IPin;
  Count, Size: Integer;
  i: Integer;
  Caps: TVideoStreamConfigCaps;
  pmt: PAMMediaType;
  VideoInfoHeader: PVideoInfoHeader;
  FormatDisplayName: string;
  CurrentFormatInfo: PFormatInfo;
  CompressionStr: AnsiString;
  SelectedMonikerWrapper: TMonikerWrapper;
  MonikerToUse: IMoniker;
  P_PIN_CATEGORY_PREVIEW: PGUID; // For FindInterface
  P_MEDIATYPE_Video: PGUID;      // For FindInterface
  P_IID_IAMStreamConfig: PGUID;  // For FindInterface
  validFormatListIndex: Integer; // New counter for contiguous list indexing
begin
  OutputDebugString('ListFormatsForSelectedDevice: Starting...');
  // Ensure FSelectedFormatInfo is nullified before potentially removing its underlying data
  FSelectedFormatInfo := nil;

  // --- START OF FORMAT-RELATED CLEANUP (moved from StopPreview) ---
  // Free previously stored format info if any
  if Assigned(FDeviceFormatsList) then
  begin
    OutputDebugString('ListFormatsForSelectedDevice: Freeing previous FDeviceFormatsList contents.');
    for i := 0 to FDeviceFormatsList.Count - 1 do
    begin
      CurrentFormatInfo := PFormatInfo(FDeviceFormatsList.Items[i]); // Re-use CurrentFormatInfo for clarity
      if Assigned(CurrentFormatInfo) then
      begin
        if Assigned(CurrentFormatInfo^.pMediaType) then
        begin
          if CurrentFormatInfo^.pMediaType^.cbFormat <> 0 then CoTaskMemFree(CurrentFormatInfo^.pMediaType^.pbFormat);
          if Assigned(CurrentFormatInfo^.pMediaType^.pUnk) then CurrentFormatInfo^.pMediaType^.pUnk._Release;
          CoTaskMemFree(CurrentFormatInfo^.pMediaType);
        end;
        Dispose(CurrentFormatInfo); // Dispose the TFormatInfo record
      end;
    end;
    FDeviceFormatsList.Free; // Free the TList object itself
    FDeviceFormatsList := nil;
  end;

  // Free TIntegerObject instances from ComboBoxFormats.Items.Objects
  if Assigned(ComboBoxFormats) then
  begin
    OutputDebugString('ListFormatsForSelectedDevice: Freeing TIntegerObject instances from ComboBoxFormats.');
    for i := ComboBoxFormats.Items.Count - 1 downto 0 do
    begin
      if Assigned(ComboBoxFormats.Items.Objects[i]) and
         (ComboBoxFormats.Items.Objects[i] is TIntegerObject) then
      begin
        TIntegerObject(ComboBoxFormats.Items.Objects[i]).Free;
        ComboBoxFormats.Items.Objects[i] := nil;
      end;
    end;
  end;
  // --- END OF FORMAT-RELATED CLEANUP (moved from StopPreview) ---

  // Clear GUI after freeing objects
  ComboBoxFormats.Clear;
  ComboBoxFormats.Enabled := False;
  //ButtonStart.Enabled := False;

  // Clear previous interfaces related to capture filter/formats
  FVideoStreamConfig := nil;
  FCurrentMoniker := nil; // Clear current moniker (will be set below for selected device)

  // If no device is selected (index 0), exit
  if ComboBoxDevices.ItemIndex <= 0 then
  begin
    HandleError('No device selected to list formats.');
    OutputDebugString('ListFormatsForSelectedDevice: No device selected (ItemIndex <= 0).');
    Exit;
  end;

  // Get the moniker for the selected device
  SelectedMonikerWrapper := ComboBoxDevices.Items.Objects[ComboBoxDevices.ItemIndex] as TMonikerWrapper;
  MonikerToUse := SelectedMonikerWrapper.Moniker;
  FCurrentMoniker := MonikerToUse; // Store the moniker for StartPreview
  OutputDebugString(PChar(Format('ListFormatsForSelectedDevice: Selected device: %s', [ComboBoxDevices.Text])));

  // Initialize DirectShow interfaces needed for format enumeration
  FGraphBuilder := nil;
  FCaptureGraphBuilder := nil;
  CaptureFilter := nil;
  PinEnum := nil;
  Pin := nil;

  try
    // 1. Create a temporary Filter Graph Manager
    OutputDebugString('ListFormatsForSelectedDevice: CoCreateInstance for CLSID_FilterGraph.');
    HR := CoCreateInstance(CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER,
                           IID_IGraphBuilder, FGraphBuilder);
    if Failed(HR) then
    begin
      HandleError('Failed to create temporary filter graph (CoCreateInstance).', HR);
      Exit;
    end;

    // 2. Bind the Moniker to an IBaseFilter (the capture device)
    OutputDebugString('ListFormatsForSelectedDevice: Binding Moniker to IBaseFilter.');
    HR := MonikerToUse.BindToObject(nil, nil, IID_IBaseFilter, CaptureFilter);
    if Failed(HR) then
    begin
      HandleError('Failed to bind device moniker to filter (BindToObject).', HR);
      Exit;
    end;

    // 3. Add the capture filter to the graph (needed for pin enumeration)
    OutputDebugString('ListFormatsForSelectedDevice: Adding capture filter to graph.');
    HR := FGraphBuilder.AddFilter(CaptureFilter, 'Temp Capture Filter');
    if Failed(HR) then
    begin
      HandleError('Failed to add temporary capture filter to graph (AddFilter).', HR);
      Exit;
    end;

    // 4. Enumerate pins on the capture filter
    OutputDebugString('ListFormatsForSelectedDevice: Enumerating pins on capture filter.');
    HR := CaptureFilter.EnumPins(PinEnum);
    if Failed(HR) then
    begin
      HandleError('Failed to enumerate pins on device (EnumPins).', HR);
      Exit;
    end;

    // 5. Find the output pin that supports IAMStreamConfig (for video)
    OutputDebugString('ListFormatsForSelectedDevice: Searching for IAMStreamConfig pin.');
    while PinEnum.Next(1, Pin, nil) = S_OK do
    begin
      HR := Pin.QueryInterface(IID_IAMStreamConfig, FVideoStreamConfig);
      if Succeeded(HR) and Assigned(FVideoStreamConfig) then
      begin
        OutputDebugString('ListFormatsForSelectedDevice: Found IAMStreamConfig pin.');
        Break; // Found the pin with IAMStreamConfig
      end;
      Pin := nil; // Release current pin before checking next
    end;

    if not Assigned(FVideoStreamConfig) then
    begin
      HandleError('No IAMStreamConfig interface found on device pins. Cannot list formats (QueryInterface).');
      Exit;
    end;

    // 6. Get the number of stream capabilities (formats)
    OutputDebugString('ListFormatsForSelectedDevice: Getting number of capabilities.');
    HR := FVideoStreamConfig.GetNumberOfCapabilities(Count, Size);
    if Failed(HR) then
    begin
      HandleError('Failed to get number of capabilities from device (GetNumberOfCapabilities).', HR);
      Exit;
    end;
    OutputDebugString(PChar(Format('ListFormatsForSelectedDevice: Found %d capabilities, size %d.', [Count, Size])));

    if Size <> SizeOf(TVideoStreamConfigCaps) then
    begin
      HandleError('Unexpected TVideoStreamConfigCaps size. DirectShow API mismatch? (Size check).', HR);
      Exit;
    end;

    FDeviceFormatsList := TList.Create; // Create list to store format info
    validFormatListIndex := 0; // Initialize new counter

    // 7. Iterate through each capability (format)
    OutputDebugString('ListFormatsForSelectedDevice: Iterating through capabilities...');
    for i := 0 to Count - 1 do
    begin
      pmt := nil; // Initialize pointer
      FillChar(Caps, SizeOf(Caps), 0); // Clear the capabilities structure

      // Get the stream capabilities (media type and extended caps)
      HR := FVideoStreamConfig.GetStreamCaps(i, pmt, TVideoStreamConfigCaps(Caps));
      if Failed(HR) then
      begin
        OutputDebugString(PChar(Format('Warning: Failed to get stream caps for index %d (HRESULT: %x)', [i, HR])));
        Continue; // Skip if unable to get capabilities for this index
      end;

      // 8. Process the AM_MEDIA_TYPE structure (assuming VideoInfo format)
      if (pmt^.formattype = FORMAT_VideoInfo) and (pmt^.cbFormat >= SizeOf(TVideoInfoHeader)) then
      begin
        VideoInfoHeader := PVideoInfoHeader(pmt^.pbFormat);

        // Extract FourCC compression string for display
        SetLength(CompressionStr, 4);
        CompressionStr[1] := AnsiChar(Byte(VideoInfoHeader.bmiHeader.biCompression));
        CompressionStr[2] := AnsiChar(Byte(VideoInfoHeader.bmiHeader.biCompression shr 8));
        CompressionStr[3] := AnsiChar(Byte(VideoInfoHeader.bmiHeader.biCompression shr 16));
        CompressionStr[4] := AnsiChar(Byte(VideoInfoHeader.bmiHeader.biCompression shr 24));

        // Create a TFormatInfo record and populate it
        New(CurrentFormatInfo); // Allocate memory for the record
        CurrentFormatInfo^.Width := VideoInfoHeader.bmiHeader.biWidth;
        CurrentFormatInfo^.Height := VideoInfoHeader.bmiHeader.biHeight;
        CurrentFormatInfo^.BitCount := VideoInfoHeader.bmiHeader.biBitCount;
        CurrentFormatInfo^.CompressionCode := VideoInfoHeader.bmiHeader.biCompression;
        CurrentFormatInfo^.OriginalStreamCapsIndex := i; // Store original index
        CurrentFormatInfo^.ListInternalIndex := validFormatListIndex; // Store contiguous index

        if VideoInfoHeader.AvgTimePerFrame > 0 then
          CurrentFormatInfo^.FrameRate := 10000000.0 / VideoInfoHeader.AvgTimePerFrame
        else
          CurrentFormatInfo^.FrameRate := 0;

        // Store the allocated PAMMediaType directly for later use in SetFormat
        CurrentFormatInfo^.pMediaType := pmt; // Takes ownership of pmt pointer

        // Create a user-friendly display string
        FormatDisplayName := Format('%s: %dx%d (%d bit) @ %.0f FPS',
          [string(CompressionStr), CurrentFormatInfo^.Width, CurrentFormatInfo^.Height,
           CurrentFormatInfo^.BitCount, CurrentFormatInfo^.FrameRate]);

        OutputDebugString(PChar(Format('ListFormatsForSelectedDevice: Adding format: %s with original index %d, list index %d', [FormatDisplayName, CurrentFormatInfo^.OriginalStreamCapsIndex, CurrentFormatInfo^.ListInternalIndex])));
        // *** Store a TIntegerObject wrapping the contiguous list index ***
        ComboBoxFormats.Items.AddObject(FormatDisplayName, TIntegerObject.Create(CurrentFormatInfo^.ListInternalIndex));
        FDeviceFormatsList.Add(CurrentFormatInfo); // Add the actual PFormatInfo to our master list
        Inc(validFormatListIndex); // Increment only for valid formats added
      end
      else
      begin
        OutputDebugString(PChar(Format('Warning: Format index %d is not FORMAT_VideoInfo or invalid size. Skipping and freeing pmt.', [i])));
        // If not a VideoInfo format, or invalid size, free the PMT
        if Assigned(pmt) then
        begin
          if pmt^.cbFormat <> 0 then CoTaskMemFree(pmt^.pbFormat);
          if Assigned(pmt^.pUnk) then pmt^.pUnk._Release;
          CoTaskMemFree(pmt);
        end;
      end;
    end;

    // After populating, select the first format by default if available
    if validFormatListIndex > 0 then // Use validFormatListIndex for count
    begin
      ComboBoxFormats.ItemIndex := 0; // Select the first listed format
      OutputDebugString(PChar(Format('ListFormatsForSelectedDevice: Setting ItemIndex to 0. Triggering ComboBoxFormatsChange for initial selection. ComboBoxFormats.Items.Count: %d', [validFormatListIndex])));
      ComboBoxFormatsChange(nil);     // Manually trigger change to set FSelectedFormatInfo
      ComboBoxFormats.Enabled := True; // Enable format selection
      //ButtonStart.Enabled := True;    // Enable Start button
      HandleError(Format('Found %d formats for %s. Selected first available.', [validFormatListIndex, ComboBoxDevices.Text]));
    end
    else
    begin
      HandleError('No supported video formats found for selected device.');
      OutputDebugString('ListFormatsForSelectedDevice: No formats found for selected device.');
    end;

  finally
    // Release temporary COM objects used only for enumeration
    // FVideoStreamConfig is stored in a field, so it is not released here.
    Pin := nil; // Release current pin if loop broke early
    PinEnum := nil;
    CaptureFilter := nil;
    FCaptureGraphBuilder := nil; // Release temp builder
    FGraphBuilder := nil;       // Release temp graph
  end;
  OutputDebugString('ListFormatsForSelectedDevice: Finished.');
end;

procedure TCapture.StartPreview;
var
  HR: HRESULT;
  pmtToSet: PAMMediaType;
  P_PIN_CATEGORY_PREVIEW: PGUID;
  P_MEDIATYPE_Video: PGUID;
  PinEnum: IEnumPins;
  Pin: IPin;
  MediaType: TAMMediaType;
begin
  OutputDebugString('StartPreview: Starting...');

  if ComboBoxDevices.ItemIndex <= 0 then
  begin
    HandleError('Please select a video device from the list.');
    OutputDebugString('StartPreview: Error - No device selected.');
    Exit;
  end;

  if not Assigned(FSelectedFormatInfo) or (ComboBoxFormats.ItemIndex < 0) then
  begin
    HandleError('Please select a video format from the list.');
    OutputDebugString(PChar(Format('StartPreview: Error - No format selected (FSelectedFormatInfo: %p, ComboBoxFormats.ItemIndex: %d, ComboBoxFormats.Items.Count: %d).', [FSelectedFormatInfo, ComboBoxFormats.ItemIndex, ComboBoxFormats.Items.Count])));
    Exit;
  end;

  OutputDebugString(PChar(Format('StartPreview: Selected device: %s, Format: %s', [ComboBoxDevices.Text, ComboBoxFormats.Text])));

  // Initialize DirectShow interfaces to nil before creating them
  FGraphBuilder := nil;
  FCaptureGraphBuilder := nil;
  FMediaControl := nil;
  FVideoWindow := nil;
  FVideoStreamConfig := nil;
  FCaptureFilter := nil;
  FSampleGrabber := nil;
  FSampleGrabberIntf := nil;

  try
    // 1. Create the Filter Graph Manager
    OutputDebugString('StartPreview: CoCreateInstance for CLSID_FilterGraph.');
    HR := CoCreateInstance(CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER,
      IID_IGraphBuilder, FGraphBuilder);
    if Failed(HR) then
    begin
      HandleError('Failed to create filter graph manager (CoCreateInstance).', HR);
      Exit;
    end;

    // 2. Create the Capture Graph Builder 2
    OutputDebugString('StartPreview: CoCreateInstance for CLSID_CaptureGraphBuilder2.');
    HR := CoCreateInstance(CLSID_CaptureGraphBuilder2, nil, CLSCTX_INPROC_SERVER,
      IID_ICaptureGraphBuilder2, FCaptureGraphBuilder);
    if Failed(HR) then
    begin
      HandleError('Failed to create capture graph builder (CoCreateInstance).', HR);
      Exit;
    end;

    // 3. Set the filter graph for the capture graph builder
    OutputDebugString('StartPreview: Setting filter graph for builder.');
    HR := FCaptureGraphBuilder.SetFiltergraph(FGraphBuilder);
    if Failed(HR) then
    begin
      HandleError('Failed to set filter graph for builder (SetFiltergraph).', HR);
      Exit;
    end;

    // 4. Bind the selected Moniker to the IBaseFilter interface
    OutputDebugString('StartPreview: Binding selected Moniker to capture filter.');
    HR := FCurrentMoniker.BindToObject(nil, nil, IID_IBaseFilter, FCaptureFilter);
    if Failed(HR) then
    begin
      HandleError('Failed to bind moniker to capture filter. Device might be in use or unavailable (BindToObject).', HR);
      Exit;
    end;

    // 5. Add the capture filter to the graph
    OutputDebugString('StartPreview: Adding capture filter to graph.');
    HR := FGraphBuilder.AddFilter(FCaptureFilter, 'Video Capture Source');
    if Failed(HR) then
    begin
      HandleError('Failed to add capture filter to graph (AddFilter).', HR);
      Exit;
    end;

    // 6. Get IAMStreamConfig by enumerating pins
    FVideoStreamConfig := nil;
    PinEnum := nil;
    Pin := nil;
    OutputDebugString('StartPreview: Enumerating pins on capture filter to get IAMStreamConfig.');
    HR := FCaptureFilter.EnumPins(PinEnum);
    if Failed(HR) then
    begin
      HandleError('Failed to enumerate pins on device (EnumPins) for IAMStreamConfig acquisition.', HR);
      Exit;
    end;
    while PinEnum.Next(1, Pin, nil) = S_OK do
    begin
      HR := Pin.QueryInterface(IID_IAMStreamConfig, FVideoStreamConfig);
      if Succeeded(HR) and Assigned(FVideoStreamConfig) then
      begin
        OutputDebugString('StartPreview: Found IAMStreamConfig on a pin.');
        Break;
      end;
      Pin := nil;
    end;
    if not Assigned(FVideoStreamConfig) then
    begin
      HandleError('No IAMStreamConfig interface found on device pins. Cannot set format (QueryInterface on pins).');
      Exit;
    end;
    OutputDebugString('StartPreview: IAMStreamConfig acquired.');

    // 7. Set the selected format
    pmtToSet := FSelectedFormatInfo^.pMediaType;
    OutputDebugString('StartPreview: Setting stream format.');
    HR := FVideoStreamConfig.SetFormat(pmtToSet);
    if Failed(HR) then
    begin
      HandleError('Failed to set video format. Device might not support selected format in practice (SetFormat).', HR);
      Exit;
    end;
    HandleError(Format('Format set to %s.', [ComboBoxFormats.Text]));
    OutputDebugString(PChar(Format('StartPreview: Format set to %s.', [ComboBoxFormats.Text])));

    // 8. Create the Sample Grabber filter
    HR := CoCreateInstance(CLSID_SampleGrabber, nil, CLSCTX_INPROC_SERVER,
      IID_IBaseFilter, FSampleGrabber);
    if Failed(HR) then
    begin
      HandleError('Failed to create Sample Grabber filter.', HR);
      Exit;
    end;
    HR := FGraphBuilder.AddFilter(FSampleGrabber, 'Sample Grabber');
    if Failed(HR) then
    begin
      HandleError('Failed to add Sample Grabber to graph.', HR);
      Exit;
    end;
    HR := FSampleGrabber.QueryInterface(IID_ISampleGrabber, FSampleGrabberIntf);
    if Failed(HR) then
    begin
      HandleError('Failed to get ISampleGrabber interface.', HR);
      Exit;
    end;

    // 9. Configure the Sample Grabber
    // Set to accept any video media type
    ZeroMemory(@MediaType, SizeOf(MediaType));
    MediaType.majortype := MEDIATYPE_Video;
    FSampleGrabberIntf.SetMediaType(MediaType);
    // Set to buffer mode so we can read the samples manually
    FSampleGrabberIntf.SetBufferSamples(OVF_True);

    // 10. Render the video stream from the capture filter through the Sample Grabber
    P_PIN_CATEGORY_PREVIEW := @PIN_CATEGORY_PREVIEW;
    P_MEDIATYPE_Video := @MEDIATYPE_Video;
    OutputDebugString('StartPreview: Rendering preview stream.');

    // We render the stream through the SampleGrabber.
    // The final renderer is a default video renderer that DirectShow will add.
    HR := FCaptureGraphBuilder.RenderStream(
      P_PIN_CATEGORY_PREVIEW,
      P_MEDIATYPE_Video,
      FCaptureFilter,
      FSampleGrabber, // Intermediate filter is now the Sample Grabber
      nil             // DirectShow will find a default video renderer here
    );
    if Failed(HR) then
    begin
      HandleError('Failed to render preview stream. Device might not support preview or a suitable format (RenderStream).', HR);
      Exit;
    end;
    OutputDebugString('StartPreview: Preview stream rendered successfully.');

    // 11. Get the IMediaControl interface
    OutputDebugString('StartPreview: Getting IMediaControl.');
    FMediaControl := FGraphBuilder as IMediaControl;
    if not Assigned(FMediaControl) then
    begin
      HandleError('Failed to get IMediaControl interface from graph (IMediaControl cast).');
      Exit;
    end;

    // 12. Get the IVideoWindow interface from the graph builder.
    OutputDebugString('StartPreview: Getting IVideoWindow.');
    FVideoWindow := FGraphBuilder as IVideoWindow;
    if Assigned(FVideoWindow) then
    begin
      OutputDebugString('StartPreview: Setting video window owner.');
      // The IVideoWindow will now use the TImage32's handle directly
      HR := FVideoWindow.put_Owner(PanelVideo.Handle);
      if Failed(HR) then HandleError('Failed to set video window owner (put_Owner).', HR);

      OutputDebugString('StartPreview: Setting video window style.');
      HR := FVideoWindow.put_WindowStyle(WS_CHILD or WS_CLIPCHILDREN);
      if Failed(HR) then HandleError('Failed to set video window style (put_WindowStyle).', HR);

      // Position the video window to fill the TImage32 client area
      OutputDebugString('StartPreview: Setting video window position.');
      HR := FVideoWindow.put_Left(0);
      HR := FVideoWindow.put_Top(0);
      HR := FVideoWindow.put_Width(PanelVideo.Width);
      HR := FVideoWindow.put_Height(PanelVideo.Height);
      if Failed(HR) then HandleError('Failed to set video window position (put_position).', HR);

      OutputDebugString('StartPreview: Making video window visible.');
      HR := FVideoWindow.put_Visible(OVF_True);
      if Failed(HR) then HandleError('Failed to make video window visible (put_Visible).', HR);
    end
    else
    begin
      HandleError('Could not get IVideoWindow interface. Video might not display visually (IVideoWindow cast).');
    end;

    // 13. Run the graph
    OutputDebugString('StartPreview: Running graph.');
    HR := FMediaControl.Run;
    if Failed(HR) then
    begin
      HandleError('Failed to run graph. Device might be busy or unsupported (Run).', HR);
      StopPreview;
      Exit;
    end;

    HandleError('Preview started successfully.');
    OutputDebugString('StartPreview: Preview started successfully.');

  except
    on E: Exception do
    begin
      HandleError('An unexpected error occurred during preview start: ' + E.Message);
      OutputDebugString(PChar(Format('StartPreview: Exception occurred: %s', [E.Message])));
      StopPreview;
    end;
  end;
  OutputDebugString('StartPreview: Finished.');
end;

procedure TCapture.StopPreview;
var
  HR: HRESULT; // This local variable is fine
begin
  OutputDebugString('StopPreview: Starting...');
  // Stop the graph if it's running
  if Assigned(FMediaControl) then
  begin
    OutputDebugString('StopPreview: Stopping MediaControl.');
    FMediaControl.Stop;
    FMediaControl := nil; // Release the interface
  end;

  // Detach and hide the video window
  if Assigned(FVideoWindow) then
  begin
    OutputDebugString('StopPreview: Hiding and detaching VideoWindow.');
    FVideoWindow.put_Visible(OVF_False); // Hide the video window
    FVideoWindow.put_Owner(0); // Release ownership of the window handle
    FVideoWindow := nil;       // Release the interface
  end;

  // Crucial: Remove filters from the graph before releasing the graph itself
  if Assigned(FGraphBuilder) then
  begin
    OutputDebugString('StopPreview: Removing filters from graph.');
    if Assigned(FCaptureFilter) then
    begin
      FGraphBuilder.RemoveFilter(FCaptureFilter);
      FCaptureFilter := nil; // Release the interface
    end;
  end;

  // Release all DirectShow graph-related interfaces.
  // Delphi's ARC will automatically handle the _Release calls as they go out of scope or are set to nil.
  OutputDebugString('StopPreview: Releasing DirectShow interfaces.');
  FGraphBuilder := nil;
  FCaptureGraphBuilder := nil;
  FVideoStreamConfig := nil; // Release stream config interface
  // FCurrentMoniker is the selected device moniker, it should persist until device is changed
  // so do not release FCurrentMoniker here.

  // Commented out: NEW: Stop and clean up audio
  // StopAudioPassthrough;

  // Do NOT free FDeviceFormatsList or clear ComboBoxFormats here.
  // These are now handled by ListFormatsForSelectedDevice (when device changes)
  // and FormDestroy (on app close).
  // FSelectedFormatInfo should also persist until the device or format dropdown changes.

  HandleError('Preview stopped.');
  OutputDebugString('StopPreview: Preview stopped.');
  //ButtonStart.Enabled := True;  // Enable Start button
  //ButtonStop.Enabled := False;  // Disable Stop button
  OutputDebugString('StopPreview: Finished.');
end;

procedure TCapture.ComboBoxDevicesChange(Sender: TObject);
begin
  StopPreview; // Stop any active preview
  ListFormatsForSelectedDevice; // Populate the formats combobox (this will also clean up old formats)
  ComboBoxFormats.ItemIndex := 1;
end;

procedure TCapture.ComboBoxFormatsChange(Sender: TObject);
var
  SelectedIntegerObject: TIntegerObject; // Declare as TIntegerObject
  DebugMessage: string;
  FourCCString: string; // Declare a string to hold the FourCC code
begin
  OutputDebugString(PChar(Format('ComboBoxFormatsChange: Selected format index %d. Text: %s. Items.Count: %d', [ComboBoxFormats.ItemIndex, ComboBoxFormats.Text, ComboBoxFormats.Items.Count])));
  // Update the currently selected format information
  if (ComboBoxFormats.ItemIndex >= 0) and (ComboBoxFormats.ItemIndex < ComboBoxFormats.Items.Count) then
  begin
    // Retrieve the TIntegerObject.
    // Ensure it's assigned and is indeed a TIntegerObject.
    SelectedIntegerObject := ComboBoxFormats.Items.Objects[ComboBoxFormats.ItemIndex] as TIntegerObject;
    if Assigned(SelectedIntegerObject) then
    begin
      // Get the actual integer index from the TIntegerObject's Value property.
      // This is the ListInternalIndex we stored earlier.
      OutputDebugString(PChar(Format('ComboBoxFormatsChange: Retrieved TIntegerObject Value (ListInternalIndex): %d.', [SelectedIntegerObject.Value])));

      // Now use this ListInternalIndex to get the actual PFormatInfo from FDeviceFormatsList
      if (SelectedIntegerObject.Value >= 0) and (SelectedIntegerObject.Value < FDeviceFormatsList.Count) then
      begin
        FSelectedFormatInfo := PFormatInfo(FDeviceFormatsList.Items[SelectedIntegerObject.Value]);
        OutputDebugString(PChar(Format('ComboBoxFormatsChange: FSelectedFormatInfo set to %p from FDeviceFormatsList[%d].', [FSelectedFormatInfo, SelectedIntegerObject.Value])));

        // --- Convert FourCC code to string manually ---
        SetLength(FourCCString, 4);
        FourCCString[1] := Char(FSelectedFormatInfo^.CompressionCode and $FF);                 // 1st byte (LSB)
        FourCCString[2] := Char((FSelectedFormatInfo^.CompressionCode shr 8) and $FF);        // 2nd byte
        FourCCString[3] := Char((FSelectedFormatInfo^.CompressionCode shr 16) and $FF);       // 3rd byte
        FourCCString[4] := Char((FSelectedFormatInfo^.CompressionCode shr 24) and $FF);       // 4th byte (MSB)

        // --- Display format details using ShowMessage ---
        DebugMessage := Format(
          'Selected Format Details (List Index %d, Original Stream Caps Index %d):' + sLineBreak +
          '  Width: %d' + sLineBreak +
          '  Height: %d' + sLineBreak +
          '  Bit Count: %d' + sLineBreak +
          '  Frame Rate: %.0f FPS' + sLineBreak +
          '  Compression: %s (0x%x)',
          [
            FSelectedFormatInfo^.ListInternalIndex,
            FSelectedFormatInfo^.OriginalStreamCapsIndex,
            FSelectedFormatInfo^.Width,
            FSelectedFormatInfo^.Height,
            FSelectedFormatInfo^.BitCount,
            FSelectedFormatInfo^.FrameRate,
            FourCCString,
            FSelectedFormatInfo^.CompressionCode
          ]
        );
        LabelResolution.Caption := Format(
          '  Width: %d' + '  Height: %d',
          [
            FSelectedFormatInfo^.Width,
            FSelectedFormatInfo^.Height
          ]);
        //ShowMessage(DebugMessage);
        OutputDebugString(PChar(DebugMessage));
        // --- End ShowMessage ---\

        //ButtonStart.Enabled := True; // Enable Start button when a format is selected
      end
      else
      begin
        FSelectedFormatInfo := nil;
        ShowMessage(Format('Error: Invalid ListInternalIndex (%d) retrieved from ComboBox. Please re-select device/format.', [SelectedIntegerObject.Value]));
        OutputDebugString(PChar(Format('ComboBoxFormatsChange: Invalid ListInternalIndex (%d) from ComboBox. FSelectedFormatInfo set to nil.', [SelectedIntegerObject.Value])));
        //ButtonStart.Enabled := False;
      end;
    end
    else // The object stored was not a TIntegerObject or was nil
    begin
      FSelectedFormatInfo := nil;
      ShowMessage(Format('Error: ComboBoxFormats.Items.Objects[%d] is not a valid TIntegerObject. Internal error.', [ComboBoxFormats.ItemIndex]));
      OutputDebugString(PChar(Format('ComboBoxFormatsChange: ComboBoxFormats.Items.Objects[%d] is not a TIntegerObject or is nil. FSelectedFormatInfo set to nil.', [ComboBoxFormats.ItemIndex])));
      //ButtonStart.Enabled := False;
    end;
  end
  else
  begin
    FSelectedFormatInfo := nil;
    OutputDebugString(PChar(Format('ComboBoxFormatsChange: Invalid ComboBox ItemIndex (%d). FSelectedFormatInfo set to nil.', [ComboBoxFormats.ItemIndex])));
    //ButtonStart.Enabled := False;
  end;
end;

procedure TCapture.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  StopPreview;
  CanClose := True;
end;

procedure TCapture.FormPaint(Sender: TObject);
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

procedure TCapture.FormShow(Sender: TObject);
begin
  ListVideoCaptureDevices;
  ComboBoxDevices.ItemIndex := 1;
  ListFormatsForSelectedDevice; // Populate the formats combobox (this will also clean up old formats)
  ComboBoxFormats.ItemIndex := 1;
  StartPreview;
end;

procedure TCapture.pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TCapture.RoundedSpeedButton7Click(Sender: TObject);
begin
  Close;
end;

end.

