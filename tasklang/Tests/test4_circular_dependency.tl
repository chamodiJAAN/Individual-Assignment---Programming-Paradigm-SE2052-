# test4_circular_dependency.tl
# TEST CASE 4: Circular dependency semantic error
# Scenario: Task A depends on B, B depends on C, C depends on A

TASK task_A {
    RUN "/scripts/a.sh";
    DEPENDS ON task_C;
    DAILY AT 09:00;
}

TASK task_B {
    RUN "/scripts/b.sh";
    DEPENDS ON task_A;
    DAILY AT 09:05;
}

TASK task_C {
    RUN "/scripts/c.sh";
    DEPENDS ON task_B;
    DAILY AT 09:10;
}

