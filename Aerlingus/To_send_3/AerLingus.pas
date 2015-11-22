unit AerLingus;

interface

uses
  Windows, SysUtils, Classes, HTTPApp, MSHTML, ActiveX, OleCtrls, SHDocVw,
  {$IFNDEF VER130}Variants,{$ENDIF} IniFiles, Unit1;

  procedure GetAerLingus(
              {paramOutData} FlightList: TStringList;
              {returnflight} IsRoundTrip: Boolean;
              {flexible} IsFlexible: Boolean;
              {airport_depart} Origin: string;
              {date_depart} DepartureDate: TDateTime;
              {airport_destination} Destination: string;
              {date_return} ReturnDate: TDateTime;
              {adults} AdultNr: Integer;
              {children} ChildrenNr: Integer;
              {infants} InfantNr: Integer);

implementation

uses
  Forms, Controls, Dialogs;

{.$DEFINE SHOWBROWSER}
{.$DEFINE ISDEBUG}

const
  CONFIG_FILENAME = '\data\AerLingus.ini';

type
  PFlightInfo = ^TFlightInfo;
  TFlightInfo = record
    DepDateTime: TDateTime;
    ArrDateTime: TDateTime;
    FlightNr: string;
    Via: string;
    TotalVal: Double;
    Currency: string;
    // internal
    BaseCost: Double;
    TotalStr: string;
    RowIndex: Integer;
  end;

  TFlightsArray = array of TFlightInfo;


function CurrentYear: Word;
var
  SystemTime: TSystemTime;
begin
  GetLocalTime(SystemTime);
  Result := SystemTime.wYear;
end;

function DayOf(const Value: TDateTime): Word;
var
  Year, Month: Word;
begin
  DecodeDate(Value, Year, Month, Result);
end;

function MonthOf(const Value: TDateTime): Word;
var
  Year, Day: Word;
begin
  DecodeDate(Value, Year, Result, Day);
end;

function ParseDateTime(const S: string): TDateTime;
const
  Months = 'Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec';
var
  Year, Month, Day, Hour, Min: Word;
begin
 	//'09:30 Sat 12 Mar'
  Hour:= StrToInt(Copy(S, 1, 2));
  Min:= StrToInt(Copy(S, 4, 2));
  Day:= StrToInt(Trim(Copy(S, 11, 2)));
  Month:= (Pos(Trim(Copy(S, 13, 3)), Months) + 3) div 4;
  Year:= CurrentYear();
  Result:= EncodeDate(Year, Month, Day) + EncodeTime(Hour, Min, 0, 0);
end;

function ParseFloat(const S: string): Double;
var
	Temp: string;
begin
  //'1,854.58'
  Temp:= StringReplace(S, ',', '', [rfReplaceAll]);
	Temp:= StringReplace(Temp, '.', DecimalSeparator, []);
	Result:= StrToFloat(Temp);
end;


procedure WaitWhileLoading(const Document: IHTMLDocument2);
begin
  repeat
    Application.ProcessMessages; //HandleMessage;
    Sleep(10);
  until (Document.readyState = 'complete');
end;

function FindDepartingColumnIndex(const FlightsTable: IHTMLTable): Integer;
var
  Row: HTMLTableRow;
  Element: IHTMLElement;
  Index: Integer;
begin
  Assert(Assigned(FlightsTable), 'FlightsTable is null.');
  Result:= -1;
  Row:= FlightsTable.rows.item(0, EmptyParam) as HTMLTableRow;
  Assert(Assigned(Row), 'Row is null.');
  for Index:= 0 to Row.cells.length - 1 do begin
    Element:= Row.cells.item(Index, EmptyParam) as IHTMLElement;
    if Element.innerText = 'Departing' then begin
      Result:= Index;
      Exit;
    end;
  end;
end;

function FindFirstFlightRowIndex(const FlightsTable: IHTMLTable): Integer;
var
  Row: HTMLTableRow;
  Element: IHTMLElement;
  Index: Integer;
