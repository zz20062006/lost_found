package com.lostfound.dao;

import com.lostfound.entity.LostItem;
import com.lostfound.util.DBUtil;
import com.lostfound.util.PageInfo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 失物信息数据访问层
 */
public class LostItemDAO {

    /**
     * 发布失物信息
     */
    public int insert(LostItem item) {
        String sql = "INSERT INTO lost_items (user_id, title, category, description, lost_time, lost_place, image, contact, status) " +
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
            ps.setTimestamp(5, item.getLostTime() != null ? new Timestamp(item.getLostTime().getTime()) : null);
            ps.setString(6, item.getLostPlace());
            ps.setString(7, item.getImage());
            ps.setString(8, item.getContact());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return 0;
    }

    /**
     * 根据ID查询详情
     */
    public LostItem findById(int itemId) {
        String sql = "SELECT l.*, u.nickname, u.username, uc.nickname AS claimedByName FROM lost_items l " +
                     "LEFT JOIN users u ON l.user_id = u.user_id " +
                     "LEFT JOIN users uc ON l.claimed_by = uc.user_id WHERE l.item_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapItem(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * 分页查询失物列表（已审核通过的，用于前台展示）
     */
    public PageInfo<LostItem> findPublished(int currentPage, int pageSize, String keyword, String category) {
        PageInfo<LostItem> pageInfo = new PageInfo<>(currentPage, pageSize);
        StringBuilder where = new StringBuilder(" WHERE l.status IN (1, 2, 3)");

        if (keyword != null && !keyword.isEmpty()) {
            where.append(" AND (l.title LIKE ? OR l.lost_place LIKE ? OR l.description LIKE ?)");
        }
        if (category != null && !category.isEmpty() && !"全部".equals(category)) {
            where.append(" AND l.category = ?");
        }

        String countSql = "SELECT COUNT(*) FROM lost_items l" + where;
        String listSql = "SELECT l.*, u.nickname, u.username, uc.nickname AS claimedByName FROM lost_items l " +
                         "LEFT JOIN users u ON l.user_id = u.user_id " +
                         "LEFT JOIN users uc ON l.claimed_by = uc.user_id" + where +
                         " ORDER BY l.create_time DESC LIMIT ?, ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();

            // 查询总数
            ps = conn.prepareStatement(countSql);
            int paramIndex = 1;
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(paramIndex++, "%" + keyword + "%");
                ps.setString(paramIndex++, "%" + keyword + "%");
                ps.setString(paramIndex++, "%" + keyword + "%");
            }
            if (category != null && !category.isEmpty() && !"全部".equals(category)) {
                ps.setString(paramIndex++, category);
            }
            rs = ps.executeQuery();
            if (rs.next()) pageInfo.setTotalCount(rs.getInt(1));
            DBUtil.close(null, ps, rs);

            // 查询列表
            ps = conn.prepareStatement(listSql);
            paramIndex = 1;
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(paramIndex++, "%" + keyword + "%");
                ps.setString(paramIndex++, "%" + keyword + "%");
                ps.setString(paramIndex++, "%" + keyword + "%");
            }
            if (category != null && !category.isEmpty() && !"全部".equals(category)) {
                ps.setString(paramIndex++, category);
            }
            ps.setInt(paramIndex++, pageInfo.getOffset());
            ps.setInt(paramIndex, pageInfo.getPageSize());
            rs = ps.executeQuery();

