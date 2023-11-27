; routine for setting up the view matrix.
; multiplies the current matrix (that is
; expected to be an identity matrix) so
; that the camera looks at target, at the
; same time being located at camera position
proc Camera.LookAt uses esi edi ebx,\
     camera, target, up

        locals
                temp    dd              ?
                matrix  Matrix4x4
                zAxis   Vector3
                xAxis   Vector3
                yAxis   Vector3
        endl

        lea     edi, [matrix]
        mov     ecx, 4 * 4
        xor     eax, eax
        rep     stosd

        mov     esi, [camera]
        mov     edi, [target]
        mov     ebx, [up]

        fld     [edi + Vector3.x]
        fsub    [esi + Vector3.x]
        fstp    [zAxis.x]

        fld     [edi + Vector3.y]
        fsub    [esi + Vector3.y]
        fstp    [zAxis.y]

        fld     [edi + Vector3.z]
        fsub    [esi + Vector3.z]
        fstp    [zAxis.z]

        lea     eax, [zAxis]
        stdcall Vector3.Normalize, eax

        lea     eax, [zAxis]
        lea     ecx, [xAxis]
        stdcall Vector3.Cross, eax, ebx, ecx

        lea     eax, [xAxis]
        stdcall Vector3.Normalize, eax

        lea     eax, [xAxis]
        lea     ecx, [zAxis]
        lea     ebx, [yAxis]
        stdcall Vector3.Cross, eax, ecx, ebx

        lea     esi, [xAxis]
        lea     edi, [matrix]
        fld     [esi + Vector3.x]
        fstp    [edi + Matrix4x4.m11]
        fld     [esi + Vector3.y]
        fstp    [edi + Matrix4x4.m21]
        fld     [esi + Vector3.z]
        fstp    [edi + Matrix4x4.m31]

        fld     [ebx + Vector3.x]
        fstp    [edi + Matrix4x4.m12]
        fld     [ebx + Vector3.y]
        fstp    [edi + Matrix4x4.m22]
        fld     [ebx + Vector3.z]
        fstp    [edi + Matrix4x4.m32]

        lea     esi, [zAxis]
        fld     [esi + Vector3.x]
        fchs
        fstp    [edi + Matrix4x4.m13]
        fld     [esi + Vector3.y]
        fchs
        fstp    [edi + Matrix4x4.m23]
        fld     [esi + Vector3.z]
        fchs
        fstp    [edi + Matrix4x4.m33]

        fld1
        fstp    [edi + Matrix4x4.m44]

        invoke  glMultMatrixf, edi

        mov     esi, [camera]
        fld     [esi + Vector3.z]
        fchs
        fstp    [temp]
        push    [temp]
        fld     [esi + Vector3.y]
        fchs
        fstp    [temp]
        push    [temp]
        fld     [esi + Vector3.x]
        fchs
        fstp    [temp]
        push    [temp]
        invoke  glTranslatef

        ret
endp


; routine that is used for setting the
; movement process for the camera. 
; depending on the value of VKCode sets
; the camera movement in that direction
; to true if the key is proper
; (or if the chosen key is a debug key;
; in that way outputs debug value to 
; OutputDebug buffer)
proc Camera.SetMovement,\
        VKCode

        mov     eax, [VKCode]
        JumpIf  VK_FORWARD, .setForward
        JumpIf  VK_BACKWARD, .setBackward
        JumpIf  VK_LEFT, .setLeft 
        JumpIf  VK_RIGHT, .setRight
        JumpIf  VK_DEBUGGER, .debugger 

        jmp     .return 

.setForward:
        mov     [mvForward], MOVEMENT_TRUE  
        jmp     .return
.setBackward:
        mov     [mvBackward], MOVEMENT_TRUE
        jmp     .return
.setLeft:
        mov     [mvLeft], MOVEMENT_TRUE
        jmp     .return
.setRight:
        mov     [mvRight], MOVEMENT_TRUE
        jmp     .return
.debugger:
        stdcall Debug.OutputValueHex, [fYaw]
        stdcall Debug.OutputValueHex, [fPitch]
        stdcall Debug.OutputValueHex, [cameraFront.x]
        stdcall Debug.OutputValueHex, [cameraFront.y]
        stdcall Debug.OutputValueHex, [cameraFront.z]
        stdcall Debug.OutputValueHex, [cameraPos.x]
        stdcall Debug.OutputValueHex, [cameraPos.y]
        stdcall Debug.OutputValueHex, [cameraPos.z]

        jmp .return 
.return:
        ret 
endp

