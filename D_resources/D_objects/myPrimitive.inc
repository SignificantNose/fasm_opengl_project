myPrimitiveVertices:


                GLfloat     -0.5, -0.5, 0.5,         0.0, 0.0
                GLfloat     -0.5, 0.5, 0.5,         0.0, 0.0
                GLfloat     0.5, -0.5, 0.5,         0.0, 0.0
                GLfloat     0.5, 0.5, 0.5,         0.0, 0.0
                GLfloat     0.5, -0.5, -0.5,         0.0, 0.0
                GLfloat     0.5, 0.5, -0.5,         0.0, 0.0
                GLfloat     -0.5, -0.5, -0.5,         0.0, 0.0
                GLfloat     -0.5, 0.5, -0.5,         0.0, 0.0

                
sizeofPrimitiveVertices = $-myPrimitiveVertices
myPrimitiveVertices.count = (sizeofPrimitiveVertices)/(4)

myPrimitiveIndices: 
                GLuint  2, 3, 1,\
                        2, 1, 0,\
                        4, 5, 3,\
                        4, 3, 2,\
                        6, 7, 5,\
                        6, 5, 4,\
                        0, 1, 7,\
                        0, 7, 6,\
                        3, 5, 7,\
                        3, 7, 1,\
                        4, 2, 0,\
                        4, 0, 6
                
sizeofPrimitiveIndices = $-myPrimitiveIndices