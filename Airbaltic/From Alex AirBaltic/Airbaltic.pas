unit Airbaltic;
interface

uses
  SysUtils, Classes, Httpapp, MSHTML, ActiveX, OleCtrls, SHDocVw,
  {$IFNDEF VER130}Variants,{$ENDIF} INIFiles, windows, unit1;

procedure GetAirbaltic(
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
function if_str(Expression: Boolean; TrueValue: string;FalseValue: string) : string;
function TryStrToInt(str : string; out Value: Integer) : Boolean;
function TryStrToFloat(str : string; out Value: Double) : Boolean;
function YearOf(const AValue: TDateTime): Word;
function MonthOf(const AValue: TDateTime): Word;

implementation

uses Forms, Controls, Dialogs;


procedure GetAirbaltic(
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
  i,j,k,a_index,div_index,div2_index,td_index : integer;
  strHTML        : String;
  DocSelect        : IHTMLElementCollection;
  DocElement       : IHtmlElement;
  DocElementSelect : IHTMLSelectElement;
  DocElementInput  : IHTMLInputElement;
  DocSelectDiv     : IHTMLElementCollection;
  DocElementDiv    : IHTMLElement;
  DocSelectDiv2    : IHTMLElementCollection;
  DocElementDiv2   : IHTMLElement;
  DocSelectTD      : IHTMLElementCollection;
  DocElementTD     : IHTMLElement;
  DocElementResults: IHTMLElement;
  Doc              : IHTMLDocument2;
  flight_type,
  flight_no,
  depart_date,
  depart_time,
  arrival_date,
  arrival_time,
  str,
  via,
  price : string;
//  price_infant: double;
//  price_sum,price_numeric : double;
  DateConvertDay,DateConvertMonth,DateConvertYear : integer;
  depart_date_dt,arrival_date_dt : TDateTime;
  ParamWebBrowser: TWebBrowser;
  currency_code,
  default_flight_suffix,
  AirbalticStartURL: string;
  ini : tinifile;
  iniPath:string;
  IsSuccess : boolean;

  function SetInputControlsAndWaitResults(paramIsReverse : boolean):IHTMLElement;
  var
    i : integer;
  begin
    // set controls...
    if paramWebBrowser.Document <> nil then
    begin
      paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);

      DocSelect := (Doc.all.tags('SELECT')as IHTMLElementCollection);
      for i := 0 to DocSelect.length - 1 do
      try
        DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
        DocElementSelect := DocElement as IHTMLSelectElement;
        // destination
        if paramIsReverse then
        begin
          if POS('ORIGIN',UpperCase(DocElementSelect.name))>0 then
            DocElementSelect.value := airport_destination;
          if POS('DESTIN',UpperCase(DocElementSelect.name))>0 then
          begin
            try
              DocElementSelect.add(
                  (Doc.parentWindow.Option as IHTMLOptionElementFactory).create(
                          airport_depart,airport_depart,true,true) as IHTMLElement, true);
            except
            end;
            DocElementSelect.value := airport_depart;
          end;
        end
        else
        begin
          if POS('ORIGIN',UpperCase(DocElementSelect.name))>0 then
            DocElementSelect.value := airport_depart;
          if POS('DESTIN',UpperCase(DocElementSelect.name))>0 then
          begin
            try
              DocElementSelect.add(
                  (Doc.parentWindow.Option as IHTMLOptionElementFactory).create(
                          airport_destination,airport_destination,true,true) as IHTMLElement, true);
            except
            end;
            DocElementSelect.value := airport_destination;
          end;
        end;
        // persons
        if POS('NUMADT',UpperCase(DocElementSelect.name))>0 then
          DocElementSelect.value := IntToStr(adults);
        if POS('NUMCHD',UpperCase(DocElementSelect.name))>0 then
          DocElementSelect.value := IntToStr(children);
        if POS('NUMINF',UpperCase(DocElementSelect.name))>0 then
          DocElementSelect.value := IntToStr(infants);
        // dates
        if paramIsReverse then
        begin                                                  
          if POS('DAY0',UpperCase(DocElementSelect.name))>0 then
            DocElementSelect.value := DateTimeToStringRet('dd',loc_date_return);
          if POS('DAY1',UpperCase(DocElementSelect.name))>0 then
            DocElementSelect.value := DateTimeToStringRet('dd',loc_date_depart);
          if POS('MONTH0',UpperCase(DocElementSelect.name))>0 then
            DocElementSelect.value := DateTimeToStringRet('mm',loc_date_return)+
                                  '-'+DateTimeToStringRet('yyyy',loc_date_return);
          if POS('MONTH1',UpperCase(DocElementSelect.name))>0 then
            DocElementSelect.value := DateTimeToStringRet('mm',loc_date_depart)+
                                  '-'+DateTimeToStringRet('yyyy',loc_date_depart);
        end
        else
        begin
          if POS('DAY0',UpperCase(DocElementSelect.name))>0 then
            DocElementSelect.value := DateTimeToStringRet('dd',loc_date_depart);
          if POS('DAY1',UpperCase(DocElementSelect.name))>0 then
            DocElementSelect.value := DateTimeToStringRet('dd',loc_date_return);
          if POS('MONTH0',UpperCase(DocElementSelect.name))>0 then
            DocElementSelect.value := DateTimeToStringRet('mm',loc_date_depart)+
                                  '-'+DateTimeToStringRet('yyyy',loc_date_depart);
          if POS('MONTH1',UpperCase(DocElementSelect.name))>0 then
            DocElementSelect.value := DateTimeToStringRet('mm',loc_date_return)+
                                  '-'+DateTimeToStringRet('yyyy',loc_date_return);
        end;
        // travel class
        if POS('COMPARTMENT',UpperCase(DocElementSelect.name))>0 then
          DocElementSelect.value := 'ER';
      except
      end;
      DocSelect := (Doc.all.tags('INPUT')as IHTMLElementCollection);
      for i := 0 to DocSelect.length - 1 do
      try
        DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
        DocElementInput := DocElement as IHTMLInputElement;
        if POS('TRAVELTYPE',UpperCase(DocElementInput.name))>0 then
          if POS('bti',UpperCase(DocElement.innerHTML))>0 then
            DocElementInput.checked := true;
        if POS('LEGS',UpperCase(DocElementInput.name))>0 then
        begin
          DocElementInput.checked := DocElementInput.value = '1';
        end;
      except
      end;
      // Cleck "Select"
      DocSelect := (Doc.all.tags('INPUT')as IHTMLElementCollection);
      for i := 0 to DocSelect.length - 1 do
      try
        DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
        DocElementInput := DocElement as IHTMLInputElement;
        if POS('CONTINUE',UpperCase(DocElementInput.value))>0 then
          if DocElementInput.form <> nil then
            //if DocElementInput.form <> NULL then
              if POS('FB_INPUT',UpperCase(DocElementInput.form.name))>0 then
                DocElement.click;
      except
      end;

      // Wait
      IsSuccess := false;
      Result := nil;
      repeat
        Application.HandleMessage;
        Sleep(50);
        Doc.close;
        paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);
        // get flights info table
        DocSelect := (Doc.all.tags('TABLE')as IHTMLElementCollection);
        for i := 0 to DocSelect.length - 1 do
        begin
          DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
          if pos('TBLFARES', UpperCase(DocElement.id)) > 0 then
          begin
            IsSuccess := true;
            Result := DocElement;
            break;
          end;
        end;
        DocSelect := (Doc.all.tags('DIV')as IHTMLElementCollection);
        for i := 0 to DocSelect.length - 1 do
        begin
          DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
          if pos('AVAIL_NONEFOUND', UpperCase(DocElement.id)) > 0 then
          begin
            IsSuccess := true;
            Result := nil;
            break;
          end;
        end;
      until IsSuccess;

    end;
  end;

  procedure GetResultsForDay();
  var
    div_index, div2_index, td_index, i : integer;
    flight_duration : string;
    flight_duration_h,flight_duration_m,
    depart_time_h, depart_time_m : integer;
  begin
    if (paramWebBrowser.Document <> nil) and
       (DocElementResults <> nil) then
    begin
      paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);

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

      DocSelectDiv := (Doc.all.tags('DIV')as IHTMLElementCollection);
      if flight_type <> '' then
      for div_index := 0 to DocSelectDiv.length - 1 do
      begin
        DocElementDiv := DocSelectDiv.Item(div_index,EmptyParam) as IHTMLElement;

        if( Pos('ID_FLTDATE_', UpperCase(DocElementDiv.id))>0 ) then
        begin
          StrHTML := DocElementDiv.innerHTML;
          StrHTML := StringReplace(StrHTML, '&', ' ', [rfReplaceAll, rfIgnoreCase]);
          StrHTML := StringReplace(StrHTML, 'nbsp', '    ', [rfReplaceAll, rfIgnoreCase]);
          StrHTML := StringReplace(StrHTML, ';', ' ', [rfReplaceAll, rfIgnoreCase]);
          StrHTML := StringReplace(StrHTML, '.', ' ', [rfReplaceAll, rfIgnoreCase]);
          StrHTML := StringReplace(StrHTML, ' ', '', [rfReplaceAll, rfIgnoreCase]);
          Str := DateTimeToStringRet('mmm',loc_date_depart)+DateTimeToStringRet('d',loc_date_depart);
        end
        else
          StrHTML := '';

        if (StrHTML <> '')and
           (pos(UpperCase(DateTimeToStringRet('mmm',loc_date_depart)+DateTimeToStringRet('d',loc_date_depart)),
                UpperCase(StrHTML)) > 0) then
        begin
          // Get Price
          price := '';
          if flexible then
            Str := 'ID_MATRIX_'+IntToStr(round(loc_date_depart - date_depart) mod 7)
           else
            Str := 'ID_MATRIX_3';

          DocSelectDiv2 := (Doc.all.tags('TD') as IHTMLElementCollection);
          for div2_index := 0 to DocSelectDiv2.length - 1 do
          begin
            DocElementDiv2 := DocSelectDiv2.Item(div2_index,EmptyParam) as IHTMLElement;
