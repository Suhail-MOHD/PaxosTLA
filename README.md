# PaxosTLA
A TLA+ specification of the basic Paxos algorithm described in 'The Part-Time Parliament' paper authored by Leslie Lamport

TLA+ is a high-level language used to specify systems and verify their correctness. The language allows specifing assertions on the state of the program and also specifying the next state through those same assertions.

The Paxos spec lies in MyPaxos.tla. It is the only file of importance.

To start off, we first define what composes the state of our program. The Paxos system implemented consists of leaders and Acceptors, where a leader proposes a value and an Acceptor accepts it. The following variables define the state of all Leaders and Acceptors:

```
CONSTANTS ACCEPTORS, DECREES, NULLVOTE, QUORUMSIZE
VARIABLES leaderMsg, acceptorMsg, nextBal, prevVote, remainingBallots

The important ones are described below:
ACCEPTORS: The set of all acceptor IDs. This is configured manually when running the model-checker.
DECREES: The set of all decrees. This is configured manually when running the model-checker.
leaderMsg: This is a set of all messages sent to the leader
acceptorMsg: This is a set of all messages sent to the acceptor
nextBal, prevVote: The last ballot and last vote that an acceptor cast. This is a tuple of elements where each element represents one acceptor.
```

Paxos consists of 4 actions that can be taken. In TLA+, an action consists of:
- asserting whether the conditions for the action to execute have been met
- specifying the next state of the program once the action is complete.

Here are the 4 actions of Paxos in TLA+. 
```
(*
The NextBallot action is performed by a leader

It can be performed any time and has no pre-conditions to be met. So, it directly performs SendToAcceptors which adds a message to the 'acceptorMsg' set. It also asserts that the other variables remain unchanged in the next state through the UNCHANGED keyword.
*)
NextBallot(b) == /\ SendToAcceptors([type |-> "NextBallot", bal |-> b])
                 /\ UNCHANGED <<leaderMsg, nextBal, prevVote, remainingBallots>>

(*
MaxVote is carried out by an Acceptor which is passed in as the parameter 'a'

MaxVote is only carried out in response to a NextBallot message sent by the leader (and some other conditions specified by the Paxos algorithm). So, the first 3 lines is a conjunction that asserts that there exists (\E is the existential quantifier) a message m in 'acceptorMsg' (in the current state) whose type is "NextBallot" and whose ballot number is greater than any we have voted for or seen before. 'SendToLeader' will be allowed to specify the next state of the system and send the LastVote message to the leader only if previous conditions hold true.
*)
MaxVote(a) == /\ \E m \in acceptorMsg:
                /\ m.type = "NextBallot"
                /\ m.bal > nextBal[a]
                /\ nextBal' = [nextBal EXCEPT ![a] = m.bal]
                /\ SendToLeader([type |-> "LastVote", acc |-> a, bal |-> m.bal, lastVote |-> prevVote[a]])
              /\ UNCHANGED <<prevVote, acceptorMsg, remainingBallots>>


(*
BeginBallot is carried out by a leader for a particular ballot when it notices that a quorum of Acceptors have responded with LastVote.

It tries to a decree 'dec' and a quorum 'q', such that:
- Every acceptor in the quorum has sent a LastVote message with ballot 'b'
- dec is the decree of the largest ballot amongst all previously voted ballots sent by the quorum 'q' to  the leader.

If it is able to find 'dec' and 'q', the leader send a message to the acceptors to begin the ballot.
*)
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

(*
Voted is carried out by an acceptor in response to a BeginBallot

It only responds if the ballot number is greater than the last ballot voted for or seen. If that condition is satisfied, then the acceptor votes for the ballot by sending a message back to the leader.
*)
Voted(a) == /\ \E m \in acceptorMsg:
                /\ m.type = "BeginBallot"
                /\ m.bal = nextBal[a]
                /\ prevVote' = [prevVote EXCEPT ![a] = [bal |-> m.bal, dec |-> m.dec]]
                /\ SendToLeader([type |-> "Voted", acc |-> a, bal |-> m.bal, vote |-> [bal |-> m.bal, dec |-> m.dec]])
            /\ UNCHANGED <<nextBal, acceptorMsg, remainingBallots>>

```

