{ 
    Ten year old sourcecode (in 2017)
    Only for learning purpose, don't make something stupide with this SourceCode
}


unit GameInjector;

interface

uses Windows;

function InjectDLLInGame(ProcessPID:integer) : Boolean;

const
DLLSource = 'DSMP.dll';

implementation


function InjectDLLInGame(ProcessPID:integer) : Boolean;
var
    LibName     : Pointer;
    hProcess    : THandle;
    ThreadHandle: THandle;
    OctEcrit    : Cardinal;
    TheadID     : DWORD;
begin
    Result := False;


    hProcess := OpenProcess( PROCESS_ALL_ACCESS, FALSE, ProcessPID);
    if (hProcess = 0) then Exit;
    LibName := VirtualAllocEx( hProcess, nil, Length(DLLSource) + 1, MEM_COMMIT, PAGE_READWRITE );
    if ( LibName <> nil ) then
    begin
      WriteProcessMemory( hProcess, LibName, PChar(DLLSource), Length(DLLSource) + 1, OctEcrit );
      if ( (Length(DLLSource) + 1) <> OctEcrit ) then Exit;
      ThreadHandle := CreateRemoteThread( hProcess, nil, 0, GetProcAddress( LoadLibrary('kernel32.dll'), 'LoadLibraryA' ), LibName, 0, TheadID );
      Result := ( ThreadHandle <> 0 );
      WaitForSingleObject( ThreadHandle, INFINITE );
    end else Result := False;
    VirtualFreeEx( hProcess, LibName, 0, MEM_RELEASE );
    CloseHandle( hProcess );
end;


end.
