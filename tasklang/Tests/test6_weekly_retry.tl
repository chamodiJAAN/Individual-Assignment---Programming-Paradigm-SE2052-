# test6_weekly_retry.tl
# TEST CASE 6: Weekly schedule with retry and timeout
# Scenario: Weekly report generation every Monday at 08:00

TASK generate_report {
    RUN "/reports/weekly_gen.py";
    WEEKLY MONDAY AT 08:00;
    TIMEOUT 600;
    RETRY 3;
    LOG "Weekly report generation started";
    NOTIFY "Management: Weekly report is ready";
}

TASK archive_logs {
    RUN "/scripts/archive.sh";
    EVERY 7 DAY AT 01:00;
    LOG "Archiving system logs";
    TIMEOUT 180;
}

