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



; ! warning ! returns pointer to the end point of afterrun
proc Spectator.AfterRunInitialize uses ebx esi edi,\
    pScene, direction, pDestPoint 

    locals
        pFrontMain      dd  ?
        pFrontSecond    dd  ?
        pFrontThird     dd  ?
    endl 

    mov     esi, [pScene]
    invoke  HeapAlloc, [hHeap], 8, sizeof.SpectatorData
    mov     [esi + Scene.movement], eax
    xchg    edi, eax                        ; edi now points to SpectatorData struct


; allocating memory for camera position spline
    invoke  HeapAlloc, [hHeap], 8, sizeof.Spline.Point*2
    mov     [edi + SpectatorData.SPCameraPos], eax 

    mov     [edi + SpectatorData.splineCameraPosData + Spline.pointsCount], 2
    mov     [edi + SpectatorData.splineCameraPosData + Spline.points], eax 
    fld1
    fadd    [esi + Scene.sceneDuration]
    fstp    [edi + SpectatorData.splineCameraPosData + Spline.time]
    xchg    eax, ebx

; allocating memory for camera front spline 
    invoke  HeapAlloc, [hHeap], 8, sizeof.Spline.Point*2
    mov     [edi + SpectatorData.SPFront], eax

    mov     [edi + SpectatorData.splineFrontData + Spline.pointsCount], 2
    mov     [edi + SpectatorData.splineFrontData + Spline.points], eax 
    fld1
    fadd    [esi + Scene.sceneDuration]
    fstp    [edi + SpectatorData.splineFrontData + Spline.time]
    xchg    edi, eax

; initializing spline points
    ; edi points to an array of camerafront points
    ; ebx points to an array of camerapos points

    invoke  HeapAlloc, [hHeap], 8, sizeof.Vector3 
    push    eax
    stdcall Vector3.Copy, eax, [pDestPoint]
    pop     eax 

    xchg    ebx, edi 
    ; now edi points at camerapos array 
    mov     ecx, 3
    rep     stosd 
    mov     edx, [esi + Scene.sceneDuration]
    xchg    edx, eax        ; now edx has ptr, eax has time value 
    stosd 

    xchg    edx, eax        ; now edx has time value, eax has ptr
    mov     ecx, 3
    rep     stosd 
    mov     eax, 100000.0
    stosd


    xchg    edi, ebx 
    ; now edi points at camerafront points 

; main direction initialization 
    ; invoke  HeapAlloc, [hHeap], 8, sizeof.Vector3 
    ; stdcall Vector3.Copy, eax, []
    mov     eax, [direction]
    JumpIf  DIRECTION_UP, .up
    JumpIf  DIRECTION_DOWN, .down
    JumpIf  DIRECTION_LEFT, .left
    JumpIf  DIRECTION_RIGHT, .right
.up:
    lea     eax, [dirVector_up]
    lea     edx, [dirVector_left]
    lea     ecx, [dirVector_right]
    jmp     .storeVectors
.down:
    lea     eax, [dirVector_down]
    lea     edx, [dirVector_right]
    lea     ecx, [dirVector_left]
    jmp     .storeVectors
.left:
    lea     eax, [dirVector_left]
    lea     edx, [dirVector_down]
    lea     ecx, [dirVector_up]
    jmp     .storeVectors
.right:
    lea     eax, [dirVector_right]
    lea     edx, [dirVector_up]
    lea     ecx, [dirVector_down]
