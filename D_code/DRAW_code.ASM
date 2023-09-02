proc Draw
     locals
        f               dd      ?
        tempFloat       dd      ?
     endl

     invoke     GetTickCount
     mov        [currentTime], eax
     sub        eax, [startTime]
     mov        [programTime], eax

     fild    [programTime]
     fdiv    [oneSecond]
     fstp    [programTime]

     mov     eax, [currentTime]
     sub     eax, [lastTime]
     cmp     eax, 10
     jle     .Skip

     mov        eax, [currentTime]
     mov        [lastTime], eax

; updates the scene
     ;stdcall    Tick
.Skip:

; clearing the scene
     invoke     glClearColor, 0.3,0.3,0.3,1.0           ; basically bgColor characteristics
     invoke     glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT


; placing the camera
     ;invoke     glRotatef, [angle], 0.0,1.0,0.0
     ;fld        [angle]
     ;fdiv       [radian]
     ;fsincos
     ;fmul       [length]
     ;fst        [light0Position.x]
     ;fchs
     ;fstp       [light1Position.x]
     ;fmul       [length]
     ;fst        [light0Position.z]
     ;fchs
     ;fstp       [light1Position.z]

     invoke     glLightfv, GL_LIGHT0, GL_POSITION, light0Position
     ;invoke     glLightfv, GL_LIGHT0, GL_SPOT_CUTOFF, myCutout
      ;invoke     glLightfv, GL_LIGHT0, GL_SPOT_DIRECTION, spotdir
;     invoke     glLightfv, GL_LIGHT1, GL_POSITION, light1Position

     ;fld        [angle]
     ;fdiv       [radian]
     ;fsin
     ;fabs
     ;fstp       [f]
     ;stdcall    DrawMesh, plane, planeTransform
     ;stdcall    DrawMesh, cube, cubeTransform

     ;stdcall    Movement.Interpolate, cubePosition1, cubePosition2, cubePosition, [f]
     ;invoke     glTranslatef, [cubePosition.x], [cubePosition.y], [cubePosition.z]
     ;stdcall    DrawMesh, cube

; draw
     ;stdcall    Spline.GetPoint, cubeSpline, cubeTransform.position, [programTime]
     ;stdcall    Spline.GetPoint, cameraSpline, cameraPosition, [programTime]


     invoke     glMatrixMode, GL_MODELVIEW
     invoke     glLoadIdentity
     stdcall    Matrix.LookAt, cameraPosition, targetPosition, upVector


;        cmp     [program], ebx
;        je      @F
;
;        invoke  glUseProgram, [program]
;
;        fild    [programTime]
;        fdiv    [oneSecond]
;        fstp    [tempFloat]
;        push    [tempFloat]
;
;        invoke  glUniform1f, [timeLocation] ; , (float)(programTime)
;
;        fild    [clientRect.bottom]
;        fstp    [tempFloat]
;        push    [tempFloat]
;
;        fild    [clientRect.right]
;        fstp    [tempFloat]
;        push    [tempFloat]
;
;        invoke  glUniform2f, [sizeLocation] ; , (float)(width), (float)(height)
;
;@@:

     ;stdcall    DrawMesh, cube, cubeTransform

;     invoke     glUseProgram, ebx

     invoke     glPushMatrix
     invoke     glMaterialfv, GL_FRONT, GL_DIFFUSE, PlaneDiffuse
     invoke     glMaterialfv, GL_FRONT, GL_AMBIENT, PlaneAmbient
     stdcall    DrawMesh, plane, planeTransform
     invoke     glPopMatrix


     invoke     glPushMatrix
     invoke     glMaterialfv, GL_FRONT, GL_DIFFUSE, BuildDiffuse
     invoke     glMaterialfv, GL_FRONT, GL_AMBIENT, BuildAmbient
     stdcall    DrawMesh, Tower, cubeTransform
     invoke     glPopMatrix

     invoke     SwapBuffers, [hdc]

     ret
endp

proc Tick
     ; updating the angle
     fld        [angle]          ; angle
     fsub       [step]           ; angle-step
     fstp       [angle]          ;

     ret
endp



proc DrawMesh uses esi,\
     mesh, transform

     mov        esi, [mesh]
     mov        edi, [transform]

; pushing the matrix, so that the changes do not affect anything but the current mesh
     invoke     glPushMatrix


; you spin me right round baby right round like a record baby right round round round           ('You Spin Me Round (Like a Record)' by Dead or Alive, 1985)
     invoke     glTranslatef, [edi+Transform.position.x], [edi+Transform.position.y], [edi+Transform.position.z]
     invoke     glRotatef, [edi+Transform.rotation.x], 1.0, 0.0, 0.0
     invoke     glRotatef, [edi+Transform.rotation.y], 0.0, 1.0, 0.0
     invoke     glRotatef, [edi+Transform.rotation.z], 0.0, 0.0, 1.0
     invoke     glScalef, [edi+Transform.scale.x], [edi+Transform.scale.y], [edi+Transform.scale.z]

; allowing to import the arrays of data
     invoke     glEnableClientState, GL_VERTEX_ARRAY
     invoke     glEnableClientState, GL_COLOR_ARRAY
     invoke     glEnableClientState, GL_NORMAL_ARRAY

     invoke     glVertexPointer, 3, GL_FLOAT, ebx, [esi+Mesh.vertices]
     invoke     glColorPointer, 3, GL_FLOAT, ebx, [esi+Mesh.colors]
     invoke     glNormalPointer, GL_FLOAT, ebx, [esi+Mesh.normals]
     invoke     glDrawArrays, GL_TRIANGLES, ebx, [esi+Mesh.verticesCount]

     invoke     glDisableClientState, GL_VERTEX_ARRAY
     invoke     glDisableClientState, GL_COLOR_ARRAY
     invoke     glDisableClientState, GL_NORMAL_ARRAY

     invoke     glPopMatrix

     ret
endp