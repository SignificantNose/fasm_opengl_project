MOVEMENT_FALSE      =       false 
MOVEMENT_TRUE       =       true
VK_FORWARD          =       'W'
VK_BACKWARD         =       'S'
VK_LEFT             =       'A'
VK_RIGHT            =       'D'
VK_DEBUGGER         =       'Y'

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



cameraPos           Vector3         -3.0, 3.0, -3.0

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
fPitch              dd              -30.0



cameraUp            Vector3         0.0, 1.0, 0.0             

mvForward           db              MOVEMENT_FALSE
mvBackward          db              MOVEMENT_FALSE
mvLeft              db              MOVEMENT_FALSE
mvRight             db              MOVEMENT_FALSE



cameraPos1          Vector3         10.0, 10.0, 0.0
cameraDirPrev1      Vector3         10.0, 10.0, 10.0
cameraDirNext1      Vector3         10.0, 10.0, -10.0

cameraPos2          Vector3         -10.0, 10.0, 0.0
cameraDirPrev2      Vector3         -10.0, 10.0, -10.0
cameraDirNext2      Vector3         -10.0, 10.0, 10.0

cameraPosPoints:    Spline.Point    cameraPos1, cameraDirPrev1, cameraDirNext1, 1.0
                    Spline.Point    cameraPos2, cameraDirPrev2, cameraDirNext2, 1.0
cameraSpline        Spline          2, cameraPosPoints, SPLINE_LOOPED, 2.0 