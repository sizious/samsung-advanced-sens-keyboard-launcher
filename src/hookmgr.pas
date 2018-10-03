unit hookmgr;

interface

uses
  Windows, Forms;

function StartMonitoring() : Boolean;
procedure StopMonitoring();

implementation

uses main, dllcalls;

//------------------------------------------------------------------------------

function StartMonitoring() : Boolean;
var
  SHresult: Byte;
  
begin
  Result := False;
  SHresult := StartHook(Main_Form.Handle);

  case SHresult of
    0 : Result := True;//ShowMessage('the Key Hook was Started, good');
    1 : Main_Form.MsgBox('Error : The Key Hook was already started. Failed.', 'Error', MB_ICONERROR);
    2 : Main_Form.MsgBox('Error : The Key Hook can NOT be started ! Failed.', 'Error', MB_ICONERROR);
    //4 : ShowMessage('MemoHandle is incorrect');
  end;
end;

//------------------------------------------------------------------------------

procedure StopMonitoring();
begin
  if not StopHook() then
    Main_Form.MsgBox('Error : Hook was NOT stopped ! Please reboot your computer.', 'Error', MB_ICONERROR);
end;

//------------------------------------------------------------------------------

end.
