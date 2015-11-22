unit Easyjet;
interface

uses
  SysUtils, Classes, Httpapp, MSHTML, ActiveX, OleCtrls, SHDocVw,
  {$IFNDEF VER130}Variants,{$ENDIF} INIFiles, windows, unit1;

//webBrowser was removed from parameters, it creates internaly
// paramStartURL,paramGetTotalSumURL were removed from parameters, it creates internaly
procedure GetEasyjet(
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

procedure GetEasyjet(
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
var
  EncodedDataString: string;
  PostData: OleVariant;
  Headers: OleVariant;
  loc_date_depart: TDateTime;
  loc_date_return: TDateTime;
  i,j,k,a_index,div_index,innerdiv_index : integer;
  strHTML        : String;
  DocSelect        : IHTMLElementCollection;
  DocElement       : IHtmlElement;
  DocSelectA       : IHTMLElementCollection;
  DocElementA      : IHTMLElement;
  DocElementATyped : IHTMLAnchorElement;
  DocSelectDiv     : IHTMLElementCollection;
  DocElementDiv    : IHTMLElement;
  DocElementFlightInfo    : IHTMLElement;
  Doc              : IHTMLDocument2;
  flight_type,
  flight_no,
  depart_date,
  depart_time,
  arrival_date,
  arrival_time,
  str,
  price : string;
  price_sum,price_numeric : double;
  DateConvertDay,DateConvertMonth,DateConvertYear : integer;
  depart_date_dt,arrival_date_dt : TDateTime;
  ParamWebBrowser: TWebBrowser;
  EasyjetStartURL: string;
  ini : tinifile;
  iniPath:string;
  IsSuccess : boolean;
begin
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
  ShortMonthNames[10]:= 'Oct';
  ShortMonthNames[11]:= 'Nov';
  ShortMonthNames[12]:= 'Dec';

  LongMonthNames[1] := 'January';
  LongMonthNames[2] := 'February';
  LongMonthNames[3] := 'March';
  LongMonthNames[4] := 'April';
  LongMonthNames[5] := 'May';
  LongMonthNames[6] := 'June';
  LongMonthNames[7] := 'July';
  LongMonthNames[8] := 'August';
  LongMonthNames[9] := 'September';
  LongMonthNames[10]:= 'October';
  LongMonthNames[11]:= 'November';
  LongMonthNames[12]:= 'December';

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
    IniPath:=extractfiledir(Application.ExeName)+'\data\Easyjet.ini';
    // change the verification accordint to your rules
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    //May change 4 lines according to your rules
    ini := TIniFile.Create(IniPath);
    EasyjetStartURL  := ini.ReadString('main','EasyjetStartURL', 'nil');
    ini.free;
    if EasyjetStartURL='nil' then
    begin
      ShowMessage('Please chech the value of parameter EasyjetStartURL in Easyjet.ini');
      exit; //please change the code according to your rules
    end;
//
    ParamWebBrowser.Height := 1;
    ParamWebBrowser.Visible := false;

    if returnflight then
      loc_date_depart := date_depart-1
     else
      loc_date_depart := date_depart;
      
    while loc_date_depart <= date_return do
    begin
      loc_date_return := loc_date_depart+1;

      //forward
      EncodedDataString :=
        '__step=1&'+
        '__action=goto&'+
        '__goto=step2.asp&'+
        'txtorigID=&'+
        'txtdestID=&'+
        'txtdorig=&'+
        'txtddest=&'+
        'url=/page/appXML/url&'+
        'numOfPax='+IntToStr(adults+children)+'&'+
        //__STATEDATA	MGoGCSsGAQQBgjdYA6BdMFsGCisGAQQBgjdYAwGgTTBLAgMCAAECAmYDAgIAwAQI|Nq0N1f6heBQEEAcBOPsne0PXiA9lo6PyvSoEIJbX7GCH58hFYKSJ1pxTmSmKIFNJ|P5BNWsSuzKZY7PSP|
        'orig='+airport_depart+'&'+
        'dest='+airport_destination+'&'+
        'oDay='+DateTimeToStringRet('dd',loc_date_depart)+'&'+
        'oMonYear='+DateTimeToStringRet('mm',loc_date_depart)+''+
                    DateTimeToStringRet('yyyy',loc_date_depart)+'&'+
        'rDay='+DateTimeToStringRet('dd',loc_date_return)+'&'+
        'rMonYear='+DateTimeToStringRet('mm',loc_date_return)+''+
                    DateTimeToStringRet('yyyy',loc_date_return)+'&'+
        'numOfAdults='+IntToStr(adults)+'&'+
        'numOfKids='+IntToStr(children)+'&'+
        'numOfInfants='+IntToStr(infants)+'&'+
        'btn_submitForm=Show flights!';

      // The PostData OleVariant needs to be an array of bytes
      // as large as the string (minus the 0 terminator)
      PostData := VarArrayCreate([0, length(EncodedDataString)-1], varByte);

      // Now, move the Ordinal value of the character into the PostData array
      for i := 1 to length(EncodedDataString) do
        PostData[i-1] := ord(EncodedDataString[i]);

      Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

      // Naviagate to blank page
      paramWebBrowser.Navigate('about:blank');
      repeat
      Application.HandleMessage;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      // Naviagate to source page
      paramWebBrowser.Navigate(EasyjetStartURL, EmptyParam, EmptyParam, PostData, Headers);
      // Wait while page is loading...
      repeat
      Application.HandleMessage;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;

      if paramWebBrowser.Document <> nil then
      begin
        paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);

        DocSelectDiv := (Doc.all.tags('DIV')as IHTMLElementCollection);
        for div_index := 0 to DocSelectDiv.length - 1 do
        begin
          DocElementDiv := DocSelectDiv.Item(div_index,EmptyParam) as IHTMLElement;

          // get flight type
          flight_type := '';
          if pos('OUTBOUNDDAYSLIDER', UpperCase(DocElementDiv.className)) > 0 then
            flight_type := 'forward';
          if returnflight  then
            if pos('RETURNDAYSLIDER', UpperCase(DocElementDiv.className)) > 0 then
              flight_type := 'reverse';

          if flexible then
          begin
            if flight_type = 'forward' then
              if (loc_date_depart < date_depart) or (loc_date_depart>date_return) then
                flight_type := '';
            if flight_type = 'reverse' then
              if (loc_date_return < date_depart) or (loc_date_return>date_return) then
                flight_type := '';
          end
          else
          begin
            if flight_type = 'forward' then
              if (loc_date_depart <> date_depart) and (loc_date_depart<>date_return) then
                flight_type := '';
            if flight_type = 'reverse' then
              if (loc_date_return <> date_depart) and (loc_date_return<>date_return) then
                flight_type := '';
          end;
          

          if flight_type <> '' then
          begin
            if (DocElementDiv.children as IHTMLElementCollection).length > 2 then
              DocSelectA := ((  (((DocElementDiv.children as IHTMLElementCollection).item(2, EmptyParam)) as IHTMLElement
                              ).all as IHTMLElementCollection).tags('A') as IHTMLElementCollection);
            if (DocElementDiv.children as IHTMLElementCollection).length > 2 then
            for a_index := 0 to DocSelectA.length - 1 do
            begin
              DocElementA := DocSelectA.Item(a_index,EmptyParam) as IHTMLElement;
              DocElementATyped := DocElementA as IHTMLAnchorElement;

              // clear flight info div
              DocSelect := (Doc.all.tags('DIV')as IHTMLElementCollection);
              for i := 0 to DocSelect.length - 1 do
              begin
                DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
                if pos('EXPANDEDFLIGHTS', UpperCase(DocElement.id)) > 0 then
                begin
                  DocElement.innerHTML := '';
                  break;
                end;
              end;

              DocElementA.click;

              // Wait while page is loading...
              IsSuccess := false;
              repeat
                Application.HandleMessage;
                Sleep(100);
                Doc.close;
                paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);
                // get flight info div
                DocSelect := (Doc.all.tags('DIV')as IHTMLElementCollection);
                for i := 0 to DocSelect.length - 1 do
                begin
                  DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
                  if pos('EXPANDEDFLIGHTS', UpperCase(DocElement.id)) > 0 then
                  begin
                    DocElementFlightInfo := nil;
                    if flight_type = 'forward' then
                    begin
                      DocElementFlightInfo := DocElement;
                    end
                    else
                    begin
                      DocElementFlightInfo := DocElement;
                    end;
                    IsSuccess := DocElement.innerHTML <> '';
                    break;
                  end;
                end;
              until IsSuccess;

              if DocElementFlightInfo <> nil then
              begin
