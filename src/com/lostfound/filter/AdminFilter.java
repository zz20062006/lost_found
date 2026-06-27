package com.lostfound.filter;

import com.lostfound.entity.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 管理员权限过滤器 — 非管理员无法访问后台
 */
@WebFilter(filterName = "AdminFilter", urlPatterns = {"/admin/*", "/AdminServlet", "/AnnouncementServlet"})
public class AdminFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);

        // 放行管理员登录页和登录请求
        String path = req.getRequestURI();
        if (path.contains("/admin/login.jsp")) {
            chain.doFilter(req, resp);
            return;
        }
        if (path.contains("/UserServlet") && "adminLogin".equals(req.getParameter("action"))) {
            chain.doFilter(req, resp);
            return;
        }

        if (session == null || session.getAttribute("admin") == null) {
            String requestedWith = req.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equals(requestedWith)) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"code\": -1, \"msg\": \"请先登录管理员账号\"}");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/admin/login.jsp");
            return;
        }

        chain.doFilter(req, resp);
    }

    @Override
    public void destroy() {
    }
}
