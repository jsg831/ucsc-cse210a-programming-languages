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
    [("OP", "+")] ++ tokenize (drop 1 str)
  else if next == '*' then
    [("OP", "*")] ++ tokenize (drop 1 str)
  else if next == '%' then
    [("OP", "%")] ++ tokenize (drop 1 str)
  else
    []

data Expr = Val Integer
          | BinaryExpr String Expr Expr
          | Invalid

instance Show Expr where
  show (Val a) = show a
  show (BinaryExpr op a b) = "(" ++ show a ++ op ++ show b ++ ")"
  show (Invalid) = "INVALID"

precedence "+" = 1
precedence "*" = 2
precedence "%" = 2

parse :: [Expr] -> [String] -> [(String, String)] -> Expr

parse exps ops tokens =
  let (ty, text) = head tokens in
  if ty == "$" then
    if (length ops) == 0 then
      head exps
    else
      parse ([(BinaryExpr (head ops) (exps !! 1) (exps !! 0))] ++ (drop 2 exps)) (drop 1 ops) tokens
  else if ty == "NUM" then
    parse ([(Val (read text :: Integer))] ++ exps) ops (drop 1 tokens)
    -- Val (read text :: Integer)
  else if ty == "OP" then
    if (length ops) == 0 then
      parse exps [text] (drop 1 tokens)
    else if precedence (head ops) >= precedence text then
      parse ([(BinaryExpr (head ops) (exps !! 1) (exps !! 0))] ++ (drop 2 exps)) (drop 1 ops) tokens
    else
      parse exps ([text] ++ ops) (drop 1 tokens)
  else
    Invalid

eval :: Expr -> Integer
eval (Val a) = a
eval (BinaryExpr "+" a b) = eval a + eval b
eval (BinaryExpr "*" a b) = eval a * eval b
eval (BinaryExpr "%" a b) = eval a `mod` eval b

main :: IO ()
main = do
  line <- getLine
  let tokens = tokenize line
  -- print tokens
  let ast = parse [] [] tokens
  -- print ast
  let val = eval ast
  print val
