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

        ;mov eax, 6
        ret
endp


