for project 4 of spring 2015 cs61c, we optimized a bitmap depth map generator (more info)[http://inst.eecs.berkeley.edu/~cs61c/fa15/projs/04/] 

to test our code accurately, we would ssh onto the same machines these are graded on to get the closest idea of how our code performed. unfortunately, with 600 students in the class divided by 30 machines, some of these machines would get incredibly loaded so i wrote a script that found the machine with the least load, sshed in, and ran the benchmarking commands

sorta slow because it sshs into each machine sequentially so finding the load takes about a minute. could be parallelized with gnu parallel but that's an unnecessary dependency

requires you to set up public key ssh auth (passwordless)

written in bash
