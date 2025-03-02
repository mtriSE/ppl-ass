grammar BKIT;

program: decllist EOF;

decllist: declprime |;
declprime: decl declprime | decl;
decl: const_decl | var_decl | type_decl | func_decl;

// ! DECLARATION___________________________________________
typ: primitive_typ | composite_typ | array_typ;
primitive_typ: INT | FLOAT | BOOLEAN | STRING;
composite_typ: ID; // struct or interface name
array_typ: list_dim (primitive_typ | composite_typ);
list_dim: dim list_dim | dim; //* non-null list: [1][2][a]...
dim:
	LSB INT_LIT RSB // [1] 
	| LSB ID RSB; // [CONST], [A], ...

// ! constant declaration: 
const_decl: CONST ID EQUAL expr SEMI; // 

// ! variable declaration: TODO: separate non-initialized var and initialized var 
var_decl: (var_decl_typ_init | var_decl_init | var_decl_typ) SEMI;
var_decl_typ_init: VAR ID typ EQUAL expr;
var_decl_init: VAR ID EQUAL expr;
var_decl_typ: VAR ID typ;

// ! type declaration:
type_decl: struct_decl | interface_decl;
//* struct declaration:
struct_decl: TYPE ID STRUCT field_section SEMI?;
field_section: LCB field_decl_list RCB; // toi thieu 1 field
field_decl_list: field_decl_prime |;
field_decl_prime: field_decl field_decl_prime | field_decl;
field_decl: ID typ SEMI;

//* interface declaration:
interface_decl: TYPE ID INTERFACE method_section SEMI?;
method_section: LCB method_decl_list RCB;
method_decl_list: method_decl_prime |;
method_decl_prime: method_decl method_decl_list | method_decl;
method_decl: ID LP param_list RP typ? SEMI;
param_list: param_prime |;
param_prime: param_decl COMMA param_prime | param_decl;
param_decl: ID typ | ID;

// ! function declaration:
func_decl: (func | method) SEMI?;
func: FUNC ID LP param_list RP typ? block;
method: FUNC receiver ID LP param_list RP typ? block;
receiver: LP ID composite_typ RP;

// ! EXPRESSION____________________________________________ 
expr: expr OR expr1 | expr1;
expr1: expr1 AND expr2 | expr2;
expr2: expr2 (SAME | DIFF | LT | LTE | GT | GTE) expr3 | expr3;
expr3: expr3 (ADD | SUB) expr4 | expr4;
expr4: expr4 (MUL | DIV | MOD) expr5 | expr5;
expr5: (NOT | SUB) expr5 | expr6;
expr6:
	expr6 LSB expr RSB
	| expr6 DOT ID // access struct field
	| expr6 DOT ID LP arg_list RP // access method aka method call experssion
	| expr7;
expr7: ID | literal | func_call_expr | prior_expr;

literal: basic_lit | composite_lit;
basic_lit: INT_LIT | FLOAT_LIT | STR_LIT | BOOL_LIT;
composite_lit: array_lit | struct_lit; // todo

func_call_expr: ID LP arg_list RP;
arg_list: arg_prime |;
arg_prime: expr COMMA arg_prime | expr;
prior_expr: LP expr RP;

// ! STATEMENT_____________________________________________
block: LCB stmt_prime RCB;
// stmt_list: stmt_prime |;
stmt_prime: stmt stmt_prime | stmt;
stmt:
	assignment_stmt
	| decl
	| if_stmt
	| for_stmt
	| break_stmt
	| continue_stmt
	| call_stmt
	| return_stmt; // | block

// * Assignment statement
assignment_stmt: lhs assign_operator rhs SEMI;
assign_operator:
	ASSIGN
	| ADD_EQ
	| SUB_EQ
	| MUL_EQ
	| DIV_EQ
	| MOD_EQ;
lhs:
	ID // scalar variable
	| lhs LSB expr RSB // array element access
	| lhs DOT ID; // struct field access
rhs: expr;

if_stmt: if_clause elif_list else_clause? SEMI;
// moi clause luon ket thuc bang block -> khong can 
if_clause: IF LP expr RP block;
elif_list: elif_clause elif_list |;
elif_clause: ELSE IF LP expr RP block;
else_clause: ELSE block;

// * Loop statement
for_stmt: (basic_loop | init_cond_upd_loop | range_loop) SEMI;
basic_loop:
	FOR expr // __
	block;

init_cond_upd_loop:
	FOR initialization SEMI expr SEMI update // __
	block; // expr is condition
initialization:
	ID assign_operator expr
	| var_decl_typ_init
	| var_decl_init;
update: ID assign_operator expr;

range_loop:
	FOR ID COMMA ID ASSIGN RANGE expr // __
	block;

// * break, continue, return statement
break_stmt: BREAK SEMI;
continue_stmt: CONTINUE SEMI;
return_stmt: RETURN expr? SEMI;

