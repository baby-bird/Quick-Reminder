--explode ƒ 2008 ljr (http://applescript.bratis-lover.net)
on explode(delimiter, input)
	local delimiter, input, ASTID
	set ASTID to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to delimiter
		set input to text items of input
		set AppleScript's text item delimiters to ASTID
		return input --> list
	on error eMsg number eNum
		set AppleScript's text item delimiters to ASTID
		error "Can't explode: " & eMsg number eNum
	end try
end explode

--Remind Me ƒ 2014 Jonathan Wiesel (http://github.com/jonathanwiesel)
display dialog "¾î¶² ¹Ì¸®¾Ë¸²À» ¹ÞÀ¸½Ã°Ú¾î¿ä?" default answer ¡þ
	"" with icon path to resource "Reminders.icns" in bundle "/Applications/Reminders.app"
set reminder_input to text returned of result --get input

set noDate to "no"
set myList to explode(";", reminder_input)
set theReminder to item 1 of myList
try
	set queryDay to item 2 of myList
on error
	set queryDay to "none"
end try
try
	set theHour to item 3 of myList
on error
	set theHour to "none"
end try


if queryDay contains "¿À´Ã" then
	set theDay to day of (current date)
	set theMonth to month of (current date) as integer
	set theYear to year of (current date)
	set theDate to theYear & " " & theMonth & " " & theDay & " "
	set DateString to the theDate as string
	
else if queryDay contains "³»ÀÏ" then
	set theDay to (day of ((current date) + (24 * 60 * 60)))
	if (day of (current date)) < (day of ((current date) + (24 * 60 * 60))) then
		set theMonth to month of (current date) as integer
	else
		set theMonth to (month of ((current date) + (30 * 24 * 60 * 60))) as integer
	end if
	if year of (current date) < year of ((current date) + (24 * 60 * 60)) then
		set theYear to (year of (current date)) + 1
		set theDate to theYear & " " & theMonth & " " & theDay & " "
	else
		set theYear to year of (current date)
		set theDate to theYear & " " & theMonth & " " & theDay & " "
	end if
	
	
else if queryDay contains "ÀÌ¹øÁÖ" then
	set theDay to (day of ((current date) + (7 * 24 * 60 * 60)))
	if (day of (current date)) < (day of ((current date) + (7 * 24 * 60 * 60))) then
		set theMonth to month of (current date) as integer
	else
		set theMonth to (month of ((current date) + (30 * 24 * 60 * 60))) as integer
	end if
	if year of (current date) < year of ((current date) + (7 * 24 * 60 * 60)) then
		set theYear to (year of (current date)) + 1
		set theDate to theYear & " " & theMonth & " " & theDay & " "
	else
		set theYear to year of (current date)
		set theDate to theYear & " " & theMonth & " " & theDay & " "
	end if
	
else if queryDay contains "none" then
	set noDate to "yes"
	
else
	if date ((year of (current date)) & " " & queryDay as string) < (current date) then
		set theDate to (year of (current date)) + 1 & " " & queryDay
	else
		set theDate to (year of (current date)) & " " & queryDay
	end if
end if

if noDate contains "yes" then
	tell application "Reminders"
			make new reminder with properties {name:theReminder}
		quit
	end tell
	set output to theReminder
else
	
	set stringedDate to theDate as string
	if theHour does not contain "none" then
		set stringedHour to theHour as string
		if stringedHour does not contain "¿ÀÀü" and stringedHour does not contain "¿ÀÈÄ" then
			
			set mySplitedFullHour to explode(":", stringedHour)
			set theSplitedHour to item 1 of mySplitedFullHour
			set theSplitedMinutes to item 2 of mySplitedFullHour
			
			
			if (theSplitedHour as number) > 23 then
				set DueDate to date (stringedDate & " " & "¿ÀÀü 12:00")
			else if (theSplitedHour as number) > 12 then
				set correctHour to (theSplitedHour as number) - 12
				set stringedCorrectHour to "¿ÀÈÄ" & (correctHour as string) & ":" & (theSplitedMinutes as string)
				set DueDate to date (stringedDate & " " & stringedCorrectHour)
			else if (theSplitedHour as number) = 12 then
				set correctHour to (theSplitedHour as number)
				set stringedCorrectHour to "¿ÀÈÄ" & (correctHour as string) & ":" & (theSplitedMinutes as string)
				set DueDate to date (stringedDate & " " & stringedCorrectHour)
			else
				set correctHour to (theSplitedHour as number)
				set stringedCorrectHour to "¿ÀÀü" & (correctHour as string) & ":" & (theSplitedMinutes as string)
				set DueDate to date (stringedDate & " " & stringedCorrectHour)
			end if
		end if
		
	else
		if queryDay contains "¿À´Ã" or queryDay contains "³»ÀÏ" or queryDay contains "ÀÌ¹øÁÖ" or theHour contains "none" then
			set DueDate to date (stringedDate)
		else
			set DueDate to date (stringedDate & " " & stringedHour)
		end if
	end if
	tell application "Reminders"
			make new reminder with properties {name:theReminder, due date:DueDate}
		quit
	end tell
	set output to theReminder & "
Due: " & DueDate
end if