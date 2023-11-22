################# Informations #####################
# Title: Interactive Monthly Calendar Application		
# Author: Tariq Odeh - 1190699 | Wasim Atta - 1200920
# Date: 1 December, 2023
# Description: MIPS code for viewing, editing, and managing appointments within a monthly calendar. The application provide a user-friendly interface to interact with the calendar functionality, allowing them to add, edit, and view appointments for specific dates.
# Filename: P1-Interactive_Monthly_Calendar_Application-1190699_1200920
# Input: calendar-input.txt
# Output: calendar-output.txts


################# Data segment #####################
.data
    #file_path:    		.asciiz "C:\\Users\\tariq\\OneDrive\\Desktop\\P1-Arch\\calendar-input.txt" 	# The path of input file 
    file_path:    		.asciiz "C:\\Users\\wasim\\Desktop\\calendar-input.txt" 	# The path of input file 
    menu:  	  		.asciiz "*-----------------------------*\n*           Main Menu          *\n*-----------------------------*\n[1]--> View the calendar\n[2]--> View Statistics\n[3]--> Add a new appointment\n[4]--> Delete an appointment\n[0]--> Exit\nEnter your choice: "
    view_menu:    		.asciiz "\n*-----------------------------*\n*          View Menu          *\n*-----------------------------*\n[1]--> View per day\n[2]--> View per set of days\n[3]--> View given slot in a given day\n[0]--> Back\nEnter your choice: "
    view_per_day_str:  		.asciiz "\nEnter the day (1-31): "
    view_per_set_days_str: 	.asciiz "\nEnter a comma-separated list of integers: "
    invalid_day_str:   		.asciiz "\nInvalid day input. Please enter a day between 1 and 31.\n"
    newline: 			.asciiz "\n"
    char_L:       		.asciiz "L"
    char_M:       		.asciiz "M"
    char_O:       		.asciiz "O"
    space:       		.asciiz "   "
    number_of_L:		.asciiz "Number of lectures (in hours): "
    number_of_OH:		.asciiz "number of OH (in hours): "
    number_of_M	:		.asciiz "Number of Meetings (in hours): "
    The_average:		.asciiz "The average lectures per day: "
    The_ratio:		        .asciiz "The ratio between total number of hours reserved for L and the OH: "

    
    
    input_string: 		.space 91      		# Maximum length of the input string (we calculated it) 
    calendar_mem: 		.space 2790     	# Memory space to store the calendar (we calculated it 31 × 10 × 9)
    END: 			.asciiz "E"
        
################# Code segment #####################
.text
main:

    li $v0, 13       			# Open file - syscall 13
    la $a0, file_path			# Load address of file_path into $a0
    li $a1, 0        			# Read only mode
    syscall		 		# System call
    move $t0, $v0   	 		# Save file handle

    la $a1, calendar_mem 		# Load address of calendar_mem into register $a1
    li $v0, 14        			# Read file - syscall 14
    move $a0, $t0     			# File handle
    la $a2, 2790      			# Maximum number of bytes to read
    syscall				# System call

    li $v0, 16        			# Close file - syscall 16
    move $a0, $t0     			# File handle
    syscall				# System call

    li $v0, 4          			# Print string - syscall 4
    la $a0, menu     			# Load the menu
    syscall				# System call

    li $v0, 5          			# Read integer - syscall 5
    syscall				# System call
    move $t2, $v0     			# Save the user input

    beq $t2, 1, view_calendar 		# Check the user input, if it 1 that mean view_calendar
    beq $t2, 2, view_statistics		# Check the user input, if it 2 that mean view_statistics
    beq $t2, 3, add_appointment		# Check the user input, if it 3 that mean add_appointment
    beq $t2, 4, delete_appointment	# Check the user input, if it 4 that mean delete_appointment
    beq $t2, 0, exit_program		# Check the user input, if it 0 that mean exit_program
    j main 				# Check the user input, if it invalid that mean jump back to the menu

# -------------------------------------------------

