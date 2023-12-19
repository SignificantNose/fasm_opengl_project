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
    fld1                                    ; 1
    fdiv    [edi + Scene.sceneDuration]     ; 1/dur
    push    edx         ; 
    fstp    dword[esp]
    pop     edx         ; multiplier
    stdcall Vector3.Scale, eax, edx  

    pop     eax         ; pDirVector
    push    eax         ; pDirVector
    lea     edi, [esi + RunnerData.dirNegativeVec]
    stdcall Vector3.Copy, edi, eax 
    stdcall Vector3.Scale, edi, -1.0

; calculating the right and up vector 
    pop     eax         ; pDirVector
    lea     edi, [esi + RunnerData.vectorRight] 
    stdcall Vector3.Cross, eax, VecUpward, edi 
    stdcall Vector3.Normalize, edi 
    stdcall Vector3.Scale, edi, [RunnerStep]
    lea     edi, [esi + RunnerData.vectorUp]
    stdcall Vector3.Copy, edi, VecUpward
    stdcall Vector3.Scale, edi, [RunnerStep]

    ret
endp 

proc Runner.InitializeObstacles uses ebx esi edi,\
    pScene, amntOfObstacles, difficulty

    locals
        tempTime            dd      0.0
        timeIncrement       dd      ?
        vectorIncrement     Vector3 
        currTransform       Transform   <0.0, 0.0, 0.0>,\
                                        <0.0, 0.0, 0.0>,\
                                        <1.0, 1.0, 1.0>
    endl 

    mov     esi, [pScene]
    fld     [esi + Scene.sceneDuration]     ; sceneDur
    fild    [amntOfObstacles]               ; n, sceneDur
    fld1                                    ; 1, n, sceneDur
    faddp                                   ; 1+n, sceneDur
    fdivp                                   ; dt 
    fst     [timeIncrement]                 ; 
; also for game logic we must initialize the scene's next obstacle time
    mov     esi, [esi + Scene.movement]     ; esi now points to RunnerData
    fstp    [esi + RunnerData.nextObstacleTime]

; initializing the array
    mov     eax, [amntOfObstacles]
    mov     [esi + RunnerData.obstacles + Obstacles.obstCount], eax 
    imul    eax, sizeof.ObstacleData
    invoke  HeapAlloc, [hHeap], 8, eax  
    mov     [esi + RunnerData.obstacles + Obstacles.arrObstacles], eax 
    mov     edi, eax 

; initializing the increment vector
    lea     edx, [esi + RunnerData.dirVector] 
    lea     ebx, [vectorIncrement]
    stdcall Vector3.Copy, ebx, edx
    stdcall Vector3.Scale, ebx, [timeIncrement]
    lea     ebx, [currTransform]

; acquiring the range of disabled cells
    mov     eax, [difficulty]
    JumpIf  DIFFICULTY_EASY, .easy 
    JumpIf  DIFFICULTY_MEDIUM, .medium 
    jmp     .hard 
.easy:
    mov     al, 3
    mov     ah, 5
    jmp     @F 
.medium:
    mov     al, 5
    mov     ah, 7
    jmp     @F
.hard:
    mov     al, 8
    mov     ah, 8
@@:
    

; generating the cells themselves 
    movzx   edx, al 
    movzx   eax, ah
    mov     ecx, [amntOfObstacles]
.looper:
    push    ecx 
    push    edx
    push    eax 

    stdcall Rand.GetRandomInBetween, edx, eax 
    push    eax     ; nOfBits
    stdcall Runner.GetMask, eax 

    mov     [edi + ObstacleData.mask], ax 
    fld     [tempTime]
    fadd    [timeIncrement]
    fst     [edi + ObstacleData.time]
    fstp    [tempTime]
    pop     edx     ; nOfBits 

    push    ebx 
    push    edx 
    push    eax 
    lea     ecx, [edi + ObstacleData.model]
    push    ecx 
    
    lea     eax, [vectorIncrement]
    lea     ecx, [ebx + Transform.position]
    stdcall Vector3.Add, ecx, eax 
    stdcall GenerateModelOfObstacle;, ecx, eax, edx, ebx 

    add     edi, sizeof.ObstacleData


    pop     eax 
    pop     edx 
    pop     ecx 
    loop    .looper 

    ret 
endp 

proc Runner.GetMask uses ebx,\
    nOfElements

    mov     ebx, $FF800000
    mov     ecx, [nOfElements]
    rol     ebx, cl             ; bx will store the result 
    mov     ecx, 9
.looper:
    push    ecx 
    dec     ecx
    stdcall Rand.GetRandomInBetween, 0, ecx 
    pop     edx 
    push    edx 
    dec     edx
    xor     ecx, ecx 
    bts     ecx, eax 
    bts     ecx, edx 
    mov     edx, ecx
    and     cx, bx
    jz      .done 
    cmp     cx, dx 
    je      .done 
    xor     bx, dx 
.done:
    pop     ecx 
    loop    .looper

    movzx   eax, bx
    ret 
endp 


