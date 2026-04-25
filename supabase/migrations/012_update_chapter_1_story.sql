-- Update Chapter 1 story to move '-- a variable' to a new line
UPDATE chapters 
SET story = 'You arrive at a vast library. Ancient tomes line the walls, each labelled and sorted. The Keeper whispers: "Everything here is stored in a named container \n— a variable."'
WHERE concept = 'variables';
