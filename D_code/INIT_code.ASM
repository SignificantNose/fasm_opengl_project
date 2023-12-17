proc Init uses esi edi
     locals
        hMainWindow dd ?
        aspect      dd ?
     endl


; acquiring the descriptor for the heap memory
     invoke      GetProcessHeap
     mov         [hHeap], eax

     invoke      RegisterClass, wndClass
     invoke      CreateWindowEx, ebx, className, className, WINDOW_STYLE,\
                             ebx, ebx, ebx, ebx, ebx, ebx, ebx, ebx
     mov         [hMainWindow], eax


; initializing important data
     invoke      GetClientRect, eax, clientRect
     invoke      ShowCursor, ebx
     ;invoke      ShowCursor, true

     ; invoke      GetTickCount
     ; mov         [lastTime], eax
     ; mov         [startTime], eax
; acquiring the device context handle
     invoke      GetDC, [hMainWindow]
     mov         [hdc], eax
; setting the pixel format
     invoke      ChoosePixelFormat, [hdc], pfd
     invoke      SetPixelFormat, [hdc], eax, pfd

; setting the render
     invoke      wglCreateContext, [hdc]
     invoke      wglMakeCurrent, [hdc], eax
     invoke      glViewport, 0, 0, [clientRect.right], [clientRect.bottom]              ; setting the render field from (0;0) to (width;height)
     

; calculating the aspect ratio of the screen
     ;mov        eax, 2.0
     ;push       eax 
     fild       [clientRect.right]      ; width
     ;fdiv       dword[esp]              ; w/2
     ;fist       word[wCenterCoordsX]
     fild       [clientRect.bottom]     ; height, w
     ;fdiv       dword[esp]              ; h/2, w/2
     ;fist       word[wCenterCoordsY]
     fdivp                              ; w/h
     fstp       [aspect]

     ;movzx      eax, word[wCenterCoordsX]
     ;movzx      edx, word[wCenterCoordsY]      
     ;invoke     SetCursorPos, eax, edx


     invoke     glEnable, GL_DEPTH_TEST
     invoke     glShadeModel, GL_SMOOTH
     invoke     glHint, GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST
     
     stdcall    Glext.LoadFunctions
     stdcall    Glext.InitShaders


; initializing textures
     stdcall    Texture.LoadTexture, textureNeonBluePath, textureNeonBlueID, GL_BGR
     stdcall    Texture.LoadTexture, textureNeonWhitePath, textureNeonWhiteID, GL_BGR 
     stdcall    Texture.LoadTexture, textureGroundPath, textureGroundID, GL_BGR
     stdcall    Texture.LoadTexture, textureRoadPath, textureRoadID, GL_BGR
     stdcall    Texture.LoadTexture, textureCrossroadPath, textureCrossroadID, GL_BGR

