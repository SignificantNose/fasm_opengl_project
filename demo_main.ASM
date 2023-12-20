include 'demo_importHeader.inc'


className       db      "OpenGLDemo", 0
clientRect      RECT
hdc             dd      ?
hdcBack         dd      ?
hHeap           dd      ?

radian          dd      57.32
fovY            dd      60.0
zNear           dd      0.001
zFar            dd      1000.0




myCutout        dd              40.0
spotdir         Vector3         0.0,0.0,0.0
light0Position  Vector4         5.0, 5.0, 5.0, 1.0
light0Ambient   ColorRGBA       0.2, 0.2, 0.2, 0.0
light0Diffuse   ColorRGBA       1.0, 1.0, 1.0, 1.0
light0Specular  ColorRGBA       0.0, 0.0, 0.0, 1.0

light1Position  Vector4         0.0, 2.1, 0.0, 1.0
light1Diffuse   ColorRGBA       1.0, 0.0, 0.0, 1.0

BuildDiffuse    ColorRGBA       0.3, 0.3, 0.3, 1.0
BuildAmbient    ColorRGBA       0.2, 0.2, 0.2, 1.0
PlaneDiffuse    ColorRGBA       0.0, 0.0, 0.0, 1.0
PlaneAmbient    ColorRGBA       0.0, 0.3, 0.0, 1.0


lastBufferTime  dd              0.0
currentTime     dd              0.0
; programTime     dd              0.0
angle           GLfloat      0.0
step            GLfloat      3.14
length          GLfloat      6.0
oneSecond       GLfloat      1000.0
PlayBuffer      IDirectSoundBuffer8
SFXBuffer       IDirectSoundBuffer8
amntOfLives     db             ?



seed            dd            ?
RandomValue     dd            0


; planeTransform  Transform       <0.0, -1.0, 0.0>,\
;                                 <0.0, 0.0, 0.0>,\
;                                 <1.0, 1.0, 1.0>

; cubeTransform   Transform       <0.0, 0.0, 0.0>,\
;                                 <0.0, 0.0, 0.0>,\
;                                 <1.0, 1.0, 1.0>

; cubePosition1   Vector3         0.0, 0.0, 1.0
; cubeDirection1  Vector3         3.0, 0.0, 1.0
; cubeDirection2  Vector3         -3.0, 0.0, -1.0
; cubePosition2   Vector3         0.0, 0.0, -1.0

; cubePrev1  Vector3               -3.0, 0.0, 1.0
; cubePrev2  Vector3               3.0, 0.0, -1.0

; cameraPosition1 Vector3         5.0, 5.0, 0.0
; cameraDirPrev1  Vector3         5.0, 5.0, 6.66
; cameraDirNext1  Vector3         5.0, 5.0, -6.66

; cameraPosition2 Vector3         -5.0, 5.0, 0.0
; cameraDirPrev2  Vector3         -5.0, 5.0, -6.66
; cameraDirNext2  Vector3         -5.0, 5.0, 6.66

; cameraPosition  Vector3         20.0, 20.0, 20.0
; targetPosition  Vector3         0.0, 0.0, 0.0
; upVector        Vector3         0.0, 1.0, 0.0

; nullVector      Vector3         0.0, 0.0, 0.0

; cubePoints:     Spline.Point    cubePosition1, cubePrev1, cubeDirection1, 1.0
;                 Spline.Point    cubePosition2, cubePrev2, cubeDirection2, 2.0

; cubeSpline      Spline          2, cubePoints, false, 3.0

; cameraPoints:   Spline.Point    cameraPosition1, cameraDirPrev1, cameraDirNext1, 5.0
;                 Spline.Point    cameraPosition2, cameraDirPrev2, cameraDirNext2, 5.0

; cameraSpline    Spline          2, cameraPoints, true, 10.0




; shaders data section
vertexShaderText:
                        file            "vertex.glsl"
                        db              0
        vertexShader    dd              vertexShaderText

fragmentShaderText:
                        file            "fragment.glsl"
                        db              0
        fragmentShader  dd              fragmentShaderText

