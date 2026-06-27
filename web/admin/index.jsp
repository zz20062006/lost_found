<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lostfound.entity.*, com.lostfound.service.*" %>
<%
    User admin = (User) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    LostItemService lostItemService = new LostItemService();
    FoundItemService foundItemService = new FoundItemService();
    int totalLost = lostItemService.countAll();
    int totalFound = foundItemService.countAll();
    int resolvedLost = lostItemService.countResolved();
    int claimedFound = foundItemService.countClaimed();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>管理后台 - 校园失物招领</title>
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<nav class="navbar navbar-dark bg-dark">
    <a class="navbar-brand ml-3" href="index.jsp"><i class="fas fa-shield-alt"></i> 管理后台</a>
    <span class="navbar-text mr-3">
        <i class="fas fa-user"></i> <%= admin.getNickname() %>
        <a href="<%= request.getContextPath() %>/index.jsp" class="text-light ml-3">返回前台</a>
    </span>
</nav>

<div class="container-fluid">
    <div class="row">
        <!-- 左侧菜单 -->
        <div class="col-md-2 admin-sidebar">
            <nav class="nav flex-column">
                <a class="nav-link active" href="index.jsp"><i class="fas fa-tachometer-alt mr-2"></i>控制面板</a>
                <a class="nav-link" href="user-manage.jsp"><i class="fas fa-users mr-2"></i>用户管理</a>
                <a class="nav-link" href="lost-manage.jsp"><i class="fas fa-exclamation-circle mr-2"></i>失物审核</a>
                <a class="nav-link" href="found-manage.jsp"><i class="fas fa-gift mr-2"></i>招领审核</a>
                <a class="nav-link" href="comment-manage.jsp"><i class="fas fa-comments mr-2"></i>留言管理</a>
                <a class="nav-link" href="announcement-manage.jsp"><i class="fas fa-bullhorn mr-2"></i>公告管理</a>
            </nav>
        </div>

        <!-- 右侧内容 -->
        <div class="col-md-10 admin-content">
            <h4 class="mb-4">控制面板</h4>
            <div class="row">
                <div class="col-md-3 mb-3">
                    <div class="stat-card">
                        <div class="stat-number"><%= totalLost %></div>
                        <div class="stat-label">失物总数</div>
                    </div>
                </div>
                <div class="col-md-3 mb-3">
                    <div class="stat-card">
                        <div class="stat-number"><%= totalFound %></div>
                        <div class="stat-label">招领总数</div>
                    </div>
                </div>
                <div class="col-md-3 mb-3">
                    <div class="stat-card">
                        <div class="stat-number"><%= resolvedLost %></div>
                        <div class="stat-label">已找回</div>
                    </div>
                </div>
                <div class="col-md-3 mb-3">
                    <div class="stat-card">
                        <div class="stat-number"><%= claimedFound %></div>
                        <div class="stat-label">已认领</div>
                    </div>
                </div>
            </div>

            <div class="row mt-2">
                <div class="col-md-4 mb-3">
                    <div class="stat-card">
                        <div class="stat-number"><%= totalLost + totalFound %></div>
                        <div class="stat-label">总发布量</div>
                    </div>
                </div>
                <div class="col-md-4 mb-3">
                    <div class="stat-card">
                        <div class="stat-number"><%= resolvedLost + claimedFound %></div>
                        <div class="stat-label">已完成认领数</div>
                    </div>
                </div>
                <div class="col-md-4 mb-3">
                    <div class="stat-card">
                        <div class="stat-number"><%= (totalLost + totalFound) > 0 ? ((resolvedLost + claimedFound) * 100 / (totalLost + totalFound)) : 0 %>%</div>
                        <div class="stat-label">完成率</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/js/bootstrap.bundle.min.js"></script>
</body>
</html>
