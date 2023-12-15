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
; proc Camera.SetMovement,\
;         VKCode

;         mov     eax, [VKCode]
;         JumpIf  VK_FORWARD, .setForward
;         JumpIf  VK_BACKWARD, .setBackward
;         JumpIf  VK_LEFT, .setLeft 
;         JumpIf  VK_RIGHT, .setRight
;         JumpIf  VK_DEBUGGER, .debugger 

;         jmp     .return 

; .setForward:
;         mov     [mvForward], MOVEMENT_TRUE  
;         jmp     .return
; .setBackward:
;         mov     [mvBackward], MOVEMENT_TRUE
;         jmp     .return
; .setLeft:
;         mov     [mvLeft], MOVEMENT_TRUE
;         jmp     .return
; .setRight:
;         mov     [mvRight], MOVEMENT_TRUE
;         jmp     .return
; .debugger:
;         stdcall Debug.OutputValueHex, [fYaw]
;         stdcall Debug.OutputValueHex, [fPitch]
;         stdcall Debug.OutputValueHex, [cameraFront.x]
;         stdcall Debug.OutputValueHex, [cameraFront.y]
;         stdcall Debug.OutputValueHex, [cameraFront.z]
;         stdcall Debug.OutputValueHex, [cameraPos.x]
;         stdcall Debug.OutputValueHex, [cameraPos.y]
;         stdcall Debug.OutputValueHex, [cameraPos.z]

;         jmp .return 
; .return:
;         ret 
; endp

; routine for permitting movement in the 
; direction determined by VKCode
; proc Camera.ClearMovement,\
;         VKCode

;         mov     eax, [VKCode]
;         JumpIf  VK_FORWARD, .clearForward
;         JumpIf  VK_BACKWARD, .clearBackward
;         JumpIf  VK_LEFT, .clearLeft 
;         JumpIf  VK_RIGHT, .clearRight
        
;         jmp .return 

; .clearForward:
;         mov     [mvForward], MOVEMENT_FALSE
;         jmp     .return
; .clearBackward:
;         mov     [mvBackward], MOVEMENT_FALSE
;         jmp     .return
; .clearLeft:
;         mov     [mvLeft], MOVEMENT_FALSE
;         jmp     .return
; .clearRight:
;         mov     [mvRight], MOVEMENT_FALSE
;         jmp     .return
; .return:
;         ret 
; endp


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
        fmul    [cameraSpeed]
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
        fmul    [cameraSpeed]
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



proc Camera.UpdateScene uses esi edi,\
        pScene, time

        locals
                CameraPosition      Vector3     ?, ?, ?
                AdditionalOffset    Vector3     ?, ?, ?
        endl

        mov     esi, [pScene]
        movzx   eax, [esi + Scene.mode]
        JumpIf  SCENEMODE_SPECTATOR, .spectator
        JumpIf  SCENEMODE_RUNNER, .runner 
        JumpIf  SCENEMODE_CHOICE, .choice 
        JumpIf  SCENEMODE_INDEPENDENT, .return 
        jmp     .return 

.spectator:

        jmp     .return 
.runner:

        nop
        mov     esi, [esi + Scene.movement]     ; esi now points at the RunnerData struct
        
        lea     edi, [AdditionalOffset]
        mov     ecx, sizeof.Vector3/4
        xor     eax, eax
        rep     stosd
        ; the direction vector must be calculated based on the length of the 
        ; route and the duration of the runner scene. so, the direction vector is:
        ; dirVector = (point.end - point.start)/trackDuration

        ;copying. do not like. trying.
        lea     edi, [CameraPosition]
        lea     eax, [esi + RunnerData.dirVector]
        stdcall Vector3.Copy, edi, eax
        stdcall Vector3.Scale, edi, [time]
        lea     eax, [esi + RunnerData.startPos]
        stdcall Vector3.Add, edi, eax    
        movsx   eax, [esi + RunnerData.playerData + PlayerPos.posHorizontal]
        cmp     eax, 0
        je      @F 
        lea     eax, [esi + RunnerData.vectorRight]
        jl      .horizNegative 
.horizPositive:
        stdcall Vector3.Add, edi, eax 
        jmp     @F 
.horizNegative:
        stdcall Vector3.Sub, edi, eax 
@@:

        movsx   eax, [esi + RunnerData.playerData + PlayerPos.posVertical]
        cmp     eax, 0
        je      @F
        lea     eax, [VecUpward]
        jl      .vertNegative 
.vertPositive:
        stdcall Vector3.Add, edi, eax 
        jmp     @F
.vertNegative:
        stdcall Vector3.Sub, edi, eax 

@@:

        ; at this point we have the right camera position. modify matrix? 
        ; or copy it to the cameraPos?
        ; for now I can just copy it, and then modify the routine to make it more optimized

        lea     eax, [cameraPos]
        stdcall Vector3.Copy, eax, edi

        ; make addition for the current pattern
        ; then - logic for patterns 
        ; so for now tasks are:
        ;
        ; form the runnerData struct 
        ; think of how to fit the data into the scene, not with pointer to data    

        ;thoughts: 
        ;       start position
        ;       direction vector (to not recalculate it every time)
        ;       current pattern position of the camera 
        ;       pointer to some kind of struct with obstacles
        ;       
        ; 
        ;obstacles: (an obstacle is a pattern)
        ;       array of obstacles  
        ;       amount of obstacles
        ;       next obstacle
        jmp     .return 
.choice:


.return:
        ret
endp