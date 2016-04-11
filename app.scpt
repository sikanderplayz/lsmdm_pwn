set launcherPath to path to me

set dialogReply to display dialog "Clicking okay will open up the terminal and execute ./lsmdm_pwn.sh" ¬
	hidden answer false ¬
	buttons {"GitHub", "Okay", "Cancel"} ¬
	default button "Okay" ¬
	with title "LSMDM_pwn" ¬
	with icon note ¬
	
if dialogReply = Github then
	open location "http://www.google.com"
else
	if dialogReply = Okay
		do shell script launcherPath + "/lsmdm_pwn.sh"
	end if
end if