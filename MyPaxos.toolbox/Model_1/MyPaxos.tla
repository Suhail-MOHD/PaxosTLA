------------------------------ MODULE MyPaxos ------------------------------
EXTENDS Integers, FiniteSets, TLC

CONSTANTS ACCEPTORS, DECREES, NULLVOTE, QUORUMSIZE

QUORUM == {s \in SUBSET ACCEPTORS: Cardinality(s) = QUORUMSIZE}

BallotNum == Nat

Vote == [bal: BallotNum, dec: DECREES] \cup {[bal |-> -1, dec |-> -1]} 
MessageToAcceptor == [type: {"NextBallot"}, bal: BallotNum] \cup [type: {"BeginBallot"}, bal: BallotNum, dec: DECREES]
MessageToLeader == [type: {"LastVote"}, acc: ACCEPTORS, bal: BallotNum, lastVote: Vote] \cup [type: {"Voted"}, bal: BallotNum, acc: ACCEPTORS, vote: Vote]

VARIABLES leaderMsg, acceptorMsg, nextBal, prevVote, remainingBallots


(* Invariants about the types used *)
MsgInvariant == /\ leaderMsg \subseteq MessageToLeader
                /\ acceptorMsg \subseteq MessageToAcceptor

AcceptorStateInvariant == /\ nextBal \in [ACCEPTORS -> BallotNum \cup {-1}]
                          /\ prevVote \in [ACCEPTORS -> Vote]
                    
AllInvariant == /\ MsgInvariant
                /\ AcceptorStateInvariant

(* The initial state *)
Init == /\ nextBal = [a \in ACCEPTORS |-> -1]
        /\ prevVote = [a \in ACCEPTORS |-> [bal |-> -1, dec |-> -1]]
        /\ leaderMsg = {}
        /\ acceptorMsg = {}
        /\ remainingBallots = 1


(* Some helpful utilities *)
SendToLeader(m) == leaderMsg' = leaderMsg \cup {m}
SendToAcceptors(m) == acceptorMsg' = acceptorMsg \cup {m}
FilterMsgs(b, q, t) == {m \in leaderMsg: /\ m.type = t
                                         /\ m.acc \in q
                                         /\ m.bal = b}
GetMaxVote(vs) == CHOOSE v \in vs:
                    /\ \A v2 \in vs:
                        /\ v.bal >= v2.bal


(* The consensus invariant *)
ConsensusDecrees == {dec \in DECREES: \E b \in BallotNum:
    /\ \E q \in QUORUM:
        LET msgs == FilterMsgs(b, q, "Voted")
        IN
        /\ \A msg \in msgs:
            /\ msg.vote.dec = dec
        /\ Cardinality(msgs) = Cardinality(q)
}


VotedBallotsSane == /\ \A b \in BallotNum:
                     LET msgs == {m \in leaderMsg: m.type = "Voted" /\ m.vote.bal = b}
                     IN \/ msgs = {}
                        \/ \E dec \in DECREES:
                          /\ \A msg \in msgs:
                             /\ msg.vote.dec = dec
                             
ConsensusInvariant == VotedBallotsSane /\ Cardinality(ConsensusDecrees) \leq 1



(* The four steps of the paxos algorithm *)
NextBallot(b) == /\ SendToAcceptors([type |-> "NextBallot", bal |-> b])
              /\ UNCHANGED <<leaderMsg, nextBal, prevVote, remainingBallots>>

MaxVote(a) == /\ \E m \in acceptorMsg:
                /\ m.type = "NextBallot"
                /\ m.bal > nextBal[a]
                /\ nextBal' = [nextBal EXCEPT ![a] = m.bal]
                /\ SendToLeader([type |-> "LastVote", acc |-> a, bal |-> m.bal, lastVote |-> prevVote[a]])
              /\ UNCHANGED <<prevVote, acceptorMsg, remainingBallots>>




BeginBallot(b) ==   /\ ~ \E m \in acceptorMsg: /\ m.type = "BeginBallot"
                                               /\ m.bal =  b
                    /\ \E dec \in DECREES:
                        /\ \E q \in QUORUM:
                            LET msgs == FilterMsgs(b, q, "LastVote")
                                votes == {m.lastVote: m \in msgs}
                                maxBallotVote == GetMaxVote(votes)
                            IN /\ Cardinality(msgs) = Cardinality(q)
                               /\ \/ maxBallotVote.bal = -1
                                  \/ maxBallotVote.dec = dec
                        /\ SendToAcceptors([type |-> "BeginBallot", bal |-> b, dec |-> dec])
                    /\ UNCHANGED <<nextBal, prevVote, leaderMsg, remainingBallots>>

Voted(a) == /\ \E m \in acceptorMsg:
                /\ m.type = "BeginBallot"
                /\ m.bal = nextBal[a]
                /\ prevVote' = [prevVote EXCEPT ![a] = [bal |-> m.bal, dec |-> m.dec]]
                /\ SendToLeader([type |-> "Voted", acc |-> a, bal |-> m.bal, vote |-> [bal |-> m.bal, dec |-> m.dec]])
            /\ UNCHANGED <<nextBal, acceptorMsg, remainingBallots>>

\*Success ==    /\ Cardinality(ConsensusDecrees) \geq 1
\*              /\ PrintT(ConsensusDecrees)
\*              /\ UNCHANGED <<leaderMsg, acceptorMsg, nextBal, prevVote, remainingBallots>>

(* Spec definition *)
Next == \/ \E b \in BallotNum: NextBallot(b)
        \/ \E b \in BallotNum: BeginBallot(b)
        \/ \E a \in ACCEPTORS: \/ MaxVote(a)
                               \/ Voted(a)
\*        \/ Success

Spec == Init /\ [][Next]_<<leaderMsg, acceptorMsg, nextBal, prevVote, remainingBallots>>


\*THEOREM Invariance == Spec => []Inv
=============================================================================

