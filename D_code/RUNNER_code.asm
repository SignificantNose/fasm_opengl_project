proc Runner.InitializeRunner uses esi edi,\
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

; calculating the right vector 
    pop     eax
    lea     edi, [esi + RunnerData.vectorRight] 
    stdcall Vector3.Cross, eax, VecUpward, edi 
    stdcall Vector3.Normalize, edi 
    stdcall Vector3.Scale, edi, [RunnerStep]

    ret
endp 



proc Runner.Move,\
    direction, pRunnerData
    
    mov     edx, [pRunnerData]

    mov     eax, [direction]
    JumpIf  RUNDIR_UP, .up  
    JumpIf  RUNDIR_DOWN, .down 
    JumpIf  RUNDIR_LEFT, .left 
    JumpIf  RUNDIR_RIGHT, .right 

.up:
    movsx   eax, byte[edx + RunnerData.playerData + PlayerPos.posVertical]
    cmp     eax, 1
    jge     .return   
    inc     eax 
    jmp     .storeVertical 

.down:
    movsx   eax, byte[edx + RunnerData.playerData + PlayerPos.posVertical]
    cmp     eax, -1
    jle     .return 
    dec     eax 
    jmp     .storeVertical 

.left:
    movsx   eax, byte[edx + RunnerData.playerData + PlayerPos.posHorizontal]
    cmp     eax, -1
    jle     .return 
    dec     eax
    jmp     .storeHorizontal
    
.right:
    movsx   eax, byte[edx + RunnerData.playerData + PlayerPos.posHorizontal]
    cmp     eax, 1
    jge     .return 
    inc     eax
    jmp     .storeHorizontal

.storeVertical:
    mov     byte[edx + RunnerData.playerData + PlayerPos.posVertical], al 
    jmp     .return 

.storeHorizontal:
    mov     byte[edx + RunnerData.playerData + PlayerPos.posHorizontal], al

.return:
    ret
endp 