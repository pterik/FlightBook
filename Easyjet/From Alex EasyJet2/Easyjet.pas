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
function GetEasyjetInfantPrice(
            airport_depart: string;
            date_depart: TDateTime;
            airport_destination: string;
            date_return: TDateTime):double;
function DateTimeToStringRet(paramFormat: String; paramDate: TDateTime) : string;
function TryStrToInt(str : string; out Value: Integer) : Boolean;
function TryStrToFloat(str : string; out Value: Double) : Boolean;
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
  i,j,k,a_index,div_index,innerdiv_index : integer;
  strHTML        : String;
  DocSelect        : IHTMLElementCollection;
  DocElement       : IHtmlElement;
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
  str, default_flight_suffix,
  price : string;
  price_infant,price_numeric : double;
  DateConvertDay,DateConvertMonth,DateConvertYear : integer;
  depart_date_dt,arrival_date_dt : TDateTime;
  ParamWebBrowser: TWebBrowser;
  EasyjetStartURL: string;
  ini : tinifile;
  iniPath:string;
  IsSuccess : boolean;
  MinDateTime : TDateTime;
  MaxDateTime : TDateTime;

begin
  // separate by month
  if MonthOf(date_depart)<>MonthOf(date_return) then
  begin
    GetEasyjet( paramOutData,
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
  ShortMonthNames[10]:= 'Oct';
  ShortMonthNames[11]:= 'Nov';
  ShortMonthNames[12]:= 'Dec';
  MinDateTime := -657434.0;      { 01/01/0100 12:00:00.000 AM }
  MaxDateTime :=  2958465.99999; { 12/31/9999 11:59:59.999 PM }


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
    price_infant := ini.ReadInteger('main','EasyjetInfantPrice', 0);
    default_flight_suffix  := ini.ReadString('main','DefaultFlightSuffix', '');
    ini.free;
    if EasyjetStartURL='nil' then
    begin
      ShowMessage('Please chech the value of parameter EasyjetStartURL in Easyjet.ini');
      exit; //please change the code according to your rules
    end;
//
    ParamWebBrowser.Height := 1;
    ParamWebBrowser.Visible := false;


    //forward
    EncodedDataString :=
      'month='+DateTimeToStringRet('mm',date_depart)+'&'+
      'year='+DateTimeToStringRet('yyyy',date_depart)+'&'+
      'fromCode='+airport_depart+'&'+
      'toCode='+airport_destination+'&'+
      'increment=0'+
      '&_'+IntToStr(MonthOf(date_depart));

    Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

    // Naviagate to blank page
    paramWebBrowser.Navigate('about:blank');
    repeat
    Application.HandleMessage;
    Sleep(10);
    until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
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

      DocSelectDiv := (Doc.all.tags('TD')as IHTMLElementCollection);
      for div_index := 0 to DocSelectDiv.length - 1 do
      begin
        DocElementDiv := DocSelectDiv.Item(div_index,EmptyParam) as IHTMLElement;

        if pos('AVAILABLE', UpperCase(DocElementDiv.className)) > 0 then
        begin
          // Get Date
          arrival_date_dt := MinDateTime;
          DocSelect := ((DocElementDiv.all as IHTMLElementCollection).tags('A')as IHTMLElementCollection);
          for i := 0 to DocSelect.length - 1 do
          begin
            DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
            Str := DocElement.id;
            if pos('|', Str) > 0 then
            begin
              if TryStrToInt(Copy(Str,1,pos('|', Str)-1), DateConvertDay) then
              if Pos('|'+IntToStr(MonthOf(date_depart))+IntToStr(YearOf(date_depart)),Str) >0 then
              begin
                arrival_date_dt := EncodeDate(YearOf(date_depart),MonthOf(date_depart),DateConvertDay);
                arrival_date := DateTimeToStringRet('dd mmm yyyy',arrival_date_dt);
                depart_date  := DateTimeToStringRet('dd mmm yyyy',arrival_date_dt);
              end
            end;
          end;

          // check date
          flight_type := 'forward';
          if flexible then
            if (arrival_date_dt<date_depart) or (arrival_date_dt>date_return) then
              flight_type := '';
          if not flexible then
            if (arrival_date_dt<>date_depart) and (arrival_date_dt<>date_return) then
              flight_type := '';

          if flight_type <> '' then
          begin
            // Get type
            flight_type := 'forward';
            // Get Price
            price_numeric := 0;
            DocSelect := ((DocElementDiv.all as IHTMLElementCollection).tags('SPAN')as IHTMLElementCollection);
            for i := 0 to DocSelect.length - 1 do
            begin
              DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
              if pos('PRICESMALLER', UpperCase(DocElement.className)) > 0 then
              begin
                Str := DocElement.innerHTML;
                Str := StringReplace(Str,'�', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,'</span>', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,' ', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,'<span>', DecimalSeparator, [rfReplaceAll, rfIgnoreCase]);
                if not TryStrToFloat(Str, price_numeric) then
                  price_numeric := 0;
              end;
            end;
            if (infants > 0) and (price_infant = 0) then
              price_infant := GetEasyjetInfantPrice(
                      airport_depart,
                      date_depart,
                      airport_destination,
                      date_return);
            price := '�'+FloatToStr(price_numeric*(adults+children)+price_infant*infants);

            // Get Flight Num / Time
            price_numeric := 0;
            DocSelect := ((DocElementDiv.all as IHTMLElementCollection).tags('LI')as IHTMLElementCollection);
            for i := 0 to DocSelect.length - 1 do
            begin
              DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
              if pos('FLIGHT NUMBER', UpperCase(DocElement.innerHTML)) > 0 then
              begin
                Str := DocElement.innerHTML;
                if pos(':', UpperCase(Str))>0 then
                  Delete(Str,1,pos(':', UpperCase(Str)));
                Str := Trim(Str);
                if TryStrToInt(Str, j) then
                  Str := default_flight_suffix + Str;
                flight_no := Str;
              end;
              if pos('DEP', UpperCase(DocElement.innerHTML)) > 0 then
              begin
                Str := DocElement.innerHTML;
                Str := StringReplace(Str,' ', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,'Dep:', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,'Arr:', '',[rfReplaceAll, rfIgnoreCase]);
                if pos('-', UpperCase(Str))>0 then
                begin
                  depart_time := copy(Str,1,pos('-', Str)-1);
                  Delete(Str,1,pos('-', Str));
                end;
                arrival_time := str;
                paramOutData.add(
                      FloatToStr(arrival_date_dt)+flight_type+depart_time+'|'+  // sort field
                      flight_type+'|'+
                      depart_date+'|'+
                      depart_time+'|'+
                      arrival_date+'|'+
                      arrival_time+'|'+
                      flight_no+'|'+
                      price
                      );
              end;
            end;

          end; // arrival_date_dt <> SysUtils.MinDateTime
        end; // AVAILABLE = DocElementDiv.className
      end;
      Doc.close;
    end
     else
      paramOutData.Add('InternalError');

    //reverse
    if returnflight then
    begin
      EncodedDataString :=
        'month='+DateTimeToStringRet('mm',date_depart)+'&'+
        'year='+DateTimeToStringRet('yyyy',date_depart)+'&'+
        'fromCode='+airport_destination+'&'+
        'toCode='+airport_depart+'&'+
        'increment=0';

      Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

      // Naviagate to blank page
      paramWebBrowser.Navigate('about:blank');
      repeat
      Application.HandleMessage;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      // Naviagate to source page
      paramWebBrowser.Navigate(EasyjetStartURL+'?'+EncodedDataString, EmptyParam, EmptyParam, EmptyParam, Headers);
      // Wait while page is loading...
      repeat
      Application.HandleMessage;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
    end;

    if returnflight then
    if paramWebBrowser.Document <> nil then
    begin
      paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);

      DocSelectDiv := (Doc.all.tags('TD')as IHTMLElementCollection);
      for div_index := 0 to DocSelectDiv.length - 1 do
      begin
        DocElementDiv := DocSelectDiv.Item(div_index,EmptyParam) as IHTMLElement;

        if pos('AVAILABLE', UpperCase(DocElementDiv.className)) > 0 then
        begin
          // Get Date
          arrival_date_dt := MinDateTime;
          DocSelect := ((DocElementDiv.all as IHTMLElementCollection).tags('A')as IHTMLElementCollection);
          for i := 0 to DocSelect.length - 1 do
          begin
            DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
            Str := DocElement.id;
            if pos('|', Str) > 0 then
            begin
              if TryStrToInt(Copy(Str,1,pos('|', Str)-1), DateConvertDay) then
              if Pos('|'+IntToStr(MonthOf(date_depart))+IntToStr(YearOf(date_depart)),Str) >0 then
              begin
                arrival_date_dt := EncodeDate(YearOf(date_depart),MonthOf(date_depart),DateConvertDay);
                arrival_date := DateTimeToStringRet('dd mmm yyyy',arrival_date_dt);
                depart_date  := DateTimeToStringRet('dd mmm yyyy',arrival_date_dt);
              end
            end;
          end;

          // check date
          flight_type := 'reverse';
          if flexible then
            if (arrival_date_dt<date_depart) or (arrival_date_dt>date_return) then
              flight_type := '';
          if not flexible then
            if (arrival_date_dt<>date_depart) and (arrival_date_dt<>date_return) then
              flight_type := '';

          if flight_type <> '' then
          begin
            // Get type
            flight_type := 'reverse';
            // Get Price
            price_numeric := 0;
            DocSelect := ((DocElementDiv.all as IHTMLElementCollection).tags('SPAN')as IHTMLElementCollection);
            for i := 0 to DocSelect.length - 1 do
            begin
              DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
              if pos('PRICESMALLER', UpperCase(DocElement.className)) > 0 then
              begin
                Str := DocElement.innerHTML;
                Str := StringReplace(Str,'�', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,'?', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,'</span>', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,' ', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,'<span>', DecimalSeparator, [rfReplaceAll, rfIgnoreCase]);
                if not TryStrToFloat(Str, price_numeric) then
                  price_numeric := 0;
              end;
            end;
            if (infants > 0) and (price_infant = 0) then
              price_infant := GetEasyjetInfantPrice(
                      airport_depart,
                      date_depart,
                      airport_destination,
                      date_return);
            price := '�'+FloatToStr(price_numeric*(adults+children)+price_infant*infants);

            // Get Flight Num / Time
            price_numeric := 0;
            DocSelect := ((DocElementDiv.all as IHTMLElementCollection).tags('LI')as IHTMLElementCollection);
            for i := 0 to DocSelect.length - 1 do
            begin
              DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
              if pos('FLIGHT NUMBER', UpperCase(DocElement.innerHTML)) > 0 then
              begin
                Str := DocElement.innerHTML;
                if pos(':', UpperCase(Str))>0 then
                  Delete(Str,1,pos(':', UpperCase(Str)));
                Str := Trim(Str);
                if TryStrToInt(Str, j) then
                  Str := default_flight_suffix + Str;
                flight_no := Str;
              end;
              if pos('DEP', UpperCase(DocElement.innerHTML)) > 0 then
              begin
                Str := DocElement.innerHTML;
                Str := StringReplace(Str,' ', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,'Dep:', '',[rfReplaceAll, rfIgnoreCase]);
                Str := StringReplace(Str,'Arr:', '',[rfReplaceAll, rfIgnoreCase]);
                if pos('-', UpperCase(Str))>0 then
                begin
                  depart_time := copy(Str,1,pos('-', Str)-1);
                  Delete(Str,1,pos('-', Str));
                end;
                arrival_time := str;
                paramOutData.add(
                      FloatToStr(arrival_date_dt)+flight_type+depart_time+'|'+  // sort field
                      flight_type+'|'+
                      depart_date+'|'+
                      depart_time+'|'+
                      arrival_date+'|'+
                      arrival_time+'|'+
                      flight_no+'|'+
                      price
                      );
              end;
            end;

          end; // arrival_date_dt <> SysUtils.MinDateTime
        end; // AVAILABLE = DocElementDiv.className
      end;
      Doc.close;
    end
     else
      paramOutData.Add('InternalError');

  finally
    ParamWebBrowser.Free;
  end;
