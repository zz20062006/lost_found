package com.lostfound.servlet;

import com.lostfound.entity.*;
import com.lostfound.service.*;
import com.lostfound.util.PageInfo;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;

/**
 * 管理员后台控制器 — 用户管理、物品审核、留言管理、数据统计
 */
@WebServlet("/AdminServlet")
public class AdminServlet extends HttpServlet {

    private UserService userService = new UserService();
    private LostItemService lostItemService = new LostItemService();
    private FoundItemService foundItemService = new FoundItemService();
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
            // 用户管理
            case "userList":
                userList(req, resp);
                break;
            case "userDisable":
                userDisable(req, resp);
                break;
            case "userDelete":
                userDelete(req, resp);
                break;
            // 失物管理
            case "lostList":
                lostList(req, resp);
                break;
            case "lostApprove":
                lostApprove(req, resp);
                break;
            case "lostReject":
                lostReject(req, resp);
                break;
            case "lostDelete":
                lostDelete(req, resp);
                break;
            // 招领管理
            case "foundList":
                foundList(req, resp);
                break;
            case "foundApprove":
                foundApprove(req, resp);
                break;
            case "foundReject":
                foundReject(req, resp);
                break;
            case "foundDelete":
                foundDelete(req, resp);
                break;
            // 留言管理
            case "commentList":
                commentList(req, resp);
                break;
            case "commentDelete":
                commentDelete(req, resp);
                break;
            // 统计
            case "statistics":
                statistics(req, resp);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    /**
     * 用户列表（分页）
     */
    private void userList(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}
        String keyword = req.getParameter("keyword");

