all: demedal trisubdot

trisubdot: trisubdot.c
	gcc trisubdot.c -lm -o trisubdot

demedal: demedal.c
	gcc demedal.c -o demedal
