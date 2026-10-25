package com.restaurant.billing.dto.common;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * Standard Pagination Metadata mirroring C# Pagination
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Pagination {

    private Integer totalRecords;
    private Integer maxPages;
    private Integer currentPage;
    private Integer pageSize;

    public Pagination() {}

    public Pagination(Integer totalRecords, Integer maxPages) {
        this.totalRecords = totalRecords;
        this.maxPages = maxPages;
    }

    public Pagination(Integer totalRecords, Integer maxPages, Integer currentPage, Integer pageSize) {
        this.totalRecords = totalRecords;
        this.maxPages = maxPages;
        this.currentPage = currentPage;
        this.pageSize = pageSize;
    }

    public Integer getTotalRecords() {
        return totalRecords;
    }

    public void setTotalRecords(Integer totalRecords) {
        this.totalRecords = totalRecords;
    }

    public Integer getMaxPages() {
        return maxPages;
    }

    public void setMaxPages(Integer maxPages) {
        this.maxPages = maxPages;
    }

    public Integer getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(Integer currentPage) {
        this.currentPage = currentPage;
    }

    public Integer getPageSize() {
        return pageSize;
    }

    public void setPageSize(Integer pageSize) {
        this.pageSize = pageSize;
    }
}
