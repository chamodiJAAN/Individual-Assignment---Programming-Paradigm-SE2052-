# test9_hourly_failure_condition.tl
# TEST CASE 9: Hourly schedule + failure condition handling

TASK health_check {
    RUN "/scripts/health_check.sh";
    EVERY 1 HOUR;
    TIMEOUT 30;
    RETRY 3;
    LOG "Running system health check";
}

TASK alert_on_failure {
    RUN "/scripts/send_alert.sh";
    AFTER health_check;
    IF (health_check failure) {
        NOTIFY "Ops Team: CRITICAL - Health check failed!";
        LOG "Health check failure alert sent";
    }
}

TASK log_health_report {
    RUN "/scripts/log_health.sh";
    AFTER health_check;
    IF (health_check success) {
        LOG "Health check passed - system nominal";
        NOTIFY "Ops Team: System healthy";
    }
}
