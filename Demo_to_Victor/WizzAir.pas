unit WizzAir;

interface

uses
  Windows, SysUtils, Classes, HTTPApp, MSHTML, ActiveX, OleCtrls, SHDocVw,
  {$IFNDEF VER130}Variants,{$ENDIF} IniFiles, Unit1;

//webBrowser was removed from parameters, it creates internaly
// paramStartURL,paramGetTotalSumURL were removed from parameters, it creates internaly
procedure GetVueling(
            paramOutData: TStringList;
            returnflight: Boolean;
            flexible: Boolean;
            airport_depart: string;
            date_depart: TDateTime;
            airport_destination: string;
            date_return: TDateTime;
            adults: Integer;
            children: Integer;
            infants: Integer);
procedure ChangePrice(const wb: TWebBrowser; const Currency: string; var Price: string);
function DateTimeToStringRet(paramFormat: string; paramDate: TDateTime) : string;
function TryStrToFloat(S: string; var Value: Extended): Boolean;

implementation

uses Forms, Controls, Dialogs;

procedure GetVueling(
            paramOutData: TStringList;
            returnflight : Boolean;
            flexible: Boolean;
            airport_depart: string;
            date_depart: TDateTime;
            airport_destination: string;
            date_return: TDateTime;
            adults: Integer;
            children: Integer;
            infants: Integer);
