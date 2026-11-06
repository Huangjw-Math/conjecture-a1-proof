import ConjectureA1

namespace ConjectureA1

/-- Finite ring certificate; the right factors are exactly the vector annihilators. -/
lemma two_mul_add_pow_five {R : Type*} [Ring R] (x y : R)
    (hX : Commute x (ad x y)) (hY : Commute y (ad x y)) :
    2 * (x + y) ^ 5 =
      ((2) * (x * x * x) +
        (12) * (x * x * y) +
        (-4) * (x * y * x) +
        (5) * (x * y * y) +
        (2) * (y * x * x) +
        (20) * (y * x * y) +
        (-10) * (y * y * x) +
        (5) * (y * y * y)) * (x ^ 2) +
      ((5) * (x * x * x) +
        (2) * (x * x * y) +
        (-4) * (x * y * x) +
        (2) * (x * y * y) +
        (17) * (y * x * x) +
        (-4) * (y * x * y) +
        (12) * (y * y * x) +
        (2) * (y * y * y)) * (y ^ 2) := by
  have hRX : x * ad x y - ad x y * x = 0 := sub_eq_zero.mpr hX.eq
  have hRY : y * ad x y - ad x y * y = 0 := sub_eq_zero.mpr hY.eq
  have cert : 2 * (x + y) ^ 5 =
      ((2) * (x * x * x) +
        (12) * (x * x * y) +
        (-4) * (x * y * x) +
        (5) * (x * y * y) +
        (2) * (y * x * x) +
        (20) * (y * x * y) +
        (-10) * (y * y * x) +
        (5) * (y * y * y)) * (x ^ 2) +
      ((5) * (x * x * x) +
        (2) * (x * x * y) +
        (-4) * (x * y * x) +
        (2) * (x * y * y) +
        (17) * (y * x * x) +
        (-4) * (y * x * y) +
        (12) * (y * y * x) +
        (2) * (y * y * y)) * (y ^ 2) +
        ((-4) * (((x * ad x y - ad x y * x)) * (x * y)) +
        (2) * (((x * ad x y - ad x y * x)) * (y * x)) +
        (6) * ((x) * ((x * ad x y - ad x y * x)) * (x)) +
        (-3) * ((x) * ((x * ad x y - ad x y * x)) * (y)) +
        (12) * ((y) * ((x * ad x y - ad x y * x)) * (x)) +
        (-15) * ((y) * ((x * ad x y - ad x y * x)) * (y)) +
        (2) * ((x * x) * ((x * ad x y - ad x y * x))) +
        (-3) * ((x * y) * ((x * ad x y - ad x y * x))) +
        (6) * ((y * x) * ((x * ad x y - ad x y * x))) +
        (3) * ((y * y) * ((x * ad x y - ad x y * x))) +
        (-14) * (((y * ad x y - ad x y * y)) * (x * y)) +
        (4) * (((y * ad x y - ad x y * y)) * (y * x)) +
        (6) * ((y) * ((y * ad x y - ad x y * y)) * (x)) +
        (-6) * ((y) * ((y * ad x y - ad x y * y)) * (y)) +
        (-6) * ((x * y) * ((y * ad x y - ad x y * y))) +
        (-2) * ((y * y) * ((y * ad x y - ad x y * y)))) := by
    unfold ad
    noncomm_ring
  rw [hRX, hRY] at cert
  simpa only [mul_zero, zero_mul, add_zero] using cert

/-- Finite ring certificate; the right factors are exactly the vector annihilators. -/
lemma two_mul_add_pow_three {R : Type*} [Ring R] (x y : R)
    (hX : Commute x (ad x y)) (hY : Commute y (ad x y)) :
    2 * (x + y) ^ 3 =
      ((2) * (x) +
        (3) * (y)) * (x ^ 2) +
      ((3) * (x * x) +
        (6) * (y * x) +
        (2) * (y * y)) * (y ^ 1) := by
  have hRX : x * ad x y - ad x y * x = 0 := sub_eq_zero.mpr hX.eq
  have hRY : y * ad x y - ad x y * y = 0 := sub_eq_zero.mpr hY.eq
  have cert : 2 * (x + y) ^ 3 =
      ((2) * (x) +
        (3) * (y)) * (x ^ 2) +
      ((3) * (x * x) +
        (6) * (y * x) +
        (2) * (y * y)) * (y ^ 1) +
        ((-1) * (((x * ad x y - ad x y * x))) +
        (-2) * (((y * ad x y - ad x y * y)))) := by
    unfold ad
    noncomm_ring
  rw [hRX, hRY] at cert
  simpa only [mul_zero, zero_mul, add_zero] using cert

end ConjectureA1
