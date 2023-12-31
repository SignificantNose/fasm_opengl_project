        format PE GUI 5.0
        entry WinMain

        include '..\INCLUDE\win32ax.inc'

        include '..\INCLUDE\api\kernel32.inc'
        include '..\INCLUDE\api\user32.inc'
        include '..\INCLUDE\api\gdi32.inc'
        include '..\INCLUDE\api\opengl.inc'

; sound structs
        include 'D_STRUCTS\SOUND_structs\TRACK_structs.inc'
        include 'D_structs\SOUND_structs\SOUNDFX_structs.inc'
        include 'D_STRUCTS\SOUND_structs\SOUND_structs.inc'
        include 'D_STRUCTS\SOUND_structs\LFO_structs.inc'
        include 'D_STRUCTS\SOUND_structs\SOUNDMSG_structs.inc'
        include 'D_STRUCTS\SOUND_structs\SEQUENCER_structs.inc'
        include 'D_STRUCTS\SOUND_structs\FILTER_structs.inc'
        include 'D_STRUCTS\SOUND_structs\REVERB_structs.inc'

; notes
        include 'D_resources\NOTES.inc'

; scene tracks data
        include 'D_resources\D_scenetracks\ST_START.inc'
        include 'D_resources\D_scenetracks\ST_CHOICE.inc'        
        include 'D_resources\D_scenetracks\ST_RUNNERFIRST.inc'
        include 'D_resources\D_scenetracks\ST_RUNNERSECOND.inc'
        include 'D_resources\D_scenetracks\ST_RUNNERTHIRD.inc'
        include 'D_resources\D_scenetracks\ST_AFTERRUN.inc'
        include 'D_resources\D_scenetracks\ST_PRERUN.inc'
        include 'D_resources\D_scenetracks\ST_FINAl.inc'
        include 'D_resources\D_scenetracks\ST_CRASH.inc'
        include 'D_resources\D_scenetracks\ST_DEATH.inc'

        include 'D_STRUCTS\DEBUG_structs.inc'
        include 'D_structs\VECTOR_structs.inc'
        include 'D_structs\MATRIX_structs.inc'
        include 'D_structs\SMOOTH_structs.inc'
        include 'D_structs\MESH_structs.inc'
        include 'D_structs\GLEXT_structs.inc'
        include 'D_structs\DRAW_structs.inc'
        include 'D_structs\FILE_structs.inc'
        include 'D_structs\RANDOM_structs.inc'
        include 'D_structs\BUILD_structs.inc'
        include 'D_STRUCTS\MEMORY_structs.inc'
        include 'D_STRUCTS\TEXTURE_structs.inc'
        include 'D_STRUCTS\THREADS_structs.inc'
        include 'D_STRUCTS\KEYBOARD_structs.inc'
        include 'D_structs\INIT_structs.inc'
        include 'D_structs\SCENE_structs\MOVEMENT_structs.inc'
        include 'D_STRUCTS\SCENE_structs\CAMERA_structs.inc'
        include 'D_STRUCTS\SCENE_structs\SCENE_structs.inc'
        include 'D_STRUCTS\SCENE_structs\RUNNER_structs.inc'
        include 'D_STRUCTS\SCENE_structs\CHOICE_structs.inc'
        include 'D_STRUCTS\SCENE_structs\SPECTATOR_structs.inc'

; graphic primitives
        include 'D_resources\D_objects\PLANE.inc'
        include 'D_resources\D_objects\ROADS.inc'
        include 'D_resources\D_objects\TOWNS.inc'
        include 'D_resources\D_objects\TOWERS.inc'
        include 'D_resources\D_objects\CROSSROADS.inc'


; CONST
true            =       1
false           =       0
COLOR_DEPTH     =       24
PFD_FLAGS       =       PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or PFD_DRAW_TO_WINDOW
WINDOW_STYLE    =       WS_VISIBLE or WS_MAXIMIZE or WS_POPUP

