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
    file_path:    		.asciiz "C:\\Users\\tariq\\OneDrive\\Desktop\\P1-Arch\\calendar-input.txt" 	# The path of input file 
    #file_path:    		.asciiz "C:\\Users\\wasim\\Desktop\\calendar-input.txt" 	# The path of input file 
    menu:  	  		.asciiz "*--------------------------------*\n*            {Main Menu}         *\n*--------------------------------*\n*  [1]--> View the calendar      *\n*  [2]--> View Statistics        *\n*  [3]--> Add a new appointment  *\n*  [4]--> Delete an appointment  *\n*  [0]--> Exit                   *\n*--------------------------------*\nEnter your choice: "
    view_menu:  	  	.asciiz "\n\n*-------------------------------------*\n*             {View Menu}             *\n*-------------------------------------*\n*   [1]--> Per day                    *\n*   [2]--> Per set of days            *\n*   [3]--> Given slot in a given day  *\n*   [0]--> Back                       *\n*-------------------------------------*\nEnter your choice: "
    view_per_day_str:  		.asciiz "\nEnter the day in range(1-31): "
    view_per_set_days_str: 	.asciiz "\nEnter a comma-separated list of integers (1,2,3,...): "
    invalid_day_str:   		.asciiz "\nInvalid day input. Please enter a day between 1 and 31.\n"
    newline: 			.asciiz "\n"
    char_L:       		.asciiz "L"
    char_M:       		.asciiz "M"
    char_O:       		.asciiz "O"
    space:       		.asciiz "   "
    number_of_L:		.asciiz "\nNumber of lectures (in hours): "
    number_of_OH:		.asciiz "\nnumber of OH (in hours): "
    number_of_M	:		.asciiz "\nNumber of Meetings (in hours): "
    The_average:		.asciiz "\nThe average lectures per day: "
    The_ratio:		        .asciiz "\nThe ratio between total number of hours reserved for L and the OH: "
    slot_start: 		.asciiz "\nEnter the slot start: "
    slot_end: 			.asciiz "\nEnter the slot end: "
    wrong_input: 		.asciiz "\nInvalid time input. Please enter a time between 8AM and 5PM. "
    
    day_buffer:        		.space 100         	# Buffer to store the day as a string
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
        
