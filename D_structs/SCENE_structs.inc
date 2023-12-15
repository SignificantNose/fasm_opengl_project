SCENEMODE_SPECTATOR     =       0
SCENEMODE_RUNNER        =       1
SCENEMODE_CHOICE        =       2

struct Scene

    mode        db      ?
    movement    dd      ? 
    soundtrack  Track   

ends

; in case something else that is packed comes up
struct  PackedScene
    packedSoundtrack    PackedTrack
ends 



struct Obstacle
    data            dd      ?
    count           dd      ?
    nextObstacle    dw      ?
ends 

struct RunnerData 
    startPos        Vector3 
    dirVector       Vector3
    currPattern     dw      ?
    obstacles       Obstacle
ends 


testStartingPoint   Vector3     0.0, 1.0, -4.0
testEndingPoint     Vector3     0.0, 1.0, 4.0
currentScene        dd      ? 



; for now I've decided to put the scenes here;
; somewhy (not a word) I have a feeling that 
; it will not be so convenient. but who knows.
Scenes.ArrPacked:
SG1_SpectatorStart_Packed       PackedScene     <32.0, 0,\
        SG1_SpectatorStart.Msgs, SG1_SpectatorStart.MsgsCount,\
        SG1_SpectatorStart.Seqs, SG1_SpectatorStart.SeqsCount>
; SG1_ChoiceFirst_Packed          PackedScene     ?
SG1_RunnerFirst_Packed          PackedScene     <42.666666666, 0,\
        SG1_RunnerFirst.Msgs, SG1_RunnerFirst.MsgsCount,\
        SG1_RunnerFirst.Seqs, SG1_RunnerFirst.SeqsCount>

; SG2_SpectatorMoveCamera_Packed  PackedScene     ?
; SG2_ChoiceSecond_Packed         PackedScene     ?
; SG2_RunnerSecond_Packed         PackedScene     ?

; SG3_SpectatorMoveCamera_Packed  PackedScene     ?
; SG3_ChoiceThird_Packed          PackedScene     ?
; SG3_RunnerThird_Packed          PackedScene     ?

; SG4_SpectatorMoveCamera_Packed  PackedScene     ?
; SG4_ChoiceFinal_Packed          PackedScene     ?
; SG4_SpectatorFinal_Packed       PackedScene     ?
Scenes.ArrPackedCount = ($-Scenes.ArrPacked)/sizeof.PackedScene


Scenes.ArrMain:
SG1_SpectatorStart_Scene        Scene           SCENEMODE_SPECTATOR, ?, ?
; SG1_ChoiceFirst_Scene           Scene           ?, ?, ?
SG1_RunnerFirst_Scene           Scene           SCENEMODE_RUNNER, ?, ?

; SG2_SpectatorMoveCamera_Scene   Scene           ?, ?, ?
; SG2_ChoiceSecond_Scene          Scene           ?, ?, ?
; SG2_RunnerSecond_Scene          Scene           ?, ?, ?

; SG3_SpectatorMoveCamera_Scene   Scene           ?, ?, ?
; SG3_ChoiceThird_Scene           Scene           ?, ?, ?
; SG3_RunnerThird_Scene           Scene           ?, ?, ?

; SG4_SpectatorMoveCamera_Scene   Scene           ?, ?, ?
; SG4_ChoiceFinal_Scene           Scene           ?, ?, ?
; SG4_SpectatorFinal_Scene        Scene           ?, ?, ?


Scenes.ArrMainCount = ($ - Scenes.ArrMain)/sizeof.Scene     
; must be the same as Scenes.ArrPackedCount

independentSpectator        Scene       SCENEMODE_CHOICE, ?, ?