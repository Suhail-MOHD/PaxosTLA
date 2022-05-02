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
const_1651482139845138000 == 
{a1, a2, a3}
----

\* MV CONSTANT definitions DECREES
const_1651482139845139000 == 
{d1, d2}
----

\* CONSTANT definitions @modelParameterConstants:0QUORUM
const_1651482139845140000 == 
{{a1, a2}, {a2, a3}, {a1, a3}}
----

\* CONSTANT definition @modelParameterDefinitions:0
def_ov_1651482139845141000 ==
1..2
----
=============================================================================
\* Modification History
\* Created Mon May 02 04:02:19 CDT 2022 by suhailmuhammed