# ++++++++++++++++

    view_given_slot_in_day:
    	jal give_day			# Call give_day to store the day that want to search in
    	jal read_slot			# Call read_slot to read the slot time
    	
    	li $t9, 0          		# Reset the temporary register for the next integer	
    	li $t7, 1  			# Flag for start/end appointment who want to check
    	li $t8, 0			# Flag for start/end appointment
    	li $t5, 1			# Flag to make the output have good view
    	la $s0, day_buffer  		# Pointer to the day buffer

        li $v0, 11      		# Set the system call code for printing a character
	li $a0, '|'     		# Load the '|' to print
	syscall             		# System call
	
    	search_loop:			# Search for the start of an appointment 
    	lb $t2, 0($s0)	 		# Load a character from the input buffer
    	beqz $t2, view_calendar 	# Check if we've reached the end of the string
    	beq $t2, ':', check_start_time  # Check for the start of an appointment
        addi $s0, $s0, 1  		# Continue to the next character
        j search_loop			# Continue the loop

    	check_start_time: 		# Reach the start of an appointment 
        addi $s0, $s0, 1 		# Move to the next character (skip the space)

   	extract:			# Extract the numbers from string
        lb $t2, 0($s0)	 		# Load a character from the input buffer
        beqz $t2, view_calendar		# Check if the character is null (end of string)
        li $t1, 48          		# ASCII code for '0'
        li $t4, 57          		# ASCII code for '9'
        blt $t2, $t1, pr_day		# Check if it in range
        bgt $t2, $t4, pr_day		# Check if it in range
        sub $t2, $t2, $t1   		# Convert ASCII to integer
        mul $t9, $t9, 10    		# Multiply previous result by 10
        add $t9, $t9, $t2   		# Add the digit to the result
        j continue_ext			# Continue extracting

        pr_day:				# Check the number and make it in formula
       	beq $t9, $zero, continue_ext	# Check if it number
	beq $t9, 1, add_12        	# Add 12 if the number is 1 to make the time in 24-formula	
	beq $t9, 2, add_12        	# Add 12 if the number is 2 to make the time in 24-formula
	beq $t9, 3, add_12        	# Add 12 if the number is 3 to make the time in 24-formula
	beq $t9, 4, add_12        	# Add 12 if the number is 4 to make the time in 24-formula
	beq $t9, 5, add_12        	# Add 12 if the number is 5 to make the time in 24-formula
	
	after_add12:
	beq $t7, 0, inv0_1		# Check the flag to know start/end appointment
	beq $t7, 1, inv1_0		# Check the flag to know start/end appointment
	
	bac_inv:
	beq $t8, $zero, greater		# Check the start of appointment
	j less				# Check the end of appointment
	
	inv1_0:				# Change the flag to know start/end appointment
	li $t7, 0			# inverter the start/end appointment flag
	j bac_inv
	
	inv0_1:				# Change the flag to know start/end appointment
	li $t7, 1			# inverter the start/end appointment flag
	j bac_inv
	
	greater:
       	bge $t9, $t0, gte_start		# Check if the number is larger than or equal than start slot
       	li $t9, 0 			# Reset the temporary register for the next integer	         		
	j continue_ext			# Skip this round
	
	less:
       	ble $t9, $t6, gte_end		# Check if the number is less than or equal than end slot
       	bne $t7, $zero, p_end		# Check start/end appointment
	j view_calendar			# Done worke - go back to the vire menu
	
	p_end:		
	li $v0, 1			# Set the system call code for printing a integer
       	move $a0, $t6			# Set the end of slot in $a0
    	syscall				# System call
        j good_p        		# Continue the loop
	
	continue_ext:
        addi $s0, $s0, 1         	# Increment the counter
        j extract        		# Continue the loop
       	
       	add_12:
	addi $t9, $t9, 12		# Add 12 to make the time in 24-formula
	j after_add12			# Go back to continue work
       	
       	gte_start:
       	beq $t7, $zero, is_zero		# Check start/end appointment
	li $t9, 0          		# Reset the temporary register for the next integer
        j continue_ext        
       	
       	is_zero:			
       	li $v0, 1			# Set the system call code for printing a integer
       	move $a0, $t0			# Set the start of slot in $a0
    	syscall				# System call
	li $t9, 0          		# Reset the temporary register for the next integer
	li $t8,1			# Set flag for start/end appointment to be end appointment
	li $v0, 11      		# Set the system call code for printing a character
	li $a0, '-'     		# Load the ASCII value of the character to print
	syscall				# System call
        j continue_ext       		# Continue the loop
       	
       	gte_end:
       	li $v0, 1			# Set the system call code for printing a integer
       	move $a0, $t9			# Set the integer that checked in $a0
    	syscall				# System call
    	li $t9, 0          		# Reset the temporary register for the next integer
    	beq $t5, 1, good_p		# To separate appointments
    	li $v0, 11      		# Set the system call code for printing a character
	li $a0, '-'     		# Load the ASCII value of the character to print
	syscall				# System call
    	
    	end_good_p:	
       	beq $t5, 0, to_1		# inverter the flag
	beq $t5, 1, to_0		# inverter the flag
        j continue_ext       		# Continue the loop
       	
       	good_p:	
	lb $t3, 1($s0)			# Load the types of an appointments
	li $v0, 11      		# Set the system call code for printing a character
	move $a0, $t3     		# Load the ASCII value of the character to print
	syscall				# System call
    	beq $t3, 'O', print_next_char 	# If the char O than go to print H
	j delo

	print_next_char:		# Print char H after print H
    	lb $t3, 2($s0)			# Load the H char
    	li $v0, 11      		# Set the system call code for printing a character
    	move $a0, $t3     		# Load the ASCII value of the character to print
    	syscall				# System call
	j delo
       	
       	delo:
       	li $v0, 11      		# Set the system call code for printing a character
	li $a0, '|'     		# Load the ASCII value of the character to print
	syscall				# System call
       	j end_good_p			# Go to make the output good view
       	
	to_0:
	li $t5, 0			# inverter the start/end appointment flag
	j continue_ext			# Go back to continue work
	
	to_1:
	li $t5, 1			# inverter the start/end appointment flag
	j continue_ext			# Go back to continue work
    
    	j view_calendar			# Go back to the view menu
    
