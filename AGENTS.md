# Conjecture A.1 proof and formalization

## Contract and working methods

Audit Conjecture A.1 of Liu–Wu–Zhang–Zhou, arXiv:1811.10137v2,
Appendix A. Work over every characteristic-zero field, every vector space,
natural p,q (including zero), with Z=XY-YX, XZ=ZX, YZ=ZY and vector
annihilation X^(p+1)v=Y^(q+1)v=0. The target is
(X+Y)^(2p+2q+1)v=0. Do not replace this by operator nilpotence or ambient
centrality. Preserve the author's weighted-degree/line-system proof route
when making local repairs. Record exact gaps; a target definition is not a proof.

Read the proof in report/src/report.tex, the original Appendix A and
formalization/PROGRESS.md before relying on their status claims.
Use exact Python arithmetic and the pinned Lean/Mathlib environment.
Run `python verification/run_all.py`; build Lean as documented in
formalization/PROGRESS.md and check actual theorem signatures and transitive axioms.
Compile both reports with XeLaTeX twice and inspect their rendered pages.
Finite computations do not prove the universal theorem or sharpness.

## Publication and preservation

The user authorized a draft PR to Huangjw-Math/conjecture-a1-proof, not a merge.
Preserve the existing audit branch and its files. This clean branch is based on
upstream main, with selected mathematical changes copied from the prior branch.
Do not include local paths, user/process/session identifiers, launch arguments,
credentials or raw machine logs. Keep only portable source, precise reports and
reproduction commands. Never rewrite or force-push existing published branches
without the user's confirmation. Keep other owners' changes intact.

## Current evidence and open work

Takeover checked upstream main f8f7235 and prior fork branch f4fd266; the old
worktree was clean and exactly two commits ahead. The clean review branch does
not include those run-record commits in its ancestry.

The written main theorem and all-parameter tensor sharpness passed current
independent mathematical audit after the local repairs recorded below. Both
PDFs are regenerated from the final TeX and visually checked (15 and 6 pages).

Lean 4.31.0 with pinned Mathlib and eight dependencies compiled all six material
modules, 37 proved declarations in total (17 new). Checked infinite boundary
families are p=0 or q=0; p=q=1 is also proved. General Taylor, normal ordering
and the right-annihilator relation are proved. The positive-parameter line
system, triangular elimination, fewnomial module argument and final general
assembly remain open in Lean. The general target is still a proposition def.

The exact Python suite passed nine scripts and ten regression groups, with
finite ranges and failure-path evidence in docs/audit-2026-11-05/exact-checks.md.
Scanner tests pass five groups. `python formalization/validate.py` always builds
fresh material artifacts and queries every theorem's transitive axioms.
Existing imported dependency oleans are trusted cache inputs, not rebuilt here.

Independent source/type readback and separate contract comparison passed for the
stated partial scope. An independently authored typed Guard compiled successfully.
See docs/audit-2026-11-05/lean-review.md. The general target remains open.
No merge is authorized.

## Decisions and work record — 2026-11-05

- User requested independent takeover, proof and script repair, continued general
  Lean formalization, PDF/source consistency and a draft PR. Requested runtime:
  gpt-6.1-sol, reasoning max, Fast. Actual runtime evidence is checked locally;
  raw process and session records will not be published.
- Fetched both remotes: upstream main and the old fork branch matched the stated
  commits. No upstream changes or uncommitted local work were found.
- Created a separate worktree and new branch audit/a1-clean-2026-11-05 from main.
  Copied substantive sources without the old runtime/evidence directories.
  Original files and both published commits remain available on the old branch.
- Independent mathematical audit, exact-script checks and Lean development have
  separate ownership. The coordinator owns integration, PDF QA and publication.
- Independent review found an additional false auxiliary statement: characteristic
  zero of a ring alone does not justify integer cancellation. The counterexample
  R=Z×M₂(F₂), x=(0,E₁₂), y=(0,E₂₁), p=q=1 has x²=y²=0 and central
  z=(0,I₂), but (x+y)^5=x+y≠0. Both TeX auxiliary propositions now explicitly
  require an associative algebra over a characteristic-zero field and explain
  cancellation of choose(p+1,J)·J!. The original vector theorem is unchanged.
- The independent audit accepted the full written theorem and all-parameter
  tensor sharpness, including empty tensors and all three line-system boundaries.
  Further local repairs: do not exclude the two-sided augmentation ideal at p=q=0;
  state the commutative iff in K[X,Y]; give exact normal-order specialization and
  factorial conversion; restrict computational claims to their enumerated ranges.
- Regenerated both PDFs with XeLaTeX after installing the missing small enumitem
  package in the existing user MiKTeX. Removed an unused mathrsfs import. Reflowed
  long formulas rather than shrinking them. Full-page render QA and source/PDF
  consistency checks are recorded in the takeover report.
- The current exact-verifier audit passed all nine scripts and ten regression
  groups. It exercised a corrupted real coefficient checker, a timeout and disabled
  assertions in disposable subprocesses, verifying nonzero aggregate exits.
  Added 144 high-degree Z^k B_m assertions where a probe formerly only printed.
- Lean development has compiled both arbitrary zero-boundary families. General
  p,q remains open while reusable normal-order work continues.
- Final Lean author validation passed 37/37 transitive axiom probes with only
  propext, Classical.choice and Quot.sound. It freshly compiled all six modules.
  The new quoted-identifier scanner repair has five passed regression groups;
  PowerShell source parsing also passed. Existing dependency checkouts were all
  pinned and tracked-clean. The online dependency-download route was not run.
- Historical privacy scanning covered both old commits (200 changed files):
  machine paths, session identifiers and process launch details were confirmed;
  supported token patterns produced no match. Candidate source scanning found
  none of those categories. This is a pattern check, not a proof about every
  possible credential format. Old published history remains untouched.
- The final PDFs were compiled twice from their final source. Render review
  covered all 21 pages and corrected formula overflows; final logs have no missing
  glyphs, undefined references or overfull boxes. A nonessential font-style fallback
  and installed-LaTeX-version warnings remain. No PDF-source mismatch is retained.
- A fresh reader reconstructed all 37 actual signatures from the frozen Lean
  source/type packet without the informal target. A separate fresh comparator
  checked that readback against Appendix A and compiled an independently authored
  Guard for five root interfaces, target definition and independent universes.
  All checks passed for the stated partial scope. The Guard source is published
  under docs/audit-2026-11-05; raw compiler/process logs remain local.
- Final upstream refresh still resolved main to f8f7235. One transport attempt
  failed TLS; the command-scoped Schannel backend succeeded, without changing
  global Git/network configuration. The old worktree remained clean and preserved.
