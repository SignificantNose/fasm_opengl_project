aHundred  dw    100
aTen      dw    10
aNine     dw    9
aRadian   dd    57.3
aThousand dw    1000
anEleven  dw    11
aNinety   dw    90

proc    Build.GeneratePackedTower uses ebx edi, resultMesh, scale
        locals
                numOfFloorsLiterally    dd      ?
                ;theMesh                 dd      ?
                cosValue                dd      ?
                sinValue                dd      ?
                randValue               dd      ?
                currHeight              dd      ?
        endl

        ;invoke HeapAlloc, [hHeap], 8, sizeof.PackedMesh
        ;mov [theMesh], eax                         ; theMesh = pointer to the memory loc, where the packed mesh is stored


        stdcall Rand.GetRandomNumber, 2, 10                 ; generating the amount of floors
        mov     [numOfFloorsLiterally], eax     ; i can just push it?

        xor edx, edx
        mov edi, 4*sizeof.Vertex
        mul edi                         ; eax = eax * 4 * 4 * 3

        push eax
        invoke HeapAlloc, [hHeap], 8

        mov edx, [resultMesh]
        mov [edx+PackedMesh.vertices], eax
        mov edi, eax



        fldz
        fstp [currHeight]
        mov ecx, [numOfFloorsLiterally]
.GenVertices:
        push ecx

;gen sin, cos
        stdcall Rand.GetRandomNumber, ebx, 10000
        mov [randValue], eax
        fild [aNinety]       ; 90
        fild [randValue]     ; [0;10000], 90
        fidiv [aThousand]    ; [0;10], 90
        fchs                 ; -x, 90
        fiadd [anEleven]     ; -x+11, 90
        fdivp                ; 90/(-x+11)
        fdiv  [aRadian]      ;angleRad

        ;fsqrt        ; [0;100], meaning x^2
        ;fsqrt        ; [0;10], meaning x
        ;fchs         ; -x
        ;fiadd [aTen] ; -x+10
        ;fild  [aTen] ; 10, -x+10
        ;fidiv [aHundred] ; 0.1, -x+10
        ;faddp        ; -x+10.1
        ;fld1         ; 1; -x+10.1
        ;fdiv  st0,st1  ;1/(-x+10)
        ;fimul [aNine]  ; angleDeg
        ;fdiv  [aRadian]; angleRad
        fsincos        ; sin, cos
        fmul  [scale]  ; R*sin, cos
        fld   st1      ; cos, R*sin, cos
        fmul  [scale]  ; R*cos, R*sin, cos

;gen vertices themselves
        mov   edx, [currHeight]
        fstp  [cosValue]
        fstp  [sinValue]
        mov eax, [cosValue]
        stosd
        mov eax, edx
        stosd
        mov eax, [sinValue]
        stosd

        jmp @F
.GenVerticesContinue:
        jmp .GenVertices                      ; eh
@@:

        fld   [sinValue]
        fchs
        fstp  [sinValue]
        mov   eax, [sinValue]
        stosd
        mov eax, edx
        stosd
        mov   eax, [cosValue]
        stosd


        fld   [cosValue]
        fchs
        fstp  [cosValue]
        mov  eax, [cosValue]
        stosd
        mov eax, edx
        stosd
        mov  eax, [sinValue]
        stosd


        fld [sinValue]
        fchs
        fstp [sinValue]
        mov  eax, [sinValue]
        stosd
        mov eax, edx
        stosd
        mov  eax, [cosValue]
        stosd



        fld     [currHeight]
        fadd    [scale]
        fstp    [currHeight]
        mov edx, [currHeight]

        pop ecx
        loop .GenVerticesContinue

; generating indices
        xor edx, edx
        mov eax, [numOfFloorsLiterally]         ; = n
        dec eax                                                                                   ; WARNING: THIS ONLY ALLOCATES ENOUGH MEMORY FOR OUTER WALLS
        mov ecx, 6*4                 ; 6 = num of bytes for one wall, 4 = num of walls per *floor*
        mul ecx

        push eax
        invoke HeapAlloc, [hHeap], 8
        mov ecx, [resultMesh]
        mov [ecx+PackedMesh.indices], eax
        mov edi, eax

        mov eax, [numOfFloorsLiterally]
        dec eax
        shl eax, 3
        mov [ecx+PackedMesh.trianglesCount], eax


        mov ecx, [numOfFloorsLiterally]                                        ; i can unite this part of code with the previous part
        dec ecx                  ; the amount of walls i need to draw
        xor eax, eax

.GenWalls:
        push ecx
        mov ecx, 3
.GenSomeWalls:
        stosb
        add al, 4
        stosb
        inc al
        stosb
        stosb
        sub al, 4
        stosb
        dec al
        stosb
        inc al
        loop .GenSomeWalls

        stosb
        add al, 4
        stosb
        sub al, 3
        stosb
        stosb
        sub al, 4
        stosb
        add al, 3
        stosb
        inc al

        pop ecx
        loop .GenWalls


        mov eax, [cubeMesh.colors]  ; what the hell is this
        mov ecx, [resultMesh]
        mov [ecx+PackedMesh.colors], eax

        ;mov eax, [theMesh]
        ;mov [resultMesh], eax
        ret

endp