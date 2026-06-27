package com.lostfound.dao;

import com.lostfound.entity.Announcement;
import com.lostfound.util.DBUtil;
import com.lostfound.util.PageInfo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 公告数据访问层
 */
public class AnnouncementDAO {

    /**
     * 发布公告
     */
    public int insert(Announcement announcement) {
        String sql = "INSERT INTO announcements (title, content) VALUES (?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, announcement.getTitle());
            ps.setString(2, announcement.getContent());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return 0;
    }

    /**
     * 分页查询所有公告
     */
    public PageInfo<Announcement> findAll(int currentPage, int pageSize) {
        PageInfo<Announcement> pageInfo = new PageInfo<>(currentPage, pageSize);
        String countSql = "SELECT COUNT(*) FROM announcements";
        String listSql = "SELECT * FROM announcements ORDER BY create_time DESC LIMIT ?, ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(countSql);
            rs = ps.executeQuery();
            if (rs.next()) pageInfo.setTotalCount(rs.getInt(1));
            DBUtil.close(null, ps, rs);

            ps = conn.prepareStatement(listSql);
            ps.setInt(1, pageInfo.getOffset());
            ps.setInt(2, pageInfo.getPageSize());
            rs = ps.executeQuery();
            List<Announcement> list = new ArrayList<>();
            while (rs.next()) list.add(mapAnnouncement(rs));
            pageInfo.setList(list);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return pageInfo;
    }

    /**
     * 获取最新几条公告（首页展示）
     */
    public List<Announcement> findLatest(int limit) {
        String sql = "SELECT * FROM announcements ORDER BY create_time DESC LIMIT ?";
        List<Announcement> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapAnnouncement(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    /**
     * 根据ID查询
     */
    public Announcement findById(int announcementId) {
        String sql = "SELECT * FROM announcements WHERE announcement_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, announcementId);
            rs = ps.executeQuery();
            if (rs.next()) return mapAnnouncement(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * 更新公告
     */
    public boolean update(Announcement announcement) {
        String sql = "UPDATE announcements SET title = ?, content = ? WHERE announcement_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, announcement.getTitle());
            ps.setString(2, announcement.getContent());
            ps.setInt(3, announcement.getAnnouncementId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps);
        }
        return false;
    }

    /**
     * 删除公告
     */
    public boolean delete(int announcementId) {
        String sql = "DELETE FROM announcements WHERE announcement_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, announcementId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps);
        }
        return false;
    }

    private Announcement mapAnnouncement(ResultSet rs) throws SQLException {
        Announcement a = new Announcement();
        a.setAnnouncementId(rs.getInt("announcement_id"));
        a.setTitle(rs.getString("title"));
        a.setContent(rs.getString("content"));
        a.setCreateTime(rs.getTimestamp("create_time"));
        a.setUpdateTime(rs.getTimestamp("update_time"));
        return a;
    }
}