var
  EncodedDataString: string;
  PostData: OleVariant;
  Headers: OleVariant;
  loc_date_depart: TDateTime;
  loc_date_return: TDateTime;

  i,div_index, innerdiv_index: Integer;
  strHTML        : string;
  DocSelectDiv   : IHTMLElementCollection;
  DocElementDiv  : IHTMLElement;
  DocSelectTR    : IHTMLElementCollection;
  DocElementTR   : IHTMLElement;
  DocElementTRTyped   : IHTMLTableRow;
  Doc            : IHTMLDocument2;
  flight_type,
  flight_no,
  depart_date,
  depart_time,
  arrival_date,
  arrival_time,
  total_price : string;
  ParamWebBrowser: TWebBrowser;
  WizzAirStartURL: string;
  ini : TIniFile;
  iniPath: string;
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
  ShortMonthNames[10] := 'Oct';
  ShortMonthNames[11] := 'Nov';
  ShortMonthNames[12] := 'Dec';

  try
    ParamWebBrowser := TWebBrowser.Create(Application.MainForm);
    // Don`t forget to insert   uses Forms;  above
    TWinControl(ParamWebBrowser).Name := 'ParamWebBrowser'+ IntToStr(Application.MainForm.ComponentCount);
    TWinControl(ParamWebBrowser).Parent := Application.MainForm;
    ParamWebBrowser.Height := 200;
    ParamWebBrowser.Visible := True;
    ParamWebBrowser.Align := alTop;
    ParamWebBrowser.Silent := True;
    ParamWebBrowser.Update;
    Application.HandleMessage;
    IniPath := ExtractFileDir(Application.ExeName)+'\data\WizzAir.ini';
    // change the verification accordint to your rules
    if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'+#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
    //May change 4 lines according to your rules
    ini := TIniFile.Create(IniPath);
    WizzAirStartURL := ini.ReadString('main', 'WizzAirStartURL', 'nil');
    ini.Free;
    if WizzAirStartURL = 'nil' then
      begin
        ShowMessage('Please chech the value of parameter WizzAirStartURL in WizzAir.ini');
        Exit; //please change the code according to your rules
      end;

    ParamWebBrowser.Height := 1;
    ParamWebBrowser.Visible := False;

    loc_date_depart := date_depart;
    while loc_date_depart <= date_return do
      begin
        loc_date_return := loc_date_depart;

        //forward
        EncodedDataString :=
            'event=search&' +
            'module=SB&' +
            'page=SEARCH&' +
            'language=NL&' +
            'mode=&' +
            'sid=&' +
            'ref=&' +
            'selectedUtil=login&' +
            'email=&' +
            'pw=&' +
            'log_in=0&' +
            'confNum=&' +
            'departFrom=&' +
            'flight_key=&' +
            'flight_number=&' +
            'depart_date=&' +
            'depart_city=&' +
            'arrive_city=&' +
            'orig=XXX&' +
            'dest=XXX&' +
            'date=' + DateTimeToStringRet('yyyymmdd', Now) + '&' +
            'flightnum=&' +
            'travel=2&' +
            'from1=' + airport_depart + '&' +
            'to1=' + airport_destination + '&' +
            'departDay1=' + DateTimeToStringRet('dd', loc_date_depart) + '&' +
            'departMonth1=' + DateTimeToStringRet('yyyymm', loc_date_depart) + '&' +
            'depart1FlexBy=0000&' +
            'departDay2=' + DateTimeToStringRet('dd', loc_date_return) + '&' +
            'departMonth2=' + DateTimeToStringRet('yyyymm', loc_date_return) + '&' +
            'depart2FlexBy=0000&' +
            'ADULT=' + IntToStr(adults) + '&' +
            'defaultADULT=-1&' +
            'CHILD=' + IntToStr(children) + '&' +
            'defaultCHILD=-1&' +
            'INFANT=' + IntToStr(infants) + '&' +
            'defaultINFANT=-1&' +
            'toCity1=' + airport_destination + '&' +
            'toCity2=' + airport_depart + '&' + // ???
            'departDate1=&' +
            'departDate2=&' +
            'numberMarkets=2';

        // The PostData OleVariant needs to be an array of bytes
        // as large as the string (minus the 0 terminator)
        PostData := VarArrayCreate([0, Length(EncodedDataString)-1], varByte);

        // Now, move the Ordinal value of the character into the PostData array
        for i := 1 to Length(EncodedDataString) do
          PostData[i-1] := Ord(EncodedDataString[i]);

        Headers := 'Content-Type: application/x-www-form-urlencoded' + #10#13;

        // Naviagate to blank page
        paramWebBrowser.Navigate('about:blank');
        repeat
          Application.HandleMessage;
          Sleep(10);
        until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
        // Naviagate to source page
        paramWebBrowser.Navigate(WizzAirStartURL, EmptyParam, EmptyParam, PostData, Headers);
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
                DocElementDiv := DocSelectDiv.item(div_index, EmptyParam) as IHTMLElement;

                flight_type := '';

                //(DocElementDiv as IHTMLElement).
                if (Pos('SBFLIGHTDETAILSDIV1', UpperCase(DocElementDiv.id)) > 0) then
                  begin
                    flight_type := 'forward';
                    depart_date := DateTimeToStringRet('dd mmm yyyy', loc_date_return);
                    arrival_date := DateTimeToStringRet('dd mmm yyyy', loc_date_return);
                  end;
                if (Pos('SBFLIGHTDETAILSDIV2', UpperCase(DocElementDiv.id)) > 0) and returnflight then
                  begin
                    flight_type := 'reverse';
                    depart_date := DateTimeToStringRet('dd mmm yyyy', loc_date_depart);
                    arrival_date := DateTimeToStringRet('dd mmm yyyy', loc_date_depart);
                  end;

                if flight_type <> '' then
                  begin
                    DocSelectTR := ((DocElementDiv.all as IHTMLElementCollection).tags('TR') as IHTMLElementCollection);
                    for innerdiv_index := 0 to DocSelectTR.length - 1 do
                    begin
                      DocElementTR := DocSelectTR.Item(innerdiv_index, EmptyParam) as IHTMLElement;
                      DocElementTRTyped := DocElementTR as IHTMLTableRow;
                      if Pos('BESTDATE ', UpperCase(DocElementTR.className)) > 0 then
                        begin
                          flight_no := (DocElementTRTyped.cells.item(1, 0) as HTMLTableCell).innerHTML;
                          depart_time := (DocElementTRTyped.cells.item(2, 0) as HTMLTableCell).innerHTML;
                          arrival_time := (DocElementTRTyped.cells.item(3, 0) as HTMLTableCell).innerHTML;

                          strHTML := (DocElementTRTyped.cells.item(4, 0) as HTMLTableCell).innerHTML;
                          if Pos('_summary', strHTML) > 0 then
                            begin
                              Delete(strHTML, 1, Pos('_summary', strHTML));
                              Delete(strHTML, 1, Pos('>', strHTML));
                              Delete(strHTML, Pos('<', strHTML), Length(strHTML));

                              total_price := (DocElementTRTyped.cells.item(5, 0) as HTMLTableCell).innerHTML;
                                Delete(total_price, 1, Pos('&nbsp;', total_price)+5);
                              while (total_price <> '') and (total_price[Length(total_price)] = ' ') do
                                Delete(total_price, Length(total_price), 1);
                              if UpperCase(total_price) <> 'EUR' then
                                ChangePrice(ParamWebBrowser, 'EUR', strHTML);

                              total_price := strHTML + ' EUR';

                              if total_price <> ' EUR' then
                                try
                                  paramOutData.add(
                                        flight_type + '|' +
                                        depart_date + '|' +
                                        depart_time + '|' +
                                        arrival_date + '|' +
                                        arrival_time + '|' +
                                        flight_no + '|' +
                                        total_price);
                                finally
                                  SetLength(flight_no, 0);
                                  SetLength(depart_time, 0);
                                  SetLength(arrival_time, 0);
                                  SetLength(strHTML, 0);
                                  SetLength(total_price, 0);
                                end;
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
          loc_date_depart := date_return;

      end;
  finally
    SetLength(WizzAirStartURL, 0);
    SetLength(EncodedDataString, 0);
    SetLength(iniPath, 0);
    SetLength(flight_type, 0);
    SetLength(depart_date, 0);
    SetLength(arrival_date, 0);
    FreeAndNil(ParamWebBrowser); // that there were no memory leaks
  end;
