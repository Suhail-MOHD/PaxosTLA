---- MODULE MC ----
EXTENDS MyPaxos, TLC

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
a1, a2, a3
----

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
d1, d2
----

\* MV CONSTANT definitions ACCEPTORS
const_1651482755732153000 == 
{a1, a2, a3}
----

\* MV CONSTANT definitions DECREES
const_1651482755732154000 == 
{d1, d2}
----

\* CONSTANT definitions @modelParameterConstants:3QUORUMSIZE
const_1651482755732155000 == 
2
----

\* CONSTANT definition @modelParameterDefinitions:0
def_ov_1651482755732156000 ==
1..2
----
=============================================================================
\* Modification History
\* Created Mon May 02 04:12:35 CDT 2022 by suhailmuhammed
