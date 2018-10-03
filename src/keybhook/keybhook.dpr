library keybhook;

{$R 'version.res' 'version.rc'}

uses
  Windows,
  Messages,
  SysUtils,
  keysmap in '..\common\keysmap.pas';

const
  NET_KEY_CODE   : Integer = -1066074111;
  MAIL_KEY_CODE  : Integer = -1065877503;
  USER_KEY_CODE  : Integer = -1066139647;

type
  PHookRec = ^THookRec;
  THookRec = record
    AppHnd: Integer; 
    //MemoHnd: Integer; 
  end; 

var 
  Hooked: Boolean; 
  hKeyHook, hMemFile, hApp: HWND; 
  PHookRec1: PHookRec; 

//------------------------------------------------------------------------------

function GetKeysPressed(KeyStroke : Integer ; KeyState : TKeyboardState) : TKeysPressed;
const
  KEYS_VALUES : array[1..6] of Integer = (1, 2, 3, 10, 30, 50);
  
var
  KeysPressed : array[1..6] of Boolean;
  i, _keys_int_codes : Integer;
  
begin
  KeysPressed[1] := Ord(KeyStroke) = NET_KEY_CODE; // Net vaut 1
  KeysPressed[2] := Ord(KeyStroke) = MAIL_KEY_CODE; // Mail vaut 2
  KeysPressed[3] := Ord(KeyStroke) = USER_KEY_CODE; // User vaut 3
  KeysPressed[4] := (KeyState[VK_CONTROL] and $80) = 128; // Ctrl vaut 10
  KeysPressed[5] := (GetKeyState(VK_LSHIFT) and $80) = 128; // MAJ Gauche vaut 30
  KeysPressed[6] := (GetKeyState(VK_RSHIFT) and $80) = 128;// MAJ Droite vaut 50

  //MessageBoxA(0, PChar(IntToStr(GetAsyncKeyState(VK_CONTROL) and $8000)), '', 0);

  {MessageBoxA(0, PChar('CTRL : ' + IntToStr(KeyState[VK_CONTROL]) + ' | ALT : '
    + IntToStr(KeyState[VK_MENU]) + ' | SHIFT : ' + IntToStr(KeyState[VK_SHIFT])
    + ' ||| NET : ' + BoolToStr(KeysPressed[1], True)
    + ' | MAIL : ' + BoolToStr(KeysPressed[2], True)
    + ' | USER : ' + BoolToStr(KeysPressed[3], True)), 'X', 0);}

  _keys_int_codes := 0;
  for i := Low(KeysPressed) to High(KeysPressed) do // pour les 6 touches
    if KeysPressed[i] then _keys_int_codes := _keys_int_codes + KEYS_VALUES[i]; //KEYS_VALUES donne la valeur de la touche

  Result := TKeysPressed(_keys_int_codes); // la somme donne la position dans l'enum : et donc les touches pressées.
end;

//------------------------------------------------------------------------------

function KeyHookFunc(Code, VirtualKey, KeyStroke: Integer): LRESULT; stdcall;
var 
  KeyState1: TKeyBoardState;
  _keys_pressed : TKeysPressed;
  
begin 
  Result := 0; 
  if Code = HC_NOREMOVE then Exit; 
  Result := CallNextHookEx(hKeyHook, Code, VirtualKey, KeyStroke); 
  {I moved the CallNextHookEx up here but if you want to block 
   or change any keys then move it back down} 
  if Code < 0 then 
    Exit;

  if Code = HC_ACTION then 
  begin 

    if ((KeyStroke and (1 shl 30)) <> 0) then
      if not IsWindow(hApp) then 
      begin
       //I moved the OpenFileMapping up here so it would not be opened
       // unless the app the DLL is attatched to gets some Key messages
        hMemFile  := OpenFileMapping(FILE_MAP_WRITE, False, 'Global7v9k');
        PHookRec1 := MapViewOfFile(hMemFile, FILE_MAP_WRITE, 0, 0, 0); 
        if PHookRec1 <> nil then
          hApp  := PHookRec1.AppHnd;
      end;
       
    if ((KeyStroke and (1 shl 30)) <> 0) then
    begin
      GetKeyboardState(KeyState1);
      _keys_pressed := GetKeysPressed(KeyStroke, KeyState1);
      PostMessage(hApp, WM_SENS_KEYB, Integer(_keys_pressed), 0);
      //messageboxa(0, pchar(inttostr(hApp)), '', 0);
    end;
    
  end; 
end; 

//------------------------------------------------------------------------------

function StartHook(AppHandle: HWND): Byte; export; 
begin 
  Result := 0; 
  if Hooked then 
  begin 
    Result := 1; 
    Exit; 
  end; 

  {if not IsWindow(MemoHandle) then
  begin
    Result := 4;
    Exit;
  end;}

  hKeyHook := SetWindowsHookEx(WH_KEYBOARD, KeyHookFunc, hInstance, 0); 
  if hKeyHook > 0 then 
  begin 
    {you need to use a mapped file because this DLL attatches to every app 
     that gets windows messages when it's hooked, and you can't get info except 
     through a Globally avaiable Mapped file} 
    hMemFile := CreateFileMapping($FFFFFFFF, // $FFFFFFFF gets a page memory file 
      nil,                // no security attributes 
      PAGE_READWRITE,     // read/write access 
      0,                  // size: high 32-bits 
      SizeOf(THookRec),   // size: low 32-bits 
      //SizeOf(Integer), 
      'Global7v9k');    // name of map object 
    PHookRec1 := MapViewOfFile(hMemFile, FILE_MAP_WRITE, 0, 0, 0); 
    //hMemo := MemoHandle;
    //PHookRec1.MemoHnd := MemoHandle; 
    hApp := AppHandle; 
    PHookRec1.AppHnd := AppHandle; 
    {set the Memo and App handles to the mapped file} 
    Hooked := True; 
  end 
  else 
    Result := 2; 
end; 

//------------------------------------------------------------------------------

function StopHook: Boolean; export; 
begin 
  if PHookRec1 <> nil then 
  begin 
    UnmapViewOfFile(PHookRec1); 
    CloseHandle(hMemFile); 
    PHookRec1 := nil; 
  end; 
  if Hooked then 
    Result := UnhookWindowsHookEx(hKeyHook) 
  else 
    Result := True; 
  Hooked := False; 
end; 

//------------------------------------------------------------------------------

procedure EntryProc(dwReason: DWORD); 
begin 
  if (dwReason = Dll_Process_Detach) then 
  begin 
    if PHookRec1 <> nil then 
    begin 
      UnmapViewOfFile(PHookRec1); 
      CloseHandle(hMemFile); 
    end; 
    UnhookWindowsHookEx(hKeyHook); 
  end; 
end; 

//------------------------------------------------------------------------------

exports 
  StartHook, 
  StopHook; 

//------------------------------------------------------------------------------

begin 
  PHookRec1 := nil; 
  Hooked := False; 
  hKeyHook := 0; 
  //hMemo := 0; 
  DLLProc := @EntryProc; 
  EntryProc(Dll_Process_Attach); 
end. 
