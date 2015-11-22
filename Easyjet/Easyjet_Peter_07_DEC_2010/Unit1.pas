unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OleCtrls, SHDocVw,
  MSHTML,
  MMSystem;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    WebBrowser1: TWebBrowser;
    btn_open_website: TButton;
    Edit3: TEdit;
    Edit4: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    btn_add_input: TButton;
    Edit5: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Edit6: TEdit;
    Label5: TLabel;
    Edit7: TEdit;
    Label6: TLabel;
    Edit8: TEdit;
    Label7: TLabel;
    btn_submit: TButton;
    btn_test: TButton;
    procedure btn_open_websiteClick(Sender: TObject);
    procedure btn_add_inputClick(Sender: TObject);
    procedure btn_submitClick(Sender: TObject);
    procedure btn_testClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure SetFieldValue(theForm: IHTMLFormElement;
  const fieldName: string; const newValue: string;
  const instance: integer=0);
var
    field: IHTMLElement;
    inputField: IHTMLInputElement;
    selectField: IHTMLSelectElement;
    textField: IHTMLTextAreaElement;
begin
    field := theForm.Item(fieldName,instance) as IHTMLElement;
    if Assigned(field) then
    begin
       if field.tagName = 'INPUT' then
       begin
           inputField := field as IHTMLInputElement;
           if (inputField.type_ <> 'radio') and
              (inputField.type_ <> 'checkbox')
           then inputField.value := newValue else
                inputField.checked := (newValue = 'checked');
       end else

       if field.tagName = 'SELECT' then
       begin
           selectField := field as IHTMLSelectElement;
           selectField.value := newValue;
       end else

       if field.tagName = 'TEXTAREA' then
       begin
           textField := field as IHTMLTextAreaElement;
           textField.value := newValue;
       end;
    end;
end; //einde procedure SetFieldValue(

procedure TForm1.btn_open_websiteClick(Sender: TObject);
begin
    webbrowser1.Navigate(edit1.text);
    repeat
         Application.HandleMessage;
         Sleep(10);
    until webbrowser1.ReadyState >= READYSTATE_COMPLETE;
end; //end procedure TForm1.btn_open_websiteClick

function GetFormByNumber(document: IHTMLDocument2;
    formNumber: integer): IHTMLFormElement;
var
    forms: IHTMLElementCollection;
begin
    forms := document.Forms as IHTMLElementCollection;
    if formNumber < forms.Length then result := forms.Item(formNumber,'') as IHTMLFormElement else
                                      result := nil;
end; //end function GetFormByNumber

procedure TForm1.btn_add_inputClick(Sender: TObject);
var
    document: IHTMLDocument2;
    theForm: IHTMLFormElement;
    index: integer;
begin
    document := WebBrowser1.Document as IHTMLDocument2;
    theForm := GetFormByNumber(WebBrowser1.Document as IHTMLDocument2,0);
    SetFieldValue(theForm,'orig',edit3.text);
    SetFieldValue(theForm,'dest',edit4.text);
    SetFieldValue(theForm,'oDay',edit5.text);
    SetFieldValue(theForm,'oMonYear',edit6.text);
    SetFieldValue(theForm,'rDay',edit7.text);
    SetFieldValue(theForm,'rMonYear',edit8.text);
end; //end btn_add_inputClick

procedure TForm1.btn_submitClick(Sender: TObject);
var
    doc: IHtmlDocument2;
    i: integer;
    ov: OleVariant;
    disp: IDispatch;
    collection: IHTMLElementCollection;
    inputelement: HTMLInputImage;
begin
    WebBrowser1.ControlInterface.Document.QueryInterface(IHtmlDocument2, doc);
    if not Assigned(doc) then
    begin
        Exit;
    end;

    ov := 'INPUT';
    disp := doc.all.tags(ov);
    if Assigned(disp) then
    begin
        disp.QueryInterface(IHTMLElementCollection, collection);
        if Assigned(collection) then
        begin
            for i := 1 to collection.Get_length do
            begin
                disp := collection.item(pred(i), 0);
                disp.QueryInterface(HTMLInputImage, inputelement);
                if Assigned(inputelement) then
                begin
                    if inputelement.Name = 'btn_submitForm' then
                    begin
                        inputelement.Click;
                    end;
                end;
           end;
        end;
    end;
end; // einde btn_add_inputClick

procedure TForm1.btn_testClick(Sender: TObject);
var
    no,
    start,
    return : integer;

    {--------------------------------------------------------------------------}

    {sub} procedure Wait(Time: integer);
    var
        TimeNow: LongInt;
    begin
        TimeNow := timeGetTime;
        while (TimeNow + Time) > timeGetTime do
        begin
            Application.ProcessMessages;
        end;
    end; //einde {sub} procedure Wait(Time: integer);

   {--------------------------------------------------------------------------}
   {--------------------------------------------------------------------------}

begin
    for no:=1 to 10 do
    begin
        start:=no*3;

        if start<10 then edit5.text:='0'+inttostr(start) else
                         edit5.text:=inttostr(start);

        return:=no*3+1;
        if return<10 then edit7.text:='0'+inttostr(return) else
                          edit7.text:=inttostr(return);

        btn_open_websiteClick(Sender);
        btn_add_inputClick(Sender);
        btn_submitClick(Sender);

        Wait(100000);
    end;
end; //einde procedure TForm1.btn_testClick

end.