.storeVectors:

    push    ecx     ; thirdTemplate
    push    edx     ; secondTemplate
    push    eax     ; mainTemplate

    invoke  HeapAlloc, [hHeap], 8, sizeof.Vector3 
    pop     edx     ; mainTemplate
    push    eax     ; main
    stdcall Vector3.Copy, eax, edx
    pop     edx     ; main 
    mov     [edi + Spline.Point.pMainVertex], edx 
    mov     [edi + Spline.Point.pDirectionPrev], edx
    mov     [edi + sizeof.Spline.Point + Spline.Point.pMainVertex], edx
    mov     [edi + sizeof.Spline.Point + Spline.Point.pDirectionNext], edx

    invoke  HeapAlloc, [hHeap], 8, sizeof.Vector3 
    pop     edx     ; secondTemplate 
    push    eax     ; second
    stdcall Vector3.Copy, eax, edx 
    pop     edx     ; second  
    mov     [edi + Spline.Point.pDirectionNext], edx 

    invoke  HeapAlloc, [hHeap], 8, sizeof.Vector3
    pop     edx     ; thirdTemplate
    push    eax     ; third
    stdcall Vector3.Copy, eax, edx
    pop     edx 
    mov     [edi + sizeof.Spline.Point + Spline.Point.pDirectionPrev], edx 

    mov     eax, [esi + Scene.sceneDuration]
    mov     [edi + Spline.Point.time], eax
    mov     eax, 1000000.0
    mov     [edi + sizeof.Spline.Point + Spline.Point.time], eax 

    mov     eax, [pDestPoint]

    ret 
endp 

; ! warning ! returns pointer to the end point of afterrun
; proc Spectator.AfterRunInitialize uses esi edi,\
;     pScene, direction, pStartPoint 

;     locals  
;         P1pP            dd      ? 
;         P1pM            dd      ?
;         P1pN            dd      ?     
;         P2pP            dd      ? 
;         P2pM            dd      ? 
;         P2pN            dd      ?  
;         F1pP            dd      ?
;         F1pM            dd      ?
;         F1pN            dd      ?
;         F2pP            dd      ?
;         F2pM            dd      ?
;         F2pN            dd      ?  
;         SPCameraPos     dd      ?
;         SPFront         dd      ?
;     endl 

;     mov     ecx, 12 
;     lea     edi, [P1pP]
; .loopAlloc:
;     push    ecx 
;     invoke  HeapAlloc, [hHeap], 8, sizeof.Vector3
;     stosd   
;     pop     ecx 
;     loop    .loopAlloc 

;     lea     edi, [P1pP]
;     mov     ecx, 6 
; .loopCopy:
;     push    ecx 
;     mov     eax, [edi] 
;     stdcall Vector3.Copy, eax, [pStartPoint]
;     add     edi, 4
;     pop     ecx 
;     loop    .loopCopy 

;     mov     esi, [pScene]
;     invoke  HeapAlloc, [hHeap], 8, sizeof.SpectatorData 
;     mov     [esi + Scene.movement], eax 
;     mov     edi, eax

; ; i have the memory for spline. i need the points
;     invoke  HeapAlloc, [hHeap], 8 sizeof.Spline.Point*2
;     mov     [edi + SpectatorData.SPCameraPos], eax 
;     mov     [SPCameraPos], eax 
;     invoke  HeapAlloc, [hHeap], 8, sizeof.Spline.Point*2
;     mov     [edi + SpectatorData.SPFront], eax 
;     mov     [SPFront], eax



;     mov     eax, [direction]
;     JumpIf  DIRECTION_LEFT, .left 
;     JumpIf  DIRECTION_RIGHT, .right
;     JumpIf  DIRECTION_UP, .up 
;     JumpIf  DIRECTION_DOWN, .down 
;     jmp     .return 
; .left:
;     mov     edx, [pStartPoint]
;     fld     [edx + Vector3.x]       ; StartPoint.x
;     mov     edx, ROADLENGTHTWICE
;     push    edx 
;     fadd    dword[esp]              ; StartPoint.x + 2*lenOfRoad 
;     pop     edx 

;     mov     eax, [P1pN]
;     fst     [eax + Vector3.x]
;     mov     eax, [P2pP]
;     fst     [eax + Vector3.x] 
;     mov     edx, UNITLENGTH
;     push    edx 
;     fadd    dword[esp]              ; StartPoint.x + 2*lenOfRoad + unitLen
;     pop     edx 
;     mov     eax, [P2pM]
;     fstp    [eax + Vector3.x] 

