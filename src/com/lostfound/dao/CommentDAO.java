package com.lostfound.dao;

import com.lostfound.entity.Comment;
import com.lostfound.util.DBUtil;
import com.lostfound.util.PageInfo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 留言数据访问层
 */
public class CommentDAO {

    /**
     * 添加留言
     */
    public int insert(Comment comment) {
        String sql = "INSERT INTO comments (item_id, item_type, user_id, content) VALUES (?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, comment.getItemId());
            ps.setInt(2, comment.getItemType());
            ps.setInt(3, comment.getUserId());
            ps.setString(4, comment.getContent());
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
     * 根据物品ID和类型查询留言列表
     */
    public List<Comment> findByItemId(int itemId, int itemType) {
        String sql = "SELECT c.*, u.nickname, u.username FROM comments c " +
                     "LEFT JOIN users u ON c.user_id = u.user_id " +
                     "WHERE c.item_id = ? AND c.item_type = ? ORDER BY c.create_time ASC";
        List<Comment> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            ps.setInt(2, itemType);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapComment(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    /**
     * 查询某用户的所有留言
     */
    public PageInfo<Comment> findByUserId(int userId, int currentPage, int pageSize) {
        PageInfo<Comment> pageInfo = new PageInfo<>(currentPage, pageSize);
        String countSql = "SELECT COUNT(*) FROM comments WHERE user_id = ?";
        String listSql = "SELECT c.*, u.nickname, u.username FROM comments c " +
                         "LEFT JOIN users u ON c.user_id = u.user_id WHERE c.user_id = ? " +
                         "ORDER BY c.create_time DESC LIMIT ?, ?";

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
            List<Comment> list = new ArrayList<>();
            while (rs.next()) list.add(mapComment(rs));
            pageInfo.setList(list);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return pageInfo;
    }

    /**
     * 管理员分页查询所有留言
     */
    public PageInfo<Comment> findAll(int currentPage, int pageSize, String keyword) {
        PageInfo<Comment> pageInfo = new PageInfo<>(currentPage, pageSize);
        String where = "";
        if (keyword != null && !keyword.isEmpty()) {
            where = " WHERE c.content LIKE ? OR u.nickname LIKE ?";
        }
        String countSql = "SELECT COUNT(*) FROM comments c LEFT JOIN users u ON c.user_id = u.user_id" + where;
        String listSql = "SELECT c.*, u.nickname, u.username FROM comments c " +
                         "LEFT JOIN users u ON c.user_id = u.user_id" + where +
                         " ORDER BY c.create_time DESC LIMIT ?, ?";

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
            rs = ps.executeQuery();
            if (rs.next()) pageInfo.setTotalCount(rs.getInt(1));
            DBUtil.close(null, ps, rs);

            ps = conn.prepareStatement(listSql);
            pi = 1;
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(pi++, "%" + keyword + "%");
                ps.setString(pi++, "%" + keyword + "%");
            }
            ps.setInt(pi++, pageInfo.getOffset());
            ps.setInt(pi, pageInfo.getPageSize());
            rs = ps.executeQuery();
            List<Comment> list = new ArrayList<>();
            while (rs.next()) list.add(mapComment(rs));
            pageInfo.setList(list);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return pageInfo;
    }

    /**
     * 删除留言
     */
    public boolean delete(int commentId) {
        String sql = "DELETE FROM comments WHERE comment_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, commentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps);
        }
        return false;
    }

    /**
     * 用户删除自己的留言
     */
    public boolean delete(int commentId, int userId) {
        String sql = "DELETE FROM comments WHERE comment_id = ? AND user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, commentId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps);
        }
        return false;
    }

    private Comment mapComment(ResultSet rs) throws SQLException {
        Comment comment = new Comment();
        comment.setCommentId(rs.getInt("comment_id"));
        comment.setItemId(rs.getInt("item_id"));
        comment.setItemType(rs.getInt("item_type"));
        comment.setUserId(rs.getInt("user_id"));
        comment.setContent(rs.getString("content"));
        comment.setCreateTime(rs.getTimestamp("create_time"));
        try { comment.setNickname(rs.getString("nickname")); } catch (Exception ignored) {}
        try { comment.setUsername(rs.getString("username")); } catch (Exception ignored) {}
        return comment;
    }
}