//            if( Pos('MATRIX', UpperCase(DocElementDiv2.id))>0 ) then
//              Str := 'ID_MATRIX_'+IntToStr(round(loc_date_depart - date_depart) mod 7);

            if( Pos(Str, UpperCase(DocElementDiv2.id))>0 ) then
            begin
              strHTML  := DocElementDiv2.innerHTML;
              if( Pos('UNDERLINE', UpperCase(strHTML))>0 ) then
              if( Pos('/SPAN', UpperCase(strHTML))>0 ) then
              begin
                currency_code := '�';
                Delete(strHTML,1,Pos('UNDERLINE', UpperCase(strHTML)));
                if Pos('>', strHTML) >0 then
                  Delete(strHTML,1, Pos('>', strHTML));
                price := Trim(Copy(strHTML,1,Pos('<', UpperCase(strHTML))-1));
              end;
            end;
          end;



          DocSelectDiv2 := (( DocElementDiv.all as IHTMLElementCollection).tags('DIV') as IHTMLElementCollection);

          for div2_index := 0 to DocSelectDiv2.length - 1 do
          begin
            DocElementDiv2 := DocSelectDiv2.Item(div2_index,EmptyParam) as IHTMLElement;

            DocSelectTD := (( DocElementDiv2.all as IHTMLElementCollection).tags('TD') as IHTMLElementCollection);
            for td_index := 0 to DocSelectTD.length - 1 do
            begin
              DocElementTD := DocSelectTD.Item(td_index,EmptyParam) as IHTMLElement;
              if( Pos('ID_FLT_', UpperCase(DocElementTD.id))>0 ) then
              begin
                strHTML := DocElementTD.innerHTML;

                flight_no := '';
                via := '';
                depart_date := DateTimeToStringRet('dd mmm yyyy',loc_date_depart);
                depart_time := '';
                arrival_date := DateTimeToStringRet('dd mmm yyyy',loc_date_depart);
                arrival_time := '';


                while (Pos('<A HREF="JAVASCRIPT:OPENPOP(', UpperCase(strHTML)) > 0) do
                begin
                  // arrival time and depart time
                  Str := Copy(strHTML,1,Pos('<A HREF="JAVASCRIPT:OPENPOP(', UpperCase(strHTML)));
                  while Pos('>', UpperCase(Str)) >0 do
                    Delete(Str,1, Pos('>', UpperCase(Str)));
                  Str := Trim(Str);
                  if Pos(' ', UpperCase(Str)) > 0 then
                  begin
                    if flight_no = '' then
                      depart_time := Copy(Str,1,Pos(' ', UpperCase(Str))-1);
                    Delete(Str,1,Pos(' ', UpperCase(Str)));
                  end;
                  Str := Trim(Str);
                  if Pos(':', UpperCase(Str)) > 0 then
                  begin
                    if flight_no <> '' then
                      via := Trim(Copy(Str,1,Pos(':', UpperCase(Str))-3));
                    Delete(Str,1,Pos(':', UpperCase(Str))-3);
                  end;
                  Str := Trim(Str);
                  if Pos(' ', UpperCase(Str)) > 0 then
                  begin
                    arrival_time := Copy(Str,1,Pos(' ', UpperCase(Str))-1);
                    Delete(Str,1,Pos(' ', UpperCase(Str)));
                  end;
                  // flight num
                  Delete(strHTML, 1, Pos('<A HREF="JAVASCRIPT:OPENPOP(', UpperCase(strHTML)) );
                  if Pos('>', strHTML) >0 then
                    Delete(strHTML,1, Pos('>', strHTML));
                  if Pos('<', strHTML) >0 then
                  begin
                    Str := Copy(strHTML,1,Pos('<', UpperCase(strHTML))-1);
                    if TryStrToInt(Str, j) then
                      Str := default_flight_suffix + Str;
                    if flight_no <> '' then
                      flight_no := flight_no + ',';
                    flight_no := flight_no + Trim(Str);
                  end;
                end;
                // flight duration
                flight_duration := '';
                if Pos('FLIGHT DURATION:', UpperCase(strHTML)) >0 then
                  Delete(strHTML, 1, Pos('FLIGHT DURATION:', UpperCase(strHTML)) );
                if Pos('>', strHTML) >0 then
                  Delete(strHTML,1, Pos('>', strHTML));
                strHTML := Trim(strHTML);
                flight_duration := Copy(strHTML,1,5);
                if (flight_duration[3]=':')and(depart_time[3]=':') then
                if TryStrToInt(copy(flight_duration,1,2),flight_duration_h) then
                if TryStrToInt(copy(flight_duration,4,2),flight_duration_m) then
                if TryStrToInt(copy(depart_time,1,2),depart_time_h) then
                if TryStrToInt(copy(depart_time,4,2),depart_time_m) then
                begin
                  if (depart_time_m + flight_duration_m)>60 then
                    Inc(flight_duration_h);
                  if (depart_time_h + flight_duration_h)>24 then
                    arrival_date := DateTimeToStringRet(
                          'dd mmm yyyy',
                          loc_date_depart+(depart_time_h + flight_duration_h) div 24
                          );
                end;

                paramOutData.add(
                      FloatToStr(loc_date_depart)+flight_type+depart_time+'|'+  // sort field
                      flight_type+'|'+
                      depart_date+'|'+
                      depart_time+'|'+
                      arrival_date+'|'+
                      arrival_time+'|'+
                      flight_no+'|'+
                      currency_code+' '+price+'|'+
                      via
                      );
              end;
            end;
          end;


        end;
      end;
      Doc.close;
    end;
