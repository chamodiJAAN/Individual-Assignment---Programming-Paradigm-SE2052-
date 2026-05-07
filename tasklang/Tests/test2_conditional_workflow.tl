# test2_conditional_workflow.tl
# TEST CASE 2: Multi-step workflow with conditional execution

TASK run_tests {
    RUN "pytest /app/tests/";
    DAILY AT 22:00;
    LOG "Running automated test suite";
    TIMEOUT 300;
    RETRY 2;
}

TASK deploy_app {
    RUN "/scripts/deploy.sh production";
    AFTER run_tests;
    IF (run_tests success) {
        LOG "Tests passed deploying to production";
        NOTIFY "DevOps: Deployment started";
    }
}

TASK alert_team {
    RUN "/scripts/notify_slack.sh";
    AFTER run_tests;
    IF (run_tests failure) {
        NOTIFY "Dev Team: Tests FAILED deployment cancelled";
        LOG "Deployment aborted due to test failure";
    }
}