view_calendar:
    li $v0, 4           		# Print string - syscall 4
    la $a0, view_menu   		# Load the view_menu
    syscall             		# System call

    li $v0, 5           		# Read integer - syscall 5
    syscall             		# System call
    move $t3, $v0       		# Save the user input

    beq $t3, 1, view_per_day            # Check the user input, if it's 1, that means view_per_day
    beq $t3, 2, view_per_set_of_days    # Check the user input, if it's 2, that means view_per_set_of_days
    beq $t3, 3, view_given_slot_in_day  # Check the user input, if it's 3, that means view_given_slot_in_day
    beq $t3, 0, back                    # Check the user input, if it's 0, that means back

# ++++++++++++++++

    view_per_day:    	
        li $v0, 4           		# Print string - syscall 4
    	la $a0, view_per_day_str	# Load address of view_per_day_str into $a0
    	syscall             		# System call

    	li $v0, 5          		# Read integer - syscall 5
    	syscall            		# System call
    	move $t9, $v0       		# Save the user input
    	
    	p_indiv_day:
    	la $t3, calendar_mem 		# Load address of calendar_mem into register $t3
    	li $t5, 0           		# Initialize newline counter
    	
  	beq $t9, 1, skip_1		# Check if the input is first day
    	subi $t7, $t9, 2    		# subtract 2 from user input to track the day want to print
  	
  	skip_1:				# In case the inpt is first day
  	bne  $t9, 1, skip_2		# Check if the input is not hte first day
	j print_first_line_loop		# Print fist day
  			
  	skip_2:      			# In case not hte first day
    	blt $t9, 1, invalid_day 	# Validate the day input (1-31)
    	bgt $t9, 31, invalid_day	# Validate the day input (1-31)
    	
    	calendar_loop:        		# Loop to count newlines
        lb $t6, 0($t3)     		# Load a byte from the calendar
        beq $t6, 10, inc_lines  	# Check if the current character is a newline
        j continue_loop   		# Continue the loop

    	inc_lines:
        beq $t5, $t7, print_day 	# Check if reached the day want to print
        addi $t5, $t5, 1  		# Increment the newline counter
        j continue_loop   		# Continue the loop

	continue_loop:
        addi $t3, $t3, 1  		# Move to the next position in memory
        j calendar_loop   		# Continue the loop

        print_day:
        addi $t3, $t3, 1  		# Move to the next position in memory
        lb $t6, 0($t3)    		# Load a byte from the calendar
        beq $t6, 10, reset 		# Check if the current character is a newline

        li $v0, 11        		# Print character - syscall 11
        move $a0, $t6	 		# Move the character to $a0
    	syscall             		# System call
        j print_day			# Continue the loop

    	invalid_day:
        li $v0, 4           		# Print string - syscall 4
        la $a0, invalid_day_str 	# Print invalid day string
        syscall            		# System call
        	
        j reset				# Back to the calendar view	
        
        print_first_line_loop:
        lb $t6, 0($t3)           	# Load a byte from the calendar
        beq $t6, 10, done_first_line  	# Check if the current character is a newline
        li $v0, 11                	# Print character - syscall 11
        move $a0, $t6             	# Move the character to $a0
        syscall                   	# System call
        addi $t3, $t3, 1          	# Move to the next position in memory
        j print_first_line_loop   	# Continue the loop

    	done_first_line:
    	j reset				# Back to the calendar view
 
