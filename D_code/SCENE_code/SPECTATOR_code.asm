proc Spectator.InitializeSpectator,\
    pScene, pSpline

    invoke  HeapAlloc, [hHeap], 8, sizeof.SpectatorData
    mov     edx, [pScene]
    mov     [edx + Scene.movement], eax 
    mov     edx, [pSpline]
    lea     eax, [eax + SpectatorData.splineData]
    stdcall Memory.memcpy, eax, edx, sizeof.Spline

    ret 
endp