{
  let keywords = [
    ("if", Parser.IF);
    ("then", Parser.THEN);
    ("else", Parser.ELSE);
    ("let", Parser.LET);
    ("in", Parser.IN);
    ("fun", Parser.FUN);
    ("true", Parser.TRUE);
    ("false", Parser.FALSE);
  ]

  exception EOF
}

rule token = parse
    [' ' '\t' '\n']+ { token lexbuf }
  | eof { raise EOF }
  | '(' { Parser.LPAREN }
  | ')' { Parser.RPAREN }
  | '+' { Parser.PLUS }
  | '-' { Parser.MINUS }
  | '<' { Parser.LT }
  | '=' { Parser.EQ }
  | "->" { Parser.RARROW }
  | ";" { Parser.SEMI }
  | ['0'-'9']+ as lxm { Parser.INT (int_of_string lxm) }
  | ['_' 'a'-'z'] [''' '_' 'a'-'z' 'A'-'Z' '0'-'9']* as id
    { try List.assoc id keywords with Not_found -> Parser.VAR id }
