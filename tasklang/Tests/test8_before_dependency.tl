# test8_before_dependency.tl
# TEST CASE 8: BEFORE dependency keyword

TASK validate_input {
    RUN "/scripts/validate.sh";
    DAILY AT 05:00;
    LOG "Validating input data";
    TIMEOUT 60;
}

TASK preprocess_data {
    RUN "/scripts/preprocess.py";
    BEFORE process_data;
    LOG "Pre-processing raw data";
    RETRY 2;
}

TASK process_data {
    RUN "/scripts/process.py";
    AFTER validate_input;
    DEPENDS ON validate_input;
    DAILY AT 05:30;
    LOG "Main processing started";
    TIMEOUT 300;
    NOTIFY "Pipeline Team: Processing complete";
}