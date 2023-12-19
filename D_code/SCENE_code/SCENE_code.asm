; routine for unpacking the array of packed
; scene tracks. causes the generation of 
; track list that will be further used in 
; scenes
proc Scene.UnpackSceneTracks uses esi edi
    
    mov     esi, Scenes.PackedTracks 
    mov     edi, Scenes.TrackList

    mov     ecx, Scenes.PackedTracksCount 
    cmp     ecx, Scenes.TrackListCount 
    jne     .return 

.looper:
    push    ecx 

    stdcall Track.GenerateTrack, esi 
    ; return value:
    ; eax - buffer 
    ; edx - track duration 

    mov     [edi + Track.buffer], eax 
    mov     [edi + Track.trackDuration], edx

    pop     ecx
    add     esi, sizeof.PackedTrack 
    add     edi, sizeof.Track
    loop    .looper 

.return: 
    ret
endp 

; routine for unpacking the array of packed 
; scenes, which is basically an array of 
; pointers to tracks. the routine causes the
; copying process of IDirectSoundBuffer8s
; to the actual scenes that will be used in 
; the game process
proc Scene.UnpackScenes uses esi edi 

    mov     esi, Scenes.PackedScenes
    mov     edi, Scenes.SceneList 

    mov     ecx, Scenes.PackedScenesCount
    cmp     ecx, Scenes.SceneListCount 
    jne     .return 

.looper:
    push    ecx 

    mov     eax, [esi + PackedScene.pSceneTrack]
    ; eax has the pointer to the track struct 

    lea     edx, [edi + Scene.soundtrack]
    stdcall Memory.memcpy, edx, eax, sizeof.Track
    ; copy the track 

    pop     ecx 
    add     esi, sizeof.PackedScene
    add     edi, sizeof.Scene
    loop    .looper 

.return:
    ret 
endp 


proc Scene.SwitchScene uses edi

    mov         edi, [currentScene]
    push        edi     ; prevScene

    add         edi, sizeof.Scene
    cmp         edi, Scenes.SceneListEnd
    je          .terminate 

    ; play the new buffer
    cominvk     PlayBuffer, Stop
    mov         eax, [edi + Scene.soundtrack + Track.buffer]
    mov         [PlayBuffer], eax 
    cominvk     PlayBuffer, Play, 0, 0, 0
    mov         [currentScene], edi


; deal with the previous scene
    pop         edi     ; prevScene
    movzx       eax, byte[edi + Scene.mode]
    mov         ecx, [edi + Scene.movement]
    JumpIf      SCENEMODE_CHOICE, .switchChoiceScene 
    JumpIf      SCENEMODE_INDEPENDENT, .return 
    JumpIf      SCENEMODE_RUNNER, .runner
    JumpIf      SCENEMODE_SPECTATOR, .return
    jmp         .terminate 
.switchChoiceScene:
    ; make smooth choice change 
    stdcall     Choice.ApplyChoice, ecx 
    jmp         .return 
.runner: 
    
; initializing after run struct
    mov         edi, [currentScene]
    mov         eax, [edi + Scene.movement]
    mov         eax, [eax + SpectatorData.SPCameraPos]
    lea         edi, [eax + Spline.Point.pMainVertex]
    invoke      HeapAlloc, [hHeap], 8, sizeof.Vector3
    mov         [edi], eax
    lea         edx, [cameraPos]
    stdcall     Vector3.Copy, eax, edx

    jmp         .return 


.terminate:     
    invoke      ExitProcess, 0
.return:

    ret 
endp


proc Scene.ProcessScene uses edi,\
    pScene, time

    mov     edi, [pScene]
    movzx   eax, [edi + Scene.mode]
    JumpIf  SCENEMODE_RUNNER, .runner 
    JumpIf  SCENEMODE_CHOICE, .choice 
    JumpIf  SCENEMODE_SPECTATOR, .spectator
    JumpIf  SCENEMODE_INDEPENDENT, .independent
    jmp     .return 
.runner:
    mov     edi, [edi + Scene.movement]     ; edx now points to RunnerData struct 
    fld     [edi + RunnerData.nextObstacleTime]     ; ot
    fld     [time]                                  ; t, ot 
    FPU_CMP 
    jb      .runnerNotChecking

; acquire the pointer to the current obstacle 
    movzx   eax, byte[edi + RunnerData.indexNextObstacle]
    imul    eax, sizeof.ObstacleData
    mov     edx, [edi + RunnerData.obstacles + Obstacles.arrObstacles]
    add     edx, eax

    cmp     eax, [edi + RunnerData.obstacles + Obstacles.obstCount]
    jne     .initNextObstacle
    mov     [edi + RunnerData.nextObstacleTime], 999999999.0        ; yikes 
    jmp     .continueChecking
.initNextObstacle:
    mov     eax, sizeof.ObstacleData 
    add     eax, edx        ; p to next obstacle 
    mov     eax, [eax + ObstacleData.time]
    mov     [edi + RunnerData.nextObstacleTime], eax 
    inc     byte[edi + RunnerData.indexNextObstacle]
.continueChecking:

; acquiring the current obstacle
    movzx   ecx, word[edx + ObstacleData.mask]

; acquiring the current player position bit 
    movsx   eax, byte[edi + RunnerData.playerData + PlayerPos.posVertical]
    inc     eax 
    imul    eax, 3
    movsx   edx, byte[edi + RunnerData.playerData + PlayerPos.posHorizontal]
    neg     edx 
    inc     edx 
    add     eax, edx 
    
    nop 
    bt      ecx, eax 
    jnc     .notCrash
    
    movzx   ecx, [amntOfLives]
    dec     ecx
    mov     [amntOfLives], cl
    jecxz   .death 
    cominvk SFXBuffer, Stop
    cominvk SFXBuffer, SetCurrentPosition, 0
    cominvk SFXBuffer, Play, 0, 0, 0
    jmp     .notCrash 
.death:

    invoke  ExitProcess, 0
.notCrash:


.runnerNotChecking:
    jmp     .return
.choice:
.spectator:
.independent:
.return:

    ret 

endp 