            List<LostItem> list = new ArrayList<>();
            while (rs.next()) {
                list.add(mapItem(rs));
            }
            pageInfo.setList(list);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return pageInfo;
    }

    /**
     * 查询某用户发布的失物列表
     */
    public PageInfo<LostItem> findByUserId(int userId, int currentPage, int pageSize) {
        PageInfo<LostItem> pageInfo = new PageInfo<>(currentPage, pageSize);
        String countSql = "SELECT COUNT(*) FROM lost_items WHERE user_id = ?";
        String listSql = "SELECT l.*, u.nickname, u.username FROM lost_items l " +
                         "LEFT JOIN users u ON l.user_id = u.user_id WHERE l.user_id = ? " +
                         "ORDER BY l.create_time DESC LIMIT ?, ?";

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
            List<LostItem> list = new ArrayList<>();
            while (rs.next()) {
                list.add(mapItem(rs));
            }
            pageInfo.setList(list);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return pageInfo;
    }

    /**
     * 管理员分页查询所有失物（含待审核）
     */
    public PageInfo<LostItem> findAll(int currentPage, int pageSize, String keyword, String category, Integer status) {
        PageInfo<LostItem> pageInfo = new PageInfo<>(currentPage, pageSize);
        StringBuilder where = new StringBuilder(" WHERE 1=1");

        if (keyword != null && !keyword.isEmpty()) {
            where.append(" AND (l.title LIKE ? OR l.lost_place LIKE ?)");
        }
        if (category != null && !category.isEmpty() && !"全部".equals(category)) {
            where.append(" AND l.category = ?");
        }
        if (status != null && status >= 0) {
            where.append(" AND l.status = ?");
        }

        String countSql = "SELECT COUNT(*) FROM lost_items l" + where;
        String listSql = "SELECT l.*, u.nickname, u.username, uc.nickname AS claimedByName FROM lost_items l " +
                         "LEFT JOIN users u ON l.user_id = u.user_id " +
                         "LEFT JOIN users uc ON l.claimed_by = uc.user_id" + where +
                         " ORDER BY l.create_time DESC LIMIT ?, ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();

            ps = conn.prepareStatement(countSql);
            int paramIndex = 1;
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(paramIndex++, "%" + keyword + "%");
                ps.setString(paramIndex++, "%" + keyword + "%");
            }
            if (category != null && !category.isEmpty() && !"全部".equals(category)) {
                ps.setString(paramIndex++, category);
            }
            if (status != null && status >= 0) {
                ps.setInt(paramIndex++, status);
            }
            rs = ps.executeQuery();
            if (rs.next()) pageInfo.setTotalCount(rs.getInt(1));
            DBUtil.close(null, ps, rs);

            ps = conn.prepareStatement(listSql);
            paramIndex = 1;
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(paramIndex++, "%" + keyword + "%");
                ps.setString(paramIndex++, "%" + keyword + "%");
            }
            if (category != null && !category.isEmpty() && !"全部".equals(category)) {
                ps.setString(paramIndex++, category);
            }
            if (status != null && status >= 0) {
                ps.setInt(paramIndex++, status);
            }
            ps.setInt(paramIndex++, pageInfo.getOffset());
            ps.setInt(paramIndex, pageInfo.getPageSize());
            rs = ps.executeQuery();

            List<LostItem> list = new ArrayList<>();
            while (rs.next()) {
                list.add(mapItem(rs));
            }
            pageInfo.setList(list);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return pageInfo;
    }

    /**
     * 更新失物信息
     */
    public boolean update(LostItem item) {
        String sql = "UPDATE lost_items SET title=?, category=?, description=?, lost_time=?, lost_place=?, contact=?";
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
            ps.setTimestamp(4, item.getLostTime() != null ? new Timestamp(item.getLostTime().getTime()) : null);
            ps.setString(5, item.getLostPlace());
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

    /**
     * 删除失物信息
     */
    public boolean delete(int itemId, int userId) {
        String sql = "DELETE FROM lost_items WHERE item_id = ? AND user_id = ?";
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

    /**
     * 管理员删除
     */
    public boolean deleteById(int itemId) {
        String sql = "DELETE FROM lost_items WHERE item_id = ?";
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

    /**
     * 更新状态
     */
    public boolean updateStatus(int itemId, int status) {
        String sql = "UPDATE lost_items SET status = ? WHERE item_id = ?";
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

    /**
     * 认领失物 — 设置状态为3(已认领)，记录认领者
     */
    public boolean claimItem(int itemId, int claimerId) {
        String sql = "UPDATE lost_items SET status = 3, claimed_by = ? WHERE item_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, claimerId);
            ps.setInt(2, itemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps);
        }
        return false;
    }

    /**
     * 统计失物总数
     */
    public int countAll() {
        String sql = "SELECT COUNT(*) FROM lost_items";
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

    /**
     * 统计已找回数量
     */
    public int countResolved() {
        String sql = "SELECT COUNT(*) FROM lost_items WHERE status = 2";
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

    /**
     * 获取最新几条失物（首页展示）
     */
    public List<LostItem> findLatest(int limit) {
        String sql = "SELECT l.*, u.nickname, u.username, uc.nickname AS claimedByName FROM lost_items l " +
                     "LEFT JOIN users u ON l.user_id = u.user_id " +
                     "LEFT JOIN users uc ON l.claimed_by = uc.user_id WHERE l.status = 1 " +
                     "ORDER BY l.create_time DESC LIMIT ?";
        List<LostItem> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapItem(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    /**
     * 获取最新已找回/已认领的失物（首页展示）
     */
    public List<LostItem> findResolved(int limit) {
        String sql = "SELECT l.*, u.nickname, u.username, uc.nickname AS claimedByName FROM lost_items l " +
                     "LEFT JOIN users u ON l.user_id = u.user_id " +
                     "LEFT JOIN users uc ON l.claimed_by = uc.user_id WHERE l.status IN (2,3) " +
                     "ORDER BY l.create_time DESC LIMIT ?";
        List<LostItem> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapItem(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    private LostItem mapItem(ResultSet rs) throws SQLException {
        LostItem item = new LostItem();
        item.setItemId(rs.getInt("item_id"));
        item.setUserId(rs.getInt("user_id"));
        item.setTitle(rs.getString("title"));
        item.setCategory(rs.getString("category"));
        item.setDescription(rs.getString("description"));
        item.setLostTime(rs.getTimestamp("lost_time"));
        item.setLostPlace(rs.getString("lost_place"));
        item.setImage(rs.getString("image"));
        item.setContact(rs.getString("contact"));
        item.setStatus(rs.getInt("status"));
        item.setCreateTime(rs.getTimestamp("create_time"));
        try { item.setClaimedBy(rs.getInt("claimed_by")); if (rs.wasNull()) item.setClaimedBy(null); } catch (Exception ignored) {}
        try { item.setNickname(rs.getString("nickname")); } catch (Exception ignored) {}
        try { item.setUsername(rs.getString("username")); } catch (Exception ignored) {}
        try { item.setClaimedByName(rs.getString("claimedByName")); } catch (Exception ignored) {}
        return item;
    }
}
