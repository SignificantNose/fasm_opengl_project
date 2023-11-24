myPrimitiveVertices:


                GLfloat     0.5, 0.5, 0.0,      0.0, 1.0, 0.0,      0.0, 0.0
                GLfloat     0.5, -0.5, 0.0,     1.0, 0.0, 0.0,      0.5, 1.0
                GLfloat     -0.5, -0.5, 0.0,    0.0, 0.0, 1.0,      0.0, 0.0
                GLfloat     -0.5, 0.5, 0.0,     1.0, 1.0, 1.0,      1.0, 0.0
                
sizeofPrimitiveVertices = $-myPrimitiveVertices
myPrimitiveVertices.count = (sizeofPrimitiveVertices)/(4)

myPrimitiveIndices: 
                GLuint       0, 1, 3
                GLuint       1, 2, 3
sizeofPrimitiveIndices = $-myPrimitiveIndices