; routine for permitting movement in the 
; direction determined by VKCode
proc Camera.ClearMovement,\
        VKCode

        mov     eax, [VKCode]
        JumpIf  VK_FORWARD, .clearForward
        JumpIf  VK_BACKWARD, .clearBackward
        JumpIf  VK_LEFT, .clearLeft 
        JumpIf  VK_RIGHT, .clearRight
        
        jmp .return 

.clearForward:
        mov     [mvForward], MOVEMENT_FALSE
        jmp     .return
.clearBackward:
        mov     [mvBackward], MOVEMENT_FALSE
        jmp     .return
.clearLeft:
        mov     [mvLeft], MOVEMENT_FALSE
        jmp     .return
.clearRight:
        mov     [mvRight], MOVEMENT_FALSE
        jmp     .return
.return:
        ret 
endp


; routine for updating the camera position.
; dTime is the difference in ms between the 
; current frame and the last frame. depending
; on what directions are active (mvForward, 
; mvBackward and others) moves the camera 
; in those directions
proc Camera.Move uses edi,\      
        dTime
        locals 
                frontVector     Vector3 
                tempVector      Vector3
                scale           dd      ?
        endl

        lea     edi, [frontVector]



        mov     al, [mvForward]
        xor     al, [mvBackward]
        cmp     al, MOVEMENT_FALSE
        je      .noForwardBackward 

        stdcall Vector3.Copy, edi, cameraFront        
        fld     [dTime]
        mov     eax, 2.5
        push    eax 
        fmul    dword[esp]
        pop     eax 
        fstp    [scale]
        stdcall Vector3.Scale, edi, [scale]

        mov     al, [mvForward]
        cmp     al, MOVEMENT_FALSE
        je      .backward
.forward: 
        stdcall Vector3.Add, cameraPos, edi
        jmp     .noForwardBackward
.backward:
        stdcall Vector3.Sub, cameraPos, edi
.noForwardBackward:


        mov     al, [mvLeft]
        xor     al, [mvRight]
        cmp     al, MOVEMENT_FALSE
        je      .noLeftRight

        stdcall Vector3.Copy, edi, cameraFront
        lea     eax, [tempVector]
        stdcall Vector3.Cross, edi, cameraUp, eax 
        lea     edi, [tempVector]
        stdcall Vector3.Normalize, edi 
        fld     [dTime]
        mov     eax, 2.5
        push    eax 
        fmul    dword[esp]
        pop     eax 
        fstp    [scale]
        stdcall Vector3.Scale, edi, [scale]

        mov     al, [mvLeft]
        cmp     al, MOVEMENT_FALSE
        je      .right 
.left:
        stdcall Vector3.Sub, cameraPos, edi 
        jmp     .noLeftRight
.right:
        stdcall Vector3.Add, cameraPos, edi

.noLeftRight:
        ret
endp

; proc Camera.LookAroundUpdate uses edi,\
;         XYOffsets
        
;         locals
;                 direction       Vector3
;         endl

;         mov     eax, [XYOffsets]

;         mov     ecx, 0x0000FFFF
;         and     ecx, eax
;         ; ecx = current x position

;         movzx   edx, word[xPosLast]
;         mov     word[xPosLast], cx 
;         sub     ecx, edx 
;         ; ecx = x offset

;         push    ecx 
;         fild    dword[esp]              ; xOffs                  
;         pop     ecx 



;         rol     eax, 16 
;         mov     ecx, 0xFFFF
;         and     ecx, eax
;         ; ecx = current y position

;         movzx   edx, word[yPosLast]
;         mov     word[yPosLast], cx
;         sub     ecx, edx 
;         ; ecx = y offset 

;         push    ecx 
;         fild    dword[esp]              ; yOffs, xOffs                                    
;         pop     ecx 


;         mov     eax, 0.1
;         push    eax 

;         fmul    dword[esp]              ; 0.1*yOffs, xOffs
;         fadd    [pitch]                 ; newPitch, xOffs
;         fstp    [pitch]                 ; xOffs                           
        
;         fmul    dword[esp]              ; 0.1*xOffs
;         fadd    [yaw]                   ; newYaw
;         fstp    [yaw]                   ;

;         pop     eax 

;         stdcall Camera.AdjustPitch

