# Makefile for TaskLang++

CC     = gcc
CFLAGS = -Wall -g
TARGET = tasklang
LIBS   = -lfl

.PHONY: all test clean

all: $(TARGET)

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

$(TARGET): parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $(TARGET) parser.tab.c lex.yy.c $(LIBS)
	@echo "Build successful! Binary: ./$(TARGET)"

test: $(TARGET)
	@echo ""; echo "===== TEST 1: Simple Daily Schedule (valid) ====="
	./$(TARGET) ../Tests/test1_daily_schedule.tl
	@echo ""; echo "===== TEST 2: Conditional Workflow (valid) ====="
	./$(TARGET) ../Tests/test2_conditional_workflow.tl
	@echo ""; echo "===== TEST 3: Task Dependencies Chain (valid) ====="
	./$(TARGET) ../Tests/test3_dependencies.tl
	@echo ""; echo "===== TEST 4: Circular Dependency (semantic error) ====="
	./$(TARGET) ../Tests/test4_circular_dependency.tl
	@echo ""; echo "===== TEST 5: Syntax Error (missing semicolons) ====="
	./$(TARGET) ../Tests/test5_syntax_error.tl
	@echo ""; echo "===== TEST 6: Weekly Schedule + Retry/Timeout (valid) ====="
	./$(TARGET) ../Tests/test6_weekly_retry.tl
    @echo ""; echo "===== TEST 7: Lexical Error (unrecognised characters) ====="
	./$(TARGET) ../Tests/test7_lexical_error.tl
	@echo ""; echo "===== TEST 8: BEFORE Dependency (valid) ====="
	./$(TARGET) ../Tests/test8_before_dependency.tl
	@echo ""; echo "===== TEST 9: Hourly + Failure Condition (valid) ====="
	./$(TARGET) ../Tests/test9_hourly_failure_condition.tl
	@echo ""; echo "===== TEST 10: Missing Closing Brace (syntax error) ====="
	./$(TARGET) ../Tests/test10_missing_body_error.tl

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h $(TARGET)
	@echo "Cleaned."

