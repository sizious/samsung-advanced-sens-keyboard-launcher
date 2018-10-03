unit uilang;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, IniFiles;

type
  TLanguagePackInformation = record
    Author: string;
    FileName: TFileName;
    Name: string;
    Version: string;
  end;

  TfrmLanguage = class(TForm)
    bApply: TBitBtn;
    cbLang: TComboBox;
    Bevel1: TBevel;
    Image1: TImage;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Image1Click(Sender: TObject);
    procedure cbLangChange(Sender: TObject);
  private
    { Déclarations privées }
    fConfigClicked: Boolean;
    fLanguageFiles: TStringList;
    fMustRestart: Boolean;
    fLangChanged: Boolean;
    procedure ApplyLanguagePack;
    procedure GetAvailableLanguages;
    property LangChanged: Boolean read fLangChanged write fLangChanged;
  public
    { Déclarations publiques }
    property MustRestart: Boolean read fMustRestart write fMustRestart;
  end;

const
  ENGLISH_DEFAULT = 'ENGLISH:DEFAULT';
  
var
  frmLanguage: TfrmLanguage;
  LanguagePackSelected: TFileName;

  MESSAGE_OneInstanceOnly,
  MESSAGE_KeyboardHookNotStarted,
  MESSAGE_RecoverMessageInfo,
  MESSAGE_QuitConfirmation,
  TITLE_Information,
  TITLE_FatalError,
  TITLE_Question: string;
  
function GetSelectedLanguagePackInfo: TLanguagePackInformation;
function LoadLanguagePack: Boolean;
function ShowLanguageWindow(ConfigClicked: Boolean): Boolean;

implementation

uses XMLDoc, XMLIntf, config, main;

{$R *.dfm}

//------------------------------------------------------------------------------

function GetLanguagesPath: TFileName;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'ui\';
end;

//------------------------------------------------------------------------------

function GetLanguagePackSelectedFromConfigFile: TFileName;
var
  LangNode : IXMLNode;
  XMLDoc : TXMLDocument;

begin
  Result := ENGLISH_DEFAULT;
  if not FileExists(GetConfigFileName) then Exit;
  XMLDoc := TXMLDocument.Create(Application);
  try
    XMLDoc.Active := True;
    XMLDoc.LoadFromFile(GetConfigFileName);
    LangNode := XMLDoc.DocumentElement.ChildNodes.FindNode('language');
    try
      Result := LangNode.NodeValue;
    except
      Result := ENGLISH_DEFAULT;
    end;
  finally
    XMLDoc.Free;
  end;
end;

//------------------------------------------------------------------------------

function GetSelectedLanguagePackInfo: TLanguagePackInformation;
var
  LanguagePackFile: TFileName;
  IniFile: TIniFile;

begin
  Result.Author := '';
  Result.FileName := '';
  Result.Name := ENGLISH_DEFAULT;
  Result.Version := '';

  LanguagePackSelected := GetLanguagePackSelectedFromConfigFile;
  LanguagePackFile := GetLanguagesPath + LanguagePackSelected;
  if LanguagePackSelected <> ENGLISH_DEFAULT then
    try
      IniFile := TIniFile.Create(LanguagePackFile);
      Result.Author := IniFile.ReadString('SENS Language Pack', 'Author', '(Unknow)');
      Result.FileName := LanguagePackFile;
      Result.Name := IniFile.ReadString('SENS Language Pack', 'Name', '(Unknow)');
      Result.Version := IniFile.ReadString('SENS Language Pack', 'Version', '(Unknow)');
      IniFile.Free;
    except end;
end;

//------------------------------------------------------------------------------