begin
  Assert(Assigned(FlightsTable), 'FlightsTable is null.');
  Result:= -1;
  for Index:= 1 to FlightsTable.rows.length - 1 do begin
    Row:= FlightsTable.rows.item(Index, EmptyParam) as HTMLTableRow;
    Assert(Assigned(Row), 'Row is null.');
    Element:= Row.cells.item(0, EmptyParam) as IHTMLElement;
    if Element.id <> '' then begin
      Result:= Index;
      Exit;
    end;
  end;
end;

function FindLastFlightRowIndex(const Document: IHTMLDocument2; const FlightTableName: string): Integer;
var
  Table: IHTMLTable;
  Row: HTMLTableRow;
  Index: Integer;
begin
  Result:= -1;
  Table:= Document.all.item(FlightTableName, EmptyParam) as IHTMLTable;
  Index:= FindFirstFlightRowIndex(Table);
  while Index < Table.rows.length do begin
    Result:= Index;
    // get next index
    Row:= Table.rows.item(Index, EmptyParam) as HTMLTableRow;
    Inc(Index, (Row.cells.item(0, EmptyParam) as HTMLTableCell).rowSpan);
  end;
end;

function PressContinue(const Document: IHTMLDocument2): Boolean;
var
  Elements: IHTMLElementCollection;
  I: Integer;
  Submit: HTMLInputElement;
begin
  Result:= False;
  Elements:= Document.all.item('methodToUse', EmptyParam) as IHTMLElementCollection;
  for I := 0 to Elements.length - 1 do begin
    if Supports(Elements.item(I, EmptyParam), HTMLInputElement, Submit) then
      if (Submit.type_ = 'submit') and (Pos('>>', Submit.value) > 0) then begin
        if not Submit.disabled then begin
          Result:= True;
          Submit.click;
        end;
        Exit
      end;
  end;
  Assert(False, 'Submit not found');
end;

function PressLastNextDayButton(const Doc: IHTMLDocument2): Boolean;
var
  Elements: IHTMLElementCollection;
  I: Integer;
  Button: HTMLInputElement;
begin
  Result:= False;
  Elements:= Doc.all.item('methodToUse', EmptyParam) as IHTMLElementCollection;
  for I := Elements.length - 1 downto 0 do begin
    if Supports(Elements.item(I, EmptyParam), HTMLInputElement, Button) then
      if (Button.type_ = 'button') and (Pos('>>', Button.value) > 0) then begin
        if not Button.disabled then begin
          Result:= True;
          Button.click;
        end;
        Exit
      end;
  end;
  Assert(False, 'NextDay button not found');
end;

procedure SelectFare(const Doc: IHTMLDocument2; var Flight: TFlightInfo; const FlightTabelName, FareTableName: string);
var
  Table: HTMLTable;
  Row: HTMLTableRow;
  TotalCell: HTMLTableCell;
  Element: IHTMLElement;
begin
  //try
  // find total element
  Table:= Doc.all.item(FareTableName, EmptyParam) as HTMLTable;
  Assert(Assigned(Table), 'Table is null');
  Row:= Table.rows.item(3, EmptyParam) as HTMLTableRow;
  Assert(Assigned(Row), 'Row is null');
  TotalCell:= Row.cells.item(1, EmptyParam) as HTMLTableCell;
  Assert(Assigned(TotalCell), 'Table is null');
  // clear total text
  with TotalCell.children as IHTMLElementCollection do
    Element:= item(0, EmptyParam) as IHTMLElement;
  Assert(Assigned(Element), 'Element is null');
  repeat
    Element.innerText:= '';
    Application.ProcessMessages;
  until TotalCell.innerText = '';
  // click on row
  Table:= Doc.all.item(FlightTabelName, EmptyParam) as HTMLTable;
  Assert(Assigned(Table), 'Table is null');
  Row:= Table.rows.item(Flight.RowIndex, EmptyParam) as HTMLTableRow;
  Assert(Assigned(Row), Format('Row is null. RowIndex=%u', [Flight.RowIndex]));
  (Row.cells.item(0, EmptyParam) as HTMLTableCell).click;
  // wait while javascript executed
  repeat
    Application.ProcessMessages;
  until TotalCell.innerText <> '';
  Flight.BaseCost:= ParseFloat(TotalCell.innerText);
