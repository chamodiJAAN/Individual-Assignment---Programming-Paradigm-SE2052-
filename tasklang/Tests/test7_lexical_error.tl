# test7_lexical_error.tl
# TEST CASE 7: Lexical error unrecognised characters
# Scenario: Task contains illegal characters (@, $, !)

TASK invalid_chars {
    RUN "/scripts/run.sh";
    DAILY AT 08:00;
    LOG @"this is invalid";
    NOTIFY $"also invalid";
}