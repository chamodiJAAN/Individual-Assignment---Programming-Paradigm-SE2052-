# test10_missing_body_error.tl
# TEST CASE 10: Syntax error missing closing brace

TASK missing_brace {
    RUN "/scripts/run.sh";
    DAILY AT 09:00;
    LOG "This task never closes"

TASK another_task {
    RUN "/scripts/another.sh";
    EVERY DAY AT 10:00;
   }
}

