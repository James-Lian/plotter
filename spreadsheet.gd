extends Node2D

class_name Spreadsheet

const ALPHABET := ["a", "b", "c", "d", 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
const NUMBERS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

var spreadsheet_data = {
	
}

func check_if_cell_is_real(spreadsheet_cell_to_check):
	var column = ""
	var row = ""
	
	var cell_is_real = false
	
	var checking_column_or_row = true #true for checking column, false if checking row
	
	for char in spreadsheet_cell_to_check:
		if checking_column_or_row:
			for letter in ALPHABET:
				if char.to_lower() == letter:
					cell_is_real = true
					column += char.to_lower()
		else:
			for number in NUMBERS:
				if char == number:
					cell_is_real = true
					row += char
	
	if cell_is_real:
		return [column, row]
	else:
		return [false]

func se_data(spreadsheet_cell_list, value):
	pass
