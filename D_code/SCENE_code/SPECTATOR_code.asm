proc Spectator.InitializeSpectator,\
    pScene, pSplineCamPos, pSplineFront

    invoke  HeapAlloc, [hHeap], 8, sizeof.SpectatorData
    push    eax     ; spectatorData
    mov     edx, [pScene]
    mov     [edx + Scene.movement], eax 
    mov     edx, [pSplineCamPos]
    lea     eax, [eax + SpectatorData.splineCameraPosData]
    stdcall Memory.memcpy, eax, edx, sizeof.Spline

    pop     eax     ; spectatorData
    mov     edx, [pSplineFront]
    lea     eax, [eax + SpectatorData.splineFrontData]
    stdcall Memory.memcpy, eax, edx, sizeof.Spline


    ret 
endp