shaderProgram   GLint           0
timeLocation    GLint           0
sizeLocation    GLint           0
VAO             GLuint          0
VBO             GLuint          0
EBO             GLuint          0



; legacy
;fragmentShader  GLuint          0
;program         GLint           0
;
;timeLocation    GLint           0
;sizeLocation    GLint           0
;shaderFile      db              "fragment.glsl", 0
;timeName        db              "time", 0
;sizeName        db              "size", 0

        include 'D_code\SOUND_code\TRACK_code.asm'
        include 'D_code\SOUND_code\SOUNDFX_code.asm'
        include 'D_code\SOUND_code\SOUND_code.asm'
        include 'D_code\SOUND_code\LFO_code.asm'
        include 'D_code\SOUND_code\SOUNDMSG_code.asm'
        include 'D_code\SOUND_code\SEQUENCER_code.asm'
        include 'D_code\SOUND_code\FILTER_code.asm'
        include 'D_code\SOUND_code\REVERB_code.asm'
        
        include 'D_code\DEBUG_code.asm'
        include 'D_code\VECTOR_code.asm'
        include 'D_code\MATRIX_code.asm'
        include 'D_code\SMOOTH_code.asm'
        include 'D_code\MESH_code.asm'
        include 'D_code\GLEXT_code.asm'
        include 'D_code\DRAW_code.asm'
        include 'D_code\FILE_code.asm'
        include 'D_code\RANDOM_code.asm'
        include 'D_code\BUILD_code.asm'
        include 'D_code\MEMORY_code.asm'
        include 'D_code\TEXTURE_code.asm'
        include 'D_code\THREADS_code.asm'
        include 'D_code\KEYBOARD_code.asm'
        include 'D_code\INIT_code.asm'

        include 'D_code\SCENE_code\MOVEMENT_code.asm'
        include 'D_code\SCENE_code\CAMERA_code.asm'
        include 'D_code\SCENE_code\SCENE_code.asm'
        include 'D_code\SCENE_code\RUNNER_code.asm'
        include 'D_code\SCENE_code\CHOICE_code.asm'
        include 'D_code\SCENE_code\SPECTATOR_code.asm'

proc WinMain
     locals
        msg         MSG
     endl

     xor         ebx,ebx
     stdcall     Init

     lea         esi, [msg]
.cycle:
     invoke     GetMessage, esi, ebx, ebx, ebx
     invoke     DispatchMessage, esi
     jmp        .cycle
endp




proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam

     xor        ebx, ebx
     mov        eax, [uMsg]
     JumpIf     WM_PAINT,       .Paint
     JumpIf     WM_DESTROY,     .Destroy
     JumpIf     WM_KEYDOWN,     .KeyDown
     JumpIf     WM_KEYUP,       .KeyUp
     JumpIf     WM_MOUSEMOVE,   .MouseMove

     invoke     DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
     jmp        .Return

.Paint:
     stdcall    Draw
     jmp        .ReturnZero
.KeyDown:
     cmp        [wParam], VK_ESCAPE
     je         .Destroy
     ; cmp        [wParam], VK_SPACE
     ; je         .DebugSwitchScene

     stdcall    Keyboard.KeyDown, [wParam]
     jmp        .ReturnZero

; #############
; to be removed
.KeyUp:
     stdcall    Keyboard.KeyUp, [wParam]
     jmp        .ReturnZero
; to be removed
; #############


; #############
; to be removed
.MouseMove:
     mov        eax, [currentScene]
     movzx      eax, [eax + Scene.mode]
     cmp        eax, SCENEMODE_INDEPENDENT
     jne        .ReturnZero 
     stdcall    Camera.LookAroundUpdate, [lParam]
     jmp        .ReturnZero
; to be removed
; #############
.DebugSwitchScene:
     ; invoke     SetEvent, [hEventNotify]
     mov        [currentTime], 999999.0
     jmp        .ReturnZero
.Destroy:
     ; invoke     SetEvent, [hEventTerminate]
     invoke     ExitProcess, ebx
.ReturnZero:
     xor    eax, eax
.Return:
     ret
endp

