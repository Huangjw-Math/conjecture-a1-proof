# Problem contract

Source: Liu, Wu, Zhang, Zhou, arXiv:1811.10137, Appendix A, Conjecture A.1;
repository baseline f8f7235dca197933cd97ac74b6d35d64f67e693d.

## Objects, hypotheses, conclusion

Let K be any characteristic-zero field, V any K-vector space (no finite dimension
assumption), X,Y in End_K(V), and Z=XY-YX. Assume XZ=ZX and YZ=ZY.
For every p,q in the nonnegative integers and v in V, if X^(p+1)v=0 and
Y^(q+1)v=0, then (X+Y)^(2p+2q+1)v=0.

All constants/exponents are explicit. Include p=0, q=0, V=0, and v=0.
The universal algebra quotient and its left ideal are proof tools. Do not replace
vector annihilation by operator annihilation or treat a left ideal as two-sided.
General sharpness is a separate target, not necessary to prove Conjecture A.1.

## Completion criteria

Audit all mathematical dependencies and original-source fidelity. A complete Lean
proof requires faithful statements, pinned compilation, zero unfinished proof terms,
and a justified axiom set. A partial Lean contribution is permitted only with exact
scope and open obligations stated. Finite exact computations do not establish the
universal conjecture or universal sharpness.

## Tools and constraints

Local Codex formalizer: gpt-6.1-sol, priority (fast); report runtime evidence.
Changes go to a review branch and draft PR; no merge. Preserve author files and history.
Public primary-source browsing permitted. No omitted attachment contents were available.

## Contract audit

Checked directly against arXiv:1811.10137v2, Appendix A, printed page 42
(PDF page index 41), on 2026-11-05: the objects, characteristic, local
commutation, vector hypotheses, exponent and zero-parameter cases match.
The original paper proves p=0 or q=0, and p=q=1 separately. It does not restrict
both parameters to {0,1}. The repaired manuscript and faithful Lean target retain
the original vector-level quantifiers; the legacy ring/module definition is
explicitly identified as a different, unproved proposition.
