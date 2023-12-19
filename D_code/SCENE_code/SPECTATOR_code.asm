proc Spectator.InitializeSpectator,\
    pScene, pSplineCamPos, pSplineFront

    invoke  HeapAlloc, [hHeap], 8, sizeof.SpectatorData
    push    eax     ; spectatorData
    mov     edx, [pScene]
    mov     [edx + Scene.movement], eax 
    mov     edx, [pSplineCamPos]
    lea     eax, [eax + SpectatorData.splineCameraPosData]
    stdcall Memory.memcpy, eax, edx, sizeof.Spline

    pop     eax     ; spectatorData
    mov     edx, [pSplineFront]
    lea     eax, [eax + SpectatorData.splineFrontData]
    stdcall Memory.memcpy, eax, edx, sizeof.Spline

    ret 
endp


proc Spectator.AfterRunInitialize uses esi edi,\
    pScene, direction, pStartPoint 

    locals  
        P1pP            dd      ? 
        P1pM            dd      ?
        P1pN            dd      ?     
        P2pP            dd      ? 
        P2pM            dd      ? 
        P2pN            dd      ?  
        F1pP            dd      ?
        F1pM            dd      ?
        F1pN            dd      ?
        F2pP            dd      ?
        F2pM            dd      ?
        F2pN            dd      ?  
        SPCameraPos     dd      ?
        SPFront         dd      ?
    endl 

    mov     ecx, 12 
    lea     edi, [P1pP]
.loopAlloc:
    push    ecx 
    invoke  HeapAlloc, [hHeap], 8, sizeof.Vector3
    stosd   
    pop     ecx 
    loop    .loopAlloc 

    lea     edi, [P1pP]
    mov     ecx, 6 
.loopCopy:
    push    ecx 
    mov     eax, [edi] 
    stdcall Vector3.Copy, eax, [pStartPoint]
    add     edi, 4
    pop     ecx 
    loop    .loopCopy 

    mov     esi, [pScene]
    invoke  HeapAlloc, [hHeap], 8, sizeof.SpectatorData 
    mov     [esi + Scene.movement], eax 
    mov     edi, eax

; i have the memory for spline. i need the points
    invoke  HeapAlloc, [hHeap], 8 sizeof.Spline.Point*2
    mov     [edi + SpectatorData.SPCameraPos], eax 
    mov     [SPCameraPos], eax 
    invoke  HeapAlloc, [hHeap], 8, sizeof.Spline.Point*2
    mov     [edi + SpectatorData.SPFront], eax 
    mov     [SPFront], eax



    mov     eax, [direction]
    JumpIf  DIRECTION_LEFT, .left 
    JumpIf  DIRECTION_RIGHT, .right
    JumpIf  DIRECTION_UP, .up 
    JumpIf  DIRECTION_DOWN, .down 
    jmp     .return 
.left:
    mov     edx, [pStartPoint]
    fld     [edx + Vector3.x]       ; StartPoint.x
    mov     edx, ROADLENGTHTWICE
    push    edx 
    fadd    dword[esp]              ; StartPoint.x + 2*lenOfRoad 
    pop     edx 

    mov     eax, [P1pN]
    fst     [eax + Vector3.x]
    mov     eax, [P2pP]
    fst     [eax + Vector3.x] 
    mov     edx, UNITLENGTH
    push    edx 
    fadd    dword[esp]              ; StartPoint.x + 2*lenOfRoad + unitLen
    pop     edx 
    mov     eax, [P2pM]
    fstp    [eax + Vector3.x] 

    lea     eax, [dirVector_left]
    mov     [F1pM], eax
    mov     [F2pM], eax 
    lea     eax, [dirVector_down]
    mov     [F1pN], eax 
    lea     eax, [dirVector_up]
    mov     [F2pP], eax

    jmp     .store

.right:
    mov     edx, [pStartPoint]
    fld     [edx + Vector3.x]       ; StartPoint.x
    mov     edx, ROADLENGTHTWICE
    push    edx 
    fsub    dword[esp]              ; StartPoint.x - 2*lenOfRoad 
    pop     edx 

    mov     eax, [P1pN]
    fst     [eax + Vector3.x]
    mov     eax, [P2pP]
    fst     [eax + Vector3.x] 
    mov     edx, UNITLENGTH
    push    edx 
    fsub    dword[esp]              ; StartPoint.x - 2*lenOfRoad - unitLen
    pop     edx 
    mov     eax, [P2pM]
    fstp    [eax + Vector3.x] 

    lea     eax, [dirVector_right]
    mov     [F1pM], eax
    mov     [F2pM], eax 
    lea     eax, [dirVector_up]
    mov     [F1pN], eax 
    lea     eax, [dirVector_down]
    mov     [F2pP], eax

    jmp     .store

