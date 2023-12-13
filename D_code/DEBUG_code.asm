proc Debug.OutputValueDec uses edi,\
    value

    mov     edi, debugOutValue
    mov     ecx, 8
    xor     eax, eax
    rep stosb 

    stdcall    Debug.IntToDecString, debugOutValue, [value]
    invoke     OutputDebugString, dbgStartDefault
    
    ret
endp

proc Debug.OutputValueHex uses edi,\
    value

    mov     edi, debugOutValue
    mov     ecx, 8
    xor     eax, eax
    rep stosb 

    stdcall    Debug.IntToHexString, debugOutValue, [value]
    invoke     OutputDebugString, dbgStartDefault
    
    ret
endp

proc Debug.OutputValueFloat,\
    value

    mov     edi, debugOutFloatValue
    mov     ecx, 64
    xor     eax, eax
    rep stosb 

    fld     [value]     ; v
    fld1                ; 1, v
    fld     st1         ; v, 1, v
    fprem               ; 0.xxx, 1, v
    fstp    st1         ; 0.xxx, v
    fsubp               ; v
    push    eax 
    fistp   dword[esp]

    stdcall Debug.IntToDecString, debugOutFloatValue

    push    eax

    fld1                ; 1
    fld     [value]     ; v, 1
    fprem               ; 0.xxx, 1
    fstp    st1         ; 0.xxx
    mov     eax, 1000000
    push    eax 
    fmul    dword[esp]  ; expPart
    fabs 
    fstp    dword[esp]
    pop     eax 


    mov     edi, debugOutFloatValue 
    pop     edx 
    add     edi, edx 
    push    eax 
    mov     al, '.'
    stosb   
    pop     eax 
    
    stdcall Debug.IntToDecStringZeroExtended, edi, eax, 6
    invoke  OutputDebugString, dbgStartFloat

    ret 
endp

proc    Debug.OutputTickCount,\
    valueTicks

    mov     edi, dbgOutValueCount
    mov     ecx, 8
    xor     eax, eax
    rep stosb 

    stdcall    Debug.IntToDecString, dbgOutValueCount, [valueTicks]
    invoke     OutputDebugString, dbgStartCountTicks

    ret 
endp

proc Debug.IntToHexString uses ebx edi,\
    dest, value

    mov   edi, [dest]
    mov   ebx, [value]

    mov   ecx, 8

.looper:
    rol  ebx, 4
    mov  eax, ebx
    and  eax, 0000000Fh
    
    cmp  al, $0A
    sbb  al, $69
    das
    stosb
     
    loop .looper
    ret                   ; return to main
endp

proc Debug.IntToDecString uses ebx edi,\
    dest, value

    locals
        isNegative              db      0 
        amntOfCharacters        dd      ?
    endl 

    mov     edi, [dest]
    mov     eax, [value]
    xor     ebx, ebx        

    cmp     eax, 0
    jge     @F
    neg     eax 
    mov     [isNegative], 1
@@:

 .push_chars:
    xor     edx, edx  
    mov     ecx, 10       
    div     ecx               
    add     edx, 0x30         
    push    edx  
    inc     ebx              
    test    eax, eax 
    jnz     .push_chars       

    movzx   eax, [isNegative]
    cmp     eax, 0
    je      .notNegative
    inc     ebx 
    push    '-'
.notNegative:

    mov     [amntOfCharacters], ebx

 .pop_chars:
    pop     eax               
    stosb                 
    dec     ebx               
    cmp     ebx, 0             
    jg  .pop_chars         

    mov     eax, [amntOfCharacters]

    ret                   
endp

proc Debug.IntToDecStringZeroExtended uses ebx edi,\
    dest, value, amntOfPositions

    mov     edi, [dest]
    mov     ecx, [amntOfPositions]
    inc     ecx
    xor     eax, eax
    rep stosb 

    mov     edi, [dest]
    mov     eax, [value]
    xor     ebx, ebx    


    mov     ecx, [amntOfPositions]
 .push_chars:
    xor     edx, edx  
    mov     ebx, 10       
    div     ebx               
    add     edx, 0x30         
    push    edx               
    loop   .push_chars       

    mov     ecx, [amntOfPositions]
 .pop_chars:
    pop     eax               
    stosb                 
    loop  .pop_chars         

    ret                   
endp

proc Debug.PrintThreadInfo

    invoke     OutputDebugString, debugOutThreadPing

    ret
endp 