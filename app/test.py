import sys
from pylint.lint import Run

results = Run([sys.argv[1]], do_exit=False)
results = results.linter.stats['global_note']

if results < 5:
    exit(1)
else:
    exit(0)
