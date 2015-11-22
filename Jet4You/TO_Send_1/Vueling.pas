unit Vueling;
interface

uses
  SysUtils, Classes, Httpapp, MSHTML, ActiveX, OleCtrls, SHDocVw,
  {$IFNDEF VER130}Variants,{$ENDIF} INIFiles, windows, unit1;

//webBrowser was removed from parameters, it creates internaly
// paramStartURL,paramGetTotalSumURL were removed from parameters, it creates internaly
procedure GetVueling(
            paramOutData: TStringList;
            returnflight : boolean;
            flexible: boolean;
            airport_depart: string;
            date_depart: TDateTime;
            airport_destination: string;
            date_return: TDateTime;
            adults: integer;
            children: integer;
            infants: integer);
function DateTimeToStringRet(paramFormat: String; paramDate: TDateTime) : string;
function TryStrToInt(str : string; out Value: Integer) : Boolean;
function TryStrToFloat(str : string; out Value: Double) : Boolean;
function if_str(Expression: Boolean; TrueValue: string;FalseValue: string) : string;
function YearOf(const AValue: TDateTime): Word;
function MonthOf(const AValue: TDateTime): Word;

implementation

uses Forms, Controls, Dialogs;

procedure GetVueling(
            paramOutData: TStringList;
            returnflight : boolean;
            flexible: boolean;
            airport_depart: string;
            date_depart: TDateTime;
            airport_destination: string;
            date_return: TDateTime;
            adults: integer;
            children: integer;
            infants: integer);