A ballot is said to be accepted if a quorum of acceptors vote for it.

The following conditions check the safety of the algorithm and ensure that no more than one decree is accepted by the system.

```
(* 
The set of all decrees that have reached consensus

The below code can be translated into english as:
ConsensusDecrees is the set of all 'dec' in Decrees such that:
- there exists a ballot b and quorum q such that:
  - all votes in the ballot have the same decree, 'dec'
  - all acceptors in the quorum have voted for b (through the cardinality check)
*)
ConsensusDecrees == {dec \in DECREES: \E b \in BallotNum:
    /\ \E q \in QUORUM:
        LET msgs == FilterMsgs(b, q, "Voted")
        IN
        /\ \A msg \in msgs:
            /\ msg.vote.dec = dec
        /\ Cardinality(msgs) = Cardinality(q)
}

(*
This is a sanity check to ensure that no two votes in the same ballot have different decrees
*)
VotedBallotsSane == /\ \A b \in BallotNum:
                     LET msgs == {m \in leaderMsg: m.type = "Voted" /\ m.vote.bal = b}
                     IN \/ msgs = {}
                        \/ \E dec \in DECREES:
                          /\ \A msg \in msgs:
                             /\ msg.vote.dec = dec
(* The consensus invariant asserts that only one element exists in ConsensusDecrees and that the votes are well-formed *)
ConsensusInvariant == VotedBallotsSane /\ Cardinality(ConsensusDecrees) \leq 1
```

We've defined actions and invariants, but we haven't really plugged them into the TLA+ model checker yet. The next step is to define a temporal formula that describes how the program runs.

We first describe the next action the program can take:
```
Next == \/ \E b \in BallotNum: NextBallot(b)
        \/ \E b \in BallotNum: BeginBallot(b)
        \/ \E a \in ACCEPTORS: \/ MaxVote(a)
                               \/ Voted(a)
```
Next is a disjunction of the actions we defined later. This branches the system into separate states. i.e The system can either perform NextBallot (assuming conditions are met) OR it can perform one of the other three (MaxVote, Voted, BeginBallot). For each of the possible actions, TLA+ will generate a new state and check each new state. An interesting point to note that it can only perform ONE action across each branch, which begs the question: How does this verify concurrent execution of actions. The answer is that it doesn't. It doesn't matter though. In TLA+, we have full control of the abstraction over which we design our system. In this case, we have process local state which is local to each acceptor and a pair of communication channels (leaderMsg, acceptorMsg). In each action, a process should only modify its local state and one communication channel. As a result a concurrent execution of two actions A and B in the real world, can be represent by a sequential execution of A -> B OR B->A, both of which will be explored by the model checker. If we change the rules and modify another processes state, then we're admitting that there exists some form of mutual exclusion that allows our action to run in isolation and if we implement the spec in the real world without it then our program may not meet the requirements verified.

We now implement the spec:
```
Spec == Init /\ [][Next]_<<leaderMsg, acceptorMsg, nextBal, prevVote, remainingBallots>>
```

The spec is a temporal formula that means the following:
- Init is true for the initial state of the program
- The next clause specifies that Next is true for the next and all successive states of the program. The TLA+ model-checker will keep apply Next on the state to generate new states and verify them.
- Additionally, this temporal spec also specifies that it is possible for the system to take no Action and leave all the state variables as is in the next state.

The last point is important. Since we're modelling a distributed system, we also want to model process failures or message loss. Allowing the system to take no step, allows the model-checker to explore paths where an action stops executing. For example, it can explore a path where BeginBallot(b) never executes for a given ballot. Since BeginBallot never executes, we never check to see if the required messages have arrived for BeginBallot and this simulates a message loss.

Finally, we add the ConsensusInvariant to the model-checker and execute it. The model-checker allows configuring the input paramaters for the algorithm like the set of Acceptors and the set of Decrees. The runtime of the model-checker grows exponentially with the size of input since it enumerates all possible states and checks whether the invariants are met. I have tested it out with acceptors ranging from sizes 3-6. To confirm that my invariant is working correctly, I also tested out reducing the size of the QUORUM to less than a majority of all acceptors and the verification failed as expected.
