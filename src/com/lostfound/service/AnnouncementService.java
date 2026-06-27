package com.lostfound.service;

import com.lostfound.dao.AnnouncementDAO;
import com.lostfound.entity.Announcement;
import com.lostfound.util.PageInfo;

import java.util.List;

/**
 * 公告业务逻辑层
 */
public class AnnouncementService {

    private AnnouncementDAO announcementDAO = new AnnouncementDAO();

    public int publish(Announcement announcement) {
        return announcementDAO.insert(announcement);
    }

    public PageInfo<Announcement> findAll(int currentPage, int pageSize) {
        return announcementDAO.findAll(currentPage, pageSize);
    }

    public List<Announcement> findLatest(int limit) {
        return announcementDAO.findLatest(limit);
    }

    public Announcement findById(int announcementId) {
        return announcementDAO.findById(announcementId);
    }

    public boolean update(Announcement announcement) {
        return announcementDAO.update(announcement);
    }

    public boolean delete(int announcementId) {
        return announcementDAO.delete(announcementId);
    }
}
