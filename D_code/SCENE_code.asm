proc Scene.InitScenes uses esi
    
    mov     esi, Scenes.ArrPacked
    mov     edi, Scenes.ArrMain

    mov     ecx, Scenes.ArrPackedCount
    ; silly hehe
    cmp     ecx, Scenes.ArrMainCount
    jne     .return 

.looper:
    push    ecx 

    mov     eax, esi
    add     eax, PackedScene.packedSoundtrack
    stdcall Track.GenerateTrack, eax
    ; return value :
    ; eax - buffer
    ; edx - track duration
    
    mov     ecx, edi
    mov     [ecx + Scene.soundtrack + Track.trackDuration], edx
    mov     [ecx + Scene.soundtrack + Track.buffer], eax 

    pop     ecx 
    add     esi, sizeof.PackedScene
    add     edi, sizeof.Scene
    loop    .looper 

.return:
    ret
endp 
