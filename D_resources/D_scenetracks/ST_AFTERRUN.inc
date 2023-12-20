ST_AfterRun.Msgs:
       UnprocessedMessage          <D3, 5.333333333333333, 0.0>, INSTR_BASS

       UnprocessedMessage          <E5, 0.333333333, 0.0>, INSTR_SYNTH
       UnprocessedMessage          <D5, 0.166666666, 0.333333333>, INSTR_SYNTH
       UnprocessedMessage          <E5, 0.333333333, 0.5>, INSTR_SYNTH
       UnprocessedMessage          <D5, 0.166666666, 0.833333333>, INSTR_SYNTH
       UnprocessedMessage          <E5, 1.333333333, 1.0>, INSTR_SYNTH

       UnprocessedMessage          <E2, 0.333333333, 4.833333333>, INSTR_TOM
       UnprocessedMessage          <D2, 0.333333333, 5.0>, INSTR_TOM
       UnprocessedMessage          <A1, 0.333333333, 5.166666666>, INSTR_TOM

ST_AfterRun.MsgsCount = ($-ST_AfterRun.Msgs)/sizeof.UnprocessedMessage


; sequencers array
ST_AfterRun.Seqs:
       ; Sequencer                 testTrack_SeqMsgs, testTrack_SeqMsgsCount, 90.0, 0.0, 4, 4 
ST_AfterRun.SeqsCount = ($-ST_AfterRun.Seqs)/sizeof.Sequencer


; sequencer messages
ST_AfterRun.SeqMsgs:
       ; SeqMessage                testtrack2seqmessagehihat, 0111111111111111b
;       SeqMessage                testtrack2seqmessagehihat2, 8AAAh                
ST_AfterRun.SeqMsgsCount = ($-ST_AfterRun.SeqMsgs)/sizeof.SeqMessage

; testtrack2seqmessagehihat   UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT
; testtrack2seqmessagehihat2  UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT

; track2          PackedTrack                     10.64, 0