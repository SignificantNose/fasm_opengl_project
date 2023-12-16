PLANE_TRIANGLES_COUNT   =       2

planeVertices:
        GLfloat         -1.0, 0.0, -1.0
        GLfloat         -1.0, 0.0, 1.0
        GLfloat         1.0, 0.0, 1.0
        GLfloat         1.0, 0.0, -1.0
planeTexCoords:
        GLfloat         0.0, 1000.0
        GLfloat         0.0, 0.0
        GLfloat         1000.0, 0.0
        GLfloat         1000.0, 1000.0

roadTexCoords:
        GLfloat         0.0, 12.0
        GLfloat         0.0, 0.0
        GLfloat         1.0, 0.0
        GLfloat         1.0, 12.0

crossTexCoords:
        GLfloat         0.0, 1.0
        GLfloat         0.0, 0.0
        GLfloat         1.0, 0.0
        GLfloat         1.0, 1.0

planeIndices:
        db          0, 1, 2,\
                    2, 3, 0


templatePackedPlane     PackedVerticesMesh      planeVertices, planeIndices, planeTexCoords,  PLANE_TRIANGLES_COUNT
planeModel              Model   <0,0,0,0,0,0>,\
                        <\
                               <0.0, 0.0, 0.0>,\
                               <0.0, 0.0, 0.0>,\
                               <1000.0, 1000.0, 1000.0>\
                        >