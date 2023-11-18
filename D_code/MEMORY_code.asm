; used in shifthing the buffers, that's
; why the copying process is from the
; end of each of the buffers, as the
; buffers might intersect
proc Memory.memcpy uses esi edi,\
    pDest, pSrc, countByte

    mov     ecx, [countByte]
    dec     ecx
    mov     esi, [pSrc]
    add     esi, ecx
    mov     edi, [pDest]
    add     edi, ecx
    inc     ecx
    pushf
    std
    rep     movsb    
    popf

    ret
endp