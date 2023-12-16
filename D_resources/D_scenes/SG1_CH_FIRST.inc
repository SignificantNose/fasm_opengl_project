SG1_ChoiceFirst.Msgs:
       UnprocessedMessage        <E3,2.66,0.0>, INSTR_BASS
       UnprocessedMessage        <G3,2.66,2.66>, INSTR_BASS
       UnprocessedMessage        <B3,2.66,5.32>, INSTR_BASS
       UnprocessedMessage        <A3,2.66,7.98>, INSTR_BASS

SG1_ChoiceFirst.MsgsCount = ($-SG1_ChoiceFirst.Msgs)/sizeof.UnprocessedMessage


; sequencers array
SG1_ChoiceFirst.Seqs:
       ; Sequencer                 testTrack_SeqMsgs, testTrack_SeqMsgsCount, 90.0, 0.0, 4, 4 
SG1_ChoiceFirst.SeqsCount = ($-SG1_ChoiceFirst.Seqs)/sizeof.Sequencer


; sequencer messages
SG1_ChoiceFirst.SeqMsgs:
       ; SeqMessage                testtrack2seqmessagehihat, 0111111111111111b
;       SeqMessage                testtrack2seqmessagehihat2, 8AAAh                
SG1_ChoiceFirst.SeqMsgsCount = ($-SG1_ChoiceFirst.SeqMsgs)/sizeof.SeqMessage

; testtrack2seqmessagehihat   UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT
; testtrack2seqmessagehihat2  UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT

; track2          PackedTrack                     10.64, 0