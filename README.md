Part of the MATLAB codes for the phase tumbling project.
The codes are also related to my previous repositories, such as NT/CNT projects. 

To determine the reentrainment time of the fully coupled two oscillators model in four steps:

1. Setting up the ODE solver with appropriate options, including event detection to identify section crossings. For each oscillator, we have two event sections at its $P_1=1.72$ and $P_2=1.72$. 

2. Solving the ODE system to obtain event times and corresponding states at the events.

3. Analyzing the event times to determine reentrainment times based on the periodic behavior of the system at sections O1 and O2.

4. Returning the maximum reentrainment time among O1 and O2, which is the total entrainment time of the system.

The code file \verb|map_checktime_C.m| does the calculation and returns three kinds of reentrain time \verb|t_entrain|, \verb|t_entrain_O1|, \verb|t_entrain_O2|

Code \verb|Fig7b.m| iteratively applying the 2D mapping function \verb|map2D_general_phase.m| to trace the trajectory of initial conditions over multiple iterations. The purpose is to visualize how the 2D map evolves over time and understand its behavior in the phase space.
