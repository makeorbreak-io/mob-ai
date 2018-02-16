# AI Competition


## Setting

The game is composed of a 2D Board, of N x M squares. Each player has an
avatar, located at one of the squares. Squares cannot be occupied by multiple
avatars. Each square may be in a neutral state, or painted the color of a
player.

In a turn based fashion, players can do one of two actions:

* Move in any direction, causing the target square to be painted in their color
* Shoot paint in any direction, in a straight line whose length is at least
  one, or the length of the contiguous line of squares painted in their color
  in the opposite direction. The shot may be blocked by other players standing
  in the way or other players' shots.

Cardinal and ordinal directions are considered valid.

The game ends after a fixed number of turns. Players are ranked by the number
of squares painted their color. Players with the same number of painted squares
receive the same rank.


## Variants

These variants are easily implemented, and can add an extra level of difficulty
to the challenge:

* Obstacles placed at squares, making them unpaintable and unoccupiable by avatars.


## Turn based action resolution

Player actions must be resolved in a way that avoids first player advantage,
while still resolving ambiguities. The action resolving algorithm is as
follows:

* all movement actions are applied
  * each avatar is placed in its new position
  * while there is a square with two or more avatars in them, actions from all
    avatars in the square are undone
  * paint the squares occupied by all the avatars
* all shooting actions are applied:
  * each action's range is calculated
  * consider each shot a projectile that moves one square at a time, starting
    at the avatar's position
  * while there are active shots:
    * advance all shots one square
    * any shots that share a square with other shots or with any avatars, or
      that are in squares painted in this turn, are disabled
    * paint the squares of the remaining active shots
    * disable any shots that have reached their maximum range

Note that this allows players to swap places. It also causes shots fired
against each other to differently depending on the parity of the distance
between the shooters, leaving an untouched square if the distance is odd. It
also means that perpendicular shots will behave differently at their
intersection, depending on the distance from the shooters to that point.

The simplest version of this game would be in a 2-player setting, but it
supports up to N\*M players (it might be a bit crowded, though).


## Player API

Our evaluating servers will interact with the programs through the standard
input and standard output streams, using a line based json formatted protocol.
*Multiline JSON objects are not supported*.

The first message that the server sends to a program is the initialization
message, which just contains the player identifier for the game:

```json
{"player_id":"alice"}
```

This identifier will be used throughout the following messages, so the program
should remember this value to be able to identify themselves in the game state.

The program should reply to this message with a simple ackknowledgement:

```json
{"ready":true}
```

The second and following messages include the current game state, and expect
the next move decision in the reply. The following example will be spread over
multiple lines for readability purposes only; the real message will be
strippedof whitespace.

```json
{
  "width":3,
  "height":2,
  "player_positions:{
    "alice":[0,0],
    "bob":[1,1]
  },
  "colors":[
    ["alice","alice",null],
    [null,"bob","bob"]
  ],
  "turns_left":5,
  "previous_actions": [
    {
      "alice": {"type":"walk","direction":[0,-1]},
      "bob": {"type":"shoot","direction":[0,1]}
    }
  ]
}
```

Here are a few examples of valid answers:

```json
{"turns_left":5,"type":"shoot","direction":[0,1]}
{"turns_left":5,"type":"walk","direction":[-1,0]}
{"turns_left":5,"type":"walk","direction":[1,-1]}
```

`type` must always be `walk` or `shoot`, and `direction` must be a list of two
elements, describing one of the eight valid directions.

`turns_left` should match the value from the game state. This acts as a nonce,
and it is required to protect programs from timeout issues.


### Timeouts

To prevent players from accidentally slow down the server by taking too long to
reply, the server will only wait a certain amount of time for a reply. The
timeouts are as follows:

- ready message: 5 seconds; this includes program boot time, if applicable
- next move message: 0.5 seconds
