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
        pSceneTrack     dd      ?
ends 



testStartingPoint   Vector3     0.0, 1.0, -4.0
testEndingPoint     Vector3     0.0, 1.0, 4.0
currentScene        dd      Scenes.SceneList
currentSceneIndex   dd      0



; the packed tracks that actually will be used will be stored here
Scenes.PackedTracks:

        ; independentpackedtrack          PackedTrack     1.0, 0,\
        ;         0, 0,\
        ;         0, 0

        ; ; ScenePackedTrack.Start          PackedTrack     32.0, 0,\
        ; ;         ST_Start.Msgs, ST_Start.MsgsCount,\
        ; ;         ST_Start.Seqs, ST_Start.SeqsCount
        ; ScenePackedTrack.Start          PackedTrack     1.0, 0,\
        ;         0, 0,\
        ;         0, 0



        ; ; ScenePackedTrack.Choice         PackedTrack     1.33333333, 0,\
        ; ;         ST_Choice.Msgs, ST_Choice.MsgsCount,\
        ; ;         ST_Choice.Seqs, ST_Choice.SeqsCount
        ; ScenePackedTrack.Choice         PackedTrack     1.0, 0,\
        ;         0, 0,\
        ;         0, 0


        ; ; ScenePackedTrack.RunnerFirst    PackedTrack     42.6666666, 0,\
        ; ;         ST_RunnerFirst.Msgs, ST_RunnerFirst.MsgsCount,\
        ; ;         ST_RunnerFirst.Seqs, ST_RunnerFirst.SeqsCount
        ; ScenePackedTrack.RunnerFirst    PackedTrack     1.0, 0,\
        ;         0, 0,\
        ;         0, 0

        ; ScenePackedTrack.RunnerSecond   PackedTrack     1.0, 0,\
        ;         0, 0,\
        ;         0, 0


        ; ScenePackedTrack.RunnerThird    PackedTrack     1.0, 0,\
        ;         0, 0,\
        ;         0, 0

        ; ScenePackedTrack.AfterRunTrack  PackedTrack     1.0, 0,\
        ;         0, 0,\
        ;         0, 0

        ; ScenePackedTrack.PreRunTrack    PackedTrack     1.0, 0,\
        ;         0, 0,\
        ;         0, 0

        ; ScenePackedTrack.Final          PackedTrack     1.0, 0,\
        ;         0, 0,\
        ;         0, 0

        independentpackedtrack          PackedTrack     100.0, 0,\
                0, 0,\
                0, 0
            
        ; ScenePackedTrack.Start          PackedTrack     32.0, 0,\
        ;         ST_Start.Msgs, ST_Start.MsgsCount,\
        ;         ST_Start.Seqs, ST_Start.SeqsCount
        ScenePackedTrack.Start          PackedTrack     1.0, 0,\
                0, 0,\
                0, 0

        ; ScenePackedTrack.Choice         PackedTrack     1.33333333, 0,\
        ;         ST_Choice.Msgs, ST_Choice.MsgsCount,\
        ;         ST_Choice.Seqs, ST_Choice.SeqsCount

        ScenePackedTrack.Choice         PackedTrack     1.0, 0,\
                0, 0,\
                0, 0

        ScenePackedTrack.RunnerFirst    PackedTrack     42.6666666, 0,\
                ST_RunnerFirst.Msgs, ST_RunnerFirst.MsgsCount,\
                ST_RunnerFirst.Seqs, ST_RunnerFirst.SeqsCount

        ScenePackedTrack.RunnerSecond   PackedTrack     1.0, 0,\
                ST_RunnerSecond.Msgs, ST_RunnerSecond.MsgsCount,\
                ST_RunnerSecond.Seqs, ST_RunnerSecond.MsgsCount

        ScenePackedTrack.RunnerThird    PackedTrack     1.0, 0,\
                ST_RunnerThird.Msgs, ST_RunnerThird.MsgsCount,\
                ST_RunnerThird.Seqs, ST_RunnerThird.MsgsCount

        ScenePackedTrack.AfterRun       PackedTrack     1.0, 0,\
                ST_AfterRun.Msgs, ST_AfterRun.MsgsCount,\
                ST_AfterRun.Seqs, ST_AfterRun.MsgsCount 

        ScenePackedTrack.PreRun         PackedTrack     1.0, 0,\
                ST_PreRun.Msgs, ST_PreRun.MsgsCount,\
                ST_PreRun.Seqs, ST_PreRun.MsgsCount 

        ScenePackedTrack.Final          PackedTrack     1.0, 0,\
                ST_Final.Msgs, ST_Final.MsgsCount,\
                ST_Final.Seqs, ST_Final.MsgsCount 

        

Scenes.PackedTracksCount = ($-Scenes.PackedTracks)/sizeof.PackedTrack 

