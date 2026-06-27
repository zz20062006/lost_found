package com.lostfound.servlet;

import com.lostfound.entity.User;
import com.lostfound.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * 用户控制器 — 处理登录、注册、退出、资料修改
 */
@WebServlet("/UserServlet")
public class UserServlet extends HttpServlet {

    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        switch (action) {
            case "login":
                login(req, resp);
                break;
            case "register":
                register(req, resp);
                break;
            case "logout":
                logout(req, resp);
                break;
            case "adminLogin":
                adminLogin(req, resp);
                break;
            case "updateProfile":
                updateProfile(req, resp);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    /**
     * 普通用户登录
     */
    private void login(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        User user = userService.login(username, password);
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        if (user == null) {
            out.write("{\"code\": 0, \"msg\": \"用户名或密码错误，或账号已被禁用\"}");
        } else if (user.getRole() == 1) {
            out.write("{\"code\": 0, \"msg\": \"请使用管理员入口登录\"}");
        } else {
            req.getSession().setAttribute("user", user);
            out.write("{\"code\": 1, \"msg\": \"登录成功\"}");
        }
    }

    /**
     * 管理员登录
     */
    private void adminLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        User user = userService.adminLogin(username, password);
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        if (user == null) {
            out.write("{\"code\": 0, \"msg\": \"管理员账号或密码错误\"}");
        } else {
            req.getSession().setAttribute("admin", user);
            req.getSession().setAttribute("user", user);
            out.write("{\"code\": 1, \"msg\": \"登录成功\"}");
        }
    }

    /**
     * 用户注册
     */
    private void register(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String nickname = req.getParameter("nickname");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");

        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            out.write("{\"code\": 0, \"msg\": \"用户名和密码不能为空\"}");
            return;
        }

        User user = new User();
        user.setUsername(username.trim());
        user.setPassword(password.trim());
        user.setNickname(nickname != null ? nickname.trim() : username.trim());
        user.setPhone(phone != null ? phone.trim() : "");
        user.setEmail(email != null ? email.trim() : "");

        int result = userService.register(user);
        if (result > 0) {
            out.write("{\"code\": 1, \"msg\": \"注册成功，请登录\"}");
        } else if (result == -1) {
            out.write("{\"code\": 0, \"msg\": \"用户名已被占用\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"注册失败，请重试\"}");
        }
    }

    /**
     * 退出登录
     */
    private void logout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/index.jsp");
    }

    /**
     * 修改个人资料
     */
    private void updateProfile(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        User sessionUser = (User) session.getAttribute("user");
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        if (sessionUser == null) {
            out.write("{\"code\": 0, \"msg\": \"请先登录\"}");
            return;
        }

        String nickname = req.getParameter("nickname");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        sessionUser.setNickname(nickname != null ? nickname.trim() : sessionUser.getNickname());
        sessionUser.setPhone(phone != null ? phone.trim() : sessionUser.getPhone());
        sessionUser.setEmail(email != null ? email.trim() : sessionUser.getEmail());
        if (password != null && !password.trim().isEmpty()) {
            sessionUser.setPassword(password.trim());
        }

        boolean success = userService.update(sessionUser);
        if (success) {
            session.setAttribute("user", sessionUser);
            if (session.getAttribute("admin") != null) {
                session.setAttribute("admin", sessionUser);
            }
            out.write("{\"code\": 1, \"msg\": \"资料更新成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"更新失败，请重试\"}");
        }
    }
}
