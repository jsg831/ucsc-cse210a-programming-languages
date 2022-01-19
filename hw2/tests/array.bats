load harness

@test "array-assign" {
  check 'a[0] := 1' '{a[0] → 1}'
}

@test "array-expression" {
  check 'a[0] := 2; a[1] := 3; a[2] := a[0] * a[1]' '{a[0] → 2, a[1] → 3, a[2] → 6}'
}

@test "array-recursive" {
  check 'a[0] := 3; a[a[0]] := 1' '{a[0] → 3, a[3] → 1}'
}

@test "array-fibonacci" {
  check 'a[0] := 0; a[1] := 1; i := 2; while i < 10 do { a[i] := a[i-1] + a[i-2]; i := i + 1 }' \
    '{a[0] → 0, a[1] → 1, a[2] → 1, a[3] → 2, a[4] → 3, a[5] → 5, a[6] → 8, a[7] → 13, a[8] → 21, a[9] → 34, i → 10}'
}

@test "array-factorial" {
  check 'while i < 6 do { j := 1; a[i] := 1; while j < (i + 1) do { a[i] := a[i] * j; j := j + 1 }; i := i + 1 }' \
    '{a[0] → 1, a[1] → 1, a[2] → 2, a[3] → 6, a[4] → 24, a[5] → 120, i → 6, j → 6}'
}
