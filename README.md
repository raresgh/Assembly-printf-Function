# Assembly-printf-Function
This is printf function project written in Assembly x86 AT&amp;T which does not use any of the C Library pre-defined functions

# Run this in the terminal
as -no-pie -g -o printf.o my_printf.s && ld --fatal-warnings --entry main -o printf printf.o

# Then run this
./printf

# How to change param/fstring
To change format string and parameters you would do that in the my_printf.s in the main function. First 5 parameters are placed in registers, and if the number of param exceeds 5 you push them on the stack.
