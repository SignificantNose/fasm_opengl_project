; routine that finds the linear interpolation
; between vectors v1 and v2 and stores the
; interpolation value in result (f is the 
; interpolation phase)
proc Movement.Interpolate uses esi edi ebx,\
     v1, v2, result, f

        locals
                r       dd      ?
        endl

        mov     esi, [v1]
        mov     edi, [v2]
        mov     ebx, [result]

        fld1
        fsub    [f]
        fstp    [r]

        fld     [esi + Vector3.x]
        fmul    [r]
        fld     [edi + Vector3.x]
        fmul    [f]
        faddp
        fstp    [ebx + Vector3.x]

        fld     [esi + Vector3.y]
        fmul    [r]
        fld     [edi + Vector3.y]
        fmul    [f]
        faddp
        fstp    [ebx + Vector3.y]

        fld     [esi + Vector3.z]
        fmul    [r]
        fld     [edi + Vector3.z]
        fmul    [f]
        faddp
        fstp    [ebx + Vector3.z]

        ret
endp

; routine that performs cubic interpolation
; between 4 vectors: v1, d1, d2 and v2 and
; stores the interpolation value in result
; (f is the interpolation phase)
proc Movement.CubicInterpolate uses esi edi ebx,\
     v1, d1, d2, v2, result, f

        locals
                p0      Vector3
                p1      Vector3
                p2      Vector3
        endl

        lea     esi, [p0]
        lea     edi, [p1]
        lea     ebx, [p2]

        stdcall Movement.Interpolate, [v1], [d1], esi, [f]
        stdcall Movement.Interpolate, [d1], [d2], edi, [f]
        stdcall Movement.Interpolate, [d2], [v2], ebx, [f]
        stdcall Movement.Interpolate, esi, edi, esi, [f]
        stdcall Movement.Interpolate, edi, ebx, edi, [f]
        stdcall Movement.Interpolate, esi, edi, [result], [f]

        ret
endp



; routine that takes a spline and interpolates 
; the value for the current time moment and 
; stores the interpolation value in result
; vector
proc Spline.GetPoint uses esi edi ebx,\
     spline, result, time

        locals
                t       dd      ?
                t2      dd      ?
                t1      dd      ?
                f       dd      ?
                index   dd      ?
        endl

        mov     esi, [spline]

        cmp     [esi + Spline.cycle], SPLINE_LOOPED
        je      .DoNotCheck

        fld     [esi + Spline.time]                     ; tc
        fld     [time]                                  ; ts, tc
        fcomip  st0, st1                                ; tc
        fstp    [esi + Spline.time]                     ;
        ja      .Return                                 ; ts < tc

.DoNotCheck:
        mov     [index], 0

        fld     [esi + Spline.time]                     ; tc
        fld     [time]                                  ; ts, tc
        fprem                                           ; t, tc
        fstp    [t]                                     ; tc
        fstp    [esi + Spline.time]                     ;

        fldz                                            ; 0

        mov     ecx, [esi + Spline.pointsCount]
        mov     ebx, [esi + Spline.points]

.CheckPointsLoop:
        fadd    [ebx + Spline.Point.time]               ; t2
        fld     [t]                                     ; t, t2
        fcomip  st0, st1                                ; t2
        jb      .FoundTransition                        ; if t < t2

        add     ebx, sizeof.Spline.Point
        inc     [index]

        loop    .CheckPointsLoop

.FoundTransition:
        fst     [t2]                                    ; t2
        fld     st0                                     ; t2, t2
        fsub    [ebx + Spline.Point.time]               ; t1, t2
        fst     [t1]                                    ; t1, t2
        fsubp                                           ; (t2 - t1)
        fld     [t]                                     ; t, (t2 - t1)
        fsub    [t1]                                    ; (t - t1), (t2 - t1)
        fdivrp                                          ; f
        fstp    [f]                                     ;

        mov     eax, sizeof.Spline.Point
        xor     edx, edx
        mul     [index]

        mov     ebx, [spline]
        mov     esi, [ebx + Spline.points]
        add     esi, eax

        mov     edi, esi
        add     edi, sizeof.Spline.Point

        mov     ecx, [index]
        inc     ecx
        cmp     ecx, [ebx + Spline.pointsCount]
        jne     .Calculate
        mov     edi, [ebx + Spline.points]

.Calculate:
        stdcall Movement.CubicInterpolate, [esi + Spline.Point.pMainVertex],\
                        [esi + Spline.Point.pDirectionNext],\
                        [edi + Spline.Point.pDirectionPrev],\
                        [edi + Spline.Point.pMainVertex], [result], [f]

.Return:
        ret
endp