;         lea     edi, [direction]
;         fld     [yaw]                   ; yaw
;         fdiv    [radian]                ; yaw        
;         fsincos                         ; sin(yaw), cos(yaw)
;         fld     [pitch]                 ; pitch, sin(yaw), cos(yaw)
;         fdiv    [radian]                ; pitch, sin(yaw), cos(yaw)
;         fsincos                         ; sin(pitch), cos(pitch), sin(yaw), cos(yaw)
;         fstp    [edi + Vector3.y]       ; cos(pitch), sin(yaw), cos(yaw)
;         ;fxch                            ; sin(yaw), cos(pitch), cos(yaw)
;         ;fmul    st0, st1                ; z, cos(pitch), cos(yaw)
;         ;fstp    [direction.z]           ; cos(pitch), cos(yaw)
;         ;fmulp                           ; x
;         ;fstp    [direction.x]           ; 
;         fmul    st2, st0                ; cos(pitch), sin(yaw), x
;         fmulp                           ; z, x
;         fstp    [edi + Vector3.z]       ; x
;         fstp    [edi + Vector3.x]       ; 

;         stdcall Vector3.Normalize, edi
;         stdcall Vector3.Copy, cameraFront, edi

;         ret
; endp

; proc Camera.AdjustPitch 

;         mov     eax, 89.0
;         push    eax

;         fld     [pitch]         ; pitch
;         fabs                    ; |pitch|
;         fld     dword[esp]      ; 89.0, |pitch|
;         FPU_CMP                 ;
;         jb      .allRight
;         fld     dword[esp]      ; 89.0
;         fld     [pitch]         ; pitch, 89.0 
;         fldz                    ; 0, pitch, 89.0
;         FPU_CMP                 ; 89.0
;         jb      .pitchIsPositive
;         fchs                    ; -89.0
; .pitchIsPositive:
;         fstp    [pitch]
; .allRight:
;         pop     eax 

; ;         fld     st0                     ; newPitch, newPitch, xOffs
; ;         mov     eax, 89.0               
; ;         push    eax 
; ;         fld     dword[esp]              ; 89.0, newPitch, newPitch, xOffs
; ;         FPU_CMP                         ; newPitch, xOffs
; ;         ja      @F
; ;         fstp    st1                     ; xOffs
; ;         fld     dword[esp]              ; 89.0, xOffs
; ; @@:
; ;         pop     eax 
;         ret 
; endp


; proc Camera.LookAroundUpdate uses edi,\
;         XYCoords

;         locals
;                 direction       Vector3
;         endl

;         mov     eax, [XYCoords]
;         rol     eax, 16
;         movzx   ecx, ax                         ; ecx has the current x coordinate
;         movzx   edx, [wXPosLast]
;         ;mov     [wXPosLast], cx 
;         sub     ecx, edx 

;         push    ecx 
;         fild    dword[esp]                      ; xOffs
;         pop     ecx 


;         rol     eax, 16
;         movzx   ecx, ax                         ; ecx has the current y coordinate
;         movzx   edx, [wYPosLast]
;         ;mov     [wYPosLast], cx 
;         sub     edx, ecx 

;         push    edx
;         fild    dword[esp]                      ; yOffs, xOffs
;         pop     edx
        

;         mov     eax, 0.1
;         push    eax 

;         fmul    dword[esp]                      ; yOffs*0.1, xOffs
;         fadd    [fYaw]                          ; yawNew, xOffs
;         fstp    [fYaw]                          ; xOffs 

;         fmul    dword[esp]                      ; xOffs*0.1
;         fadd    [fPitch]                        ; pitchNew
;         fstp    [fPitch]                        ; 

;         pop     eax

;         stdcall Camera.AdjustPitch

;         lea     edi, [direction]
;         fld     [fYaw]                  ; yaw
;         fdiv    [radian]                ; yaw
;         fsincos                         ; sin(yaw), cos(yaw)
;         fld     [fPitch]                ; pitch, sin(yaw), cos(yaw)
;         fdiv    [radian]                ; pitch, sin(yaw), cos(yaw)
;         fsincos                         ; sin(pitch), cos(pitch), sin(yaw), cos(yaw)
;         fstp    [edi + Vector3.y]       ; cos(pitch), sin(yaw), cos(yaw)
;         fmul    st2, st0                ; cos(pitch), sin(yaw), cos(yaw)*cos(pitch)=x
;         fmulp                           ; cos(pitch)*sin(yaw) = z, x
;         fstp    [edi + Vector3.z]       ; x
;         fstp    [edi + Vector3.x]       ; 

;         stdcall Vector3.Normalize, edi 
;         lea     eax, [cameraFront] 
;         stdcall Vector3.Copy, eax, edi 
        
;         movzx   eax, word[wCenterCoordsX]
;         movzx   edx, word[wCenterCoordsY]
;         invoke  SetCursorPos, eax, edx

;         ret
; endp

; proc Camera.AdjustPitch 