//                // Price
//                DocSelect := (Doc.all.tags('DIV')as IHTMLElementCollection);
//                for i := DocSelect.length - 1 downto 0 do
//                begin
//                  DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
//                  if (pos('AMOUNT', UpperCase(DocElement.className)) > 0)and
//                     (pos('SUBTOTAL', UpperCase(DocElement.className)) > 0) then
//                  begin
//                    strHTML := DocElement.innerHTML;
////                    strHTML := StringReplace(strHTML, ',', DecimalSeparator,[rfReplaceAll, rfIgnoreCase]);
////                    strHTML := StringReplace(strHTML, '.', DecimalSeparator,[rfReplaceAll, rfIgnoreCase]);
//                    price := Trim(strHTML);
//                    break;
//                  end;
//                end;

                // Flight info
                DocSelect := ((DocElementFlightInfo.all as IHTMLElementCollection).tags('DIV')as IHTMLElementCollection);
                for i := DocSelect.length - 1 downto 0 do
                begin
                  DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
                  if (pos('CONTENT', UpperCase(DocElement.className)) > 0) and
                     (pos('H4', UpperCase(DocElement.innerHTML)) > 0) then
                  begin
                    DocElementFlightInfo := DocElement;
                    break;
                  end;
                end;
                if DocElementFlightInfo <> nil then
                begin
                  StrHTML := DocElementFlightInfo.innerHTML;
                  StrHTML := StringReplace(StrHTML, '<strong>', '', [rfReplaceAll, rfIgnoreCase]);
                  StrHTML := StringReplace(StrHTML, '</strong>', '', [rfReplaceAll, rfIgnoreCase]);
                  StrHTML := StringReplace(StrHTML, '\n', '', [rfReplaceAll, rfIgnoreCase]);

                  // Flight
                  Str := StrHTML;
                  if( Pos('FLIGHT', UpperCase(Str))>0 ) then
                    Delete(Str, 1, Pos('FLIGHT', UpperCase(Str))-1+Length('FLIGHT') );
                  if( Pos('<', Str)>0 ) then
                    Str := Copy(Str, 1, Pos('<', Str)-1);
                  Str := StringReplace(Str, '\n', '', [rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, '\t', '', [rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, ' ', '', [rfReplaceAll, rfIgnoreCase]);
                  flight_no := Trim(Str);

                  // Depart Date/Time
                  Str := StrHTML;
                  if( Pos('DEP', UpperCase(Str))>0 ) then
                    Delete(Str, 1, Pos('DEP', UpperCase(Str))-1+Length('DEP') );
                  if( Pos('<', Str)>0 ) then
                    Str := Copy(Str, 1, Pos('<', Str)-1);
                  Str := Trim(Str);
                  DateConvertMonth := 0;
                  for I := 1 to 12 do
                    if( Pos(UpperCase(LongMonthNames[i]), UpperCase(Str))>0 ) then
                    begin
                      Str := StringReplace(Str, LongMonthNames[i], '', [rfReplaceAll, rfIgnoreCase]);
                      DateConvertMonth := i;
                    end;
                  Str := StringReplace(Str, ' ', '', [rfReplaceAll, rfIgnoreCase]);
                  if Length(Str) >= 6 then
                  if TryStrToInt(Copy(Str,1,2), DateConvertDay) then
                    if TryStrToInt(Copy(Str,3,4), DateConvertYear) then
                    begin
                      depart_date_dt := EncodeDate(DateConvertYear,DateConvertMonth,DateConvertDay);
                      depart_date := DateTimeToStringRet('dd mmm yyyy',depart_date_dt);
                      Delete(Str,1,6);
                      depart_time := Str;
                    end;

                  // Arrival Date/Time
                  Str := StrHTML;
                  if( Pos('ARR', UpperCase(Str))>0 ) then
                    Delete(Str, 1, Pos('ARR', UpperCase(Str))-1+Length('ARR') );
                  if( Pos('<', Str)>0 ) then
                    Str := Copy(Str, 1, Pos('<', Str)-1);
                  Str := Trim(Str);
                  DateConvertMonth := 0;
                  for I := 1 to 12 do
                    if( Pos(UpperCase(LongMonthNames[i]), UpperCase(Str))>0 ) then
                    begin
                      Str := StringReplace(Str, LongMonthNames[i], '', [rfReplaceAll, rfIgnoreCase]);
                      DateConvertMonth := i;
                    end;
                  Str := StringReplace(Str, ' ', '', [rfReplaceAll, rfIgnoreCase]);
                  if Length(Str) >= 6 then
                  if TryStrToInt(Copy(Str,1,2), DateConvertDay) then
                    if TryStrToInt(Copy(Str,3,4), DateConvertYear) then
                    begin
                      arrival_date_dt := EncodeDate(DateConvertYear,DateConvertMonth,DateConvertDay);
                      arrival_date := DateTimeToStringRet('dd mmm yyyy',arrival_date_dt);
                      Delete(Str,1,6);
                      arrival_time := Str;
                    end;

                  // Price
                  price_sum := 0;
                  DocSelect := ((DocElementFlightInfo.all as IHTMLElementCollection).tags('LI')as IHTMLElementCollection);
                  for i := 0 to DocSelect.length - 1 do
                  begin
                    DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
                    if (pos('AMOUNT', UpperCase(DocElement.className)) > 0) then
                    begin
                      if flight_no = '8876' then
                      Str := DocElement.innerHTML;

                      Str := DocElement.innerHTML;
                      Str := StringReplace(Str, ',', '', [rfReplaceAll, rfIgnoreCase]);
                      Str := StringReplace(Str, 'ˆ', '', [rfReplaceAll, rfIgnoreCase]);
                      Str := StringReplace(Str, '.', DecimalSeparator, [rfReplaceAll, rfIgnoreCase]);


                      if( Pos('X', UpperCase(Str))>0 ) then
                      begin
                        if not TryStrToInt(Trim(copy(Str, 1, Pos('X', UpperCase(Str))-1 )), j) then
                        begin
                          str := Trim(copy(Str, 1, Pos('X', UpperCase(Str))-1 ));
                          j := 1;
                        end;

                        Delete(Str, 1, Pos('X', UpperCase(Str)) );
                        if TryStrToFloat(Str, price_numeric) then
                          price_sum := price_sum + j * price_numeric;

                      end
                      else
                        if TryStrToFloat(Str, price_numeric) then
                          price_sum := price_sum + price_numeric;
                    end;
                  end;


                  paramOutData.add(
                        FloatToStr(arrival_date_dt)+flight_type+depart_time+'|'+  // sort field
                        flight_type+'|'+
                        depart_date+'|'+
                        depart_time+'|'+
                        arrival_date+'|'+
                        arrival_time+'|'+
                        flight_no+'|'+
                        FloatToStr(price_sum)
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

      if (loc_date_depart = date_return) then
        break;

      if flexible then
        loc_date_depart := loc_date_depart + 1
       else
      begin
        if loc_date_depart = date_depart-1 then
        begin
          loc_date_depart := date_depart
        end
        else
        if loc_date_depart = date_depart then
        begin
          if date_depart < date_return-1 then
            loc_date_depart := date_return-1
           else
            loc_date_depart := date_return;
        end
        else
        if loc_date_depart = date_return-1 then
        begin
          loc_date_depart := date_return;
        end;
      end;
    end;


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

