import json
import sys
import os


def run(Class):
    stdout = os.fdopen(sys.stdout.fileno(), 'w', buffering=1)

    msg = json.loads(sys.stdin.readline().strip())

    bot = Class(msg["player_id"])

    print(json.dumps({ "ready": True }), file=stdout)

    while True:
        msg = json.loads(sys.stdin.readline().strip())

        next_move = bot.next_move(msg)

        print(json.dumps(dict(turns_left=msg["turns_left"], **next_move)), file=stdout)