;     lea     eax, [dirVector_left]
;     mov     [F1pM], eax
;     mov     [F2pM], eax 
;     lea     eax, [dirVector_down]
;     mov     [F1pN], eax 
;     lea     eax, [dirVector_up]
;     mov     [F2pP], eax

;     jmp     .store

; .right:
;     mov     edx, [pStartPoint]
;     fld     [edx + Vector3.x]       ; StartPoint.x
;     mov     edx, ROADLENGTHTWICE
;     push    edx 
;     fsub    dword[esp]              ; StartPoint.x - 2*lenOfRoad 
;     pop     edx 

;     mov     eax, [P1pN]
;     fst     [eax + Vector3.x]
;     mov     eax, [P2pP]
;     fst     [eax + Vector3.x] 
;     mov     edx, UNITLENGTH
;     push    edx 
;     fsub    dword[esp]              ; StartPoint.x - 2*lenOfRoad - unitLen
;     pop     edx 
;     mov     eax, [P2pM]
;     fstp    [eax + Vector3.x] 

;     lea     eax, [dirVector_right]
;     mov     [F1pM], eax
;     mov     [F2pM], eax 
;     lea     eax, [dirVector_up]
;     mov     [F1pN], eax 
;     lea     eax, [dirVector_down]
;     mov     [F2pP], eax

;     jmp     .store

; .up:

;     mov     edx, [pStartPoint]
;     fld     [edx + Vector3.z]       ; StartPoint.z
;     mov     edx, ROADLENGTHTWICE
;     push    edx 
;     fadd    dword[esp]              ; StartPoint.z + 2*lenOfRoad 
;     pop     edx 

;     mov     eax, [P1pN]
;     fst     [eax + Vector3.z]
;     mov     eax, [P2pP]
;     fst     [eax + Vector3.z] 
;     mov     edx, UNITLENGTH
;     push    edx 
;     fadd    dword[esp]              ; StartPoint.z + 2*lenOfRoad + unitLen
;     pop     edx 
;     mov     eax, [P2pM]
;     fstp    [eax + Vector3.z] 

;     lea     eax, [dirVector_up]
;     mov     [F1pM], eax
;     mov     [F2pM], eax 
;     lea     eax, [dirVector_left]
;     mov     [F1pN], eax 
;     lea     eax, [dirVector_right]
;     mov     [F2pP], eax

;     jmp     .store 

; .down:

;     mov     edx, [pStartPoint]
;     fld     [edx + Vector3.z]       ; StartPoint.z
;     mov     edx, ROADLENGTHTWICE
;     push    edx 
;     fsub    dword[esp]              ; StartPoint.z - 2*lenOfRoad 
;     pop     edx 

;     mov     eax, [P1pN]
;     fst     [eax + Vector3.z]
;     mov     eax, [P2pP]
;     fst     [eax + Vector3.z] 
;     mov     edx, UNITLENGTH
;     push    edx 
;     fsub    dword[esp]              ; StartPoint.z - 2*lenOfRoad - unitLen
;     pop     edx 
;     mov     eax, [P2pM]
;     fstp    [eax + Vector3.z] 

;     lea     eax, [dirVector_down]
;     mov     [F1pM], eax
;     mov     [F2pM], eax 
;     lea     eax, [dirVector_right]
;     mov     [F1pN], eax 
;     lea     eax, [dirVector_left]
;     mov     [F2pP], eax

;     jmp     .store


; .store:

; ; camerapos array of spline points 
;     mov     eax, [SPCameraPos]
;     mov     edx, [P1pP]
;     mov     [eax + Spline.Point.pDirectionPrev], edx 
;     mov     edx, [P1pM]
;     mov     [eax + Spline.Point.pMainVertex], edx 
;     mov     edx, [P1pN]
;     mov     [eax + Spline.Point.pDirectionNext], edx 
;     mov     edx, [esi + Scene.sceneDuration]
;     mov     [eax + Spline.Point.time], edx

