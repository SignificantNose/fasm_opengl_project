
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
       pIndices          dd      ?               ; WARNING! Indices are bytes!!
       pTexCoords        dd      ?               ; optional to fill 
       trianglesCount    dd      ?
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
; the data must be ready for this type of struct)
;
; EBO: I don't think that in my case it's relevant
; to use EBO as, for example, towers have a distinct
; structure that requires for one vertice to have 
; different texture coords. I might be wrong, but
; anyway if some time it becomes mandatory to use 
; EBO, welp, okay then.
struct ShaderMesh
       pBufferData      dd         ?
       szBufferData     dd         ?
       VerticesCount    dd         ?
       
       textureID        GLuint     ?
       VAO              GLuint     ? 
       VBO              GLuint     ?      
       ; EBO              GLuint          
ends


testPackedPlane PackedVerticesMesh      planeVertices, planeIndices, planeTexCoords,  PLANE_TRIANGLES_COUNT
testPlane       Mesh
testShaderPlane ShaderMesh

testPackedTower PackedVerticesMesh
testTower       Mesh
testShaderTower ShaderMesh         