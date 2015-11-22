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
function YearOf(const AValue: TDateTime): Word;
function MonthOf(const AValue: TDateTime): Word;

implementation

uses Forms, Controls, Dialogs;

function GetEasyjetInfantPrice(
            airport_depart: string;
            date_depart: TDateTime;
            airport_destination: string;
            date_return: TDateTime):double;
var
  EncodedDataString: string;
  PostData: OleVariant;
  Headers: OleVariant;
  loc_date_depart: TDateTime;
  loc_date_return: TDateTime;
  i, a_index,div_index : integer;
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
  Str : string;
  price_numeric : double;
  ParamWebBrowser: TWebBrowser;
  currency_code, EasyjetInfantURL: string;
  ini : tinifile;
  iniPath:string;
  IsSuccess : boolean;
begin
  Result := 0;
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
    EasyjetInfantURL  := ini.ReadString('main','EasyjetInfantPriceURL', 'nil');
    ini.free;
    if EasyjetInfantURL='nil' then
    begin
      Result:=20;
      exit; //please change the code according to your rules
    end;
//
    ParamWebBrowser.Height := 1;
    ParamWebBrowser.Visible := false;

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
        'numOfPax='+IntToStr(2)+'&'+
        //__STATEDATA	MGoGCSsGAQQBgjdYA6BdMFsGCisGAQQBgjdYAwGgTTBLAgMCAAECAmYDAgIAwAQI|Nq0N1f6heBQEEAcBOPsne0PXiA9lo6PyvSoEIJbX7GCH58hFYKSJ1pxTmSmKIFNJ|P5BNWsSuzKZY7PSP|
        'orig='+airport_depart+'&'+
        'dest='+airport_destination+'&'+
        'oDay='+DateTimeToStringRet('dd',loc_date_depart)+'&'+
        'oMonYear='+DateTimeToStringRet('mm',loc_date_depart)+''+
                    DateTimeToStringRet('yyyy',loc_date_depart)+'&'+
        'rDay='+DateTimeToStringRet('dd',loc_date_return)+'&'+
        'rMonYear='+DateTimeToStringRet('mm',loc_date_return)+''+
                    DateTimeToStringRet('yyyy',loc_date_return)+'&'+
        'numOfAdults='+IntToStr(1)+'&'+
        'numOfKids='+IntToStr(0)+'&'+
        'numOfInfants='+IntToStr(1)+'&'+
        'btn_submitForm=Show flights!';

      // The PostData OleVariant needs to be an array of bytes
      // as large as the string (minus the 0 terminator)
      PostData := VarArrayCreate([0, length(EncodedDataString)-1], varByte);

      // Now, move the Ordinal value of the character into the PostData array
      for i := 1 to length(EncodedDataString) do
        PostData[i-1] := ord(EncodedDataString[i]);

      Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

      // Naviagate to source page
      paramWebBrowser.Navigate(EasyjetInfantURL, EmptyParam, EmptyParam, PostData, Headers);
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
          if pos('RETURNDAYSLIDER', UpperCase(DocElementDiv.className)) > 0 then
            flight_type := 'reverse';

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

                  // Price
                  DocSelect := ((DocElementFlightInfo.all as IHTMLElementCollection).tags('LI')as IHTMLElementCollection);
                  for i := 0 to DocSelect.length - 1 do
                  begin
                    DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
                    if (pos('AMOUNT', UpperCase(DocElement.className)) > 0) then
                    begin
                      Str := DocElement.innerHTML;
                      //�
                      if pos('�', Str)>0 then
                      begin
                        currency_code := 'EUR';
                        Str := StringReplace(Str,'�', '',[rfReplaceAll, rfIgnoreCase]);
                      end
                      else
                      //Pound
                      if pos(#63, Str)>0 then
                      begin
                        currency_code := 'GBP';
                        Str := StringReplace(Str, #63, '',[rfReplaceAll, rfIgnoreCase]);
                      end
                      else
                      // The plural form is pronounced darahim, although in French and English "dirhams" is commonly used.
                      // Its ISO 4217 code is "MAD".
                      if pos('Md', Str)>0 then
                      begin
                        currency_code := 'MAD';
                        Str := StringReplace(Str, 'Md', '',[rfReplaceAll, rfIgnoreCase]);
                      end
                      else
                      // Polish z?oty
                      // Its ISO 4217 code is "PLN".
                      if pos('zl', Str)>0 then
                      begin
                        currency_code := 'PLN';
                        Str := StringReplace(Str, 'zl', '',[rfReplaceAll, rfIgnoreCase]);
                      end
                      else
                      // Hungarian forint
                      // Its ISO 4217 code is "HUF".
                      if pos('Ft', Str)>0 then
                      begin
                        currency_code := 'HUF';
                        Str := StringReplace(Str, 'Ft', '',[rfReplaceAll, rfIgnoreCase]);
                      end
                      else
                      // Czech koruna
                      // Its ISO 4217 code is "CZK".
                      if pos('Kc', Str)>0 then
                      begin
                        currency_code := 'CZK';
                        Str := StringReplace(Str, 'Kc', '',[rfReplaceAll, rfIgnoreCase]);
                      end
                      else
                      // Danish krone
                      // Its ISO 4217 code is "DKK".
                      if pos('Dkr', Str)>0 then
                      begin
                        currency_code := 'DKK';
                        Str := StringReplace(Str, 'Dkr', '',[rfReplaceAll, rfIgnoreCase]);
                      end
                      else
                      // Swiss franc
                      // Its ISO 4217 code is "DKK".
                      if pos('CHF', Str)>0 then
                      begin
                        currency_code := 'CHF';
                        Str := StringReplace(Str, 'CHF', '',[rfReplaceAll, rfIgnoreCase]);
                      end
                      else
                        currency_code := '';

                        //Md

                      Str := StringReplace(Str,'</span>', '',[rfReplaceAll, rfIgnoreCase]);
                      Str := StringReplace(Str,' ', '',[rfReplaceAll, rfIgnoreCase]);
                      Str := StringReplace(Str,'&nbsp;', '',[rfReplaceAll, rfIgnoreCase]);
                      Str := StringReplace(Str,',', '',[rfReplaceAll, rfIgnoreCase]);
                      Str := StringReplace(Str,'<span>', DecimalSeparator, [rfReplaceAll, rfIgnoreCase]);
                      Str := StringReplace(Str,'.', DecimalSeparator, [rfReplaceAll, rfIgnoreCase]);
                      if pos('X', UpperCase(Str))>0 then
                        Delete(Str,1,pos('X', UpperCase(Str)));
                      if TryStrToFloat(Str, price_numeric) then
                        Result := price_numeric;

                    end;
                  end;
                end;
              end;

            end;
          end;
        end;
        Doc.close;


      end;
      if (loc_date_depart = date_return) then
        break;

      if (Result <> 0) then
        break;

      loc_date_depart := loc_date_depart + 1
    end;
  finally
    ParamWebBrowser.Free;
  end;
end;

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
  i,j,k,day_index,a_index,div_index,innerdiv_index : integer;
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
  price_infant: double;
  price_sum,price_numeric : double;
  DateConvertDay,DateConvertMonth,DateConvertYear : integer;
  depart_date_dt,arrival_date_dt : TDateTime;
  ParamWebBrowser: TWebBrowser;
  currency_code,
  default_flight_suffix,
  EasyjetMainURL,
  EasyjetStartURL: String;
  ini : tinifile;
  iniPath:string;
  IsSuccess : boolean;
  flight_nums : TStringList;
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
    EasyjetStartURL  := ini.ReadString('main','EasyjetSLOWStartURL', 'nil');
    EasyjetMainURL  := ini.ReadString('main','EasyjetSLOWMainURL', 'nil');
    price_infant := ini.ReadInteger('main','EasyjetInfantPrice', 0);
    default_flight_suffix  := ini.ReadString('main','DefaultFlightSuffix', '');
    ini.free;
    if EasyjetStartURL='nil' then
    begin
      ShowMessage('Please chech the value of parameter EasyjetSLOWStartURL in Easyjet.ini');
      exit; //please change the code according to your rules
    end;
//
    ParamWebBrowser.Height := 1;
    ParamWebBrowser.Visible := false;

{    if (infants > 0) and (price_infant = 0) then
    begin
      price_infant := GetEasyjetInfantPrice(
              airport_depart,
              date_depart,
              airport_destination,
              date_return);
      if price_infant = 0 then
        price_infant := 0.000001;
    end;
}
    Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

    // ############ Get Flight Nums
    flight_nums := TStringList.Create;
    // goto friday
    loc_date_depart := date_depart;
    while  DayOfWeek(loc_date_depart) <> 5 do
      loc_date_depart := loc_date_depart + 1;
    loc_date_return := loc_date_depart + 1;
    EncodedDataString :=
      'origAirportCode='+airport_depart+
      '&destAirportCode='+airport_destination+
      '&departureDay='+DateTimeToStringRet('dd',loc_date_depart)+
      '&departureMonthYear='+DateTimeToStringRet('mm',loc_date_depart)+''+
                             DateTimeToStringRet('yyyy',loc_date_depart)+
      '&returnDay='+DateTimeToStringRet('dd',loc_date_return)+
      '&returnMonthYear='+DateTimeToStringRet('mm',loc_date_return)+''+
                          DateTimeToStringRet('yyyy',loc_date_return)+
      '&numberOfAdults='+IntToStr(adults)+
      '&numberOfChildren='+IntToStr(children)+
      '&numberOfInfants='+IntToStr(infants)+
      '&flexibleOnDates=false&email=';

    // Naviagate to source page
    paramWebBrowser.Navigate(EasyjetStartURL+'?'+EncodedDataString, EmptyParam, EmptyParam, EmptyParam, Headers);
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


        if flight_type <> '' then
        if (DocElementDiv.children as IHTMLElementCollection).length > 2 then
        begin
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
                if TryStrToInt(Str, j) then
                  Str := default_flight_suffix + Str;
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

                if flight_nums.IndexOfName(flight_type+depart_time+'|'+arrival_time) = -1 then
                  flight_nums.add( flight_type+depart_time+'|'+arrival_time+'='+flight_no );
              end;
            end;

          end;
        end;
      end;
      Doc.close;
    end;

    // ############ Get Flights
    loc_date_depart := date_depart;
    while loc_date_depart <= date_return do
    begin
      loc_date_return := loc_date_depart;

      if ((round(loc_date_depart - date_depart) mod 3) = 0) or (not flexible)  then
      begin
        //forward
        if (flexible) then
        begin
          loc_date_depart := loc_date_depart+1;
          loc_date_return := loc_date_return+1;
        end;

        EncodedDataString :=
//          'acOriginAirport='+airport_depart+
//          '&acOriginAirportValue='+airport_depart+
//          '&oDay='+DateTimeToStringRet('d',loc_date_depart)+
//          '&oMonYear='+DateTimeToStringRet('mm',loc_date_depart)+''+
//                       DateTimeToStringRet('yyyy',loc_date_depart)+
//          '&oDate='+DateTimeToStringRet('dd',loc_date_depart)+''+
//                    DateTimeToStringRet('mm',loc_date_depart)+''+
//                    DateTimeToStringRet('yyyy',loc_date_depart)+
//          '&chkIsReturn=on'+
//          '&acDestinationAirport='+airport_destination+
//          '&acDestinationAirportValue='+airport_destination+
//          '&rDay='+DateTimeToStringRet('d',loc_date_return)+
//          '&rMonYear='+DateTimeToStringRet('mm',loc_date_return)+''+
//                       DateTimeToStringRet('yyyy',loc_date_return)+
//          '&rDate='+DateTimeToStringRet('dd',loc_date_return)+''+
//                    DateTimeToStringRet('mm',loc_date_return)+''+
//                    DateTimeToStringRet('yyyy',loc_date_return)+
//          '&SelectFlights='+
//          '&SelectLowestFlights='+
//          '&SelectLowestFlightsByMonth='+
//          '&DisplayCurrency=EUR'+
//          '&currencyChanged=currencyChanged'+
//          '&FlightOptionsState=Hidden';

          'origAirportCode='+airport_depart+
          '&destAirportCode='+airport_destination+
          '&departureDay='+DateTimeToStringRet('dd',loc_date_depart)+
          '&departureMonthYear='+DateTimeToStringRet('mm',loc_date_depart)+''+
                                 DateTimeToStringRet('yyyy',loc_date_depart)+
          '&returnDay='+DateTimeToStringRet('dd',loc_date_return)+
          '&returnMonthYear='+DateTimeToStringRet('mm',loc_date_return)+''+
                              DateTimeToStringRet('yyyy',loc_date_return)+
          '&numberOfAdults='+IntToStr(adults)+
          '&numberOfChildren='+IntToStr(children)+
          '&numberOfInfants='+IntToStr(infants)+
          '&flexibleOnDates=false&email=';

//        // The PostData OleVariant needs to be an array of bytes
//        // as large as the string (minus the 0 terminator)
//        PostData := VarArrayCreate([0, length(EncodedDataString)-1], varByte);
//
//        // Now, move the Ordinal value of the character into the PostData array
//        for i := 1 to length(EncodedDataString) do
//          PostData[i-1] := ord(EncodedDataString[i]);

        if (flexible) then
        begin
          loc_date_depart := loc_date_depart-1;
          loc_date_return := loc_date_return-1;
        end;

        // Naviagate to source page
        Sleep(1000);
        paramWebBrowser.Navigate(EasyjetStartURL+'?'+EncodedDataString, EmptyParam, EmptyParam, EmptyParam, Headers);
        // Wait while page is loading...
        repeat
        Application.HandleMessage;
        Sleep(10);
        until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      end;

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

          if not flexible then
            day_index := 2
           else
            day_index := 1 + (round(loc_date_depart - date_depart) mod 3);

          if flight_type <> '' then
          if (DocElementDiv.children as IHTMLElementCollection).length >= 4 then
          begin
            DocSelectA := ((  (((DocElementDiv.children as IHTMLElementCollection).item(day_index, EmptyParam)) as IHTMLElement
                            ).all as IHTMLElementCollection).tags('A') as IHTMLElementCollection);

            for a_index := 0 to DocSelectA.length - 1 do
//            if pos('PRICESMALLER',
//             UpperCase((DocSelectA.Item(a_index,EmptyParam) as IHTMLElement).className)) > 0 then
            begin
              DocElementA := DocSelectA.Item(a_index,EmptyParam) as IHTMLElement;
              DocElementATyped := DocElementA as IHTMLAnchorElement;

              // Depart Date/Time
              Str := DocElementA.innerHTML;
              if( Pos('DEP', UpperCase(Str))>0 ) then
                Delete(Str, 1, Pos('DEP', UpperCase(Str))-1+Length('DEP') );
              if( Pos('<', Str)>0 ) then
                Str := Copy(Str, 1, Pos('<', Str)-1);
              depart_time := Trim(Str);
              depart_date := DateTimeToStringRet('dd mmm yyyy',loc_date_depart);

              // Arrival Date/Time
              Str := DocElementA.innerHTML;
              if( Pos('ARR', UpperCase(Str))>0 ) then
                Delete(Str, 1, Pos('ARR', UpperCase(Str))-1+Length('ARR') );
              if( Pos('<', Str)>0 ) then
                Str := Copy(Str, 1, Pos('<', Str)-1);
              arrival_time := Trim(Str);
              arrival_date := DateTimeToStringRet('dd mmm yyyy',loc_date_depart);

              // Price
              Str := DocElementA.innerHTML;
              if( Pos('PRICE', UpperCase(Str))>0 ) then
                Delete(Str, 1, Pos('PRICE', UpperCase(Str))-1+Length('PRICE') );
              if( Pos('>', UpperCase(Str))>0 ) then
                Delete(Str, 1, Pos('>', UpperCase(Str)) );
              if( Pos('</span>', Str)>0 ) then
                Str := Copy(Str, 1, Pos('</span>', Str)-1);
                //�
                if pos('�', Str)>0 then
                begin
                  currency_code := 'EUR';
                  Str := StringReplace(Str,'�', '',[rfReplaceAll, rfIgnoreCase]);
                end
                else
                //Pound
                if pos(#63, Str)>0 then
                begin
                  currency_code := 'GBP';
                  Str := StringReplace(Str, #63, '',[rfReplaceAll, rfIgnoreCase]);
                end
                else
                // The plural form is pronounced darahim, although in French and English "dirhams" is commonly used.
                // Its ISO 4217 code is "MAD".
                if pos('Md', Str)>0 then
                begin
                  currency_code := 'MAD';
                  Str := StringReplace(Str, 'Md', '',[rfReplaceAll, rfIgnoreCase]);
                end
                else
                // Polish z?oty
                // Its ISO 4217 code is "PLN".
                if pos('zl', Str)>0 then
                begin
                  currency_code := 'PLN';
                  Str := StringReplace(Str, 'zl', '',[rfReplaceAll, rfIgnoreCase]);
                end
                else
                // Hungarian forint
                // Its ISO 4217 code is "HUF".
                if pos('Ft', Str)>0 then
                begin
                  currency_code := 'HUF';
                  Str := StringReplace(Str, 'Ft', '',[rfReplaceAll, rfIgnoreCase]);
                end
                else
                // Czech koruna
                // Its ISO 4217 code is "CZK".
                if pos('Kc', Str)>0 then
                begin
                  currency_code := 'CZK';
                  Str := StringReplace(Str, 'Kc', '',[rfReplaceAll, rfIgnoreCase]);
                end
                else
                // Danish krone
                // Its ISO 4217 code is "DKK".
                if pos('Dkr', Str)>0 then
                begin
                  currency_code := 'DKK';
                  Str := StringReplace(Str, 'Dkr', '',[rfReplaceAll, rfIgnoreCase]);
                end
                else
                // Swiss franc
                // Its ISO 4217 code is "DKK".
                if pos('CHF', Str)>0 then
                begin
                  currency_code := 'CHF';
                  Str := StringReplace(Str, 'CHF', '',[rfReplaceAll, rfIgnoreCase]);
                end
                else
                  currency_code := '';

                Str := StringReplace(Str,'</span>', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,' ', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,'&nbsp;', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,',', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,'<span>', DecimalSeparator, [rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,'.', DecimalSeparator, [rfReplaceAll, rfIgnoreCase]);
                if( Pos('<', Str)>0 ) then
                  Str := Trim(Copy(Str, 1, Pos('<', Str)-1));
                if not TryStrToFloat(Str, price_numeric) then
                  price_numeric := 0;

              if flight_nums.IndexOfName(flight_type+depart_time+'|'+arrival_time) >= 0 then
                flight_no := flight_nums.Values[flight_type+depart_time+'|'+arrival_time];

              paramOutData.add(
                    FloatToStr(loc_date_depart)+flight_type+depart_time+'|'+  // sort field
                    flight_type+'|'+
                    depart_date+'|'+
                    depart_time+'|'+
                    arrival_date+'|'+
                    arrival_time+'|'+
                    flight_no+'|'+
                    currency_code+' '+FloatToStr(price_numeric*(adults+children)+price_infant*infants)
                    );
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

