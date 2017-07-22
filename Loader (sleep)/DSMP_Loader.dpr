{ 
    Ten year old sourcecode (in 2017)
    Only for learning purpose, don't make something stupide with this SourceCode
}

program DSMP_Loader;

//{$APPTYPE CONSOLE}
{$R CSSLAUNCHER.res}


uses
Windows, shellapi, DSMP, TlHelp32, SysUtils;

function ProgEnCours(NomProg:string):boolean;
var
LPPE : TProcessEntry32;
H      : Thandle;

begin
  result := false;
  h:=CreateToolhelp32Snapshot(TH32CS_SNAPALL ,0);
  Lppe.DwSize:=Sizeof(TProcessEntry32);
  if Process32First(h,lppe)
  then
  Begin;
    if (ExtractFileName(LPPE.szexefile))= (NomProg) then result:=true;
    while Process32next(h,lppe) do
    begin
      if (ExtractFileName(LPPE.szexefile))= (NomProg) then result:=true;
    end;
  End;
  Closehandle(h);
end;

var
ShExecInfo : TShellExecuteInfo;
Patched:bool=false;
begin

if (not ProgEnCours('Steam.exe')) and (not ProgEnCours('steam.exe')) then
begin
  with ShExecInfo do begin
        cbSize := SizeOf(ShExecInfo);
        fMask  := SEE_MASK_NOCLOSEPROCESS;
        lpFile := 'Steam.exe';      { le nom du programme }
        lpVerb := 'open';
        nShow  := SW_NORMAL;
  end;

  If ShellExecuteEx(@ShExecInfo) Then
  Begin
  sleep(1000);
  if InjectDll(ShExecInfo.hProcess) then
  Patched:=true;

  end;



end;


end.
