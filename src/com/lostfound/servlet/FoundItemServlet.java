package com.lostfound.servlet;

import com.lostfound.entity.FoundItem;
import com.lostfound.entity.User;
import com.lostfound.service.FoundItemService;
import com.lostfound.util.PageInfo;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.UUID;

/**
 * 招领信息控制器
 */
@WebServlet("/FoundItemServlet")
@MultipartConfig(
    maxFileSize = 10 * 1024 * 1024,
    maxRequestSize = 20 * 1024 * 1024
)
public class FoundItemServlet extends HttpServlet {

    private FoundItemService foundItemService = new FoundItemService();

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
            case "detail":
                detail(req, resp);
                break;
            case "update":
                update(req, resp);
                break;
            case "delete":
                delete(req, resp);
                break;
            case "updateStatus":
                updateStatus(req, resp);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private void publish(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        if (user == null) {
            out.write("{\"code\": 0, \"msg\": \"请先登录\"}");
            return;
        }

        String imagePath = "";
        Part filePart = req.getPart("image");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = UUID.randomUUID().toString() + "_" + getSubmittedFileName(filePart);
            String uploadDir = getServletContext().getRealPath("/upload");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();
            filePart.write(uploadDir + File.separator + fileName);
            imagePath = "upload/" + fileName;
        }

        FoundItem item = new FoundItem();
        item.setUserId(user.getUserId());
        item.setTitle(req.getParameter("title"));
        item.setCategory(req.getParameter("category"));
        item.setDescription(req.getParameter("description"));
        item.setFoundPlace(req.getParameter("foundPlace"));
        item.setContact(req.getParameter("contact"));
        item.setImage(imagePath);

