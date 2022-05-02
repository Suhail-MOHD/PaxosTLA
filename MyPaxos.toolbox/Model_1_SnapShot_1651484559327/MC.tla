---- MODULE MC ----
EXTENDS MyPaxos, TLC

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
a1, a2, a3, a4, a5, a6
----

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
d1, d2
----

\* MV CONSTANT definitions ACCEPTORS
const_1651484499127226000 == 
{a1, a2, a3, a4, a5, a6}
----

\* MV CONSTANT definitions DECREES
const_1651484499127227000 == 
{d1, d2}
----

\* CONSTANT definitions @modelParameterConstants:3QUORUMSIZE
const_1651484499127228000 == 
4
----

\* CONSTANT definition @modelParameterDefinitions:0
def_ov_1651484499127229000 ==
1..2
----
=============================================================================
\* Modification History
\* Created Mon May 02 04:41:39 CDT 2022 by suhailmuhammed
