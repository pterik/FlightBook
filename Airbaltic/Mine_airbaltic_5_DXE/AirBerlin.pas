unit AirBerlin;

interface
uses
  SysUtils, Classes, Httpapp, MSHTML, ActiveX, OleCtrls, SHDocVw,
  INIFiles, windows,unit1;

const   AirBerlinStartURL : string = 'http://www.airberlin.com/booking/flight/vacancy.php';
  DaysPerQuery = 5; //
  CheckBugWithPreviousPage = true; //

procedure GetAirBerlin(paramOutData:TStringList;
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

implementation

uses Forms, Controls, Dialogs; 

function TryStrToFloat(str : string; out Value: double) : Boolean;
begin
  str := StringReplace(str, ',', DecimalSeparator,[]);
  str := StringReplace(str, '.', DecimalSeparator,[]);
  try
    Value := StrToFloat(str);
    result := true;
  except
    result := false;
  end;
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

function CustomSortByValue(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := CompareText(List.Values[List.Names[Index1]], List.Values[List.Names[Index2]]);
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

//webBrowser was removed from parameters, it creates internaly
// startUrl was removed from parameters, it creates internaly
procedure GetAirBerlin(paramOutData:TStringList;
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

  table_index,i,j,k : integer;
  strHTML,strRow, str : String;
  htmlRow : IHTMLTableRow;
  DocSelect   : IHTMLElementCollection;
  DocSelectTable : IHTMLElementCollection;
  DocElement  : IHtmlElement;
  DocElementAnchor  : IHTMLAnchorElement;
  DocElementInput   : IHTMLInputElement;
  DocElementTable   : IHTMLTable;
  ItemElement : IHtmlElement;
  Doc         : IHTMLDocument2;
  flight_type,
  flight_no,
  depart_date,
  depart_time,
  arrival_date,
  arrival_time,
  total_price,
  via : string;
  depart_date_dt, arrival_date_dt : TDateTime;
  priceAdult,priceChild,priceInfant,priceTaxes, priceAdditional,vacantSeats : double;
  IsSuccess : boolean;
  NextFlightsButtonLink : string;
  DateConvertDay,DateConvertMonth,DateConvertYear : integer;
  IsFirstTable : boolean;
  ParamWebBrowser: TWebBrowser;
  C_EmptyParam:OleVariant;
begin
//Separate dates
  if (date_return - date_depart) > DaysPerQuery then
  begin
    if flexible then
    begin
      GetAirBerlin(
          paramOutData,
          returnflight,
          flexible,
          airport_depart,
          date_depart,
          airport_destination,
          date_depart+DaysPerQuery,
          adults,
          children,
          infants);
      GetAirBerlin(
          paramOutData,
          returnflight,
          flexible,
          airport_depart,
          date_depart+DaysPerQuery+1,
          airport_destination,
          date_return,
          adults,
          children,
          infants);
    end
    else
    begin
      GetAirBerlin(
          paramOutData,
          returnflight,
          flexible,
          airport_depart,
          date_depart,
          airport_destination,
          date_depart,
          adults,
          children,
          infants);
      GetAirBerlin(
          paramOutData,
          returnflight,
          flexible,
          airport_depart,
          date_return,
          airport_destination,
          date_return,
          adults,
          children,
          infants);
    end;
  end;

if not Assigned(paramOutData) then paramOutData:=TStringList.Create;
try
// Don`t forget to insert   uses Forms;  above
if not Assigned(ParamWebBrowser) then ParamWebBrowser := TWebBrowser.Create(Application.mainForm);
TWinControl(ParamWebBrowser).Name:= 'ParamWebBrowser';
TWinControl(ParamWebBrowser).Parent:= Application.MainForm;
ParamWebBrowser.Visible := true;
ParamWebBrowser.Height := 400;
ParamWebBrowser.Align := alTop;
ParamWebBrowser.Silent := true;
ParamWebBrowser.Update;
Application.ProcessMessages;
ParamWebBrowser.Height := 1;
ParamWebBrowser.Visible := false;
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
  depart_date_dt := 0;
    // Open start page
    Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

    EncodedDataString :=
       'LANG=net'+
       '&HINDATUM='+DateTimeToStringRet('yyyy-mm-dd',date_depart)+
       if_str(returnflight,'&RUECKDATUM='+DateTimeToStringRet('yyyy-mm-dd',date_return),'')+
       '&VON='+airport_depart+
       '&NACH='+airport_destination+
       '&startConnection='+airport_depart+'@'+
                           airport_destination+'@'+
                           DateTimeToStringRet('yyyy-mm-dd',date_depart)+'@'+
                           DateTimeToStringRet('yyyy-mm-dd',date_return)+
       '&MARKT=NL';

    paramWebBrowser.Navigate('about:blank');
    // Wait while page is loading...
    repeat
      // Don`t forget to insert   uses Forms;  above
      Application.HandleMessage;
      Sleep(10);
    until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      C_EmptyParam:=EmptyParam; //for Delphi 2010 compability
      paramWebBrowser.Navigate('AirBerlinStartURL'+'?'+'EncodedDataString',EmptyParam, EmptyParam, C_EmptyParam, Headers);
    // Wait while page is loading...
    repeat
      Application.HandleMessage;
      Sleep(10);
    until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;

    if CheckBugWithPreviousPage then
    begin
      // Goto next-previous pages (site bug :'(... )
      NextFlightsButtonLink :=  AirBerlinStartURL+'?'+
         'LANG=net'+
         '&HINDATUM='+DateTimeToStringRet('yyyy-mm-dd',date_depart-0)+
         if_str(returnflight,'&RUECKDATUM='+DateTimeToStringRet('yyyy-mm-dd',date_return+30),'')+
         '&VON='+airport_depart+
         '&NACH='+airport_destination+
         '&EUR&scrollOption=';
      // # Forward
      // 1.Forward: naviagate to next page
      C_EmptyParam:=EmptyParam; //for Delphi 2010 compability
      paramWebBrowser.Navigate(
          NextFlightsButtonLink+'SCROLL_OUTBOUND_FORWARD',
          EmptyParam, EmptyParam, C_EmptyParam, Headers);
      // Wait while page is loading...
      repeat
        Application.HandleMessage;
        Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      // 2.Forward: naviagate to previous page
      C_EmptyParam:=EmptyParam; //for Delphi 2010 compability
      paramWebBrowser.Navigate(
          NextFlightsButtonLink+'SCROLL_OUTBOUND_BACKWARD',
          EmptyParam, EmptyParam, C_EmptyParam, Headers);
      // Wait while page is loading...
      repeat
        Application.HandleMessage;
        Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      // 3.Forward: naviagate to previous page
      C_EmptyParam:=EmptyParam; //for Delphi 2010 compability
      paramWebBrowser.Navigate(
          NextFlightsButtonLink+'SCROLL_OUTBOUND_BACKWARD',
          EmptyParam, EmptyParam, C_EmptyParam, Headers);
      // Wait while page is loading...
      repeat
        Application.HandleMessage;
        Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      // # Return
      // 4.Return: naviagate to next page
      C_EmptyParam:=EmptyParam; //for Delphi 2010 compability
      paramWebBrowser.Navigate(
          NextFlightsButtonLink+'SCROLL_RETURN_BACKWARD',
          EmptyParam, EmptyParam, C_EmptyParam, Headers);
      // Wait while page is loading...
      repeat
        Application.HandleMessage;
        Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      // 5.Return: naviagate to previous page
      C_EmptyParam:=EmptyParam; //for Delphi 2010 compability
      paramWebBrowser.Navigate(
          NextFlightsButtonLink+'SCROLL_RETURN_FORWARD',
          EmptyParam, EmptyParam, C_EmptyParam, Headers);
      // Wait while page is loading...
      repeat
        Application.HandleMessage;
        Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      // 6.Return: naviagate to previous page
      C_EmptyParam:=EmptyParam; //for Delphi 2010 compability
      paramWebBrowser.Navigate(
          NextFlightsButtonLink+'SCROLL_RETURN_FORWARD',
          EmptyParam, EmptyParam, C_EmptyParam, Headers);
      // Wait while page is loading...
      repeat
        Application.HandleMessage;
        Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
    end;

    // forwards
    repeat
      NextFlightsButtonLink := '';
      if paramWebBrowser.Document <> nil then
      begin
        paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);

        // Get "Next flights" button
//        DocSelect := (Doc.all.tags('A')) as IHTMLElementCollection;
//        for i := 0 to DocSelect.length-1 do
//        begin
//          try
//            DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
//            DocElementAnchor := DocElement as IHTMLAnchorElement;
//            if pos('submitNewDate',DocElement.className) >0  then
//            if pos('SCROLL_OUTBOUND_FORWARD',DocElementAnchor.href) >0 then
//            begin
//              NextFlightsButtonLink := DocElementAnchor.href;
//            end;
//          except
//          end;
//        end;
        NextFlightsButtonLink :=  AirBerlinStartURL+'?'+
         'LANG=net'+
         '&HINDATUM='+DateTimeToStringRet('yyyy-mm-dd',date_depart-0)+
         if_str(returnflight,'&RUECKDATUM='+DateTimeToStringRet('yyyy-mm-dd',date_return+30),'')+
         '&VON='+airport_depart+
         '&NACH='+airport_destination+
         '&EUR&scrollOption=SCROLL_OUTBOUND_FORWARD';

        // Parse Data
        IsFirstTable := false;
        DocSelectTable := (Doc.all.tags('TABLE')as IHTMLElementCollection);
        for table_index := 0 to DocSelectTable.length-1 do
        begin
          DocSelect := (DocSelectTable.Item(table_index,EmptyParam) as IHTMLTable).rows;

          if IsFirstTable then
            break;

          for i := 0 to DocSelect.length-1 do
          begin
            try
              htmlRow := DocSelect.Item(i,EmptyParam) as IHTMLTableRow;

              if htmlRow.cells.length = 12 then
              begin
                IsFirstTable := true;
                // flight num

                strHTML := (htmlRow.cells.item(1, 1) as HTMLTableCell).innerHTML;
                flight_no := strHTML;

                // Via
                strHTML := (htmlRow.cells.item(4, 4) as HTMLTableCell).innerHTML;
                Delete(strHTML, 1, pos('>',strHTML));
                via := Trim(Copy(strHTML, 1, pos('<',strHTML)-1));

                // depart date/time
                strHTML := (htmlRow.cells.item(3, 3) as HTMLTableCell).innerHTML;
                Delete(strHTML, 1, pos('>',strHTML));
                depart_date := Copy(strHTML, 1, pos(' ',strHTML)-1);
                Delete(strHTML, 1, pos(' ',strHTML));
                depart_time := Copy(strHTML, 1, pos('<',strHTML)-1);

                depart_date_dt := 0;
                if Length(depart_date) >= 10 then
                  if TryStrToInt(Copy(depart_date,1,4), DateConvertYear) then
                    if TryStrToInt(Copy(depart_date,6,2), DateConvertMonth) then
                      if TryStrToInt(Copy(depart_date,9,2), DateConvertDay) then
                      begin
                        depart_date_dt := EncodeDate(DateConvertYear,DateConvertMonth,DateConvertDay);
                        depart_date := DateTimeToStringRet('dd mmm yyyy',depart_date_dt);
                      end;

                // arrival date/time
                strHTML := (htmlRow.cells.item(5, 5) as HTMLTableCell).innerHTML;
                Delete(strHTML, 1, pos('>',strHTML));
                arrival_date := Copy(strHTML, 1, pos(' ',strHTML)-1);
                Delete(strHTML, 1, pos(' ',strHTML));
                arrival_time := Copy(strHTML, 1, pos('<',strHTML)-1);

                arrival_date_dt := 0;
                if Length(arrival_date) >= 10 then
                  if TryStrToInt(Copy(arrival_date,1,4), DateConvertYear) then
                    if TryStrToInt(Copy(arrival_date,6,2), DateConvertMonth) then
                      if TryStrToInt(Copy(arrival_date,9,2), DateConvertDay) then
                      begin
                        arrival_date_dt := EncodeDate(DateConvertYear,DateConvertMonth,DateConvertDay);
                        arrival_date := DateTimeToStringRet('dd mmm yyyy',arrival_date_dt);
                      end;

                // Price
                strHTML := (htmlRow.cells.item(8, 8) as HTMLTableCell).innerHTML;
                strHTML := StringReplace(strHTML,'&nbsp;',' ',[rfReplaceAll, rfIgnoreCase]);
                strHTML := StringReplace(strHTML,'&gt;',' ',[rfReplaceAll, rfIgnoreCase]);
                // priceAdult
                str := strHTML;
                Delete(strHTML, 1, pos('priceNet',strHTML)+Length('priceNet'));
                Delete(strHTML, 1, pos('>',strHTML));
                str := Copy(strHTML, 1, pos('<',strHTML)-1);
                if Trim(str)<>'' then
                  if not TryStrToFloat(str, priceAdult) then
                    priceAdult := 0;
                // priceChild
                str := strHTML;
                Delete(strHTML, 1, pos('priceChd',strHTML)+Length('priceChd'));
                Delete(strHTML, 1, pos('>',strHTML));
                str := Copy(strHTML, 1, pos('<',strHTML)-1);
                if Trim(str)<>'' then
                  if not TryStrToFloat(str, priceChild) then
                    priceChild := 0;
                // priceInfant
                str := strHTML;
                Delete(strHTML, 1, pos('priceInf',strHTML)+Length('priceInf'));
                Delete(strHTML, 1, pos('>',strHTML));
                str := Copy(strHTML, 1, pos('<',strHTML)-1);
                if Trim(str)<>'' then
                  if not TryStrToFloat(str, priceInfant) then
                    priceInfant := 0;
                // priceTaxes
                str := strHTML;
                Delete(strHTML, 1, pos('priceTaxes',strHTML)+Length('priceTaxes'));
                Delete(strHTML, 1, pos('>',strHTML));
                str := Copy(strHTML, 1, pos('<',strHTML)-1);
                if Trim(str)<>'' then
                  if not TryStrToFloat(str, priceTaxes) then
                    priceTaxes := 0;
                // priceAdditional
                str := strHTML;
                Delete(strHTML, 1, pos('priceAdditional',strHTML)+Length('priceAdditional'));
                Delete(strHTML, 1, pos('>',strHTML));
                str := Copy(strHTML, 1, pos('<',strHTML)-1);
                if Trim(str)<>'' then
                  if not TryStrToFloat(str, priceAdditional) then
                    priceAdditional := 0;
                // vacantSeats
                str := strHTML;
                Delete(strHTML, 1, pos('priceInf',strHTML)+Length('vacantSeats'));
                Delete(strHTML, 1, pos('>',strHTML));
                str := Copy(strHTML, 1, pos('<',strHTML)-1);
                if Trim(str)<>'' then
                  if not TryStrToFloat(str, vacantSeats) then
                    vacantSeats := 0;

                // calculate prices
                priceAdult := priceAdult + priceAdditional + priceTaxes+10;
                priceChild := priceChild + priceAdditional + priceTaxes+10;
                priceInfant := priceInfant;
                total_price := FormatFloat('# ##0.00',
                        priceAdult*adults+
                        priceChild*children+
                        priceInfant*infants)+' EUR';;

                IsSuccess := vacantSeats >= adults+children;
                if (flexible and IsSuccess) then
                  IsSuccess := (depart_date_dt>=date_depart) and (depart_date_dt<=date_return);
                if ((not flexible) and IsSuccess) then
                  IsSuccess := (depart_date_dt=date_depart)or(depart_date_dt=date_return);
                if (depart_date_dt > date_return) then
                  NextFlightsButtonLink := ''; // break

                if IsSuccess then
                  paramOutData.add(
                        'forward|'+
                        depart_date+'|'+
                        depart_time+'|'+
                        arrival_date+'|'+
                        arrival_time+'|'+
                        flight_no+'|'+
                        total_price+'|'+
                        via
                        );

              end;
            except
            end;
          end;
        end;  
        Doc.close;

        // Open Next Page
        if NextFlightsButtonLink <> '' then
        begin
          // Naviagate to source page
          C_EmptyParam:=EmptyParam; //for Delphi 2010 compability
          paramWebBrowser.Navigate(
              NextFlightsButtonLink,EmptyParam, EmptyParam, C_EmptyParam, Headers);
          // Wait while page is loading...
          repeat
          Application.HandleMessage;
          Sleep(10);
          until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
        end;
      end;
    until NextFlightsButtonLink = '';

    // reverce
    repeat
      NextFlightsButtonLink := '';
      if paramWebBrowser.Document <> nil then
      begin
        paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);

        // Get "Next flights" button
//        DocSelect := (Doc.all.tags('A')) as IHTMLElementCollection;
//        for i := 0 to DocSelect.length-1 do
//        begin
//          try
//            DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
//            DocElementAnchor := DocElement as IHTMLAnchorElement;
//            if pos('submitNewDate',DocElement.className) >0  then
//            if pos('SCROLL_RETURN_BACKWARD',DocElementAnchor.href) >0 then
//            begin
//              NextFlightsButtonLink := DocElementAnchor.href;
//            end;
//          except
//          end;
//        end;
        EncodedDataString := AirBerlinStartURL+'?'+
         'LANG=net'+
         '&HINDATUM='+DateTimeToStringRet('yyyy-mm-dd',date_depart-0)+
         if_str(returnflight,'&RUECKDATUM='+DateTimeToStringRet('yyyy-mm-dd',date_return+30),'')+
         '&VON='+airport_depart+
         '&NACH='+airport_destination+
         '&EUR&scrollOption=SCROLL_RETURN_BACKWARD';

        // Parse Data
        IsFirstTable := true;
        DocSelectTable := (Doc.all.tags('TABLE')as IHTMLElementCollection);
        for table_index := 0 to DocSelectTable.length-1 do
        begin
          DocSelect := (DocSelectTable.Item(table_index,EmptyParam) as IHTMLTable).rows;

          for i := DocSelect.length-1 downto 0 do
          //if flexible and (i<DocSelect.length div 2) then
          begin
            try
              htmlRow := DocSelect.Item(i,EmptyParam) as IHTMLTableRow;

              if htmlRow.cells.length = 12 then
              begin
                if IsFirstTable then
                begin
                  IsFirstTable := false;
                  break;
                end;  
                // flight num

                strHTML := (htmlRow.cells.item(1, 1) as HTMLTableCell).innerHTML;
                flight_no := strHTML;

                // depart date/time
                strHTML := (htmlRow.cells.item(3, 3) as HTMLTableCell).innerHTML;
                Delete(strHTML, 1, pos('>',strHTML));
                depart_date := Copy(strHTML, 1, pos(' ',strHTML)-1);
                Delete(strHTML, 1, pos(' ',strHTML));
                depart_time := Copy(strHTML, 1, pos('<',strHTML)-1);

                depart_date_dt := 0;
                if Length(depart_date) >= 10 then
                  if TryStrToInt(Copy(depart_date,1,4), DateConvertYear) then
                    if TryStrToInt(Copy(depart_date,6,2), DateConvertMonth) then
                      if TryStrToInt(Copy(depart_date,9,2), DateConvertDay) then
                      begin
                        depart_date_dt := EncodeDate(DateConvertYear,DateConvertMonth,DateConvertDay);
                        depart_date := DateTimeToStringRet('dd mmm yyyy',depart_date_dt);
                      end;

                // arrival date/time
                strHTML := (htmlRow.cells.item(5, 5) as HTMLTableCell).innerHTML;
                Delete(strHTML, 1, pos('>',strHTML));
                arrival_date := Copy(strHTML, 1, pos(' ',strHTML)-1);
                Delete(strHTML, 1, pos(' ',strHTML));
                arrival_time := Copy(strHTML, 1, pos('<',strHTML)-1);

                arrival_date_dt := 0;
                if Length(arrival_date) >= 10 then
                  if TryStrToInt(Copy(arrival_date,1,4), DateConvertYear) then
                    if TryStrToInt(Copy(arrival_date,6,2), DateConvertMonth) then
                      if TryStrToInt(Copy(arrival_date,9,2), DateConvertDay) then
                      begin
                        arrival_date_dt := EncodeDate(DateConvertYear,DateConvertMonth,DateConvertDay);
                        arrival_date := DateTimeToStringRet('dd mmm yyyy',arrival_date_dt);
                      end;

                // Price
                strHTML := (htmlRow.cells.item(8, 8) as HTMLTableCell).innerHTML;
                strHTML := StringReplace(strHTML,'&nbsp;',' ',[rfReplaceAll, rfIgnoreCase]);
                strHTML := StringReplace(strHTML,'&gt;',' ',[rfReplaceAll, rfIgnoreCase]);
                // priceAdult
                str := strHTML;
                Delete(strHTML, 1, pos('priceNet',strHTML)+Length('priceNet'));
                Delete(strHTML, 1, pos('>',strHTML));
                str := Copy(strHTML, 1, pos('<',strHTML)-1);
                if not TryStrToFloat(str, priceAdult) then
                  priceAdult := 0;
                // priceChild
                str := strHTML;
                Delete(strHTML, 1, pos('priceChd',strHTML)+Length('priceChd'));
                Delete(strHTML, 1, pos('>',strHTML));
                str := Copy(strHTML, 1, pos('<',strHTML)-1);
                if not TryStrToFloat(str, priceChild) then
                  priceChild := 0;
                // priceInfant
                str := strHTML;
                Delete(strHTML, 1, pos('priceInf',strHTML)+Length('priceInf'));
                Delete(strHTML, 1, pos('>',strHTML));
                str := Copy(strHTML, 1, pos('<',strHTML)-1);
                if not TryStrToFloat(str, priceInfant) then
                  priceInfant := 0;
                // priceTaxes
                str := strHTML;
                Delete(strHTML, 1, pos('priceTaxes',strHTML)+Length('priceTaxes'));
                Delete(strHTML, 1, pos('>',strHTML));
                str := Copy(strHTML, 1, pos('<',strHTML)-1);
                if not TryStrToFloat(str, priceTaxes) then
                  priceTaxes := 0;
                // priceAdditional
                str := strHTML;
                Delete(strHTML, 1, pos('priceAdditional',strHTML)+Length('priceAdditional'));
                Delete(strHTML, 1, pos('>',strHTML));
                str := Copy(strHTML, 1, pos('<',strHTML)-1);
                if not TryStrToFloat(str, priceAdditional) then
                  priceAdditional := 0;
                // vacantSeats
                str := strHTML;
                Delete(strHTML, 1, pos('priceInf',strHTML)+Length('vacantSeats'));
                Delete(strHTML, 1, pos('>',strHTML));
                str := Copy(strHTML, 1, pos('<',strHTML)-1);
                if not TryStrToFloat(str, vacantSeats) then
                  vacantSeats := 0;

                // calculate prices
                priceAdult := priceAdult + priceAdditional + priceTaxes;
                priceChild := priceChild + priceAdditional + priceTaxes;
                priceInfant := priceInfant;
                total_price := FormatFloat('# ##0.00',
                        priceAdult*adults+
                        priceChild*children+
                        priceInfant*infants)+' EUR';

                IsSuccess := vacantSeats >= adults+children;
                if (flexible and IsSuccess) then
                  IsSuccess := (depart_date_dt>=date_depart) and (depart_date_dt<=date_return);
                if ((not flexible) and IsSuccess) then
                  IsSuccess := (depart_date_dt=date_depart)or(arrival_date_dt=date_return);
                if (depart_date_dt < date_depart) then
                  NextFlightsButtonLink := ''; // break

                if IsSuccess then
                  paramOutData.add(
                        'reverse|'+
                        depart_date+'|'+
                        depart_time+'|'+
                        arrival_date+'|'+
                        arrival_time+'|'+
                        flight_no+'|'+
                        total_price+'|'+
                        via
                        );

              end;
            except
            end;
          end;
        end;
        Doc.close;

        // Open Next Page
        if NextFlightsButtonLink <> '' then
        begin
          C_EmptyParam:=EmptyParam; //for Delphi 2010 compability
          paramWebBrowser.Navigate(
              NextFlightsButtonLink,EmptyParam, EmptyParam, C_EmptyParam, Headers);
        // Wait while page is loading...
            repeat
            Application.HandleMessage;
            Sleep(10);
            until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
        end;
      end;
    until NextFlightsButtonLink = '';

  finally
    if Assigned(ParamWebBrowser) then
      ParamWebBrowser.Free;
    // Sort result data
    paramOutData.Sort;
  end;
end;

end.