;     add     eax, sizeof.Spline.Point  
;     mov     edx, [P2pP]
;     mov     [eax + Spline.Point.pDirectionPrev], edx 
;     mov     edx, [P2pM]
;     mov     [eax + Spline.Point.pMainVertex], edx 
;     mov     edx, [P2pN]
;     mov     [eax + Spline.Point.pDirectionNext], edx 
;     mov     edx, 1000000000000.0
;     mov     [eax + Spline.Point.time], edx

; ; front array of spline points 
;     mov     eax, [SPFront]
;     mov     edx, [F1pP]
;     mov     [eax + Spline.Point.pDirectionPrev], edx 
;     mov     edx, [F1pM]
;     mov     [eax + Spline.Point.pMainVertex], edx 
;     mov     edx, [F1pN]
;     mov     [eax + Spline.Point.pDirectionNext], edx 
;     mov     edx, [esi + Scene.sceneDuration]
;     mov     [eax + Spline.Point.time], edx

;     add     eax, sizeof.Spline.Point  
;     mov     edx, [F2pP]
;     mov     [eax + Spline.Point.pDirectionPrev], edx 
;     mov     edx, [F2pM]
;     mov     [eax + Spline.Point.pMainVertex], edx 
;     mov     edx, [F2pN]
;     mov     [eax + Spline.Point.pDirectionNext], edx 
;     mov     edx, 10000000000000.0
;     mov     [eax + Spline.Point.time], edx

;     mov     eax, [esi + Scene.movement] ; now has a pointer to SpectatorData struct 
;     mov     edx, [SPCameraPos]
;     mov     [eax + SpectatorData.SPCameraPos], edx 
;     mov     [eax + SpectatorData.splineCameraPosData + Spline.points], edx 
;     mov     [eax + SpectatorData.splineCameraPosData + Spline.pointsCount], 2
;     ; mov     [eax + SpectatorData.splineCameraPosData + Spline.cycle], SPLINE_NOT_LOOPED
;     fld1 
;     fadd    [esi + Scene.sceneDuration]
;     fstp    [eax + SpectatorData.splineCameraPosData + Spline.time]  

;     mov     edx, [SPFront]
;     mov     [eax + SpectatorData.SPFront], edx 
;     mov     [eax + SpectatorData.splineFrontData + Spline.points], edx 
;     mov     [eax + SpectatorData.splineFrontData + Spline.pointsCount], 2
;     ; mov     [eax + SpectatorData.splineFrontData + Spline.cycle], SPLINE_NOT_LOOPED
;     fld1 
;     fadd    [esi + Scene.sceneDuration]
;     fstp    [eax + SpectatorData.splineFrontData + Spline.time]  
; .return:
;     ret 
; endp 

; ! warning ! returns ptr to next point
proc Spectator.PreRunInitialize uses esi edi,\
    pScene, prevDirection, nextDirection, pStartPoint 

    locals
        posStart        dd      ?
        posEnd          dd      ?
        frontStart      dd      ?
        frontEnd        dd      ?

        SPCameraPos     dd      ?
        SPFront         dd      ?
    endl 


; allocating memory for local variables
    mov     ecx, 4
    lea     edi, [posStart]
.loopAlloc:
    push    ecx 
    invoke  HeapAlloc, [hHeap], 8, sizeof.Vector3 
    stosd
    pop     ecx 
    loop    .loopAlloc 

; copying starting point 
    lea     edi, [posStart]
    mov     ecx, 2
.loopCopyStartPos:
    push    ecx 
    mov     eax, [edi]
    stdcall Vector3.Copy, eax, [pStartPoint]
    add     edi, 4
    pop     ecx 
    loop    .loopCopyStartPos 

    mov     esi, [pScene]
    invoke  HeapAlloc, [hHeap], 8, sizeof.SpectatorData 
    mov     [esi + Scene.movement], eax 
    mov     edi, eax

    invoke  HeapAlloc, [hHeap], 8 sizeof.Spline.Point*2
    mov     [edi + SpectatorData.SPCameraPos], eax 
    mov     [SPCameraPos], eax 
    invoke  HeapAlloc, [hHeap], 8, sizeof.Spline.Point*2
    mov     [edi + SpectatorData.SPFront], eax 
    mov     [SPFront], eax

