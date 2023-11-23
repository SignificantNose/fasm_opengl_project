proc Debug.OutputValueDec,\
    value

    stdcall    Debug.IntToDecString, debugOutValue, [value]
    invoke     OutputDebugString, debugOutStartStr
    
    ret
endp

proc Debug.OutputValueHex,\
    value

    stdcall    Debug.IntToHexString, debugOutValue, [value]
    invoke     OutputDebugString, debugOutStartStr
    
    ret
endp

proc Debug.IntToHexString uses ebx edi,\
    dest, value

    mov   edi, [dest]
    mov   ecx, 8
    xor   eax, eax
    rep stosb    

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

    mov     edi, [dest]
    mov     ecx, 8
    xor     eax, eax
    rep stosb 

    mov     edi, [dest]
    mov     eax, [value]
    xor     ebx, ebx        
 .push_chars:
    xor     edx, edx  
    mov     ecx, 10       
    div     ecx               
    add     edx, 0x30         
    push    edx  
    inc     ebx              
    test    eax, eax 
    jnz     .push_chars       
 .pop_chars:
    pop     eax               
    stosb                 
    dec     ebx               
    cmp     ebx, 0             
    jg  .pop_chars         

    ret                   
endp