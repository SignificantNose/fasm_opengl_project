aHundred  dw    100
aTen      dw    10
aNine     dw    9
aRadian   dd    57.3
aThousand dw    1000
anEleven  dw    11
anEighty  dw    80


; routine for generating a Model struct from a template
; defined by pTemplatePackedMesh and the ID of a texture.
; Model struct is stored at pDestModel and is ready to use
; (meaning, can be passed onto the Draw.ModelDraw routine 
; and be processed)
proc    Build.ModelByTemplate uses edi,\
        pDestModel, pTemplatePackedMesh, textureID

        locals
                bufferMesh      Mesh   
        endl 

        lea     edi, [bufferMesh]
        stdcall Mesh.PackedMesh2Mesh, [pTemplatePackedMesh], edi, true 
        mov     eax, [pDestModel]
        lea     eax, [eax + Model.meshData]
        stdcall Mesh.Mesh2ShaderMesh, edi, eax, [textureID]

        ret 
endp

; routine for generating a Model struct of a 
; building that is ready to use. the struct is 
; stored at pTowerModel
proc    Build.GenerateTowerModel uses esi edi,\
        pTowerModel

        invoke     HeapAlloc, [hHeap], 8, sizeof.PackedVerticesMesh
        mov        esi, eax
        invoke     HeapAlloc, [hHeap], 8, sizeof.Mesh
        mov        edi, eax                   

        stdcall    Build.GeneratePackedTower, esi, 1.0
        stdcall    Mesh.PackedMesh2Mesh, esi, edi, false
        stdcall    Build.DesignTower, edi
        mov        edx, [pTowerModel]
        lea        eax, [edx+Model.meshData]
        stdcall    Mesh.Mesh2ShaderMesh, edi, eax, [textureNeonID]

        invoke     HeapFree, [hHeap], 0, edi 
        invoke     HeapFree, [hHeap], 0, esi

        ret 
endp