//  except
//    on E: Exception do
//      ShowMessage(E.Message);
//  end;
end;

procedure ParseFlight(var Result: TFlightInfo; Row: HTMLTableRow; FareCol, DepartCol: Integer);
var
  depTime, arrTime, flightNr, via: string;
begin
  Assert(Assigned(Row), 'Row is null.');

  // parse cells
  depTime:= Trim((Row.cells.item(DepartCol + 1, EmptyParam) as HTMLTableCell).innerText);
  arrTime:= Trim((Row.cells.item(DepartCol + 3, EmptyParam) as HTMLTableCell).innerText);
  flightNr:= Trim(StringReplace((Row.cells.item(DepartCol + 4, EmptyParam) as HTMLTableCell).innerText, '*', '', []));

  // check of 2 segment
  via:= '';
  if (Row.cells.item(FareCol, EmptyParam) as HTMLTableCell).rowSpan = 2 then begin
    Row:= Row.nextSibling as HTMLTableRow;
    DepartCol:= 0;
    if via <> '' then
      via:= via + ',';
    via:= via + (Row.cells.item(DepartCol + 0, EmptyParam) as HTMLTableCell).innerText;
    //depTime:= (Row.cells.item(DepartCol + 1, EmptyParam) as HTMLTableCell).innerHTML;
    arrTime:= (Row.cells.item(DepartCol + 3, EmptyParam) as HTMLTableCell).innerHTML;
    flightNr:= flightNr + ',' + Trim(StringReplace((Row.cells.item(DepartCol + 4, EmptyParam) as HTMLTableCell).innerText, '*', '', []));
  end;

  Assert(depTime <> '', 'depTime is null.');
  Assert(arrTime <> '', 'arrTime is null.');
  Assert(flightNr <> '', 'flightNr is null.');

  // fill list
  Result.DepDateTime:= ParseDateTime(depTime);
  Result.ArrDateTime:= ParseDateTime(arrTime);
  Result.FlightNr:= flightNr;
  Result.Via:= via;
end;

procedure ParseFlightTable(const Doc: IHTMLDocument2; const FlightTableName: string; var Flights: TFlightsArray);
var
  Table: IHTMLTable;
  FareCol, DepartingCol, RowIndex: Integer;
  Row: HTMLTableRow;
  Flight: TFlightInfo;

begin
  Table:= Doc.all.item(FlightTableName, EmptyParam) as IHTMLTable;
  // find 'departing' column and first row of flight
  FareCol:= 0;
  DepartingCol:= FindDepartingColumnIndex(Table);
  RowIndex:= FindFirstFlightRowIndex(Table);
  Row:= nil;
  while RowIndex < Table.rows.length do begin
    // parse flight
    Row:= Table.rows.item(RowIndex, EmptyParam) as HTMLTableRow;
    ParseFlight(Flight, Row, FareCol, DepartingCol);
    Flight.RowIndex:= RowIndex;
    // add to list
    SetLength(Flights, Length(Flights) + 1);
    Flights[High(Flights)]:= Flight;
    // next
    Inc(RowIndex, (Row.cells.item(0, EmptyParam) as HTMLTableCell).rowSpan);
  end;
  Assert(Assigned(Row), 'Flights not found.');
end;

procedure ParsePrice(const Doc: IHTMLDocument2; const DepFlight, RetFlight: PFlightInfo);
var
  I, J: Integer;
  TotalPrice, Adlt, Chld, Inf: Double;
  K, D: Double;
  Curr: string;
  Elements: IHTMLElementCollection;
  Table: HTMLTable;
  Row: HTMLTableRow;
  RetTotal, DepTotal: Double;
