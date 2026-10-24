package com.restaurant.billing.dto.common;

/**
 * Encapsulates the execution outcome and resulting payload,
 * mirroring the C# tuple return: Task<(DbExecutionResult exeResult, dynamic? result)>
 */
public class DbExecutionOutput<T> {

    private final DbExecutionResult executionResult;
    private final T data;

    public DbExecutionOutput(DbExecutionResult executionResult, T data) {
        this.executionResult = executionResult;
        this.data = data;
    }

    public DbExecutionResult getExecutionResult() {
        return executionResult;
    }

    public T getData() {
        return data;
    }
}