wndClass        WNDCLASS                0, WindowProc, 0, 0, 0, 0, 0, 0, 0, className
pfd             PIXELFORMATDESCRIPTOR   sizeof.PIXELFORMATDESCRIPTOR, 1, PFD_FLAGS,\
                                                PFD_TYPE_RGBA, COLOR_DEPTH,\
                                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\
                                                COLOR_DEPTH, 0, 0, PFD_MAIN_PLANE, 0,\
                                                PFD_MAIN_PLANE
; CONST END

macro JumpIf value, label
{
        cmp     eax, value
        je      label
}


; macro for comparing 2 top values on the FPU stack
macro FPU_CMP
{
        fcomip  st0, st1
        fstp    st0
}

macro push_st0                  ; 4 B          #REMEMBER: IT AFFECTS STACK
{
        push eax
        fstp dword[esp]
}

macro FPU_LD reg                ; 4 B          #REMEMBER: IT AFFECTS STACK
{
        push reg
        fld  dword[esp]
}

macro FPU_ILD reg
{
        push reg
        fild dword[esp]
}

macro FPU_STP reg               ; 4 B          #REMEMBER: IT AFFECTS STACK
{
        fstp dword[esp]
        pop reg
}

macro FPU_ISTP reg
{
        fistp dword[esp]
        pop reg
}



data import
        library kernel32, 'kernel32.dll',\
                gdi32,    'gdi32.dll',\
                user32,   'user32.dll',\
                opengl32, 'opengl32.dll',\
                dsound, 'dsound.dll'
        
        import dsound,\
               DirectSoundCaptureCreate,'DirectSoundCaptureCreate',\
               DirectSoundCaptureCreate8,'DirectSoundCaptureCreate8',\
               DirectSoundCaptureEnumerate ,'DirectSoundCaptureEnumerateA',\
               DirectSoundCreate,'DirectSoundCreate',\
               DirectSoundCreate8,'DirectSoundCreate8',\
               DirectSoundEnumerate ,'DirectSoundEnumerateA',\
               DirectSoundFullDuplexCreate,'DirectSoundFullDuplexCreate',\
               DllCanUnloadNow,'DllCanUnloadNow',\
               DllGetClassObject,'DllGetClassObject',\
               GetDeviceID,'GetDeviceID'       

        interface IDirectSound8,\
                  QueryInterface,\
                  AddRef,\
                  Release,\
                  CreateSoundBuffer,\
                  GetCaps,\
                  DuplicateSoundBuffer,\
                  SetCooperativeLevel,\
                  Compact,\
                  GetSpeakerConfig,\
                  SetSpeakerConfig,\
                  Initialize,\
                  VerifyCertification

        interface IDirectSoundBuffer,\
                  QueryInterface,\
                  AddRef,\
                  Release,\
                  GetCaps,\
                  GetCurrentPosition,\
                  GetFormat,\
                  GetVolume,\
                  GetPan,\
                  GetFrequency,\
                  GetStatus,\
                  Initialize,\
                  Lock,\
                  Play,\
                  SetCurrentPosition,\
                  SetFormat,\
                  SetVolume,\
                  SetPan,\
                  SetFrequency,\
                  Stop,\
                  Unlock,\
                  Restore

        interface IDirectSoundBuffer8,\
                  QueryInterface,\
                  AddRef,\
                  Release,\
                  GetCaps,\
                  GetCurrentPosition,\
                  GetFormat,\
                  GetVolume,\
                  GetPan,\
                  GetFrequency,\
                  GetStatus,\
                  Initialize,\
                  Lock,\
                  Play,\
                  SetCurrentPosition,\
                  SetFormat,\
                  SetVolume,\
                  SetPan,\
                  SetFrequency,\
                  Stop,\
                  Unlock,\
                  Restore,\
                  SetFX,\
                  AcquireResources,\
                  GetObjectInPath
        interface IDirectSoundNotify,\
                  QueryInterface,\
                  AddRef,\
                  Release,\
                  SetNotificationPositions 
end data

