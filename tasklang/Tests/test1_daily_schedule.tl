# test1_daily_schedule.tl
# TEST CASE 1: Simple daily recurring task
# Scenario: A daily database backup task scheduled at 02:00 AM

TASK daily_backup {
    RUN "/scripts/backup_db.sh";
    DAILY AT 02:00;
    LOG "Daily backup started";
    NOTIFY "DBA Team: Backup completed";
}

