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

camFarPoint             Vector3         10000.0, 10000.0, 10000.0



cameraFirstMove1        Vector3         -32.0, 104.0, 158.0
cameraFirstMoveNext1    Vector3         -13.0, 82.0, 173.0
cameraFirstMovePrev2    Vector3         15.0, 43.0, 181.0
cameraFirstMove2        Vector3         58.0, 38.0, 185.0

cameraSecondMove1       Vector3         -92.0, 97.0, 145.0
cameraSecondMoveNext1   Vector3         -101.0, 88.0, 169.0
cameraSecondMovePrev2   Vector3         -112.0, 75.0, 190.0
cameraSecondMove2       Vector3         -115.0, 75.0, 211.0

cameraThirdMove1        Vector3         373.0, 29.0, 174.0
cameraThirdMoveNext1    Vector3         348.0, 22.0, 181.0
cameraThirdMovePrev2    Vector3         303.0, 14.0, 197.0
cameraThirdMove2        Vector3         264.0, 7.0, 200.0

cameraFourthMove1        Vector3         414.0, 23.0, 388.0
cameraFourthMoveNext1    Vector3         256.0, 8.0, 363.0
cameraFourthMovePrev2    Vector3         9.0, 8.0, 363.0
cameraFourthMove2        Vector3         -168.0, 16.0, 382.0

cameraFifthMove1        Vector3         434.0, 127.0, 186.0
cameraFifthMoveNext1    Vector3         109.0, 78.0, 195.0
cameraFifthMovePrev2    Vector3         -161.0, 25.0, 188.0
cameraFifthMove2        Vector3         -269.0, 16.0, 188.0

cameraSixthMove1        Vector3         323.0, 87.0, 31.0
cameraSixthMoveNext1    Vector3         190.0, 87.0, 115.0
cameraSixthMovePrev2    Vector3         104.0, 82.0, 202.0
cameraSixthMove2        Vector3         -57.0, 19.0, 176.0

cameraSeventhMove1        Vector3         119.0, 88.0, 68.0
cameraSeventhMoveNext1    Vector3         93.0, 26.0, 3.0
cameraSeventhMovePrev2    Vector3         20.0, 11.0, -10.0
cameraSeventhMove2        Vector3         0.0, 4.0, 4.0

cameraPosPoints:
                Spline.Point    cameraFirstMove1, camFarPoint, cameraFirstMoveNext1, 1.333333333
                Spline.Point    cameraFirstMove2, cameraFirstMovePrev2, camFarPoint, 0.0

                Spline.Point    cameraSecondMove1, camFarPoint, cameraSecondMoveNext1, 1.333333333
                Spline.Point    cameraSecondMove2, cameraSecondMovePrev2, camFarPoint, 0.0

                Spline.Point    cameraThirdMove1, camFarPoint, cameraThirdMoveNext1, 2.666666666
                Spline.Point    cameraThirdMove2, cameraThirdMovePrev2, camFarPoint, 0.0

                Spline.Point    cameraFourthMove1, camFarPoint, cameraFourthMoveNext1, 5.333333333
                Spline.Point    cameraFourthMove2, cameraFourthMovePrev2, camFarPoint, 0.0

                Spline.Point    cameraFifthMove1, camFarPoint, cameraFifthMoveNext1, 5.333333333
                Spline.Point    cameraFifthMove2, cameraFifthMovePrev2, camFarPoint, 0.0

                Spline.Point    cameraSixthMove1, camFarPoint, cameraSixthMoveNext1, 5.333333333
                Spline.Point    cameraSixthMove2, cameraSixthMovePrev2, camFarPoint, 0.0

                Spline.Point    cameraSeventhMove1, camFarPoint, cameraSeventhMoveNext1, 10.66666666
                Spline.Point    cameraSeventhMove2, cameraSeventhMovePrev2, camFarPoint, 0.0

CameraPos.countSplinePoints = ($ - cameraPosPoints)/sizeof.Spline.Point
cameraPosSpline         Spline          CameraPos.countSplinePoints, cameraPosPoints, SPLINE_NOT_LOOPED, 33.0


