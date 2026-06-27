package com.lostfound.service;

import com.lostfound.dao.UserDAO;
import com.lostfound.entity.User;
import com.lostfound.util.PageInfo;

/**
 * 用户业务逻辑层
 */
public class UserService {

    private UserDAO userDAO = new UserDAO();

    /**
     * 用户注册
     */
    public int register(User user) {
        // 检查用户名是否已存在
        User exist = userDAO.findByUsername(user.getUsername());
        if (exist != null) {
            return -1; // 用户名已存在
        }
        return userDAO.register(user);
    }

    /**
     * 用户登录
     */
    public User login(String username, String password) {
        return userDAO.login(username, password);
    }

    /**
     * 管理员登录
     */
    public User adminLogin(String username, String password) {
        return userDAO.adminLogin(username, password);
    }

    /**
     * 根据ID查找用户
     */
    public User findById(int userId) {
        return userDAO.findById(userId);
    }

    /**
     * 更新用户资料
     */
    public boolean update(User user) {
        return userDAO.update(user);
    }

    /**
     * 禁用/启用用户
     */
    public boolean updateStatus(int userId, int status) {
        return userDAO.updateStatus(userId, status);
    }

    /**
     * 删除用户
     */
    public boolean delete(int userId) {
        return userDAO.delete(userId);
    }

    /**
     * 分页查询所有用户
     */
    public PageInfo<User> findAll(int currentPage, int pageSize, String keyword) {
        return userDAO.findAll(currentPage, pageSize, keyword);
    }
}
