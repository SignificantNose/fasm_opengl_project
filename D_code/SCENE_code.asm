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


proc Scene.InitializeRunner uses esi edi,\
    pScene, pStartPoint, pEndPoint

; allocating memory for the RunnerData structure
; and saving a pointer to it 
    mov     edi, [pScene]
    invoke  HeapAlloc, [hHeap], 8, sizeof.RunnerData 
    mov     [edi + Scene.movement], eax
    mov     esi, eax

; initializing the starting point 
    lea     eax, [esi + RunnerData.startPos]
    stdcall Vector3.Copy, eax, [pStartPoint]

; calculating the direction vector
    lea     eax, [esi + RunnerData.dirVector]
    push    eax         ; pDirVector
    push    eax         ; pDirVector
    stdcall Vector3.Copy, eax, [pEndPoint]
    pop     eax         ; pDirVector
    stdcall Vector3.Sub, eax, [pStartPoint]
    pop     eax         ; pDirVector
    fld1                                                    ; 1
    fdiv    [edi + Scene.soundtrack + Track.trackDuration]       ; 1/dur
    push    edx         ; 
    fstp    dword[esp]
    pop     edx         ; multiplier
    stdcall Vector3.Scale, eax, edx     

    ret
endp 