begin
  // parse price
  if Assigned(RetFlight) then begin // RoundTrip
    TotalPrice:= 0; Adlt:= 0; Chld:= 0; Inf:= 0;
    Elements:= Doc.all.tags('table') as IHTMLElementCollection;
    for I := 0 to Elements.length - 1 do begin
      Table:= Elements.item(I, EmptyParam) as HTMLTable;
      if Assigned(Table) and (Table.getAttribute('summary', 0) = 'Fare information') then begin
        for J := 1 to Table.rows.length - 1 do begin
          Row:= Table.rows.item(J, EmptyParam) as HTMLTableRow;
          with Row.cells.item(0, EmptyParam) as HTMLTableCell do
            if (Pos('Adult', innerText) > 0) then begin
              Adlt:= ParseFloat((Row.cells.item(4, EmptyParam) as HTMLTableCell).innerText)
            end
            else if (Pos('Children', innerText) > 0) then begin
              Chld:= ParseFloat((Row.cells.item(4, EmptyParam) as HTMLTableCell).innerText)
            end
            else if (Pos('Infant', innerText) > 0) then begin
              // if taxes for infant is present then include costs
              if ParseFloat((Row.cells.item(2, EmptyParam) as HTMLTableCell).innerText) > 0 then
                Inf:= ParseFloat((Row.cells.item(4, EmptyParam) as HTMLTableCell).innerText)
            end
            else if J = Pred(Table.rows.length) then begin
              Curr:= (Row.cells.item(1, EmptyParam) as IHTMLElement).innerText;
              TotalPrice:= ParseFloat((Row.cells.item(2, EmptyParam) as IHTMLElement).innerText);
            end;
        end;
        Break;
      end;
    end;

    // validate
    Assert(TotalPrice > 0, 'Error when price parsing.');

    D:= Adlt + Chld + Inf;

    TotalPrice:= TotalPrice - D;
    K:= DepFlight.BaseCost + RetFlight.BaseCost;
    DepTotal:= (D * DepFlight.BaseCost / K) + (TotalPrice / 2);
    RetTotal:= (D * RetFlight.BaseCost / K) + (TotalPrice / 2);

    with DepFlight^ do begin
      {$IFDEF ISDEBUG}
      if TotalStr = '' then
        TotalStr:= Format('[%.2f] ', [BaseCost]);
      if Int(TotalVal) <> Int(DepTotal) then begin
        DepFlight.TotalStr:= TotalStr + Format('%.2f ', [DepTotal, Currency]);
      end;
      {$ENDIF ISDEBUG}
      TotalVal:= (TotalVal + DepTotal) / (1 + Integer(TotalVal > 0));
      Currency:= Curr;
    end;
    with RetFlight^ do begin
      {$IFDEF ISDEBUG}
      if TotalStr = '' then
        TotalStr:= Format('[%.2f] ', [BaseCost]);
      if Int(TotalVal) <> Int(RetTotal) then begin
        RetFlight.TotalStr:= TotalStr + Format('%.2f ', [RetTotal, Currency]);
      end;
      {$ENDIF ISDEBUG}
      TotalVal:= (TotalVal + RetTotal) / (1 + Integer(TotalVal > 0));
      Currency:= Curr;
    end;
  end
  else begin // OneWay
    Elements:= Doc.all.tags('tr') as IHTMLElementCollection;
    for J := 0 to Elements.length - 1 do begin
      if Supports(Elements.item(J, EmptyParam), HTMLTableRow, Row) then
        if (Row.className = 'totalPrice') then
          Break;
    end;

    // validate
    Assert(Assigned(Row), 'Error when price parsing.');

    if Assigned(Row) then begin
      with DepFlight^ do begin
        Currency:= (Row.cells.item(1, EmptyParam) as IHTMLElement).innerText;
        TotalVal:= ParseFloat((Row.cells.item(2, EmptyParam) as IHTMLElement).innerText);
      end;
    end;
  end;
end;

procedure PopulateFlights(var Flights: TFlightsArray; IsReturn: Boolean; Date: TDate; FlightList: TStringList);
const
  Direction: array[Boolean] of string = ('forward', 'reverse');
var
  Index: Integer;
