unit BrusselsAirlines;

interface

uses
  SysUtils, Classes, Httpapp, MSHTML, ActiveX, OleCtrls, SHDocVw,
  {$IFNDEF VER130}Variants,{$ENDIF} INIFiles, Windows, Unit1;

procedure GetBrusselsAirlines(
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

function GetCount(List1, List2: TStringList): Integer;
function GetString(Item: Integer; List: TStringList): string;
function GetCountAndParseHTML(const html: string; Date: TDateTime; var List: TStringList): Integer;
function GetPrice(Doc: IHTMLDocument2; id1, id2: string): string;
procedure SelectTab(Doc: IHTMLDocument2; Direction, sDate: string; Element: IHTMLElement; ATimeout: Integer = 10000);
procedure Delay(ATimeout: Integer);
function DateTimeToStringRet(paramFormat: String; paramDate: TDateTime) : string;

var
  ParamWebBrowser: TWebBrowser;

implementation

uses Forms, Controls, Dialogs;

procedure GetBrusselsAirlines(
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
  PostData: OleVariant;
  Headers: OleVariant;
  orig_date_depart: TDateTime;
  orig_date_return: TDateTime;
  loc_date_depart: TDateTime;
  loc_date_return: TDateTime;
  ch_date: TDateTime;
  i, j, div_index: Integer;
  DocCollectionDiv: IHTMLElementCollection;
  DocElementDiv: IHTMLElement;
  CollectionLi: IHTMLElementCollection;
  ElementLi: IHTMLElement;
  ElementDecForward: IHTMLElement;
  ElementLiForward: IHTMLElement;
  ElementIncForward: IHTMLElement;
  ElementDecReverse: IHTMLElement;
  ElementLiReverse: IHTMLElement;
  ElementIncReverse: IHTMLElement;
  HTMLWindow: IHTMLWindow2;
  Doc: IHTMLDocument2;
//  ParamWebBrowser: TWebBrowser;
  ini : TIniFile;
  forward_index, reverse_index, forward_reverse_index, flight_per_day: TStringList;
  EncodedDataString, StartURL, iniPath, strHTML, price, forward_id, reverse_id,
  txt, forward_tab, reverse_tab, strDate, forward_inc, forward_dec, reverse_inc, reverse_dec: string;
  count_click, count_forward, count_reverse, index_count, len, for_item, rev_item, count_li: Integer;
  isError, isMaxFlight: Boolean;
//  strlTest: TStringList;
  ForwardActive, ReverseActive: Boolean;
  vResult: OleVariant;
  ExecutionKey: string;
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

  ParamWebBrowser := TWebBrowser.Create(Application.MainForm);
  try
// Don`t forget to insert   uses Forms;  above
    TWinControl(ParamWebBrowser).Name := 'ParamWebBrowser'+IntToStr(Application.MainForm.ComponentCount);
    TWinControl(ParamWebBrowser).Parent := Application.MainForm;
    ParamWebBrowser.OnDocumentComplete := ParamWebBrowser.OnDocumentComplete;
    ParamWebBrowser.Height := Form1.ClientHeight - Form1.pn_controls.Height;
    ParamWebBrowser.Visible := True;
    ParamWebBrowser.Align := alTop;
    ParamWebBrowser.Silent := True;
    ParamWebBrowser.Update;
    Application.HandleMessage;
    IniPath := ExtractFileDir(Application.ExeName)+'\data\BrusselsAirlines.ini';
    // change the verification accordint to your rules
    if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
    //May change 4 lines according to your rules
    ini := TIniFile.Create(IniPath);
    StartURL := ini.ReadString('main','StartURL', 'nil');
    ini.Free;
    if StartURL = 'nil' then
      begin
        ShowMessage('Please chech the value of parameter StartURL in BrusselsAirlines.ini');
        Exit; //please change the code according to your rules
      end;

    if not Form1.chk1.Checked then
      begin
        ParamWebBrowser.Height := 1;
        ParamWebBrowser.Visible := False;
      end;

    Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

    forward_index := TStringList.Create;
    reverse_index := TStringList.Create;
    forward_reverse_index := TStringList.Create;
    flight_per_day := TStringList.Create;
    isMaxFlight := False;
    case flexible of
      True:
        begin
          orig_date_depart := date_depart + 2;
          orig_date_return := date_return - 3;
        end;
      False:
        begin
          orig_date_depart := date_depart;
          orig_date_return := date_return;
        end;
    end;

    loc_date_depart := date_depart;
    while (loc_date_depart <= date_return) and not Application.Terminated do
      begin
        loc_date_return := loc_date_depart;

        // Naviagate to blank page
        paramWebBrowser.Navigate('about:blank');
        repeat
          Application.HandleMessage;
          Sleep(10);
        until paramWebBrowser.ReadyState = READYSTATE_COMPLETE;

        paramWebBrowser.Navigate(StartURL);
        Form1.lbl1.Caption := 'Get value of a flowExecutionKey';
        repeat
          Application.HandleMessage;
          Sleep(10);
        until paramWebBrowser.ReadyState = READYSTATE_COMPLETE;

        ExecutionKey := ParamWebBrowser.LocationURL;
        Delete(ExecutionKey, 1, Pos('_flowExecutionKey=', ExecutionKey));
        Delete(ExecutionKey, 1, Pos('=', ExecutionKey));

        //forward
        EncodedDataString :=
          'DIRECTION=SUBMIT&' +
          '_eventId=submit&' +
          '_flowExecutionKey=' + ExecutionKey + '&' + //_cFC8B11C1-2737-2057-C9F0-D3F848FA717A_k10EDD4FE-1FC3-00D4-1010-089FC0D5E377&
          'searchOrigin=SEARCH_START&' +
          'refreshDates=&' +
          'selectedOriginAirport=' + airport_depart + '&' +
          'selectedDestinationAirport=' + airport_destination + '&' +
          'departureDate=' + DateTimeToStringRet('yyyy-mm-dd', loc_date_depart) + '&' +
          'returnDate=' + DateTimeToStringRet('yyyy-mm-dd', loc_date_return) + '&' +
          'flightFilterType=NORMAL&' +
          'serviceType=Lowest+fare+available&' +
          'numAdultsSelected=' + IntToStr(adults) + '&' +
          'numChildrenSelected=' + IntToStr(children) + '&' +
          'numInfantsSelected=' + IntToStr(infants) + '&' +
          'lang=en&' +
          'origin=' + airport_depart + '&' +
          'destination=' + airport_destination + '&' +
          'journeySpanR=RT&' +
          'journeySpan=RT&' +
          'journeySpanOW=OW&' +
          'journeySpanRT=RT&' +
          'formattedDepartureDate=' + DateTimeToStringRet('dd%2Fmm%2Fyyyy', loc_date_depart) + '&' +
//          'departureDateRange=0&' +
          'formattedReturnDate=' + DateTimeToStringRet('dd%2Fmm%2Fyyyy', loc_date_return) + '&' +
//          'returnDateRange=0&' +
          'numAdults=' + IntToStr(adults) + '&' +
          'numChildren=' + IntToStr(children) + '&' +
          'numInfants=' + IntToStr(infants) + '&' +
          'searchType=NORMAL&' +
          'services=Lowest+fare+available&' +
          'promotion=&' +
          'operatingAirlineType=bruOperatedOnly&' +
          'nonStopFlightOnly=nonStopFlightOnlySelected';

        // The PostData OleVariant needs to be an array of bytes
        // as large as the string (minus the 0 terminator)
        PostData := VarArrayCreate([0, Length(EncodedDataString)-1], varByte);

        // Now, move the Ordinal value of the character into the PostData array
        for i := 1 to Length(EncodedDataString) do
          PostData[i-1] := Ord(EncodedDataString[i]);

        Headers := 'Content-Type: application/x-www-form-urlencoded' + #10#13;

        // Naviagate to source page
        paramWebBrowser.Navigate(StartURL, EmptyParam, EmptyParam, PostData, Headers);
        // Wait while page is loading...
        isError := False;
        Form1.lbl1.Caption := 'Parse: ' + DateTimeToStringRet('dd mmm yyyy', loc_date_depart);
        repeat
          if (paramWebBrowser.ReadyState = READYSTATE_COMPLETE) and (paramWebBrowser.Document <> nil) then
            begin
              strHTML := paramWebBrowser.OleObject.Document.documentElement.innerHTML;
              isError := (Pos('id=error', strHTML) > 0) or
                         (Pos('Select your travel details', strHTML) > 0) or
                         (Pos('Selecteer je vluchtdetails', strHTML) > 0) or
                         (Pos('An error has occurred or your session has timed out.', strHTML) > 0);
            end;
          Application.HandleMessage;
          Sleep(10);
        until (paramWebBrowser.ReadyState >= READYSTATE_COMPLETE) and
              (paramWebBrowser.OleObject.Document.frames.Length > 0) or isError or Application.Terminated;

        if not isError and (paramWebBrowser.Document <> nil) and not Application.Terminated then
          begin
            paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);
            HTMLWindow := Doc.parentWindow;
            // check whether the active tabs
            CollectionLi := (Doc.all.tags('LI') as IHTMLElementCollection);
            ElementDecForward := nil;
            ElementLiForward := nil;
            ElementIncForward := nil;
            ElementDecReverse := nil;
            ElementLiReverse := nil;
            ElementIncReverse := nil;
            forward_dec := 'OUTBOUND_' + DateTimeToStringRet('yyyymmdd', loc_date_depart - 1) + '_TAB';
            forward_tab := 'OUTBOUND_' + DateTimeToStringRet('yyyymmdd', loc_date_depart) + '_TAB';
            forward_inc := 'OUTBOUND_' + DateTimeToStringRet('yyyymmdd', loc_date_depart + 1) + '_TAB';
            reverse_dec := 'INBOUND_' + DateTimeToStringRet('yyyymmdd', loc_date_depart - 1) + '_TAB';
            reverse_tab := 'INBOUND_' + DateTimeToStringRet('yyyymmdd', loc_date_depart) + '_TAB';
            reverse_inc := 'INBOUND_' + DateTimeToStringRet('yyyymmdd', loc_date_depart + 1) + '_TAB';
            count_li := 0;
            for i := 0 to CollectionLi.length - 1 do
              begin
                ElementLi := CollectionLi.item(i, EmptyParam) as IHTMLElement;

                if UpperCase(ElementLi.id) = forward_dec then
                  ElementDecForward := ElementLi;
                if UpperCase(ElementLi.id) = forward_tab then
                  ElementLiForward := ElementLi;
                if UpperCase(ElementLi.id) = forward_inc then
                  ElementIncForward := ElementLi;

                if UpperCase(ElementLi.id) = reverse_dec then
                  ElementDecReverse := ElementLi;
                if UpperCase(ElementLi.id) = reverse_tab then
                  ElementLiReverse := ElementLi;
                if UpperCase(ElementLi.id) = reverse_inc then
                  ElementIncReverse := ElementLi;

                if Assigned(ElementDecForward) and Assigned(ElementLiForward) and
                  Assigned(ElementIncForward) and Assigned(ElementDecReverse) and
                  Assigned(ElementLiReverse) and Assigned(ElementIncReverse) then Break;
              end;

            forward_id := 'OUTBOUND_' + DateTimeToStringRet('yyyymmdd', loc_date_depart) + '_DIV';
            reverse_id := 'INBOUND_' + DateTimeToStringRet('yyyymmdd', loc_date_depart) + '_DIV';

            ForwardActive := UpperCase(ElementLiForward.className) = 'SELECTED';
            ReverseActive := UpperCase(ElementLiReverse.className) = 'SELECTED';

            case ForwardActive and ReverseActive of
              True:
                begin
                  DocCollectionDiv := (Doc.all.tags('DIV') as IHTMLElementCollection);
                  for div_index := 0 to DocCollectionDiv.length - 1 do
                    begin
                      DocElementDiv := DocCollectionDiv.item(div_index, EmptyParam) as IHTMLElement;
                      if UpperCase(DocElementDiv.id) = forward_id then
                        count_forward := GetCountAndParseHTML(DocElementDiv.innerHTML,
                                         loc_date_depart, forward_index);

                      if UpperCase(DocElementDiv.id) = reverse_id then
                        count_reverse := GetCountAndParseHTML(DocElementDiv.innerHTML,
                                         loc_date_depart, reverse_index);

                      if (forward_index.Count > 0) and (reverse_index.Count > 0) then Break;
                    end;
                end;
              False:
                begin
                  if not ForwardActive then
                    begin
                      SelectTab(Doc, 'inbound', DateTimeToStringRet('yyyymmdd',
                        loc_date_depart + 1), ElementIncReverse);

                      SelectTab(Doc, 'outbound', DateTimeToStringRet('yyyymmdd',
                        loc_date_depart), ElementLiForward);
                    end;
                  DocCollectionDiv := (Doc.all.tags('DIV') as IHTMLElementCollection);
                  for div_index := 0 to DocCollectionDiv.length - 1 do
                    begin
                      DocElementDiv := DocCollectionDiv.item(div_index, EmptyParam) as IHTMLElement;
                      if UpperCase(DocElementDiv.id) = forward_id then
                        begin
                          count_forward := GetCountAndParseHTML(DocElementDiv.innerHTML,
                                           loc_date_depart, forward_index);
                          Break;
                        end;
                    end;

                  if not ReverseActive then
                    begin
                      SelectTab(Doc, 'outbound', DateTimeToStringRet('yyyymmdd',
                        loc_date_depart - 1), ElementDecForward);

                      SelectTab(Doc, 'inbound', DateTimeToStringRet('yyyymmdd',
                        loc_date_depart), ElementLiReverse);
                    end;
                  DocCollectionDiv := (Doc.all.tags('DIV') as IHTMLElementCollection);
                  for div_index := 0 to DocCollectionDiv.length - 1 do
                    begin
                      DocElementDiv := DocCollectionDiv.item(div_index, EmptyParam) as IHTMLElement;
                      if UpperCase(DocElementDiv.id) = reverse_id then
                        begin
                          count_reverse := GetCountAndParseHTML(DocElementDiv.innerHTML,
                                           loc_date_depart, reverse_index);
                          Break;
                        end;
                    end;
                end;
            end;

            isMaxFlight := ((loc_date_depart = orig_date_depart) or
                            (loc_date_depart = orig_date_return)) and
                           ((count_forward > 3) or (count_reverse > 3));

            index_count := GetCount(forward_index, reverse_index);

            if index_count > 0 then
              begin
                for i := 0 to index_count -1 do
                  begin
                    forward_id := '';
                    reverse_id := '';
                    strHTML := GetString(i, forward_index);
                    if strHTML <> '' then
                      begin
                        forward_id := Copy(strHTML, 1, Pos('|', strHTML)-1);
                        Delete(strHTML, 1, Pos('|', strHTML)-1);
                        paramOutData.Add(strHTML);
                      end;
                    if returnflight then
                      begin
                        if strHTML <> '' then
                          begin
                            for j := 0 to 6 do
                              Delete(strHTML, LastDelimiter('|', strHTML)-1, Length(strHTML));
                            txt := strHTML;
                          end;

                        strHTML := GetString(i, reverse_index);
                        if strHTML <> '' then
                          begin
                            reverse_id := Copy(strHTML, 1, Pos('|', strHTML)-1);
                            Delete(strHTML, 1, Pos('|', strHTML)-1);
                            paramOutData.Add(strHTML);

                            if (forward_id <> '') and (reverse_id <> '') and
                              ForwardActive and ReverseActive then
                              begin
                                price := GetPrice(Doc, forward_id, reverse_id);
                                price := StringReplace(price, 'EUR', 'ˆ', [rfReplaceAll, rfIgnoreCase]);
                                price := StringReplace(price, '.00 ˆ', ' ˆ', [rfReplaceAll, rfIgnoreCase]);

                                Delete(strHTML, 1, Pos(' | | | | | |', strHTML) + 11);
                                Delete(strHTML, Length(strHTML), 1);
                                Delete(strHTML, LastDelimiter('|', strHTML)+1, Length(strHTML));
                                txt := txt + strHTML + price + '|';
                                txt := StringReplace(txt, '|forward|', '|forward+reverse|',
                                  [rfReplaceAll, rfIgnoreCase]);

                                case isMaxFlight of
                                  True : flight_per_day.Add(IntToStr(forward_reverse_index.Add(txt)));
                                  False: forward_reverse_index.Add(txt);
                                end;
                              end;
                          end;
                      end;
                  end;
              end;
            Doc.close;
            forward_index.Clear;
            reverse_index.Clear;
            strHTML := '';
//          end
//        else
//        if not Application.Terminated then
//          begin
//            if Pos('id=error', strHTML) > 0 then
//              begin
//                Delete(strHTML, 1, Pos('id=error', strHTML));
//                Delete(strHTML, 1, Pos('>', strHTML));
//                Delete(strHTML, 1, Pos('>', strHTML));
//                SetLength(strHTML, Pos('<', strHTML)-1);
//                paramOutData.Add(strHTML);
//              end
//            else
//            if Pos('An error has occurred or your session has timed out.', strHTML) > 0 then
//              paramOutData.Add('An error has occurred or your session has timed out.')
//            else
//              paramOutData.Add('InternalError');
          end;

        if loc_date_depart = date_return then
          Break;

        if flexible then
          loc_date_depart := loc_date_depart + 1
        else
          loc_date_depart := date_return;
      end;
    case flight_per_day.Count > 0 of
      True:
        if forward_reverse_index.Count > 0 then
          for i := 0 to flight_per_day.Count-1 do
            paramOutData.Add(forward_reverse_index[StrToInt(flight_per_day[i])]);
      False:
        if forward_reverse_index.Count > 0 then
          paramOutData.AddStrings(forward_reverse_index);
    end;
    Form1.lbl1.Caption := '';
  finally
    SetLength(StartURL, 0);
    SetLength(EncodedDataString, 0);
    SetLength(iniPath, 0);
    SetLength(strHTML, 0);
    SetLength(price, 0);
    SetLength(forward_id, 0);
    SetLength(reverse_id, 0);
    SetLength(txt, 0);
    FreeAndNil(forward_index);
    FreeAndNil(reverse_index);
    FreeAndNil(flight_per_day);
    FreeAndNil(forward_reverse_index);
    FreeAndNil(ParamWebBrowser); // that there were no memory leaks
  end;
end;

function GetCount(List1, List2: TStringList): Integer;
begin
  Result := 0;
  if Assigned(List1) and Assigned(List2) then
    begin
      if List1.Count > 0 then
        begin
          if List1.Count >= List2.Count then
            Result := List1.Count
          else
            Result := List2.Count;
        end
      else
      if List2.Count > 0 then
        Result := List2.Count;
    end;
end;

function GetString(Item: Integer; List: TStringList): string;
begin
  Result := '';
  if Assigned(List) and (List.Count > 0) then
    begin
      if List.Count > Item then
        Result := List[Item]
      else
        Result := List[List.Count-1];
    end;
end;

function GetCountAndParseHTML(const Html: string; Date: TDateTime; var List: TStringList): Integer;
var
  s, data, flight_str, price, depart_time, arrival_time, via, flight_num: string;
  depart_date: TDateTime;
begin
  try
    Result := 0;
    via := ' ';
    s := html;
    while Pos('<DIV id=', s) > 0 do
      begin
        Delete(s, 1, Pos('<DIV id=', s)+7);
        case Pos('<DIV id=', s) > 0 of
          True : data := Copy(s, 1, Pos('<DIV id=', s));
          False: data := Copy(s, 1, Length(s));
        end;
        Delete(data, 1, Pos('_', data));
         flight_str := Copy(data, 1, Pos(' ', data)-1) + '|';

        if Pos('_outbound_', flight_str) > 0 then
          flight_str := flight_str + 'forward|'
        else
        if Pos('_inbound_', flight_str) > 0 then
          flight_str := flight_str + 'reverse| | | | | | |';

        depart_date := Date;
        flight_str := flight_str + DateTimeToStringRet('dd mmm yyyy', depart_date) + '|';

        Delete(data, 1, Pos('<SPAN class=allinPrice', data));
        Delete(data, 1, Pos('>', data));

        price := Trim(Copy(data, 1, Pos('<', data)-1));
        if Pos('ˆ', price) = 0 then
          price := price + ' ˆ';

        Delete(data, 1, Pos('<B>', data)+2);
         depart_time := Trim(Copy(data, 1, Pos('<', data)-1));

        flight_str := flight_str + depart_time + '|';

        Delete(data, 1, Pos('<B>', data)+2);
        if Pos('<B>', data) > 0 then
          begin
            Delete(data, 1, Pos('<TD', data));
            Delete(data, 1, Pos('>', data));
            via := Trim(Copy(data, 1, Pos('<', data)-1));
            while Pos('<B>', data) > 0 do
              Delete(data, 1, Pos('<B>', data)+2);
          end;
        arrival_time := Trim(Copy(data, 1, Pos('<', data)-1));

        if depart_time > arrival_time then
          depart_date := depart_date + 1;

        flight_str := flight_str + DateTimeToStringRet('dd mmm yyyy', depart_date) + '|' +
          arrival_time + '|';

        while Pos('<A title=', data) > 0 do
          begin
            Delete(data, 1, Pos('<A title=', data)+1);
            Delete(data, 1, Pos('>', data));
            flight_num := flight_num + Trim(Copy(data, 1, Pos('<', data)-1)) + ',';
          end;
        SetLength(flight_num, Length(flight_num)-1);

        flight_str := flight_str + flight_num + '|' + via + '|';

        if Pos('|forward|', flight_str) > 0 then
          flight_str := flight_str + ' | | | | | |';

        flight_str := flight_str + price + '|';

        List.Add(flight_str);

        flight_num := '';
        via := ' ';
        Inc(Result);
      end;
  finally
    SetLength(s, 0);
    SetLength(data, 0);
    SetLength(flight_str, 0);
    SetLength(price, 0);
    SetLength(depart_time, 0);
    SetLength(arrival_time, 0);
    SetLength(via, 0);
    SetLength(flight_num, 0);
  end;
end;

function GetPrice(Doc: IHTMLDocument2; id1, id2: string): string;
var
  DocCollection: IHTMLElementCollection;
  DocElement: IHTMLElement;
  count_click, i: Integer;
begin
  if Assigned(Doc) then
    begin
      count_click := 0;
      DocCollection := (Doc.all.tags('INPUT') as IHTMLElementCollection);
      for i := 0 to DocCollection.length - 1 do
        begin
          DocElement := DocCollection.item(i, EmptyParam) as IHTMLElement;
          if DocElement.id = id1 then
            begin
              DocElement.click;
              Inc(count_click);
            end;

          if DocElement.id = id2 then
            begin
              DocElement.click;
              Inc(count_click);
            end;

          if count_click = 2 then Break;
        end;

      DocCollection := (Doc.all.tags('SPAN') as IHTMLElementCollection);
      for i := 0 to DocCollection.length - 1 do
        begin
          DocElement := DocCollection.item(i, EmptyParam) as IHTMLElement;
          if UpperCase(DocElement.id) = 'SUMMARYTOTAL' then
            begin
              while Pos('Updating', DocElement.innerHTML) > 0 do
                Application.HandleMessage;
              Result := Trim(DocElement.innerHTML);
              Break;
            end;
        end;
    end;
end;

procedure SelectTab(Doc: IHTMLDocument2; Direction, sDate: string;
  Element: IHTMLElement; ATimeout: Integer = 10000);
var
  HTMLWin: IHTMLWindow2;
  t: Cardinal;
begin
  HTMLWin := Doc.parentWindow;
  if Assigned(HTMLWin) then
    try
      HTMLWin.execScript('dateTabSearch(' + #39 + Direction +
        #39 + ',' + #39 + sDate + #39 + ')', 'JavaScript');

      repeat
        t := GetTickCount;
        if MsgWaitForMultipleObjects(0, nil^, False, ATimeOut,
          QS_ALLINPUT) = WAIT_TIMEOUT then Exit;
        Application.ProcessMessages;
        Dec(ATimeout, GetTickCount - t);
      until (ATimeout <= 0) or (UpperCase(Element.className) = 'SELECTED')
    except
    end;
end;

procedure Delay(ATimeout: Integer);
var
  t: Cardinal;
begin
  while ATimeout > 0 do
    begin
      t:= GetTickCount;
      if MsgWaitForMultipleObjects(0, nil^, False, ATimeOut, QS_ALLINPUT) = WAIT_TIMEOUT then
        Exit;
      Application.ProcessMessages;
      Dec(ATimeout, GetTickCount - t);
    end;
end;

function DateTimeToStringRet(paramFormat: string; paramDate: TDateTime) : string;
begin
  DateTimeToString(Result, paramFormat, paramDate);
end;

end.


