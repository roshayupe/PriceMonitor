unit UnitMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxCheckBox, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinBasic, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkroom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinOffice2019Black, dxSkinOffice2019Colorful,
  dxSkinOffice2019DarkGray, dxSkinOffice2019White, dxSkinPumpkin, dxSkinSeven,
  dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver,
  dxSkinSpringtime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld,
  dxSkinTheBezier, dxSkinValentine, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinWXI, dxSkinXmas2008Blue, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCheckComboBox, Vcl.ComCtrls, dxCore, cxDateUtils, cxCalendar,
  Vcl.Menus, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, dxDateRanges, dxScrollbarAnnotations, Data.DB, cxDBData,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, Vcl.StdCtrls, cxButtons, OraCall,
  DBAccess, Ora, MemDS, dxmdaset, Generics.Collections, cxCurrencyEdit;

const
  ST_ACTIVE: integer = 1;

type
  TFormMain = class(TForm)
    cbCompetitors: TcxCheckComboBox;
    deDate: TcxDateEdit;
    cxButtonLoad: TcxButton;
    cxButtonSave: TcxButton;
    cxButtonCancel: TcxButton;
    viewDB: TcxGridDBTableView;
    cxGridMonitoringLevel: TcxGridLevel;
    cxGridMonitoring: TcxGrid;
    OraSession: TOraSession;
    MemData: TdxMemData;
    dsUI: TDataSource;
    viewDBColumn1: TcxGridDBColumn;
    viewDBColumn2: TcxGridDBColumn;
    spGet: TOraStoredProc;
    spSave: TOraStoredProc;
    spGetPrev: TOraStoredProc;
    procedure FormCreate(Sender: TObject);
    procedure cxButtonLoadClick(Sender: TObject);
    procedure cxButtonSaveClick(Sender: TObject);
    procedure cxButtonCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure viewDBStylesGetContentStyle(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
  private
    FSnapshot: TMemoryStream;
    FStyleUp, FStyleDown, FStyleNoPrev: TcxStyle;
    procedure LoadCompetitors(Sender: TObject);
    procedure CheckAllItems(Sender: TObject; AButtonIndex: Integer);
    function GetSelectedCompetitorIds(Cmb: TcxCheckComboBox): TArray<Integer>;
    procedure EnsureGridStructureDxMemDB(const View: TcxGridDBTableView;
                                         const DS: TDataSource;
                                         const CompMap: TDictionary<Integer,string>;
                                         const Mem: TdxMemData);
    function SelectedCompetitors: TArray<Integer>;
    procedure FetchPrevPrices(const MonitorDate: TDate; const Csv: string);
  public
    { Public declarations }
  end;

  function IntArrayToCsv(const A: TArray<Integer>): string;
  function LoadViaStoredProcCSV(const DateValue: TDate; const CsvIds: string;
                                SP: TOraStoredProc): TDataSet;

var
  FormMain: TFormMain;

type
  TPriceKey = record
    ProductID: Integer;
    CompetitorID: Integer;
  end;

var
  PrevPrices: TDictionary<TPriceKey, Double>;

implementation

{$R *.dfm}

function IntArrayToCsv(const A: TArray<Integer>): string;
var i: Integer;
begin
  Result := '';
  for i := 0 to High(A) do
  begin
    if Result <> '' then Result := Result + ',';
    Result := Result + IntToStr(A[i]);
  end;
end;

procedure TFormMain.CheckAllItems(Sender: TObject; AButtonIndex: Integer);
begin
  with (Sender as TcxCheckComboBox) do
    if AButtonIndex = 1 then
      for var I := 0 to Properties.Items.Count - 1 do
          States[I] := cbsChecked;
end;

procedure TFormMain.cxButtonCancelClick(Sender: TObject);
var
  cur: Integer;
begin
  // If user is editing a single cell — just cancel that edit
  if MemData.State in [dsEdit, dsInsert] then
    MemData.Cancel;

  // If we have a snapshot — restore it, otherwise just reload from DB
  if (FSnapshot <> nil) and (FSnapshot.Size > 0) then
  begin
    cur := MemData.RecNo; // optional: keep row position
    MemData.DisableControls;
    try
      FSnapshot.Position := 0;
      MemData.Close;
      MemData.LoadFromStream(FSnapshot); // restores data + fields
      MemData.Open;
      if (cur > 0) and (cur <= MemData.RecordCount) then
        MemData.RecNo := cur;
    finally
      MemData.EnableControls;
    end;
  end
  else
  begin
    // Fallback: no snapshot — just reload from DB
    cxButtonLoadClick(nil);
  end;
end;

procedure TFormMain.cxButtonLoadClick(Sender: TObject);
var
  CompIds: TArray<Integer>;
  Csv: string;
  D: TDataSet; // result of SP.Open
  CompMap: TDictionary<Integer,string>;
  RowOf: TDictionary<Integer,Integer>;
  ProdID, CompID, RowIndex: Integer;
  ProdName: string;
  PriceVal: Variant;
  Bm: TBookmark;
  AliasCol: string;
begin

  // Editing allowed only for today
  viewDB.OptionsData.Editing := (Trunc(deDate.Date) = Trunc(Date));

  // 1) Collect competitors and build CSV
  CompIds := GetSelectedCompetitorIds(cbCompetitors);
  Csv := IntArrayToCsv(CompIds); // '' => will be treated as NULL in SP

  FetchPrevPrices(deDate.Date, Csv);

  // 2) Call stored proc and get dataset
  D := LoadViaStoredProcCSV(deDate.Date, Csv, spGet);  // D.Fields: product_id, product_name, competitor_id, competitor_name, monitor_date, price

  // 3) First pass: build competitor map (for dynamic columns)
  CompMap := TDictionary<Integer,string>.Create;
  try
    D.First;
    while not D.Eof do
    begin
      CompID := D.FieldByName('competitor_id').AsInteger;
      if not CompMap.ContainsKey(CompID) then
        CompMap.Add(CompID, D.FieldByName('competitor_name').AsString);
      D.Next;
    end;

    // 4) Rebuild MemData + grid columns
    EnsureGridStructureDxMemDB(viewDB, dsUI, CompMap, MemData);

    // 5) Second pass: pivot rows into MemData (product × competitor)
    MemData.DisableControls;
    RowOf := TDictionary<Integer,Integer>.Create;
    try
      D.First;
      while not D.Eof do
      begin
        ProdID   := D.FieldByName('product_id').AsInteger;
        ProdName := D.FieldByName('product_name').AsString;
        CompID   := D.FieldByName('competitor_id').AsInteger;
        PriceVal := D.FieldByName('price').Value; // may be NULL

        if not RowOf.TryGetValue(ProdID, RowIndex) then
        begin
          MemData.Append;
          MemData.FieldByName('PRODUCT_ID').AsInteger := ProdID;
          MemData.FieldByName('PRODUCT_NAME').AsString := ProdName;
          MemData.Post;
          RowIndex := MemData.RecNo;
          RowOf.Add(ProdID, RowIndex);
        end;

        Bm := MemData.Bookmark;
        MemData.RecNo := RowIndex;

        // Go to the target row and write the value
        MemData.RecNo := RowIndex;
        MemData.Edit;

        AliasCol := Format('PRICE_%d', [CompID]);
        if VarIsNull(PriceVal) then
          MemData.FieldByName(AliasCol).Clear
        else
          MemData.FieldByName(AliasCol).AsCurrency := PriceVal;

        MemData.Post;

        MemData.Bookmark := Bm;

        D.Next;
      end;

      // Keep an in-memory snapshot for Cancel
      FSnapshot.Clear;
      MemData.DisableControls;
      try
        MemData.First;
        MemData.SaveToStream(FSnapshot);
      finally
        MemData.EnableControls;
      end;
    finally
      RowOf.Free;
      MemData.EnableControls;
    end;

  finally
    CompMap.Free;
  end;
end;

function BuildPricesCsv(DS: TDataSet; const CompIds: TArray<Integer>;
                        const MonitorDate: TDate): string;
var
  sb: TStringBuilder;
  i: Integer;
  prodID, compID: Integer;
  fld: TField;
  fldName: string;
  raw: string;
  priceValue: Double;
  FS: TFormatSettings;
  bm: TBookmark;
begin
  Result := '';
  if (Length(CompIds) = 0) or (DS = nil) then Exit;

  // Use dot as decimal separator and ISO date
  FS := TFormatSettings.Create;
  FS.DecimalSeparator := '.';

  sb := TStringBuilder.Create;
  bm := nil;
  DS.DisableControls;
  try
    bm := DS.GetBookmark;
    DS.First;
    while not DS.Eof do
    begin
      // PRODUCT_ID is stored in the dataset (MemData)
      prodID := DS.FieldByName('PRODUCT_ID').AsInteger;

      for i := Low(CompIds) to High(CompIds) do
      begin
        compID := CompIds[i];
        fldName := Format('PRICE_%d', [compID]);
        fld := DS.FindField(fldName);

        if Assigned(fld) and (not fld.IsNull) then
        begin
          // Normalize decimal separator
          raw := fld.AsString.Trim;
          raw := StringReplace(raw, ',', '.', [rfReplaceAll]);

          if not TryStrToFloat(raw, priceValue, FS) then
            raise Exception.CreateFmt('Invalid price "%s" for product %d (competitor %d).',
                                      [raw, prodID, compID]);

          if sb.Length > 0 then
            sb.Append('|'); // Row delimiter

          sb.Append(prodID).Append(';')
            .Append(compID).Append(';')
            .Append(FormatDateTime('yyyy-mm-dd', MonitorDate)).Append(';')
            .Append(FloatToStr(priceValue, FS)); // Ensure dot decimal
        end;
      end;

      DS.Next;
    end;

    Result := sb.ToString;
  finally
    if Assigned(bm) then
    begin
      DS.GotoBookmark(bm);
      DS.FreeBookmark(bm);
    end;
    DS.EnableControls;
    sb.Free;
  end;
end;

procedure TFormMain.cxButtonSaveClick(Sender: TObject);
var
  ds: TDataSet;
  compIds: TArray<Integer>;
  csv: string;
begin
  // Save is allowed only for today (keep your rule if needed)
  if Trunc(deDate.Date) <> Trunc(Date) then
  begin
    ShowMessage('Editing allowed only for today.');
    Exit;
  end;

  // Choose competitors to save
  compIds := GetSelectedCompetitorIds(cbCompetitors); // or SelectedCompetitors
  if Length(compIds) = 0 then
  begin
    ShowMessage('Please select at least one competitor.');
    Exit;
  end;

  ds := dsUI.DataSet; // MemData bound dataset
  csv := BuildPricesCsv(ds, compIds, Trunc(deDate.Date));

  if csv = '' then
  begin
    ShowMessage('Nothing to save.');
    Exit;
  end;

  // Call PRICE_MONITORING.SAVE_PRICES(p_data_csv => :P_DATA_CSV)
  OraSession.StartTransaction;
  try
    spSave.Close;
    spSave.StoredProcName := 'PRICE_MONITORING.SAVE_PRICES';
    spSave.Params.Clear;
    spSave.Params.CreateParam(ftString, 'P_DATA_CSV', ptInput).AsString := csv;

    spSave.ExecProc; // Execute procedure (no result set)
    OraSession.Commit;

    ShowMessage('Data saved successfully.');
  except
    on E: Exception do
    begin
      OraSession.Rollback;
      ShowMessage('Error while saving: ' + E.Message);
    end;
  end;
end;

function EnsureField(DataSet: TDataSet; const AName: string;
                     AType: TFieldType; ASize: Integer = 0): TField;
begin
  Result := DataSet.FindField(AName);
  if Assigned(Result) then Exit;

  case AType of
    ftInteger:   Result := TIntegerField.Create(DataSet);
    ftFloat,
    ftCurrency:  Result := TCurrencyField.Create(DataSet);
    ftString:    begin
                   var F := TStringField.Create(DataSet);
                   F.Size := ASize;
                   Result := F;
                 end;
  else
    Result := TField.Create(DataSet);
  end;
  Result.FieldName := AName;
  Result.DataSet   := DataSet; // Binding creates a field in the dataset
end;

procedure TFormMain.EnsureGridStructureDxMemDB(
  const View: TcxGridDBTableView; const DS: TDataSource;
  const CompMap: TDictionary<Integer, string>; const Mem: TdxMemData);
var
  Col: TcxGridDBColumn;
  CompID: Integer;
  ColName: string;
begin
  // Dataset schema
  Mem.Close;
  while Mem.FieldCount > 0 do Mem.Fields[0].Free;
  Mem.FieldDefs.Clear;
  Mem.FieldDefs.Add('PRODUCT_ID',   ftInteger);
  Mem.FieldDefs.Add('PRODUCT_NAME', ftString, 200);
  for CompID in CompMap.Keys do
  begin
    ColName := Format('PRICE_%d', [CompID]);
    Mem.FieldDefs.Add(ColName, ftCurrency);
  end;

  // Make sure fields exist (covers cases with/without persistent fields)
  EnsureField(Mem, 'PRODUCT_ID',   ftInteger);
  EnsureField(Mem, 'PRODUCT_NAME', ftString, 200);
  for CompID in CompMap.Keys do
    EnsureField(Mem, Format('PRICE_%d', [CompID]), ftCurrency);

  Mem.Open;

  // Grid columns
  View.BeginUpdate;
  try
    View.ClearItems;
    View.OptionsView.ColumnAutoWidth := True;   // Spread columns evenly
    View.OptionsCustomize.ColumnHiding := False;

    // Hidden column to read ProductID in style handler
    var ColID := View.CreateColumn;
    ColID.DataBinding.FieldName := 'PRODUCT_ID';
    ColID.Visible := False;
    ColID.Options.Editing := False;
    ColID.Tag := -1; // Service mark

    // Product column — wider and fixed on the left if needed
    Col := View.CreateColumn;
    Col.DataBinding.FieldName := 'PRODUCT_NAME';
    Col.Caption := 'Product';
    Col.Width := 220;                 // Default width
    Col.MinWidth := 160;              // Prevent too narrow
    Col.Options.HorzSizing := True;   // User can resize

    // Price columns — uniform width
    for CompID in CompMap.Keys do
    begin
      Col := View.CreateColumn;
      Col.DataBinding.FieldName := Format('PRICE_%d', [CompID]);
      Col.Caption := CompMap[CompID];
      Col.Tag := CompID;

      // Editor
      Col.PropertiesClassName := 'TcxCurrencyEditProperties';

      // Sizing defaults
      Col.Width := 90;                // Base width for price
      Col.MinWidth := 70;
      Col.Options.HorzSizing := True;
    end;

    DS.DataSet := Mem;
    View.DataController.DataSource := DS;
  finally
    View.EndUpdate;
  end;
end;

procedure TFormMain.FetchPrevPrices(const MonitorDate: TDate;
  const Csv: string);
var
  D: TDataSet;
  key: TPriceKey;
begin
  PrevPrices.Clear;

  // Call the same procedure get_prices, but with date -1
  D := LoadViaStoredProcCSV(MonitorDate - 1, Csv, spGetPrev);
  try
    D.First;
    while not D.Eof do
    begin
      key.ProductID := D.FieldByName('product_id').AsInteger;
      key.CompetitorID := D.FieldByName('competitor_id').AsInteger;

      if not D.FieldByName('price').IsNull then
        PrevPrices.AddOrSetValue(key, D.FieldByName('price').AsFloat);

      D.Next;
    end;
  finally
    // spGetPrev is a TOraStoredProc, it lives on the form, no need to free it
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  CheckAllButton : TcxEditButton;
begin
  // Add "All" button
  CheckAllButton := cbCompetitors.Properties.Buttons.Add;
  CheckAllButton.Kind := bkText;
  CheckAllButton.Caption := 'All';
  cbCompetitors.Properties.OnButtonClick := CheckAllItems;

  deDate.Date := Date;
  LoadCompetitors(cbCompetitors);

  PrevPrices := TDictionary<TPriceKey, Double>.Create;

  FSnapshot := TMemoryStream.Create;

  // Soft colors
  FStyleUp    := TcxStyle.Create(Self);    FStyleUp.Color    := RGB(255,200,200); // light red
  FStyleDown  := TcxStyle.Create(Self);    FStyleDown.Color  := RGB(200,255,200); // light green
  FStyleNoPrev:= TcxStyle.Create(Self);    FStyleNoPrev.Color:= RGB(230,230,230); // light gray
  // If you have font preferences:
  // FStyleUp.TextColor := clWindowText; etc.

  viewDB.OptionsSelection.CellSelect := True;   // Only cells are selected
  viewDB.OptionsSelection.HideSelection := True; // Row cursor is hidden

  PrevPrices := TDictionary<TPriceKey, Double>.Create; // Same as before

  cxButtonLoadClick(nil);
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FSnapshot.Free;
  PrevPrices.Free;
  FStyleUp.Free;
  FStyleDown.Free;
  FStyleNoPrev.Free;
end;

function TFormMain.GetSelectedCompetitorIds(
  Cmb: TcxCheckComboBox): TArray<Integer>;
begin
  var List := TList<Integer>.Create;
  try
    for var i := 0 to Cmb.Properties.Items.Count - 1 do
      if Cmb.States[i] = cbsChecked then
        List.Add(Cmb.Properties.Items[i].Tag); // ID is stored in Tag
    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

procedure TFormMain.LoadCompetitors(Sender: TObject);
begin
  with (Sender as TcxCheckComboBox) do
  begin
    Properties.Items.Clear;

    with TOraQuery.Create(nil) do
      try
        Session := OraSession;
        SQL.Text := 'select id, name, status from competitors order by name';
        Open;
        while not Eof do
        begin
          var Item := Properties.Items.Add;
          Item.Tag := FieldByName('id').AsInteger;
          Item.Description := FieldByName('name').AsString;
          var Idx := Properties.Items.Count - 1;
          if FieldByName('status').AsInteger = ST_ACTIVE then
            States[Idx] := cbsChecked
          else
            States[Idx] := cbsUnchecked;

          Next;
        end;
      finally
        Free;
      end;
  end;
end;

// Open function PRICE_MONITORING.GET_PRICES (CSV version) and return it as a dataset.
function LoadViaStoredProcCSV(const DateValue: TDate; const CsvIds: string;
                              SP: TOraStoredProc): TDataSet;
begin
  SP.Close;
  SP.StoredProcName := 'PRICE_MONITORING.GET_PRICES'; // Overloaded function
  SP.Params.Clear;

  // 1. Date parameter
  SP.Params.CreateParam(ftDate, 'P_MONITOR_DATE', ptInput).AsDate :=
    Trunc(DateValue);

  // 2. CSV competitors parameter (NULL => all active)
  if CsvIds = '' then
    SP.Params.CreateParam(ftString, 'P_COMPETITORS', ptInput).Clear
  else
    SP.Params.CreateParam(ftString, 'P_COMPETITORS', ptInput).AsString := CsvIds;

  // 3. Out cursor
  SP.Params.CreateParam(ftCursor, 'RESULT', ptResult);

  // NB: in ODAC sometimes OUT param name must match exactly as in PL/SQL,
  //     and sometimes ptResult is enough — depends on version.
  //     If error occurs, rename 'RESULT' -> 'RETURN_VALUE' or 'SYS_REFCURSOR'.

  SP.Open;        // Open cursor as DataSet
  Result := SP;   // StoredProc can be used as DataSet
end;

function TFormMain.SelectedCompetitors: TArray<Integer>;
begin
  Result := [];
  for var i := 0 to cbCompetitors.Properties.Items.Count - 1 do
    if cbCompetitors.States[i] = cbsChecked then
      Result := Result + [Integer(cbCompetitors.Properties.Items[i].Tag)];
end;

procedure TFormMain.viewDBStylesGetContentStyle(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
var
  PriceCol, ProdCol: TcxGridDBColumn;
  Key: TPriceKey;
  VProd, VNew: Variant;
  OldVal, NewVal: Double;
begin
  if (ARecord = nil) or not (AItem is TcxGridDBColumn) then Exit;

  PriceCol := TcxGridDBColumn(AItem);
  if PriceCol.Tag = 0 then Exit; // We are only interested in dynamic price columns

  ProdCol := viewDB.GetColumnByFieldName('PRODUCT_ID');
  if ProdCol = nil then Exit; // Structure is not ready yet

  VProd := ARecord.Values[ProdCol.Index];
  VNew  := ARecord.Values[PriceCol.Index];
  if VarIsNull(VProd) or VarIsNull(VNew) then Exit;

  Key.ProductID    := VarAsType(VProd, varInteger);
  Key.CompetitorID := PriceCol.Tag;

  if PrevPrices.TryGetValue(Key, OldVal) then
  begin
    NewVal := VarAsType(VNew, varDouble); // Valid for Currency/Float
    if NewVal > OldVal then
      AStyle := FStyleUp     // light red
    else if NewVal < OldVal then
      AStyle := FStyleDown   // light green
    else
      AStyle := FStyleNoPrev // light gray — unchanged
  end
end;

end.