// * call statement
call_stmt: func_call_stmt | method_call_stmt;
func_call_stmt: func_call_expr SEMI;
method_call_stmt: instance_expr DOT func_call_expr SEMI; // todo
instance_expr: expr;

// ! LITERALS_____________________________________________
array_lit: array_typ array_ele_list;
array_ele_list: LCB array_ele_prime? RCB;
array_ele_prime:
	array_ele_value COMMA array_ele_prime
	| array_ele_value;
array_ele_value:
	ID // constant
	| basic_lit
	| struct_lit
	| array_ele_list;
struct_lit:
	ID // struct's name
	struct_ele_list;
struct_ele_list: LCB struct_ele_prime? RCB;
struct_ele_prime:
	struct_ele_value COMMA struct_ele_prime
	| struct_ele_value;
struct_ele_value: ID COLON expr;

fragment LETTER: [a-z] | [A-Z];
fragment UNDERSCORE: '_';
fragment DOUBLEQUOTE: ["];
fragment SINGLEQUOTE: ['];
fragment DIGIT: [0-9];
fragment ZERO: '0';
fragment NON_0: [1-9];
fragment ESCAPE: '\\n' | '\\t' | '\\r' | '\\"' | '\\\\';
fragment ESCAPE_ERR: '\\' ~[ntr"\\];
fragment BIN_DIGIT: [01];
fragment OCT_DIGIT: [0-7];
fragment HEX_DIGIT: DIGIT | [A-F] | [a-f];
fragment INTEGER_PART: DIGIT+;
fragment FRACTIONAL_PART: DIGIT+;
fragment EXPONENT_PART: [eE][+-]? DIGIT+; //! 'an integer' 
fragment STR_CHAR: ~["\\\n];

// ! KEYWORDS_____________________________________________
IF: 'if';
ELSE: 'else';
FOR: 'for';
RETURN: 'return';
FUNC: 'func';
TYPE: 'type';
STRUCT: 'struct';
INTERFACE: 'interface';
STRING: 'string';
INT: 'int';
FLOAT: 'float';
BOOLEAN: 'boolean';
CONST: 'const';
VAR: 'var';
CONTINUE: 'continue';
BREAK: 'break';
RANGE: 'range';
fragment NIL: 'nil';
fragment TRUE: 'true';
fragment FALSE: 'false';

LINE_COMMENT: '//' (~[\r\n])* -> skip;
BLOCK_COMMENT: '/*' (BLOCK_COMMENT | .)*? '*/' -> skip;

// ! LITERALS_____________________________________________
FLOAT_LIT: INTEGER_PART '.' FRACTIONAL_PART? EXPONENT_PART?;

INT_LIT: DEC_LIT | BIN_LIT | OCT_LIT | HEX_LIT;
DEC_LIT: ZERO | NON_0 DIGIT*;
BIN_LIT: ('0B' | '0b') BIN_DIGIT+ {self.text = str(int(self.text,  2))} ;
OCT_LIT: ('0o' | '0O') OCT_DIGIT+ {self.text = str(int(self.text,  8))} ;
HEX_LIT: ('0x' | '0X') HEX_DIGIT+ {self.text = str(int(self.text, 16))} ;

STR_LIT: DOUBLEQUOTE (STR_CHAR | ESCAPE)* DOUBLEQUOTE;
BOOL_LIT: TRUE | FALSE;
NIL_LIT: NIL;

// ! OPERATORS_____________________________________________ 

// ! arithmetic operators:
ADD: [+]; // int/float/string
SUB: [-]; // int/float
MUL: [*]; // int/float
DIV: [/]; // int/float
MOD: [%]; // int -> int

// ! relational operators:
SAME: '=='; // int/float/string
DIFF: '!='; // int/float/string
LT: '<'; // int/float/string
GT: '>'; // int/float/string
LTE: '<='; // int/float/string
GTE: '>='; // int/float/string

// ! boolean operators:
AND: '&&'; // boolean
OR: '||'; // boolean
NOT: '!'; // boolean

// TODO: for assignment statement
ASSIGN: ':=';
EQUAL: '=';
ADD_EQ: '+=';
SUB_EQ: '-=';
MUL_EQ: '*=';
DIV_EQ: '/=';
MOD_EQ: '%=';
DOT: '.';

// ! SEPARATORS_____________________________________________
LP: '(';
RP: ')';
LCB: '{';
RCB: '}';
LSB: '[';
RSB: ']';
COMMA: ',';
SEMI:
	';'
	| '\r'? '\n' {
self.newline_handler()
};
COLON: ':';

ID: (LETTER | UNDERSCORE) (LETTER | DIGIT | UNDERSCORE)*;

WS: [ \t\f\r]+ -> skip; // skip spaces, tabs 