# test3_dependencies.tl
# TEST CASE 3: Chained task dependencies

TASK fetch_data {
    RUN "/etl/fetch.sh";
    EVERY 6 HOUR;
    LOG "Fetching raw data from source";
    TIMEOUT 120;
}

TASK transform_data {
    RUN "/etl/transform.py";
    AFTER fetch_data;
    DEPENDS ON fetch_data;
    LOG "Transforming and cleaning data";
    RETRY 3;
}

TASK load_data {
    RUN "/etl/load.sh";
    AFTER transform_data;
    DEPENDS ON transform_data;
    LOG "Loading data into warehouse";
    NOTIFY "Data Team: ETL pipeline completed";
}