;         fld     [fPitch]                ; pitch
;         mov     eax, 89.0 
;         push    eax 
;         fld     dword[esp]              ; 89.0, pitch       
;         FPU_CMP         
;         ja      .posOkay
;         fld     dword[esp]
;         fstp    [fPitch]
; .posOkay:  
;         pop     eax 

;         fld     [fPitch]                ; pitch
;         mov     eax, -89.0
;         push    eax     
;         fld     dword[esp]              ; -89.0, pitch
;         FPU_CMP 
;         jb      .negOkay
;         fld     dword[esp]      
;         fstp    [fPitch]
; .negOkay:
;         pop     eax 



;         ret
; endp

; proc Camera.LookAroundUpdate uses ebx edi,\
;         XYCoords
;         locals
;                 direction       Vector3 
;         endl 

;         mov     eax, [lastCursorPos.x]
;         mov     ebx, [lastCursorPos.y]

;         ;push    eax
;         ;invoke  GetCursorPos, lastCursorPos
;         ;pop     eax 
;         mov     ecx, [XYCoords]
;         movzx   edx, cx
;         mov     [lastCursorPos.x], edx
;         rol     ecx, 16
;         movzx   edx, cx
;         mov     [lastCursorPos.y], edx

;         sub     eax, [lastCursorPos.x]
;         sub     ebx, [lastCursorPos.y]
;         neg     ebx 

;         push    eax
;         fild    dword[esp]              ; xOffset                      
;         pop     eax
         
;         push    ebx 
;         fild    dword[esp]              ; yOffset, xOffset
;         pop     ebx
        

;         mov     eax, 0.1
;         push    eax 

;         fmul    dword[esp]              ; yOffs*0.1, xOffs
;         fadd    [fYaw]                  ; yawNew, xOffs
;         fstp    [fYaw]                  ; xOffs

;         fmul    dword[esp]              ; xOffs*0.1
;         fadd    [fPitch]                ; pitchNew
;         fstp    [fPitch]                ;

;         pop     eax 

;         stdcall Camera.AdjustPitch

;         lea     edi, [direction]
;         fld     [fYaw]                  ; yaw
;         fdiv    [radian]                ; yaw
;         fsincos                         ; sin(yaw), cos(yaw)
;         fld     [fPitch]                ; pitch, sin(yaw), cos(yaw)
;         fdiv    [radian]                ; pitch, sin(yaw), cos(yaw)
;         fsincos                         ; sin(pitch), cos(pitch), sin(yaw), cos(yaw)
;         fstp    [edi + Vector3.y]       ; cos(pitch), sin(yaw), cos(yaw)
;         fmul    st2, st0                ; cos(pitch), sin(yaw), cos(yaw)*cos(pitch)=x
;         fmulp                           ; cos(pitch)*sin(yaw) = z, x
;         fstp    [edi + Vector3.z]       ; x
;         fstp    [edi + Vector3.x]       ; 

;         stdcall Vector3.Normalize, edi 
;         lea     eax, [cameraFront]
;         stdcall Vector3.Copy, eax, edi
        
;         stdcall Camera.NormalizeCursor, lastCursorPos

;         ret 
; endp

; proc Camera.AdjustPitch 

;         mov     eax, 89.0
;         push    eax

;         fld     [fPitch]        ; pitch
;         fabs                    ; |pitch|
;         fld     dword[esp]      ; 89.0, |pitch|
;         FPU_CMP                 ;
;         jb      .allRight
;         fld     dword[esp]      ; 89.0
;         fld     [fPitch]        ; pitch, 89.0 
;         fldz                    ; 0, pitch, 89.0
;         FPU_CMP                 ; 89.0
;         jb      .pitchIsPositive
;         fchs                    ; -89.0
; .pitchIsPositive:
;         fstp    [fPitch]
; .allRight:
;         pop     eax 

; ;         fld     st0                     ; newPitch, newPitch, xOffs
; ;         mov     eax, 89.0               
; ;         push    eax 
; ;         fld     dword[esp]              ; 89.0, newPitch, newPitch, xOffs
; ;         FPU_CMP                         ; newPitch, xOffs
; ;         ja      @F
; ;         fstp    st1                     ; xOffs
; ;         fld     dword[esp]              ; 89.0, xOffs
; ; @@:
; ;         pop     eax 
;         ret 
; endp


