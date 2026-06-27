package com.lostfound.dao;

import com.lostfound.entity.FoundItem;
import com.lostfound.util.DBUtil;
import com.lostfound.util.PageInfo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 招领信息数据访问层
 */
public class FoundItemDAO {

    public int insert(FoundItem item) {
        String sql = "INSERT INTO found_items (user_id, title, category, description, found_time, found_place, image, contact, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, item.getUserId());
            ps.setString(2, item.getTitle());
            ps.setString(3, item.getCategory());
            ps.setString(4, item.getDescription());
            ps.setTimestamp(5, item.getFoundTime() != null ? new Timestamp(item.getFoundTime().getTime()) : null);
            ps.setString(6, item.getFoundPlace());
            ps.setString(7, item.getImage());
            ps.setString(8, item.getContact());
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

    public FoundItem findById(int itemId) {
        String sql = "SELECT f.*, u.nickname, u.username FROM found_items f " +
                     "LEFT JOIN users u ON f.user_id = u.user_id WHERE f.item_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            rs = ps.executeQuery();
            if (rs.next()) return mapItem(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    public PageInfo<FoundItem> findPublished(int currentPage, int pageSize, String keyword, String category) {
        PageInfo<FoundItem> pageInfo = new PageInfo<>(currentPage, pageSize);
        StringBuilder where = new StringBuilder(" WHERE f.status IN (1, 2)");

        if (keyword != null && !keyword.isEmpty()) {
            where.append(" AND (f.title LIKE ? OR f.found_place LIKE ? OR f.description LIKE ?)");
        }
        if (category != null && !category.isEmpty() && !"全部".equals(category)) {
            where.append(" AND f.category = ?");
        }

        String countSql = "SELECT COUNT(*) FROM found_items f" + where;
        String listSql = "SELECT f.*, u.nickname, u.username FROM found_items f " +
                         "LEFT JOIN users u ON f.user_id = u.user_id" + where +
                         " ORDER BY f.create_time DESC LIMIT ?, ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(countSql);
            int pi = 1;
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(pi++, "%" + keyword + "%");
                ps.setString(pi++, "%" + keyword + "%");
                ps.setString(pi++, "%" + keyword + "%");
            }
            if (category != null && !category.isEmpty() && !"全部".equals(category)) {
                ps.setString(pi++, category);
            }
            rs = ps.executeQuery();
            if (rs.next()) pageInfo.setTotalCount(rs.getInt(1));
            DBUtil.close(null, ps, rs);

            ps = conn.prepareStatement(listSql);
            pi = 1;
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(pi++, "%" + keyword + "%");
                ps.setString(pi++, "%" + keyword + "%");
                ps.setString(pi++, "%" + keyword + "%");
            }
            if (category != null && !category.isEmpty() && !"全部".equals(category)) {
                ps.setString(pi++, category);
            }
            ps.setInt(pi++, pageInfo.getOffset());
            ps.setInt(pi, pageInfo.getPageSize());
            rs = ps.executeQuery();

            List<FoundItem> list = new ArrayList<>();
            while (rs.next()) list.add(mapItem(rs));
            pageInfo.setList(list);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return pageInfo;
    }

    public PageInfo<FoundItem> findByUserId(int userId, int currentPage, int pageSize) {
        PageInfo<FoundItem> pageInfo = new PageInfo<>(currentPage, pageSize);
        String countSql = "SELECT COUNT(*) FROM found_items WHERE user_id = ?";
        String listSql = "SELECT f.*, u.nickname, u.username FROM found_items f " +
                         "LEFT JOIN users u ON f.user_id = u.user_id WHERE f.user_id = ? " +
                         "ORDER BY f.create_time DESC LIMIT ?, ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(countSql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) pageInfo.setTotalCount(rs.getInt(1));
            DBUtil.close(null, ps, rs);

            ps = conn.prepareStatement(listSql);
            ps.setInt(1, userId);
            ps.setInt(2, pageInfo.getOffset());
            ps.setInt(3, pageInfo.getPageSize());
            rs = ps.executeQuery();
            List<FoundItem> list = new ArrayList<>();
            while (rs.next()) list.add(mapItem(rs));
            pageInfo.setList(list);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return pageInfo;
    }

    public PageInfo<FoundItem> findAll(int currentPage, int pageSize, String keyword, String category, Integer status) {
        PageInfo<FoundItem> pageInfo = new PageInfo<>(currentPage, pageSize);
        StringBuilder where = new StringBuilder(" WHERE 1=1");

        if (keyword != null && !keyword.isEmpty()) {
            where.append(" AND (f.title LIKE ? OR f.found_place LIKE ?)");
        }
        if (category != null && !category.isEmpty() && !"全部".equals(category)) {
            where.append(" AND f.category = ?");
        }
        if (status != null && status >= 0) {
            where.append(" AND f.status = ?");
        }

        String countSql = "SELECT COUNT(*) FROM found_items f" + where;
        String listSql = "SELECT f.*, u.nickname, u.username FROM found_items f " +
                         "LEFT JOIN users u ON f.user_id = u.user_id" + where +
                         " ORDER BY f.create_time DESC LIMIT ?, ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(countSql);
            int pi = 1;
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(pi++, "%" + keyword + "%");
                ps.setString(pi++, "%" + keyword + "%");
            }
            if (category != null && !category.isEmpty() && !"全部".equals(category)) {
                ps.setString(pi++, category);
            }
            if (status != null && status >= 0) {
                ps.setInt(pi++, status);
            }
            rs = ps.executeQuery();
            if (rs.next()) pageInfo.setTotalCount(rs.getInt(1));
            DBUtil.close(null, ps, rs);

            ps = conn.prepareStatement(listSql);
            pi = 1;
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(pi++, "%" + keyword + "%");
                ps.setString(pi++, "%" + keyword + "%");
            }
            if (category != null && !category.isEmpty() && !"全部".equals(category)) {
                ps.setString(pi++, category);
            }
            if (status != null && status >= 0) {
                ps.setInt(pi++, status);
            }
            ps.setInt(pi++, pageInfo.getOffset());
            ps.setInt(pi, pageInfo.getPageSize());
            rs = ps.executeQuery();

