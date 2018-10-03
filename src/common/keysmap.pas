unit keysmap;

interface

uses
  Messages;
  
const
  WM_SENS_KEYB = WM_USER + 1678;
  
type
  TKeysPressed =  (
                    kpNet = 1,                          kpMail = 2,                         kpUser = 3,
                    kpCtrlNet = 11,                     kpCtrlMail = 12,                    kpCtrlUser = 13,
                    kpLeftShiftNet = 31,                kpLeftShiftMail = 32,               kpLeftShiftUser = 33,
                    kpRightShiftNet = 51,               kpRightShiftMail = 52,              kpRightShiftUser = 53,
                    kpCtrlLeftShiftNet = 41,            kpCtrlLeftShiftMail = 42,           kpCtrlLeftShiftUser = 43,
                    kpCtrlRightShiftNet = 61,           kpCtrlRightShiftMail = 62,          kpCtrlRightShiftUser = 63,
                    kpRightShiftLeftShiftNet = 81,      kpRightShiftLeftShiftMail = 82,     kpRightShiftLeftShiftUser = 83,
                    kpCtrlLeftShiftRightShiftNet = 91,  kpCtrlLeftShiftRightShiftMail = 92, kpCtrlLeftShiftRightShiftUser = 93
                  );

implementation

end.
