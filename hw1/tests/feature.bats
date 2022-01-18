load harness

@test "feature-1" {
  check '13 % -3 + 3 * 8 % 5 * 7 % 5 + 2' '3'
}

@test "feature-2" {
  check '-2 % -3' '-2'
}

@test "feature-3" {
  check '-2 % 3' '1'
}

@test "feature-4" {
  check '100 % -29 % -7' '-2'
}

@test "feature-5" {
  check '29 % 2 * 23 % 3 + 19 % 5 + 17 % 7 * 13 % 11' '12'
}