; generating meshes
     invoke     GetTickCount
     push       eax 

     ; stdcall    Build.GenerateTowerModel, towerModel
     ; stdcall    Build.GenerateTowerModel, towerIndicatorCenter
     stdcall    Build.GenerateLayout, 4.0, 90.0  

     stdcall    Build.ModelByTemplate, planeModel, templatePackedPlane, [textureGroundID]

     ; stdcall    Build.ModelByTemplate, roadV13, templatePackedRoad, [textureRoadID]
     ; stdcall    Build.ModelByTemplate, roadV23, templatePackedRoad, [textureRoadID]


     ; width is in direction of x
     ; stdcall    Build.GenerateTown, 13, 13, 6.92, townMain
     ; stdcall    Build.GenerateTown, 5, 5, 6.92, townM11, 6, 11
     ; stdcall    Build.GenerateTown, 5, 5, 6.92, townM12, 6, 11
     ; stdcall    Build.GenerateTown, 5, 5, 6.92, townM21, 6, 11
     ; stdcall    Build.GenerateTown, 5, 5, 6.92, townM22, 6, 11
     ; stdcall    Build.GenerateTown, 3, 4, 6.92, townS1, 2, 6
     ; stdcall    Build.GenerateTown, 3, 4, 6.92, townS2, 2, 6
     ; stdcall    Build.GenerateTown, 3, 4, 6.92, townS3, 2, 6
     ; stdcall    Build.GenerateTown, 3, 4, 6.92, townS4, 2, 6
     ; stdcall    Build.GenerateTown, 3, 3, 6.92, townL, 12, 19

     ; stdcall    Build.GenerateTown, 3, 3, 1.0, town11
     ; stdcall    Build.GenerateTown, 3, 3, 1.0, town12
     ; stdcall    Build.GenerateTown, 3, 3, 1.0, town13
 
     ; stdcall    Build.GenerateTown, 3, 3, 1.0, town21
     ; stdcall    Build.GenerateTown, 3, 3, 1.0, town22
     ; stdcall    Build.GenerateTown, 3, 3, 1.0, town23
 
     ; stdcall    Build.GenerateTown, 3, 3, 1.0, town31
     ; stdcall    Build.GenerateTown, 3, 3, 1.0, town32
     ; stdcall    Build.GenerateTown, 3, 3, 1.0, town33


     invoke     GetTickCount 
     pop        edx 
     sub        eax, edx
     stdcall    Debug.OutputTickCount, eax
     
                                   ;  program object   uniform name string
     ;invoke     glGetUniformLocation, [shaderProgram], shaderTransformName
     ;mov        [shaderTransformID], eax
;
     ;mov       [testTransform+Matrix4x4.m11], 1.0
     ;mov       [testTransform+Matrix4x4.m22], 1.0
     ;mov       [testTransform+Matrix4x4.m33], 1.0
     ;mov       [testTransform+Matrix4x4.m44], 1.0
     ;
     ;                              ; loc of the uniform     how many matrices to pass
     ;invoke    glUniformMatrix4fv, [shaderTransformID],     1,\ 
     ;                             \; transpose the matrix?  the matrix itself
     ;                              GL_FALSE,                testTransform

; initializing matrices
     invoke      glGetUniformLocation, [shaderProgram], modelMxName
     mov         [modelMxID], eax
     invoke      glGetUniformLocation, [shaderProgram], viewMxName
     mov         [viewMxID], eax
     invoke      glGetUniformLocation, [shaderProgram], projectionMxName
     mov         [projectionMxID], eax

     invoke      glMatrixMode, GL_PROJECTION
     invoke      glLoadIdentity
     stdcall     Matrix.Projection, [aspect], [fovY], [zNear], [zFar]
     invoke      glGetFloatv, GL_PROJECTION_MATRIX, projectionMx
     invoke      glUniformMatrix4fv, [projectionMxID], 1, GL_FALSE, projectionMx

     ;stdcall     Camera.NormalizeCursor, lastCursorPos
     invoke      SetCursorPos, cursorPosX, cursorPosY
     
     ; stdcall Debug.OutputValueDec, 160
     ; stdcall Debug.OutputValueHex, 160
     ; stdcall Debug.OutputValueFloat, 160.0

     ; stdcall   Threads.InitEventsAndThreads

     invoke    GetTickCount
     push      eax 
     stdcall   Sound.Init  
     stdcall   Scene.UnpackSceneTracks
     stdcall   Scene.UnpackScenes
     invoke    GetTickCount
     pop       edx
     sub       eax, edx  
     stdcall   Debug.OutputTickCount, eax


     ; invoke    SetEvent, [hEventNotify]
     stdcall   Runner.InitializeRunner, SG1_RunnerFirst_Scene, testStartingPoint, testEndingPoint
     stdcall   Choice.InitializeChoice, SG1_ChoiceFirst_Scene, 0, testStartingPoint, testEndingPoint

; it's just some buffer. can be any buffer, because
; it's only used to calculate the current time in the buffer
     mov       eax, [Scenes.SceneList + Scene.soundtrack + Track.buffer]
     mov       [PlayBuffer], eax  
     cominvk   PlayBuffer, Play, 0, 0, 0
     
     ret
endp