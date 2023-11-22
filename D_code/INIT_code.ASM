proc Init uses esi
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


;; initializing the matrices
;     fild        [clientRect.right]             ; width
;     fidiv       [clientRect.bottom]            ; width/height
;     fstp        [aspect]                       ;
;
;     invoke      glMatrixMode, GL_PROJECTION
;     invoke      glLoadIdentity
;     stdcall     Matrix.Projection, [aspect], [fovY], [zNear], [zFar]
;
;; setting some things up
;     invoke      glEnable, GL_DEPTH_TEST
;     invoke      glShadeModel, GL_SMOOTH
;     invoke      glHint, GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST
;
;
;     ;invoke      HeapAlloc, [hHeap], 8, sizeof.Vertex * 8             ; trying; seeing what will happen if we load the colors to the figure and add the lights
;     ;mov         [cubeMesh.colors], eax
;
;     invoke      HeapAlloc, [hHeap], ebx, sizeof.Vertex * 6
;     mov         [plane.normals], eax
;
;     stdcall     Mesh.Generate, cubeMesh, cube, true
;     stdcall     Mesh.CalculateNormals, cube
;     stdcall     Mesh.CalculateNormals, plane
;
;
;     stdcall     Build.GeneratePackedTower, PackedTower, nullVector, 2.0
;     ;mov         eax, [MyBuilding.vertices]
;     ;mov         [cubeMesh.vertices], eax
;     ;mov         eax, [MyBuilding.indices]
;     ;mov         [cubeMesh.indices], eax
;     ;mov         eax, [MyBuilding.trianglesCount]
;     ;mov         [cubeMesh.trianglesCount], eax
;     ;stdcall     Mesh.Generate, cubeMesh, cube, true
;     stdcall     Mesh.Generate, PackedTower, Tower, true
;     stdcall     Mesh.CalculateNormals, Tower
;
;     stdcall     Build.GenerateTown, 3, 3, 1.0, MyTown
;
;     ;stdcall     Mesh.CalculateNormals, cube


     
     stdcall Glext.LoadFunctions
     stdcall Glext.InitShaders

     ;invoke     glEnable, GL_TEXTURE_2D
     invoke     glGenVertexArrays, 1, VAO
     invoke     glGenBuffers, 1, VBO
     invoke     glGenBuffers, 1, EBO

     ; SET the vertex array
     invoke     glBindVertexArray, [VAO]

     ; bind the buffer so that the bufferdata call can be made to the currently bound VBO
     invoke     glBindBuffer, GL_ARRAY_BUFFER, [VBO]
     ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     invoke     glBufferData, GL_ARRAY_BUFFER, sizeofPrimitiveVertices, myPrimitiveVertices, GL_STATIC_DRAW
     
     invoke     glBindBuffer, GL_ELEMENT_ARRAY_BUFFER, [EBO]
     ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     invoke     glBufferData, GL_ELEMENT_ARRAY_BUFFER, sizeofPrimitiveIndices, myPrimitiveIndices, GL_STATIC_DRAW


     ; binding the attribute for a vertex
     invoke     glVertexAttribPointer, 0, 3, GL_FLOAT, GL_FALSE, 8*4, 0
     
     ; enabling the bound attribute
     invoke     glEnableVertexAttribArray, 0
     
     invoke     glVertexAttribPointer, 1, 3, GL_FLOAT, GL_FALSE, 8*4, 3*4
     invoke     glEnableVertexAttribArray, 1

     invoke     glVertexAttribPointer, 2, 2, GL_FLOAT, GL_FALSE, 8*4, 6*4
     invoke     glEnableVertexAttribArray, 2


     ;lea        eax, [textureNeonID]
     ;stdcall    Texture.LoadTexture, textureNeonPath, eax
     stdcall    Texture.LoadTexture, textureNeonPath, textureNeonID

     ; reset the currently bound buffers
     invoke     glBindBuffer, GL_ARRAY_BUFFER, 0
     invoke     glBindVertexArray, 0

     ;stdcall Sound.init

;     ;stdcall     Subdivide, mesh, mesh
;     invoke  glEnable, GL_LIGHTING
;     invoke  glEnable, GL_LIGHT0
;     invoke  glLightfv, GL_LIGHT0, GL_DIFFUSE, light0Diffuse
;     ;invoke     glLightfv, GL_LIGHT0, GL_POSITION, light0Position
;     invoke  glLightfv, GL_LIGHT0, GL_AMBIENT, light0Ambient
;     ;invoke  glLightfv, GL_LIGHT0, GL_SPECULAR, light0Specular
;
;     ;invoke  glEnable, GL_LIGHT1
;     ;invoke  glLightfv, GL_LIGHT1, GL_DIFFUSE, light1Diffuse

     ret
endp