end;

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
  Str : string;
  price_sum,price_numeric : double;
  ParamWebBrowser: TWebBrowser;
  EasyjetStartURL: string;
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
    EasyjetStartURL  := ini.ReadString('main','EasyjetInfantPriceURL', 'nil');
    ini.free;
    if EasyjetStartURL='nil' then
    begin
      ShowMessage('Please chech the value of parameter EasyjetStartURL in Easyjet.ini');
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
                  price_sum := 0;
                  DocSelect := ((DocElementFlightInfo.all as IHTMLElementCollection).tags('LI')as IHTMLElementCollection);
                  for i := 0 to DocSelect.length - 1 do
                  begin
                    DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
                    if (pos('AMOUNT', UpperCase(DocElement.className)) > 0) then
                    begin
                      Str := DocElement.innerHTML;
                      Str := StringReplace(Str, ',', '', [rfReplaceAll, rfIgnoreCase]);
                      Str := StringReplace(Str, '�', '', [rfReplaceAll, rfIgnoreCase]);
                      Str := StringReplace(Str, '.', DecimalSeparator, [rfReplaceAll, rfIgnoreCase]);
                      if pos('X', UpperCase(Str))>0 then
                        Delete(Str,1,pos('X', UpperCase(Str)));
                      Str := Trim(Str);

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
