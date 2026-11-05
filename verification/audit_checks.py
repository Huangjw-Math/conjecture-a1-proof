"""Independent exact regressions; all parameter ranges are finite."""
import unittest
import json
import pathlib
import subprocess
import sys
import tempfile
from fractions import Fraction as F
from itertools import product
from math import factorial
from conj2 import Quotient, T_powers, I_basis
from conj import T_power_on_v
from verify import X, Y, Z, one, mul, pw, add
import run_all


def poly_op(poly, terms):
    """Apply sum c*x_target*d/dx_source to six-variable monomials."""
    out = {}
    for mono, coeff in poly.items():
        for target, source, sign in terms:
            if mono[source]:
                dest = list(mono)
                dest[source] -= 1
                dest[target] += 1
                dest = tuple(dest)
                out[dest] = out.get(dest, 0) + coeff * mono[source] * sign
    return {m: c for m, c in out.items() if c}


# Sym^p(W*) tensor Sym^q(W), coordinates u1,u2,u3,v1,v2,v3.
# This is independent of PBW quotient elimination. Dual action is -transpose.
PX = [(1, 0, -1), (3, 4, 1)]
PY = [(2, 1, -1), (4, 5, 1)]
PZ = [(2, 0, -1), (3, 5, 1)]


def compositions3(n):
    return [(a, b, n-a-b) for a in range(n+1) for b in range(n-a+1)]


