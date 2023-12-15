proc Keyboard.KeyDown,\
    vKey

        mov     eax, [vKey]
        mov     ecx, [currentScene]
        movzx   edx, [ecx + Scene.mode]

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
        nop

        mov     ecx, [ecx + Scene.movement]
        JumpIf  VKRUN_UP, .up
        JumpIf  VKRUN_DOWN, .down
        JumpIf  VKRUN_LEFT, .left 
        JumpIf  VKRUN_RIGHT, .right 
        jmp     .return 

.up:
        movzx   eax, [Runner.CurrStateUp]
        cmp     eax, 0
        jne     .return
        mov     [Runner.CurrStateUp], 1
        stdcall Runner.Move, RUNDIR_UP, ecx
        jmp     .return 
.down:
        nop
        movzx   eax, [Runner.CurrStateDown]
        cmp     eax, 0
        jne     .return 
        mov     [Runner.CurrStateDown], 1
        stdcall Runner.Move, RUNDIR_DOWN, ecx
        jmp     .return 
.left:
        movzx   eax, [Runner.CurrStateLeft]
        cmp     eax, 0
        jne     .return
        mov     [Runner.CurrStateLeft], 1
        stdcall Runner.Move, RUNDIR_LEFT, ecx 
        jmp     .return 
.right:
        movzx   eax, [Runner.CurrStateRight]
        cmp     eax, 0
        jne     .return 
        mov     [Runner.CurrStateRight], 1
        stdcall Runner.Move, RUNDIR_RIGHT, ecx 
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
        ; stdcall Debug.OutputValueHex, [fYaw]
        ; stdcall Debug.OutputValueHex, [fPitch]

        stdcall Debug.PrintFrontCamText
        stdcall Debug.PrintCameraPosText

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

        JumpIf  VKRUN_UP, .up
        JumpIf  VKRUN_DOWN, .down
        JumpIf  VKRUN_LEFT, .left 
        JumpIf  VKRUN_RIGHT, .right 
        jmp     .return 
    
.up:
        mov     [Runner.CurrStateUp], 0
        jmp     .return 
.down:
        mov     [Runner.CurrStateDown], 0
        jmp     .return 
.left:
        mov     [Runner.CurrStateLeft], 0
        jmp     .return 
.right:
        mov     [Runner.CurrStateRight], 0
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