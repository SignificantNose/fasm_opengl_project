proc Subdivide uses esi edi ebx,\
     sourceMesh, resultMesh

        locals
                trianglesCount          dd      ?
                verticesCount           dd      ?
                newVerticesCount        dd      ?
                newTrianglesCount       dd      ?
                vertices                dd      ?
                colors                  dd      ?
                newVertices             dd      ?
                newColors               dd      ?
                index                   dd      ?
                center                  Vertex
                oldV                    dd      (sizeof.Vertex * 3 / 4) dup ?
                middlePoints            dd      (sizeof.Vertex * 3 / 4) dup ?
                newV                    dd      (sizeof.Vertex * 12 / 4) dup ?
        endl

        mov     esi, [sourceMesh]
        mov     edi, [resultMesh]


;counting the new amount of vertices and triangles
        mov     eax, [esi + Mesh.trianglesCount]
        mov     [trianglesCount], eax                   ; old triangles
        xor     edx, edx
        mov     ecx, 3
        mul     ecx
        mov     [verticesCount], eax
        shl     eax, 2
        mov     [newVerticesCount], eax            ; vertices *=4

        mov     eax, [trianglesCount]
        shl     eax, 2
        mov     [newTrianglesCount], eax           ; triangles *=4

        mov     eax, [esi + Mesh.vertices]
        mov     [vertices], eax                         ; old vertices
        mov     eax, [esi + Mesh.colors]
        mov     [colors], eax                           ; old colors

; allocating the mamory for new arrays of vertices and smth ellse
        mov     eax, [newVerticesCount]
        xor     edx, edx
        mov     ecx, sizeof.Vertex
        mul     ecx

        push    eax
        push    eax
        invoke  HeapAlloc, [hHeap], 8   ; eax
        mov     [newVertices], eax
        invoke  HeapAlloc, [hHeap], 8   ; eax
        mov     [newColors], eax

; initializing some of the locals with 0.0
        mov     [index], ebx
        mov     [center.x], ebx
        mov     [center.y], ebx
        mov     [center.z], ebx

; calculating the center coordinate as the mean of all the vertices

        mov     esi, [vertices]
        mov     ecx, [verticesCount]

.SumVerticesLoop:
        fld     [esi + Vertex.x]
        fadd    [center.x]
        fstp    [center.x]
        fld     [esi + Vertex.y]
        fadd    [center.y]
        fstp    [center.y]
        fld     [esi + Vertex.z]
        fadd    [center.z]
        fstp    [center.z]

        mov     eax, sizeof.Vertex
        add     esi, eax

        loop    .SumVerticesLoop

        fld     [center.x]
        fdiv    [verticesCount]
        fstp    [center.x]

        fld     [center.y]
        fdiv    [verticesCount]
        fstp    [center.y]

        fld     [center.z]
        fdiv    [verticesCount]
        fstp    [center.z]

; okay, so now we have the center coordinate. let us divide the vertices
        mov     ecx, [trianglesCount]

.SubdivideLoop:
        push    ecx

        mov     eax, [trianglesCount]
        sub     eax, ecx
        xor     edx, edx
        mov     ecx, sizeof.Vertex * 3
        mul     ecx

        mov     esi, [sourceMesh]
        mov     esi, [vertices]
        add     esi, eax
        lea     edi, [oldV]
        mov     ecx, sizeof.Vertex * 3 / 4
        rep     movsd

        lea     esi, [oldV]
        lea     edi, [center]
        lea     ebx, [middlePoints]

        push    ebx
        push    edi
        add     esi, sizeof.Vertex * 1
        push    esi
        sub     esi, sizeof.Vertex * 1
        push    esi
        stdcall GetSmoothPoint

        add     ebx, sizeof.Vertex * 1
        push    ebx
        push    edi
        add     esi, sizeof.Vertex * 2
        push    esi
        sub     esi, sizeof.Vertex * 1
        push    esi
        stdcall GetSmoothPoint

        add     ebx, sizeof.Vertex * 1
        push    ebx
        push    edi
        add     esi, sizeof.Vertex * 1
        push    esi
        sub     esi, sizeof.Vertex * 2
        push    esi
        stdcall GetSmoothPoint

        jmp     .CopyVertices

.Continue:
        pop     ecx
        loop    .SubdivideLoop

        jmp     .CopyResults

