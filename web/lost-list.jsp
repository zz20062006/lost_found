<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lostfound.entity.*, com.lostfound.service.*, com.lostfound.util.*, java.util.*" %>
<%
    String keyword = request.getParameter("keyword");
    String category = request.getParameter("category");
    int pageNum = 1;
    try { pageNum = Integer.parseInt(request.getParameter("page")); } catch (Exception e) {}
    LostItemService lostItemService = new LostItemService();
    PageInfo<LostItem> pageInfo = lostItemService.findPublished(pageNum, 9, keyword, category);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>失物招领列表 - 校园失物招领</title>
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
    <div class="container">
        <a class="navbar-brand" href="index.jsp"><i class="fas fa-search"></i>校园失物招领</a>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav mr-auto">
                <li class="nav-item"><a class="nav-link" href="index.jsp">首页</a></li>
                <li class="nav-item active"><a class="nav-link" href="lost-list.jsp">失物招领</a></li>
                <li class="nav-item"><a class="nav-link" href="found-list.jsp">物品寻主</a></li>
                <li class="nav-item"><a class="nav-link" href="publish-lost.jsp">发布失物</a></li>
                <li class="nav-item"><a class="nav-link" href="publish-found.jsp">发布招领</a></li>
            </ul>
            <%
                User sessionUser = (User) session.getAttribute("user");
                if (sessionUser != null) {
            %>
            <ul class="navbar-nav">
                <li class="nav-item"><a class="nav-link" href="user-center.jsp"><i class="fas fa-user"></i> <%= sessionUser.getNickname() %></a></li>
            </ul>
            <% } else { %>
            <ul class="navbar-nav">
                <li class="nav-item"><a class="nav-link" href="auth.jsp">登录</a></li>
            </ul>
            <% } %>
        </div>
    </div>
</nav>

<div class="container" style="margin-top:20px;">
    <h4><i class="fas fa-exclamation-circle" style="color:#dc3545;"></i> 失物招领</h4>

    <!-- 搜索+分类筛选 -->
    <div class="card mb-3">
        <div class="card-body">
            <form class="form-inline" id="filterForm">
                <input type="text" class="form-control mr-2 mb-2" name="keyword" placeholder="搜索物品名称、地点..." value="<%= keyword != null ? keyword : "" %>">
                <select class="form-control mr-2 mb-2" name="category">
                    <option value="全部">全部分类</option>
                    <option value="证件" <%= "证件".equals(category) ? "selected" : "" %>>证件</option>
                    <option value="电子设备" <%= "电子设备".equals(category) ? "selected" : "" %>>电子设备</option>
                    <option value="书籍" <%= "书籍".equals(category) ? "selected" : "" %>>书籍</option>
                    <option value="衣物" <%= "衣物".equals(category) ? "selected" : "" %>>衣物</option>
                    <option value="生活用品" <%= "生活用品".equals(category) ? "selected" : "" %>>生活用品</option>
                    <option value="钥匙" <%= "钥匙".equals(category) ? "selected" : "" %>>钥匙</option>
                    <option value="钱包" <%= "钱包".equals(category) ? "selected" : "" %>>钱包</option>
                    <option value="其他" <%= "其他".equals(category) ? "selected" : "" %>>其他</option>
                </select>
                <button type="submit" class="btn btn-primary mb-2"><i class="fas fa-search"></i> 筛选</button>
            </form>
        </div>
    </div>

    <!-- 物品列表 -->
    <div class="row" id="itemList">
        <% for (LostItem item : pageInfo.getList()) { %>
        <div class="col-md-4 col-lg-4 mb-3">
            <div class="card h-100">
                <% if (item.getImage() != null && !item.getImage().isEmpty()) { %>
                    <a href="${pageContext.request.contextPath}/LostItemServlet?action=detail&itemId=<%= item.getItemId() %>">
                        <img src="<%= item.getImage() %>" class="item-img" alt="<%= item.getTitle() %>">
                    </a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/LostItemServlet?action=detail&itemId=<%= item.getItemId() %>">
                        <div class="item-placeholder"><i class="fas fa-image"></i></div>
                    </a>
                <% } %>
                <div class="card-body">
                    <h5 class="card-title">
                        <a href="${pageContext.request.contextPath}/LostItemServlet?action=detail&itemId=<%= item.getItemId() %>"
                           style="color:#333;text-decoration:none;"><%= item.getTitle() %></a>
                    </h5>
                    <p class="card-text small text-muted mb-1">
                        <i class="fas fa-map-marker-alt"></i> <%= item.getLostPlace() != null ? item.getLostPlace() : "未知" %>
                    </p>
                    <p class="card-text small text-muted mb-1">
                        <i class="fas fa-tag"></i> <%= item.getCategory() %>
                        &nbsp; <i class="fas fa-user"></i> <%= item.getNickname() != null ? item.getNickname() : "匿名" %>
                    </p>
                    <span class="status-badge <%= item.getStatusBadgeClass() %>">
                        <%= item.getStatusText() %>
                    </span>
                    <small class="text-muted float-right"><%= new java.text.SimpleDateFormat("MM-dd HH:mm").format(item.getCreateTime()) %></small>
                </div>
            </div>
        </div>
        <% } %>
        <% if (pageInfo.getList().isEmpty()) { %>
        <div class="col-12 empty-state"><i class="fas fa-inbox"></i><p>没有找到相关失物信息</p></div>
        <% } %>
    </div>

    <!-- 分页 -->
    <% if (pageInfo.getTotalPage() > 1) { %>
    <nav>
        <ul class="pagination">
            <li class="page-item <%= pageInfo.isHasPrevious() ? "" : "disabled" %>">
                <a class="page-link" href="?page=<%= pageInfo.getCurrentPage()-1 %>&keyword=<%= keyword != null ? keyword : "" %>&category=<%= category != null ? category : "" %>">&laquo;</a>
            </li>
            <% for (int i = 1; i <= pageInfo.getTotalPage(); i++) { %>
            <li class="page-item <%= i == pageInfo.getCurrentPage() ? "active" : "" %>">
                <a class="page-link" href="?page=<%= i %>&keyword=<%= keyword != null ? keyword : "" %>&category=<%= category != null ? category : "" %>"><%= i %></a>
            </li>
            <% } %>
            <li class="page-item <%= pageInfo.isHasNext() ? "" : "disabled" %>">
                <a class="page-link" href="?page=<%= pageInfo.getCurrentPage()+1 %>&keyword=<%= keyword != null ? keyword : "" %>&category=<%= category != null ? category : "" %>">&raquo;</a>
            </li>
        </ul>
    </nav>
    <% } %>
</div>

<footer class="footer"><div class="container"><p class="mb-0">&copy; 2026 校园失物招领互助平台</p></div></footer>
<div class="toast-container"></div>

<script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="js/common.js"></script>
</body>
</html>
