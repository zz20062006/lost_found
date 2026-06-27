package com.lostfound.servlet;

import com.lostfound.entity.LostItem;
import com.lostfound.entity.User;
import com.lostfound.service.LostItemService;
import com.lostfound.util.PageInfo;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

/**
 * 失物信息控制器
 */
@WebServlet("/LostItemServlet")
@MultipartConfig(
    maxFileSize = 10 * 1024 * 1024,
    maxRequestSize = 20 * 1024 * 1024
)
public class LostItemServlet extends HttpServlet {

    private LostItemService lostItemService = new LostItemService();

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
            case "claim":
                claim(req, resp);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    /**
     * 发布失物信息
     */
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

        // 处理图片上传
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

        LostItem item = new LostItem();
        item.setUserId(user.getUserId());
        item.setTitle(req.getParameter("title"));
        item.setCategory(req.getParameter("category"));
        item.setDescription(req.getParameter("description"));
        item.setLostPlace(req.getParameter("lostPlace"));
        item.setContact(req.getParameter("contact"));
        item.setImage(imagePath);

        try {
            String lostTimeStr = req.getParameter("lostTime");
            if (lostTimeStr != null && !lostTimeStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                item.setLostTime(sdf.parse(lostTimeStr));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        int result = lostItemService.publish(item);
        if (result > 0) {
            out.write("{\"code\": 1, \"msg\": \"发布成功！\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"发布失败，请重试\"}");
        }
    }

    /**
     * 查询失物列表（分页+搜索+分类筛选）
     */
    private void list(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String keyword = req.getParameter("keyword");
        String category = req.getParameter("category");
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}

        PageInfo<LostItem> pageInfo = lostItemService.findPublished(page, 10, keyword, category);

        // 判断是否 AJAX 请求
        String requestedWith = req.getHeader("X-Requested-With");
        if ("XMLHttpRequest".equals(requestedWith)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("{\"code\":1,\"data\":[");
            for (int i = 0; i < pageInfo.getList().size(); i++) {
                LostItem item = pageInfo.getList().get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"itemId\":").append(item.getItemId()).append(",");
                json.append("\"title\":\"").append(escapeJson(item.getTitle())).append("\",");
                json.append("\"category\":\"").append(escapeJson(item.getCategory())).append("\",");
                json.append("\"lostPlace\":\"").append(escapeJson(item.getLostPlace())).append("\",");
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
            req.getRequestDispatcher("/lost-list.jsp").forward(req, resp);
        }
    }

    /**
     * 查看失物详情
     */
    private void detail(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        int itemId = Integer.parseInt(req.getParameter("itemId"));
        LostItem item = lostItemService.findById(itemId);

        if (item == null) {
            resp.sendRedirect(req.getContextPath() + "/error.jsp");
            return;
        }

        // 判断AJAX请求
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
            json.append("\"lostPlace\":\"").append(escapeJson(item.getLostPlace())).append("\",");
            json.append("\"lostTime\":\"").append(item.getLostTime() != null ?
                    new SimpleDateFormat("yyyy-MM-dd HH:mm").format(item.getLostTime()) : "").append("\",");
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
            req.setAttribute("itemType", "lost");
            req.getRequestDispatcher("/item-detail.jsp").forward(req, resp);
        }
    }

    /**
     * 更新失物信息
     */
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

        LostItem item = new LostItem();
        item.setItemId(itemId);
        item.setUserId(user.getUserId());
        item.setTitle(req.getParameter("title"));
        item.setCategory(req.getParameter("category"));
        item.setDescription(req.getParameter("description"));
        item.setLostPlace(req.getParameter("lostPlace"));
        item.setContact(req.getParameter("contact"));

        try {
            String lostTimeStr = req.getParameter("lostTime");
            if (lostTimeStr != null && !lostTimeStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                item.setLostTime(sdf.parse(lostTimeStr));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 处理新上传的图片
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

        boolean success = lostItemService.update(item);
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"更新成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"更新失败\"}");
        }
    }

    /**
     * 删除失物信息
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

        int itemId = Integer.parseInt(req.getParameter("itemId"));
        boolean success = lostItemService.delete(itemId, user.getUserId());
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"删除成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"删除失败\"}");
        }
    }

    /**
     * 更新物品状态（标记已找回）
     */
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

        boolean success = lostItemService.updateStatus(itemId, status);
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"状态更新成功\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"更新失败\"}");
        }
    }

    /**
     * 认领失物
     */
    private void claim(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=UTF-8");

        if (user == null) {
            out.write("{\"code\": 0, \"msg\": \"请先登录\"}");
            return;
        }

        int itemId = Integer.parseInt(req.getParameter("itemId"));
        boolean success = lostItemService.claimItem(itemId, user.getUserId());
        if (success) {
            out.write("{\"code\": 1, \"msg\": \"认领成功！\"}");
        } else {
            out.write("{\"code\": 0, \"msg\": \"认领失败\"}");
        }
    }

    /**
     * 获取上传文件的原始文件名
     */
    private String getSubmittedFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                return fileName.substring(fileName.lastIndexOf(File.separator) + 1);
            }
        }
        return "unknown";
    }

    /**
     * JSON 字符串转义
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r");
    }
}