begin
  Index:= 0;
  while Index < Length(Flights) do begin
    with Flights[Index] do begin
      if Int(DepDateTime) > Int(Date) then
        Break;
      FlightList.Add(
        Direction[IsReturn] + '|' +
        DateToStr(DepDateTime) + '|' + TimeToStr(DepDateTime) + '|' +
        DateToStr(ArrDateTime) + '|' + TimeToStr(ArrDateTime) + '|' +
        FlightNr + '|' +
        Format('%.2f %s', [TotalVal, Currency]) + {$IFDEF ISDEBUG}TotalStr +{$ENDIF} '|' + Via);
    end;
    Inc(Index);
  end;

  Flights:= Copy(Flights, Index, Length(Flights) - Index);
end;

var
  WebBrowser: TWebBrowser = nil;

procedure GetAerLingus(FlightList: TStringList; IsRoundTrip, IsFlexible: Boolean;
  Origin: string; DepartureDate: TDateTime; Destination: string; ReturnDate: TDateTime;
  AdultNr, ChildrenNr, InfantNr: Integer);
const
  FlightType: array [Boolean] of string = ('ONEWAY', 'RETURN');
  SearchType: array [Boolean] of string = ('FIXED', 'FLEXIBLE');
var
  IniPath: string;
  Ini: TIniFile;
  StartURL: string;

  Doc: IHTMLDocument2;
  EncodedDataString: string;
  PostDataVar: OleVariant;
  HeadersVar: OleVariant;
  currDepDate, currRetDate: TDateTime;

  I: Integer;
  DepIndex, RetIndex: Integer;
  IsValid: Boolean;
  RetFlight: TFlightInfo;
  DepFlights, RetFlights: TFlightsArray;

  // TODO remove this after debug
  depDate, retDate: string;
  {$IFDEF ISDEBUG}
  Start: Cardinal;
  {$ENDIF ISDEBUG}
