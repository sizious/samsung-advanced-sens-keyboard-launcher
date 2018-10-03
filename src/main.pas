unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, KeysMap, XPMan, ComCtrls, ExtCtrls, Buttons,
  PiconeBarreTache, Menus, XPMenu, ShellApi, ImgList;

type
  TMain_Form = class(TForm)
    XPManifest: TXPManifest;
    pcMain: TPageControl;
    tsStandard: TTabSheet;
    tsCtrl: TTabSheet;
    tsLShift: TTabSheet;
    tsRShift: TTabSheet;
    Bevel1: TBevel;
    bAbout: TBitBtn;
    bApply: TBitBtn;
    bCancel: TBitBtn;
    ePrgNet: TEdit;
    ePrgMail: TEdit;
    ePrgUser: TEdit;
    bPrgMail: TBitBtn;
    bPrgUser: TBitBtn;
    tsCtrlLShift: TTabSheet;
    tsCtrlRShift: TTabSheet;
    tsLShiftRShift: TTabSheet;
    tsCtrlLShiftRShift: TTabSheet;
    bPrgNet: TBitBtn;
    lNet1: TLabel;
    lMail1: TLabel;
    lUser1: TLabel;
    lNet2: TLabel;
    ePrgCtrlNet: TEdit;
    ePrgCtrlMail: TEdit;
    lMail2: TLabel;
    lUser2: TLabel;
    ePrgCtrlUser: TEdit;
    bPrgCtrlUser: TBitBtn;
    bPrgCtrlMail: TBitBtn;
    bPrgCtrlNet: TBitBtn;
    lNet3: TLabel;
    eAltNet: TEdit;
    eAltMail: TEdit;
    lMail3: TLabel;
    lUser3: TLabel;
    eAltUser: TEdit;
    bAltUser: TBitBtn;
    bAltMail: TBitBtn;
    bAltNet: TBitBtn;
    lNet4: TLabel;
    eShiftNet: TEdit;
    eShiftMail: TEdit;
    lMail4: TLabel;
    lUser4: TLabel;
    eShiftUser: TEdit;
    bShiftUser: TBitBtn;
    bShiftMail: TBitBtn;
    bShiftNet: TBitBtn;
    lStandard: TLabel;
    lCtrl: TLabel;
    eCtrlAltNet: TEdit;
    lNet5: TLabel;
    lMail5: TLabel;
    eCtrlAltMail: TEdit;
    eCtrlAltUser: TEdit;
    lUser5: TLabel;
    bCtrlAltUser: TBitBtn;
    bCtrlAltMail: TBitBtn;
    bCtrlAltNet: TBitBtn;
    eCtrlShiftNet: TEdit;
    lNet6: TLabel;
    lMail6: TLabel;
    eCtrlShiftMail: TEdit;
    eCtrlShiftUser: TEdit;
    lUser6: TLabel;
    bCtrlShiftUser: TBitBtn;
    bCtrlShiftMail: TBitBtn;
    bCtrlShiftNet: TBitBtn;
    eAltShiftNet: TEdit;
    lNet7: TLabel;
    lMail7: TLabel;
    eAltShiftMail: TEdit;
    eAltShiftUser: TEdit;
    lUser7: TLabel;
    bAltShiftUser: TBitBtn;
    bAltShiftMail: TBitBtn;
    bAltShiftNet: TBitBtn;
    eCtrlAltShiftNet: TEdit;
    lNet8: TLabel;
    lMail8: TLabel;
    eCtrlAltShiftMail: TEdit;
    eCtrlAltShiftUser: TEdit;
    lUser8: TLabel;
    bCtrlAltShiftUser: TBitBtn;
    bCtrlAltShiftMail: TBitBtn;
    bCtrlAltShiftNet: TBitBtn;
    lLShift: TLabel;
    lRShift: TLabel;
    lCtrlLShift: TLabel;
    lCtrlRShift: TLabel;
    lLShiftRShift: TLabel;
    lCtrlLShiftRShift: TLabel;
    tsConfig: TTabSheet;
    lConfiguration: TLabel;
    Picone: TPiconeBarreTache;
    PopupMenu: TPopupMenu;
    Open1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    XPMenu: TXPMenu;
    odFile: TOpenDialog;
    tsHelp: TTabSheet;
    lHelp: TLabel;
    rgTray: TRadioGroup;
    gbOptions: TGroupBox;
    cbRunStartup: TCheckBox;
    cbClosePrompt: TCheckBox;
    lDescription: TLabel;
    lNotMadeSamsung: TLabel;
    ImageList: TImageList;
    lNoAltKey: TLabel;
    lVersion: TLabel;
    GroupBox2: TGroupBox;
    BitBtn1: TBitBtn;
    Label39: TLabel;
    lTranslatedBy: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bPrgNetClick(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bApplyClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure bAboutClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
    procedure ExecuteApplicationMessage(var Msg: TMessage); message WM_SENS_KEYB;
    procedure Run(ApplicationName: TFileName);

    function CloseConfigWindow : Boolean;

    function QuitApplication(ByCode: Boolean; RestartApplication: Boolean): Boolean;
  public
    { Public declarations }
    ProgramsFileNames : array[0..23] of string;

    procedure ApplyProgramsChanges;
    procedure ApplyConfig;
    function MsgBox(Text, Caption: string; Flags: Integer): Integer;
  end;

var
  Main_Form: TMain_Form;
  AppName: string;
  
implementation

uses config, about, uilang;

{$R *.dfm}

//------------------------------------------------------------------------------
//
// Procédure de lecture du numéro de version de l'application
//    Par Nono40 et publiée sur nono40.developpez.com
//
// Si le numéro de version est trouvé, la réponse est du style '2.1.3.154'
// Si le numéro de version n'est pas trouvé, la réponse est ''
//
type
  TApplicationFileVersion = record
    Major,
    Minor,
    Release,
    Build: Integer;
  end;

function GetApplicationFileVersion: TApplicationFileVersion;
Var
  Chaine:String;
  i     :Integer;

  function _FileVersion(LanguageCode: string): string;
  Var
    S         : String;
    Taille    : DWord;
    Buffer    : PChar;
    VersionPC : PChar;
    VersionL  : DWord;

  Begin
    Result:='';
    {--- On demande la taille des informations sur l'application ---}
    S := Application.ExeName;
    Taille := GetFileVersionInfoSize(PChar(S), Taille);
    Buffer := nil;
    If Taille>0
    Then Try
    {--- Réservation en mémoire d'une zone de la taille voulue ---}
      Buffer := AllocMem(Taille);
    {--- Copie dans le buffer des informations ---}
      GetFileVersionInfo(PChar(S), 0, Taille, Buffer);
    {--- Recherche de l'information de version ---}
      If VerQueryValue(Buffer, PChar('\StringFileInfo\' + LanguageCode
        + '\FileVersion'), Pointer(VersionPC), VersionL) Then
          Result:=VersionPC;
    Finally
      FreeMem(Buffer, Taille);
    End;
  end;

begin
  Chaine:=_FileVersion('040C04E4');

  Result.Major := -1;
  Result.Minor := -1;
  Result.Release := -1;
  Result.Build := -1;

  If Chaine <> '' then Begin
    i:=Pos('.',Chaine);
    If i>1
    Then Begin
      Result.Major:=StrToIntDef(Copy(Chaine,1,i-1), -1);
      Chaine:=Copy(Chaine,i+1,Length(Chaine)-i);
      i:=Pos('.',Chaine);
      If i>1
      Then Begin
        Result.Minor:=StrToIntDef(Copy(Chaine,1,i-1), -1);
        Chaine:=Copy(Chaine,i+1,Length(Chaine)-i);
        i:=Pos('.',Chaine);
        If i>1
        Then Begin
          Result.Release:=StrToIntDef(Copy(Chaine,1,i-1), -1);
          Result.Build:=StrToIntDef(Copy(Chaine,i+1,Length(Chaine)-i), -1);
        End;
      End;
    End;
  End;
End;


//------------------------------------------------------------------------------

procedure TMain_Form.Run(ApplicationName : TFileName);
begin
  //ShowMessage(ApplicationName);
  if ApplicationName = '' then Exit;
  ShellExecute(Handle, 'open', PChar(ApplicationName), '', '', SW_SHOWNORMAL);
end;

//------------------------------------------------------------------------------

procedure TMain_Form.ExecuteApplicationMessage(var Msg: TMessage);
var
  KeysCode : TKeysPressed;

begin
  KeysCode := TKeysPressed(Msg.wParam);
  //ShowMessage(IntToStr(Integer(KeysCode)));

  case KeysCode of
      kpNet                           : Run(ProgramsFileNames[0]);
      kpMail                          : Run(ProgramsFileNames[1]);
      kpUser                          : Run(ProgramsFileNames[2]);
      kpCtrlNet                       : Run(ProgramsFileNames[3]);
      kpCtrlMail                      : Run(ProgramsFileNames[4]);
      kpCtrlUser                      : Run(ProgramsFileNames[5]);
      kpLeftShiftNet                  : Run(ProgramsFileNames[6]);
      kpLeftShiftMail                 : Run(ProgramsFileNames[7]);
      kpLeftShiftUser                 : Run(ProgramsFileNames[8]);
      kpRightShiftNet                 : Run(ProgramsFileNames[9]);
      kpRightShiftMail                : Run(ProgramsFileNames[10]);
      kpRightShiftUser                : Run(ProgramsFileNames[11]);
      kpCtrlLeftShiftNet              : Run(ProgramsFileNames[12]);
      kpCtrlLeftShiftMail             : Run(ProgramsFileNames[13]);
      kpCtrlLeftShiftUser             : Run(ProgramsFileNames[14]);
      kpCtrlRightShiftNet             : Run(ProgramsFileNames[15]);
      kpCtrlRightShiftMail            : Run(ProgramsFileNames[16]);
      kpCtrlRightShiftUser            : Run(ProgramsFileNames[17]);
      kpRightShiftLeftShiftNet        : Run(ProgramsFileNames[18]);
      kpRightShiftLeftShiftMail       : Run(ProgramsFileNames[19]);
      kpRightShiftLeftShiftUser       : Run(ProgramsFileNames[20]);
      kpCtrlLeftShiftRightShiftNet    : Run(ProgramsFileNames[21]);
      kpCtrlLeftShiftRightShiftMail   : Run(ProgramsFileNames[22]);
      kpCtrlLeftShiftRightShiftUser   : Run(ProgramsFileNames[23]);
  end;
end;

//------------------------------------------------------------------------------

procedure TMain_Form.ApplyConfig;
begin
  LoadLanguagePack;
  
  ApplyProgramsChanges;
  
  // --- options ---
  // tray icon
  case rgTray.ItemIndex of
    0 : begin // minimize
          Picone.CacherSiMinimize := True;
          Picone.ReduireSiFin := False;
          Picone.PetiteIconeVisible := True;
        end;
    1 : begin // close
          Picone.CacherSiMinimize := False;
          Picone.ReduireSiFin := True;
          Picone.PetiteIconeVisible := True;
        end;
    2 : begin
          // disable
          Picone.CacherSiMinimize := False;
          Picone.ReduireSiFin := False;
          Picone.PetiteIconeVisible := False;
        end;
  end;

  // pour le run at startup
  if cbRunStartup.Checked <> IsSetToRunAtStartup then SetToRunAtStartup(cbRunStartup.Checked);

  // sauver dans le fichier
  SaveConfig;
end;

//------------------------------------------------------------------------------

procedure TMain_Form.ApplyProgramsChanges;
var
  i : Integer;

begin
  // sauver tous les chemins des différentes applications
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TEdit then
    begin
      with Components[i] as TEdit do
        ProgramsFileNames[Tag] := Text;
    end;

  end;
end;

//------------------------------------------------------------------------------

function TMain_Form.CloseConfigWindow : Boolean;
begin
  Result := True;

  if Picone.CacherSiMinimize then
  begin
    Application.Minimize;
    Exit;
  end;

  if Picone.ReduireSiFin then
  begin
    Close;
    Exit;
  end;

  Result := False;
  //Close; //quitter
end;

//------------------------------------------------------------------------------

procedure TMain_Form.FormCreate(Sender: TObject);
var
  Version: TApplicationFileVersion;
  S: string;

begin
  lTranslatedBy.Caption := '';
  AppName := Application.Title;
  Picone.Hint := AppName;
  Version := GetApplicationFileVersion;
  S := IntToStr(Version.Major) + '.' + IntToStr(Version.Minor);

  Application.Title := AppName + ' - v' + S + ' - (C)reated by [big_fury]SiZiOUS';
  Caption := Application.Title;
  pcMain.ActivePageIndex := 0;

  lVersion.Caption := lVersion.Caption + ' ' + S + '.' + IntToStr(Version.Release) + ' (Build '
    + IntToStr(Version.Build) + ')';

  LoadConfig;
end;

procedure TMain_Form.FormHide(Sender: TObject);
begin
  Picone.GrandeIconeVisible := False;
end;

procedure TMain_Form.FormShow(Sender: TObject);
begin
  Picone.GrandeIconeVisible := True;
end;

function TMain_Form.MsgBox(Text, Caption: string; Flags: Integer): Integer;
begin
  Result := MessageBoxA(Handle, PChar(Text), PChar(Caption), Flags);
end;

procedure TMain_Form.bCancelClick(Sender: TObject);
begin
  LoadConfig;
  if not CloseConfigWindow then Close;
end;

procedure TMain_Form.BitBtn1Click(Sender: TObject);
begin
  if ShowLanguageWindow(True) then
    QuitApplication(True, True);  
end;

procedure TMain_Form.bPrgNetClick(Sender: TObject);
var
  edit_name : string;
  target_edit : TEdit;
  
begin
  edit_name := (Sender as TBitBtn).Name;
  edit_name[1] := 'e';
  target_edit := FindComponent(edit_name) as TEdit;

  with odFile do
    if Execute then target_edit.Text := FileName;
end;

procedure TMain_Form.Open1Click(Sender: TObject);
begin
  Picone.MontrerApplication;
end;

procedure TMain_Form.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Main_Form.Picone.ReduireSiFin then Exit;
  if not QuitApplication(False, False) then
    Action := caNone;
end;

procedure TMain_Form.bApplyClick(Sender: TObject);
begin
  ApplyConfig;
  if not CloseConfigWindow then
  begin
    MsgBox(MESSAGE_RecoverMessageInfo, TITLE_Information, MB_ICONINFORMATION);
    Picone.CacherApplication;
  end;
end;

function TMain_Form.QuitApplication(ByCode: Boolean; RestartApplication: Boolean): Boolean;
var
  CanDo : Integer;
  P: string;

begin
  Result := False;

  if not ByCode and Main_Form.cbClosePrompt.Checked then
  begin
    CanDo := MsgBox(MESSAGE_QuitConfirmation, TITLE_Question, MB_ICONWARNING + MB_YESNO + MB_DEFBUTTON2);
    if CanDo = IDNO then Exit;
  end;

  Result := True;

  // une dernière sauvegarde
  SaveConfig;

  if RestartApplication then begin
    P := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
    ShellExecute(Handle, 'open', PChar(P + 'recover.exe'), '/setlang', PChar(P), SW_SHOWNORMAL);
  end;

  Application.Terminate; // si close met en Tray
end;

procedure TMain_Form.Exit1Click(Sender: TObject);
begin
  QuitApplication(False, False);
end;

procedure TMain_Form.bAboutClick(Sender: TObject);
begin
  AboutBox := TAboutBox.Create(Application);
  try
    AboutBox.ShowModal;
  finally
    AboutBox.Free;
  end;
end;

end.
