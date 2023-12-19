struct SpectatorData 
    SPCameraPos             dd      ?
    SPFront                 dd      ?
    splineCameraPosData     Spline
    splineFrontData         Spline 
ends 


DIRECTION_LEFT  = 0
DIRECTION_RIGHT = 1
DIRECTION_UP    = 2
DIRECTION_DOWN  = 3

dirVector_left          Vector3     1.0, 0.0, 0.0
dirVector_right         Vector3     -1.0, 0.0, 0.0
dirVector_up            Vector3     0.0, 0.0, 1.0
dirVector_down          Vector3     0.0, 0.0, -1.0