            List<FoundItem> list = new ArrayList<>();
            while (rs.next()) list.add(mapItem(rs));
            pageInfo.setList(list);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return pageInfo;
    }

    public boolean update(FoundItem item) {
        String sql = "UPDATE found_items SET title=?, category=?, description=?, found_time=?, found_place=?, contact=?";
        if (item.getImage() != null && !item.getImage().isEmpty()) {
            sql += ", image=?";
        }
        sql += " WHERE item_id=? AND user_id=?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, item.getTitle());
            ps.setString(2, item.getCategory());
            ps.setString(3, item.getDescription());
            ps.setTimestamp(4, item.getFoundTime() != null ? new Timestamp(item.getFoundTime().getTime()) : null);
            ps.setString(5, item.getFoundPlace());
            ps.setString(6, item.getContact());
            int idx = 7;
            if (item.getImage() != null && !item.getImage().isEmpty()) {
                ps.setString(idx++, item.getImage());
            }
            ps.setInt(idx++, item.getItemId());
            ps.setInt(idx, item.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps);
        }
        return false;
    }

    public boolean delete(int itemId, int userId) {
        String sql = "DELETE FROM found_items WHERE item_id = ? AND user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps);
        }
        return false;
    }

    public boolean deleteById(int itemId) {
        String sql = "DELETE FROM found_items WHERE item_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps);
        }
        return false;
    }

    public boolean updateStatus(int itemId, int status) {
        String sql = "UPDATE found_items SET status = ? WHERE item_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, status);
            ps.setInt(2, itemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps);
        }
        return false;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM found_items";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return 0;
    }

    public int countClaimed() {
        String sql = "SELECT COUNT(*) FROM found_items WHERE status = 2";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return 0;
    }

    public List<FoundItem> findLatest(int limit) {
        String sql = "SELECT f.*, u.nickname, u.username FROM found_items f " +
                     "LEFT JOIN users u ON f.user_id = u.user_id WHERE f.status IN (1,2) " +
                     "ORDER BY f.create_time DESC LIMIT ?";
        List<FoundItem> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapItem(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    private FoundItem mapItem(ResultSet rs) throws SQLException {
        FoundItem item = new FoundItem();
        item.setItemId(rs.getInt("item_id"));
        item.setUserId(rs.getInt("user_id"));
        item.setTitle(rs.getString("title"));
        item.setCategory(rs.getString("category"));
        item.setDescription(rs.getString("description"));
        item.setFoundTime(rs.getTimestamp("found_time"));
        item.setFoundPlace(rs.getString("found_place"));
        item.setImage(rs.getString("image"));
        item.setContact(rs.getString("contact"));
        item.setStatus(rs.getInt("status"));
        item.setCreateTime(rs.getTimestamp("create_time"));
        try { item.setNickname(rs.getString("nickname")); } catch (Exception ignored) {}
        try { item.setUsername(rs.getString("username")); } catch (Exception ignored) {}
        return item;
    }
}
