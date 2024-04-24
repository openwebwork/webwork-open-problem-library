This is a repository of problem libraries developed at Portland Community College. 

The most important copy of this repo lives at webwork.pcc.edu, in opt/webwork/libraries/PCC/.
Subfolders (like BasicMath, BasicAlgebra, etc.) are symlinked from typical courses' templates
folders. 

For problem development, each person working on problem development has their own LibDev course,
for example LibDev-jordan. These courses do *not* have symlinks to BasicMath, etc. Instead, they 
have copies of the entire repo, stored in templates/local/PCC/.

Developers work on problems from the web side of their LibDev course. As needed, development is 
committed, and pushed to the repo at opt/webwork/libraries/PCC/, from which it is pushed back down
to all other LibDev courses.

Lastly, the subfolders in opt/webwork/libraries/PCC/ are periodically *copied* (not using git in 
any way) into webwork-open-problem-library/Contrib/PCC/, so that development can be committed to 
that repo and shared with the world.