        try {
            String foundTimeStr = req.getParameter("foundTime");
            if (foundTimeStr != null && !foundTimeStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                item.setFoundTime(sdf.parse(foundTimeStr));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        int result = foundItemService.publish(item);
        if (result > 0) {
            out.write("{\"code\": 1, \"msg\": \"发布成功！\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"发布失败，请重试\"}");
        }
    }

    private void list(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        String keyword = req.getParameter("keyword");
        String category = req.getParameter("category");
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}

        PageInfo<FoundItem> pageInfo = foundItemService.findPublished(page, 10, keyword, category);

        String requestedWith = req.getHeader("X-Requested-With");
        if ("XMLHttpRequest".equals(requestedWith)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("{\"code\":1,\"data\":[");
            for (int i = 0; i < pageInfo.getList().size(); i++) {
                FoundItem item = pageInfo.getList().get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"itemId\":").append(item.getItemId()).append(",");
                json.append("\"title\":\"").append(escapeJson(item.getTitle())).append("\",");
                json.append("\"category\":\"").append(escapeJson(item.getCategory())).append("\",");
                json.append("\"foundPlace\":\"").append(escapeJson(item.getFoundPlace())).append("\",");
                json.append("\"image\":\"").append(escapeJson(item.getImage())).append("\",");
                json.append("\"status\":").append(item.getStatus()).append(",");
                json.append("\"statusText\":\"").append(item.getStatusText()).append("\",");
                json.append("\"nickname\":\"").append(escapeJson(item.getNickname())).append("\",");
                json.append("\"createTime\":\"").append(item.getCreateTime() != null ?
                        new SimpleDateFormat("yyyy-MM-dd HH:mm").format(item.getCreateTime()) : "").append("\"");
                json.append("}");
            }
            json.append("],\"totalPage\":").append(pageInfo.getTotalPage());
            json.append(",\"currentPage\":").append(pageInfo.getCurrentPage());
            json.append(",\"totalCount\":").append(pageInfo.getTotalCount()).append("}");
            out.write(json.toString());
        } else {
            req.setAttribute("pageInfo", pageInfo);
            req.setAttribute("keyword", keyword);
            req.setAttribute("category", category);
            req.getRequestDispatcher("/found-list.jsp").forward(req, resp);
        }
    }

    private void detail(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        int itemId = Integer.parseInt(req.getParameter("itemId"));
        FoundItem item = foundItemService.findById(itemId);

        if (item == null) {
            resp.sendRedirect(req.getContextPath() + "/error.jsp");
            return;
        }

        String requestedWith = req.getHeader("X-Requested-With");
        if ("XMLHttpRequest".equals(requestedWith)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("{\"code\":1,\"data\":{");
            json.append("\"itemId\":").append(item.getItemId()).append(",");
            json.append("\"title\":\"").append(escapeJson(item.getTitle())).append("\",");
            json.append("\"category\":\"").append(escapeJson(item.getCategory())).append("\",");
            json.append("\"description\":\"").append(escapeJson(item.getDescription())).append("\",");
            json.append("\"foundPlace\":\"").append(escapeJson(item.getFoundPlace())).append("\",");
            json.append("\"foundTime\":\"").append(item.getFoundTime() != null ?
                    new SimpleDateFormat("yyyy-MM-dd HH:mm").format(item.getFoundTime()) : "").append("\",");
            json.append("\"image\":\"").append(escapeJson(item.getImage())).append("\",");
            json.append("\"contact\":\"").append(escapeJson(item.getContact())).append("\",");
            json.append("\"status\":").append(item.getStatus()).append(",");
            json.append("\"statusText\":\"").append(item.getStatusText()).append("\",");
            json.append("\"nickname\":\"").append(escapeJson(item.getNickname())).append("\",");
            json.append("\"userId\":").append(item.getUserId()).append(",");
            json.append("\"createTime\":\"").append(item.getCreateTime() != null ?
                    new SimpleDateFormat("yyyy-MM-dd HH:mm").format(item.getCreateTime()) : "").append("\"");
            json.append("}}");
            out.write(json.toString());
        } else {
            req.setAttribute("item", item);
            req.setAttribute("itemType", "found");
            req.getRequestDispatcher("/item-detail.jsp").forward(req, resp);
        }
    }

    private void update(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        if (user == null) {
            out.write("{\"code\": 0, \"msg\": \"请先登录\"}");
            return;
        }

        int itemId = Integer.parseInt(req.getParameter("itemId"));

        FoundItem item = new FoundItem();
        item.setItemId(itemId);
        item.setUserId(user.getUserId());
        item.setTitle(req.getParameter("title"));
        item.setCategory(req.getParameter("category"));
        item.setDescription(req.getParameter("description"));
        item.setFoundPlace(req.getParameter("foundPlace"));
        item.setContact(req.getParameter("contact"));

        try {
            String foundTimeStr = req.getParameter("foundTime");
            if (foundTimeStr != null && !foundTimeStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                item.setFoundTime(sdf.parse(foundTimeStr));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            Part filePart = req.getPart("image");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = UUID.randomUUID().toString() + "_" + getSubmittedFileName(filePart);
                String uploadDir = getServletContext().getRealPath("/upload");
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();
                filePart.write(uploadDir + File.separator + fileName);
                item.setImage("upload/" + fileName);
            }
        } catch (Exception ignored) {}

        boolean success = foundItemService.update(item);
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"更新成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"更新失败\"}");
        }
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        if (user == null) {
            out.write("{\"code\": 0, \"msg\": \"请先登录\"}");
            return;
        }

        int itemId = Integer.parseInt(req.getParameter("itemId"));
        boolean success = foundItemService.delete(itemId, user.getUserId());
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"删除成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"删除失败\"}");
        }
    }

    private void updateStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        if (user == null) {
            out.write("{\"code\": 0, \"msg\": \"请先登录\"}");
            return;
        }

        int itemId = Integer.parseInt(req.getParameter("itemId"));
        int status = Integer.parseInt(req.getParameter("status"));
        boolean success = foundItemService.updateStatus(itemId, status);
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"状态更新成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"更新失败\"}");
        }
    }

    private String getSubmittedFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                return fileName.substring(fileName.lastIndexOf(File.separator) + 1);
            }
        }
        return "unknown";
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\").replace("\"", "\\\"")
                  .replace("\n", "\\n").replace("\r", "\\r");
    }
}
