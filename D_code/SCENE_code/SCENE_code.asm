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
    ; make smooth spline

    jmp         .return 


.terminate:     
    invoke      ExitProcess, 0
.return:

    ret 
endp