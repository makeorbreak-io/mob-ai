"use strict";

const multipaint = require("multipaint");

const choice = (array) => array[Math.floor(Math.random() * array.length)];

class Megabot2000 {
  constructor(player_id) {
    this.player_id = player_id;
  }

  next_move(state) {
    return {
      type: choice(["walk", "shoot"]),
      direction: choice([[-1, -1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]),
    };
  }
}

multipaint.run(Megabot2000);
