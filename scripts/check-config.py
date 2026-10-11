"""Validate tracked TOML and JSON, or their staged contents."""
import json
import subprocess
import sys
import tomllib
from pathlib import Path
staged = '--staged' in sys.argv
args = ['git', 'diff', '--cached', '--name-only', '--diff-filter=ACMR', '-z'] if staged else ['git', 'ls-files', '-z']
for raw in subprocess.check_output(args).split(b'\0'):
    if not raw:
        continue
    name = raw.decode()
    if not name.endswith(('.toml', '.json')):
        continue
    content = subprocess.check_output(['git', 'show', ':' + name]).decode() if staged else Path(name).read_text()
    (tomllib.loads if name.endswith('.toml') else json.loads)(content)
