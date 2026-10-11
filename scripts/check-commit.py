"""Validate the first non-comment commit-message line."""
import re
import sys
from pathlib import Path
header = next((line for line in Path(sys.argv[1]).read_text().splitlines()
               if line.strip() and not line.startswith('#')), '')
pattern = r'(feat|fix|docs|style|refactor|test|chore|ci|perf|revert)(?:\((rust|lean|docs|ci|deps|tooling)\))?: [a-zA-Z][-a-zA-Z0-9 .,():+/]+'
if not re.fullmatch(pattern, header):
    sys.exit('Use type(scope): subject; scopes: rust, lean, docs, ci, deps, tooling')