# ++++++++++++++++

    back: 				# Go bake to the main manu
    j main				# Jump to the amin

#  -------------------------------------------------

view_statistics:

	la $t3, calendar_mem 		# Load address of calendar_mem into register $t2
	li $s0, 0                      	# Counter for L in H
	li $s1, 0			# Counter for OH in H
	li $s2, 0			# Counter for M in H
	
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
        j Statistics_loop   		# Continue the loop



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
   	 la $a0, number_of_L        	# load the text 		
   	 syscall				
   	 li $v0,1  		    	# print int
	 move $a0, $s0 	            	# load number of H  
	 syscall	
	 li $v0, 4          			
   	 la $a0,newline   	    	# add new line  		
   	 syscall
   	
	 li $v0, 4          			
   	 la $a0, number_of_OH        	# load the text 		
   	 syscall				
   	 li $v0,1  		    	# print int
	 move $a0, $s1 	            	# load number of H  
	 syscall	
	 li $v0, 4          			
   	 la $a0,newline   	    	# add new line  		
   	 syscall
   	 
   	  li $v0, 4          			
   	 la $a0, number_of_M        	# load the text 		
   	 syscall				
   	 li $v0,1  		    	# print int
	 move $a0, $s2 	            	# load number of H  
	 syscall	
	 li $v0, 4          			
   	 la $a0,newline   	    	# add new line  		
   	 syscall
	
   	# li $s4 ,0                  	# s4 to save the avarege
	 li $s5 ,0                  	# s4 to save the ratio
	 
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
   	 la $a0, The_average       	# load the text 		
   	 syscall				
   	  li $v0, 2 
	 syscall	
	 li $v0, 4          			
   	 la $a0,newline   	    	# add new line  		
   	 syscall


    	mtc1 $s0, $f0  
    	cvt.s.w $f0, $f0 	    	# Convert the integer to a float in $f0                        	
    	mtc1 $s1, $f1 
    	cvt.s.w $f1, $f1	    	# Convert the integer to a float in $f1                      
    	div.s $f12, $f0, $f1  
    	
 	 li $v0, 4          			
   	 la $a0, The_ratio      	# load the text 		
   	 syscall				
   	  li $v0, 2 
	 syscall	
	 li $v0, 4          			
   	 la $a0,newline   	    	# add new line  		
   	 syscall
   	 

    j main     				# Jump back to the menu
#  -------------------------------------------------    
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
	j second_number                	# first number end go to the second
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






    j main    		# Jump back to the menu

#  -------------------------------------------------

