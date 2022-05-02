---- MODULE MC ----
EXTENDS MyPaxos, TLC

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
a1, a2, a3, a4, a5, a6, a7, a8
----

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
d1, d2
----

\* MV CONSTANT definitions ACCEPTORS
const_1651482804382163000 == 
{a1, a2, a3, a4, a5, a6, a7, a8}
----

\* MV CONSTANT definitions DECREES
const_1651482804382164000 == 
{d1, d2}
----

\* CONSTANT definitions @modelParameterConstants:3QUORUMSIZE
const_1651482804382165000 == 
5
----

\* CONSTANT definition @modelParameterDefinitions:0
def_ov_1651482804382166000 ==
1..2
----
=============================================================================
\* Modification History
\* Created Mon May 02 04:13:24 CDT 2022 by suhailmuhammed
