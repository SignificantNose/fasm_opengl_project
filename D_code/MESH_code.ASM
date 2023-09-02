proc Mesh.Generate uses ebx esi edi,\
     sourceMesh, resultMesh, copyColors

        locals
                verticesCount   dd      ?
                resultIndex     dd      ?
                vertices        dd      ?
                resultVertices  dd      ?
                colors          dd      ?
                resultColors    dd      ?
                resultNormals   dd      ?
                indices         dd      ?
        endl

        ;xor ebx, ebx
        mov     esi, [sourceMesh]                       ; esi has the address of the source mesh
        mov     edi, [resultMesh]

        mov     eax, [esi + PackedMesh.vertices]        ; initializing variables for proc
        mov     [vertices], eax
        mov     eax, [esi + PackedMesh.colors]
        mov     [colors], eax
        mov     eax, [esi + PackedMesh.indices]
        mov     [indices], eax

        mov     [resultIndex], ebx

        mov     eax, [esi + PackedMesh.trianglesCount]    ;   acquiring the amount of the triangles of the source mesh
        ; mov     [edi + Mesh.trianglesCount], eax        ;   rewriting the amount of triangles in the resulting mesh
        xor     edx, edx                            ; why?
        mov     ecx, 3
        mul     ecx                                 ; saving the amount of vertices
        mov     [verticesCount], eax    ; verticesCount = trianglesCount * 3

        xor     edx, edx
        mov     ecx, sizeof.Vertex
        mul     ecx                             ; eax = size of memory needed to keep the source mesh

        push    eax
        push    eax
        push    eax
        invoke  HeapAlloc, [hHeap], 8   ; eax
        mov     [resultVertices], eax              ; resultVertices = handle to the allocated dynamic memory (for  vertices)
        invoke  HeapAlloc, [hHeap], 8   ; eax
        mov     [resultColors], eax                ; resultColors = handle to the allocated dynamic memory   (for colors)          ; it's the same
        invoke  HeapAlloc, [hHeap], 8   ; eax
        mov     [resultNormals], eax               ; resultNormals = handle to the allocated dynamic memory   (for normals)          ; it's the same


        mov     ecx, [verticesCount]
.CopyCycle:
        push    ecx

        xor     edx, edx
        mov     esi, [indices]
        movzx   eax, byte[esi + ebx]    ; index
        mov     edi, sizeof.Vertex
        mul     edi                     ; index * sizeof.Vertex         ;;; has the offset of the needed vertice

        mov     esi, [vertices]
        add     esi, eax                ; vertices + index * sizeof.Vertex = vertices[index]         ;;; has the address of the needed vertice

        xor     edx, edx
        mov     eax, [resultIndex]      ; resultIndex
        mov     edi, sizeof.Vertex
        mul     edi                     ; resultIndex * sizeof.Vertex

        mov     edi, [resultVertices]
        add     edi, eax                ; resultVertices + resultIndex * sizeof.Vertex =
                                        ; resultVertices[resultIndex]

        mov     eax, [esi + Vertex.x]   ; x = vertices[index].x
        mov     ecx, [esi + Vertex.y]   ; y = vertices[index].y
        mov     edx, [esi + Vertex.z]   ; z = vertices[index].z
        mov     [edi + Vertex.x], eax   ; resultVertices[resultIndex].x = x
        mov     [edi + Vertex.y], ecx   ; resultVertices[resultIndex].y = y
        mov     [edi + Vertex.z], edx   ; resultVertices[resultIndex].z = z

        cmp     [copyColors], false
        je      .DoNotCopyColors

        xor     edx, edx
        mov     esi, [indices]
        movzx   eax, byte[esi + ebx]    ; index
        mov     edi, sizeof.Color
        mul     edi                     ; index * sizeof.Color

        mov     esi, [colors]
        add     esi, eax                ; colors + index * sizeof.Color = colors[index]

        xor     edx, edx
        mov     eax, [resultIndex]      ; resultIndex
        mov     edi, sizeof.Color
        mul     edi                     ; resultIndex * sizeof.Color

        mov     edi, [resultColors]
        add     edi, eax                ; resultColors + resultIndex * sizeof.Color = resultColors[resultIndex]

        mov     eax, [esi + Color.r]    ; r = colors[index].r
        mov     ecx, [esi + Color.g]    ; g = colors[index].g
        mov     edx, [esi + Color.b]    ; b = colors[index].b
        mov     [edi + Color.r], eax    ; resultColors[resultIndex].r = r
        mov     [edi + Color.g], ecx    ; resultColors[resultIndex].g = g
        mov     [edi + Color.b], edx    ; resultColors[resultIndex].b = b

.DoNotCopyColors:

        inc     ebx
        inc     [resultIndex]

        pop     ecx
        loop    .CopyCycle

        mov     edi, [resultMesh]

        mov     eax, [resultVertices]
        mov     [edi + Mesh.vertices], eax
        mov     eax, [resultColors]
        mov     [edi + Mesh.colors], eax
        mov     eax, [resultNormals]
        mov     [edi + Mesh.normals], eax
        mov     eax, [verticesCount]
        mov     [edi + Mesh.verticesCount], eax

        ret
endp


proc Mesh.CalculateNormals uses esi edi ebx,\
     mesh

        locals
                trianglesCount  dd      ?
                v1              Vector3
                v2              Vector3
                normal          Vector3
        endl

        mov     esi, [mesh]

        mov     eax, [esi + Mesh.verticesCount]
        xor     edx, edx
        mov     ecx, 3
        div     ecx
        mov     [trianglesCount], eax

        mov     edi, [esi + Mesh.normals]
        mov     esi, [esi + Mesh.vertices]

        mov     ecx, [trianglesCount]

.CalculateNormalsLoop:
        push    ecx

        lea     ebx, [v1]
        add     esi, sizeof.Vector3 * 2
        stdcall Vector3.Copy, ebx, esi

        sub     esi, sizeof.Vector3 * 2
        stdcall Vector3.Sub, ebx, esi

        stdcall Vector3.Normalize, ebx

        lea     ebx, [v2]
        add     esi, sizeof.Vector3 * 1
        stdcall Vector3.Copy, ebx, esi

        sub     esi, sizeof.Vector3 * 1
        stdcall Vector3.Sub, ebx, esi

        stdcall Vector3.Normalize, ebx

        lea     ebx, [normal]
        push    ebx
        lea     ebx, [v1]
        push    ebx
        lea     ebx, [v2]
        push    ebx
        stdcall Vector3.Cross

        lea     ebx, [normal]
        stdcall Vector3.Normalize, ebx

        lea     ebx, [normal]
        stdcall Vector3.Copy, edi, ebx
        add     edi, sizeof.Vector3 * 1
        stdcall Vector3.Copy, edi, ebx
        add     edi, sizeof.Vector3 * 1
        stdcall Vector3.Copy, edi, ebx
        add     edi, sizeof.Vector3 * 1

        add     esi, sizeof.Vector3 * 3

        pop     ecx
        loop    .CalculateNormalsLoop

        ret
endp