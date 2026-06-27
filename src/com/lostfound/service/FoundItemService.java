package com.lostfound.service;

import com.lostfound.dao.FoundItemDAO;
import com.lostfound.entity.FoundItem;
import com.lostfound.util.PageInfo;

import java.util.List;

/**
 * 招领信息业务逻辑层
 */
public class FoundItemService {

    private FoundItemDAO foundItemDAO = new FoundItemDAO();

    public int publish(FoundItem item) {
        return foundItemDAO.insert(item);
    }

    public FoundItem findById(int itemId) {
        return foundItemDAO.findById(itemId);
    }

    public PageInfo<FoundItem> findPublished(int currentPage, int pageSize, String keyword, String category) {
        return foundItemDAO.findPublished(currentPage, pageSize, keyword, category);
    }

    public PageInfo<FoundItem> findByUserId(int userId, int currentPage, int pageSize) {
        return foundItemDAO.findByUserId(userId, currentPage, pageSize);
    }

    public PageInfo<FoundItem> findAll(int currentPage, int pageSize, String keyword, String category, Integer status) {
        return foundItemDAO.findAll(currentPage, pageSize, keyword, category, status);
    }

    public boolean update(FoundItem item) {
        return foundItemDAO.update(item);
    }

    public boolean delete(int itemId, int userId) {
        return foundItemDAO.delete(itemId, userId);
    }

    public boolean deleteById(int itemId) {
        return foundItemDAO.deleteById(itemId);
    }

    public boolean updateStatus(int itemId, int status) {
        return foundItemDAO.updateStatus(itemId, status);
    }

    public int countAll() {
        return foundItemDAO.countAll();
    }

    public int countClaimed() {
        return foundItemDAO.countClaimed();
    }

    public List<FoundItem> findLatest(int limit) {
        return foundItemDAO.findLatest(limit);
    }
}
