![Panic Button](https://i.imgur.com/Q43KgN3.png)

Idea by [/u/robtheimpure](https://www.reddit.com/user/robtheimpure): https://reddit.com/5mledp

###Panic Button
* Active item, single use
* On activation, the game moves at SPEED! challenge pace for the next 10 rooms.
* The item is consumed and a countdown appears above Isaac's head, showing
        how many rooms are left to clear.
* Individual boss rush & greed mode waves count as 1 room each.
* Big rooms do not count as 2 rooms.
* When the countdown reaches 0, game speed returns to normal and the button
        spawns an item and several pickups.
* Spawns 2 items if completed on a post-Mom floor.

###How to get the item
Play the game!

Or if you really, really want to try it out:
1. [Open the console](https://zatherz.eu/isaac/afterbirth+docs/md__i_1_doxygen_test_input_converted_test__debug__console__primer.html)
2. Type `giveitem Panic Button` and hit enter

####TODO:
* implement boss rush & greed mode waves
* stop drawing the countdown during cutscenes
* speed up music if active (is this possible?)
* "animate" the required room count as it approaches zero
* tweak reward pickup weights
* ? speed up player (like post-nerf SPEED! challenge)?
* ? spawn items from specific item pools based on floor (like Pandora's Box)?
* ? switch to costume instead of RenderText above the player's head?

