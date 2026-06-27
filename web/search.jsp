<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lostfound.entity.*, com.lostfound.service.*, com.lostfound.util.*, java.util.*" %>
<%
    String keyword = request.getParameter("keyword");
    int pageNum = 1;
    try { pageNum = Integer.parseInt(request.getParameter("page")); } catch (Exception e) {}

    LostItemService lostItemService = new LostItemService();
    FoundItemService foundItemService = new FoundItemService();

    PageInfo<LostItem> lostPage = null;
    PageInfo<FoundItem> foundPage = null;
    int totalResults = 0;

    if (keyword != null && !keyword.trim().isEmpty()) {
        lostPage = lostItemService.findPublished(pageNum, 6, keyword, null);
        foundPage = foundItemService.findPublished(pageNum, 6, keyword, null);
        totalResults = lostPage.getTotalCount() + foundPage.getTotalCount();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>搜索 "<%= keyword != null ? keyword : "" %>" - 校园失物招领</title>
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
                <li class="nav-item"><a class="nav-link" href="lost-list.jsp">失物招领</a></li>
                <li class="nav-item"><a class="nav-link" href="found-list.jsp">物品寻主</a></li>
            </ul>
            <form class="form-inline mr-2" action="search.jsp" method="get">
                <input class="form-control mr-1" name="keyword" type="search" placeholder="搜索失物/招领..."
                       value="<%= keyword != null ? keyword : "" %>" style="width:200px;">
                <button class="btn btn-outline-light btn-sm" type="submit"><i class="fas fa-search"></i></button>
            </form>
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
    <div class="card mb-3">
        <div class="card-body">
            <form class="form-inline" action="search.jsp" method="get">
                <div class="input-group" style="width:100%;">
                    <input type="text" class="form-control form-control-lg" name="keyword"
                           placeholder="输入关键词搜索失物、招领..." value="<%= keyword != null ? keyword : "" %>">
                    <div class="input-group-append">
                        <button class="btn btn-primary btn-lg" type="submit"><i class="fas fa-search"></i> 搜索</button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <% if (keyword != null && !keyword.trim().isEmpty()) { %>
        <p class="mb-3">
            搜索 "<strong><%= keyword %></strong>" ，共找到 <strong><%= totalResults %></strong> 条结果
        </p>

        <!-- 失物结果 -->
        <% if (lostPage != null && !lostPage.getList().isEmpty()) { %>
        <h5 class="mb-3"><i class="fas fa-exclamation-circle" style="color:#dc3545;"></i> 失物招领（<%= lostPage.getTotalCount() %>条）</h5>
        <div class="row">
            <% for (LostItem item : lostPage.getList()) { %>
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
                            &nbsp; <i class="fas fa-tag"></i> <%= item.getCategory() %>
                        </p>
                        <span class="status-badge <%= item.getStatusBadgeClass() %>"><%= item.getStatusText() %></span>
                        <small class="text-muted float-right"><%= item.getNickname() != null ? item.getNickname() : "" %></small>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>

        <!-- 招领结果 -->
        <% if (foundPage != null && !foundPage.getList().isEmpty()) { %>
        <h5 class="mb-3 mt-3"><i class="fas fa-hand-holding-heart" style="color:#28a745;"></i> 物品寻主（<%= foundPage.getTotalCount() %>条）</h5>
        <div class="row">
            <% for (FoundItem item : foundPage.getList()) { %>
            <div class="col-md-4 col-lg-4 mb-3">
                <div class="card h-100">
                    <% if (item.getImage() != null && !item.getImage().isEmpty()) { %>
                        <a href="${pageContext.request.contextPath}/FoundItemServlet?action=detail&itemId=<%= item.getItemId() %>">
                            <img src="<%= item.getImage() %>" class="item-img" alt="<%= item.getTitle() %>">
                        </a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/FoundItemServlet?action=detail&itemId=<%= item.getItemId() %>">
                            <div class="item-placeholder"><i class="fas fa-image"></i></div>
                        </a>
                    <% } %>
                    <div class="card-body">
                        <h5 class="card-title">
                            <a href="${pageContext.request.contextPath}/FoundItemServlet?action=detail&itemId=<%= item.getItemId() %>"
                               style="color:#333;text-decoration:none;"><%= item.getTitle() %></a>
                        </h5>
                        <p class="card-text small text-muted mb-1">
                            <i class="fas fa-map-marker-alt"></i> <%= item.getFoundPlace() != null ? item.getFoundPlace() : "未知" %>
                            &nbsp; <i class="fas fa-tag"></i> <%= item.getCategory() %>
                        </p>
                        <span class="status-badge <%= item.getStatus() == 1 ? "status-active" : "status-claimed" %>"><%= item.getStatusText() %></span>
                        <small class="text-muted float-right"><%= item.getNickname() != null ? item.getNickname() : "" %></small>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>

        <% if (totalResults == 0) { %>
        <div class="empty-state">
            <i class="fas fa-search" style="font-size:4rem;color:#ccc;"></i>
            <p class="mt-3">没有找到与 "<strong><%= keyword %></strong>" 相关的物品</p>
            <p class="text-muted small">试试其他关键词，如物品名称、地点、分类</p>
        </div>
        <% } %>
    <% } else { %>
        <div class="empty-state">
            <i class="fas fa-search" style="font-size:4rem;color:#ccc;"></i>
            <p class="mt-3">输入关键词进行搜索</p>
            <p class="text-muted small">可按物品名称、丢失/捡到地点、分类等进行搜索</p>
        </div>
    <% } %>
</div>

<footer class="footer"><div class="container"><p class="mb-0">&copy; 2026 校园失物招领互助平台</p></div></footer>

<script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</body>
</html>
