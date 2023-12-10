track2msgs:
       UnprocessedMessage        <E3,2.66,0.0>, INSTR_BASS
       UnprocessedMessage        <G3,2.66,2.66>, INSTR_BASS
       UnprocessedMessage        <B3,2.66,5.32>, INSTR_BASS
       UnprocessedMessage        <A3,2.66,7.98>, INSTR_BASS

TRACK2_MESSAGESCOUNT = ($-track2msgs)/sizeof.UnprocessedMessage


; sequencers array
track2seqs:
       Sequencer                 track2seqs.messages, TRACK2_SEQMSGSCOUNT, 90.0, 0.0, 4, 4 
TRACK2_SEQUENCERSCOUNT = ($-track2seqs)/sizeof.Sequencer


; sequencer messages
track2seqs.messages:
       SeqMessage                testtrack2seqmessagehihat, 0111111111111111b
;       SeqMessage                testtrack2seqmessagehihat2, 8AAAh                
TRACK2_SEQMSGSCOUNT = ($-track2seqs.messages)/sizeof.SeqMessage

testtrack2seqmessagehihat   UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT
testtrack2seqmessagehihat2  UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT

track2          Track                     10.64, 0