        PageInfo<User> pageInfo = userService.findAll(page, 10, keyword);

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        StringBuilder json = new StringBuilder();
        json.append("{\"code\":1,\"data\":[");
        for (int i = 0; i < pageInfo.getList().size(); i++) {
            User u = pageInfo.getList().get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"userId\":").append(u.getUserId()).append(",");
            json.append("\"username\":\"").append(escapeJson(u.getUsername())).append("\",");
            json.append("\"nickname\":\"").append(escapeJson(u.getNickname())).append("\",");
            json.append("\"phone\":\"").append(escapeJson(u.getPhone())).append("\",");
            json.append("\"email\":\"").append(escapeJson(u.getEmail())).append("\",");
            json.append("\"status\":").append(u.getStatus()).append(",");
            json.append("\"createTime\":\"").append(u.getCreateTime() != null ?
                    sdf.format(u.getCreateTime()) : "").append("\"");
            json.append("}");
        }
        json.append("],\"totalPage\":").append(pageInfo.getTotalPage());
        json.append(",\"currentPage\":").append(pageInfo.getCurrentPage());
        json.append(",\"totalCount\":").append(pageInfo.getTotalCount()).append("}");
        out.write(json.toString());
    }

    private void userDisable(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int userId = Integer.parseInt(req.getParameter("userId"));
        int status = Integer.parseInt(req.getParameter("status")); // 0=禁用, 1=启用
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        boolean success = userService.updateStatus(userId, status);
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"操作成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"操作失败\"}");
        }
    }

    private void userDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int userId = Integer.parseInt(req.getParameter("userId"));
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        boolean success = userService.delete(userId);
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"删除成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"删除失败，不能删除管理员\"}");
        }
    }

    /**
     * 失物列表审核管理
     */
    private void lostList(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}
        String keyword = req.getParameter("keyword");
        String category = req.getParameter("category");
        Integer status = null;
        try { status = Integer.parseInt(req.getParameter("status")); } catch (Exception ignored) {}

        PageInfo<LostItem> pageInfo = lostItemService.findAll(page, 10, keyword, category, status);

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        StringBuilder json = new StringBuilder();
        json.append("{\"code\":1,\"data\":[");
        for (int i = 0; i < pageInfo.getList().size(); i++) {
            LostItem item = pageInfo.getList().get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"itemId\":").append(item.getItemId()).append(",");
            json.append("\"title\":\"").append(escapeJson(item.getTitle())).append("\",");
            json.append("\"category\":\"").append(escapeJson(item.getCategory())).append("\",");
            json.append("\"status\":").append(item.getStatus()).append(",");
            json.append("\"statusText\":\"").append(item.getStatusText()).append("\",");
            json.append("\"nickname\":\"").append(escapeJson(item.getNickname())).append("\",");
            json.append("\"createTime\":\"").append(item.getCreateTime() != null ?
                    sdf.format(item.getCreateTime()) : "").append("\"");
            json.append("}");
        }
        json.append("],\"totalPage\":").append(pageInfo.getTotalPage());
        json.append(",\"currentPage\":").append(pageInfo.getCurrentPage());
        json.append(",\"totalCount\":").append(pageInfo.getTotalCount()).append("}");
        out.write(json.toString());
    }

    private void lostApprove(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int itemId = Integer.parseInt(req.getParameter("itemId"));
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        boolean success = lostItemService.updateStatus(itemId, 1); // 1=审核通过-寻找中
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"审核通过\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"操作失败\"}");
        }
    }

    private void lostReject(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int itemId = Integer.parseInt(req.getParameter("itemId"));
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        // 驳回就是删除
        boolean success = lostItemService.deleteById(itemId);
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"已驳回并删除\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"操作失败\"}");
        }
    }

    private void lostDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int itemId = Integer.parseInt(req.getParameter("itemId"));
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        boolean success = lostItemService.deleteById(itemId);
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"删除成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"删除失败\"}");
        }
    }

    /**
     * 招领列表审核管理
     */
    private void foundList(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}
        String keyword = req.getParameter("keyword");
        String category = req.getParameter("category");
        Integer status = null;
        try { status = Integer.parseInt(req.getParameter("status")); } catch (Exception ignored) {}

        PageInfo<FoundItem> pageInfo = foundItemService.findAll(page, 10, keyword, category, status);

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        StringBuilder json = new StringBuilder();
        json.append("{\"code\":1,\"data\":[");
        for (int i = 0; i < pageInfo.getList().size(); i++) {
            FoundItem item = pageInfo.getList().get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"itemId\":").append(item.getItemId()).append(",");
            json.append("\"title\":\"").append(escapeJson(item.getTitle())).append("\",");
            json.append("\"category\":\"").append(escapeJson(item.getCategory())).append("\",");
            json.append("\"status\":").append(item.getStatus()).append(",");
            json.append("\"statusText\":\"").append(item.getStatusText()).append("\",");
            json.append("\"nickname\":\"").append(escapeJson(item.getNickname())).append("\",");
            json.append("\"createTime\":\"").append(item.getCreateTime() != null ?
                    sdf.format(item.getCreateTime()) : "").append("\"");
            json.append("}");
        }
        json.append("],\"totalPage\":").append(pageInfo.getTotalPage());
        json.append(",\"currentPage\":").append(pageInfo.getCurrentPage());
        json.append(",\"totalCount\":").append(pageInfo.getTotalCount()).append("}");
        out.write(json.toString());
    }

    private void foundApprove(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int itemId = Integer.parseInt(req.getParameter("itemId"));
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        boolean success = foundItemService.updateStatus(itemId, 1); // 1=审核通过-待认领
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"审核通过\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"操作失败\"}");
        }
    }

    private void foundReject(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int itemId = Integer.parseInt(req.getParameter("itemId"));
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        boolean success = foundItemService.deleteById(itemId);
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"已驳回并删除\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"操作失败\"}");
        }
    }

    private void foundDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int itemId = Integer.parseInt(req.getParameter("itemId"));
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        boolean success = foundItemService.deleteById(itemId);
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"删除成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"删除失败\"}");
        }
    }

    /**
     * 留言列表管理
     */
    private void commentList(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}
        String keyword = req.getParameter("keyword");

        PageInfo<Comment> pageInfo = commentService.findAll(page, 10, keyword);

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        StringBuilder json = new StringBuilder();
        json.append("{\"code\":1,\"data\":[");
        for (int i = 0; i < pageInfo.getList().size(); i++) {
            Comment c = pageInfo.getList().get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"commentId\":").append(c.getCommentId()).append(",");
            json.append("\"itemId\":").append(c.getItemId()).append(",");
            json.append("\"itemType\":").append(c.getItemType()).append(",");
            json.append("\"content\":\"").append(escapeJson(c.getContent())).append("\",");
            json.append("\"nickname\":\"").append(escapeJson(c.getNickname())).append("\",");
            json.append("\"createTime\":\"").append(c.getCreateTime() != null ?
                    sdf.format(c.getCreateTime()) : "").append("\"");
            json.append("}");
        }
        json.append("],\"totalPage\":").append(pageInfo.getTotalPage());
        json.append(",\"currentPage\":").append(pageInfo.getCurrentPage());
        json.append(",\"totalCount\":").append(pageInfo.getTotalCount()).append("}");
        out.write(json.toString());
    }

    private void commentDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int commentId = Integer.parseInt(req.getParameter("commentId"));
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        boolean success = commentService.delete(commentId);
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"删除成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"删除失败\"}");
        }
    }

    /**
     * 数据统计
     */
    private void statistics(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int totalLost = lostItemService.countAll();
        int totalFound = foundItemService.countAll();
        int resolvedLost = lostItemService.countResolved();
        int claimedFound = foundItemService.countClaimed();

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.write("{\"code\":1,\"data\":{");
        out.write("\"totalLost\":" + totalLost + ",");
        out.write("\"totalFound\":" + totalFound + ",");
        out.write("\"resolvedLost\":" + resolvedLost + ",");
        out.write("\"claimedFound\":" + claimedFound + ",");
        out.write("\"totalPublish\":" + (totalLost + totalFound) + ",");
        out.write("\"totalResolved\":" + (resolvedLost + claimedFound));
        out.write("}}");
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\").replace("\"", "\\\"")
                  .replace("\n", "\\n").replace("\r", "\\r");
    }
}
