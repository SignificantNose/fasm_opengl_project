ST_Final.Msgs:

       UnprocessedMessage        <E5, 0.3333333, 0.0>, INSTR_SYNTH
       UnprocessedMessage        <D5, 0.1666666, 0.3333333>, INSTR_SYNTH
       UnprocessedMessage        <E5, 1.3333333, 0.5>, INSTR_SYNTH

       UnprocessedMessage        <B4, 0.1666666, 4.8333333>, INSTR_SYNTH
       UnprocessedMessage        <C5, 0.1666666, 5.0>, INSTR_SYNTH
       UnprocessedMessage        <D5, 0.1666666, 5.1666666>, INSTR_SYNTH
       UnprocessedMessage        <E5, 0.3333333, 5.3333333>, INSTR_SYNTH
       UnprocessedMessage        <D5, 0.1666666, 5.6666666>, INSTR_SYNTH
       UnprocessedMessage        <E5, 1.3333333, 5.8333333>, INSTR_SYNTH


       
       UnprocessedMessage        <C3, 1.3333333, 0.0>, INSTR_BASS
       UnprocessedMessage        <D3, 1.3333333, 1.3333333>, INSTR_BASS
       UnprocessedMessage        <E3, 2.6666666, 2.6666666>, INSTR_BASS
       UnprocessedMessage        <C3, 1.3333333, 5.3333333>, INSTR_BASS
       UnprocessedMessage        <D3, 1.3333333, 6.6666666>, INSTR_BASS
       UnprocessedMessage        <E3, 2.6666666, 8.0>, INSTR_BASS

ST_Final.MsgsCount = ($-ST_Final.Msgs)/sizeof.UnprocessedMessage


; sequencers array
ST_Final.Seqs:
       ; Sequencer                 testTrack_SeqMsgs, testTrack_SeqMsgsCount, 90.0, 0.0, 4, 4 
ST_Final.SeqsCount = ($-ST_Final.Seqs)/sizeof.Sequencer


; sequencer messages
ST_Final.SeqMsgs:
       ; SeqMessage                testtrack2seqmessagehihat, 0111111111111111b
;       SeqMessage                testtrack2seqmessagehihat2, 8AAAh                
ST_Final.SeqMsgsCount = ($-ST_Final.SeqMsgs)/sizeof.SeqMessage

; testtrack2seqmessagehihat   UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT
; testtrack2seqmessagehihat2  UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT

; track2          PackedTrack                     10.64, 0