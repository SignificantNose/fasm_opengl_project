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
light0Position  Vector4         0.0, 3.0, 0.0, 1.0
light0Ambient   ColorRGBA       0.2, 0.0, 0.0, 0.0
light0Diffuse   ColorRGBA       10.0, 10.0, 10.0, 1.0
light0Specular  ColorRGBA       0.0, 0.0, 0.0, 1.0

light1Position  Vector4         0.0, 2.1, 0.0, 1.0
light1Diffuse   ColorRGBA       1.0, 0.0, 0.0, 1.0


startTime       dd              ?
lastTime        dd              ?
currentTime     dd              ?
programTime     dd              ?
angle           GLfloat      0.0
step            GLfloat      3.14
length          GLfloat      6.0
oneSecond       GLfloat      1000.0


cubeMesh        PackedMesh    cubeVertices, cubeColors, cubeIndices, CUBE_TRIANGLES_COUNT
cube            Mesh    0,0,0,0
plane           Mesh    planeVertices, planeColors, 0, PLANE_VERTICES_COUNT
MyBuilding      PackedMesh    0,0,0,0
Building        Mesh          0,0,0,0
seed            dd            ?


planeTransform  Transform       <0.0, -1.0, 0.0>,\
                                <0.0, 0.0, 0.0>,\
                                <1.0, 1.0, 1.0>

cubeTransform   Transform       <0.0, 0.0, 0.0>,\
                                <0.0, 0.0, 0.0>,\
                                <1.0, 1.0, 1.0>

cubePosition1   Vector3         0.0, 0.0, 1.0
cubeDirection1  Vector3         3.0, 0.0, 1.0
cubeDirection2  Vector3         -3.0, 0.0, -1.0
cubePosition2   Vector3         0.0, 0.0, -1.0

cubePrev1  Vector3               -3.0, 0.0, 1.0
cubePrev2  Vector3               3.0, 0.0, -1.0

cameraPosition1 Vector3         5.0, 5.0, 0.0
cameraDirPrev1  Vector3         5.0, 5.0, 6.66
cameraDirNext1  Vector3         5.0, 5.0, -6.66

cameraPosition2 Vector3         -5.0, 5.0, 0.0
cameraDirPrev2  Vector3         -5.0, 5.0, -6.66
cameraDirNext2  Vector3         -5.0, 5.0, 6.66

cameraPosition  Vector3         10.0, 10.0, 10.0
targetPosition  Vector3         0.0, 0.0, 0.0
upVector        Vector3         0.0, 1.0, 0.0

cubePoints:     Spline.Point    cubePosition1, cubePrev1, cubeDirection1, 1.0
                Spline.Point    cubePosition2, cubePrev2, cubeDirection2, 2.0

cubeSpline      Spline          2, cubePoints, false, 3.0

cameraPoints:   Spline.Point    cameraPosition1, cameraDirPrev1, cameraDirNext1, 5.0
                Spline.Point    cameraPosition2, cameraDirPrev2, cameraDirNext2, 5.0

cameraSpline    Spline          2, cameraPoints, true, 10.0




fragmentShader  GLuint          0
program         GLint           0

timeLocation    GLint           0
sizeLocation    GLint           0

shaderFile      db              "fragment.glsl", 0
timeName        db              "time", 0
sizeName        db              "size", 0

        include 'D_code\MESH_code.asm'
        include 'D_code\VECTOR_code.asm'
        include 'D_code\MATRIX_code.asm'
        include 'D_code\INIT_code.asm'
        include 'D_code\SMOOTH_code.asm'
        include 'D_code\MOVEMENT_code.asm'
        include 'D_code\DRAW_code.asm'
        include 'D_code\GLEXT_code.asm'
        include 'D_code\FILE_code.asm'
        include 'D_code\RANDOM_code.asm'
        include 'D_code\BUILD_code.asm'

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

     invoke     DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
     jmp        .Return

.Paint:
     stdcall    Draw
     jmp        .ReturnZero
.KeyDown:
     cmp        [wParam], VK_ESCAPE
     jne        .ReturnZero
.Destroy:
     invoke     ExitProcess, ebx
.ReturnZero:
     xor    eax, eax
.Return:
     ret
endp
