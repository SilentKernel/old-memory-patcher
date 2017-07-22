{ 
    Ten year old sourcecode (in 2017)
    Only for learning purpose, don't make something stupide with this SourceCode
}

library dsmp;

{$R DSMP.res}
uses Windows,GameInjector;

const
Bytesize = 6;
NbrFonction = 2;

var
FnIsAppSubscribed:pointer;
FnIsSubscribed:pointer;
BackUp:Array[1..NbrFonction] of pointer;


///// PATCHED FUNCTION

type
  pFakeSteamError = ^TFakeSteamError;
  TFakeSteamError = packed record
    f1,f2,f3: Integer;
    f4: array[0..254] of char;
  end;


procedure JIsAppSubscribed;
asm jmp FnIsAppSubscribed
end;

procedure JIsSubscribed;
asm jmp FnIsSubscribed
end;


function SteamIsSubscribed(uSubscriptionId: LongWord; pbIsSubscribed, pReserved: pInteger; pError: pFakeSteamError): Integer; cdecl;
var null: Integer;
begin
null := 0;

  if pError <> nil then
  begin
  with pError^ do
  begin
    f1 := null;
    f2 := null;
    f3 := null;
    f4[0] := char(null);
  end;
  end;

  if pReserved  <> nil then pReserved^ := null;

    if pbIsSubscribed <> nil then begin
    if uSubscriptionId = 61 then
    pbIsSubscribed^ := 1
    else pbIsSubscribed^ := null;
    end;

  Result := 1;
end;

function SteamIsAppSubscribed(uAppId: LongWord; pbIsSubscribed, pReserved: pInteger; pError: pFakeSteamError): Integer; cdecl;
var null: Integer;
begin
  null := 0;


  if pError <> nil then
  begin
  with pError^ do
  begin
    f1 := null;
    f2 := null;
    f3 := null;
    f4[0] := char(null);
  end;
  end;

  if pReserved <> nil then  pReserved^ := null;

  if pbIsSubscribed <> nil then  pbIsSubscribed^ := 1;

  Result := 1;
end;

/// END OF PATCHED FUNCTION.

function PatchFunction(destAddress:pointer;srcAddress:pointer;dwsize:cardinal;backup:pointer):bool;
var
retval:bool;
oldProtect:cardinal;
begin
if (destAddress <> nil) and (srcAddress <> nil) then
  begin
  retval := VirtualProtect(destAddress, dwSize, PAGE_EXECUTE_READWRITE,@oldProtect);
  if backup <> nil then
  CopyMemory(Backup,destAddress,dwSize);
  CopyMemory(destAddress, srcAddress, dwSize);
  VirtualProtect(destAddress, dwSize, oldProtect ,oldProtect);
  end
else
retval := false;

result := retval;

end;

var
     ThreadID  : DWORD      ;  // Thread ID du nouveau thread.
     hThread   : THANDLE     ;  // Handle sur le nouveau thread.
     ProcStatus : bool = false;
Function MyThreadProc ( lpParam : Pointer ) : LongWord ; stdcall ;
Var
   windowfound, lastwindow:thandle;
   ProcessPID:Integer;
Begin
windowfound := 0;
lastwindow := 0;

if (lastwindow = 0) and (windowfound = 0)then
begin

repeat
sleep(500);
windowfound := findwindow(nil, 'Counter-Strike Source');
if (windowfound <> 0) and (lastwindow <> windowfound) then
begin
lastwindow := windowfound;
GetWindowThreadProcessId(windowfound, @ProcessPID);
InjectDLLInGame(ProcessPID);
end;
until ProcStatus;

end;
result := 1;
Exit;
End;

procedure Main( Reason : Integer ) ;
Var
hModuleSteam:thandle;
SteamAdress:Array[1..NbrFonction] of pointer;
LocalAdress:Array[1..NbrFonction] of pointer;
i:integer;
begin

  case reason of

    DLL_PROCESS_DETACH: // DLL Se ferme
    begin
     hModuleSteam := GetModuleHandleA('Steam.dll');
      if hModuleSteam <> 0 then
        begin

          if (pos('Steam.exe',getcommandline) <> 0 ) or (pos('steam.exe',getcommandline) <> 0 ) then
           begin
              ProcStatus := false;
              closehandle(hThread);
          end;

          SteamAdress[1] := GetProcAddress(hModuleSteam, 'SteamIsAppSubscribed');
          SteamAdress[2] := GetProcAddress(hModuleSteam, 'SteamIsSubscribed');

             for i:=1 to NbrFonction do
             begin
                 PatchFunction(SteamAdress[i],Backup[i], Bytesize, nil);
                 Freemem(Backup[i], Bytesize);
             end;


        end;
    end;

    DLL_PROCESS_ATTACH: // DLL Se lance
    begin

    hModuleSteam := GetModuleHandleA('Steam.dll');

        if hModuleSteam <> 0 then
        begin

          FnIsAppSubscribed := @SteamIsAppSubscribed;
          FnIsSubscribed := @SteamIsSubscribed;

          SteamAdress[1] := GetProcAddress(hModuleSteam, 'SteamIsAppSubscribed');
          SteamAdress[2] := GetProcAddress(hModuleSteam, 'SteamIsSubscribed');

          LocalAdress[1] := @JIsAppSubscribed;
          LocalAdress[2] := @JIsSubscribed;

            for i:=1 to NbrFonction do
             begin
              GetMem(Backup[i], Bytesize);
                  if not PatchFunction(SteamAdress[i],LocalAdress[i], Bytesize, Backup[i]) then
                  begin
                  PatchFunction(SteamAdress[i],Backup[i], Bytesize, nil)
                  end;
            end;

        end;

              if (pos('Steam.exe',getcommandline) <> 0 ) or (pos('steam.exe',getcommandline) <> 0 ) then
                begin
                      hThread:=CreateThread(Nil,0,@MyThreadProc,nil,0,ThreadID);
                end;


    end;

  end;

end;

{ *******************
  *** Entry Point ***
  ******************* }

begin
   DllProc := @Main;
   DllProc(DLL_PROCESS_ATTACH) ;
end.
