load harness

@test "algorithms-gcd" {
  check 'a := 12321; b := 23412324; while ¬ ( a = 0 ) do { if ¬ (b < a) then b := b - a else { tmp := a; a := b; b := tmp } }' \
  '{a → 0, b → 3, tmp → 3}'
}

@test "algorithms-dfs" {
  check 'num_edges := 5; src[0] := 0; dst[0] := 1; src[1] := 1; dst[1] := 2; src[2] := 2; dst[2] := 3; src[3] := 1; dst[3] := 3; src[4] := 3; dst[4] := 4; stack[0] := 0; stack_index := 1; order_index := 0; i := 0; while 0 < stack_index do { node := stack[stack_index-1]; visited[node] := 1; stack_index := stack_index - 1; order[order_index] := node; order_index := order_index + 1; j := 0; while j < num_edges do { if (src[j] = node) ∧ (visited[dst[j]] = 0) then {stack[stack_index] := dst[j]; stack_index := stack_index + 1} else {skip}; j := j + 1}}' \
  '{dst[0] → 1, dst[1] → 2, dst[2] → 3, dst[3] → 3, dst[4] → 4, i → 0, j → 5, node → 2, num_edges → 5, order[0] → 0, order[1] → 1, order[2] → 3, order[3] → 4, order[4] → 2, order_index → 5, src[0] → 0, src[1] → 1, src[2] → 2, src[3] → 1, src[4] → 3, stack[0] → 2, stack[1] → 4, stack_index → 0, visited[0] → 1, visited[1] → 1, visited[2] → 1, visited[3] → 1, visited[4] → 1}'
}
