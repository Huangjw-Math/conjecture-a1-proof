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

## Current evidence and publication gate

The original Conjecture A.1 now has an actual general Lean proof:
`ConjectureA1.vector_conjecture K V : VectorConjecture K V`, implemented in
formalization/General.lean. It covers every natural p,q and preserves exactly the
original field/vector-space/local-commutation/vector-annihilation hypotheses.
The shared sparse-root and line-vanishing interfaces are discharged by proved
implementations; they do not remain root assumptions.

Lean 4.31.0 and the pinned Mathlib/eight dependencies freshly compiled all twelve
material modules. All 62 proved declarations returned allowed transitive axiom
sets; the full root uses propext, Classical.choice and Quot.sound. Material source
contains no unfinished terms, user axioms, unsafe or native_decide. A fresh source
readback and separate original-contract comparison passed the full-root semantic gate.

The written main theorem and all-parameter tensor sharpness retain the prior
independent mathematical audit. Paper/verification sources and their validated
PDFs are unchanged in this continuation; their existing same-input checks remain
valid. General tensor sharpness is not formalized and is not a root dependency.

The user requires a complete original root proof before any draft PR submission.
Do not submit another partial-result PR. The previous GitHub integration returned
HTTP 403; repository/PR connection permission is a publication dependency, separate
from the completed mathematics. No credential workaround or merge is authorized.

Current theorem/build details are in formalization/PROGRESS.md and
`docs/full-formalization-2026-11-06/`. Earlier 2026-11-05 partial reviews apply to
their recorded snapshots, not to the new full-root completion status.

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
- Published the clean code snapshot 183368b3428aa755acb80987be43ba3ac2ee900c
  to the new fork branch. The Git server acknowledged creation of that branch.
  Creating the requested draft PR through the connected GitHub integration then
  returned HTTP 403, Resource not accessible by integration. No PR was created.
  This is the remaining delivery blocker: the connection owner must enable the
  necessary repository/PR permission, then the coordinator can retry the same
  authorized draft-creation action. The user may instead create the draft from
  the published branch. No alternate credential route or merge was attempted.

## Complete-formalization continuation — 2026-11-05

- User changed the acceptance gate: finish the arbitrary-p,q original Lean theorem
  before submitting a draft PR. Do not publish another partial-result PR.
- Starting snapshot edd9dd0 is clean and already pushed; prior machine evidence
  remains valid for its unchanged 37 declarations. The GitHub 403 is a later
  publication dependency, not a reason to stop mathematical work.
- Chosen formal route retains normal ordering and weighted line relations.
  A scalar sparse-root uniqueness theorem and a vector finite-convolution kernel
  will eliminate all three line regions uniformly. Natural lower endpoints encode
  negative line differences, avoiding unnecessary integer-exponent machinery.
- Shared interfaces are frozen in LineRecurrence.lean: SparseRootProperty,
  lineCoeff and LineRecurrence. The full final theorem must discharge the sparse
  uniqueness premise, not retain it as a new hypothesis. No placeholders or new
  axioms are accepted. Root owns these interfaces and the endomorphism assembly;
  independent obligation owners write separate leaf modules. No shared Lake builds
  run concurrently; direct per-module Lean compilation uses read-only external caches.

## General-proof completion work — 2026-11-06

- Completed the user's new acceptance gate at the proof layer: vector_general
  and vector_conjecture in General.lean were directly compiled for arbitrary natural parameters.
  Root type/axiom inspection gives the faithful target and only standard foundations.
- Proved SparseRootProperty by Euler support elimination; proved the exact finite
  generating-polynomial kernel and lifted it to arbitrary vector spaces by full dual
  separation. These are actual Lean theorems, not newly assumed analytic facts.
- Proved genuine left-anchor monomial relations, with out-of-range terms removed by
  zero coefficients. Natural lower endpoints encode negative line differences.
  The uniform support kernel handles all line regions, and weighted induction
  assembles the original sum-power conclusion without PBW or an explicit trinomial sum.
- Added 25 proved declarations across six new modules, retaining all 37 earlier
  interfaces. The successful fresh full run checks 12 material modules and 62/62
  declaration axiom sets. A preceding audit attempt failed on a nonexistent probe
  accidentally parsed from a comment; removed only that extra probe and reran the
  complete build. No mathematical obligation or actual declaration check was removed.
- Froze the full root's eight-module mathematical dependency packet for a fresh
  blind reader. A separate original-contract comparison follows that readback.
  No new PR is attempted until these full-proof acceptance checks finish.

- Updated current README, PROGRESS, formalization notes and citation description to
  the actual complete root. The CFF had still described general sharpness as open
  and Lean as uncompiled; its mathematical description now matches the checked
  results, preserving the original author/release fields. Historical partial
  audits are clearly linked as earlier snapshots rather than current blockers.

- Final independent acceptance passed: the blind reader reconstructed the full
  original mathematical statement without the informal target. A separate comparator
  checked the paper contract and compiled a new raw-commutator, independent-universe
  Guard, including the literal three-operator formulation. It found no remaining
  root obligations; ten independent axiom checks used only the standard three.
  Reports and reusable Guard are in docs/full-formalization-2026-11-06.
