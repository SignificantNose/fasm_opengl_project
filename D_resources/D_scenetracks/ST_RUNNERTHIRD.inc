ST_RunnerThird.Msgs:
    ;    UnprocessedMessage        <E3,2.66,0.0>, INSTR_BASS
    ;    UnprocessedMessage        <G3,2.66,2.66>, INSTR_BASS
    ;    UnprocessedMessage        <B3,2.66,5.32>, INSTR_BASS
    ;    UnprocessedMessage        <A3,2.66,7.98>, INSTR_BASS
ST_RunnerThird.MsgsCount = ($-ST_RunnerThird.Msgs)/sizeof.UnprocessedMessage



ST_RunnerThird.Seqs:
       ; Sequencer                 testTrack_SeqMsgs, testTrack_SeqMsgsCount, 90.0, 0.0, 4, 4 
ST_RunnerThird.SeqsCount = ($-ST_RunnerThird.Seqs)/sizeof.Sequencer



ST_RunnerThird.SeqMsgs:
       ; SeqMessage                testtrack2seqmessagehihat, 0111111111111111b
;       SeqMessage                testtrack2seqmessagehihat2, 8AAAh                
ST_RunnerThird.SeqMsgsCount = ($-ST_RunnerThird.SeqMsgs)/sizeof.SeqMessage