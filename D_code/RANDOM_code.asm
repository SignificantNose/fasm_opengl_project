; parameter values for PRNG are taken from this article:
; https://en.wikipedia.org/wiki/Linear_congruential_generator 
proc Rand.MyGen, Min, Max
        mov eax, [RandValue]
.myLabel1:
        test eax, eax
        jnz .myLabel2
        invoke  GetTickCount
        jmp .myLabel1
.myLabel2:
        ; 1) edx:eax = A*Xn
        nop 
        xor     edx, edx
        mov     ecx, 0x0019660D
        mul     ecx 

        ; 2) edx:eax = A*Xn + C
        add     eax, 0x3C6EF35F
        ; adc     edx, 0

        ; 3) eax = (A*Xn+C) mod 2^32
        mov     [RandValue], eax

        mov     ecx, [Max]
        sub     ecx, [Min]
        inc     ecx
        xor     edx, edx
        div     ecx
        mov     eax, edx
        add     eax, [Min]
        ret
endp

; note: rdrand is an extremely slow instruction.
; ; the more preferrable (i.e. later on) way to generate random numbers
; proc Rand.GetRandomInBetween, \
;         min, max
;     rdrand eax
;     mov ecx, [max]
;     sub ecx, [min]
;     inc ecx
;     xor edx, edx
;     div ecx
;     mov eax, edx
;     add eax, [min]
;     ret
; endp
