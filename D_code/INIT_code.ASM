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

     invoke      GetTickCount
     mov         [lastTime], eax
     mov         [startTime], eax
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
     stdcall    Texture.LoadTexture, textureNeonPath, textureNeonID, GL_BGR
     stdcall    Texture.LoadTexture, textureGroundPath, textureGroundID, GL_BGR
     stdcall    Texture.LoadTexture, textureRoadPath, textureRoadID, GL_BGR
     stdcall    Texture.LoadTexture, textureCrossroadPath, textureCrossroadID, GL_BGR

; generating meshes
     invoke     GetTickCount
     push       eax 

     ; stdcall    Build.GenerateTowerModel, towerModel
     stdcall    Build.GenerateTowerModel, towerIndicatorCenter
     stdcall    Build.GenerateCrossroad, Crossroad13
     stdcall    Build.GenerateCrossroad, Crossroad23
     stdcall    Build.GenerateCrossroad, Crossroad33   

     stdcall    Mesh.PackedMesh2Mesh, testPackedPlane, testPlane, true
     lea        eax, [planeModel+Model.meshData]
     stdcall    Mesh.Mesh2ShaderMesh, testPlane, eax, [textureGroundID]

     stdcall    Build.GenerateRoadModel, roadV13
     stdcall    Build.GenerateRoadModel, roadV23
     ; stdcall    Build.GenerateRoadModel, road11
     ; stdcall    Build.GenerateRoadModel, road12
     ; stdcall    Build.GenerateRoadModel, road13
     ; stdcall    Build.GenerateRoadModel, road14

     ; stdcall    Build.GenerateRoadModel, road21
     ; stdcall    Build.GenerateRoadModel, road22
     ; stdcall    Build.GenerateRoadModel, road23
     ; stdcall    Build.GenerateRoadModel, road24

     stdcall    Build.GenerateTown, 3, 3, 4.0, townMain

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
     invoke    GetTickCount
     push      eax 
     stdcall   Sound.init  
     cominvk   track1Buffer, Play, 0, 0, 0
     ;cominvk   track1Buffer, Stop
     ;cominvk   track2Buffer, Play, 0, 0, 0
     ;cominvk   track2Buffer, Stop
     invoke    GetTickCount
     pop       edx
     sub       eax, edx  
     stdcall   Debug.OutputTickCount, eax

     ret
endp