//     else
//      paramOutData.Add('InternalError');

//    sleep(1000);
    Application.ProcessMessages;
  end;

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
    IniPath:=extractfiledir(Application.ExeName)+'\data\Airbaltic.ini';
    // change the verification accordint to your rules
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    //May change 4 lines according to your rules
    ini := TIniFile.Create(IniPath);
    AirbalticStartURL  := ini.ReadString('main','AirbalticStartURL', 'nil');
    default_flight_suffix  := ini.ReadString('main','DefaultFlightSuffix', '');
    ini.free;
    if AirbalticStartURL='nil' then
    begin
      ShowMessage('Please chech the value of parameter AirbalticSLOWStartURL in Airbaltic.ini');
      exit; //please change the code according to your rules
    end;
//
    ParamWebBrowser.Height := 1;
    ParamWebBrowser.Visible := false;

    Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

    // ############ Get Flights - forward
    loc_date_depart := date_depart;
    while loc_date_depart <= date_return do
    begin
      loc_date_return := loc_date_depart;

      if ((round(loc_date_depart - date_depart) mod 7) = 0) or
         ((not flexible))  then
      begin
        DocElementResults := nil;
        //forward
        if (flexible) then
        begin
          loc_date_depart := loc_date_depart+3;
          loc_date_return := loc_date_return+3;
        end;

        Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

