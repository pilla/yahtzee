#!/bin/bash
# Yahtzee game
# Mauricio Pilla <mauricio.pilla@gmail.com>
# 

#    One, Two, Three, Four, Five, Six, Bonus, 3-of-a-kind, 4-of-a-kind, full-house, low-straight,
#     high-straight, yahtzee
CARD=(0   0     0     0     0     0    0      0            0            0           0\
      0              0)
USED=(0   0     0     0     0     0    0      0            0            0           0\
      0              0)
MULT=(0   0     0     0     0     0    35     0            0            25         30\
	  40            50)

DICE=(0 0 0 0 0)

PATIENCE=0

THRESHOLD=5


function print_card {
	printf "\n"
	printf "Yahtzee\n"
	printf " \t\t\t VALUE \t USED \n" 
	printf " 1 Aces \t\t %s \t %s \t %s\n" "${CARD[0]}" "${USED[0]}"
	printf " 2 Twos \t\t %s \t %s\n" "${CARD[1]}" "${USED[1]}"
	printf " 3 Threes \t\t %s \t %s\n" "${CARD[2]}" "${USED[2]}"
	printf " 4 Fours \t\t %s \t %s\n" "${CARD[3]}" "${USED[3]}"
	printf " 5 Fives \t\t %s \t %s\n" "${CARD[4]}" "${USED[4]}"
	printf " 6 Sixes \t\t %s \t %s\n" "${CARD[5]}" "${USED[5]}"
	printf "   Bonus \t\t %s\n" "${CARD[6]}"
	printf " 8 3-of-a-kind \t\t %s \t %s\n" "${CARD[7]}" "${USED[7]}"
	printf " 9 4-of-a-kind \t\t %s \t %s\n" "${CARD[8]}" "${USED[8]}"
	printf " 10 Full house \t\t %s \t %s\n" "${CARD[9]}" "${USED[9]}"
	printf "11 Low straight \t %s \t %s\n" "${CARD[10]}" "${USED[10]}"
	printf "12 High straight \t %s \t %s\n" "${CARD[11]}" "${USED[11]}"
	printf "13 Yahtzee \t\t %s \t %s\n" "${CARD[12]}" "${USED[12]}"
	sum_card
	printf -- "-----------------------------------\n"
	printf "TOTAL \t\t\t %s\n" "$SUM"
	printf "\n"
}

function sum_card {
	SUM=0
	for ((i=0; i<13; i++)); do
		SUM=$(($SUM + ${CARD[i]}))
	done
}

function reset_card {
	for ((i=0; i<13; i++)); do
		${CARD[i]} = 0
		${USED[i]} = 0
	done
}

function reset_dice {
	for ((i=0; i<6; i++)); do
		${DICE[i]} = 0
	done
}

function clear_dice {
	for ((i=0; i<5; i++)); do
		DICE[i]=0
	done
}

function throw_dice {
	echo "throwing"
	for ((i=0; i<5; i++)); do
		if (( ${DICE[i]} == 0 ))
		then 
			DICE[i]=$(( $RANDOM % 6 + 1))
		fi
	done
}

function print_dice {
	for ((i=0; i<5; i++)); do
		printf "%s\t" "${DICE[i]}"
	done	
	printf "\n"
}

function choose_dice {
	printf "Which dice do you want to throw again?\n"
	printf " (1, 2, 3, 4, or 5) \n"
	printf " 0 ends selection\n"
	read 
		while (( $REPLY != 0 )) 
		do
			if (( $REPLY >= 1 && $REPLY < 6))
			then
				REPLY=$(( $REPLY - 1))
				DICE[$REPLY]=0
			fi
			read
		done
}

function test_for_end {
	END=1
	for (( i=0; i<13; i++ )); do
		# Never mind the bonus
		if (( ${USED[$i]} == 0 && i != 6)) 
		then 
			END=0
			i=14
		fi
	done
}

function test_for_bonus {
	local TOTAL=0
	for (( i=0; i<7 ; i++ )); do
		TOTAL=$(( $TOTAL  + ${DICE[$i]} ))
	done
	if (( $TOTAL > 62 )) 
	then 
		printf "Bonus! \n"
		CARD[6]=35
	fi
}

