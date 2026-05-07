%{
/*
 parser.y - Parser for TaskLang++
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line_number;
extern FILE *yyin;

#define MAX_TASKS 64
char *task_names[MAX_TASKS];
int   task_deps[MAX_TASKS][MAX_TASKS];
int   task_count = 0;
char *current_task = NULL; 

int  find_or_add_task(const char *name);
void record_dependency(const char *dep_target);
int  detect_cycle(int node, int *visited, int *rec_stack);
void check_circular_dependencies(void);
void yyerror(const char *msg);
int  yylex(void);
%}

%union {
    int   ival;
    char *str;
}
%token TASK RUN EVERY DAY WEEK HOUR MINUTE AT AFTER BEFORE
%token DEPENDS ON IF SUCCESS FAILURE SCHEDULE END
%token DAILY WEEKLY WEEKDAY NOTIFY LOG RETRY TIMEOUT

%token <str>  IDENTIFIER
%token <str>  STRING_LIT
%token <str>  TIME_LIT
%token <ival> INTEGER_LIT

%type <str> task_name condition_expr

%left IF
%left AFTER BEFORE DEPENDS

%start program

%%

program
    : /* empty */
        { printf("[Parser] Empty program.\n"); }
    | task_list
        {
            printf("[Parser] Program parsed successfully.\n");
            check_circular_dependencies();
        }
    ;

task_list
    : task_definition
    | task_list task_definition
    ;



task_definition
    : TASK task_name
        {
            current_task = $2;
            find_or_add_task($2);
            printf("[Parser] Task '%s' parsing body...\n", $2);
        }
      '{' task_body '}'
        {
            printf("[Parser] Task '%s' defined successfully.\n", current_task);
            free(current_task);
            current_task = NULL;
        }
    ;

task_name
    : IDENTIFIER    { $$ = $1; }
    ;

task_body
    : task_statement
    | task_body task_statement
    ;

task_statement
    : run_statement
    | schedule_statement
    | dependency_statement
    | condition_statement
    | notify_statement
    | retry_statement
    | timeout_statement
    | log_statement
    ;

run_statement
    : RUN STRING_LIT ';'
        { printf("[Parser]   RUN: \"%s\"\n", $2); free($2); }
    ;

schedule_statement
    : EVERY time_unit ';'
        { printf("[Parser]   Schedule: recurring.\n"); }
    | EVERY time_unit AT TIME_LIT ';'
        { printf("[Parser]   Schedule: recurring at %s.\n", $4); free($4); }
    | AT TIME_LIT ';'
        { printf("[Parser]   Schedule: one-time at %s.\n", $2); free($2); }
    | DAILY ';'
        { printf("[Parser]   Schedule: daily.\n"); }
    | DAILY AT TIME_LIT ';'
        { printf("[Parser]   Schedule: daily at %s.\n", $3); free($3); }
    | WEEKLY WEEKDAY ';'
        { printf("[Parser]   Schedule: weekly.\n"); }
    | WEEKLY WEEKDAY AT TIME_LIT ';'
        { printf("[Parser]   Schedule: weekly at %s.\n", $4); free($4); }
    ;

time_unit
    : INTEGER_LIT DAY    { printf("[Parser]   Time unit: %d day(s)\n", $1); }
    | INTEGER_LIT WEEK   { printf("[Parser]   Time unit: %d week(s)\n", $1); }
    | INTEGER_LIT HOUR   { printf("[Parser]   Time unit: %d hour(s)\n", $1); }
    | INTEGER_LIT MINUTE { printf("[Parser]   Time unit: %d minute(s)\n", $1); }
    | DAY                { printf("[Parser]   Time unit: 1 day\n"); }
    | WEEK               { printf("[Parser]   Time unit: 1 week\n"); }
    | HOUR               { printf("[Parser]   Time unit: 1 hour\n"); }
    | MINUTE             { printf("[Parser]   Time unit: 1 minute\n"); }
    ;

dependency_statement
    : AFTER IDENTIFIER ';'
        {
            printf("[Parser]   AFTER task '%s'\n", $2);
            record_dependency($2);
            free($2);
        }
    | BEFORE IDENTIFIER ';'
        {
            printf("[Parser]   BEFORE task '%s'\n", $2);
            free($2);
        }
    | DEPENDS ON IDENTIFIER ';'
        {
            printf("[Parser]   DEPENDS ON task '%s'\n", $3);
            record_dependency($3);
            free($3);
        }
    ;

condition_statement
    : IF '(' condition_expr ')' '{' task_body '}'
        {
            printf("[Parser]   Conditional block (IF %s) parsed.\n", $3);
            free($3);
        }
    ;

condition_expr
    : IDENTIFIER SUCCESS
        {
            char *buf = malloc(strlen($1) + 20);
            sprintf(buf, "%s == success", $1);
            $$ = buf;
            free($1);
        }
    | IDENTIFIER FAILURE
        {
            char *buf = malloc(strlen($1) + 20);
            sprintf(buf, "%s == failure", $1);
            $$ = buf;
            free($1);
        }
    ;

notify_statement
    : NOTIFY STRING_LIT ';'
        { printf("[Parser]   NOTIFY: \"%s\"\n", $2); free($2); }
    ;

log_statement
    : LOG STRING_LIT ';'
        { printf("[Parser]   LOG: \"%s\"\n", $2); free($2); }
    ;

retry_statement
    : RETRY INTEGER_LIT ';'
        { printf("[Parser]   RETRY: %d times.\n", $2); }
    ;

timeout_statement
    : TIMEOUT INTEGER_LIT ';'
        { printf("[Parser]   TIMEOUT: %d seconds.\n", $2); }
    ;

%%

int find_or_add_task(const char *name) {
    for (int i = 0; i < task_count; i++)
        if (strcmp(task_names[i], name) == 0) return i;
    if (task_count < MAX_TASKS) {
        task_names[task_count] = strdup(name);
        return task_count++;
    }
    return -1;
}

void record_dependency(const char *dep_target) {
    if (!current_task) return;
    int from = find_or_add_task(current_task);
    int to   = find_or_add_task(dep_target);
    if (from >= 0 && to >= 0) task_deps[from][to] = 1;
}

int detect_cycle(int node, int *visited, int *rec_stack) {
    visited[node] = 1;
    rec_stack[node] = 1;
    for (int i = 0; i < task_count; i++) {
        if (task_deps[node][i]) {
            if (!visited[i] && detect_cycle(i, visited, rec_stack)) return 1;
            else if (rec_stack[i]) return 1;
        }
    }
    rec_stack[node] = 0;
    return 0;
}

void check_circular_dependencies(void) {
    int visited[MAX_TASKS]   = {0};
    int rec_stack[MAX_TASKS] = {0};
    int found = 0;
    for (int i = 0; i < task_count; i++) {
        if (!visited[i] && detect_cycle(i, visited, rec_stack)) {
            fprintf(stderr,
                "[Semantic Error] Circular dependency detected involving task '%s'!\n",
                task_names[i]);
            found = 1;
        }
    }
    if (!found && task_count > 0)
        printf("[Parser] Dependency graph valid no circular dependencies.\n");
}

void yyerror(const char *msg) {
    fprintf(stderr, "[Syntax Error] Line %d: %s\n", line_number, msg);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) { fprintf(stderr, "Cannot open '%s'\n", argv[1]); return 1; }
        printf("=== TaskLang++ Parser ===\nFile: %s\n\n", argv[1]);
    } else {
        printf("=== TaskLang++ Parser ===\nStdin input...\n\n");
    }
    int result = yyparse();
    if (argc > 1) fclose(yyin);
    if (result == 0)
        printf("\n[Result] Parsing SUCCESSFUL. Valid TaskLang++ program.\n");
    else
        printf("\n[Result] Parsing FAILED. Fix the errors above.\n");
    return result;
}









































































