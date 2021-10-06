#!/usr/bin/env python3
import json
import os

number = os.environ["GITHUB_RUN_NUMBER"]
size = os.path.getsize("voyager.iso")
max_size = 737280000
size_pct = size / max_size * 100

payload = {
    "embeds": [
        {
            "title": f"Build {number} complete",
            "description": (
                f"Size: {size:,}/{max_size:,} ({size_pct}%)\n"
                f"https://titan.voyager.sibr.dev/~ci/{number}/voyager.iso.zip"
            ),
            "color": 0x9370DB,
        }
    ]
}

print(json.dumps(payload))
