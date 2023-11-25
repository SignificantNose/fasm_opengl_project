; routine to generate a Mesh struct (resultMesh)
; out of a PackedMesh struct (sourceMesh)
proc Mesh.PackedMesh2Mesh uses ebx esi edi,\
     sourceMesh, resultMesh

        locals
                vertices        dd      ?
                indices         dd      ?
                resultVertices  dd      ?
                verticesCount   dd      ?
                resultIndex     dd      ?
        endl

        xor     ebx, ebx
        mov     esi, [sourceMesh]                       ; esi has the address of the source (packed) mesh 
        mov     edi, [resultMesh]                       ; edi has the address of the result (unhinged) mesh

        mov     eax, [esi + PackedVerticesMesh.pVertices]        ; initializing variables for proc
        mov     [vertices], eax
        mov     eax, [esi + PackedVerticesMesh.pIndices]
        mov     [indices], eax

        mov     [resultIndex], ebx

        mov     eax, [esi + PackedVerticesMesh.trianglesCount]    ;   acquiring the amount of the triangles of the source mesh
        xor     edx, edx                            
        mov     ecx, 3
        mul     ecx                     ; saving the amount of vertices
        mov     [verticesCount], eax    ; verticesCount = trianglesCount * 3
        mov     [edi + Mesh.VerticesCount], eax


        ; initializing vertices and normals in the mesh
        xor     edx, edx
        mov     ecx, sizeof.Vertex
        mul     ecx                             ; eax = amnt of bytes needed to keep all the vertices/normals
        mov     [edi + Mesh.szVertices], eax 
        mov     [edi + Mesh.szNormals], eax

        push    eax
        push    eax
        invoke  HeapAlloc, [hHeap], 8   ; eax
        mov     [edi + Mesh.pVertices], eax
        mov     [resultVertices], eax              

        invoke  HeapAlloc, [hHeap], 8   ; eax
        mov     [edi + Mesh.pNormals], eax

; push...

        ; initializing texture coords in the mesh
        mov     eax, [verticesCount]
        xor     edx, edx
        mov     ecx, sizeof.TexVertex
        mul     ecx                             ; eax = amnt of bytes needed to keep all the texture coords 
        mov     [edi + Mesh.szTexCoords], eax

        push    eax
        invoke  HeapAlloc, [hHeap], 8   ; eax
        mov     [edi + Mesh.pTexCoords], eax


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

        inc     ebx
        inc     [resultIndex]

        pop     ecx
        loop    .CopyCycle

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

; routine to generate a ShaderMesh struct (pShaderMesh)
; out of a Mesh struct (pInitialMesh). Basically puts the
; data that is stored separately sequentially
proc Mesh.Mesh2ShaderMesh uses esi edi,\
        pInitialMesh, pShaderMesh

        locals
                pInitVertices            dd      ?
                pInitTexCoords           dd      ? 
                pInitNormals             dd      ?
        endl

        mov     esi, [pInitialMesh]
        mov     edi, [pShaderMesh]

        mov     eax, [esi + Mesh.pVertices]
        mov     [pInitVertices], eax 
        mov     eax, [esi + Mesh.pTexCoords]
        mov     [pInitTexCoords], eax
        mov     eax, [esi + Mesh.pNormals]
        mov     [pInitNormals], eax

        mov     eax, [esi + Mesh.VerticesCount]
        mov     [edi + ShaderMesh.VerticesCount], eax

        ; calculating the total size of the buffer
        mov     eax, [esi + Mesh.szVertices]
        add     eax, [esi + Mesh.szTexCoords]
        add     eax, [esi + Mesh.szNormals]
        mov     [edi + ShaderMesh.szBufferData], eax

        invoke  HeapAlloc, [hHeap], 8, eax
        mov     [edi + ShaderMesh.pBufferData], eax
        mov     edi, eax 

        mov     ecx, [esi + Mesh.VerticesCount]

; task:
; for current vertice transfer the data to the buffer.
; edi must change correctly
; esi must switch from one element to the other
.looper: 
        push    ecx


; transferring position coordinates
        mov     esi, [pInitVertices]
        mov     ecx, sizeof.Vertex/4
        rep movsd
        mov     [pInitVertices], esi 

; transferring texture coordinates
        mov     esi, [pInitTexCoords]
        mov     ecx, sizeof.TexVertex/4
        rep movsd
        mov     [pInitTexCoords], esi
        
; transferring normals
        mov     esi, [pInitNormals]
        mov     ecx, sizeof.Vector3/4
        rep movsd
        mov     [pInitNormals], esi


        pop     ecx
        loop    .looper

        ret
endp