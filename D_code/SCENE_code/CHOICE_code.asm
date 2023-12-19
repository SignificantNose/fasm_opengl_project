proc Choice.InitializeChoice uses edi,\
    pScene, chIndex, pStandingPoint, pStandingDirection

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

    mov     eax, [pStandingPoint]
    lea     edx, [edi + ChoiceData.standingPoint]
    stdcall Vector3.Copy, edx, eax 
    mov     eax, [pStandingDirection]
    lea     edx, [edi + ChoiceData.standingDirection]
    stdcall Vector3.Copy, edx, eax

; ; initializing next scenes' data
;     mov     ecx, [pNextPointFirst]
;     mov     [edx + ChoiceData.pFirstDestPoint], ecx 
;     mov     ecx, [pNextPointFirst]
;     mov     [edx + ChoiceData.pSecondDestPoint], ecx

    ret 
endp

proc Choice.ApplyChoice,\
    pChoiceData

    mov     eax, [pChoiceData]
    mov     cl, byte[eax + ChoiceData.choiceIndex]
    test    [eax + ChoiceData.choiceHasBeenMade], 00000010b
    jz      .secondChoice
.firstChoice:
    mov     al, 1
    shl     al, cl 
    or      [Choice.Value], al 
.secondChoice:



    ret 
endp