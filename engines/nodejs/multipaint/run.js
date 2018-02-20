"use strict";

const readline = require("readline");

const run = (botClass) => {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false,
  });

  let bot = null;
  rl.on("line", (line) => {
    const msg = JSON.parse(line);

    if (!bot) {
      bot = new botClass(msg.player_id);
      console.log(JSON.stringify({ ready: true }));
    } else {
      console.log(JSON.stringify(Object.assign(
        { turns_left: msg.turns_left },
        bot.next_move(msg)
      )));
    }
  });
}

module.exports = run;