function test_for {
	local MANY=$(($1))
	YAY=0
	local COUNT_DICE=(0 0 0 0 0 0)
	
	for (( i = 0; i<5; i++ )); do
		local NOW=$(( ${DICE[$i]} - 1 ))
		COUNT_DICE[$NOW]=$(( ${COUNT_DICE[$NOW]} + 1 ))
	done

	for (( i = 0; i<6; i++ )); do
		if (( ${COUNT_DICE[$i]} >= $MANY ))
		then 
			YAY=1
			SUM=$(( i * $MANY ))
		fi
	done
}


function test_full_house {
	YAY=0
	local OK2=0
	local OK3=0
	local COUNT_DICE=(0 0 0 0 0 0)
	for (( i = 0; i<5; i++ )); do
		local NOW=$(( ${DICE[$i]} - 1 ))
		COUNT_DICE[$NOW]=$(( ${COUNT_DICE[$NOW]} + 1 ))
	done

	for (( i = 0; i<6; i++ )); do
		if (( ${COUNT_DICE[$i]} == 2))
		then 
			OK2=1
		elif (( ${COUNT_DICE[$i]} == 3))
		then
			OK3=1
		fi
	done

	if (( $OK2 == 1 && $OK3 == 1))
	then
		YAY=1
	fi

	echo "YAY" $YAY
}

function test_for_sequency {
	YAY=0
	HIGH=0
	local COUNT_DICE=(0 0 0 0 0 0)
	local SEQ=0	
	for (( i = 0; i<5; i++ )); do
		local NOW=$(( ${DICE[$i]} - 1 ))
		COUNT_DICE[$NOW]=$(( ${COUNT_DICE[$NOW]} + 1 ))
	done
	local PREV=0
	for (( i = 0; i<6; i++ )); do
		if (( ${COUNT_DICE[i]} == 1))
		then 
			if (( $SEQ > 0 && $PREV !=1 ))
			then 
				SEQ=-6
			else
				SEQ=$(($SEQ + 1))
				PREV=1
			fi
		fi
	done
	if (( $SEQ == 5))
	then
		YAY=1
		if (( ${COUNT_DICE[5]} == 1 ))
		then
			HIGH=1
		fi
	fi

}



function select_in_card {
	printf "Select a unused entry in the card: \n\n"
	print_card
	printf "\n"
	local DONE=0
	while (( DONE == 0)); do
		read
		while [[ ! $REPLY =~ ^[0-9]+$ ]]; do
			printf "Invalid answer. Please pick a valid entry.\n"
			read
		done
		if (( $REPLY < 1 || $REPLY > 13 || $REPLY == 7 )) 
		then 
			printf "Invalid answer. Please pick a valid entry.\n"
			PATIENCE=$(( $PATIENCE + 1 ))
		elif (( ${USED[$REPLY-1]} == 1 ))
		then 
			printf "Entry was used. Please pick another choice.\n"
			PATIENCE=$(( $PATIENCE + 1 ))
		else
			DONE=1
		fi

		if (( $DONE == 0 && $PATIENCE >= $THRESHOLD ))
		then
			printf "(Maybe you should play another thing...)\n"
		fi
	done

	USED[$(($REPLY-1))]=1

	if (( $REPLY >= 1 && $REPLY <= 6 ))
	then
		# Count the total of $REPLY
		local TOTAL=0
		for (( i=0 ; i < 6; i++ )); do
			if (( DICE[i] == $REPLY ))
			then
				TOTAL=$(( $TOTAL +  $REPLY ))
			fi
		done
		printf "Adding %s \n "  "$TOTAL"
		
		local INDEX=$(( $REPLY - 1 ))
		
		CARD[$INDEX]=$TOTAL
		USED[$INDEX]=1

		if (( ${CARD[6]} != 0 ))
	    then
			test_for_bonus
		fi
	elif (( $REPLY == 8 ))
	then
		test_for 3
		if (( $YAY == 1 ))
		then 
			CARD[7]=$SUM
			printf "Three-of-a-kind sums %s\n" $SUM
		fi
	elif (( $REPLY == 9 ))
	then
		test_for 4
		if (( $YAY == 1 ))
		then 
			CARD[8]=$SUM
			printf "Four-of-a-kind sums %s\n" $SUM
		fi
	elif (( $REPLY == 10 ))	
	then
		test_full_house
		if (( $YAY == 1 ))
		then 
			CARD[9]=25
			printf "Full house sums 25\n"
		fi
	elif (( $REPLY == 11 ))
	then
		test_for_sequency
		if (( $YAY == 1 ))
		then 
			CARD[10]=30
			printf "Low sequency sums 30\n"
		fi
	elif (( $REPLY == 12 ))
	then
		test_for_sequency
		if (( $YAY == 1 && $HIGH == 1 ))
		then 
			CARD[11]=40
			printf "High sequency sums 40\n"
		fi
	elif (( $REPLY == 13 ))
	then
		test_for 5
		if (( $YAY == 1 ))
		then 
			CARD[12]=50
			printf "YAHTZEE!!!\n"
		fi
	else 
		PATIENCE=$(( $PATIENCE + 1 ))
		if (( $PATIENCE > $THRESHOLD ))
		then
			printf "Gosh...\n"
		fi
	fi

}


