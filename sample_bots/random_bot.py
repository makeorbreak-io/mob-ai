import random
import json
import sys

import multipaint


class MegaBot4000(object):
    def __init__(self, player_id):
        self.player_id = player_id

    def next_move(self, state):
        return {
            "type": random.choice(["walk", "shoot"]),
            "direction": random.choice([[1,0], [-1,0], [0,1], [0,-1]]),
        }


if __name__ == "__main__":
    multipaint.run(MegaBot4000)
