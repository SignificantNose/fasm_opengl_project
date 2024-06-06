proc Choice.InitializeChoice uses edi,\
    pScene, chIndex, pStandingPoint, standingDirection

    mov     edi, [pScene]
    invoke  HeapAlloc, [hHeap], 8, sizeof.ChoiceData
    mov     [edi + Scene.movement], eax 
    mov     edi, eax 

; initializing the choice
    ; stdcall Rand.GetRandomInBetween, 1, 2
    stdcall Rand.MyGen, 1, 2
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

proc Choice.ApplyChoice uses ebx esi edi,\
    pChoiceData

    locals 
        nextStartPoint      Vector3
        nextEndPoint        Vector3
        prevDir             dd      ?
        nextDir             dd      ?
        nextLvlObstacles    dd      ?
        nextLvlDifficulty   dd      ?
    endl 

; save the choice 
    mov     esi, [pChoiceData]
    xor     eax, eax
    movzx   ecx, byte[esi + ChoiceData.choiceIndex]
    test    [esi + ChoiceData.choiceHasBeenMade], 00000010b
    jnz     .secondChoice
.firstChoice:
    mov     eax, 1
    shl     eax, cl 
    or      [Choice.Value], al 
.secondChoice:
    

    jecxz   .nextLvlMedium
    jmp     .nextLvlHard 
.nextLvlMedium:
    mov     [nextLvlObstacles], 40
    mov     [nextLvlDifficulty], DIFFICULTY_MEDIUM
    jmp     .getNextDirection
.nextLvlHard:
    mov     [nextLvlObstacles], 38
    mov     [nextLvlDifficulty], DIFFICULTY_HARD
.getNextDirection:

    mov     ecx, eax
    movzx   eax, [esi + ChoiceData.choiceDirectionIndex]
    JumpIf  DIRECTION_DOWN, .prevDown
    JumpIf  DIRECTION_UP, .prevUp 
    JumpIf  DIRECTION_LEFT, .prevLeft 
    JumpIf  DIRECTION_RIGHT, .prevRight

.prevDown:
    jecxz   .downChoiceSet
    mov     ebx, DIRECTION_LEFT 
    jmp     .initScenes
.downChoiceSet:
    mov     ebx, DIRECTION_RIGHT 
    jmp     .initScenes

.prevUp:
    jecxz   .upChoiceSet
    mov     ebx, DIRECTION_RIGHT 
    jmp     .initScenes
.upChoiceSet:
    mov     ebx, DIRECTION_LEFT 
    jmp     .initScenes


.prevLeft:
    jecxz   .leftChoiceSet
    mov     ebx, DIRECTION_UP 
    jmp     .initScenes
.leftChoiceSet:
    mov     ebx, DIRECTION_DOWN 
    jmp     .initScenes

.prevRight:
    jecxz   .rightChoiceSet
    mov     ebx, DIRECTION_DOWN 
    jmp     .initScenes
.rightChoiceSet:
    mov     ebx, DIRECTION_UP  
    jmp     .initScenes


    ; I need: 
    ; new direction
    ; previous direction
    ; start point 
    ; end point

.initScenes:
    mov     [prevDir], eax
    mov     [nextDir], ebx
; initialize other scenes
    mov     edi, [currentScene]     ; which is the following scene 
    ; add     edi, sizeof.Scene       ; current scene is PreRun
    lea     eax, [esi + ChoiceData.standingPoint]
    stdcall Spectator.PreRunInitialize, edi, [prevDir], ebx, eax        
    ; ! returns ptr to next point that is the starting point for runner
    ; that's why:
    lea     edx, [nextStartPoint]
    stdcall Vector3.Copy, edx, eax

    nop
    add     edi, sizeof.Scene       ; current scene is Runner
    lea     eax, [nextStartPoint]
    stdcall Runner.InitializeRunner, edi, eax, ebx
    ; ! returns pointer to end point of runner
    ; that's why:
    push    eax         ; endRunner
    stdcall Runner.InitializeObstacles, edi, [nextLvlObstacles], [nextLvlDifficulty], ebx
    mov     [currObstacleScene], edi

    add     edi, sizeof.Scene       ; current scene is AfterRun
    ; ; lea     eax, [nextStartPoint]
    ; pop     eax         ; endRunner
    stdcall Spectator.AfterRunInitialize, edi, ebx;, eax      
    ; ! returns pointer to the end point of afterrun   
    lea     edx, [nextEndPoint]
    stdcall Vector3.Copy, edx, eax

    add     edi, sizeof.Scene       ; current scene is Choice 
    cmp     [edi + Scene.mode], SCENEMODE_CHOICE
    jne     .finalsomething    
    lea     eax, [nextEndPoint]
    movzx   edx, byte[esi + ChoiceData.choiceDirectionIndex]
    inc     edx
    stdcall Choice.InitializeChoice, edi, edx, eax, ebx  
    jmp     .return
.finalsomething:
    ; this means final 
    lea     eax, [nextEndPoint]
    stdcall Spectator.InitFinal, edi, eax, ebx

.return:


    ret 
endp