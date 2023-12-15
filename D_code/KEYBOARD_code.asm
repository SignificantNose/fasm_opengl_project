proc Keyboard.KeyDown,\
    vKey

    mov     eax, [vKey]
    mov     edx, [currentScene]
    movzx   edx, [edx + Scene.mode]

    cmp     edx, SCENEMODE_RUNNER
    je      .runner
    cmp     edx, SCENEMODE_CHOICE 
    je      .choice 
    cmp     edx, SCENEMODE_SPECTATOR
    je      .spectator
    cmp     edx, SCENEMODE_INDEPENDENT
    je      .independent
    jmp     .return 

.runner:

    jmp     .return 

.choice:

    jmp     .return 

.independent:
        JumpIf  VK_FORWARD, .independent_setForward
        JumpIf  VK_BACKWARD, .independent_setBackward
        JumpIf  VK_LEFT, .independent_setLeft 
        JumpIf  VK_RIGHT, .independent_setRight
        JumpIf  VK_DEBUGGER, .independent_debugger 

        jmp     .return 

.independent_setForward:
        mov     [mvForward], MOVEMENT_TRUE  
        jmp     .return
.independent_setBackward:
        mov     [mvBackward], MOVEMENT_TRUE
        jmp     .return
.independent_setLeft:
        mov     [mvLeft], MOVEMENT_TRUE
        jmp     .return
.independent_setRight:
        mov     [mvRight], MOVEMENT_TRUE
        jmp     .return
.independent_debugger:
        stdcall Debug.OutputValueHex, [fYaw]
        stdcall Debug.OutputValueHex, [fPitch]
        stdcall Debug.OutputValueHex, [cameraFront.x]
        stdcall Debug.OutputValueHex, [cameraFront.y]
        stdcall Debug.OutputValueHex, [cameraFront.z]
        stdcall Debug.OutputValueHex, [cameraPos.x]
        stdcall Debug.OutputValueHex, [cameraPos.y]
        stdcall Debug.OutputValueHex, [cameraPos.z]

.spectator:

.return: 
    ret 
endp 


proc Keyboard.KeyUp,\
    vKey 

    mov     eax, [vKey]
    mov     edx, [currentScene]
    movzx   edx, [edx + Scene.mode]

    cmp     edx, SCENEMODE_RUNNER
    je      .runner
    cmp     edx, SCENEMODE_CHOICE 
    je      .choice 
    cmp     edx, SCENEMODE_SPECTATOR
    je      .spectator
    cmp     edx, SCENEMODE_INDEPENDENT
    je      .independent
    jmp     .return 
.runner:

    jmp     .return 

.choice:

    jmp     .return 

.independent:
        JumpIf  VK_FORWARD, .independent_clearForward
        JumpIf  VK_BACKWARD, .independent_clearBackward
        JumpIf  VK_LEFT, .independent_clearLeft 
        JumpIf  VK_RIGHT, .independent_clearRight
        
        jmp .return 

.independent_clearForward:
        mov     [mvForward], MOVEMENT_FALSE
        jmp     .return
.independent_clearBackward:
        mov     [mvBackward], MOVEMENT_FALSE
        jmp     .return
.independent_clearLeft:
        mov     [mvLeft], MOVEMENT_FALSE
        jmp     .return
.independent_clearRight:
        mov     [mvRight], MOVEMENT_FALSE
        jmp     .return

.spectator:

.return: 
    ret 
endp