MOVEMENT_FALSE      =       false 
MOVEMENT_TRUE       =       true
VK_FORWARD          =       'W'
VK_BACKWARD         =       'S'
VK_LEFT             =       'A'
VK_RIGHT            =       'D'
VK_DEBUGGER         =       'Y'
VK_SPACE            =       0x20

maxCursorY          =       700
minCursorY          =       500
maxCursorX          =       1200
minCursorX          =       800

cursorPosX          =       960
cursorPosY          =       540

struct Point 
        x           dd      ?
        y           dd      ?
ends 



cameraSpeed         dd              80.0
cameraPos           Vector3         0.0, 3.0, 0.0

; for now the target will be deprecated. and it's 
; more likely that it'll stay deprecated, as the 
; animation will require to change the target 
; relatively to the current position, which will 
; be much more convenient to change using the 
; direction of the camera (front), rather than the 
; target of the camera
;cameraTarget        Vector3         0.0, 0.0, 0.0
cameraFront         Vector3         -1.0, 0.0, 0.0
; wCenterCoordsX      dw              ?
; wCenterCoordsY      dw              ?
lastCursorPos       Point           cursorPosX, cursorPosY
fYaw                dd              45.0
fPitch              dd              0.0



cameraUp            Vector3         0.0, 1.0, 0.0             

mvForward           db              MOVEMENT_FALSE
mvBackward          db              MOVEMENT_FALSE
mvLeft              db              MOVEMENT_FALSE
mvRight             db              MOVEMENT_FALSE



; cameraPos1          Vector3         10.0, 10.0, 0.0
; cameraDirPrev1      Vector3         10.0, 10.0, 10.0
; cameraDirNext1      Vector3         10.0, 10.0, -10.0

; cameraPos2          Vector3         -10.0, 10.0, 0.0
; cameraDirPrev2      Vector3         -10.0, 10.0, -10.0
; cameraDirNext2      Vector3         -10.0, 10.0, 10.0

; cameraPosPoints:    Spline.Point    cameraPos1, cameraDirPrev1, cameraDirNext1, 5.0
;                     Spline.Point    cameraPos2, cameraDirPrev2, cameraDirNext2, 5.0
; cameraSpline        Spline          2, cameraPosPoints, SPLINE_LOOPED, 10.0


; cameraPos1Prev  Vector3         10000.0, 10000.0, 10000.0
; cameraPos1      Vector3         -10.0, 10.0, 0.0
; cameraPos1Next  Vector3         -10.0, 5.0, 0.0

; cameraPos2Prev  Vector3         -5.0, 0.0, 0.0
; cameraPos2      Vector3         0.0, 0.0, 0.0
; cameraPos2Next  Vector3         0.0, 0.0, 0.0





cameraFirstMovePrev1    Vector3         10000.0, 10000.0, 10000.0
cameraFirstMove1        Vector3         -32.0, 104.0, 158.0
cameraFirstMoveNext1    Vector3         -13.0, 82.0, 173.0

cameraFirstMovePrev2    Vector3         15.0, 43.0, 181.0
cameraFirstMove2        Vector3         58.0, 38.0, 185.0
cameraFirstMoveNext2    Vector3         10000.0, 10000.0, 10000.0

cameraSecondMovePrev1   Vector3         10000.0, 10000.0, 10000.0
cameraSecondMove1       Vector3         -92.0, 97.0, 145.0
cameraSecondMoveNext1   Vector3         -101.0, 88.0, 169.0

cameraSecondMovePrev2   Vector3         -112.0, 75.0, 190.0
cameraSecondMove2       Vector3         -115.0, 75.0, 211.0
cameraSecondMoveNext2   Vector3         10000.0, 10000.0, 10000.0

cameraThirdMovePrev1    Vector3         10000.0, 10000.0, 10000.0
cameraThirdMove1        Vector3         373.0, 29.0, 174.0
cameraThirdMoveNext1    Vector3         348.0, 22.0, 181.0

cameraThirdMovePrev2    Vector3         303.0, 14.0, 197.0
cameraThirdMove2        Vector3         264.0, 7.0, 200.0
cameraThirdMoveNext2    Vector3         10000.0, 10000.0, 10000.0

cameraPosPoints:
                Spline.Point    cameraFirstMove1, cameraFirstMovePrev1, cameraFirstMoveNext1, 1.333333333
                Spline.Point    cameraFirstMove2, cameraFirstMovePrev2, cameraFirstMoveNext2, 0.0

                Spline.Point    cameraSecondMove1, cameraSecondMovePrev1, cameraSecondMoveNext1, 1.333333333
                Spline.Point    cameraSecondMove2, cameraSecondMovePrev2, cameraSecondMoveNext2, 0.0

                Spline.Point    cameraThirdMove1, cameraThirdMovePrev1, cameraThirdMoveNext1, 2.666666666
                Spline.Point    cameraThirdMove2, cameraThirdMovePrev2, cameraThirdMoveNext2, 0.0

                ;
                ;

                ;
                ;

                ;
                ;

                
                ;
                ;


                ;
                ;

cameraPosSpline         Spline          6, cameraPosPoints, SPLINE_NOT_LOOPED, 33.0


frontFirstMovePrev1    Vector3         10000.0, 10000.0, 10000.0
frontFirstMove1        Vector3         0.643923, -0.533844, 0.571348
frontFirstMoveNext1    Vector3         0.734925, -0.537333, 0.444858

frontFirstMovePrev2    Vector3         0.919463, -0.366364, 0.162060
frontFirstMove2        Vector3         0.998576, -0.052338, 0.010449


frontFirstMoveNext2    Vector3         10000.0, 10000.0, 10000.0

frontSecondMovePrev1   Vector3         10000.0, 10000.0, 10000.0
frontSecondMove1       Vector3         -0.846185, -0.471039, 0.279330
frontSecondMoveNext1   Vector3         -0.795945, -0.383809, 0.475662

frontSecondMovePrev2   Vector3         -0.740485, -0.244242, 0.627061
frontSecondMove2       Vector3         -0.952074, -0.300069, 0.078639
frontSecondMoveNext2   Vector3         10000.0, 10000.0, 10000.0

frontThirdMovePrev1    Vector3         10000.0, 10000.0, 10000.0
frontThirdMove1        Vector3         -0.932466, 0.226797, -0.282747
frontThirdMoveNext1    Vector3         -0.982551, 0.073273, -0.170978

frontThirdMovePrev2    Vector3         -0.922833, 0.216329, -0.319853
frontThirdMove2        Vector3         -0.501888, 0.551292, -0.688299
frontThirdMoveNext2    Vector3         10000.0, 10000.0, 10000.0
cameraFrontPoints:
                Spline.Point    frontFirstMove1, frontFirstMovePrev1, frontFirstMoveNext1, 1.333333333
                Spline.Point    frontFirstMove2, frontFirstMovePrev2, frontFirstMoveNext2, 0.0

                Spline.Point    frontSecondMove1, frontSecondMovePrev1, frontSecondMoveNext1, 1.333333333
                Spline.Point    frontSecondMove2, frontSecondMovePrev2, frontSecondMoveNext2, 0.0

                Spline.Point    frontThirdMove1, frontThirdMovePrev1, frontThirdMoveNext1, 2.666666666
                Spline.Point    frontThirdMove2, frontThirdMovePrev2, frontThirdMoveNext2, 0.0


cameraFrontSpline       Spline          6, cameraFrontPoints, SPLINE_NOT_LOOPED, 33.0