; initializing frontStart 
    mov     eax, [prevDirection]
    JumpIf  DIRECTION_LEFT, .FSleft 
    JumpIf  DIRECTION_RIGHT, .FSright
    JumpIf  DIRECTION_UP, .FSup 
    JumpIf  DIRECTION_DOWN, .FSdown 
    jmp     .return
.FSleft:
    lea     eax, [dirVector_left]
    jmp     .endFS 
.FSright:
    lea     eax, [dirVector_right]
    jmp     .endFS
.FSup:  
    lea     eax, [dirVector_up]
    jmp     .endFS
.FSdown:
    lea     eax, [dirVector_down]
.endFS:
    mov     edx, [frontStart]
    stdcall Vector3.Copy, edx, eax 

; initializing frontEnd
    mov     edx, [posEnd]
    mov     eax, [nextDirection]
    push    UNITLENGTH
    JumpIf  DIRECTION_LEFT, .FEleft 
    JumpIf  DIRECTION_RIGHT, .FEright
    JumpIf  DIRECTION_UP, .FEup 
    JumpIf  DIRECTION_DOWN, .FEdown 
    pop     eax 
    jmp     .return
.FEleft:
    fld     [edx + Vector3.x]           ; x
    fadd    dword[esp]                  ; x + U
    fstp    [edx + Vector3.x]           ; 
    lea     eax, [dirVector_left]
    jmp     .endFE 
.FEright:
    fld     [edx + Vector3.x]           ; x
    fsub    dword[esp]                  ; x - U
    fstp    [edx + Vector3.x]           ; 
    lea     eax, [dirVector_right]
    jmp     .endFE
.FEup:  
    fld     [edx + Vector3.z]           ; z
    fadd    dword[esp]                  ; z + U
    fstp    [edx + Vector3.z]           ; 
    lea     eax, [dirVector_up]
    jmp     .endFE
.FEdown:
    fld     [edx + Vector3.z]           ; z
    fsub    dword[esp]                  ; z - U
    fstp    [edx + Vector3.z]           ; 
    lea     eax, [dirVector_down]
.endFE:
    pop     ecx  
    mov     edx, [frontEnd]
    stdcall Vector3.Copy, edx, eax 

; now all vectors are set. store them :)

; position array of spline points 
    mov     eax, [SPCameraPos]
    mov     edx, [posStart]
    mov     [eax + Spline.Point.pDirectionPrev], edx 
    mov     [eax + Spline.Point.pMainVertex], edx 
    mov     [eax + Spline.Point.pDirectionNext], edx 
    mov     edx, [esi + Scene.sceneDuration]
    mov     [eax + Spline.Point.time], edx

    add     eax, sizeof.Spline.Point  
    mov     edx, [posEnd]
    mov     [eax + Spline.Point.pDirectionPrev], edx 
    mov     [eax + Spline.Point.pMainVertex], edx 
    mov     [eax + Spline.Point.pDirectionNext], edx 
    mov     edx, 1000000000000.0
    mov     [eax + Spline.Point.time], edx

; front array of spline points 
    mov     eax, [SPFront]
    mov     edx, [frontStart]
    mov     [eax + Spline.Point.pDirectionPrev], edx
    mov     [eax + Spline.Point.pMainVertex], edx
    mov     [eax + Spline.Point.pDirectionNext], edx 
    mov     edx, [esi + Scene.sceneDuration]
    mov     [eax + Spline.Point.time], edx

    add     eax, sizeof.Spline.Point  
    mov     edx, [frontEnd]
    mov     [eax + Spline.Point.pDirectionPrev], edx 
    mov     [eax + Spline.Point.pMainVertex], edx 
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

    mov     eax, [posEnd]
.return:
    ret
endp 