//Patrick Quan - 10152770
//CPSC 355
//Assignment 6

//m4 macros
define(fd_r, w19)
define(nread_r, x20)
define(buf_base_r, x21)
define(input_r, d19)
define(output_r, d20)
define(x_r, d21)
define(y_r, d22)
define(dy_r, d23)
define(dydx_r, d24)
define(absdy_r, d25)
define(maxError_r, d26)



//String templates
pn:       .string         "input.bin"
fmt1:     .string         "Error opening file: %s \nExiting Application\n\n"
fmt2:     .string         "Input Number\t\tCube Root\n"
fmt3:     .string         "%13.10f\t\t%13.10f\n"



//Assembler equates
AT_FDCWD = -100 //Pathname is relative to the program's current working directory
buf_size = 8 //8 bytes read per line
alloc = -(16 + buf_size) & -16 //Amount of space required to allocate in main
dealloc = -alloc //Amount of space to return to the stack
buf_s = 16 //Location of buffer memory in stack
O_RDONLY = 0 //Read-only access

error:     .double 0r1.0e-10

          .balign 4 //Word aligned instructions
          .global main //Main is globally visible
main:
  stp      x29, x30, [sp, alloc]! //Storing FP and LR into the stack and allocating the required memory
  mov      x29, sp //Moving the SP into the FP

//Opening the file specified by the command line input
  mov      w0, AT_FDCWD //First arg (use cwd)
  ldr      x1, [x1, 8] //Second arg (pathname) input from command line
  mov      w2, O_RDONLY //Third arg (read only)
  mov      w3, 0 //Fourth arg (not used)
  mov      x8, 56 //openat I/O request
  svc      0 //Call system function
  mov      fd_r, w0 //Save the file descriptor to fd_r
  cmp      fd_r, 0 //Error check
  b.ge     open_ok //If the returned FD is greater than or equal to 0, branch to open_ok (no error occured)

  //If the returned FD is less than 0, an error has occurred when opening the file
  adrp    x0, fmt1 //Error handling string template
  add     x0, x0, :lo12:fmt1 //Lower 12 bits (1st arg)
  adrp    x1, pn //Name of the file that failed to open
  add     x1, x1, :lo12:pn //Lower 12 bits (2nd arg)
  bl      printf //Branch link to printf
  b       done

open_ok:
  add     buf_base_r, x29, buf_s //Calculating the location of the buffer base
  //Printing table header
  adrp    x0, fmt2 //Column names
  add     x0, x0, :lo12:fmt2 //Lower 12 bits
  bl      printf //Branch link to printf

top:
//Reading from the input file previously opened
  mov     w0, fd_r //1st arg(fd)
  mov     x1, buf_base_r //2nd arg(pointer to buffer in stack)
  mov     w2, buf_size //Number of bytes to be read
  mov     x8, 63 //Read I/O request
  svc     0 //Call system function
  mov     nread_r, x0 //Number of bytes actually read stored into nread_r


  cmp     nread_r, buf_size   //Comparing the number of bytes actually read to the number of bytes that each line contains
  b.ne    close //If the number of bytes read is not the same as the number of bytes that should have been read, end the program as there are no more lines to read

//Using Newton's method to aproximate the cube root of the input number
  ldr      input_r, [buf_base_r] //Loading the read FP number into register d0

  adrp     x26, error //x26 = error
  add      x26, x26, :lo12:error //Lower 12 bits
  ldr      maxError_r, [x26] //Loading the maxError from x26
  fmul     maxError_r, maxError_r, input_r //maxError_r = input * 1.0e-10

  //x = input / 3.0
  fmov    d9, 3.0
  fmov    x_r, input_r
  fdiv    x_r, x_r, d9

loop:
  //Setting up the arguments for newtonsMethod
  fmov    d0, input_r //1st arg
  fmov    d1, x_r //2nd arg
  bl      newtonsMethod //Branch link to newtonsMethod

  fmov    x_r, d1 // x = x
  fabs    absdy_r, d3 //|dy| = dy

  fcmp    absdy_r, maxError_r  //Comparing dy to the maximum allowed error
  b.gt    loop //If the absolute value of dy is greater than the allowed error, Newton's Method is repeated

  fmov    output_r, x_r //Storing the calculated cube root to the output_r
  adrp    x0, fmt3 //Input number and corresponding cube root
  add     x0, x0, :lo12:fmt3 //Lower 12 bits
  fmov    d0, input_r
  fmov    d1, output_r
  bl      printf //Branch link to printf

  b top //Branch back to the top of the loop

//Closing the binary file
close:
  mov     w0, fd_r //1st arg(fd)
  mov     x8, 57 //Close I/O request
  svc     0 //Call system function

done:
  ldp     x29, x30, [sp], dealloc //Restoring fp and lr from stack
  ret //Returning to caller

//Subroutine to use Newton's method to aproximate the cube root
//d0 = input, d1 = x, d2 = y, d3 = dy, d4 = dydx
newtonsMethod:
  stp     x29, x30, [sp, -16]!
  mov     x29, sp

  fmov    d9, 3.0

  //y = x * x * x
  fmul    d2, d1, d1
  fmul    d2, d2, d1

  //dy = y - input
  fsub    d3, d2, d0

  //dy/dx = 3.0 * x * x
  fmul    d4, d9, d1
  fmul    d4, d4, d1

  //x = x - dy / (dy/dx)
  fdiv    d10, d3, d4
  fsub    d1, d1, d10

  ldp     x29, x30, [sp], 16
  ret
