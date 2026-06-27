package com.lostfound.servlet;

import com.lostfound.entity.Comment;
import com.lostfound.entity.User;
import com.lostfound.service.CommentService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;

/**
 * 留言控制器
 */
@WebServlet("/CommentServlet")
public class CommentServlet extends HttpServlet {

    private CommentService commentService = new CommentService();

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
            case "add":
                add(req, resp);
                break;
            case "list":
                list(req, resp);
                break;
            case "delete":
                delete(req, resp);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    /**
     * 添加留言
     */
    private void add(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        if (user == null) {
            out.write("{\"code\": 0, \"msg\": \"请先登录\"}");
            return;
        }

        int itemId = Integer.parseInt(req.getParameter("itemId"));
        int itemType = Integer.parseInt(req.getParameter("itemType"));
        String content = req.getParameter("content");

        if (content == null || content.trim().isEmpty()) {
            out.write("{\"code\": 0, \"msg\": \"留言内容不能为空\"}");
            return;
        }

        Comment comment = new Comment();
        comment.setItemId(itemId);
        comment.setItemType(itemType);
        comment.setUserId(user.getUserId());
        comment.setContent(content.trim());

        int result = commentService.add(comment);
        if (result > 0) {
            out.write("{\"code\": 1, \"msg\": \"留言成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"留言失败\"}");
        }
    }

    /**
     * 查询物品的留言列表
     */
    private void list(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int itemId = Integer.parseInt(req.getParameter("itemId"));
        int itemType = Integer.parseInt(req.getParameter("itemType"));

        List<Comment> comments = commentService.findByItemId(itemId, itemType);

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        StringBuilder json = new StringBuilder();
        json.append("{\"code\":1,\"data\":[");
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        for (int i = 0; i < comments.size(); i++) {
            Comment c = comments.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"commentId\":").append(c.getCommentId()).append(",");
            json.append("\"userId\":").append(c.getUserId()).append(",");
            json.append("\"content\":\"").append(escapeJson(c.getContent())).append("\",");
            json.append("\"nickname\":\"").append(escapeJson(c.getNickname())).append("\",");
            json.append("\"createTime\":\"").append(c.getCreateTime() != null ?
                    sdf.format(c.getCreateTime()) : "").append("\"");
            json.append("}");
        }
        json.append("]}");
        out.write(json.toString());
    }

    /**
     * 删除留言
     */
    private void delete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        if (user == null) {
            out.write("{\"code\": 0, \"msg\": \"请先登录\"}");
            return;
        }

        int commentId = Integer.parseInt(req.getParameter("commentId"));
        boolean success = commentService.delete(commentId, user.getUserId());
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"删除成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"删除失败\"}");
        }
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\").replace("\"", "\\\"")
                  .replace("\n", "\\n").replace("\r", "\\r");
    }
}
