aHundred  dw    100
aTen      dw    10
aNine     dw    9
aRadian   dd    57.3
aThousand dw    1000
anEleven  dw    11
aNinety   dw    90
startValue Vector3
StartHeight     Vector3      0.0,0.0,0.0
TempMesh        PackedMesh   0,0,0,0


proc    Build.GeneratePackedTower uses ebx edi, resultMesh, startCoordsSrc, scale
        locals
                numOfFloorsLiterally    dd      ?
                currHeight              dd      ?
                cosValue                dd      ?
                sinValue                dd      ?
                sinValueNeg             dd      ?
                cosValueNeg             dd      ?
                ;startValue              Vector3
                temp                    dd      ?
        endl

        mov eax, [startCoordsSrc]
        push eax
        push startValue
        stdcall Vector3.Copy
        fld     [startValue.z]
        fstp    [currHeight]

; generating the amount of floors; literal floors, not walls: walls = numOfFloorsLiterally-1
        stdcall Rand.GetRandomNumber, 2, 10                 ; generating the amount of floors
        mov     [numOfFloorsLiterally], eax     ; i can just push it?

; allocating the memory and saving the handle
        xor edx, edx
        mov edi, 4*sizeof.Vertex
        mul edi                         ; eax = eax * 4 * 4 * 3
        push eax
        invoke HeapAlloc, [hHeap], 8
        mov edx, [resultMesh]
        mov [edx+PackedMesh.vertices], eax
        mov edi, eax

; generating vertices
        mov ecx, [numOfFloorsLiterally]
.GenVertices:
        push ecx

;gen sin, cos
        stdcall Rand.GetRandomNumber, ebx, 10000
        fild [aNinety]       ; 90
        fild [RandomValue]     ; [0;10000], 90
        fidiv [aThousand]    ; [0;10], 90
        fchs                 ; -x, 90
        fiadd [anEleven]     ; -x+11, 90
        fdivp                ; 90/(-x+11)
        fdiv  [aRadian]      ;angleRad

        fsincos        ; sin, cos
        fmul [scale]   ; R*sin, cos
        fld  st0       ; R*sin, R*sin, cos
        fchs           ; -R*sin, R*sin, cos
        fstp [sinValueNeg]   ; R*sin, cos
        fstp [sinValue]      ; cos
        fmul [scale]   ; R*cos
        fld  st0       ; R*cos, R*cos
        fchs           ; -R*cos, R*cos
        fstp [cosValueNeg]   ; R*cos
        fstp [cosValue]      ;


;gen vertices themselves

        ;mov eax, [cosValue]
        ;stosd
        ;mov eax, [currHeight]
        ;stosd
        ;mov eax, [sinValue]
        ;stosd
        fld [cosValue]
        fadd [startValue.x]
        fstp [temp]
        mov eax, [temp]
        stosd
        mov eax, [currHeight]
        stosd
        fld [sinValue]
        fadd [startValue.z]
        fstp [temp]
        mov eax, [temp]
        stosd



        jmp @F
.GenVerticesContinue:
        jmp .GenVertices
@@:

        ;mov   eax, [sinValueNeg]
        ;stosd
        ;mov eax, [currHeight]
        ;stosd
        ;mov   eax, [cosValue]
        ;stosd
        fld [sinValueNeg]
        fadd [startValue.x]
        fstp [temp]
        mov eax, [temp]
        stosd
        mov eax, [currHeight]
        stosd
        fld [cosValue]
        fadd [startValue.z]
        fstp [temp]
        mov eax, [temp]
        stosd

        ;mov  eax, [cosValueNeg]
        ;stosd
        ;mov eax, [currHeight]
        ;stosd
        ;mov  eax, [sinValueNeg]
        ;stosd
        fld [cosValueNeg]
        fadd [startValue.x]
        fstp [temp]
        mov eax, [temp]
        stosd
        mov eax, [currHeight]
        stosd
        fld [sinValueNeg]
        fadd [startValue.z]
        fstp [temp]
        mov eax, [temp]
        stosd



        ;mov  eax, [sinValue]
        ;stosd
        ;mov eax, [currHeight]
        ;stosd
        ;mov  eax, [cosValueNeg]
        ;stosd
        fld [sinValue]
        fadd [startValue.x]
        fstp [temp]
        mov eax, [temp]
        stosd
        mov eax, [currHeight]
        stosd
        fld [cosValueNeg]
        fadd [startValue.z]
        fstp [temp]
        mov eax, [temp]
        stosd


        fld     [currHeight]
        fadd    [scale]
        fstp    [currHeight]

        pop ecx
        loop .GenVerticesContinue

