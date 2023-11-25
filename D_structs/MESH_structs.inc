
struct Vertex
       x                dd      ?
       y                dd      ?
       z                dd      ?
ends
struct TexVertex
       s                dd      ?
       t                dd      ?
ends

struct Color
       r                dd      ?
       g                dd      ?
       b                dd      ?
ends


; PackedVerticesMesh is a struct used to
; generate compact data that utilizes the
; advantage of unique vertices being used
; multiple times and can be transferred to 
; the routine that will produce a mesh 
; consisting only of vertices
struct PackedVerticesMesh
       pVertices         dd      ?
       pIndices          dd      ?
       trianglesCount   dd      ?
ends


; Mesh is a struct that is easy to work with 
; (in terms of separate components: each one
; of them - position coords, tex coords - are
; easily accessible and modifiable)
struct Mesh
       pVertices        dd      ?         ; ptr to position vertices (type Vertex)
       szVertices       dd      ?         ; size (in bytes) of vertices

       pTexCoords       dd      ?         ; ptr to texture coords (type TexVertex)
       szTexCoords      dd      ?         ; size (in bytes) of texCoords

       pNormals         dd      ?         ; ptr to normals
       szNormals        dd      ?         ; size (in bytes) of normals

       VerticesCount    dd      ?         ; amount of vertices (basically szVerticesTex/sizeof.ShaverVertex)
ends


; ShaderMesh is a struct that must be the most
; compatible with the shader (in terms of buffers:
; the VBO data must be filled easily with the help 
; of this struct)
struct ShaderMesh
       pBufferData      dd      ?
       szBufferData     dd      ?
       VerticesCount    dd      ?
ends