proc GenerateModelOfObstacle uses ebx esi edi,\
    pModel, mask, nOfBits, pTransform 
    
    locals 
        pmesh   PackedVerticesMesh
    endl 

    mov     ebx, [nOfBits]
    mov     edx, ebx
    shl     edx, 1
    lea     esi, [pmesh]
    mov     [esi + PackedVerticesMesh.trianglesCount], edx
    ; generate indices
    stdcall GenerateIndicesForObstacle, esi, ebx
    ; generate tex coords
    stdcall GenerateTexCoordsForObstacle, esi, ebx 
    ; generate vertices 
    stdcall GenerateVerticesForObstacle, esi, [mask], ebx  
    
    mov     edi, [pModel]
    stdcall Build.ModelByTemplate, edi, esi, [textureGroundID]
    mov     ebx, [pTransform]
    lea     eax, [edi + Model.positionData]
    stdcall Memory.memcpy, eax, ebx, sizeof.Transform


    ret 
endp 

proc GenerateIndicesForObstacle uses edi,\
    pPackedMesh, nOfBits 

    mov     edi, [pPackedMesh]
    mov     eax, [nOfBits]
    imul    eax, 6              ; 6 is the number of indices needed for one square (= one obstacle)
    ; imul    eax, sizeof.Indices, which are 1 byte each 
    invoke  HeapAlloc, [hHeap], 8, eax 
    mov     [edi + PackedVerticesMesh.pIndices], eax 
    mov     edi, eax 

    xor     eax, eax 
    mov     ecx, [nOfBits]
.looper:
    stosb           
    inc     al     
    stosb           
    inc     al
    stosb
    stosb
    inc     al
    stosb
    sub     al, 3
    stosb
    add     al, 4
    loop    .looper 
    


    ret 
endp 

proc GenerateTexCoordsForObstacle uses edi,\
    pPackedMesh, nOfBits

    mov     edi, [pPackedMesh]
    mov     eax, [nOfBits]
    imul    eax, sizeof.TexVertex*4         ; * 4, as each bit is 1 square => 4 vertices
    invoke  HeapAlloc, [hHeap], 8, eax 
    mov     [edi + PackedVerticesMesh.pTexCoords], eax 
    mov     edi, eax 

    xor     eax, eax 
    mov     ecx, [nOfBits]
.looper:
    xor     eax, eax 
    stosd   
    mov     eax, 1.0
    stosd 

    stosd 
    stosd 

    stosd 
    xor     eax, eax 
    stosd 

    stosd 
    stosd 


    loop    .looper 

    ret 
endp 

proc GenerateVerticesForObstacle uses ebx edi,\
    pPackedMesh, mask, nOfBits 
    locals
        currPos     Vector3     ?, 4.0, 0.0
        rHalf       dd      ?
        wOfSector   dd      ?
        index       dd      ?
    endl

; initializing local variables 
    mov     eax, [RunnerStep]
    mov     [wOfSector], eax 
    push    eax
    fld     dword[esp]      ; roadLen/3
    mov     eax, 1.5
    push    eax 
    fmul    dword[esp]      ; roadLen/2
    fstp    [rHalf]         
    pop     eax 
    pop     eax 

    mov     ebx, [mask]
    mov     eax, [nOfBits]
    imul    eax, 4*sizeof.Vector3 
    invoke  HeapAlloc, [hHeap], 8, eax 
    mov     edi, [pPackedMesh]
    mov     [edi + PackedVerticesMesh.pVertices], eax 
    mov     edi, eax 
    

    mov     [index], 8
    mov     ecx, 3
.looperOuter:
    push    ecx 

    mov     eax, [rHalf]
    mov     [currPos + Vector3.x], eax 
    mov     ecx, 3
.looperInner:
    push    ecx 

    mov     eax, [index]
    bt      bx,  ax 
    jnc     @F 
    lea     eax, [currPos]
    stdcall GetVisualVertex, eax, edi  
    add     edi, sizeof.Vector3*4
@@: 

    dec     [index]
    fld     [currPos + Vector3.x]
    fsub    [wOfSector]
    fstp    [currPos + Vector3.x]
    pop     ecx 
    loop    .looperInner

    fld     [currPos + Vector3.y]
    fsub    [wOfSector]
    fstp    [currPos + Vector3.y] 
    pop     ecx 
    loop    .looperOuter 
    
    ret 
endp 

proc GetVisualVertex uses esi edi,\
    pTopLeft, pDest 
    locals
        tempVertex  Vector3 
    endl 

    push    [RunnerStep]
    mov     eax, [pTopLeft]
    lea     esi, [tempVertex]
    stdcall Memory.memcpy, esi, eax, sizeof.Vector3
    mov     edi, [pDest]

    stdcall Memory.memcpy, edi, esi, sizeof.Vector3 
    add     edi, sizeof.Vector3 

    fld     [esi + Vector3.x]
    fsub    dword[esp]
    fstp    [esi + Vector3.x]
    stdcall Memory.memcpy, edi, esi, sizeof.Vector3
    add     edi, sizeof.Vector3 

    fld     [esi + Vector3.y]
    fsub    dword[esp]
    fstp    [esi + Vector3.y]
    stdcall Memory.memcpy, edi, esi, sizeof.Vector3 
    add     edi, sizeof.Vector3 

    fld     [esi + Vector3.x]
    fadd    dword[esp]
    fstp    [esi + Vector3.x]
    stdcall Memory.memcpy, edi, esi, sizeof.Vector3 
    add     edi, sizeof.Vector3 

    pop     eax 

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