//        // Naviagate to blank page
//        paramWebBrowser.Navigate('about:blank');
//        repeat
//        Application.HandleMessage;
//        Sleep(10);
//        until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
        // Naviagate to source page
        paramWebBrowser.Navigate(AirbalticStartURL, EmptyParam, EmptyParam, EmptyParam, Headers);
        // Wait while page is loading...
        repeat
        Application.HandleMessage;
        Sleep(10);
        until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;

        DocElementResults := SetInputControlsAndWaitResults(false);

        if (flexible) then
        begin
          loc_date_depart := loc_date_depart-3;
          loc_date_return := loc_date_return-3;
        end;
      end;

      // Set flight type
      flight_type := 'forward';
      GetResultsForDay();

      if (loc_date_depart = date_return) then
        break;

      if flexible then
        loc_date_depart := loc_date_depart + 1
       else
        loc_date_depart := date_return;
    end;

    // ############ Get Flights - forward
    loc_date_depart := date_depart;
    if returnflight then
      while loc_date_depart <= date_return do
      begin
        loc_date_return := loc_date_depart;

        if ((round(loc_date_depart - date_depart) mod 7) = 0) or
           ((not flexible))  then
        begin
          DocElementResults := nil;
          //forward
          if (flexible) then
          begin
            loc_date_depart := loc_date_depart+3;
            loc_date_return := loc_date_return+3;
          end;

          Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

