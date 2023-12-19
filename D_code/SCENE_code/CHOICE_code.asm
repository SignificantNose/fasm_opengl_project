proc Choice.InitializeChoice uses edi,\
    pScene, chIndex, pStandingPoint, standingDirection

    mov     edi, [pScene]
    invoke  HeapAlloc, [hHeap], 8, sizeof.ChoiceData
    mov     [edi + Scene.movement], eax 
    mov     edi, eax 

; initializing the choice
    stdcall Rand.GetRandomInBetween, 1, 2
    mov     ecx, 1
    xchg    ecx, eax 
    shl     eax, cl
; too complex. must be simpler 
    mov     [edi + ChoiceData.choiceHasBeenMade], al 

; initializing choice index
    mov     ecx, [chIndex]
    mov     [edi + ChoiceData.choiceIndex], cl 

; saving standing point 
    mov     eax, [pStandingPoint]
    lea     edx, [edi + ChoiceData.standingPoint]
    stdcall Vector3.Copy, edx, eax 
    

; initializing standing direction
    mov     eax, [standingDirection]
    mov     [edi + ChoiceData.choiceDirectionIndex], al 
    JumpIf  DIRECTION_UP, .up 
    JumpIf  DIRECTION_DOWN, .down 
    JumpIf  DIRECTION_LEFT, .left 
    JumpIf  DIRECTION_RIGHT, .right 
.up:
    lea     eax, [dirVector_up]
    jmp     .copyDirection
.down:
    lea     eax, [dirVector_down]
    jmp     .copyDirection
.left:
    lea     eax, [dirVector_left]
    jmp     .copyDirection
.right:
    lea     eax, [dirVector_right]
    
.copyDirection:
    lea     edx, [edi + ChoiceData.standingDirection]
    stdcall Vector3.Copy, edx, eax

; ; initializing next scenes' data
;     mov     ecx, [pNextPointFirst]
;     mov     [edx + ChoiceData.pFirstDestPoint], ecx 
;     mov     ecx, [pNextPointFirst]
;     mov     [edx + ChoiceData.pSecondDestPoint], ecx

    ret 
endp

proc Choice.ApplyChoice uses edi,\
    pChoiceData

; save the choice 
    mov     eax, [pChoiceData]
    mov     cl, byte[eax + ChoiceData.choiceIndex]
    test    [eax + ChoiceData.choiceHasBeenMade], 00000010b
    jz      .secondChoice
.firstChoice:
    mov     al, 1
    shl     al, cl 
    or      [Choice.Value], al 
.secondChoice:

; initialize other scenes
    mov     edi, [currentScene]     ; which is the following scene 
    

    ; pre init
    ; runner init
    ; after init 
    ; choice init



    ret 
endp