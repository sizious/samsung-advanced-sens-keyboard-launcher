unit config;

interface

uses
  Windows, SysUtils, StdCtrls, XMLDoc, XMLIntf, Forms, Registry, PiconeBarreTache;

function GetConfigFileName: TFileName;
function IsSetToRunAtStartup : Boolean;
procedure LoadConfig;
procedure SaveConfig;
function SetToRunAtStartup(Activate : Boolean) : Boolean;

//------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------

uses main, uilang;

var
  ConfigFileName: TFileName;
  
//------------------------------------------------------------------------------

function GetConfigFileName: TFileName;
begin
  Result := ConfigFileName;
end;

//------------------------------------------------------------------------------

procedure SaveConfig;
var
  _node1, _node2, _node3 : IXMLNode;  //Noeuds de référence
  XMLDoc : TXMLDocument;
  i : Integer;
  
begin
  //Création du premier noeud 'stages' et initialisation de DocumentElement
  XMLDoc := TXMLDocument.Create(Application);
  try
    XMLDoc.Active := True;
    XMLDoc.Options := [doNodeAutoIndent];
    
    XMLDoc.DocumentElement := XMLDoc.CreateElement('config', '');

    if Assigned(Main_Form) then begin

      // applications
      _node1 := XMLDoc.DocumentElement.AddChild('applications');
      for i := 0 to Main_Form.ComponentCount - 1 do
      begin
        if Main_Form.Components[i] is TEdit then
        begin
          with (Main_Form.Components[i] as TEdit) do
          begin
            _node2 := _node1.AddChild('filename');
            _node2.Attributes['path'] := Text;
            //_node2.Attributes['id'] := Tag;
          end;
        end;
      end;

      // options
      _node1 := XMLDoc.DocumentElement.AddChild('options');
      _node2 := _node1.AddChild('close');
      _node2.Attributes['prompt'] := Main_Form.cbClosePrompt.Checked;
      _node2 := _node1.AddChild('tray');
      _node3 := _node2.AddChild('minimize');
      _node3.Attributes['intray'] := Main_Form.Picone.CacherSiMinimize;
      _node3 := _node2.AddChild('close');
      _node3.Attributes['intray'] := Main_Form.Picone.ReduireSiFin;
      _node3 := _node2.AddChild('disable');
      _node3.Attributes['intray'] := Main_Form.Picone.ReduireSiFin;
    end;

    _node1 := XMLDoc.DocumentElement.AddChild('language');
    _node1.NodeValue := LanguagePackSelected;

    XMLDoc.SaveToFile(GetConfigFileName);
  finally
    XMLDoc.Free;
  end;
end;

//------------------------------------------------------------------------------

// savoir quoi cocher dans le radio group
function PiconeConfigToInteger(Picone : TPiconeBarreTache) : Integer;
begin
  if Picone.CacherSiMinimize then
  begin
    Result := 0;
    Exit;
  end;

  if Picone.ReduireSiFin then
  begin
    Result := 1;
    Exit;
  end;
  
  Result := 2;
end;

//------------------------------------------------------------------------------

procedure LoadConfig;
var
  _node1, _node2, _node3 : IXMLNode;  //Noeuds de référence
  XMLDoc : TXMLDocument;
  i, appptr : Integer;
  
begin
  // cocher la case "Run At Startup"
  Main_Form.cbRunStartup.Checked := IsSetToRunAtStartup;
  if not FileExists(GetConfigFileName) then Exit;
  
  //Création du premier noeud 'stages' et initialisation de DocumentElement
  XMLDoc := TXMLDocument.Create(Application);
  try
    XMLDoc.Active := True;

    XMLDoc.LoadFromFile(GetConfigFileName);

    // applications
    _node1 := XMLDoc.DocumentElement.ChildNodes.FindNode('applications');
    appptr := 0;
    for i := 0 to Main_Form.ComponentCount - 1 do
    begin

      if Main_Form.Components[i] is TEdit then
      begin
        _node2 := _node1.ChildNodes.Nodes[appptr];
        with (Main_Form.Components[i] as TEdit) do
        begin
          Main_Form.ProgramsFileNames[appptr] := _node2.Attributes['path'];
          Text := _node2.Attributes['path'];
        end;
        Inc(appptr);
      end;

    end;

    // options
    _node1 := XMLDoc.DocumentElement.ChildNodes.FindNode('options');
    _node2 := _node1.ChildNodes.FindNode('close');
    Main_Form.cbClosePrompt.Checked := _node2.Attributes['prompt']; // close prompt

    // tray
    _node2 := _node1.ChildNodes.FindNode('tray');
    _node3 := _node2.ChildNodes.FindNode('minimize');
    Main_Form.Picone.CacherSiMinimize := _node3.Attributes['intray'];
    _node3 := _node2.ChildNodes.FindNode('close');
    Main_Form.Picone.ReduireSiFin := _node3.Attributes['intray'] ;
    _node3 := _node2.ChildNodes.FindNode('disable');
    Main_Form.Picone.ReduireSiFin := _node3.Attributes['intray'];
    Main_Form.rgTray.ItemIndex := PiconeConfigToInteger(Main_Form.Picone);


    _node1 := XMLDoc.DocumentElement.ChildNodes.FindNode('language');
    try
      LanguagePackSelected := _node1.NodeValue;
    except
      LanguagePackSelected := ENGLISH_DEFAULT;
    end;

    if Assigned(Main_Form) then
      Main_Form.ApplyConfig;
  finally
    XMLDoc.Free;
  end;  
end;

//------------------------------------------------------------------------------

function IsSetToRunAtStartup : Boolean;
var
  RG : TRegistry;

begin
  Result := False;

  RG := TRegistry.Create;
  try
    RG.RootKey := HKEY_LOCAL_MACHINE;
    if not RG.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', False) then Exit;
    Result := RG.ReadString(AppName) =  '"' + Application.ExeName + '" /startup';
  finally
    RG.Free;
  end;
end;

//------------------------------------------------------------------------------

function SetToRunAtStartup(Activate : Boolean) : Boolean;
var
  RG : TRegistry;

begin
  Result := False;

  RG := TRegistry.Create;
  try
    RG.RootKey := HKEY_LOCAL_MACHINE;
    if not RG.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', False) then Exit;
    if Activate then
    begin
      RG.WriteString(AppName, '"' + Application.ExeName + '" /startup');
      Result := True;
    end else Result := RG.DeleteValue(AppName);
    
  finally
    RG.Free;
  end;
end;

//------------------------------------------------------------------------------

initialization
  ConfigFileName := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))
    + 'config.xml';
  
//------------------------------------------------------------------------------

end.
