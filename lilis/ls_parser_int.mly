
%token EOF
%token <string> NAME
%token EQUAL QMARK
%token LACCO RACCO
%token AXIOM RULE DEF
%token COMMA

%start main
%type <Ls_type.AST.lsystem list> main

%start defs
%type <Ls_type.AST.def list> defs

%%

main:
  ls = nonempty_list(lsystem) EOF
  { ls }

lsystem:
  name=IDENT LACCO
  definitions=def*
  axiom=axiom
  rules=rule*
  RACCO
  { let open Ls_type.AST in {name ; definitions ; axiom ; rules} }

axiom:
  AXIOM EQUAL ol=token(args)+ { ol }

defs:
    def=def* EOF { def }

def:
    DEF toks = token(opt_vars)+ l = loption(def_rhs)
  { (toks,l) }

def_rhs: EQUAL l = token(args)* { l }

rule:
  RULE tok=token(vars) EQUAL rhs=token(args)*
  { let (lhs,vars) = tok in Ls_type.({lhs;vars;rhs}) }

token(arg):
  n = ls_token a = loption(arg)
  { (n,a) }

vars:
  LPAREN v=separated_list(COMMA,IDENT) RPAREN
  { v }

opt_vars:
  LPAREN v=opt_vars2 RPAREN { v }

opt_vars2:
  | v=opt_var { [v] }
  | i=IDENT { [(i,None)] }
  | v=opt_var COMMA l=separated_nonempty_list(COMMA,opt_var) { v :: l }
  | i=IDENT COMMA l=opt_vars2
     { (i,None) :: l }

opt_var: i=IDENT QMARK a=arit { (i, Some a) }


args:
  LPAREN a=separated_list(COMMA, arit) RPAREN
  { a }


ls_token:
  | n=NAME | n=IDENT { n }
  | PLUS  { "+" } | MINUS { "-" }
  | TIMES { "*" } | DIV   { "/" }
  | POW   { "^" }