; generating indices
        xor edx, edx
        mov eax, [numOfFloorsLiterally]         ; = n
        mov ecx, 6*4                            ; 6 = num of bytes for one wall, 4 = num of walls per *floor*
        mul ecx
        sub eax, 6*2                            ; adjustment for walls (didn't decrease eax at first, needed to be corrected)

        push eax
        invoke HeapAlloc, [hHeap], 8            ; allocates enough memory for outer walls and the floors at the top and at the bottom
        mov edx, [resultMesh]
        mov [edx+PackedMesh.indices], eax
        mov edi, eax


        xor eax, eax

        stdcall GenFloorCeil


        mov eax, [numOfFloorsLiterally]
        dec eax
        mov ecx, eax                            ; the amount of walls i need to draw
        shl eax, 3
        add eax, 4
        mov [edx+PackedMesh.trianglesCount], eax

        xor eax, eax


.GenWalls:
        push ecx
        mov ecx, 3
.GenSomeWalls:
        stosb                      ; these parts of code look the same
        add al, 4
        stosb
        inc al
        stosb

        stosb                      ; these parts of code look the same
        sub al, 4
        stosb
        dec al
        stosb
        inc al
        loop .GenSomeWalls

        stosb                       ; these parts of code look the same
        add al, 4
        stosb
        sub al, 3
        stosb

        stosb                      ; these parts of code look the same
        sub al, 4
        stosb
        add al, 3
        stosb
        inc al

        pop ecx
        loop .GenWalls

        stdcall GenFloorCeil

        mov eax, [cubeMesh.colors]  ; what the hell is this ; delete after shaders done

        mov [edx+PackedMesh.colors], eax

        ;mov eax, [theMesh]
        ;mov [resultMesh], eax
        ret

endp


; DO NOT LIKE THIS PROCEDURE AT ALL WANT TO DECAPITATE IT SO MUCH WHAT DO I DOOOOO
; i just don't want to repeat code
; so: DO NOT CALL THIS PROCEDURE OUTSIDE BUILD.GENERATEPACKEDTOWER UNDER ANY CIRCUMSTANCES
proc    GenFloorCeil

        stosb
        inc al
        stosb
        inc al
        stosb
        stosb
        inc al
        stosb
        sub al, 3
        stosb

        ret
endp



proc Build.GenerateTown uses ebx edi, width, height, scale, resultTown
        ;locals
                ;TempMesh        PackedMesh
                ;TempCoords      Vector3
                ;StartHeight     Vector3         <?, 0.0, ?>
        ;endl
        mov ebx, [resultTown]
        mov edx, [scale]
        mov [StartHeight.x], edx
        mov [StartHeight.z], edx
        xor edx, edx
        mov eax, [width]
        mov [ebx+Town.width], eax
        mov ecx, [height]
        mov [ebx+Town.height], ecx
        mul ecx


        ;push eax                ; saving eax for the loop

        xor edx, edx                    ; do i need to?
        mov ecx, sizeof.Mesh
        mul ecx


        push eax
        invoke  HeapAlloc, [hHeap], 8
        mov [ebx+Town.towers], eax
        mov edi, eax

        ;pop ecx
        mov ecx, [height]
        xor ebx, ebx
.looperHeight:
        push ecx

        mov ecx, [width]
.looperWidth:
        push ecx
        stdcall Build.GeneratePackedTower, TempMesh, StartHeight, [scale]
        push false
        push edi
        stdcall Mesh.Generate, TempMesh
        push edi
        stdcall Mesh.CalculateNormals
        add edi, sizeof.Mesh

        fld [StartHeight.x]
        fadd [scale]
        fadd [scale]
        fstp [StartHeight.x]

        pop ecx
        loop .looperWidth



        mov eax, [scale]
        mov [StartHeight.x], eax
        fld [StartHeight.z]
        fadd [scale]
        fadd [scale]
        fstp [StartHeight.z]



        pop ecx
        loop .looperHeight

        ret
endp


