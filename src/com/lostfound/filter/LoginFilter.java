package com.lostfound.filter;

import com.lostfound.entity.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 登录拦截过滤器 — 未登录用户禁止访问需登录的页面
 */
@WebFilter(filterName = "LoginFilter", urlPatterns = {
    "/publish-lost.jsp", "/publish-found.jsp",
    "/user-center.jsp", "/item-detail.jsp",
    "/LostItemServlet", "/FoundItemServlet", "/CommentServlet",
    "/UserServlet"
})
public class LoginFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        String path = req.getRequestURI();

        // 放行特定操作：查看列表、查看详情、登录、注册
        if (path.contains("/LostItemServlet") && "list".equals(req.getParameter("action"))) {
            chain.doFilter(req, resp);
            return;
        }
        if (path.contains("/FoundItemServlet") && "list".equals(req.getParameter("action"))) {
            chain.doFilter(req, resp);
            return;
        }
        if (path.contains("/LostItemServlet") && "detail".equals(req.getParameter("action"))) {
            chain.doFilter(req, resp);
            return;
        }
        if (path.contains("/FoundItemServlet") && "detail".equals(req.getParameter("action"))) {
            chain.doFilter(req, resp);
            return;
        }
        if (path.contains("/UserServlet") && "login".equals(req.getParameter("action"))) {
            chain.doFilter(req, resp);
            return;
        }
        if (path.contains("/UserServlet") && "register".equals(req.getParameter("action"))) {
            chain.doFilter(req, resp);
            return;
        }
        if (path.contains("/CommentServlet") && "list".equals(req.getParameter("action"))) {
            chain.doFilter(req, resp);
            return;
        }

        if (session == null || session.getAttribute("user") == null) {
            // 如果是AJAX请求，返回JSON
            String requestedWith = req.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equals(requestedWith)) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"code\": -1, \"msg\": \"请先登录\"}");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/auth.jsp");
            return;
        }

        chain.doFilter(req, resp);
    }

    @Override
    public void destroy() {
    }
}