begin
  {$IFDEF ISDEBUG}
  FreeAndNil(WebBrowser);
  Start:= GetTickCount();
  {$ENDIF ISDEBUG}
  WebBrowser:= TWebBrowser.Create(Application.MainForm);
  try
    // Don`t forget to insert   uses Forms;  above
    TWinControl(WebBrowser).Name:= 'ParamWebBrowser' + IntToStr(Application.MainForm.ComponentCount);
    TWinControl(WebBrowser).Parent:= Application.MainForm;
    {$IFDEF SHOWBROWSER}
    WebBrowser.Height:= 500;
    Application.MainForm.WindowState:= wsMaximized;
    WebBrowser.Align:= alClient;
    {$ELSE SHOWBROWSER}
    WebBrowser.Height:= 0;
    WebBrowser.Visible:= False;
    {$ENDIF SHOWBROWSER}
    WebBrowser.Silent:= True;
    WebBrowser.Update;
    Application.HandleMessage;

    // change the verification accordint to your rules
    IniPath:= ExtractFileDir(Application.ExeName) + CONFIG_FILENAME;
    if not FileExists(IniPath) then begin
      MessageDlg(Format('Unable to proceed, can`t find file'#13#10'"%s"', [IniPath]), mtError, [mbOK], 0);
      Halt(0);
    end;

    Ini:= TIniFile.Create(IniPath);
    try
      StartURL:= Ini.ReadString('main', 'AerLingusStartURL', 'nil');
      if StartURL = '' then begin
        ShowMessage('Please chech the value of parameter AerLingusStartURL in AerLingus.ini');
        Exit; //please change the code according to your rules
      end;
    finally
      Ini.Free;
    end;

    depDate:= DateToStr(DepartureDate);
    retDate:= DateToStr(ReturnDate);

    if not IsRoundTrip and not IsFlexible then
      ReturnDate:= DepartureDate;

    currRetDate:= ReturnDate;
    currDepDate:= DepartureDate;
      if IsFlexible then
        currRetDate:= currDepDate;
    while (currDepDate <= ReturnDate) do begin

      EncodedDataString:=
            'depart=' + Origin +
            '&destination=' + Destination +
            '&methodToUse=' + HTTPEncode('Book Now') +
            '&promoCode='+
            '&selectedAdultNumber=' + IntToStr(AdultNr) +
            '&selectedChildrenNumber=' + IntToStr(ChildrenNr) +
            '&selectedDay_1=' + IntToStr(DayOf(currDepDate)) +
            '&selectedDestinationAirport_1=' + Destination +
            '&selectedFlightType=' + FlightType[IsRoundTrip] +
            '&selectedInfantNumber=' + IntToStr(InfantNr) +
            '&selectedMonth_1=' + IntToStr(MonthOf(currDepDate) - 1) + // jan = 0 !!!
            '&selectedSearchType=' + SearchType[False {Flexible} ] +
            '&selectedSourceAirport_1=' + Origin +
            '';
      if IsRoundTrip then
        EncodedDataString:= EncodedDataString +
            '&selectedDay_2=' + IntToStr(DayOf(currRetDate)) +
            '&selectedMonth_2=' + IntToStr(MonthOf(currRetDate) - 1) + // jan = 0 !!!
            '';


      // The PostData OleVariant needs to be an array of bytes
      // as large as the string (minus the 0 terminator)
      // Now, move the Ordinal value of the character into the PostData array
      PostDataVar:= VarArrayCreate([0, Length(EncodedDataString) - 1], varByte);
      for I := 1 to Length(EncodedDataString) do
        PostDataVar[I - 1]:= Ord(EncodedDataString[I]);

      HeadersVar:=
        'Content-Type: application/x-www-form-urlencoded'#10#13 +
        'Referer: http://www.aerlingus.com/home/index.jsp'#10#13;

      // Navigate to blank page
      WebBrowser.Navigate('about:blank');
      repeat
        Application.HandleMessage;
        Sleep(10);
      until WebBrowser.ReadyState >= READYSTATE_COMPLETE;

      // Navigate to source page
      WebBrowser.Navigate(StartURL, EmptyParam, EmptyParam, PostDataVar, HeadersVar);
      // Wait while page is loading...
      repeat
        Application.HandleMessage;
        Sleep(10);
      until WebBrowser.ReadyState >= READYSTATE_COMPLETE;

      if not Assigned(WebBrowser.Document) then begin
        FlightList.Add('InternalError');
      end
      else if not IsRoundTrip then begin // One Way
        DepFlights:= nil;
        WebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);
        Assert(Assigned(Doc), 'Doc is null');

        WaitWhileLoading(Doc);

        // validate page
        IsValid:= True;
        IsValid:= IsValid and Assigned(Doc.all.item('selectFlight_1', EmptyParam));
        if IsValid then begin

          //parse flights table
          ParseFlightTable(Doc, 'selectFlight_1', DepFlights);

          // parse prices
          for I := 0 to Length(DepFlights) - 1 do begin
            // set flight selected
            SelectFare(Doc, DepFlights[I], 'selectFlight_1', 'outboundTableOnly');

            // navigate to price
            PressContinue(Doc);
            WaitWhileLoading(Doc);

            // parse price
            ParsePrice(Doc, @DepFlights[I], nil);

            // navigate to flights list
            WebBrowser.GoBack;
            WaitWhileLoading(Doc);
          end;

          // populate list
          PopulateFlights(DepFlights, False, currDepDate, FlightList);
        end;// IsValid

        Doc:= nil;
      end
      else begin // Round Trip
        DepFlights:= nil;
        //RetFlights:= nil;
        WebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);
        Assert(Assigned(Doc), 'Doc is null');

        WaitWhileLoading(Doc);

        // validate page
        IsValid:= True;
        IsValid:= IsValid and Assigned(Doc.all.item('selectFlight_1', EmptyParam));
        //IsValid:= IsValid and Assigned(Doc.all.item('selectFlight_2', EmptyParam));

        if IsValid then begin             

          // parse departure flights table
          ParseFlightTable(Doc, 'selectFlight_1', DepFlights);
          DepIndex:= Low(DepFlights);

          if Assigned(Doc.all.item('selectFlight_2', EmptyParam)) then begin
            // parse return flights table
            RetIndex:= High(RetFlights);
            ParseFlightTable(Doc, 'selectFlight_2', RetFlights);
            if RetIndex = -1 then
              RetIndex:= Low(RetFlights);

            // parse prices
            while DepIndex < Length(DepFlights) do begin
              if DepFlights[DepIndex].ArrDateTime >= RetFlights[RetIndex].DepDateTime then begin
                // return flight in next days possible

                // skip such flights for non-flexible search
                if not IsFlexible then begin
                  SetLength(DepFlights, DepIndex);
                  Break;
                end;

                // try to select return on next day
                if not PressLastNextDayButton(Doc) then
                  Break;
                currRetDate:= currRetDate + 1;
                WaitWhileLoading(Doc);
                // validate page
                if not Assigned(Doc.all.item('selectFlight_2', EmptyParam)) then
                  Break;
                // parse return flights table
                RetIndex:= High(RetFlights);
                ParseFlightTable(Doc, 'selectFlight_2', RetFlights);
                Inc(RetIndex);
              end;

              while RetIndex < Length(RetFlights) do begin
                // select departure flight
                SelectFare(Doc, DepFlights[DepIndex], 'selectFlight_1', 'outboundTable');
                // select return flight
                SelectFare(Doc, RetFlights[RetIndex], 'selectFlight_2', 'inboundTable');

                // navigate to price
                PressContinue(Doc);
                WaitWhileLoading(Doc);

                ParsePrice(Doc, @DepFlights[DepIndex], @RetFlights[RetIndex]);

                // navigate to flights list
                WebBrowser.GoBack;
                WaitWhileLoading(Doc);

                Inc(RetIndex);
              end;
              // using last return flight in other cases
              RetIndex:= High(RetFlights);

              Inc(DepIndex);
            end;//while

          end;

          // parse prices with returns on next days
          {if False and (DepIndex < Length(DepFlights)) and IsFlexible then begin
            repeat
              // try to select return on next day
              if not PressLastNextDayButton(Doc) then
                Break;

              currRetDate:= currRetDate + 1;
              WaitWhileLoading(Doc);

              // validate page
              IsValid:= True;
              //IsValid:= IsValid and Assigned(Doc.all.item('selectFlight_1', EmptyParam));
              IsValid:= IsValid and Assigned(Doc.all.item('selectFlight_2', EmptyParam));
              if not IsValid then
                Break;

              // find last return row
              RetFlight.RowIndex:= FindLastFlightRowIndex(Doc, 'selectFlight_2');

              // scan
              while DepIndex < Length(DepFlights) do begin
                // select departure flight
                SelectFare(Doc, DepFlights[DepIndex], 'selectFlight_1', 'outboundTable');
                // select last return flight
                SelectFare(Doc, RetFlight, 'selectFlight_2', 'inboundTable');

                // navigate to price
                PressContinue(Doc);
                WaitWhileLoading(Doc);

                // parse price
                ParsePrice(Doc, @DepFlights[DepIndex], @RetFlight);

                // navigate to flights list
                WebBrowser.GoBack;
                WaitWhileLoading(Doc);

                Inc(DepIndex);
              end;
            until True;
          end;}

          // populate list
          PopulateFlights(DepFlights, False, currDepDate, FlightList);
          if IsFlexible then
            PopulateFlights(RetFlights, True, currDepDate, FlightList)
          else
            PopulateFlights(RetFlights, True, currRetDate, FlightList)
        end;// isValid

        Doc:= nil;
      end;

      if IsRoundTrip and not IsFlexible then
        currDepDate:= currRetDate;

      currDepDate:= currDepDate + 1;
      currRetDate:= currRetDate + 1;
    end;//while

  finally
    {$IFNDEF ISDEBUG}
    FreeAndNil(WebBrowser);
    {$ENDIF ISDEBUG}
  end;
  {$IFDEF ISDEBUG}
  FreeAndNil(WebBrowser);
  Start:= (GetTickCount() - Start) div 1000;
  ShowMessageFmt('Process time: %.02u:%.02u.', [Start div 60, Start mod 60]);
  {$ENDIF ISDEBUG}
end;

end.