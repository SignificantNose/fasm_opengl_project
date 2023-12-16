SCENEMODE_SPECTATOR     =       0
SCENEMODE_RUNNER        =       1
SCENEMODE_CHOICE        =       2
SCENEMODE_INDEPENDENT   =       10000000b

struct Scene

    mode                db      ?
    sceneDuration       dd      ?
    movement            dd      ? 
    soundtrack          Track   

ends

; in case something else that is packed comes up
struct  PackedScene
    packedSoundtrack    PackedTrack
ends 



testStartingPoint   Vector3     0.0, 1.0, -4.0
testEndingPoint     Vector3     0.0, 1.0, 4.0
currentScene        dd      Scenes.ArrMain
currentSceneIndex   dd      0



; for now I've decided to put the scenes here;
; somewhy (not a word) I have a feeling that 
; it will not be so convenient. but who knows.
Scenes.ArrPacked:
independentSpectatorPacked      PackedScene     <1.0, 0,\
        0, 0,\
        0, 0>
SG1_SpectatorStart_Packed       PackedScene     <32.0, 0,\
        SG1_SpectatorStart.Msgs, SG1_SpectatorStart.MsgsCount,\
        SG1_SpectatorStart.Seqs, SG1_SpectatorStart.SeqsCount>
SG1_ChoiceFirst_Packed          PackedScene     <1.33333333, 0,\
        SG1_ChoiceFirst.Msgs, SG1_ChoiceFirst.MsgsCount,\
        SG1_ChoiceFirst.Seqs, SG1_ChoiceFirst.SeqsCount>
SG1_RunnerFirst_Packed          PackedScene     <1.0, 0,\
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
independentSpectator            Scene           SCENEMODE_INDEPENDENT, 100.0, ?, ?
SG1_SpectatorStart_Scene        Scene           SCENEMODE_SPECTATOR, 3.0, ?, ?
SG1_ChoiceFirst_Scene           Scene           SCENEMODE_CHOICE, 5.333333333, ?, ?
SG1_RunnerFirst_Scene           Scene           SCENEMODE_RUNNER, 85.33333333, ?, ?

; SG2_SpectatorMoveCamera_Scene   Scene           ?, ?, ?
; SG2_ChoiceSecond_Scene          Scene           ?, ?, ?
; SG2_RunnerSecond_Scene          Scene           ?, ?, ?

; SG3_SpectatorMoveCamera_Scene   Scene           ?, ?, ?
; SG3_ChoiceThird_Scene           Scene           ?, ?, ?
; SG3_RunnerThird_Scene           Scene           ?, ?, ?

; SG4_SpectatorMoveCamera_Scene   Scene           ?, ?, ?
; SG4_ChoiceFinal_Scene           Scene           ?, ?, ?
; SG4_SpectatorFinal_Scene        Scene           ?, ?, ?

Scenes.ArrMainEnd:
Scenes.ArrMainCount = (Scenes.ArrMainEnd - Scenes.ArrMain)/sizeof.Scene     
; must be the same as Scenes.ArrPackedCount