give_day:
    li $v0, 4           		# Print string - syscall 4
    la $a0, view_per_day_str		# Load address of view_per_day_str into $a0
    syscall             		# System call

    li $v0, 5          			# Read integer - syscall 5
    syscall            			# System call
    move $t9, $v0       		# Save the user input
    	
    la $t3, calendar_mem 		# Load address of calendar_mem into register $t3
    li $t5, 0           		# Initialize newline counter
    	
    beq $t9, 1, skip1			# Check if the input is first day
    subi $t7, $t9, 2    		# subtract 2 from user input to track the day want to print
  	
    skip1:				# In case the inpt is first day
    bne  $t9, 1, skip2			# Check if the input is not the first day
    j take_first_line			# Print fist day
  			
    skip2:      			# In case not hte first day
    blt $t9, 1, invalid_day 		# Validate the day input (1-31)
    bgt $t9, 31, invalid_day		# Validate the day input (1-31)
    	
    cale_loop:        			# Loop to count newlines
    lb $t6, 0($t3)     			# Load a byte from the calendar
    beq $t6, 10, add_lines  		# Check if the current character is a newline
    j con_loop   			# Continue the loop

    add_lines:
    beq $t5, $t7, print_day 		# Check if reached the day want to print
    addi $t5, $t5, 1  			# Increment the newline counter
    j con_loop   			# Continue the loop

    con_loop:
    addi $t3, $t3, 1  			# Move to the next position in memory
    j cale_loop   			# Continue the loop

    take_day:
    addi $t3, $t3, 1  			# Move to the next position in memory
    lb $t6, 0($t3)    			# Load a byte from the calendar
    beq $t6, 10, done_take 		# Check if the current character is a newline
    sb $t6, day_buffer($t8) 		# Store the character in the buffer
    addi $t8, $t8, 1           		# Increment the buffer index
    j take_day				# Continue the loop
        
    take_first_line:
    lb $t6, 0($t3)           		# Load a byte from the calendar
    sb $t6, day_buffer($t8) 		# Store the character in the buffer
    beq $t6, 10, done_take  		# Check if the current character is a newline
    addi $t3, $t3, 1  			# Move to the next position in memory
    addi $t8, $t8, 1           		# Increment the buffer index
    j take_first_line    		# Continue the loop
        
    done_take:
    jr $ra				# Return
    				
#  -------------------------------------------------

read_slot:
    li $v0, 4           		# Print string - syscall 4
    la $a0,  slot_start			# Load address of view_per_day_str into $a0
    syscall             		# System call

    li $v0, 5          			# Read integer - syscall 5
    syscall            			# System call
    move $t0, $v0       		# Save the user input
    
    li $v0, 4           		# Print string - syscall 4
    la $a0,  slot_end			# Load address of view_per_day_str into $a0
    syscall             		# System call

    li $v0, 5          			# Read integer - syscall 5
    syscall            			# System call
    move $t6, $v0       		# Save the user input
    
    bge $t0, 1, cehck_f5		# Check if the first input larger or equal than 1 to deal with slot range
    j wrong 				# The input is wrong
    
    cehck_f5:		
    ble $t0, 5, add12_s			# Check if the first input smaler or equal 5 to deal with slot range      
    
    again_here:
    bge $t6, 1, cehck_e5		# Check if the second input larger or equal than 1 to deal with slot range   
    j wrong 				# The input is wrong
    
    cehck_e5:
    ble $t6, 5, add12_e 		# Check if the second input smaler or equal 5 to deal with slot range  
    j last  				# Go to the last check
    
    add12_s:				# Add 12 to the time in range [1,5] to deal with slots
    addi $t0, $t0, 15
    j again_here  			# Go to check the second number
     
    add12_e:				# Add 12 to the time in range [1,5] to deal with slots
    addi $t6, $t0, 15
    j last  				# Go to the last check
    
    last:	  			# Last check
    bge $t0, $t6, wrong			# Check if the start slot larger than end slot 
    
    jr $ra				# Return
    
    wrong: 				# The input is wrong
    li $v0, 4           		# Print string - syscall 4
    la $a0, wrong_input			# Load address of wrong_input into $a0
    syscall             		# System call
    j view_calendar			# Back to the view menu
    			
#  -------------------------------------------------

exit_program:     			# Exit program
    li $v0, 10        			# Program exit - syscall 10
    syscall           			# System call
    
#  -------------------------------------------------
