---- MODULE MC ----
EXTENDS MyPaxos, TLC

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
a1, a2, a3, a4
----

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
d1, d2
----

\* MV CONSTANT definitions ACCEPTORS
const_1651483373862173000 == 
{a1, a2, a3, a4}
----

\* MV CONSTANT definitions DECREES
const_1651483373862174000 == 
{d1, d2}
----

\* CONSTANT definitions @modelParameterConstants:3QUORUMSIZE
const_1651483373862175000 == 
3
----

\* CONSTANT definition @modelParameterDefinitions:0
def_ov_1651483373862176000 ==
1..2
----
=============================================================================
\* Modification History
\* Created Mon May 02 04:22:53 CDT 2022 by suhailmuhammed
