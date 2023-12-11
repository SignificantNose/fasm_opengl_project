CUBE_TRIANGLES_COUNT    =       6 * 2
CUBE_VERTICES_COUNT     =       CUBE_TRIANGLES_COUNT * 3

cubeVertices:

        v0      dd      -1.0, -1.0,  1.0
        v1      dd      -1.0,  1.0,  1.0
        v2      dd       1.0, -1.0,  1.0
        v3      dd       1.0,  1.0,  1.0
        v4      dd       1.0, -1.0, -1.0
        v5      dd       1.0,  1.0, -1.0
        v6      dd      -1.0, -1.0, -1.0
        v7      dd      -1.0,  1.0, -1.0

cubeColors      dd      0.0, 1.0, 0.0,\
                        1.0, 1.0, 0.0,\
                        0.0, 1.0, 0.0,\
                        1.0, 1.0, 0.0,\
                        0.0, 1.0, 0.0,\
                        1.0, 1.0, 0.0,\
                        0.0, 1.0, 0.0,\
                        1.0, 1.0, 0.0

cubeIndices     db      2, 3, 1,\
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