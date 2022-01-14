import Data.Char

find_number :: String -> String
find_number str = 
  if str == "" then
    ""
  else if isDigit (head str) then
    [(head str)] ++ (find_number (drop 1 str))
  else
    ""

tokenize :: String -> [(String, String)]
tokenize str = 
  let next = (head str) in
  if str == "" then
    [("$", "")]
  else if next == ' ' then
    tokenize (drop 1 str)
  else if next == '-' then
    let num = (find_number (drop 1 str)) in
      [("NUM", "-" ++ num)] ++ tokenize (drop ((length (num))+1) str)
  else if isDigit (head str) then
    let num = (find_number str) in
      [("NUM", num)] ++ tokenize (drop (length num) str)
  else if next == '+' then
    [("PLUS", "+")] ++ tokenize (drop 1 str)
  else if next == '*' then
    [("MULT", "*")] ++ tokenize (drop 1 str)
  else
    []

data Expr = Val Integer
          | Sum Expr Expr
          | Mul Expr Expr
          | Invalid

instance Show Expr where
  show (Val a) = show a
  show (Sum a b) = "(" ++ show a ++ "+" ++ show b ++ ")"
  show (Mul a b) = "(" ++ show a ++ "*" ++ show b ++ ")"
  show (Invalid) = "INVALID"

parse :: [Expr] -> [String] -> [(String, String)] -> Expr

parse exps ops tokens =
  let (ty, text) = head tokens in
  if ty == "$" then
    if (length ops) == 0 then
      head exps
    else if head ops == "PLUS" then
      parse ([(Sum (exps !! 1) (exps !! 0))] ++ (drop 2 exps)) (drop 1 ops) tokens
    else if head ops == "MULT" then
      parse ([(Mul (exps !! 1) (exps !! 0))] ++ (drop 2 exps)) (drop 1 ops) tokens
    else
      Invalid
  else if ty == "NUM" then
    parse ([(Val (read text :: Integer))] ++ exps) ops (drop 1 tokens)
    -- Val (read text :: Integer)
  else if ty == "PLUS" then
    if (length ops) == 0 then
      parse exps ["PLUS"] (drop 1 tokens)
    else if (head ops) == "PLUS" then
      parse ([(Sum (exps !! 1) (exps !! 0))] ++ (drop 2 exps)) (drop 1 ops) tokens
    else if (head ops) == "MULT" then
      parse ([(Mul (exps !! 1) (exps !! 0))] ++ (drop 2 exps)) (drop 1 ops) tokens
    else
      Invalid
  else if ty == "MULT" then
    if (length ops) == 0 then
      parse exps ["MULT"] (drop 1 tokens)
    else if (head ops) == "PLUS" then
      parse exps (["MULT"] ++ ops) (drop 1 tokens)
    else if (head ops) == "MULT" then
      parse ([(Mul (exps !! 1) (exps !! 0))] ++ (drop 2 exps)) (drop 1 ops) tokens
    else
      Invalid
  else
    Invalid

eval :: Expr -> Integer
eval (Val a) = a
eval (Sum a b) = eval a + eval b
eval (Mul a b) = eval a * eval b

main :: IO ()
main = do
  line <- getLine
  let tokens = tokenize line
  -- print tokens
  let ast = parse [] [] tokens
  -- print ast
  let val = eval ast
  print val
