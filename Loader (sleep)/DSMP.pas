{ 
    Ten year old sourcecode (in 2017)
    Only for learning purpose, don't make something stupide with this SourceCode
}

unit DSMP;

interface

uses Windows;

function InjectDLL(hProcess:THandle) : Boolean;


const
PatchDll = 'DSMP.dll';
implementation


function InjectDLL(hProcess:THandle) : Boolean;
var
    LibName     : Pointer;
    ThreadHandle: THandle;
    OctEcrit    : Cardinal;
    TheadID     : DWORD;
begin

    Result := False;
   // if debug then
   // AjustePrivileges; // Ajuste les privilèges en Debug (plus de droit)

    // on ouvre le processus cible
    if (hProcess = 0) then Exit;

    // on alloue de la place dans le processus pour la DLL
    LibName := VirtualAllocEx( hProcess, nil, Length(PatchDll) + 1, MEM_COMMIT, PAGE_READWRITE );
    if ( LibName <> nil ) then
    begin
      // on map le contenu de la DLL dans la mémoire allouée
      WriteProcessMemory( hProcess, LibName, PChar(PatchDll), Length(PatchDll) + 1, OctEcrit );
      // On verifie que toute la DLL à bien été écrite !
      if ( (Length(PatchDll) + 1) <> OctEcrit ) then Exit;
      // Puis on charge la librairie dynamiquement avec l'API LoadLibrairie depuis le process
      ThreadHandle := CreateRemoteThread( hProcess, nil, 0, GetProcAddress( LoadLibrary('kernel32.dll'), 'LoadLibraryA' ), LibName, 0, TheadID );
      Result := ( ThreadHandle <> 0 );
      WaitForSingleObject( ThreadHandle, INFINITE );
    end else Result := False;
    VirtualFreeEx( hProcess, LibName, 0, MEM_RELEASE );
    CloseHandle( hProcess );
end;







end.
