program senskeyb;

uses
  Windows,
  SysUtils,
  Forms,
  main in 'main.pas' {Main_Form},
  keysmap in 'common\keysmap.pas',
  dllcalls in 'common\dllcalls.pas',
  config in 'config.pas',
  hookmgr in 'hookmgr.pas',
  about in 'about.pas' {AboutBox},
  uilang in 'uilang.pas' {frmLanguage};

{$R *.res}

var
  HookStarted : Boolean;

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutDown := True;
{$ENDIF}
  
  Application.Initialize;
  Application.Title := 'Advanced SENS Keyboard Launcher';

  (*if not FileExists(GetConfigFileName) then begin
    ShowLanguageWindow(False);
  end else*)
  LoadLanguagePack;

  CreateMutex(nil, False, PChar(ExtractFileName(Application.ExeName)));
  if (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    MessageBoxA(Application.Handle, PChar(MESSAGE_OneInstanceOnly), PChar(TITLE_FatalError), MB_ICONERROR);
    ExitCode := 1;
  end else begin

    if LowerCase(ParamStr(1)) = '/startup' then
    begin
      ShowWindow(Application.Handle, SW_HIDE);
      Application.ShowMainForm := False;
    end;

    Application.CreateForm(TMain_Form, Main_Form);
  Application.CreateForm(TfrmLanguage, frmLanguage);
  HookStarted := StartMonitoring(); // c'est Main_Form qui recoit les messages !
    if not HookStarted then begin
      MessageBoxA(Application.Handle, PChar(MESSAGE_KeyboardHookNotStarted),
        PChar(TITLE_FatalError), MB_ICONERROR);
      ExitCode := 2;
    end else begin
      Application.Run;
      StopMonitoring();
    end;
  end;
end.
