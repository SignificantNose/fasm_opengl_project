proc Draw uses edi
     locals
        deltaTime       dd      ?
        playCursor      dd      ?
        status          dd      ?
     endl

     mov       edi, [currentScene]
     fld       [currentTime]                      ; t
     fld       dword[edi + Scene.sceneDuration]   ; sceneDur, t
     FPU_CMP 
     ja        .checkBufferEnd
; :(
     ; jmp       .switchScene
.switchScene:
     movzx     edx, byte[edi + Scene.mode]
     cmp       edx, SCENEMODE_CHOICE
     jne       @F
     nop
     mov       eax, [edi + Scene.movement]
.switchChoiceScene:
     stdcall   Choice.ApplyChoice, eax 
@@:

     add       edi, sizeof.Scene
     cmp       edi, Scenes.ArrMainEnd
     je        .terminate 

     ; play the new buffer
     cominvk   PlayBuffer, Stop
     mov       eax, [edi + Scene.soundtrack + Track.buffer]
     mov       [PlayBuffer], eax 
     cominvk   PlayBuffer, Play, 0, 0, 0
     mov       [currentScene], edi

     ; restore the time intervals
     ; xor       eax, eax 
     ; mov       [currentTime], eax
     ; mov       [lastBufferTime], eax 
     mov       [currentTime], 0
     mov       [lastBufferTime], 0

.checkBufferEnd:
; ooofffff
     lea       eax, [status]
     cominvk   PlayBuffer, GetStatus, eax
     mov       eax, [status]
     cmp       eax, DSBSTATUS_PLAYING 
     je        .continueDraw 
     cmp       eax, DSBSTATUS_BUFFERLOST 
     je        .continueDraw 
     cmp       eax, DSBSTATUS_LOOPING 
     je        .continueDraw 
     cmp       eax, DSBSTATUS_LOCHARDWARE 
     je        .continueDraw 
     cmp       eax, DSBSTATUS_TERMINATED 
     je        .continueDraw 

     cominvk   PlayBuffer, Play, 0, 0, 0
     fld       [lastBufferTime]                                       
     fsub      dword[edi + Scene.soundtrack + Track.trackDuration]   
     fstp      [lastBufferTime]
     movzx     eax, byte[edi + Scene.mode]
     cmp       eax, SCENEMODE_CHOICE
     jne       .continueDraw 
     mov       eax, [edi + Scene.movement]
     test      byte[eax + ChoiceData.choiceHasBeenMade], 1
     jz        .continueDraw 
     jmp       .switchChoiceScene
     
.terminate:
     invoke    ExitProcess, 0
.continueDraw:
     lea       eax, [playCursor]
     cominvk   PlayBuffer, GetCurrentPosition, eax, ebx
     mov       eax, [playCursor]        ; in bytes

     push      eax       ; bytesSample
     fild      dword[esp]     ; currBytes
     pop       eax       ; bytesSample

     mov       eax, BYTES_PER_SECOND
     push      eax 
     fidiv     dword[esp]          ; currSeconds
     fsub      [lastBufferTime]    ; deltaTime
     fst       [deltaTime]
     fld       st0                 ; dt, dt
     fadd      [lastBufferTime]    ; lastBuf + dt, dt
     fstp      [lastBufferTime]    ; dt
     fadd      [currentTime]       ; currTime + dt
     fstp      [currentTime]       ; 
     
     pop       eax 

     ; some procedure for changing the camera position based on the current time moment and the 
     ; status of the current scene

     ; make a global variable for the current scene
     stdcall   Camera.UpdateScene, [currentScene], [currentTime]



     ; (potentially this is the place for changing the scene)





; updates the scene
     ;stdcall    Tick
.Skip:

; clearing the scene
     invoke     glClearColor, 0.3,0.3,0.3,1.0           ; basically bgColor characteristics
     invoke     glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT

     ; ! uniforms must be after the useprogram function call
     invoke    glUseProgram, [shaderProgram]
     stdcall    Draw.SetUpViewMx, [deltaTime]

     ;stdcall    Draw.ModelDraw, towerModel, true 
     stdcall    Draw.ModelDraw, planeModel, true 

     invoke     glClear, GL_DEPTH_BUFFER_BIT
     stdcall    Draw.ModelDraw, Crossroad13, true

     invoke     glClear, GL_DEPTH_BUFFER_BIT
     stdcall    Draw.ModelDraw, Crossroad23, true
     invoke     glClear, GL_DEPTH_BUFFER_BIT
     stdcall    Draw.ModelDraw, Crossroad33, true

     invoke     glClear, GL_DEPTH_BUFFER_BIT
     stdcall    Draw.ModelDraw, roadV13, true

     invoke     glClear, GL_DEPTH_BUFFER_BIT
     stdcall    Draw.ModelDraw, roadV23, true
     
     ; invoke     glClear, GL_DEPTH_BUFFER_BIT
     ; stdcall    Draw.ModelDraw, road11, true
     ; invoke     glClear, GL_DEPTH_BUFFER_BIT
     ; stdcall    Draw.ModelDraw, road12, true
     ; invoke     glClear, GL_DEPTH_BUFFER_BIT
     ; stdcall    Draw.ModelDraw, road13, true
     ; invoke     glClear, GL_DEPTH_BUFFER_BIT
     ; stdcall    Draw.ModelDraw, road14, true

     ; invoke     glClear, GL_DEPTH_BUFFER_BIT
     ; stdcall    Draw.ModelDraw, road21, true
     ; invoke     glClear, GL_DEPTH_BUFFER_BIT
     ; stdcall    Draw.ModelDraw, road22, true
     ; invoke     glClear, GL_DEPTH_BUFFER_BIT
     ; stdcall    Draw.ModelDraw, road23, true
     ; invoke     glClear, GL_DEPTH_BUFFER_BIT
     ; stdcall    Draw.ModelDraw, road24, true

     stdcall    Draw.ModelDraw, towerIndicatorCenter, true 

     stdcall    Draw.TownDraw, townMain

     ; stdcall    Draw.TownDraw, town11
     ; stdcall    Draw.TownDraw, town12
     ; stdcall    Draw.TownDraw, town13

     ; stdcall    Draw.TownDraw, town21
     ; stdcall    Draw.TownDraw, town22
     ; stdcall    Draw.TownDraw, town23

     ; stdcall    Draw.TownDraw, town31
     ; stdcall    Draw.TownDraw, town32
     ; stdcall    Draw.TownDraw, town33

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


proc Draw.SetUpViewMx uses edi,\
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

; to be removed
; #############
     mov          eax, [currentScene]
     movzx        eax, [eax + Scene.mode]
     cmp          eax, SCENEMODE_INDEPENDENT
     jne          @F
     stdcall      Camera.Move, [dTime]
@@:
; #############
; to be removed
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