; routine that generates a PackedMesh struct of
; a tower with the radius of the basis of the 
; building equal to scale.
; the amount of the floors is generated randomly
proc    Build.GeneratePackedTower uses ebx edi, pPackedMesh, scale
        locals
                numOfFloorsLiterally    dd      ?
                currHeight              dd      0.0
                cosValue                dd      ?
                sinValue                dd      ?
                sinValueNeg             dd      ?
                cosValueNeg             dd      ?
                ;startValue              Vector3
                temp                    dd      ?
        endl

        ; copying start coords to own variable
        ; (it's probably not a good idea to use them)
        ; (when the generation of town is executed, 
        ; their transformation coords must be calculated)
        ; mov eax, [startCoordsSrc]
        ; push eax
        ; push startValue
        ; stdcall Vector3.Copy
        ; fld     [startValue.y]
        ; fstp    [currHeight]

; generating the amount of floors; literal floors, not walls: walls = numOfFloorsLiterally-1
        stdcall   Rand.GetRandomInBetween, 2, 10                 ; generating the amount of floors
        mov       [numOfFloorsLiterally], eax     ; i can just push it?

; allocating the memory and saving the handle
        xor     edx, edx
        mov     edi, 4*sizeof.Vertex
        mul     edi                         ; eax = eax * sizeof(oneFloor)

        push    eax
        invoke  HeapAlloc, [hHeap], 8

        ; the result must be a pointer, so the result mesh
        ; will not be a struct, but a pointer to a struct
        mov     edi, [pPackedMesh]
        mov     [edi + PackedVerticesMesh.pVertices], eax
        mov     edi, eax

; generating vertices
        mov     ecx, [numOfFloorsLiterally]
.GenVertices:
        push    ecx

;gen sin, cos
        stdcall Rand.GetRandomNumber, ebx, 10000
        fild    [anEighty]              ; 80
        fild    [RandomValue]           ; [0;10000], 80
        fidiv   [aThousand]             ; [0;10], 80
        fchs                            ; -x, 80
        fiadd   [anEleven]              ; -x+11, 80
        fdivp                           ; 80/(-x+11)
        fdiv    [aRadian]               ; angleRad

        fsincos                         ; sin, cos
        fmul    [scale]                 ; R*sin, cos
        fld     st0                     ; R*sin, R*sin, cos
        fchs                            ; -R*sin, R*sin, cos
        fstp    [sinValueNeg]           ; R*sin, cos
        fstp    [sinValue]              ; cos
        fmul    [scale]                 ; R*cos
        fld     st0                     ; R*cos, R*cos
        fchs                            ; -R*cos, R*cos
        fstp    [cosValueNeg]           ; R*cos
        fstp    [cosValue]              ;


;gen vertices themselves


        mov     eax, [cosValue]
        stosd
        mov     eax, [currHeight]
        stosd
        mov     eax, [sinValue]
        stosd
        ;fld [cosValue]
        ;fadd [startValue.x]
        ;fstp [temp]
        ;mov eax, [temp]
        ;stosd
        ;mov eax, [currHeight]
        ;stosd
        ;fld [sinValue]
        ;fadd [startValue.z]
        ;fstp [temp]
        ;mov eax, [temp]
        ;stosd



        jmp     @F
.GenVerticesContinue:
        jmp     .GenVertices
@@:

        mov     eax, [sinValueNeg]
        stosd
        mov     eax, [currHeight]
        stosd
        mov     eax, [cosValue]
        stosd

        ;fld [sinValueNeg]
        ;fadd [startValue.x]
        ;fstp [temp]
        ;mov eax, [temp]
        ;stosd
        ;mov eax, [currHeight]
        ;stosd
        ;fld [cosValue]
        ;fadd [startValue.z]
        ;fstp [temp]
        ;mov eax, [temp]
        ;stosd

        mov     eax, [cosValueNeg]
        stosd
        mov     eax, [currHeight]
        stosd
        mov     eax, [sinValueNeg]
        stosd

        ;fld [cosValueNeg]
        ;fadd [startValue.x]
        ;fstp [temp]
        ;mov eax, [temp]
        ;stosd
        ;mov eax, [currHeight]
        ;stosd
        ;fld [sinValueNeg]
        ;fadd [startValue.z]
        ;fstp [temp]
        ;mov eax, [temp]
        ;stosd



        mov     eax, [sinValue]
        stosd
        mov     eax, [currHeight]
        stosd
        mov     eax, [cosValueNeg]
        stosd

        ;fld [sinValue]
        ;fadd [startValue.x]
        ;fstp [temp]
        ;mov eax, [temp]
        ;stosd
        ;mov eax, [currHeight]
        ;stosd
        ;fld [cosValueNeg]
        ;fadd [startValue.z]
        ;fstp [temp]
        ;mov eax, [temp]
        ;stosd


        fld     [currHeight]
        fadd    [scale]
        fstp    [currHeight]  

        pop     ecx
        loop    .GenVerticesContinue

; generating indices
        mov     eax, [numOfFloorsLiterally]
        shl     eax, 2
        sub     eax, 2                              ; eax = 4n-2 = №of rectangles

        shl     eax, 1                              ; eax = №of triangles
        mov     edi, [pPackedMesh]
        mov     [edi+PackedVerticesMesh.trianglesCount], eax


        xor     edx, edx
        mov     ecx, 3                              ; 3 = №of vertices per triangle
        mul     ecx 
        

        push    eax
        invoke  HeapAlloc, [hHeap], 8               ; allocates enough memory for outer walls and the floors at the top and at the bottom
        mov     [edi + PackedVerticesMesh.pIndices], eax
        mov     edi, eax

        xor     eax, eax

        stdcall GenFloorCeil


        mov     eax, [numOfFloorsLiterally]
        dec     eax
        mov     ecx, eax                            ; the amount of walls i need to draw = n - 1

        xor     eax, eax


.GenWalls:
        push    ecx
        mov     ecx, 3
.GenSomeWalls:
        stosb                      ; these parts of code look the same
        add     al, 4
        stosb
        inc     al
        stosb

        stosb                      ; these parts of code look the same
        sub     al , 4
        stosb
        dec     al 
        stosb
        inc     al 
        loop .GenSomeWalls

        stosb                       ; these parts of code look the same
        add     al, 4
        stosb
        sub     al, 3
        stosb

        stosb                      ; these parts of code look the same
        sub     al, 4
        stosb
        add     al, 3
        stosb
        inc     al

        pop     ecx
        loop .GenWalls

        stdcall GenFloorCeil

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

        ;stosd 
        ;inc     eax 
        ;stosd 
        ;inc     eax 
        ;stosd 
        ;stosd 
        ;inc     eax 
        ;stosd
        ;sub     eax, 3
        ;stosd

        ret
endp


; routine responsible for applying a texture
; to the tower to make it look like it's 
; composed of triangles
proc Build.DesignTower uses edi,\
        pTowerMesh

        mov     edi, [pTowerMesh]
        mov     eax, [edi + Mesh.VerticesCount]
        mov     edi, [edi + Mesh.pTexCoords]
        
        ; acquiring the amount of triangles
        xor     edx, edx
        mov     ecx, 3          
        div     ecx 
        xchg    ecx, eax 

        ; generating the texture coordinate themselves
.looper:
        ;mov     eax, 0.0
        xor     eax, eax
        stosd 
        ;mov     eax, 0.0
        stosd 

        mov     eax, 0.5
        stosd 
        mov     eax, 1.0
        stosd 

        mov     eax, 1.0
        stosd 
        ;mov     eax, 0.0
        xor     eax, eax
        stosd 

        loop    .looper


        ret
endp



proc Build.GenerateTown uses esi edi,\
        width, height, scale, resultTown

        locals
                currPos         Transform
        endl    

; initializing the currPos structure
        mov     ecx, sizeof.Transform 
        lea     edi, [currPos]
        xor     al, al 
        rep     stosb

        lea     esi, [currPos]
        mov     eax, [scale]
        mov     [esi + Transform.position + Vector3.x], eax 
        mov     [esi + Transform.position + Vector3.z], eax
        mov     [esi + Transform.scale + Vector3.x], eax
        mov     [esi + Transform.scale + Vector3.y], eax
        mov     [esi + Transform.scale + Vector3.z], eax

; filling in the result town data
        mov     edi, [resultTown]
        mov     [edi + Town.scale], eax 
        xor     edx, edx
        mov     eax, [width]
        mov     [edi + Town.width], eax
        mov     ecx, [height]
        mov     [edi + Town.height], ecx
        mul     ecx
        mov     [edi + Town.total], eax


        xor     edx, edx                    
        mov     ecx, sizeof.Model
        mul     ecx
; ecx has the amount of data needed to store all the towers

        invoke  HeapAlloc, [hHeap], 8, eax
        mov     [edi + Town.pTowerModels], eax
        mov     edi, eax

        mov     ecx, [height]
.looperHeight:
        push    ecx

        mov     ecx, [width]
.looperWidth:
        push    ecx


        stdcall   Build.GenerateTowerModel, edi 
        mov       eax, edi
        add       eax, Model.positionData 

        lea       ecx, [currPos]
        stdcall   Memory.memcpy, eax, ecx, sizeof.Transform 
        
        add       edi, sizeof.Model



        fld       dword[esi + Transform.position + Vector3.x]
        fadd      [scale]
        fadd      [scale]
        fstp      dword[esi + Transform.position + Vector3.x]

        pop ecx
        loop .looperWidth



        fld       [scale]             
        fst       dword[esi + Transform.position + Vector3.x]
        fadd      [scale]
        fadd      dword[esi + Transform.position + Vector3.z]
        fstp      dword[esi + Transform.position + Vector3.z]

        pop ecx
        loop .looperHeight

        ret
endp


proc    Build.GenerateLayout uses edi,\
        lengthOfUnit, unitsRoadLength

        locals
                currTransform           Transform 
                startOffsetX            dd              ?       
                lengthBetweenCrosses    dd              ?      
        endl 

; initializing transform matrix
        lea     edi, [currTransform]
        xor     eax, eax
        mov     ecx, sizeof.Transform/4
        rep     stosd

; setting the scale values      
        fld     [lengthOfUnit]          ; u 
        fst     [currTransform + Transform.scale + Vector3.x]
        fst     [currTransform + Transform.scale + Vector3.y]
        fst     [currTransform + Transform.scale + Vector3.z]

; calculating the starting offsets
        ; fld     [lengthOfUnit]          ; u
        fadd    [unitsRoadLength]       ; u + n
        mov     eax, 2.0
        push    eax     ; 2.0
        fmul    dword[esp]              ; 2*(u+n)
        fst     [lengthBetweenCrosses]

        mov     eax, LAYOUT_CROSSROADSWIDTH     
        push    eax     ; LOCrW
        fimul   dword[esp]              ; LOCrW * 2 * (u + n)
        fsub    [unitsRoadLength]       ; LOCrW * 2 * (u + n) - n
        fsub    [unitsRoadLength]       ; LOCrW * 2 * (u + n) - 2 * n
        pop     eax     ; LOCrW
        fdiv    dword[esp]              ; (LOCrW * 2 * (u + n) - 2 * n) / 2
        fsub    [lengthOfUnit]          ; (LOCrW * 2 * (u + n) - 2 * n) / 2 - u       ; to get cross position
        pop     eax     ; 2.0
        fstp    [startOffsetX]




; acquiring pointer to the array of crossroads
        invoke  HeapAlloc, [hHeap], 8, sizeof.Model*LAYOUT_CROSSROADSWIDTH*LAYOUT_CROSSROADSHEIGHT
        mov     edi, eax 
        mov     [crossroadArray], eax 

        mov     ecx, LAYOUT_CROSSROADSHEIGHT
.looperCrossHeight:
        push    ecx

; each height at the start must place the X back to the starting point
        mov     eax, [startOffsetX]
        mov     [currTransform + Transform.position + Vector3.x], eax 

        mov     ecx, LAYOUT_CROSSROADSWIDTH
.looperCrossWidth:
        push    ecx 


        stdcall Build.ModelByTemplate, edi, templatePackedCross, [textureCrossroadID]
        lea     eax, [edi + Model.positionData]
        lea     edx, [currTransform]
        stdcall Memory.memcpy, eax, edx, sizeof.Transform

; each width at the end must sub the current transform X with a delta value for width
        fld     [currTransform + Transform.position + Vector3.x]
        fsub    [lengthBetweenCrosses]
        fstp    [currTransform + Transform.position + Vector3.x]

        pop     ecx 
        add     edi, sizeof.Model 
        loop    .looperCrossWidth


; each height at the end must add Z with delta value for height
        fld     [lengthBetweenCrosses]
        fadd    [currTransform + Transform.position + Vector3.z]
        fstp    [currTransform + Transform.position + Vector3.z]

        pop     ecx 
        loop    .looperCrossHeight





; calculating the scale value for transform of roads
        ; fld     [lengthOfUnit]          ; u
        ; fmul    [unitsRoadLength]       ; u * n
        mov     eax, [unitsRoadLength]
        mov     [currTransform + Transform.scale + Vector3.z], eax 


; acquiring pointer to array of vertical roads
        invoke  HeapAlloc, [hHeap], 8, sizeof.Model * (LAYOUT_CROSSROADSHEIGHT-1)*LAYOUT_CROSSROADSWIDTH
        mov     edi, eax
        mov     [roadVerticalArray], eax 

; calculating the starting Z offset 
        fld     [unitsRoadLength]               ; n
        fadd    [lengthOfUnit]                  ; u + n
        fstp    [currTransform + Transform.position + Vector3.z]


        mov     ecx, LAYOUT_CROSSROADSHEIGHT-1
.looperRoadVerticalHeight:
        push    ecx 

; restore start offset of x
        mov     eax, [startOffsetX]
        mov     [currTransform + Transform.position + Vector3.x], eax 

        mov     ecx, LAYOUT_CROSSROADSWIDTH
.looperRoadVerticalWidth:
        push    ecx 

        stdcall Build.ModelByTemplate, edi, templatePackedRoad, [textureRoadID]
        lea     eax, [edi + Model.positionData]
        lea     edx, [currTransform]
        stdcall Memory.memcpy, eax, edx, sizeof.Transform

; move towards negative x to progress 
        fld     [currTransform + Transform.position + Vector3.x]
        fsub    [lengthBetweenCrosses]
        fstp    [currTransform + Transform.position + Vector3.x]
 
        pop     ecx 
        add     edi, sizeof.Model 
        loop    .looperRoadVerticalWidth


; modify z offset
        fld     [lengthBetweenCrosses]
        fadd    [currTransform + Transform.position + Vector3.z]
        fstp    [currTransform + Transform.position + Vector3.z]

        pop     ecx 
        loop    .looperRoadVerticalHeight







; acquiring pointer to array of horizontal roads
        invoke  HeapAlloc, [hHeap], 8, sizeof.Model*(LAYOUT_CROSSROADSWIDTH-1)*LAYOUT_CROSSROADSHEIGHT
        mov     edi, eax 
        mov     [roadHorizontalArray], eax 

; calculating the starting X offset
; (in horizontal roads it's easier to calculate this value
; and THEN move towards the Z axis)
        fld     [startOffsetX]          ; leftBorder
        fsub    [unitsRoadLength]       ; leftBorder - u
        fsub    [lengthOfUnit]          ; leftBorder - u - n
        fstp    [currTransform + Transform.position + Vector3.x]

; calculating the rotation value for transform
        mov     eax, 90.0
        mov     [currTransform + Transform.rotation + Vector3.y], eax 

        mov     ecx, LAYOUT_CROSSROADSWIDTH-1
.looperRoadHorizontalWidth:
        push    ecx 

; restore z value 
        xor     eax, eax 
        mov     [currTransform + Transform.position + Vector3.z], eax 

        mov     ecx, LAYOUT_CROSSROADSHEIGHT
.looperRoadHorizontalHeight:
        push    ecx 

        stdcall Build.ModelByTemplate, edi, templatePackedRoad, [textureRoadID]
        lea     eax, [edi + Model.positionData]
        lea     edx, [currTransform]
        stdcall Memory.memcpy, eax, edx, sizeof.Transform

; move towards positive Z direction 
        fld     [lengthBetweenCrosses]
        fadd    [currTransform + Transform.position + Vector3.z]
        fstp    [currTransform + Transform.position + Vector3.z]

        pop     ecx 
        add     edi, sizeof.Model 
        loop    .looperRoadHorizontalHeight



; modify x offset 
        fld     [currTransform + Transform.position + Vector3.x]
        fsub    [lengthBetweenCrosses]
        fstp    [currTransform + Transform.position + Vector3.x]

        pop     ecx 
        loop    .looperRoadHorizontalWidth

        ret 
endp