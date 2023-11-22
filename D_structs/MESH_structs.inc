struct PackedMesh
       vertices         dd      ?
       colors           dd      ?
       indices          dd      ?
       trianglesCount   dd      ?
ends


; mesh struct must be modified
; after building up the architecture 
; of the mesh in the shader
struct Mesh
       vertices         dd      ?
       colors           dd      ?
       normals          dd      ?
       verticesCount    dd      ?
ends

struct Vertex
       x                dd      ?
       y                dd      ?
       z                dd      ?
ends

struct Color
       r                dd      ?
       g                dd      ?
       b                dd      ?
ends