function LoadLanguagePack: Boolean;
var
  PackInfo: TLanguagePackInformation;
  IniFile: TIniFile;
  
  function br(S: string): string;
  begin
    Result := StringReplace(S, '<br/>', #13#10, [rfReplaceAll]);
  end;

begin
  Result := False;

  //****************************************************************************
  // DEFAULT VALUES
  //****************************************************************************

  MESSAGE_OneInstanceOnly :=
    'Error, only one instance running at the same time.' + #13#10 +
    'If you want to recover the application, launch the "Recover" program instead.';
  TITLE_FatalError := 'Fatal error';
  TITLE_Information := 'Information';
  TITLE_Question := 'Question';
  MESSAGE_KeyboardHookNotStarted := 'Error: Unable to start keyboard hook!';
  MESSAGE_RecoverMessageInfo := 'If you want to show again the application, run the "Recover" '
      + 'application from the Start menu or the "recover.exe" file from the '
      + 'Advanced SENS Keyboard Launcher directory.';
  MESSAGE_QuitConfirmation := 'Are you sure to exit ?'
      + #13#10 + 'Keyboard shortcuts will NOT work anymore.';

  //****************************************************************************
  // APPLYING LANGUAGE PACK
  //****************************************************************************

  PackInfo := GetSelectedLanguagePackInfo;
  if PackInfo.Name <> ENGLISH_DEFAULT then
    if FileExists(PackInfo.FileName) then begin
      IniFile := TIniFile.Create(PackInfo.FileName);
      try
        // messages
        MESSAGE_OneInstanceOnly := br(IniFile.ReadString('Messages', 'OneInstanceOnly', MESSAGE_OneInstanceOnly));
        MESSAGE_KeyboardHookNotStarted := br(IniFile.ReadString('Messages', 'KeyboardHookNotStarted', MESSAGE_KeyboardHookNotStarted));
        MESSAGE_RecoverMessageInfo := br(IniFile.ReadString('Messages', 'RecoverMessageInfo', MESSAGE_RecoverMessageInfo));
        MESSAGE_QuitConfirmation := br(IniFile.ReadString('Messages', 'QuitConfirmation', MESSAGE_QuitConfirmation));
        TITLE_FatalError := br(IniFile.ReadString('Titles', 'FatalError', TITLE_FatalError));
        TITLE_Information := br(IniFile.ReadString('Titles', 'Information', TITLE_Information));
        TITLE_Question := br(IniFile.ReadString('Titles', 'Question', TITLE_Question));

        if Assigned(Main_Form) then
          with Main_Form do begin
            // tray
            Open1.Caption := br(IniFile.ReadString('TrayIcon', 'Open', Open1.Caption));
            Exit1.Caption := br(IniFile.ReadString('TrayIcon', 'Exit', Exit1.Caption));

            // buttons
            bAbout.Caption := br(IniFile.ReadString('Buttons', 'About', bAbout.Caption));
            bApply.Caption := br(IniFile.ReadString('Buttons', 'Apply', bApply.Caption));
            bCancel.Caption := br(IniFile.ReadString('Buttons', 'Cancel', bCancel.Caption));
            bPrgMail.Caption := br(IniFile.ReadString('Buttons', 'Browse', bPrgMail.Caption));
            bPrgUser.Caption := bPrgMail.Caption;
            bPrgNet.Caption := bPrgMail.Caption;
            bPrgCtrlUser.Caption := bPrgMail.Caption;
            bPrgCtrlMail.Caption := bPrgMail.Caption;
            bPrgCtrlNet.Caption := bPrgMail.Caption;
            bAltUser.Caption := bPrgMail.Caption;
            bAltMail.Caption := bPrgMail.Caption;
            bAltNet.Caption := bPrgMail.Caption;
            bShiftUser.Caption := bPrgMail.Caption;
            bShiftMail.Caption := bPrgMail.Caption;
            bShiftNet.Caption := bPrgMail.Caption;
            bCtrlAltUser.Caption := bPrgMail.Caption;
            bCtrlAltMail.Caption := bPrgMail.Caption;
            bCtrlAltNet.Caption := bPrgMail.Caption;
            bCtrlShiftUser.Caption := bPrgMail.Caption;
            bCtrlShiftMail.Caption := bPrgMail.Caption;
            bCtrlShiftNet.Caption := bPrgMail.Caption;
            bCtrlAltShiftUser.Caption := bPrgMail.Caption;
            bCtrlAltShiftMail.Caption := bPrgMail.Caption;
            bCtrlAltShiftNet.Caption := bPrgMail.Caption;
            bAltShiftUser.Caption := bPrgMail.Caption;
            bAltShiftMail.Caption := bPrgMail.Caption;
            bAltShiftNet.Caption := bPrgMail.Caption;

            // labels Internet, Mail, User
            lNet1.Caption := br(IniFile.ReadString('FunctionLabels', 'Internet', lNet1.Caption));
            lMail1.Caption := br(IniFile.ReadString('FunctionLabels', 'Mail', lMail1.Caption));
            lUser1.Caption := br(IniFile.ReadString('FunctionLabels', 'User', lUser1.Caption));
            lNet2.Caption := br(IniFile.ReadString('FunctionLabels', 'Internet', lNet1.Caption));
            lMail2.Caption := br(IniFile.ReadString('FunctionLabels', 'Mail', lMail1.Caption));
            lUser2.Caption := br(IniFile.ReadString('FunctionLabels', 'User', lUser1.Caption));
            lNet3.Caption := br(IniFile.ReadString('FunctionLabels', 'Internet', lNet1.Caption));
            lMail3.Caption := br(IniFile.ReadString('FunctionLabels', 'Mail', lMail1.Caption));
            lUser3.Caption := br(IniFile.ReadString('FunctionLabels', 'User', lUser1.Caption));
            lNet4.Caption := br(IniFile.ReadString('FunctionLabels', 'Internet', lNet1.Caption));
            lMail4.Caption := br(IniFile.ReadString('FunctionLabels', 'Mail', lMail1.Caption));
            lUser4.Caption := br(IniFile.ReadString('FunctionLabels', 'User', lUser1.Caption));
            lNet5.Caption := br(IniFile.ReadString('FunctionLabels', 'Internet', lNet1.Caption));
            lMail5.Caption := br(IniFile.ReadString('FunctionLabels', 'Mail', lMail1.Caption));
            lUser5.Caption := br(IniFile.ReadString('FunctionLabels', 'User', lUser1.Caption));
            lNet6.Caption := br(IniFile.ReadString('FunctionLabels', 'Internet', lNet1.Caption));
            lMail6.Caption := br(IniFile.ReadString('FunctionLabels', 'Mail', lMail1.Caption));
            lUser6.Caption := br(IniFile.ReadString('FunctionLabels', 'User', lUser1.Caption));
            lNet7.Caption := br(IniFile.ReadString('FunctionLabels', 'Internet', lNet1.Caption));
            lMail7.Caption := br(IniFile.ReadString('FunctionLabels', 'Mail', lMail1.Caption));
            lUser7.Caption := br(IniFile.ReadString('FunctionLabels', 'User', lUser1.Caption));
            lNet8.Caption := br(IniFile.ReadString('FunctionLabels', 'Internet', lNet1.Caption));
            lMail8.Caption := br(IniFile.ReadString('FunctionLabels', 'Mail', lMail1.Caption));
            lUser8.Caption := br(IniFile.ReadString('FunctionLabels', 'User', lUser1.Caption));

            // labels functions
            lStandard.Caption := br(IniFile.ReadString('TabsTitlesLabel', 'Standard', lStandard.Caption));
            lCtrl.Caption := br(IniFile.ReadString('TabsTitlesLabel', 'Ctrl', lCtrl.Caption));
            lLShift.Caption := br(IniFile.ReadString('TabsTitlesLabel', 'LeftShift', lLShift.Caption));
            lRShift.Caption := br(IniFile.ReadString('TabsTitlesLabel', 'RightShift', lRShift.Caption));
            lCtrlLShift.Caption := br(IniFile.ReadString('TabsTitlesLabel', 'CtrlLeftShift', lCtrlLShift.Caption));
            lCtrlRShift.Caption := br(IniFile.ReadString('TabsTitlesLabel', 'CtrlRightShift', lCtrlRShift.Caption));
            lLShiftRShift.Caption := br(IniFile.ReadString('TabsTitlesLabel', 'LeftShiftRightShift', lLShiftRShift.Caption));
            lCtrlLShiftRShift.Caption := br(IniFile.ReadString('TabsTitlesLabel', 'CtrlLeftShiftRightShift', lCtrlLShiftRShift.Caption));
            lConfiguration.Caption := br(IniFile.ReadString('TabsTitlesLabel', 'Configuration', lConfiguration.Caption));
            lHelp.Caption := br(IniFile.ReadString('TabsTitlesLabel', 'Help', lHelp.Caption));

            // tabs caption
            tsStandard.Caption := br(IniFile.ReadString('Tabs', 'Standard', tsStandard.Caption));
            tsCtrl.Caption := br(IniFile.ReadString('Tabs', 'Ctrl', tsCtrl.Caption));
            tsLShift.Caption := br(IniFile.ReadString('Tabs', 'LShift', tsLShift.Caption));
            tsRShift.Caption := br(IniFile.ReadString('Tabs', 'RShift', tsRShift.Caption));
            tsCtrlLShift.Caption := br(IniFile.ReadString('Tabs', 'CtrlLShift', tsCtrlLShift.Caption));
            tsCtrlRShift.Caption := br(IniFile.ReadString('Tabs', 'CtrlRShift', tsCtrlRShift.Caption));
            tsLShiftRShift.Caption := br(IniFile.ReadString('Tabs', 'LShiftRShift', tsLShiftRShift.Caption));
            tsCtrlLShiftRShift.Caption := br(IniFile.ReadString('Tabs', 'CtrlLShiftRShift', tsCtrlLShiftRShift.Caption));
            tsConfig.Caption := br(IniFile.ReadString('Tabs', 'Config', tsConfig.Caption));
            tsHelp.Caption := br(IniFile.ReadString('Tabs', 'Help', tsHelp.Caption));

            // browse dialog
            odFile.Title := br(IniFile.ReadString('BrowseDialog', 'Title', odFile.Title));
            (*if ((Pos('Application', odFile.Filter) = 0) or (Pos('All Files', odFile.Filter) = 0)) then
              raise Exception.Create('CHECK THE odFile.Filter TO TRANSLATE IT!!');*)
            odFile.Filter := StringReplace(odFile.Filter, 'Applications',
              br(IniFile.ReadString('BrowseDialog', 'ApplicationFilter', 'Applications')), [rfReplaceAll]);
            odFile.Filter := StringReplace(odFile.Filter, 'All Files',
              br(IniFile.ReadString('BrowseDialog', 'AllFilesFilter', 'All Files')), [rfReplaceAll]);

            // help
            (*if (Pos('Application version :', lVersion.Caption) = 0) then
              raise Exception.Create('CHECK THE lVersion.Caption TO TRANSLATE IT!!');*)
            lVersion.Caption := StringReplace(lVersion.Caption, 'Application version :',
              br(IniFile.ReadString('Help', 'AppVersion', 'Application version :')), [rfReplaceAll]);
            lDescription.Caption := br(IniFile.ReadString('Help', 'Description', lDescription.Caption));
            lNotMadeSamsung.Caption := br(IniFile.ReadString('Help', 'NotMadeBySamsung', lNotMadeSamsung.Caption));
            lNoAltKey.Caption := br(IniFile.ReadString('Help', 'NoAltKey', lNoAltKey.Caption));

            // config
            rgTray.Caption := ' ' + br(IniFile.ReadString('ConfigurationTray', 'Tray', rgTray.Caption)) + ' ';
            rgTray.Items[0] := br(IniFile.ReadString('ConfigurationTray', 'Minimize', rgTray.Items[0]));
            rgTray.Items[1] := br(IniFile.ReadString('ConfigurationTray', 'Close', rgTray.Items[1]));
            rgTray.Items[2] := br(IniFile.ReadString('ConfigurationTray', 'Disabled', rgTray.Items[2]));

            gbOptions.Caption := ' ' + br(IniFile.ReadString('ConfigurationOptions', 'Options', rgTray.Caption)) + ' ';
            cbRunStartup.Caption := br(IniFile.ReadString('ConfigurationOptions', 'RunStartup', rgTray.Caption));
            cbClosePrompt.Caption := br(IniFile.ReadString('ConfigurationOptions', 'PromptWhenClosing', rgTray.Caption));

            lTranslatedBy.Caption :=
              IniFile.ReadString('SENS Language Pack', 'Name', '') +
              ' v' +
              IniFile.ReadString('SENS Language Pack', 'Version', '') +
              ' by ' +
              IniFile.ReadString('SENS Language Pack', 'Author', '');
          end;
        
        Result := True;
      finally
        IniFile.Free;
      end;
    end else begin
      LanguagePackSelected := ENGLISH_DEFAULT;
      SaveConfig;
    end;
end;

//------------------------------------------------------------------------------

function ShowLanguageWindow(ConfigClicked: Boolean): Boolean;
begin
  frmLanguage := TfrmLanguage.Create(Application);
  try
    frmLanguage.fConfigClicked := ConfigClicked;
    frmLanguage.ShowModal;
    Result := frmLanguage.MustRestart;
  finally
    frmLanguage.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmLanguage.ApplyLanguagePack;
begin
  LanguagePackSelected := fLanguageFiles[cbLang.ItemIndex];
  SaveConfig;
  LoadLanguagePack;

  if fConfigClicked and LangChanged and (cbLang.ItemIndex = 0) then begin
    MessageBoxA(Handle, 'The application will be restarted in order to apply changes.', 'Warning', MB_OK + MB_ICONWARNING);
    MustRestart := True;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmLanguage.cbLangChange(Sender: TObject);
begin
  LangChanged := True;
end;

procedure TfrmLanguage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ApplyLanguagePack;
end;

//------------------------------------------------------------------------------

procedure TfrmLanguage.FormCreate(Sender: TObject);
begin
  LangChanged := False;
  MustRestart := False;
  GetAvailableLanguages;
end;

//------------------------------------------------------------------------------

procedure TfrmLanguage.FormDestroy(Sender: TObject);
begin
  fLanguageFiles.Free;
end;

//------------------------------------------------------------------------------

procedure TfrmLanguage.GetAvailableLanguages;
const
  INVALID_LANGUAGE_NAME = '<INVALID>';

var
  SRec: TSearchRec;
  Path, LanguageName: string;
  IniFile: TIniFile;
  
begin
  cbLang.Clear;
  cbLang.Items.Add('English (Default)');
  cbLang.ItemIndex := 0;

  fLanguageFiles := TStringList.Create;
  try
    fLanguageFiles.Add(ENGLISH_DEFAULT); // for english;
    
    Path := GetLanguagesPath;
    if FindFirst(Path + '*.lng', faAnyFile, SRec) = 0 then begin
      repeat
        if (SRec.Name <> '.') and (SRec.Name <> '..') then
          if (SRec.Attr and faDirectory) = 0 then begin
            IniFile := TIniFile.Create(Path + SRec.Name);
            try
              LanguageName := IniFile.ReadString('SENS Language Pack', 'Name', INVALID_LANGUAGE_NAME);
              if LanguageName <> INVALID_LANGUAGE_NAME then begin
                cbLang.Items.Add(LanguageName);
                fLanguageFiles.Add(SRec.Name);
                if SRec.Name = LanguagePackSelected then
                  cbLang.ItemIndex := fLanguageFiles.Count - 1;
              end;
            finally
              IniFile.Free;
            end;
          end;
      until FindNext(SRec) <> 0;
      FindClose(SRec);
    end;
  except
    MessageBoxA(Handle, 'ERROR: Unable to scan for Languages Pack!', 'Fatal', MB_ICONERROR);
  end;
end;

procedure TfrmLanguage.Image1Click(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------

initialization
  LanguagePackSelected := ENGLISH_DEFAULT;
  
//------------------------------------------------------------------------------

end.