//          // Naviagate to blank page
//          paramWebBrowser.Navigate('about:blank');
//          repeat
//          Application.HandleMessage;
//          Sleep(10);
//          until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;

          // Naviagate to source page
          paramWebBrowser.Navigate(AirbalticStartURL, EmptyParam, EmptyParam, EmptyParam, Headers);
          // Wait while page is loading...
          repeat
          Application.HandleMessage;
          Sleep(10);
          until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;

          DocElementResults := SetInputControlsAndWaitResults(true);

          if (flexible) then
          begin
            loc_date_depart := loc_date_depart-3;
            loc_date_return := loc_date_return-3;
          end;
        end;

        // Set flight type
        flight_type := 'reverse';
        GetResultsForDay();

        if (loc_date_depart = date_return) then
          break;

        if flexible then
          loc_date_depart := loc_date_depart + 1
         else
          loc_date_depart := date_return;
      end;


  finally
    ParamWebBrowser.Free;
  end;
end;

function DateTimeToStringRet(paramFormat: String; paramDate: TDateTime) : string;
begin
  DateTimeToString(Result, paramFormat, paramDate);
end;
function if_str(Expression: Boolean; TrueValue: string;FalseValue: string) : string;
begin
  if Expression then
    Result := TrueValue
   else
    Result := FalseValue;
end;
function TryStrToInt(str : string; out Value: Integer) : Boolean;
var
  i : integer;
begin
  Value := 0;
  for i := 1 to length(str) do
    if not(str[i] in ['0','1','2','3','4','5','6','7','8','9','.',',',' ','-','+']) then
    begin
      Result := False;
      exit
    end;
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
    if str <> '' then
      Value := StrToFloat(str);
    result := true;
  except
    result := false;
  end;
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


