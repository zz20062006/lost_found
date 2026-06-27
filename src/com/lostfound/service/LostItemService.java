package com.lostfound.service;

import com.lostfound.dao.LostItemDAO;
import com.lostfound.entity.LostItem;
import com.lostfound.util.PageInfo;

import java.util.List;

/**
 * 失物信息业务逻辑层
 */
public class LostItemService {

    private LostItemDAO lostItemDAO = new LostItemDAO();

    public int publish(LostItem item) {
        return lostItemDAO.insert(item);
    }

    public LostItem findById(int itemId) {
        return lostItemDAO.findById(itemId);
    }

    public PageInfo<LostItem> findPublished(int currentPage, int pageSize, String keyword, String category) {
        return lostItemDAO.findPublished(currentPage, pageSize, keyword, category);
    }

    public PageInfo<LostItem> findByUserId(int userId, int currentPage, int pageSize) {
        return lostItemDAO.findByUserId(userId, currentPage, pageSize);
    }

    public PageInfo<LostItem> findAll(int currentPage, int pageSize, String keyword, String category, Integer status) {
        return lostItemDAO.findAll(currentPage, pageSize, keyword, category, status);
    }

    public boolean update(LostItem item) {
        return lostItemDAO.update(item);
    }

    public boolean delete(int itemId, int userId) {
        return lostItemDAO.delete(itemId, userId);
    }

    public boolean deleteById(int itemId) {
        return lostItemDAO.deleteById(itemId);
    }

    public boolean updateStatus(int itemId, int status) {
        return lostItemDAO.updateStatus(itemId, status);
    }

    public boolean claimItem(int itemId, int claimerId) {
        return lostItemDAO.claimItem(itemId, claimerId);
    }

    public int countAll() {
        return lostItemDAO.countAll();
    }

    public int countResolved() {
        return lostItemDAO.countResolved();
    }

    public List<LostItem> findLatest(int limit) {
        return lostItemDAO.findLatest(limit);
    }

    public List<LostItem> findResolved(int limit) {
        return lostItemDAO.findResolved(limit);
    }
}
