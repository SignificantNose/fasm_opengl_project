proc Texture.LoadTexture uses edi esi,\
    textPath, textArrayOffs

    mov         esi, [textArrayOffs]

    invoke      glGenTextures, 1, esi

    invoke      glActiveTexture, GL_TEXTURE0
    invoke      glBindTexture, GL_TEXTURE_2D, dword[esi]

    invoke      glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT
    invoke      glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT
    invoke      glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR
    invoke      glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR


    stdcall     File.LoadContent, [textPath]
    mov         edi, eax 

    ; edx will store the offset of the data
    add         edi, dword[eax+10]
    invoke      glTexImage2D, GL_TEXTURE_2D, ebx, GL_RGB, dword[eax+18], dword[eax+22], ebx, GL_BGR, GL_UNSIGNED_BYTE, edi
    invoke      glGenerateMipmap, GL_TEXTURE_2D


    invoke      HeapFree, [hHeap], ebx, eax
    invoke      glBindTexture, GL_TEXTURE_2D, ebx
    ret
endp