# ++++++++++++++++

    view_per_set_of_days:
        li $v0, 4           		# Print string - syscall 4
    	la $a0, view_per_set_days_str	# Load address of input_prompt into $a0
    	syscall             		# System call
    	
        li $v0, 8           		# Read string - syscall 8
        la $a0, input_string		# Load address of input_string into $a0
        li $a1, 91  			# Maximum length of the input string
        syscall             		# System call

        li $t0, 0          		# Counter for indexing the string)
        li $t9, 0          		# Temporary register to 0

    	extract_loop:
        lb $t2, input_string($t0)   	# Load the current character from the string
        beqz $t2, end_extract		# Check if the character is null (end of string)
        li $t1, 48          		# ASCII code for '0'
        li $t4, 57          		# ASCII code for '9'
        li $t8, 44          		# ASCII code for ','
        blt $t2, $t1, p_day		# Check if it in range
        bgt $t2, $t4, p_day		# Check if it in range
        sub $t2, $t2, $t1   		# Convert ASCII to integer
        mul $t9, $t9, 10    		# Multiply previous result by 10
        add $t9, $t9, $t2   		# Add the digit to the result
        j continue_extract		# Continue extracting

        p_day:
        li $v0, 4             		# Print string - syscall 4
        la $a0, newline     		# Load the newline character
        syscall             		# System call
        j p_indiv_day     		# Go to p_indiv_day in view_per_day to print the day
	
	reset:
        li $t9, 0          		# Reset the temporary register for the next integer

    	continue_extract:
        addi $t0, $t0, 1         	# Increment the counter
        j extract_loop        		# Continue the loop

    	end_extract:		
    	j view_calendar			# Back to the calendar view
        
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    view_given_slot_in_day:
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    j view_calendar
    
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    back:
    j main
#------------------

#  -------------------------------------------------

