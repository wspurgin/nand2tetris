// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

// Put your code here.

(WAIT)
    @KBD
    D=M

    @BLACK
    D;JNE

    @WHITE
    D;JEQ

    @WAIT
    0;JMP

(BLACK)

    @SCREEN //start of screen map
    D=A

    @pos //set position to start
    M=D

    @LOOP1
    0;JMP

    (LOOP1)


        @pos //get current position
        D=M

        A=D //Set current pos to 'black'
        M=-1

        @pos //increment position
        M=M+1

        @24576 //check if we are at the end
        D=A

        @pos
        D=D-M

        @WAIT
        D;JEQ
        
        @LOOP1
        D;JGT

(WHITE)

    @SCREEN //start of screen map
    D=A

    @pos //set position to start
    M=D

    @LOOP2
    0;JMP

    (LOOP2)


        @pos //get current position
        D=M

        A=D //Set current pos to 'white'
        M=0

        @pos //increment position
        M=M+1

        @24576 //check if we are at the end
        D=A

        @pos
        D=D-M

        @WAIT
        D;JEQ
        
        @LOOP2
        D;JGT
