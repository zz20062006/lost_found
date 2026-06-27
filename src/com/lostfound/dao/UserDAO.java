package com.lostfound.dao;

import com.lostfound.entity.User;
import com.lostfound.util.DBUtil;
import com.lostfound.util.PageInfo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 用户数据访问层
 */
public class UserDAO {

    /**
     * 用户注册
     */
    public int register(User user) {
        String sql = "INSERT INTO users (username, password, nickname, phone, email) VALUES (?, MD5(?), ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getNickname());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getEmail());
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
     * 根据用户名查找用户
     */
    public User findByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * 根据ID查找用户
     */
    public User findById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * 验证登录 (用户名+密码)
     */
    public User login(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = MD5(?) AND status = 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * 管理员登录
     */
    public User adminLogin(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = MD5(?) AND role = 1 AND status = 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    /**
     * 更新用户资料
     */
    public boolean update(User user) {
        String sql = "UPDATE users SET nickname = ?, phone = ?, email = ?";
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            sql += ", password = MD5('" + user.getPassword() + "')";
        }
        sql += " WHERE user_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            // 重新构建安全的SQL
            if (user.getPassword() != null && !user.getPassword().isEmpty()) {
                String safeSql = "UPDATE users SET nickname = ?, phone = ?, email = ?, password = MD5(?) WHERE user_id = ?";
                ps = conn.prepareStatement(safeSql);
                ps.setString(1, user.getNickname());
                ps.setString(2, user.getPhone());
                ps.setString(3, user.getEmail());
                ps.setString(4, user.getPassword());
                ps.setInt(5, user.getUserId());
            } else {
                String safeSql = "UPDATE users SET nickname = ?, phone = ?, email = ? WHERE user_id = ?";
                ps = conn.prepareStatement(safeSql);
                ps.setString(1, user.getNickname());
                ps.setString(2, user.getPhone());
                ps.setString(3, user.getEmail());
                ps.setInt(4, user.getUserId());
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps);
        }
        return false;
    }

    /**
     * 禁用/启用用户
     */
    public boolean updateStatus(int userId, int status) {
        String sql = "UPDATE users SET status = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, status);
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
     * 删除用户
     */
    public boolean delete(int userId) {
        String sql = "DELETE FROM users WHERE user_id = ? AND role = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps);
        }
        return false;
    }

    /**
     * 分页查询所有用户（管理员）
     */
    public PageInfo<User> findAll(int currentPage, int pageSize, String keyword) {
        PageInfo<User> pageInfo = new PageInfo<>(currentPage, pageSize);

        String countSql = "SELECT COUNT(*) FROM users WHERE role = 0";
        String listSql = "SELECT * FROM users WHERE role = 0";
        if (keyword != null && !keyword.isEmpty()) {
            String like = " AND (username LIKE ? OR nickname LIKE ? OR phone LIKE ?)";
            countSql += like;
            listSql += like;
        }
        listSql += " ORDER BY create_time DESC LIMIT ?, ?";

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
            rs = ps.executeQuery();
            if (rs.next()) {
                pageInfo.setTotalCount(rs.getInt(1));
            }
            DBUtil.close(null, ps, rs);

            // 查询列表
            ps = conn.prepareStatement(listSql);
            paramIndex = 1;
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(paramIndex++, "%" + keyword + "%");
                ps.setString(paramIndex++, "%" + keyword + "%");
                ps.setString(paramIndex++, "%" + keyword + "%");
            }
            ps.setInt(paramIndex++, pageInfo.getOffset());
            ps.setInt(paramIndex, pageInfo.getPageSize());
            rs = ps.executeQuery();

            List<User> list = new ArrayList<>();
            while (rs.next()) {
                list.add(mapUser(rs));
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
     * ResultSet 映射到 User 对象
     */
    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setNickname(rs.getString("nickname"));
        user.setPhone(rs.getString("phone"));
        user.setEmail(rs.getString("email"));
        user.setAvatar(rs.getString("avatar"));
        user.setRole(rs.getInt("role"));
        user.setStatus(rs.getInt("status"));
        user.setCreateTime(rs.getTimestamp("create_time"));
        return user;
    }
}
