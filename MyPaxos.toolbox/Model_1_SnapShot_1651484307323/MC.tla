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
const_1651484291257214000 == 
{a1, a2, a3, a4, a5, a6}
----

\* MV CONSTANT definitions DECREES
const_1651484291257215000 == 
{d1, d2}
----

\* CONSTANT definitions @modelParameterConstants:3QUORUMSIZE
const_1651484291257216000 == 
2
----

\* CONSTANT definition @modelParameterDefinitions:0
def_ov_1651484291257217000 ==
1..2
----
=============================================================================
\* Modification History
\* Created Mon May 02 04:38:11 CDT 2022 by suhailmuhammed