class ExactRegressions(unittest.TestCase):
    def test_runner_propagates_failure_and_timeout(self):
        # Run real child processes in a disposable copy, not mocked return codes.
        source_root = pathlib.Path(__file__).resolve().parent
        for scenario in ["assertion", "timeout"]:
            with tempfile.TemporaryDirectory(prefix="a1-check-runner-") as tmp:
                root = pathlib.Path(tmp)
                (root/"run_all.py").write_text((source_root/"run_all.py").read_text(encoding="utf-8"),
                                               encoding="utf-8")
                for name in run_all.SCRIPTS:
                    (root/name).write_text("print('sandbox control passed')\n", encoding="utf-8")
                if scenario == "assertion":
                    target = "pureZ_check.py"
                    source = (source_root/target).read_text(encoding="utf-8")
                    prediction = "pred = F((-1) ** (p + 1) * factorial(p + 1))"
                    self.assertEqual(source.count(prediction), 1)
                    # Corrupt a real coefficient prediction; the actual checker
                    # must fail rather than merely print an adverse result.
                    (root/target).write_text(source.replace(prediction, prediction + " + 1"),
                                              encoding="utf-8")
                else:
                    target = run_all.SCRIPTS[0]
                    (root/target).write_text("import time\ntime.sleep(4)\n", encoding="utf-8")
                output = root/"results"
                child = subprocess.run([sys.executable, str(root/"run_all.py"),
                                        "--output-dir", str(output), "--timeout", "1"],
                                       capture_output=True, text=True, timeout=20)
                self.assertEqual(child.returncode, 1, child.stdout + child.stderr)
                report = json.loads((output/"results.json").read_text(encoding="utf-8"))
                self.assertEqual(report["status"], "FAIL")
                self.assertEqual(len(report["results"]), len(run_all.SCRIPTS))
                failed = [entry for entry in report["results"] if entry["exit_code"] != 0]
                self.assertEqual([entry["script"] for entry in failed], [target])
                self.assertEqual(failed[0]["exit_code"], 1 if scenario == "assertion" else None)
                transcript = (output/(target + ".txt")).read_text(encoding="utf-8")
                self.assertIn("AssertionError" if scenario == "assertion" else "TIMEOUT", transcript)

    def test_runner_covers_all_python_scripts(self):
        root = pathlib.Path(__file__).resolve().parent
        actual = {path.name for path in root.glob("*.py") if path.name != "run_all.py"}
        self.assertEqual(set(run_all.SCRIPTS), actual)
        self.assertEqual(len(run_all.SCRIPTS), len(actual))

    def test_runner_rejects_disabled_assertions(self):
        with tempfile.TemporaryDirectory(prefix="a1-check-optimized-") as tmp:
            output = pathlib.Path(tmp)/"results"
            child = subprocess.run([sys.executable, "-O", run_all.__file__,
                                    "--output-dir", str(output)],
                                   capture_output=True, text=True, timeout=10)
            self.assertNotEqual(child.returncode, 0)
            self.assertIn("Run without -O", child.stderr)
            self.assertFalse(output.exists())

    def test_old_two_sided_truncation_counterexample(self):
        value = T_power_on_v(0, 1, 2)
        self.assertTrue(value)
        # Echelon reduction may choose XY rather than Z as the representative.
        self.assertFalse(Quotient(0, 1, 2).reduce(add(value, Z, -1), 2))
        self.assertEqual(T_power_on_v(0, 1, 3), {})

    def test_false_claims_and_explicit_B4_membership_certificate(self):
        Q = Quotient(1, 1, 5)
        B4 = {(a, 4-a, 0): F(1, factorial(a)*factorial(4-a)) for a in range(5)}
        left_x = {(2, 0, 0): F(1,24), (1, 1, 0): F(1,6), (0, 0, 1): F(1,3)}
        left_y = {(2, 0, 0): F(1,4), (1, 1, 0): F(1,6), (0, 2, 0): F(1,24)}
        self.assertEqual(B4, add(mul(left_x, pw(X, 2)), mul(left_y, pw(Y, 2))))
        self.assertFalse(Q.reduce(B4, 4))
        for element, degree in [(mul(Z,X),3), (mul(Z,Y),3), (pw(Z,2),4),
                                (mul(pw(X,2),Y),3)]:
            self.assertTrue(Q.reduce(element, degree))
        self.assertTrue(Q.reduce(pw(add(X,Y),4), 4))

    def test_homogeneous_input_is_not_silently_dropped(self):
        Q = Quotient(0, 1, 3)
        with self.assertRaises(ValueError):
            Q.reduce(Z, 1)
        with self.assertRaises(ValueError):
            Quotient(-1, 0, 3)

    def test_reduced_action_agrees_with_direct_PBW_power(self):
        comparisons = 0
        for p, q in product(range(4), repeat=2):
            N = 2*(p+q)+1
            Q = Quotient(p,q,N)
            values = T_powers(p,q,N)
            for n in range(N+1):
                self.assertEqual(Q.reduce(pw(add(X,Y),n),n), Q.reduce(values[n],n), (p,q,n))
                comparisons += 1
        self.assertEqual(comparisons, 128)

    def test_ideal_generators_are_stable_under_left_X_and_Y(self):
        # Multiplication by X or Y preserves the actual left-ideal relations.
        comparisons = 0
        for p, q in product(range(3), repeat=2):
            Q = Quotient(p,q,9)
            for d in range(9):
                for relation in I_basis(d,p,q):
                    self.assertFalse(Q.reduce(mul(X,relation),d+1), (p,q,d,'X'))
                    self.assertFalse(Q.reduce(mul(Y,relation),d+1), (p,q,d,'Y'))
                    comparisons += 2
        self.assertEqual(comparisons, 1848)

    def test_independent_tensor_model(self):
        # Check Heisenberg relations on every basis vector for p,q <= 3.
        basis_vectors = 0
        for p, q in product(range(4), repeat=2):
            for u, v in product(compositions3(p), compositions3(q)):
                basis_vectors += 1
                state = {u+v: 1}
                xy = poly_op(poly_op(state,PY),PX)
                yx = poly_op(poly_op(state,PX),PY)
                self.assertEqual(add(xy,yx,-1),poly_op(state,PZ))
                for op in [PX,PY]:
                    self.assertEqual(poly_op(poly_op(state,PZ),op),poly_op(poly_op(state,op),PZ))
        self.assertEqual(basis_vectors, 400)
        # Independently test the annihilation and sharpness conditions in 49 cases.
        for p, q in product(range(7), repeat=2):
            state = {(p,0,0,0,0,q): 1}
            for op, count in [(PX,p+1),(PY,q+1)]:
                value = state
                for _ in range(count):
                    value = poly_op(value,op)
                self.assertFalse(value,(p,q,count))
            N = 2*(p+q)+1
            value = state
            for n in range(N+1):
                if n == N-1:
                    self.assertEqual(value, {(0,0,p,q,0,0): factorial(N-1)//2**(p+q)},(p,q))
                if n == N:
                    self.assertFalse(value,(p,q))
                value = poly_op(value,PX+PY)
            value = state
            for n in range(p+q+2):
                if n == p+q:
                    self.assertEqual(value, {(0,0,p,q,0,0): (-1)**p * factorial(p+q)}, (p,q))
                if n == p+q+1:
                    self.assertFalse(value, (p,q))
                value = poly_op(value,PZ)

    def test_characteristic_zero_ring_is_not_a_characteristic_zero_field(self):
        # R = Z x M_2(F_2) has characteristic zero by projection to Z,
        # but 2 is not invertible. This is outside the vector-space contract.
        def mm(a, b):
            return tuple(sum(a[2*i+k]*b[2*k+j] for k in range(2)) % 2
                         for i, j in product(range(2), repeat=2))

        def rm(a, b):
            return (a[0]*b[0], mm(a[1], b[1]))

        def rs(a, b):
            return (a[0]-b[0], tuple((u-v) % 2 for u, v in zip(a[1], b[1])))

        zero = (0, (0, 0, 0, 0))
        unit = (1, (1, 0, 0, 1))
        x = (0, (0, 1, 0, 0))
        y = (0, (0, 0, 1, 0))
        z = rs(rm(x,y), rm(y,x))
        self.assertEqual(rm(x,x), zero)
        self.assertEqual(rm(y,y), zero)
        self.assertEqual(z, (0, (1, 0, 0, 1)))
        for matrix in product(range(2), repeat=4):
            self.assertEqual(rm(z,(0,matrix)), rm((0,matrix),z))
        # In characteristic 2, matrix addition agrees with subtraction.
        t = rs(x,y)
        value = unit
        for _ in range(5):
            value = rm(value,t)
        self.assertEqual(value, t)
        self.assertNotEqual(value, zero)


if __name__ == '__main__':
    unittest.main(verbosity=2)
