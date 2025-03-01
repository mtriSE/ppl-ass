grammar BKIT;

program: exp EOF;

exp: term ASSIGN exp | term;

term: factor COMPARE factor | factor;

factor: factor ANDOR operand | operand;

operand: ID | INTLIT | BOOLIT | '(' exp ')';

INTLIT: [0-9]+;

BOOLIT: 'True' | 'False';

ANDOR: 'and' | 'or';

ASSIGN: '+=' | '-=' | '&=' | '|=' | ':=';

COMPARE: '=' | '<>' | '>=' | '<=' | '<' | '>';

ID: [a-z]+;

WS: [ \t\r\n] -> skip;