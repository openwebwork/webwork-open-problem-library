This perl module is used in several pg files in setGraphTheory.
The perl module calls a C program to do the actual work.
Three steps are required for the installation :

1. The files should be copied here:

/opt/webwork/pg/lib/Chromatic.pm
/opt/webwork/pg/lib/chromatic/color.c

Apache restart is needed after editing Chromatic.pm

2. color.c needs to be compiled with the command

gcc -O3 color.c -o color

3. The module Chromatic.pm needs to be loaded in global.conf.
Follow the syntax of other perl modules loaded. Search for
'PG modules to load' in global.conf to find the location.