; routine for keeping the cursor inside 
; the client and making the looking-around
; process possible (HONESTLY STOLEN BUT NEEDED
; FOR DEBUG; I DON'T TAKE ANY RESPONSIILITY FOR
; IT; WILL BE DEPRECATED IN THE FINAL PRODUCT)
proc Camera.NormalizeCursor,\
        pMouseCursor

        mov     edi, [pMouseCursor]
        mov     eax, [edi+Point.x]
        mov     ebx, [edi+Point.y]

        cmp     eax, maxCursorX
        jb      @F

        mov     eax, (maxCursorX+minCursorX)/2
@@:

        cmp     eax, minCursorX
        ja      @F
        mov     eax, (maxCursorX+minCursorX)/2

@@:

        cmp     ebx, maxCursorY
        jb      @F
        mov     ebx, (maxCursorY+minCursorY)/2

@@:
        cmp     ebx, minCursorY
        ja      @F
        mov     ebx, (maxCursorY+minCursorY)/2
@@:
        mov     [edi+Point.x], eax
        mov     [edi+Point.y], ebx
        invoke  SetCursorPos, eax, ebx

        ret
endp

; routine for rotating the camera.
; the routine takes XYCoords (wParam 
; of the MOUSE_MOVE msg) - current 
; cursor coords - and calculates the 
; offset. the offset is then used to 
; rotate the camera
proc Camera.LookAroundUpdate uses edi,\
        XYCoords
        locals 
                direction       Vector3
                xoffset         dd              ?
                yoffset         dd              ?
                sensitivity     dd              0.2
                maxPlayerPitch  dd              89.0
        endl 

        mov     eax, [XYCoords]

        movzx   edx, ax                         ; edx = current x position
        xchg    edx, [lastCursorPos.x]
        sub     edx, [lastCursorPos.x]          ; edx = lastPos - currPos
        neg     edx                             ; edx = currPos - lastPos

        rol     eax, 16
        movzx   ecx, ax                         ; ecx = current y position
        xchg    ecx, [lastCursorPos.y]
        sub     ecx, [lastCursorPos.y]          ; ecx = lastPos - currPos

        mov     [xoffset], edx
        mov     [yoffset], ecx


        fild    [xoffset]
        fmul    [sensitivity]
        fstp    [xoffset] 

        fild    [yoffset]
        fmul    [sensitivity]
        fstp    [yoffset]

        fld     [fYaw]
        fadd    [xoffset]
        fstp    [fYaw]
        
        fld     [fPitch] 
        fadd    [yoffset]
        fstp    [fPitch]


        fld     [fPitch]
        fcomp   [maxPlayerPitch]
        fstsw   ax
        sahf 
        jb      @F

        mov     eax, [maxPlayerPitch]
        mov     [fPitch], eax 

@@:
        fld     [maxPlayerPitch]
        fchs
        fcomp   [fPitch]
        fstsw   ax
        sahf 
        jb      @F

        fld     [maxPlayerPitch]
        fchs
        fstp    [fPitch]
        
@@:

;cameracalc
        lea     edi, [direction]

        fld     [fPitch]
        fdiv    [radian]
        fcos    
        fld     [fYaw]
        fdiv    [radian]
        fcos 
        fmulp 
        fstp    [edi+Vector3.x]

        fld     [fPitch]
        fdiv    [radian]
        fstp    [edi+Vector3.y]

        fld     [fPitch]
        fdiv    [radian]
        fcos
        fld     [fYaw]
        fdiv    [radian]
        fsin 
        fmulp 
        fstp    [edi+Vector3.z]



        ;stdcall Vector3.Normalize, edi 
        lea     eax, [cameraFront]
        stdcall Vector3.Copy, eax, edi 

        stdcall Camera.NormalizeCursor, lastCursorPos

        ret
endp


; routine for not letting the pitch go beyond
; the absolute value of 89.0 (I had a more optimal
; approach to this routine, but eventually I broke
; down the procedure to the most primitive steps
; because I was so confused with the result that 
; wasn't even related to this routine, and as a 
; result this routine wasn't even included in the
; routine of calculating the current front vector.
; probably while I was writing this I could've 
; tested this routine, but whatever. it works, and
; its main purpose is to debug, not debug optimally)
proc Camera.AdjustPitch

        mov     eax, 89.0               
        push    eax 
        fld     dword[esp]              ; 89.0
        fld     [fPitch]                ; pitch, 89.0
        FPU_CMP
        jbe     @F
        fld     dword[esp]
        fstp    [fPitch]
@@:
        pop     eax 

        mov     eax, -89.0
        push    eax 
        fld     dword[esp]              ; -89.0
        fld     [fPitch]                ; pitch, -89.0
        FPU_CMP
        jae     @F
        fld     dword[esp]
        fstp    [fPitch]
@@:
        pop     eax 


        ret 
endp

