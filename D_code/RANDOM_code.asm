proc    Rand.GetRandomNumber uses ebx, minValue, maxValue
        mov             eax, [seed]
        or              eax, eax
        jnz             label2
label1:
        invoke          GetTickCount 
        or              eax, eax
        jz              label1
label2:
        xor             edx, edx
        mov             ebx, 127773
        div             ebx
        push            eax 
        mov             eax, 16807 
        mul             edx 
        pop             edx 
        push            eax 
        mov             eax, 2836 
        mul             edx 
        pop             edx 
        sub             edx, eax 
        mov             eax, edx 
        mov             [seed], edx
        xor             edx, edx
        mov             ebx, [maxValue]
        sub             ebx, [minValue]
        inc             ebx
        div             ebx
        mov             eax, edx
        add             eax, [minValue]
        mov             [RandomValue], eax

        ;mov eax, 6
        ret
endp


proc Rand.MyGen, Min, Max
        mov eax, [RandValue]
.myLabel1:
        test eax, eax
        jnz .myLabel2
        invoke  GetTickCount
        jmp .myLabel1
.myLabel2:
        ;xor     edx, edx
        ;mov     ecx, 69069
        ;mul     ecx
        ;adc     eax, 5
        ;rol      eax, 32
        ;adc      eax, 23
        mov     ecx, 8088405h                     ;or: imul    edx, seed, 8088405h
        xor     edx, edx
        mul     ecx

        mov     ecx, [Max]
        sub     ecx, [Min]
        inc     ecx
        xor     edx, edx
        div     ecx
        mov     eax, edx
        add     eax, [Min]
        mov     [RandValue], eax
        ret
endp

