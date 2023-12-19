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

.switchChoiceScene:

     stdcall   Scene.SwitchScene

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

     ; maybe it's not so optimal to make 2 separate routines in terms 
     ; of efficiency, but at least the structure is kept
     stdcall   Camera.UpdateScene, [currentScene], [currentTime]
     stdcall   Scene.ProcessScene, [currentScene], [currentTime]


     ; (potentially this is the place for changing the scene)





; updates the scene
     ;stdcall    Tick
.Skip:

; clearing the scene
     invoke     glClearColor, 0.07058, 0.0, 0.19607, 1.0           ; basically bgColor characteristics
     invoke     glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT

     ; ! uniforms must be after the useprogram function call
     invoke     glUseProgram, [shaderProgram]
     stdcall    Draw.SetUpViewMx, [deltaTime]

     stdcall    Draw.ModelDraw, planeModel, true 
     stdcall    Draw.LayoutDraw
     stdcall    Draw.ObstaclesDraw, SG1_RunnerFirst_Scene

     ; stdcall    Draw.ModelDraw, towerIndicatorCenter, true 
     ; stdcall    Draw.TownDraw, townM11
     ; stdcall    Draw.TownDraw, townM12
     ; stdcall    Draw.TownDraw, townM21
     ; stdcall    Draw.TownDraw, townM22
     ; stdcall    Draw.TownDraw, townS1
     ; stdcall    Draw.TownDraw, townS2
     ; stdcall    Draw.TownDraw, townS3
     ; stdcall    Draw.TownDraw, townS4
     ; stdcall    Draw.TownDraw, townL

     ; invoke     glPolygonMode, GL_FRONT_AND_BACK, GL_LINE
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

proc Draw.LayoutDraw uses esi 

     invoke     glClear, GL_DEPTH_BUFFER_BIT

     mov       esi, [crossroadArray]
     mov       ecx, LAYOUT_CROSSROADSWIDTH*LAYOUT_CROSSROADSHEIGHT
.looperCross:
     push      ecx 
     stdcall   Draw.ModelDraw, esi, true
     pop       ecx 
     add       esi, sizeof.Model 
     loop      .looperCross

     mov       esi, [roadVerticalArray]
     mov       ecx, (LAYOUT_CROSSROADSHEIGHT-1)*LAYOUT_CROSSROADSWIDTH
.looperRoadVertical:
     push      ecx 
     stdcall   Draw.ModelDraw, esi, true 
     pop       ecx 
     add       esi, sizeof.Model 
     loop      .looperRoadVertical

     mov       esi, [roadHorizontalArray]
     mov       ecx, (LAYOUT_CROSSROADSWIDTH-1)*LAYOUT_CROSSROADSHEIGHT
.looperRoadHorizontal:
     push      ecx 
     stdcall   Draw.ModelDraw, esi, true
     pop       ecx 
     add       esi, sizeof.Model
     loop      .looperRoadHorizontal

     mov       esi, [townArray]
     mov       ecx, (LAYOUT_CROSSROADSHEIGHT-1)*(LAYOUT_CROSSROADSWIDTH-1)*(TOWN_LCOUNT + TOWN_MCOUNT + TOWN_SCOUNT)
.looperTown:
     push      ecx 
     stdcall   Draw.TownDraw, esi
     pop       ecx 
     add       esi, sizeof.Town 
     loop      .looperTown 

     ret 
endp 

proc Draw.ObstaclesDraw uses esi edi,\
     pRunnerScene

     mov       esi, [pRunnerScene]
     mov       esi, [esi + Scene.movement]
     mov       ecx, [esi + RunnerData.obstacles + Obstacles.obstCount]
     mov       edi, [esi + RunnerData.obstacles + Obstacles.arrObstacles]

.looper:
     push      ecx 
     invoke    glMatrixMode, GL_MODELVIEW
     invoke    glPushMatrix 
     invoke    glLoadIdentity
     invoke    glTranslatef, [esi + RunnerData.startPos + Vector3.x], [esi + RunnerData.startPos + Vector3.y], [esi + RunnerData.startPos + Vector3.z]
     lea       eax, [nullVector]
     lea       edx, [esi + RunnerData.dirNegativeVec]
     stdcall   Camera.LookAt, eax, edx, VecUpward
     lea       eax, [edi + ObstacleData.model]
     stdcall   Draw.ModelDraw, eax, false
     invoke    glPopMatrix
     add       edi, sizeof.ObstacleData
     pop       ecx 
     loop      .looper


     ret 
endp 