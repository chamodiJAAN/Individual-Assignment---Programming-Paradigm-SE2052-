# test5_syntax_error.tl
# TEST CASE 5: Invalid syntax missing semicolons and bad structure
# Expected: Syntax error reported by parser

TASK broken_task {
    RUN "/scripts/oops.sh"
    DAILY AT 10:00
    LOG "This will fail"
}

