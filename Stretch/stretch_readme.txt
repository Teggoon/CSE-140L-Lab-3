Lab 3: Stretch Implementation

Haocheng Li (A15608864)
Vicente Montoya(A15561775)

Report:

Everything seems to work fine: the output matches that of the correct output file given to us. We included the testbench and 
the output transcript file when running the testbench. There are no screenshots of the waveform viewer since Professor Eldon said
we can skip it.

Implementation description:
A lot of the foundation structure, such as the clock mechanics, the structure of the state machine, mechanics of green turning to 
yellow, turning to red, etc. are taken from part 1. A new variable was added to keep track of the priority, and the priority of the
states, based on the google doc that was given, were hard-coded into the code (hence the super long code).