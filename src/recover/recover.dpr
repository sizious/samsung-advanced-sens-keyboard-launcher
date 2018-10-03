program recover;

{$R 'recover.res' 'recover.rc'}
{$R 'icon.res'}

uses
  Windows,
  SysUtils,
  Tlhelp32,
  ShellApi,
  XPMan;

const
  APPNAME : string = 'Advanced SENS Keyboard Launcher';
  APPFILE : string = 'senskeyb.exe';

var
  CurrentPath: string;
  Counter: Integer;
  
//------------------------------------------------------------------------------

function UpString(Str: string): string;
var
  i : integer;
begin
  Result := '';
  for i := 1 to Length(Str) do
    Result := Result + UpCase(Str[i]);
end;

//------------------------------------------------------------------------------

//fonction qui retourne l'id d'un process fournit en parametre
function GetProcessId(ProgName : string) : Cardinal;
var
  Snaph : THandle;
  Proc  : TProcessEntry32;
  PId   : Cardinal;
  
begin
  PId := 0;
  Proc.dwSize:=sizeof(Proc);
  Snaph := CreateToolHelp32SnapShot(TH32CS_SNAPALL, 0);  //recupere un capture de process
  Process32First(Snaph, Proc);  //premeir process de la list
  if UpString(ExtractFileName(Proc.szExeFile)) = UpString(ProgName) then  //test pour savoir si le process correspond
     PId := Proc.th32ProcessID // recupere l'id du process
  else begin
    while Process32Next(Snaph, Proc) do  //dans le cas contraire du test on continue à cherche le process en question
    begin
      if UpString(ExtractFileName(Proc.szExeFile)) = UpString(ProgName) then
        PId := Proc.th32ProcessID;
    end;
  end;
  CloseHandle(Snaph);
  Result := PId;
end;

//------------------------------------------------------------------------------

function KillFileName(FileName : string) : boolean;
var
  Proch : THandle;
  PId   : Cardinal;
  
begin
  PId := GetProcessId(FileName);
  Proch := OpenProcess(PROCESS_ALL_ACCESS, True, PId); //handle du process
  if not TerminateProcess(Proch, PId) then Result := False
  else Result := True;//terminer le process
  CloseHandle(Proch); 
end;

//------------------------------------------------------------------------------

function IsFileRunning(FileName: string): Boolean;
var
  Proch : THandle;
  PId   : Cardinal;
  
begin
  PId := GetProcessId(FileName);
  Proch := OpenProcess(PROCESS_ALL_ACCESS, True, PId); //handle du process
  Result := Proch <> 0;
  CloseHandle(Proch);
end;

//------------------------------------------------------------------------------

begin
  CurrentPath := ExtractFilePath(ParamStr(0));

  if LowerCase(ParamStr(1)) = '/setlang' then begin
    // waiting...
    Counter := 0;
    while (Counter < 10) and (IsFileRunning(APPFILE)) do begin
      Sleep(1000);
      Inc(Counter);
    end;

    // restart recover
    KillFileName(APPFILE);
  end else
    if not KillFileName(APPFILE) then
    begin
      MessageBoxA(0, PChar(APPNAME + ' not found in memory.'), 'Failed', MB_ICONWARNING);
      Exit;
    end;

  ShellExecute(0, 'open', PChar(APPFILE), '', PChar(CurrentPath), SW_SHOWNORMAL);

  if GetProcessId(APPFILE) = 0 then
  begin
    MessageBoxA(0, PChar('Failed to run ' + APPNAME +' program file.'), 'Failed', MB_ICONWARNING);
    Exit;
  end;
end.
