//Patrick Quan - 10152770
//CPSC 355
//Assignment 5

define(i_r, w19) //w19 register renamed as i_r
define(argc_r, w20) //w20 register renamed as argc_r
define(argv_r, x21) //w21 register renamed as argv_r
define(month_r, w22) //w22 register renamed to month_r
define(day_r, x23) //w23 register renamed to day_r

//Format string templates
      .text
fmt1: .string "%s %dst is %s\n" //Tempate for days ending in 1
fmt2: .string "%s %dnd is %s\n" //Tempate for days ending in 2
fmt3: .string "%s %drd is %s\n" //Tempate for days ending in 3
fmt4: .string "%s %dth is %s\n" //Tempate for days ending in 0, 4 to 9
jan_m: .string "January"
feb_m: .string "February"
mar_m: .string "March"
apr_m: .string "April"
may_m: .string "May"
jun_m: .string "June"
jul_m: .string "July"
aug_m: .string "August"
sep_m: .string "September"
oct_m: .string "October"
nov_m: .string "November"
dec_m: .string "December"
error: .string "Usage: a5b mm dd\n"
win_m: .string "Winter" //December, January, February
spr_m: .string "Spring"//March, April, May
sum_m: .string "Summer" //June, July, August
fal_m: .string "Fall" //September, October, November
placeholder: .string ""

//Initializing global variables
      .data
month_m: .dword placeholder, jan_m, feb_m, mar_m, apr_m, may_m, jun_m, jul_m, aug_m, sep_m, oct_m, nov_m, dec_m //Array used to store all months
season_m: .dword placeholder, win_m, spr_m, sum_m, fal_m //Array used to store seasons

      .text
      .global main
      .balign 4
main:
      stp         x29, x30, [sp, -16]! //Storing FP and LR into the stack and allocating the required memory
      mov         x29, sp //Moving the SP into the FP

      mov         argc_r, w0 //Storing the total number of arguments into argc_r
      cmp         argc_r, 3 //Comparing total number of args to 3
      b.eq        top       //If they are equal, branch to top

inputError:
      adrp        x0, error //Adding error string to first arg
      add         x0, x0, :lo12:error //Lower 12 bits
      bl          printf  //Branch link to printf
      b           done //Branch to done

top:
      mov         argv_r, x1 //Storing the array of arguments into argv_r

      mov         i_r, 1 //Setting counter i to 1

      ldr         x0, [argv_r, i_r, SXTW 3] //Setting the 1st arg to the first command line argument (month)
      bl          atoi //Converting month string to an int using atoi
      mov         month_r, w0 //Setting month_r to be the returned int

      mov         i_r, 2 //Setting counter i to 2

      ldr         x0, [argv_r, i_r, SXTW 3] //Setting the 1st arg to the second command line argument (day)
      bl          atoi //Converting day string to an int using atoi
      mov         day_r, x0 //Setting month_r to be the returned int

      cmp         month_r, 0 //Compare month to 0
      b.le        inputError //if less than 0, branch to inputError
      cmp         month_r, 12 //Compare month to 12
      b.gt        inputError //if greater than  0, branch to inputError

      cmp         day_r, 0 //Compare month to 0
      b.le        inputError //if less than 0, branch to inputError
      cmp         day_r, 31 //Compare month to 12
      b.gt        inputError //if greater than  0, branch to inputError

      //Setting up the print template with the month and day
      adrp        x24, month_m //Loading x24 as month_m
      add         x24, x24, :lo12:month_m //Lower 12 bits
      ldr         x1, [x24, month_r, SXTW 3] //Setting the month from the month_m into x1 (2nd arg)
      mov         x2, day_r //Settign the day_r into x2 (3rd arg)

      //Comparing the days to determine if it ends in 1, 2, or 3
      cmp         day_r, 1 //Compare month to 1
      b.eq        endsOne //if equal branch to endsOne
      cmp         day_r, 21 //Compare month to 21
      b.eq        endsOne //if equal branch to endsOne
      cmp         day_r, 31 //Compare month to 31
      b.eq        endsOne //if equal branch to endsOne

      cmp         day_r, 2 //Compare month to 1
      b.eq        endsTwo //if equal branch to endsOne
      cmp         day_r, 22 //Compare month to 21
      b.eq        endsTwo //if equal branch to endsOne

      cmp         day_r, 3 //Compare month to 1
      b.eq        endsThree //if equal branch to endsOne
      cmp         day_r, 23 //Compare month to 21
      b.eq        endsThree //if equal branch to endsOne

      //If the day does not end in 1, 2, or 3, the default format will be used
      adrp        x0, fmt4 //Adding fmt4 to the 1st argument
      add         x0, x0, :lo12:fmt4 //Lower 12 bits

      b           next //Branch to season

