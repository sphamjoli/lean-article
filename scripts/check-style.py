"""Check comment separators, trailing Rust comments and Markdown paragraphs.

The Rust comment checks use line scanning rather than a Rust parser.
"""
import re
import subprocess
import sys
from pathlib import Path
staged = '--staged' in sys.argv
args = ['git', 'diff', '--cached', '--name-only', '--diff-filter=ACMR', '-z'] if staged else ['git', 'ls-files', '-z']
failed = False
for raw in subprocess.check_output(args).split(b'\0'):
    if not raw:
        continue
    name = raw.decode()
    if not name.endswith(('.rs', '.lean', '.py', '.sh', '.md')):
        continue
    text = subprocess.check_output(['git', 'show', ':' + name]).decode() if staged else Path(name).read_text()
    fenced = False
    previous_prose = False
    for number, line in enumerate(text.splitlines(), 1):
        if name.endswith('.md'):
            if line.startswith(('```', '~~~')):
                fenced = not fenced
                previous_prose = False
                continue
            prose = bool(line.strip()) and not fenced and not re.match(r'^(?:\s*[-*+>]|\s*\d+[.)]|#|\|| {4})', line)
            bad = prose and previous_prose
            previous_prose = prose
        else:
            bad = bool(re.match(r'^\s*(?://+|--|#)\s*[-=*~_]{5,}\s*$', line))
            if name.endswith('.rs'):
                # Remove quoted string literals before looking for trailing comments.
                code = re.sub(r'"(?:\\.|[^"\\])*"', '""', line)
                bad = bad or bool(re.search(r'\S.*//', code)) and not code.lstrip().startswith('//')
        if bad:
            print(f'{name}:{number}: comment or paragraph style violation', file=sys.stderr)
            failed = True
sys.exit(1 if failed else 0)
