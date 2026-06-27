package com.lostfound.util;

import java.util.List;

/**
 * 分页工具类
 */
public class PageInfo<T> {

    private int currentPage;   // 当前页码
    private int pageSize;      // 每页记录数
    private int totalCount;    // 总记录数
    private int totalPage;     // 总页数
    private List<T> list;      // 当前页数据

    public PageInfo() {
        this.currentPage = 1;
        this.pageSize = 10;
    }

    public PageInfo(int currentPage, int pageSize) {
        this.currentPage = currentPage > 0 ? currentPage : 1;
        this.pageSize = pageSize > 0 ? pageSize : 10;
    }

    public int getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(int currentPage) {
        this.currentPage = currentPage;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }

    public int getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
        this.totalPage = (totalCount + pageSize - 1) / pageSize;
    }

    public int getTotalPage() {
        return totalPage;
    }

    public List<T> getList() {
        return list;
    }

    public void setList(List<T> list) {
        this.list = list;
    }

    /**
     * 获取分页起始位置 (LIMIT offset)
     */
    public int getOffset() {
        return (currentPage - 1) * pageSize;
    }

    /**
     * 是否有上一页
     */
    public boolean isHasPrevious() {
        return currentPage > 1;
    }

    /**
     * 是否有下一页
     */
    public boolean isHasNext() {
        return currentPage < totalPage;
    }
}
