unit dllcalls;

interface

uses
  Windows;

function StartHook(AppHandle: HWND): Byte; external 'keybhook.dll';
function StopHook: Boolean; external 'keybhook.dll';

implementation

end.