//If the day ends in 1
endsOne:
  adrp        x0, fmt1 //Adding fmt1 to the 1st argument
  add         x0, x0, :lo12:fmt1 //Lower 12 bits
  b           next

//If the day ends in 2
endsTwo:
  adrp        x0, fmt2 //Adding fmt2 to the 1st argument
  add         x0, x0, :lo12:fmt2 //Lower 12 bits
  b           next

//If the day ends in 3
endsThree:
  adrp        x0, fmt3 //Adding fmt3 to the 1st argument
  add         x0, x0, :lo12:fmt3 //Lower 12 bits
  b           next

next:
  adrp        x25, season_m //Loading season_m as x25
  add         x25, x25, :lo12:season_m //Lower 12 bits

  cmp         month_r, 1 //Comparing the month to 1
  b.eq        isWinter  //If less than 6 (June), its spring
  cmp         month_r, 2 //Comparing the month to 2
  b.eq        isWinter  //If less than 6 (June), its spring
  cmp         month_r, 3 //Comparing the month to 3
  b.eq        wOrSp  //If less than 6 (June), its spring
  cmp         month_r, 4 //Comparing the month to 4
  b.eq        isSpring  //If less than 6 (June), its spring
  cmp         month_r, 5 //Comparing the month to 5
  b.eq        isSpring  //If less than 6 (June), its spring
  cmp         month_r, 6 //Comparing the month to 6
  b.eq        spOrS  //If less than 6 (June), its spring
  cmp         month_r, 7 //Comparing the month to 7
  b.eq        isSummer  //If less than 6 (June), its spring
  cmp         month_r, 8 //Comparing the month to 8
  b.eq        isSummer  //If less than 6 (June), its spring
  cmp         month_r, 9 //Comparing the month to 9
  b.eq        sOrF  //If less than 6 (June), its spring
  cmp         month_r, 10 //Comparing the month to 10
  b.eq        isFall  //If less than 6 (June), its spring
  cmp         month_r, 11 //Comparing the month to 11
  b.eq        isFall  //If less than 6 (June), its spring
  cmp         month_r, 12 //Comparing the month to 12
  b.eq        fOrW  //If less than 6 (June), its spring

wOrSp:
  cmp         day_r, 21
  b.lt        isWinter
  b           isSpring

spOrS:
  cmp         day_r, 21
  b.lt        isSpring
  b           isSummer

sOrF:
  cmp         day_r, 21
  b.lt        isSummer
  b           isFall

fOrW:
  cmp         day_r, 21
  b.lt        isFall
  b           isWinter


isWinter:
  mov         w9, 1
  ldr         x3, [x25, w9, SXTW 3] //Loading season[0] (winter)
  bl          printf //Branch link to printf
  b           done //Branch to done

isSpring:
  mov         w9, 2
  ldr         x3, [x25, w9, SXTW 3] //Loading season[1] (spring)
  bl          printf //Branch link to printf
  b           done //Branch to done

isSummer:
  mov         w9, 3
  ldr         x3, [x25, w9, SXTW 3] //Loading season[2] (summer)
  bl          printf //Branch link to printf
  b           done //Branch to done

isFall:
  mov         w9, 4
  ldr         x3, [x25, w9, SXTW 3] //Loading season[3] (fall)
  bl          printf //Branch link to printf
  b           done //Branch to done

done:
      ldp         x29, x30, [sp], 16 //Restoring fp and lr from stack
      ret //Returning to caller