; tracks that will be used during the gameplay process
Scenes.TrackList:
        independenttrack                Track           ?, ?

        SceneTrack.Start                Track           ?, ?
        SceneTrack.ChoiceTrack          Track           ?, ?
        SceneTrack.RunnerFirst          Track           ?, ?
        SceneTrack.RunnerSecond         Track           ?, ?
        SceneTrack.RunnerThird          Track           ?, ?
        SceneTrack.AfterRunTrack        Track           ?, ?
        SceneTrack.PreRunTrack          Track           ?, ?
        SceneTrack.Final                Track           ?, ?
Scenes.TrackListCount = ($-Scenes.TrackList)/sizeof.Track 
; must be the same as Scenes.PackedTracksCount


; array of PackedScenes that link the Scenes with the sound buffers
Scenes.PackedScenes: 
        packedindependentspectator      PackedScene     independenttrack

        SG1_SpectatorStart_Packed       PackedScene     SceneTrack.Start 
        SG1_ChoiceFirst_Packed          PackedScene     SceneTrack.ChoiceTrack 
        SG1_SpectatorPreRun_Packed      PackedScene     SceneTrack.PreRunTrack 
        SG1_RunnerFirst_Packed          PackedScene     SceneTrack.RunnerFirst   
        
        SG2_SpectatorAfterRun_Packed    PackedScene     SceneTrack.AfterRunTrack
        SG2_ChoiceSecond_Packed         PackedScene     SceneTrack.ChoiceTrack
        SG2_SpectatorPreRun_Packed      PackedScene     SceneTrack.PreRunTrack
        SG2_RunnerSecond_Packed         PackedScene     SceneTrack.RunnerSecond   

        SG3_SpectatorAfterRun_Packed    PackedScene     SceneTrack.AfterRunTrack
        SG3_ChoiceSecond_Packed         PackedScene     SceneTrack.ChoiceTrack
        SG3_SpectatorPreRun_Packed      PackedScene     SceneTrack.PreRunTrack
        SG3_RunnerSecond_Packed         PackedScene     SceneTrack.RunnerThird  

        SG4_SpectatorAfterRun_Packed    PackedScene     SceneTrack.AfterRunTrack
        SG4_ChoiceFinal_Packed          PackedScene     SceneTrack.ChoiceTrack
        SG4_SpectatorFinal_Packed       PackedScene     SceneTrack.Final     
Scenes.PackedScenesCount = ($ - Scenes.PackedScenes)/sizeof.PackedScene


; scenes that will be used during the gameplay process
Scenes.SceneList:
        independentspectator            Scene           SCENEMODE_INDEPENDENT, 100.0, ?, <?, ?>

        SG1_SpectatorStart_Scene        Scene           SCENEMODE_SPECTATOR, 32.0, ?, <?, ?>
        SG1_ChoiceFirst_Scene           Scene           SCENEMODE_CHOICE, 5.333333333, ?, <?, ?>
        SG1_SpectatorPreRun_Scene       Scene           SCENEMODE_SPECTATOR, 3.0, ?, <?, ?>
        SG1_RunnerFirst_Scene           Scene           SCENEMODE_RUNNER, 85.33333333, ?, <?, ?>

        SG2_SpectatorAfterRun_Scene     Scene           SCENEMODE_SPECTATOR, 3.0, ?, <?, ?>
        SG2_ChoiceSecond_Scene          Scene           SCENEMODE_CHOICE, 5.333333333, ?, <?, ?>
        SG2_SpectatorPreRun_Scene       Scene           SCENEMODE_SPECTATOR, 3.0, ?, <?, ?>
        SG2_RunnerSecond_Scene          Scene           SCENEMODE_RUNNER, 85.33333333, ?, <?, ?>

        SG3_SpectatorAfterRun_Scene     Scene           SCENEMODE_SPECTATOR, 3.0, ?, <?, ?>
        SG3_ChoiceThird_Scene           Scene           SCENEMODE_CHOICE, 5.333333333, ?, <?, ?>
        SG3_SpectatorPreRun_Scene       Scene           SCENEMODE_SPECTATOR, 3.0, ?, <?, ?>
        SG3_RunnerThird_Scene           Scene           SCENEMODE_RUNNER, 85.33333333, ?, <?, ?>

        SG4_SpectatorAfterRun_Scene     Scene           SCENEMODE_SPECTATOR, 3.0, ?, <?, ?>
        SG4_ChoiceFinal_Scene           Scene           SCENEMODE_CHOICE, 5.333333333, ?, <?, ?>
        SG4_SpectatorFinal_Scene        Scene           SCENEMODE_SPECTATOR, 3.0, ?, <?, ?>

Scenes.SceneListEnd:
Scenes.SceneListCount = (Scenes.SceneListEnd - Scenes.SceneList)/sizeof.Scene     
; must be the same as Scenes.ArrPackedCount
