<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lostfound.entity.*, com.lostfound.service.*, java.util.*" %>
<%
    LostItemService lostItemService = new LostItemService();
    FoundItemService foundItemService = new FoundItemService();
    AnnouncementService announcementService = new AnnouncementService();
    List<LostItem> latestLost = lostItemService.findLatest(6);
    List<FoundItem> latestFound = foundItemService.findLatest(6);
    List<LostItem> resolvedItems = lostItemService.findResolved(6);
    List<Announcement> announcements = announcementService.findLatest(5);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>校园失物招领互助平台</title>
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
    <style>
        .icon-feature { font-size: 2.5rem; color: #667eea; margin-bottom: 10px; }
        .feature-card { text-align: center; padding: 25px 15px; border-radius: 10px; transition: 0.3s; }
        .feature-card:hover { background: #f8f9ff; }
    </style>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
    <div class="container">
        <a class="navbar-brand" href="index.jsp"><i class="fas fa-search"></i>校园失物招领</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav mr-auto">
                <li class="nav-item active"><a class="nav-link" href="index.jsp">首页</a></li>
                <li class="nav-item"><a class="nav-link" href="lost-list.jsp">失物招领</a></li>
                <li class="nav-item"><a class="nav-link" href="found-list.jsp">物品寻主</a></li>
                <li class="nav-item"><a class="nav-link" href="publish-lost.jsp">发布失物</a></li>
                <li class="nav-item"><a class="nav-link" href="publish-found.jsp">发布招领</a></li>
            </ul>
            <form class="form-inline mr-2">
                <input class="form-control mr-1" id="globalSearch" type="search" placeholder="搜索物品..." style="width:180px;">
            </form>
            <ul class="navbar-nav">
                <% User sessionUser = (User) session.getAttribute("user");
                   if (sessionUser != null) { %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" data-toggle="dropdown">
                            <i class="fas fa-user"></i> <%= sessionUser.getNickname() != null ? sessionUser.getNickname() : sessionUser.getUsername() %>
                        </a>
                        <div class="dropdown-menu">
                            <a class="dropdown-item" href="user-center.jsp">个人中心</a>
                            <% if (sessionUser.getRole() == 1) { %>
                            <a class="dropdown-item" href="admin/index.jsp">管理后台</a>
                            <% } %>
                            <div class="dropdown-divider"></div>
                            <a class="dropdown-item" href="${pageContext.request.contextPath}/UserServlet?action=logout">退出登录</a>
                        </div>
                    </li>
                <% } else { %>
                    <li class="nav-item"><a class="nav-link" href="auth.jsp">登录</a></li>
                    <li class="nav-item"><a class="nav-link" href="auth.jsp?mode=register">注册</a></li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<!-- Hero区域 -->
<section class="hero-section text-center">
    <div class="container">
        <h1><i class="fas fa-hand-holding-heart"></i> 校园失物招领互助平台</h1>
        <p>丢了东西？捡到物品？在这里，全校师生互帮互助，让失物早日回家</p>
        <div class="search-box mt-4">
            <div class="input-group input-group-lg">
                <input type="text" class="form-control" id="heroSearch" placeholder="输入物品名称、地点...">
                <div class="input-group-append">
                    <button class="btn btn-warning" onclick="searchItem()">
                        <i class="fas fa-search"></i> 搜索
                    </button>
                </div>
            </div>
        </div>
        <div class="mt-3">
            <a href="publish-lost.jsp" class="btn btn-outline-light mr-2"><i class="fas fa-edit"></i> 发布失物</a>
            <a href="publish-found.jsp" class="btn btn-outline-light"><i class="fas fa-gift"></i> 发布招领</a>
        </div>
    </div>
</section>

<!-- 功能特色 -->
<div class="container">
    <div class="row text-center mb-4">
        <div class="col-md-3">
            <div class="feature-card">
                <div class="icon-feature"><i class="fas fa-clipboard-list"></i></div>
                <h5>发布信息</h5>
                <p class="text-muted small">快速发布失物或招领信息</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="feature-card">
                <div class="icon-feature"><i class="fas fa-search"></i></div>
                <h5>智能搜索</h5>
                <p class="text-muted small">按名称、地点、分类检索</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="feature-card">
                <div class="icon-feature"><i class="fas fa-comments"></i></div>
                <h5>互动留言</h5>
                <p class="text-muted small">在详情页交流确认信息</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="feature-card">
                <div class="icon-feature"><i class="fas fa-shield-alt"></i></div>
                <h5>安全可靠</h5>
                <p class="text-muted small">实名认证，管理员审核</p>
            </div>
        </div>
    </div>
</div>

<!-- 最新失物 -->
<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4><i class="fas fa-exclamation-circle" style="color:#dc3545;"></i> 最新失物</h4>
        <a href="lost-list.jsp" class="btn btn-sm btn-outline-primary">查看更多 &raquo;</a>
    </div>
    <div class="row">
        <% for (LostItem item : latestLost) { %>
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
                    <p class="card-text small text-muted">
                        <i class="fas fa-map-marker-alt"></i> <%= item.getLostPlace() != null ? item.getLostPlace() : "未知" %> &nbsp;
                        <i class="fas fa-tag"></i> <%= item.getCategory() %>
                    </p>
                    <span class="status-badge <%= item.getStatusBadgeClass() %>">
                        <%= item.getStatusText() %>
                    </span>
                    <small class="text-muted float-right"><%= item.getNickname() != null ? item.getNickname() : "" %></small>
                </div>
            </div>
        </div>
        <% } %>
        <% if (latestLost.isEmpty()) { %>
        <div class="col-12 empty-state"><i class="fas fa-inbox"></i><p>暂无失物信息</p></div>
        <% } %>
    </div>
</div>

<!-- 最新招领 -->
<div class="container mt-3">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4><i class="fas fa-hand-holding-heart" style="color:#28a745;"></i> 最新招领</h4>
        <a href="found-list.jsp" class="btn btn-sm btn-outline-primary">查看更多 &raquo;</a>
    </div>
    <div class="row">
        <% for (FoundItem item : latestFound) { %>
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
                    <p class="card-text small text-muted">
                        <i class="fas fa-map-marker-alt"></i> <%= item.getFoundPlace() != null ? item.getFoundPlace() : "未知" %> &nbsp;
                        <i class="fas fa-tag"></i> <%= item.getCategory() %>
                    </p>
                    <span class="status-badge <%= item.getStatus() == 1 ? "status-active" : "status-claimed" %>">
                        <%= item.getStatusText() %>
                    </span>
                    <small class="text-muted float-right"><%= item.getNickname() != null ? item.getNickname() : "" %></small>
                </div>
            </div>
        </div>
        <% } %>
        <% if (latestFound.isEmpty()) { %>
        <div class="col-12 empty-state"><i class="fas fa-inbox"></i><p>暂无招领信息</p></div>
        <% } %>
    </div>
</div>

<!-- 已找回 / 已认领 -->
<div class="container mt-3">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4><i class="fas fa-check-circle" style="color:#28a745;"></i> 已找回 / 已认领</h4>
        <a href="lost-list.jsp" class="btn btn-sm btn-outline-success">查看更多 &raquo;</a>
    </div>
    <div class="row">
        <% for (LostItem item : resolvedItems) { %>
        <div class="col-md-4 col-lg-4 mb-3">
            <div class="card h-100" style="opacity:0.85;">
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
                    <p class="card-text small text-muted">
                        <i class="fas fa-map-marker-alt"></i> <%= item.getLostPlace() != null ? item.getLostPlace() : "未知" %> &nbsp;
                        <i class="fas fa-tag"></i> <%= item.getCategory() %>
                    </p>
                    <span class="status-badge <%= item.getStatusBadgeClass() %>">
                        <i class="fas fa-check"></i> <%= item.getStatusText() %>
                    </span>
                    <small class="text-muted float-right"><%= item.getNickname() != null ? item.getNickname() : "" %></small>
                </div>
            </div>
        </div>
        <% } %>
        <% if (resolvedItems.isEmpty()) { %>
        <div class="col-12 empty-state"><i class="fas fa-inbox"></i><p>还没有已找回的物品</p></div>
        <% } %>
    </div>
</div>

<!-- 公告区域 -->
<div class="container mt-4">
    <div class="announcement-panel">
        <h4><i class="fas fa-bullhorn" style="color:#ffc107;"></i> 校园公告</h4>
        <hr>
        <% for (Announcement a : announcements) { %>
        <div class="announcement-item">
            <h5 style="color:#333;"><%= a.getTitle() %></h5>
            <p style="font-size:0.95rem;color:#555;white-space:pre-line;line-height:1.8;">
                <%= a.getContent() != null ? a.getContent() : "" %>
            </p>
            <p class="text-muted" style="font-size:0.85rem;">
                <i class="far fa-clock"></i> <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(a.getCreateTime()) %>
            </p>
        </div>
        <% } %>
        <% if (announcements.isEmpty()) { %>
        <p class="text-muted text-center" style="font-size:0.95rem;">暂无公告</p>
        <% } %>
    </div>
</div>

<!-- 页脚 -->
<footer class="footer">
    <div class="container">
        <p class="mb-0">&copy; 2026 校园失物招领互助平台 — 让每一件失物都找到回家的路</p>
    </div>
</footer>

<div class="toast-container"></div>

<script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/js/bootstrap.bundle.min.js"></script>
<script>
    var contextPath = '${pageContext.request.contextPath}';
</script>
<script src="js/common.js"></script>
<script>
    function searchItem() {
        var keyword = $('#heroSearch').val().trim();
        if (keyword) {
            window.location.href = contextPath + '/search.jsp?keyword=' + encodeURIComponent(keyword);
        } else {
            window.location.href = contextPath + '/search.jsp';
        }
    }
</script>
</body>
</html>