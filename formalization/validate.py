"""Freshly compile all material modules, then inspect their kernel axiom output.

Python 3 standard library only; PowerShell 5.1+ or PowerShell 7 is required.
The build is run on every invocation. Historical evidence logs are never read.
See PROGRESS.md for dependency-managed and existing-cache commands.
"""
from pathlib import Path
import json
import re
import argparse
import os
import shutil
import subprocess
import sys

FORBIDDEN = re.compile(r"\b(sorry|admit|axiom|unsafe|native_decide|sorryAx)\b")


def mask(text):
    """Mask nested comments, quoted identifiers and literal strings positionally."""
    out = list(text)
    i = 0
    while i < len(text):
        end = i
        if text.startswith('--', i):
            end = text.find('\n', i)
            if end < 0: end = len(text)
        elif text.startswith('/-', i):
            end, depth = i + 2, 1
            while end < len(text) and depth:
                if text.startswith('/-', end): depth += 1; end += 2
                elif text.startswith('-/', end): depth -= 1; end += 2
                else: end += 1
        elif text[i] == '\u00ab':
            end = text.find('\u00bb', i + 1)
            end = len(text) if end < 0 else end + 1
        else:
            raw = re.match(r'r(#+)?"', text[i:]) if text[i] == 'r' else None
            if raw:
                close = '"' + (raw.group(1) or '')
                end = text.find(close, i + len(raw.group(0)))
                end = len(text) if end < 0 else end + len(close)
            elif text[i] == '"':
                end = i + 1
                while end < len(text):
                    if text[end] == '\\': end += 2
                    elif text[end] == '"': end += 1; break
                    else: end += 1
        if end > i:
            for k in range(i, min(end, len(text))):
                if out[k] not in '\r\n': out[k] = ' '
            i = end
        else: i += 1
    return ''.join(out)


def main():
    # Lean emits Unicode identifiers even with a legacy Windows console code page.
    sys.stdout.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--lean-bin', default=os.environ.get('LEAN_BIN', ''),
                        help='existing pinned Lean/Lake bin directory (otherwise PATH)')
    parser.add_argument('--mathlib-cache', default=os.environ.get('MATHLIB_CACHE', ''),
                        help='existing Mathlib checkout with pinned compiled dependencies')
    args = parser.parse_args()
    root = Path(__file__).resolve().parent
    shell = shutil.which('powershell.exe') if os.name == 'nt' else shutil.which('pwsh')
    if not shell:
        parser.error('PowerShell was not found. Use the standard lake build route in PROGRESS.md.')
    command = [shell, '-NoProfile', '-File',
               str(root / 'build.ps1')]
    if args.lean_bin:
        command += ['-LeanBin', args.lean_bin]
    if args.mathlib_cache:
        command += ['-MathlibCache', args.mathlib_cache]
    else:
        command += ['-Mathlib']
    # Capture this exact compiler run, not the last log left in the workspace.
    completed = subprocess.run(command, cwd=root, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT)
    log = completed.stdout.decode('utf-8-sig', errors='replace')
    evidence = root / 'evidence'
    evidence.mkdir(exist_ok=True)
    (evidence / 'validation-build.log').write_text(log, encoding='utf-8')
    print(log, end='')
    sources = sorted(root.glob('*.lean'))
    hits, declarations = [], []
    for path in sources:
        code = mask(path.read_text(encoding='utf-8-sig'))
        for m in FORBIDDEN.finditer(code):
            hits.append({'file': path.name, 'line': code.count('\n', 0, m.start()) + 1,
                         'token': m.group(0)})
        declarations += ['ConjectureA1.' + n for n in
                         re.findall(r"\b(?:lemma|theorem)\s+([\w']+)", code)]
    probe = mask((root / 'AxiomAudit.lean').read_text(encoding='utf-8'))
    missing = [d for d in declarations if f'#print axioms {d}' not in probe]
    axioms = {}
    for d in declarations:
        m = re.search(r"'" + re.escape(d) + r"' depends on axioms: \[([^\]]*)\]", log)
        if m:
            axioms[d] = [a.strip() for a in m.group(1).split(',') if a.strip()]
        elif f"'{d}' does not depend on any axioms" in log:
            axioms[d] = []
    allowed = {'propext', 'Classical.choice', 'Quot.sound'}
    bad = {d: a for d, a in axioms.items() if not set(a) <= allowed}
    material = [p.stem for p in sources if not p.stem.startswith('lakefile')]
    unchecked = [n for n in material if f'CHECKED {n}' not in log]
    result = {
        'sources': [p.name for p in sources],
        'forbidden_code_tokens': hits,
        'theorem_count': len(declarations),
        'missing_axiom_probes': missing,
        'unreported_axiom_sets': sorted(set(declarations) - set(axioms)),
        'axioms': axioms,
        'disallowed_axioms': bad,
        'unchecked_material_modules': unchecked,
        'build_returncode': completed.returncode,
        'lake_build_exit_zero': completed.returncode == 0 and
            'Build completed successfully' in log and 'EXIT=0' in log,
    }
    result['passed'] = (not hits and not missing and not bad and not unchecked and
                        len(axioms) == len(declarations) and result['lake_build_exit_zero'])
    report = json.dumps(result, ensure_ascii=False, indent=2)
    (evidence / 'validation-report.json').write_text(report + '\n', encoding='utf-8')
    print(report)
    return 0 if result['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
