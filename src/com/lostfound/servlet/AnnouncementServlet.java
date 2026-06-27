package com.lostfound.servlet;

import com.lostfound.entity.Announcement;
import com.lostfound.service.AnnouncementService;
import com.lostfound.util.PageInfo;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;

/**
 * 公告控制器（仅管理员可操作）
 */
@WebServlet("/AnnouncementServlet")
public class AnnouncementServlet extends HttpServlet {

    private AnnouncementService announcementService = new AnnouncementService();

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
            case "publish":
                publish(req, resp);
                break;
            case "list":
                list(req, resp);
                break;
            case "update":
                update(req, resp);
                break;
            case "delete":
                delete(req, resp);
                break;
            case "latest":
                latest(req, resp);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    /**
     * 发布公告
     */
    private void publish(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String title = req.getParameter("title");
        String content = req.getParameter("content");
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        if (title == null || title.trim().isEmpty()) {
            out.write("{\"code\": 0, \"msg\": \"标题不能为空\"}");
            return;
        }

        Announcement announcement = new Announcement();
        announcement.setTitle(title.trim());
        announcement.setContent(content != null ? content.trim() : "");

        int result = announcementService.publish(announcement);
        if (result > 0) {
            out.write("{\"code\": 1, \"msg\": \"公告发布成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"发布失败\"}");
        }
    }

    /**
     * 分页查询公告列表
     */
    private void list(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}

        PageInfo<Announcement> pageInfo = announcementService.findAll(page, 10);

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        StringBuilder json = new StringBuilder();
        json.append("{\"code\":1,\"data\":[");
        for (int i = 0; i < pageInfo.getList().size(); i++) {
            Announcement a = pageInfo.getList().get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"announcementId\":").append(a.getAnnouncementId()).append(",");
            json.append("\"title\":\"").append(escapeJson(a.getTitle())).append("\",");
            json.append("\"content\":\"").append(escapeJson(a.getContent())).append("\",");
            json.append("\"createTime\":\"").append(a.getCreateTime() != null ?
                    sdf.format(a.getCreateTime()) : "").append("\"");
            json.append("}");
        }
        json.append("],\"totalPage\":").append(pageInfo.getTotalPage());
        json.append(",\"currentPage\":").append(pageInfo.getCurrentPage());
        json.append(",\"totalCount\":").append(pageInfo.getTotalCount()).append("}");
        out.write(json.toString());
    }

    /**
     * 获取最新公告（首页展示）
     */
    private void latest(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        List<Announcement> list = announcementService.findLatest(6);

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        StringBuilder json = new StringBuilder();
        json.append("{\"code\":1,\"data\":[");
        for (int i = 0; i < list.size(); i++) {
            Announcement a = list.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"announcementId\":").append(a.getAnnouncementId()).append(",");
            json.append("\"title\":\"").append(escapeJson(a.getTitle())).append("\",");
            json.append("\"content\":\"").append(escapeJson(a.getContent())).append("\",");
            json.append("\"createTime\":\"").append(a.getCreateTime() != null ?
                    sdf.format(a.getCreateTime()) : "").append("\"");
            json.append("}");
        }
        json.append("]}");
        out.write(json.toString());
    }

    /**
     * 更新公告
     */
    private void update(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int announcementId = Integer.parseInt(req.getParameter("announcementId"));
        String title = req.getParameter("title");
        String content = req.getParameter("content");
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        Announcement announcement = new Announcement();
        announcement.setAnnouncementId(announcementId);
        announcement.setTitle(title);
        announcement.setContent(content);

        boolean success = announcementService.update(announcement);
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"更新成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"更新失败\"}");
        }
    }

    /**
     * 删除公告
     */
    private void delete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int announcementId = Integer.parseInt(req.getParameter("announcementId"));
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        boolean success = announcementService.delete(announcementId);
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