.CopyVertices:
        lea     esi, [oldV]
        lea     edi, [newV]
        lea     ebx, [middlePoints]

        mov     eax, [esi + sizeof.Vertex * 0 + Vertex.x]
        stosd
        mov     eax, [esi + sizeof.Vertex * 0 + Vertex.y]
        stosd
        mov     eax, [esi + sizeof.Vertex * 0 + Vertex.z]
        stosd

        mov     eax, [ebx + sizeof.Vertex * 0 + Vertex.x]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 0 + Vertex.y]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 0 + Vertex.z]
        stosd

        mov     eax, [ebx + sizeof.Vertex * 2 + Vertex.x]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 2 + Vertex.y]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 2 + Vertex.z]
        stosd

        mov     eax, [ebx + sizeof.Vertex * 0 + Vertex.x]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 0 + Vertex.y]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 0 + Vertex.z]
        stosd

        mov     eax, [esi + sizeof.Vertex * 1 + Vertex.x]
        stosd
        mov     eax, [esi + sizeof.Vertex * 1 + Vertex.y]
        stosd
        mov     eax, [esi + sizeof.Vertex * 1 + Vertex.z]
        stosd

        mov     eax, [ebx + sizeof.Vertex * 1 + Vertex.x]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 1 + Vertex.y]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 1 + Vertex.z]
        stosd

        mov     eax, [ebx + sizeof.Vertex * 0 + Vertex.x]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 0 + Vertex.y]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 0 + Vertex.z]
        stosd

        mov     eax, [ebx + sizeof.Vertex * 1 + Vertex.x]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 1 + Vertex.y]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 1 + Vertex.z]
        stosd

        mov     eax, [ebx + sizeof.Vertex * 2 + Vertex.x]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 2 + Vertex.y]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 2 + Vertex.z]
        stosd

        mov     eax, [ebx + sizeof.Vertex * 2 + Vertex.x]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 2 + Vertex.y]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 2 + Vertex.z]
        stosd

        mov     eax, [ebx + sizeof.Vertex * 1 + Vertex.x]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 1 + Vertex.y]
        stosd
        mov     eax, [ebx + sizeof.Vertex * 1 + Vertex.z]
        stosd

        mov     eax, [esi + sizeof.Vertex * 2 + Vertex.x]
        stosd
        mov     eax, [esi + sizeof.Vertex * 2 + Vertex.y]
        stosd
        mov     eax, [esi + sizeof.Vertex * 2 + Vertex.z]
        stosd

        lea     esi, [newV]
        mov     edi, [newVertices]

        xor     edx, edx
        mov     eax, [index]
        mov     ecx, sizeof.Vertex
        mul     ecx
        add     edi, eax

        add     [index], 12

        mov     ecx, sizeof.Vertex * 12 / 4
        rep     movsd

        jmp     .Continue
.CopyResults:

        mov     edi, [resultMesh]

        mov     eax, [newVertices]
        mov     [edi + Mesh.vertices], eax
        mov     eax, [newColors]
        mov     [edi + Mesh.colors], eax
        mov     eax, [newTrianglesCount]
        mov     [edi + Mesh.trianglesCount], eax

        ret
endp







proc GetSmoothPoint uses esi edi ebx,\
     v1, v2, center, result

        locals
                middlePoint     Vertex
                length1         dd      ?
                length2         dd      ?
                averageLength   dd      ?
                two             dd      ?
        endl

        mov     esi, [v1]
        mov     edi, [v2]
        mov     ebx, [result]

        fld1
        fld1
        faddp
        fstp    [two]

        fld     [esi + Vertex.x]
        fadd    [edi + Vertex.x]
        fdiv    [two]
        fstp    [middlePoint.x]

        fld     [esi + Vertex.y]
        fadd    [edi + Vertex.y]
        fdiv    [two]
        fstp    [middlePoint.y]

        fld     [esi + Vertex.z]
        fadd    [edi + Vertex.z]
        fdiv    [two]
        fstp    [middlePoint.z]

        mov     esi, [center]

        fld     [middlePoint.x]
        fsub    [esi + Vertex.x]
        fstp    [ebx + Vertex.x]

        fld     [middlePoint.y]
        fsub    [esi + Vertex.y]
        fstp    [ebx + Vertex.y]

        fld     [middlePoint.z]
        fsub    [esi + Vertex.z]
        fstp    [ebx + Vertex.z]

        stdcall Vector3.Distance, esi, [v1]
        mov     [length1], eax

        stdcall Vector3.Distance, esi, [v2]
        mov     [length2], eax

        fld     [length1]
        fadd    [length2]
        fdiv    [two]
        fstp    [averageLength]

        stdcall Vector3.Normalize, ebx

        fld     [ebx + Vertex.x]
        fmul    [averageLength]
        fstp    [ebx + Vertex.x]

        fld     [ebx + Vertex.y]
        fmul    [averageLength]
        fstp    [ebx + Vertex.y]

        fld     [ebx + Vertex.z]
        fmul    [averageLength]
        fstp    [ebx + Vertex.z]

        ret
endp