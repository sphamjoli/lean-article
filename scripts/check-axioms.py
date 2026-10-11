"""Check that every required theorem is audited exactly once."""
import re
import sys

EXPECTED = {
    'details_characterisation', 'authorised_characterisation',
    'authorised_meets_requirement', 'eve_passes_details',
    'eve_violates_requirement', 'eve_rejected_by_authorisation',
    'good_records_faithful', 'eve_passes_bad_records',
    'eve_still_violates_requirement', 'bad_records_not_faithful',
    'alice_accepted', 'alice_meets_requirement',
}
ALLOWED = {'propext', 'Classical.choice', 'Quot.sound'}
seen = set()
for line in sys.stdin.read().splitlines():
    print(line)
    match = re.fullmatch(
        r"'Collection\.([A-Za-z_]+)' (?:does not depend on any axioms|depends on axioms: \[(.*)\])",
        line,
    )
    if not match:
        sys.exit('Unexpected audit output')
    name, dependencies = match.groups()
    if name not in EXPECTED or name in seen:
        sys.exit('Unexpected or duplicate theorem identity')
    seen.add(name)
    if dependencies is not None:
        axioms = set(dependencies.split(', ')) if dependencies else set()
        if axioms - ALLOWED:
            sys.exit('Unexpected theorem axiom dependency')
if seen != EXPECTED:
    sys.exit('Missing required theorem audit')
