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


     ; generating the tower
     stdcall    Build.GeneratePackedTower, testPackedTower, 1.0
     stdcall    Mesh.PackedMesh2Mesh, testPackedTower, testTower
     stdcall    Build.DesignTower, testTower
     stdcall    Mesh.Mesh2ShaderMesh, testTower, testShaderTower

     invoke     glEnable, GL_DEPTH_TEST
     invoke     glShadeModel, GL_SMOOTH
     invoke     glHint, GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST
     
     stdcall    Glext.LoadFunctions
     stdcall    Glext.InitShaders

     ;invoke     glEnable, GL_TEXTURE_2D

                              ;    how many       pointer
     invoke     glGenVertexArrays, 1,             VAO
     invoke     glGenBuffers,      1,             VBO
     invoke     glGenBuffers,      1,             EBO

     ; SET the vertex array
     invoke     glBindVertexArray, [VAO]

     ; bind the buffer so that the bufferdata call can be made to the currently bound VBO
     invoke     glBindBuffer, GL_ARRAY_BUFFER, [VBO]
                         ;    target array obj                   size in bytes of the data     
     invoke     glBufferData, GL_ARRAY_BUFFER,                   [testShaderTower.szBufferData],\
                        \;    ptr to data                        usage pattern
                              [testShaderTower.pBufferData],     GL_STATIC_DRAW
     
;     invoke     glBindBuffer, GL_ELEMENT_ARRAY_BUFFER, [EBO]
;     invoke     glBufferData, GL_ELEMENT_ARRAY_BUFFER, [towerSizeIndices], [towerIndices], GL_STATIC_DRAW



     ; binding the attribute for a vertex
                                   ;   layout location      №of values                    type of data
     invoke     glVertexAttribPointer, 0,                   3,                            GL_FLOAT,\
                                   \;  normalize?           stride(sizeof all values)     offset
                                       GL_FALSE,            8*4,                          0     
     invoke     glEnableVertexAttribArray, 0
     

     invoke     glVertexAttribPointer, 1, 2, GL_FLOAT, GL_FALSE, 8*4, 3*4
     invoke     glEnableVertexAttribArray, 1

     invoke     glVertexAttribPointer, 2, 3, GL_FLOAT, GL_FALSE, 8*4, 5*4
     invoke     glEnableVertexAttribArray, 2



     ;lea        eax, [textureNeonID]
     ;stdcall    Texture.LoadTexture, textureNeonPath, eax
     stdcall    Texture.LoadTexture, textureNeonPath, textureNeonID

     ; reset the currently bound buffers
     invoke     glBindBuffer, GL_ARRAY_BUFFER, 0
     invoke     glBindVertexArray, 0

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
     invoke      glGetUniformLocation, [shaderProgram], modelMxName
     mov         [modelMxID], eax
     invoke      glGetUniformLocation, [shaderProgram], viewMxName
     mov         [viewMxID], eax
     invoke      glGetUniformLocation, [shaderProgram], projectionMxName
     mov         [projectionMxID], eax

     invoke      glMatrixMode, GL_PROJECTION
     invoke      glLoadIdentity
     stdcall     Matrix.Projection, 1.33333, 45.0, 0.1, 100.0
     invoke      glGetFloatv, GL_PROJECTION_MATRIX, projectionMx
     
     invoke      glMatrixMode, GL_MODELVIEW
     invoke      glLoadIdentity
     ;invoke      glRotatef, 30.0, 1.0, 0.0, 0.0     
     invoke      glGetFloatv, GL_MODELVIEW_MATRIX, modelMx
 
     invoke      glLoadIdentity
     invoke      glTranslatef, 0.0, 0.0, -3.0
     invoke      glGetFloatv, GL_MODELVIEW_MATRIX, viewMx

     invoke      glUniformMatrix4fv, [modelMxID], 1, GL_FALSE, modelMx
     invoke      glUniformMatrix4fv, [viewMxID], 1, GL_FALSE, viewMx
     invoke      glUniformMatrix4fv, [projectionMxID], 1, GL_FALSE, projectionMx


     stdcall     Debug.OutputValueDec, 62

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