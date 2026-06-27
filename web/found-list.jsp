<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lostfound.entity.*, com.lostfound.service.*, com.lostfound.util.*, java.util.*" %>
<%
    String keyword = request.getParameter("keyword");
    String category = request.getParameter("category");
    int pageNum = 1;
    try { pageNum = Integer.parseInt(request.getParameter("page")); } catch (Exception e) {}
    FoundItemService foundItemService = new FoundItemService();
    PageInfo<FoundItem> pageInfo = foundItemService.findPublished(pageNum, 9, keyword, category);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>物品寻主列表 - 校园失物招领</title>
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
    <style>
        :root {
            --primary: #5B6AF0; --bg: #F8F9FC; --card: #FFFFFF; --text: #1E293B;
            --text-muted: #94A3B8; --border: #E2E8F0;
            --shadow: 0 4px 16px rgba(0,0,0,0.06), 0 2px 4px rgba(0,0,0,0.04);
            --shadow-lg: 0 12px 40px rgba(0,0,0,0.08), 0 4px 12px rgba(0,0,0,0.04);
            --radius: 16px;
        }
        * { box-sizing: border-box; }
        body {
            background: var(--bg);
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
            color: var(--text);
            padding-top: 64px;
            -webkit-font-smoothing: antialiased;
        }
        .navbar {
            background: rgba(255,255,255,0.85) !important;
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--border);
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }
        .navbar .navbar-brand {
            font-weight: 700; font-size: 1.25rem;
            background: linear-gradient(135deg, var(--primary), #8B5CF6);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
        }
        .navbar .nav-link { color: var(--text) !important; font-weight: 500; font-size: 0.9rem; }
        .navbar .nav-link:hover, .navbar .nav-link.active { color: var(--primary) !important; }
        .filter-bar {
            background: var(--card); border-radius: var(--radius);
            box-shadow: var(--shadow); padding: 18px 22px; margin-bottom: 24px;
        }
        .filter-bar .form-control {
            border-radius: 10px; border: 2px solid var(--border);
            font-size: 0.9rem; transition: all 0.3s;
        }
        .filter-bar .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(91,106,240,0.08);
        }
        .filter-bar .btn {
            border-radius: 10px; font-weight: 600; font-size: 0.9rem; padding: 8px 20px;
        }
        .item-card {
            background: var(--card); border-radius: var(--radius);
            overflow: hidden; box-shadow: var(--shadow);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            height: 100%; border: 1px solid transparent;
        }
        .item-card:hover { transform: translateY(-5px); box-shadow: var(--shadow-lg); border-color: #E8ECF8; }
        .item-card .card-img-wrap { position: relative; height: 180px; overflow: hidden; background: #F1F5F9; }
        .item-card .card-img-wrap img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s; }
        .item-card:hover .card-img-wrap img { transform: scale(1.06); }
        .item-card .card-img-placeholder {
            width: 100%; height: 100%; display: flex; align-items: center; justify-content: center;
            background: linear-gradient(135deg, #F1F5F9, #E2E8F0); color: #CBD5E1; font-size: 2.5rem;
        }
        .item-card .card-body { padding: 16px 18px; }
        .item-card .card-title { font-size: 0.98rem; font-weight: 650; margin-bottom: 6px; line-height: 1.4; }
        .item-card .card-title a { color: var(--text); text-decoration: none; transition: color 0.2s; }
        .item-card .card-title a:hover { color: var(--primary); }
        .item-card .card-meta { font-size: 0.8rem; color: var(--text-muted); margin-bottom: 10px; display: flex; gap: 12px; }
        .item-card .card-meta span i { margin-right: 3px; }
        .item-card .card-footer-row { display: flex; justify-content: space-between; align-items: center; font-size: 0.78rem; }
        .badge-status {
            display: inline-block; padding: 3px 10px; border-radius: 12px;
            font-size: 0.76rem; font-weight: 600;
        }
        .badge-status.status-1 { background: #FEF3C7; color: #B45309; }
        .badge-status.status-2 { background: #DBEAFE; color: #1E40AF; }
        .page-link { color: var(--primary); border: none; border-radius: 10px !important; margin: 0 3px; }
        .page-item.active .page-link { background: var(--primary); color: #fff; }
        .page-item.disabled .page-link { color: #CBD5E1; }
        .site-footer { margin-top: 50px; padding: 24px 0; text-align: center; color: #94A3B8; font-size: 0.85rem; border-top: 1px solid var(--border); }
        .empty-state { text-align: center; padding: 50px 20px; color: #B0B8C8; }
        .empty-state i { font-size: 3rem; margin-bottom: 10px; display: block; }
        @media (max-width: 768px) { .item-card .card-img-wrap { height: 150px; } }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg fixed-top">
    <div class="container">
        <a class="navbar-brand" href="index.jsp"><i class="fas fa-search-location mr-1"></i>校园失物招领</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#mainNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="mainNav">
            <ul class="navbar-nav mr-auto ml-3">
                <li class="nav-item"><a class="nav-link" href="index.jsp">首页</a></li>
                <li class="nav-item"><a class="nav-link" href="lost-list.jsp">失物招领</a></li>
                <li class="nav-item"><a class="nav-link active" href="found-list.jsp">物品寻主</a></li>
                <li class="nav-item"><a class="nav-link" href="publish-lost.jsp">发布失物</a></li>
                <li class="nav-item"><a class="nav-link" href="publish-found.jsp">发布招领</a></li>
            </ul>
            <%
                User sessionUser = (User) session.getAttribute("user");
                if (sessionUser != null) {
            %>
            <ul class="navbar-nav">
                <li class="nav-item"><a class="nav-link" href="user-center.jsp"><i class="fas fa-user-circle mr-1"></i><%= sessionUser.getNickname() %></a></li>
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
    <h3 style="font-weight:700;margin-bottom:20px;"><i class="fas fa-hand-holding-heart" style="color:#10B981;"></i> 物品寻主</h3>

    <div class="filter-bar">
        <form class="form-inline" id="filterForm">
            <input type="text" class="form-control mr-2 mb-2" name="keyword" placeholder="搜索物品名称、地点..." value="<%= keyword != null ? keyword : "" %>" style="min-width:220px;">
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
            <button type="submit" class="btn btn-success mb-2"><i class="fas fa-search mr-1"></i>筛选</button>
        </form>
    </div>

    <div class="row">
        <% for (FoundItem item : pageInfo.getList()) { %>
        <div class="col-md-4 col-lg-4 mb-4">
            <div class="item-card">
                <a href="${pageContext.request.contextPath}/FoundItemServlet?action=detail&itemId=<%= item.getItemId() %>">
                    <div class="card-img-wrap">
                        <% if (item.getImage() != null && !item.getImage().isEmpty()) { %>
                            <img src="<%= item.getImage() %>" alt="<%= item.getTitle() %>">
                        <% } else { %>
                            <div class="card-img-placeholder"><i class="fas fa-image"></i></div>
                        <% } %>
                    </div>
                </a>
                <div class="card-body">
                    <div class="card-title">
                        <a href="${pageContext.request.contextPath}/FoundItemServlet?action=detail&itemId=<%= item.getItemId() %>"><%= item.getTitle() %></a>
                    </div>
                    <div class="card-meta">
                        <span><i class="fas fa-map-marker-alt"></i> <%= item.getFoundPlace() != null ? item.getFoundPlace() : "未知" %></span>
                        <span><i class="fas fa-tag"></i> <%= item.getCategory() %></span>
                    </div>
                    <div class="card-footer-row">
                        <span class="badge-status <%= item.getStatus() == 1 ? "status-1" : "status-2" %>"><%= item.getStatusText() %></span>
                        <span style="color:var(--text-muted);"><%= item.getNickname() != null ? item.getNickname() : "" %></span>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
        <% if (pageInfo.getList().isEmpty()) { %>
        <div class="col-12"><div class="empty-state"><i class="fas fa-inbox"></i><p>没有找到相关招领信息</p></div></div>
        <% } %>
    </div>

    <% if (pageInfo.getTotalPage() > 1) { %>
    <nav class="mt-2">
        <ul class="pagination justify-content-center">
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

<footer class="site-footer"><div class="container">&copy; 2026 校园失物招领互助平台</div></footer>
<div class="toast-container"></div>

<script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/js/bootstrap.bundle.min.js"></script>
<script>
    var contextPath = '${pageContext.request.contextPath}';
</script>
<script src="js/common.js"></script>
</body>
</html>