view_statistics:
    # Code to view statistics goes here
	la $t3, calendar_mem 		# Load address of calendar_mem into register $t2

	li $s0, 0                      #counter for L in H
	li $s1, 0			#counter for OH in H
	li $s2, 0			#counter for M in H
	
	  Statistics_loop:
        lb $t6, 0($t3)           	# Load a byte from the calendar
        lb $t0, char_L  		
        beq $t6, $t0,L_inc		# check if the char = "L" 
        lb $t0, char_O
        beq $t6, $t0,OH_inc		# check if the char = "O" 
        lb $t0, char_M
        beq $t6, $t0,M_inc		# check if the char = "M" 
        lb $t0, END
        beq $t6, $t0,END_COUNT		#check if calender is end
        continue:
        addi $t3, $t3, 1          	# Move to the next position in memory
        j Statistics_loop   	# Continue the loop



	  L_inc:
        move $a0,$t3			#take copy of addrees of calender  to function
	jal my_function			#call the function to find sum of hours
	add $s0 , $s0 , $v0 		# add the hours for the counter 
	j continue 			# back to the loop 
	
	   OH_inc:
	move $a0,$t3			#take copy of addrees of calender  to function
	jal my_function			#call the function to find sum of hours
	add $s1 , $s1, $v0 		# add the hours for the counter 
	j continue			# back to the loop 
	
          M_inc:
	 move $a0,$t3			#take copy of addrees of calender  to function
	jal my_function			#call the function to find sum of hours
	add $s2 , $s2, $v0 		# add the hours for the counter 
	j continue			# back to the loop 


           END_COUNT:
	
	 li $v0, 4          			
   	 la $a0, number_of_L        # load the text 		
   	 syscall				
   	 li $v0,1  		    # print int
	 move $a0, $s0 	            # load number of H  
	 syscall	
	 li $v0, 4          			
   	 la $a0,newline   	    # add new line  		
   	 syscall
   	
	 li $v0, 4          			
   	 la $a0, number_of_OH        # load the text 		
   	 syscall				
   	 li $v0,1  		    # print int
	 move $a0, $s1 	            # load number of H  
	 syscall	
	 li $v0, 4          			
   	 la $a0,newline   	    # add new line  		
   	 syscall
   	 
   	  li $v0, 4          			
   	 la $a0, number_of_M        # load the text 		
   	 syscall				
   	 li $v0,1  		    # print int
	 move $a0, $s2 	            # load number of H  
	 syscall	
	 li $v0, 4          			
   	 la $a0,newline   	    # add new line  		
   	 syscall
	
   	# li $s4 ,0                  # s4 to save the avarege
	 li $s5 ,0                  # s4 to save the ratio
	 
	 #add $s4,$s4,$s0
	 #add $s4,$s4,$s1
	 #add $s4,$s4,$s2
	 li $t1,31
	 
    	mtc1 $s0, $f0  
    	cvt.s.w $f0, $f0 	    	# Convert the integer to a float in $f0                        	
    	mtc1 $t1, $f1 
    	cvt.s.w $f1, $f1	    	# Convert the integer to a float in $f1                       
    	div.s $f12, $f0, $f1  
    	
 	 li $v0, 4          			
   	 la $a0, The_average       # load the text 		
   	 syscall				
   	  li $v0, 2 
	 syscall	
	 li $v0, 4          			
   	 la $a0,newline   	    # add new line  		
   	 syscall


    	mtc1 $s0, $f0  
    	cvt.s.w $f0, $f0 	    	# Convert the integer to a float in $f0                        	
    	mtc1 $s1, $f1 
    	cvt.s.w $f1, $f1	    	# Convert the integer to a float in $f1                      
    	div.s $f12, $f0, $f1  
    	
 	 li $v0, 4          			
   	 la $a0, The_ratio      # load the text 		
   	 syscall				
   	  li $v0, 2 
	 syscall	
	 li $v0, 4          			
   	 la $a0,newline   	    # add new line  		
   	 syscall














    # Jump back to the menu
    j main
    
    
    
    
    
    my_function:
	move $t2,$a0			#take copy of addrees of calender 
	subi $t2, $t2, 3         	# Move to the previce position in memory
	lb $t5 , 0($t2)			#load char from calender
	li $t7, 0x0000002d		#load "-" to $t7 
	beq $t5,$t7 next		#check if char from calender = "-"
	lb $t9,0($t2)			#load the second number in $t9
	sub $t9, $t9, 48         	# Convert ASCII to decimal
	addi $t2,$t2 ,1			# Move to the next position in memory to load the second digit
	lb $t4,0($t2)			#load second digit
	sub $t4, $t4, 48         	# Convert ASCII to decimal

	mul $t9 ,$t9 ,10		#this mul to put the both digit in one register
	add $t9 ,$t9 , $t4
	 
	subi $t2, $t2, 2		# Move to the previce position in memory
	j second_number                # first number end go to the second
	next:
	addi $t2, $t2, 1     		# Move to the next position in memory
	lb $t9,0($t2)			#load the number from calender 
	sub $t9, $t9, 48         	# Convert ASCII to decimal
	subi $t2, $t2, 1         	# Move to the previce position in memory
	
	second_number:                  # same of above but for second number 
	subi $t2, $t2, 2         	# Move to the next position in memory
	li $t7 ,0x00000020
	lb $t5 , 0($t2)
	beq $t5,$t7 next_2
	lb $t8,0($t2)
	sub $t8, $t8, 48         # Convert ASCII to decimal
	addi $t2,$t2 ,1
	lb $t4,0($t2)
	sub $t4, $t4, 48         # Convert ASCII to decimal
	mul $t8 ,$t8 ,10
	add $t8 ,$t8 , $t4
	addi $t2,$t2,1
	j next_3
	next_2:
	addi $t2,$t2,1
	lb $t8,0($t2)
	sub $t8, $t8, 48         # Convert ASCII to decimal

	
 	next_3:
	li $t2 , 6  		#load 6 to $t2 to check if any number from 1 to 5 
	blt $t8,$t2 Add1       # check if the first number 1-5 then add 12 
	
	j else_1               # if not go to else 
	Add1:
	addi $t8,$t8,12 	# add 12 to the number
	
	else_1:
	blt $t9,$t2 Add2       # check the scecond number
	
	j else_2		# if not go to else_2
	Add2:
	addi $t9,$t9,12        # add 12 to the number
	
	else_2: 		# not the number is ready 
	sub $v0,$t9,$t8		# find the long of L buy sub
	jr $ra

#  -------------------------------------------------

add_appointment:

      j main

#  -------------------------------------------------

delete_appointment:
    # Code to delete an appointment goes here

    # Jump back to the menu
    j main

#  -------------------------------------------------

exit_program:
    # Exit program
    li $v0, 10        # System call code for program exit (syscall 10)
    syscall
