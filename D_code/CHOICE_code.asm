proc Choice.InitializeChoice uses edi,\
    pScene, chIndex, pNextPointFirst, pNextPointSecond

    mov     edi, [pScene]
    invoke  HeapAlloc, [hHeap], 8, sizeof.ChoiceData
    mov     [edi + Scene.movement], eax 

; initializing the choice
    push    eax 
    stdcall Rand.GetRandomInBetween, 1, 2
    nop
    pop     edx 
    mov     ecx, 1
    xchg    ecx, eax 
    shl     eax, cl
; too complex. must be simpler 
    mov     [edx + ChoiceData.choiceHasBeenMade], al 

; initializing choice index
    mov     ecx, [chIndex]
    mov     [edx + ChoiceData.choiceIndex], cl 

; initializing next scenes' data
    mov     ecx, [pNextPointFirst]
    mov     [edx + ChoiceData.pFirstDestPoint], ecx 
    mov     ecx, [pNextPointFirst]
    mov     [edx + ChoiceData.pSecondDestPoint], ecx

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