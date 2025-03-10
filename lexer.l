%{
#include "y.tab.h"  // Include Bison definitions
#include <stdio.h>
#include <stdlib.h>
#include <string.h>  // Include for strdup
%}

%%

CREATE       { return CREATE; }
TABLE        { return TABLE; }
INT          { return INT; }
FLOAT        { return FLOAT; }
VARCHAR      { return VARCHAR; }
CHAR         { return CHAR; }
DROP         { return DROP; }
TRUNCATE     { return TRUNCATE; }
ALTER        { return ALTER; }
ADD          { return ADD; }
MODIFY       { return MODIFY; }
COLUMN       { return COLUMN; }

[0-9]+       { yylval.ival = atoi(yytext); return NUMBER; }
[A-Za-z_][A-Za-z0-9_]* { 
                yylval.strval = strdup(yytext); 
                return IDENTIFIER; 
}

";"          { return SEMICOLON; }
"("          { return '('; }
")"          { return ')'; }
","          { return ','; }

[ \t\n]+     { /* Ignore whitespace */ }

.            { fprintf(stderr, "Unexpected character: %s\n", yytext); }

%% 

int yywrap() {
    return 1;  // End of input
}
