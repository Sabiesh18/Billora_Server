package com.restaurant.billing.dto.auth;

/**
 * Direct architectural mapping of C# UserFetchInput
 */
public class UserFetchInput {

    private int pageNumber = 1;
    private int pageSize = 10;
    private String search;

    public UserFetchInput() {}

    public UserFetchInput(int pageNumber, int pageSize, String search) {
        this.pageNumber = pageNumber;
        this.pageSize = pageSize;
        this.search = search;
    }

    public int getPageNumber() {
        return pageNumber;
    }

    public void setPageNumber(int pageNumber) {
        this.pageNumber = pageNumber;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }

    public String getSearch() {
        return search;
    }

    public void setSearch(String search) {
        this.search = search;
    }
}
