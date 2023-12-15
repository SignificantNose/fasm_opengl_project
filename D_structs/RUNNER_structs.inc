; the pattern defines:
;   for player - the position it takes
;   for obstacles - positions blocked by obstacles
; 
; for example: 000100100b is 
;   000
;   100
;   100
;
; upd: for player it's better to store it as numbers of position:
; posHorizontal and posVertical
; because drawing occurs much more often that collision checking
struct PlayerPos
    posHorizontal   db      ?
    posVertical     db      ?
ends 

struct Obstacle
    arrObstacles    dd      ?
    arrCount        dd      ?
    nextObstacle    dw      ?
ends 

struct RunnerData 
    startPos        Vector3 
    dirVector       Vector3
    vectorRight     Vector3         ; because it will be calculated very fast, I do not think it 
                                    ; will be efficient to recalculate it every time. but maybe will
                                    ; try it
    ; currAddOffset   Vector3

    playerData      PlayerPos
    obstacles       Obstacle
ends 


RUNMASK_CANTMOVUP           equ     111000000b
RUNMASK_CANTMOVDOWN         equ     000000111b
RUNMASK_CANTMOVLEFT         equ     100100100b
RUNMASK_CANTMOVRIGHT        equ     001001001b

RUNDIR_UP                   equ     0
RUNDIR_DOWN                 equ     1
RUNDIR_LEFT                 equ     2
RUNDIR_RIGHT                equ     3

VKRUN_UP                    equ     'W'
VKRUN_UPALT                 equ     0x26

VKRUN_DOWN                  equ     'S'
VKRUN_DOWNALT               equ     0x28

VKRUN_LEFT                  equ     'A'
VKRUN_LEFTALT               equ     0x25

VKRUN_RIGHT                 equ     'D'
VKRUN_RIGHTALT              equ     0x27



Runner.CurrStateUp          db      ?               ; 'w'
Runner.CurrStateUpAlt       db      ?               ; '^'

Runner.CurrStateDown        db      ?               ; 's'
Runner.CurrStateDownAlt     db      ?               ; '\/'

Runner.CurrStateLeft        db      ?               ; 'a'
Runner.CurrStateLeftAlt     db      ?               ; '<'

Runner.CurrStateRight       db      ?               ; 'd'
Runner.CurrStateRightAlt    db      ?               ; '>'

RunnerStep      dd      2.66666666      ; = width of road / 3 