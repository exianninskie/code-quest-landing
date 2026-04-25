-- Fix Chapter 1 story formatting to use a real newline instead of a literal '\n' string
UPDATE chapters 
SET story = 'You arrive at a vast library. Ancient tomes line the walls, each labelled and sorted. The Keeper whispers: "Everything here is stored in a named container
— a variable."'
WHERE concept = 'variables';
