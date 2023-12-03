proc Draw uses edi
     locals
        f               dd      ?
        tempFloat       dd      ?
        deltaTime       dd      ?
     endl

     invoke     GetTickCount
     mov        [currentTime], eax
     sub        eax, [startTime]
     mov        [programTime], eax

     fild    [programTime]
     fdiv    [oneSecond]
     fstp    [programTime]


     fldz 
     fstp    [deltaTime]

     mov     eax, [currentTime]
     sub     eax, [lastTime]
     cmp     eax, 10
     jle     .Skip

     fild       [currentTime]
     fisub      [lastTime]
     fdiv       [oneSecond]
     fstp       [deltaTime]

     mov        eax, [currentTime]
     mov        [lastTime], eax

; updates the scene
     ;stdcall    Tick
.Skip:

; clearing the scene
     invoke     glClearColor, 0.3,0.3,0.3,1.0           ; basically bgColor characteristics
     invoke     glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT

     ; ! uniforms must be after the useprogram function call
     invoke    glUseProgram, [shaderProgram]
     stdcall    Draw.SetUpViewMx, [deltaTime]

     stdcall    Draw.ModelDraw, planeModel, true 
     stdcall    Draw.ModelDraw, towerModel, true 
     stdcall    Draw.TownDraw, testTown

     ;invoke     glPolygonMode, GL_FRONT_AND_BACK, GL_LINE
     invoke     glUseProgram, ebx

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


proc Draw.SetUpViewMx,\
     dTime
     locals
          cameraCurrTarget         Vector3
     endl
     
     invoke       glMatrixMode, GL_MODELVIEW
     invoke       glPushMatrix
     invoke       glLoadIdentity

     lea          edi, [cameraCurrTarget]
     stdcall      Vector3.Copy, edi, cameraPos
     stdcall      Vector3.Add, edi, cameraFront

     stdcall      Camera.Move, [dTime]
     stdcall      Camera.LookAt, cameraPos, edi, cameraUp

     invoke       glGetFloatv, GL_MODELVIEW_MATRIX, viewMx
     invoke       glUniformMatrix4fv, [viewMxID], 1, GL_FALSE, viewMx
     invoke       glPopMatrix
     
     ret 
endp

proc Draw.ModelDraw uses esi edi,\
     pPositionedMesh, selfTransform

     mov       esi, [pPositionedMesh]
     mov       edi, esi
     add       esi, Model.meshData
     add       edi, Model.positionData
; esi = mesh data, edi = position data

     invoke    glActiveTexture, GL_TEXTURE0
     invoke    glBindTexture, GL_TEXTURE_2D, [esi + ShaderMesh.textureID]
     invoke    glBindVertexArray, [esi + ShaderMesh.VAO]

     invoke    glMatrixMode, GL_MODELVIEW
     invoke    glPushMatrix

; currently I have no brighter ideas on how to make it more optimal
; besides code duplication
     mov       ecx, [selfTransform]
     jecxz     @F
     invoke    glLoadIdentity
@@:

     invoke    glTranslatef, [edi + Transform.position.x], [edi + Transform.position.y], [edi + Transform.position.z]
     invoke    glRotatef, [edi + Transform.rotation.x], 1.0, 0.0, 0.0
     invoke    glRotatef, [edi + Transform.rotation.y], 0.0, 1.0, 0.0
     invoke    glRotatef, [edi + Transform.rotation.z], 0.0, 0.0, 1.0
     invoke    glScalef, [edi + Transform.scale.x], [edi + Transform.scale.y], [edi + Transform.scale.z]
     
     invoke    glGetFloatv, GL_MODELVIEW_MATRIX, modelMx
     invoke    glUniformMatrix4fv, [modelMxID], 1, GL_FALSE, modelMx

     invoke    glPopMatrix

     invoke    glDrawArrays, GL_TRIANGLES, ebx, [esi + ShaderMesh.VerticesCount]
     invoke    glBindVertexArray, 0

     ret 
endp 

proc Draw.TownDraw uses esi edi,\
     pTown

     nop 
     mov       esi, [pTown]
     mov       ecx, [esi + Town.total]
     mov       edi, [esi + Town.pTowerModels]

.looper:
     push      ecx 

     invoke    glMatrixMode, GL_MODELVIEW
     invoke    glPushMatrix 
     invoke    glLoadIdentity

     invoke    glTranslatef, [esi + Town.townPos + Vector3.x], [esi + Town.townPos + Vector3.y], [esi + Town.townPos + Vector3.z]
     invoke    glRotatef, [esi + Town.townRot + Vector3.x], 1.0, 0.0, 0.0
     invoke    glRotatef, [esi + Town.townRot + Vector3.y], 0.0, 1.0, 0.0
     invoke    glRotatef, [esi + Town.townRot + Vector3.z], 0.0, 0.0, 1.0

     stdcall   Draw.ModelDraw, edi, false 
     invoke    glPopMatrix

     add       edi, sizeof.Model
     pop       ecx 
     loop      .looper 

     ret
endp

proc DrawTown uses esi,\
     town, transform

     mov        esi, [town]
     mov        edi, [transform]
     mov ecx, [esi+Town.total]
     mov eax, [esi+Town.towers]
     mov esi, eax
.looper:
     push ecx
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

     jmp @F
.looperContinue:
     jmp .looper
@@:

     invoke     glVertexPointer, 3, GL_FLOAT, ebx, [esi+Mesh.vertices]
     invoke     glColorPointer, 3, GL_FLOAT, ebx, [esi+Mesh.colors]
     invoke     glNormalPointer, GL_FLOAT, ebx, [esi+Mesh.normals]
     invoke     glDrawArrays, GL_TRIANGLES, ebx, [esi+Mesh.verticesCount]

     invoke     glDisableClientState, GL_VERTEX_ARRAY
     invoke     glDisableClientState, GL_COLOR_ARRAY
     invoke     glDisableClientState, GL_NORMAL_ARRAY

     invoke     glPopMatrix

     add esi, sizeof.Mesh
     pop ecx
     loop .looperContinue

     ret
endp