.up:

    mov     edx, [pStartPoint]
    fld     [edx + Vector3.z]       ; StartPoint.z
    mov     edx, ROADLENGTHTWICE
    push    edx 
    fadd    dword[esp]              ; StartPoint.z + 2*lenOfRoad 
    pop     edx 

    mov     eax, [P1pN]
    fst     [eax + Vector3.z]
    mov     eax, [P2pP]
    fst     [eax + Vector3.z] 
    mov     edx, UNITLENGTH
    push    edx 
    fadd    dword[esp]              ; StartPoint.z + 2*lenOfRoad + unitLen
    pop     edx 
    mov     eax, [P2pM]
    fstp    [eax + Vector3.z] 

    lea     eax, [dirVector_up]
    mov     [F1pM], eax
    mov     [F2pM], eax 
    lea     eax, [dirVector_left]
    mov     [F1pN], eax 
    lea     eax, [dirVector_right]
    mov     [F2pP], eax

    jmp     .store 

.down:

    mov     edx, [pStartPoint]
    fld     [edx + Vector3.z]       ; StartPoint.z
    mov     edx, ROADLENGTHTWICE
    push    edx 
    fsub    dword[esp]              ; StartPoint.z - 2*lenOfRoad 
    pop     edx 

    mov     eax, [P1pN]
    fst     [eax + Vector3.z]
    mov     eax, [P2pP]
    fst     [eax + Vector3.z] 
    mov     edx, UNITLENGTH
    push    edx 
    fsub    dword[esp]              ; StartPoint.z - 2*lenOfRoad - unitLen
    pop     edx 
    mov     eax, [P2pM]
    fstp    [eax + Vector3.z] 

    lea     eax, [dirVector_down]
    mov     [F1pM], eax
    mov     [F2pM], eax 
    lea     eax, [dirVector_right]
    mov     [F1pN], eax 
    lea     eax, [dirVector_left]
    mov     [F2pP], eax

    jmp     .store


.store:

; camerapos array of spline points 
    mov     eax, [SPCameraPos]
    mov     edx, [P1pP]
    mov     [eax + Spline.Point.pDirectionPrev], edx 
    mov     edx, [P1pM]
    mov     [eax + Spline.Point.pMainVertex], edx 
    mov     edx, [P1pN]
    mov     [eax + Spline.Point.pDirectionNext], edx 
    mov     edx, [esi + Scene.sceneDuration]
    mov     [eax + Spline.Point.time], edx

    add     eax, sizeof.Spline.Point  
    mov     edx, [P2pP]
    mov     [eax + Spline.Point.pDirectionPrev], edx 
    mov     edx, [P2pM]
    mov     [eax + Spline.Point.pMainVertex], edx 
    mov     edx, [P2pN]
    mov     [eax + Spline.Point.pDirectionNext], edx 
    mov     edx, 1000000000000.0
    mov     [eax + Spline.Point.time], edx

; front array of spline points 
    mov     eax, [SPFront]
    mov     edx, [F1pP]
    mov     [eax + Spline.Point.pDirectionPrev], edx 
    mov     edx, [F1pM]
    mov     [eax + Spline.Point.pMainVertex], edx 
    mov     edx, [F1pN]
    mov     [eax + Spline.Point.pDirectionNext], edx 
    mov     edx, [esi + Scene.sceneDuration]
    mov     [eax + Spline.Point.time], edx

    add     eax, sizeof.Spline.Point  
    mov     edx, [F2pP]
    mov     [eax + Spline.Point.pDirectionPrev], edx 
    mov     edx, [F2pM]
    mov     [eax + Spline.Point.pMainVertex], edx 
    mov     edx, [F2pN]
    mov     [eax + Spline.Point.pDirectionNext], edx 
    mov     edx, 10000000000000.0
    mov     [eax + Spline.Point.time], edx

    mov     eax, [esi + Scene.movement] ; now has a pointer to SpectatorData struct 
    mov     edx, [SPCameraPos]
    mov     [eax + SpectatorData.SPCameraPos], edx 
    mov     [eax + SpectatorData.splineCameraPosData + Spline.points], edx 
    mov     [eax + SpectatorData.splineCameraPosData + Spline.pointsCount], 2
    ; mov     [eax + SpectatorData.splineCameraPosData + Spline.cycle], SPLINE_NOT_LOOPED
    fld1 
    fadd    [esi + Scene.sceneDuration]
    fstp    [eax + SpectatorData.splineCameraPosData + Spline.time]  

    mov     edx, [SPFront]
    mov     [eax + SpectatorData.SPFront], edx 
    mov     [eax + SpectatorData.splineFrontData + Spline.points], edx 
    mov     [eax + SpectatorData.splineFrontData + Spline.pointsCount], 2
    ; mov     [eax + SpectatorData.splineFrontData + Spline.cycle], SPLINE_NOT_LOOPED
    fld1 
    fadd    [esi + Scene.sceneDuration]
    fstp    [eax + SpectatorData.splineFrontData + Spline.time]  
.return:
    ret 
endp 