function get_players {
	printf "YATZHEE!"
	printf "How many players (1-5, 0 to quit) ?"
	read
	while [[ ! $REPLY =~ [0-5]+$ ]]; do
		printf "Invalid answer. Please pick a valid number of players or quit.\n"
		read
	done

	PLAYERS=$REPLY
}

# Argument: player number
function store_card {
	CARD_FILE=".card_user_$1.txt"
	USED_FILE=".used_user_$1.txt"

	rm -f $CARD_FILE
	rm -f $USED_FILE
	for (( i= 0; i < 13 ; i++ )); do
		printf  "%s " "${CARD[i]}"  >> $CARD_FILE
		printf  "%s " "${USED[i]}"  >> $USED_FILE
	done
}

# Argument: player number
function read_card {
	CARD_FILE=".card_user_$1.txt"
	USED_FILE=".used_user_$1.txt"
	if [ ! -e "$CARD_FILE" ]
	then
		printf "%s not found\n" "$CARD_FILE"
	elif [ ! -e "$USED_FILE" ]
	then
		printf "%s not found\n" "$USED_FILE"
	else
		let i=0	
		for j in `cat $CARD_FILE`; do 
			CARD[i]=$j
			i=$(( $i + 1 ))
		done 

		let i=0	
		for j in `cat $USED_FILE`; do 
			USED[i]=$j
			i=$(( $i + 1 ))
		done
	fi
}


function init {
	get_players
	if (( $PLAYERS == 0 ))
	then 
		printf "Goodbye."
		exit
	fi

	#for each player, store cards to files
	for (( i=1; i<=$PLAYERS; i++)); do
		store_card $i
	done
}

# Argument: player number 
function play {
	PLAY=$1
	read_card $PLAY
	printf "Player %s's turn\n\n" "$PLAY"
	print_card
	clear_dice
	throw_dice
	print_dice
	choose_dice

	printf "TACK %s %s %s %s %s" "${DICE[0]}" "${DICE[1]}" "${DICE[2]}" "${DICE[3]}" "${DICE[4]}" "${DICE[5]}"

	if (( ${DICE[0]} == 0 || ${DICE[1]} == 0 || ${DICE[2]} == 0 \
	 	|| ${DICE[3]} == 0 || ${DICE[4]} == 0 ))
	then 
			throw_dice
			print_dice
	fi

	select_in_card
	store_card $PLAY
}



function play_loop {

	init

	END=0
	while (( $END == 0)); do
		for (( i=1; i<=$PLAYERS; i++)); do
			play $i
		done
		test_for_end
	done


	printf "GAME OVER...... \n\n"

	local WINNER=1
	local SCORE=0

	for (( i=1; i<=$(( $PLAYERS )); i++)); do
			printf "PLAYER %s" "$i\n"
			print_card
			printf "\n\n"
			if (( $SUM > $SCORE )) 
			then
				SCORE=$SUM
				WINNER=$i
			fi
	done

	printf "\n\n PLAYER %s WON!\n\n" "$WINNER"
}


