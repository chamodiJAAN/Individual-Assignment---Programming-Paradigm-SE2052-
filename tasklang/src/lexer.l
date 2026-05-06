%{
/*
 * lexer.l - Lexical Analyzer for TaskLang++
 * IT24104006 - Jananjana J.W.C
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.tab.h"

int line_number = 1;
%}

DIGIT       [0-9]
LETTER      [a-zA-Z]
ID          {LETTER}({LETTER}|{DIGIT}|_)*
INTEGER     {DIGIT}+
TIME        {DIGIT}{2}:{DIGIT}{2}
STRING      \"([^\"\n])*\"
WHITESPACE  [ \t\r]+
COMMENT     #[^\n]*

%%

"TASK"      { return TASK; }
"RUN"       { return RUN; }
"EVERY"     { return EVERY; }
"DAY"       { return DAY; }
"WEEK"      { return WEEK; }
"HOUR"      { return HOUR; }
"MINUTE"    { return MINUTE; }
"AT"        { return AT; }
"AFTER"     { return AFTER; }
"BEFORE"    { return BEFORE; }
"DEPENDS"   { return DEPENDS; }
"ON"        { return ON; }
"IF"        { return IF; }
"success"   { return SUCCESS; }
"failure"   { return FAILURE; }
"SCHEDULE"  { return SCHEDULE; }
"END"       { return END; }
"DAILY"     { return DAILY; }
"WEEKLY"    { return WEEKLY; }
"MONDAY"    { return WEEKDAY; }
"TUESDAY"   { return WEEKDAY; }
"WEDNESDAY" { return WEEKDAY; }
"THURSDAY"  { return WEEKDAY; }
"FRIDAY"    { return WEEKDAY; }
"SATURDAY"  { return WEEKDAY; }
"SUNDAY"    { return WEEKDAY; }
"NOTIFY"    { return NOTIFY; }
"LOG"       { return LOG; }
"RETRY"     { return RETRY; }
"TIMEOUT"   { return TIMEOUT; }

{TIME}      { yylval.str = strdup(yytext); return TIME_LIT; }
{INTEGER}   { yylval.ival = atoi(yytext); return INTEGER_LIT; }

{STRING}    {
                yytext[yyleng - 1] = '\0';
                yylval.str = strdup(yytext + 1);
                return STRING_LIT;
            }

{ID}        { yylval.str = strdup(yytext); return IDENTIFIER; }

"{"         { return '{'; }
"}"         { return '}'; }
"("         { return '('; }
")"         { return ')'; }
","         { return ','; }
";"         { return ';'; }
":"         { return ':'; }
"="         { return '='; }

{WHITESPACE} { /* ignore */ }
{COMMENT}    { /* ignore */ }
\n           { line_number++; }

.           {
                fprintf(stderr,
                    "[Lexical Error] Line %d: Unrecognized character '%s'\n",
                    line_number, yytext);
            }

%%

int yywrap(void) { return 1; }