const MonthDays : array [Boolean] of TDayTable =
    ((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
    (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));
var
  EncodedDataString: string;
  PostData: OleVariant;
  Headers: OleVariant;
  loc_date_depart: TDateTime;
  loc_date_return: TDateTime;

  i,j,k,tr_index,div_index,innerdiv_index : integer;
  strHTML        : String;
  DocSelect      : IHTMLElementCollection;
  DocElement     : IHtmlElement;
  DocSelectTR    : IHTMLElementCollection;
  DocElementTR   : IHTMLElement;
  DocElementTRTyped   : IHTMLTableRow;
  DocElementFullTotalFare : IHTMLElement;
  DocSelectDiv   : IHTMLElementCollection;
  DocElementDiv  : IHTMLElement;
  Doc            : IHTMLDocument2;
  flight_type,
  flight_no,
  depart_date,
  depart_time,
  arrival_date,
  arrival_time,
  str, via : string;
  price, price_for_infant : double;
  DateConvertDay,DateConvertMonth,DateConvertYear : integer;
  arrival_date_dt : TDateTime;
  IsError : boolean;
  ticks, mainPageTime, totalPriceTime : cardinal;
  ParamWebBrowser: TWebBrowser;
  VuelingStartURL: string;
  ini : tinifile;
  iniPath:string;
  IsSuccess : boolean;
begin
  // separate by month
  if MonthOf(date_depart)<>MonthOf(date_return) then
  begin
    GetVueling( paramOutData,
            returnflight,
            flexible,
            airport_depart,
            IncMonth( EncodeDate(
                YearOf(date_depart),MonthOf(date_depart),1 ),1),
            airport_destination,
            date_return,
            adults,
            children,
            infants);
    date_return := EncodeDate(YearOf(date_depart),
                       MonthOf(date_depart),
                       MonthDays[IsLeapYear(YearOf(date_depart))][MonthOf(date_depart)]
                       );
  end;
  

  // set english month names
  ShortMonthNames[1] := 'Jan';
  ShortMonthNames[2] := 'Feb';
  ShortMonthNames[3] := 'Mar';
  ShortMonthNames[4] := 'Apr';
  ShortMonthNames[5] := 'May';
  ShortMonthNames[6] := 'Jun';
  ShortMonthNames[7] := 'Jul';
  ShortMonthNames[8] := 'Aug';
  ShortMonthNames[9] := 'Sep';
  ShortMonthNames[10] := 'Oct';
  ShortMonthNames[11] := 'Nov';
  ShortMonthNames[12] := 'Dec';

  ParamWebBrowser := TWebBrowser.Create(Application.mainForm);
  try
// Don`t forget to insert   uses Forms;  above
    TWinControl(ParamWebBrowser).Name:= 'ParamWebBrowser'+IntToStr(Application.mainform.ComponentCount);
    TWinControl(ParamWebBrowser).Parent:= Application.mainForm;
    ParamWebBrowser.Height := 800;
    ParamWebBrowser.Visible := true;
    ParamWebBrowser.Align := alTop;
    ParamWebBrowser.Silent := true;
    ParamWebBrowser.Update;
    Application.HandleMessage;
    IniPath:=extractfiledir(Application.ExeName)+'\data\Vueling.ini';
    // change the verification accordint to your rules
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    //May change 4 lines according to your rules
    ini := TIniFile.Create(IniPath);
    VuelingStartURL  := ini.ReadString('main','VuelingStartURL', 'nil');
    ini.free;
    if VuelingStartURL='nil' then
    begin
      ShowMessage('Please chech the value of parameter VuelingStartURL in Vueling.ini');
      exit; //please change the code according to your rules
    end;

    ParamWebBrowser.Height := 1;
    ParamWebBrowser.Visible := false;

    mainPageTime := 0;
    totalPriceTime := 0;
    loc_date_depart := date_depart;
    loc_date_return := date_return;

    //forward
    EncodedDataString :=
      'numberMarkets=2&'+
      'travel_type=on&'+
      'ADULT='+IntToStr(adults)+'&'+
      'CHILD='+IntToStr(children)+'&'+
      'INFANT='+IntToStr(infants)+'&'+
      'departDay1='+DateTimeToStringRet('dd',loc_date_depart)+'&'+
      'departMonth1='+DateTimeToStringRet('mm',loc_date_depart)+''+
                 DateTimeToStringRet('yyyy',loc_date_depart)+'&'+

      'sector1_o=a'+airport_depart+'&'+
      'sector_1_m='+DateTimeToStringRet('mm',loc_date_depart)+''+
                    DateTimeToStringRet('yyyy',loc_date_depart)+'&'+
      'sector1_d='+airport_destination+'&'+
      'sector_2_m='+DateTimeToStringRet('mm',loc_date_return)+''+
                    DateTimeToStringRet('yyyy',loc_date_return)+'&'+
      'from_ff_search=1&'+
      'oP=&'+
      'pT='+IntToStr(adults)+'ADULT'+IntToStr(children)+'CHILD&'+
      'nom=2&'+
      'pM=&'+
      'sid=&'+
      'language=ES&'+
      'mode=&'+
      'mode_orig=&'+
      'module=SB&'+
      'page=FAREFINDER&'+
      'openjaw_flag=true&'+
      'fare_cat=&'+
      'fare_basis=&'+
      'fare_class=&'+
      'tc=2&'+
      'px=&'+
      'm1='+DateTimeToStringRet('yyyy',loc_date_return)+
            DateTimeToStringRet('mm',loc_date_return)+
            IntToStr(MonthDays[IsLeapYear(YearOf(loc_date_depart))][MonthOf(loc_date_depart)])+
            airport_depart+airport_destination+'&'+
      'm1DP=2&'+
      'm1DO=2&'+
      'm2='+DateTimeToStringRet('yyyy',loc_date_depart)+
            DateTimeToStringRet('mm',loc_date_depart)+
            IntToStr(MonthDays[IsLeapYear(YearOf(loc_date_depart))][MonthOf(loc_date_depart)])+
            airport_destination+airport_depart+'&'+
      'm2DP=2&'+
      'm2DO=2&'+
      'sector_1_d=01&'+
      'sector_2_d=01&';

    // The PostData OleVariant needs to be an array of bytes
    // as large as the string (minus the 0 terminator)
    PostData := VarArrayCreate([0, length(EncodedDataString)-1], varByte);

    // Now, move the Ordinal value of the character into the PostData array
    for i := 1 to length(EncodedDataString) do
      PostData[i-1] := ord(EncodedDataString[i]);

    Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

    ticks := GetTickCount;
    // Naviagate to blank page
    paramWebBrowser.Navigate('about:blank');
    repeat
    Application.HandleMessage;
    Sleep(10);
    until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
    // Naviagate to source page
    paramWebBrowser.Navigate(VuelingStartURL, EmptyParam, EmptyParam, PostData, Headers);
    // Wait while page is loading...
    repeat
    Application.HandleMessage;
    Sleep(10);
    until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
    mainPageTime := mainPageTime+(GetTickCount-ticks);
      
    if paramWebBrowser.Document <> nil then
    begin
      paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);

      DocSelectDiv := (Doc.all.tags('DIV')as IHTMLElementCollection);
      for div_index := 0 to DocSelectDiv.length - 1 do
      begin
        DocElementDiv := DocSelectDiv.Item(div_index,EmptyParam) as IHTMLElement;

        // get type
        flight_type := '';
        if pos('TOOLTIP_RADIO_1_', UpperCase(DocElementDiv.id)) > 0 then
          flight_type := 'forward';
        if returnflight  then
          if pos('TOOLTIP_RADIO_2_', UpperCase(DocElementDiv.id)) > 0 then
            flight_type := 'reverse';

        if flight_type <> '' then
        begin
          // decode flight date
          arrival_date := StringReplace(DocElementDiv.id,'tooltip_radio_1_', '',[rfReplaceAll, rfIgnoreCase]);
          arrival_date := StringReplace(arrival_date,'tooltip_radio_2_', '',[rfReplaceAll, rfIgnoreCase]);
          arrival_date := trim(arrival_date);

          if (Length(arrival_date) >= 2) and TryStrToInt(Copy(arrival_date,1,2), DateConvertDay) then
          begin
            arrival_date_dt := EncodeDate(YearOf(date_depart),MonthOf(date_depart),DateConvertDay);
            arrival_date := DateTimeToStringRet('dd mmm yyyy',arrival_date_dt);
            depart_date  := DateTimeToStringRet('dd mmm yyyy',arrival_date_dt);
          end
          else
          if (Length(arrival_date) >= 1) and TryStrToInt(Copy(arrival_date,1,1), DateConvertDay) then
          begin
            arrival_date_dt := EncodeDate(YearOf(date_depart),MonthOf(date_depart),DateConvertDay);
            arrival_date := DateTimeToStringRet('dd mmm yyyy',arrival_date_dt);
            depart_date  := DateTimeToStringRet('dd mmm yyyy',arrival_date_dt);
          end;

          // check date
          if flexible then
            if (arrival_date_dt<date_depart) or (arrival_date_dt>date_return) then
              flight_type := '';
          if not flexible then
            if (arrival_date_dt<>date_depart) or (arrival_date_dt<>date_return) then
              flight_type := '';
        end;

        if flight_type <> '' then
        begin
          DocSelectTR := ((DocElementDiv.all as IHTMLElementCollection).tags('TR')as IHTMLElementCollection);
          for tr_index := 0 to DocSelectTR.length - 1 do
          begin
            DocElementTR := DocSelectTR.Item(tr_index,EmptyParam) as IHTMLElement;
            DocElementTRTyped := DocElementTR as IHTMLTableRow;

            if (DocElementTRTyped.cells.length >=3)then
            begin
              // Get time
              strHTML := (DocElementTRTyped.cells.item(0, 0) as HTMLTableCell).innerHTML;
              if pos('ONCLICKRADIO', UpperCase(strHTML))>0 then
                Delete(strHTML,1,pos('ONCLICKRADIO', UpperCase(strHTML))+Length('ONCLICKRADIO'));
              strHTML := strHTML +',,,,,,,,,,,,,,,,,,,,,,,,,';

              if pos(',', UpperCase(strHTML))>0 then
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              if pos(',', UpperCase(strHTML))>0 then
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              if pos(',', UpperCase(strHTML))>0 then
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              if pos(',', UpperCase(strHTML))>0 then
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              // Price
              if pos(',', UpperCase(strHTML))>0 then
              begin
                Str := copy(strHTML,1,pos(',', UpperCase(strHTML))-1);
                Str := StringReplace(Str,'''', '',[rfReplaceAll, rfIgnoreCase]);
                if not TryStrToFloat(Str, Price) then
                  Price := 0;
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              end;
              if pos(',', UpperCase(strHTML))>0 then
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              // Via/Flight
              if pos(',', UpperCase(strHTML))>0 then
              begin
                Str := copy(strHTML,1,pos(',', UpperCase(strHTML))-1);
                if pos('|', UpperCase(strHTML)) >0 then
                  Str := copy(strHTML,1,pos('|', UpperCase(strHTML))-1);
                Str := StringReplace(Str,'''', '',[rfReplaceAll, rfIgnoreCase]);
                if pos('  ', UpperCase(Str))>0 then
                  Delete(Str,1,pos('  ', UpperCase(Str)));
                Str := Trim(Str);

                if pos(UpperCase(if_str(flight_type = 'forward',airport_depart,airport_destination)), UpperCase(Str)) >0 then
                  flight_no := copy(Str,1,pos(UpperCase(if_str(flight_type = 'forward',airport_depart,airport_destination)), UpperCase(Str))-1);
                if pos('  ', UpperCase(Str))>0 then
                begin
                  // get via
                  via := Copy(Str,Length(Str)-5,3);

                  Delete(Str,1,pos('  ', UpperCase(Str)));
                  Str := Trim(Str);
                  if pos(UpperCase(via), UpperCase(Str)) >0 then
                    flight_no := flight_no + ',' + copy(Str,1,pos(UpperCase(via), UpperCase(Str))-1);
                end
                else
                  via :=  '';
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              end;
              if Trim(via) <> '' then
                price_for_infant := 30
               else
                price_for_infant := 15;

              if pos(',', UpperCase(strHTML))>0 then
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              if pos(',', UpperCase(strHTML))>0 then
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              // Depart Time
              if pos(',', UpperCase(strHTML))>0 then
              begin
                Str := copy(strHTML,1,pos(',', UpperCase(strHTML))-1);
                Str := StringReplace(Str,'''', '',[rfReplaceAll, rfIgnoreCase]);
                depart_time := Trim(Str);
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              end;
              // Arrival Time
              if pos(',', UpperCase(strHTML))>0 then
              begin
                Str := copy(strHTML,1,pos(',', UpperCase(strHTML))-1);
                Str := StringReplace(Str,'''', '',[rfReplaceAll, rfIgnoreCase]);
                arrival_time := Trim(Str);
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              end;
              if pos(',', UpperCase(strHTML))>0 then
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              // Arrival Time
              if pos(',', UpperCase(strHTML))>0 then
              begin
                Str := copy(strHTML,1,pos(',', UpperCase(strHTML))-1);
                Str := StringReplace(Str,'''', '',[rfReplaceAll, rfIgnoreCase]);
                if Trim(Str) <> '' then
                  arrival_time := Trim(Str);
                Delete(strHTML,1,pos(',', UpperCase(strHTML)));
              end;

              price := price*(adults+children)+price_for_infant*infants;
              if price <> 0 then
              begin
                paramOutData.add(
                      FloatToStr(arrival_date_dt)+flight_type+depart_time+'|'+  // sort field
                      flight_type+'|'+
                      depart_date+'|'+
                      depart_time+'|'+
                      arrival_date+'|'+
                      arrival_time+'|'+
                      flight_no+'|'+
                      FloatToStr(price)+'|'+
                      via
                      );
              end;

            end;
          end;
        end;
      end;
      Doc.close;
      

    end
     else
      paramOutData.Add('InternalError');


  finally
    ParamWebBrowser.Free;
  end;
end;

function DateTimeToStringRet(paramFormat: String; paramDate: TDateTime) : string;
begin
  DateTimeToString(Result, paramFormat, paramDate);
end;

function TryStrToInt(str : string; out Value: Integer) : Boolean;
begin
  try
    Value := StrToInt(str);
    result := true;
  except
    result := false;
  end;
end;
function TryStrToFloat(str : string; out Value: Double) : Boolean;
begin
  try
    Value := StrToFloat(str);
    result := true;
  except
    result := false;
  end;
end;
function if_str(Expression: Boolean; TrueValue: string;FalseValue: string) : string;
begin
  if Expression then
    Result := TrueValue
   else
    Result := FalseValue;
end;
function YearOf(const AValue: TDateTime): Word;
var
  LMonth, LDay: Word;
begin
  DecodeDate(AValue, Result, LMonth, LDay);
end;
function MonthOf(const AValue: TDateTime): Word;
var
  LYear, LDay: Word;
begin
  DecodeDate(AValue, LYear, Result, LDay);
end;

end.