end;

procedure ChangePrice(const wb: TWebBrowser; const Currency: string; var Price: string);
var
  i, k: Integer;
  Doc: IHTMLDocument2;
  Element: IHTMLElement;
  cb: IHTMLSelectElement;
  DocCollection: IHTMLElementCollection;
  html, origPrice, chPrice: string;
  oPrice, cPrice, fPrice: Extended;
begin
  Doc := wb.Document as IHTMLDocument2;
  if Doc <> nil then
  try
    DocCollection := Doc.all.tags('select') as IHTMLElementCollection;
    for i := 0 to DocCollection.length-1 do
      begin
        Element := (DocCollection.item(i, 0) as IHTMLElement);
        if Element.getAttribute('id', 0) = 'mcpPriceChange' then
          begin
            cb := (Element as IHTMLSelectElement);
            for k := 0 to cb.length-1 do
              if (cb.item(k, 0) as IHTMLElement).innerText = Currency then
                begin
                  cb.selectedIndex := k;
                  if Doc.parentWindow <> nil then
                    begin
                      Doc.parentWindow.ExecScript('updateMcpTooltip()', OleVariant('JavaScript')) ;
                      html := wb.OleObject.Document.documentElement.innerHTML;
                      if Pos('AllInclusivePriceSummary_summary', html) > 0 then
                        begin
                          Delete(html, 1, Pos('AllInclusivePriceSummary_summary', html));
                          Delete(html, 1, Pos('>', html));
                          origPrice := Copy(html, 1, Pos('<', html)-1);
                          Delete(origPrice, Pos(' ', origPrice), Length(origPrice));

                          if Pos('mcpPriceFinal', html) > 0 then
                            begin
                              Delete(html, 1, Pos('mcpPriceFinal', html));
                              Delete(html, 1, Pos('>', html));
                              chPrice := Copy(html, 1, Pos('<', html)-1);
                              Delete(chPrice, Pos(' ', chPrice), Length(chPrice));
                            end;

                          if not TryStrToFloat(origPrice, oPrice) then
                            oPrice := 0;
                          if not TryStrToFloat(chPrice, cPrice) then
                            cPrice := 0;
                          if not TryStrToFloat(Price, fPrice) then
                            fPrice := 1;

                          if (oPrice > 0) and (cPrice > 0) then
                            Price := FormatFloat('#.##', (cPrice/oPrice)*fPrice);
                        end;
                    end;
                  Break;
                end;
            Break;
          end;
      end;
  finally
    Doc.close;
    SetLength(html, 0);
    SetLength(origPrice, 0);
    SetLength(chPrice, 0);
  end;
end;

function DateTimeToStringRet(paramFormat: string; paramDate: TDateTime) : string;
begin
  DateTimeToString(Result, paramFormat, paramDate);
end;

function TryStrToFloat(S: string; var Value: Extended): Boolean;
begin
  S := StringReplace(S, ',', DecimalSeparator, []);
  S := StringReplace(S, '.', DecimalSeparator, []);
  try
    Value := StrToFloat(S);
    Result := True;
  except
    Result := False;
  end;
end;

end.