frontFirstMove1        Vector3         0.643923, -0.533844, 0.571348
frontFirstMoveNext1    Vector3         0.734925, -0.537333, 0.444858
frontFirstMovePrev2    Vector3         0.919463, -0.366364, 0.162060
frontFirstMove2        Vector3         0.998576, -0.052338, 0.010449


frontSecondMove1       Vector3         -0.846185, -0.471039, 0.279330
frontSecondMoveNext1   Vector3         -0.795945, -0.383809, 0.475662
frontSecondMovePrev2   Vector3         -0.740485, -0.244242, 0.627061
frontSecondMove2       Vector3         -0.952074, -0.300069, 0.078639

frontThirdMove1        Vector3         -0.932466, 0.226797, -0.282747
frontThirdMoveNext1    Vector3         -0.982551, 0.073273, -0.170978
frontThirdMovePrev2    Vector3         -0.922833, 0.216329, -0.319853
frontThirdMove2        Vector3         -0.501888, 0.551292, -0.688299

frontFourthMove1        Vector3         -0.896635, 0.293091, -0.335522
frontFourthMoveNext1    Vector3         -0.999026, -0.017, -0.04
frontFourthMovePrev2    Vector3         -0.999978, 0.003490, 0.005668
frontFourthMove2        Vector3         -0.893704, -0.139567, -0.426545

frontFifthMove1        Vector3         -0.779379, -0.676902, 0.0
frontFifthMoveNext1    Vector3         -1.0, 0.0, 0.0
frontFifthMovePrev2    Vector3         -1.0, 0.0, 0.0
frontFifthMove2        Vector3         -1.0, 0.0, 0.0

frontSixthMove1        Vector3         -0.81, -0.36, 0.455
frontSixthMoveNext1    Vector3         -0.786, -0.5757, -0.29
frontSixthMovePrev2    Vector3         -0.38, -0.6, 0.729
frontSixthMove2        Vector3         -0.729, -0.15, 0.667473

frontSeventhMove1        Vector3         -0.432576, -0.771105, -0.571987
frontSeventhMoveNext1    Vector3         -0.792699, -0.45, -0.427
frontSeventhMovePrev2    Vector3         -0.9827, -0.136, -0.125
frontSeventhMove2        Vector3         0.0, 0.0, 1.0
cameraFrontPoints:
                Spline.Point    frontFirstMove1, camFarPoint, frontFirstMoveNext1, 1.333333333
                Spline.Point    frontFirstMove2, frontFirstMovePrev2, camFarPoint, 0.0

                Spline.Point    frontSecondMove1, camFarPoint, frontSecondMoveNext1, 1.333333333
                Spline.Point    frontSecondMove2, frontSecondMovePrev2, camFarPoint, 0.0

                Spline.Point    frontThirdMove1, camFarPoint, frontThirdMoveNext1, 2.66666666
                Spline.Point    frontThirdMove2, frontThirdMovePrev2, camFarPoint, 0.0

                Spline.Point    frontFourthMove1, camFarPoint, frontFourthMoveNext1, 5.333333333
                Spline.Point    frontFourthMove2, frontFourthMovePrev2, camFarPoint, 0.0

                Spline.Point    frontFifthMove1, camFarPoint, frontFifthMoveNext1, 5.333333333
                Spline.Point    frontFifthMove2, frontFifthMovePrev2, camFarPoint, 0.0

                Spline.Point    frontSixthMove1, camFarPoint, frontSixthMoveNext1, 5.333333333
                Spline.Point    frontSixthMove2, frontSixthMovePrev2, camFarPoint, 0.0

                Spline.Point    frontSeventhMove1, camFarPoint, frontSeventhMoveNext1, 10.66666666
                Spline.Point    frontSeventhMove2, frontSeventhMovePrev2, camFarPoint, 0.0




cameraFront.splinePointCount = ($ - cameraFrontPoints)/sizeof.Spline.Point
cameraFrontSpline       Spline          cameraFront.splinePointCount, cameraFrontPoints, SPLINE_NOT_LOOPED, 33.0