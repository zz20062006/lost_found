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
        :root {
            --primary: #5B6AF0;
            --primary-light: #EEF0FF;
            --accent: #F59E0B;
            --success: #10B981;
            --danger: #EF4444;
            --bg: #F8F9FC;
            --card: #FFFFFF;
            --text: #1E293B;
            --text-muted: #94A3B8;
            --border: #E2E8F0;
            --shadow-sm: 0 1px 3px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.06);
            --shadow: 0 4px 16px rgba(0,0,0,0.06), 0 2px 4px rgba(0,0,0,0.04);
            --shadow-lg: 0 12px 40px rgba(0,0,0,0.08), 0 4px 12px rgba(0,0,0,0.04);
            --radius: 16px;
            --radius-sm: 10px;
        }
        * { box-sizing: border-box; }
        body {
            background: var(--bg);
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
            color: var(--text);
            padding-top: 64px;
            -webkit-font-smoothing: antialiased;
        }

        /* ===== NAVBAR ===== */
        .navbar {
            background: rgba(255,255,255,0.85) !important;
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--border);
            box-shadow: var(--shadow-sm);
        }
        .navbar .navbar-brand {
            font-weight: 700;
            font-size: 1.25rem;
            background: linear-gradient(135deg, var(--primary), #8B5CF6);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .navbar .nav-link { color: var(--text) !important; font-weight: 500; font-size: 0.9rem; transition: color 0.2s; }
        .navbar .nav-link:hover, .navbar .nav-link.active { color: var(--primary) !important; }
        .navbar .form-control {
            border-radius: 20px;
            border: 2px solid var(--border);
            background: var(--bg);
            font-size: 0.85rem;
            transition: all 0.3s;
        }
        .navbar .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(91,106,240,0.1);
        }

        /* ===== HERO ===== */
        .hero {
            position: relative;
            overflow: hidden;
            padding: 56px 0 48px;
            background: linear-gradient(160deg, #EEF2FF 0%, #F0F4FF 25%, #FAF5FF 50%, #FDF2F8 75%, #F0FDF4 100%);
        }
        .hero::before {
            content: '';
            position: absolute;
            width: 500px; height: 500px;
            background: radial-gradient(circle, rgba(91,106,240,0.12) 0%, transparent 70%);
            top: -150px; right: -100px;
            border-radius: 50%;
        }
        .hero::after {
            content: '';
            position: absolute;
            width: 350px; height: 350px;
            background: radial-gradient(circle, rgba(139,92,246,0.10) 0%, transparent 70%);
            bottom: -80px; left: -80px;
            border-radius: 50%;
        }
        .hero-content { position: relative; z-index: 1; }
        .hero h1 {
            font-size: 2.5rem;
            font-weight: 800;
            background: linear-gradient(135deg, #4F46E5 0%, #7C3AED 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 12px;
        }
        .hero p { color: #64748B; font-size: 1.1rem; max-width: 560px; margin: 0 auto 28px; line-height: 1.7; }
        .hero .search-box {
            max-width: 580px; margin: 0 auto;
            background: #fff;
            border-radius: 50px;
            padding: 6px;
            box-shadow: 0 8px 30px rgba(91,106,240,0.15), 0 2px 8px rgba(0,0,0,0.04);
            display: flex;
            transition: box-shadow 0.3s;
        }
        .hero .search-box:focus-within { box-shadow: 0 12px 40px rgba(91,106,240,0.25), 0 4px 12px rgba(0,0,0,0.06); }
        .hero .search-box input {
            flex: 1; border: none; outline: none;
            padding: 14px 20px; font-size: 1rem;
            background: transparent; color: var(--text);
        }
        .hero .search-box input::placeholder { color: #B0B8C8; }
        .hero .search-box button {
            background: var(--primary); color: #fff; border: none;
            border-radius: 50px; padding: 12px 28px;
            font-weight: 600; font-size: 0.95rem;
            cursor: pointer; transition: all 0.3s;
        }
        .hero .search-box button:hover { background: #4A5AE0; transform: scale(1.02); }
        .hero .hero-btns { margin-top: 22px; display: flex; gap: 14px; justify-content: center; flex-wrap: wrap; }
        .hero .hero-btns a {
            padding: 10px 26px; border-radius: 50px;
            font-weight: 600; font-size: 0.9rem;
            text-decoration: none; transition: all 0.3s;
        }
        .btn-hero-primary {
            background: var(--primary); color: #fff;
            box-shadow: 0 4px 14px rgba(91,106,240,0.35);
        }
        .btn-hero-primary:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(91,106,240,0.45); color: #fff; text-decoration: none; }
        .btn-hero-outline {
            background: #fff; color: var(--primary);
            border: 2px solid #E0E4F0;
        }
        .btn-hero-outline:hover { border-color: var(--primary); transform: translateY(-2px); color: var(--primary); text-decoration: none; }

        /* ===== SECTION HEADER ===== */
        .section-header { display: flex; justify-content: space-between; align-items: center; margin: 48px 0 20px; }
        .section-header h3 { font-weight: 700; font-size: 1.35rem; color: var(--text); margin: 0; }
        .section-header h3 i { margin-right: 8px; }
        .section-header .more-link { font-size: 0.85rem; font-weight: 600; color: var(--primary); text-decoration: none; padding: 6px 16px; border-radius: 20px; background: var(--primary-light); transition: all 0.2s; }
        .section-header .more-link:hover { background: #DDE2FF; text-decoration: none; }

        /* ===== ITEM CARD ===== */
        .item-card {
            background: var(--card);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: var(--shadow);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            height: 100%;
            border: 1px solid transparent;
        }
        .item-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-lg);
            border-color: #E8ECF8;
        }
        .item-card .card-img-wrap {
            position: relative;
            height: 180px;
            overflow: hidden;
            background: #F1F5F9;
        }
        .item-card .card-img-wrap img {
            width: 100%; height: 100%;
            object-fit: cover;
            transition: transform 0.4s;
        }
        .item-card:hover .card-img-wrap img { transform: scale(1.06); }
        .item-card .card-img-placeholder {
            width: 100%; height: 100%;
            display: flex; align-items: center; justify-content: center;
            background: linear-gradient(135deg, #F1F5F9, #E2E8F0);
            color: #CBD5E1; font-size: 2.5rem;
        }
        .item-card .card-body { padding: 16px 18px; }
        .item-card .card-title {
            font-size: 0.98rem; font-weight: 650;
            margin-bottom: 6px;
            line-height: 1.4;
        }
        .item-card .card-title a {
            color: var(--text); text-decoration: none;
            transition: color 0.2s;
        }
        .item-card .card-title a:hover { color: var(--primary); }
        .item-card .card-meta {
            font-size: 0.8rem; color: var(--text-muted);
            margin-bottom: 10px;
            display: flex; gap: 12px; align-items: center;
        }
        .item-card .card-meta span i { margin-right: 3px; }
        .item-card .card-footer-row {
            display: flex; justify-content: space-between; align-items: center;
            font-size: 0.78rem;
        }
        .item-card .card-footer-row .publisher { color: var(--text-muted); }

        /* status badges */
        .badge-status {
            display: inline-block; padding: 3px 10px; border-radius: 12px;
            font-size: 0.76rem; font-weight: 600; letter-spacing: 0.3px;
        }
        .badge-status.status-1 { background: #FEF3C7; color: #B45309; }
        .badge-status.status-2 { background: #DBEAFE; color: #1E40AF; }
        .badge-status.status-3 { background: #D1FAE5; color: #065F46; }

        /* ===== FEATURE SECTION ===== */
        .features-row { display: flex; gap: 16px; margin: 32px 0; flex-wrap: wrap; }
        .feature-item {
            flex: 1; min-width: 200px;
            text-align: center; padding: 28px 20px;
            background: var(--card); border-radius: var(--radius);
            box-shadow: var(--shadow);
            transition: all 0.3s;
            border: 1px solid transparent;
        }
        .feature-item:hover { transform: translateY(-3px); box-shadow: var(--shadow-lg); border-color: #E8ECF8; }
        .feature-item .feature-icon {
            width: 56px; height: 56px; margin: 0 auto 14px;
            border-radius: 16px; display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem;
        }
        .feature-item h6 { font-weight: 700; font-size: 0.95rem; margin-bottom: 4px; color: var(--text); }
        .feature-item p { font-size: 0.8rem; color: var(--text-muted); margin: 0; }

        /* ===== ANNOUNCEMENT ===== */
        .announce-card {
            background: var(--card); border-radius: var(--radius);
            box-shadow: var(--shadow); padding: 24px 28px;
            border-left: 4px solid var(--accent);
        }
        .announce-card h4 { font-weight: 700; color: var(--text); margin-bottom: 16px; }
        .announce-card .announce-item {
            padding: 12px 0;
            border-bottom: 1px dashed var(--border);
        }
        .announce-card .announce-item:last-child { border-bottom: none; }
        .announce-card .announce-item h6 { font-weight: 650; color: var(--text); margin-bottom: 4px; font-size: 0.95rem; }
        .announce-card .announce-item p { font-size: 0.85rem; color: #64748B; margin-bottom: 4px; white-space: pre-line; line-height: 1.6; }
        .announce-card .announce-item .ann-date { font-size: 0.75rem; color: #A0AEC0; }

        /* ===== FOOTER ===== */
        .site-footer {
            margin-top: 60px; padding: 28px 0;
            text-align: center; color: #94A3B8; font-size: 0.85rem;
            border-top: 1px solid var(--border);
        }

        /* ===== EMPTY ===== */
        .empty-state { text-align: center; padding: 50px 20px; color: #B0B8C8; }
        .empty-state i { font-size: 3rem; margin-bottom: 10px; display: block; }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 768px) {
            .hero h1 { font-size: 1.7rem; }
            .hero p { font-size: 0.95rem; }
            .features-row { gap: 12px; }
            .feature-item { min-width: 42%; }
            .item-card .card-img-wrap { height: 150px; }
        }
    </style>
</head>
<body>

<!-- ========== NAVBAR ========== -->
<nav class="navbar navbar-expand-lg fixed-top">
    <div class="container">
        <a class="navbar-brand" href="index.jsp"><i class="fas fa-search-location mr-1"></i>校园失物招领</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#mainNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="mainNav">
            <ul class="navbar-nav mr-auto ml-3">
                <li class="nav-item"><a class="nav-link active" href="index.jsp">首页</a></li>
                <li class="nav-item"><a class="nav-link" href="lost-list.jsp">失物招领</a></li>
                <li class="nav-item"><a class="nav-link" href="found-list.jsp">物品寻主</a></li>
                <li class="nav-item"><a class="nav-link" href="publish-lost.jsp">发布失物</a></li>
                <li class="nav-item"><a class="nav-link" href="publish-found.jsp">发布招领</a></li>
            </ul>
            <form class="form-inline mr-2" onsubmit="return false;">
                <input class="form-control mr-1" id="globalSearch" type="search" placeholder="搜索物品..." style="width:170px;">
            </form>
            <ul class="navbar-nav">
                <% User sessionUser = (User) session.getAttribute("user");
                   if (sessionUser != null) { %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" data-toggle="dropdown" style="font-weight:600;">
                            <i class="fas fa-user-circle mr-1"></i><%= sessionUser.getNickname() != null ? sessionUser.getNickname() : sessionUser.getUsername() %>
                        </a>
                        <div class="dropdown-menu dropdown-menu-right" style="border:none;box-shadow:var(--shadow-lg);border-radius:12px;">
                            <a class="dropdown-item" href="user-center.jsp"><i class="fas fa-id-card mr-2"></i>个人中心</a>
                            <% if (sessionUser.getRole() == 1) { %>
                            <a class="dropdown-item" href="admin/index.jsp"><i class="fas fa-shield-alt mr-2"></i>管理后台</a>
                            <% } %>
                            <div class="dropdown-divider"></div>
                            <a class="dropdown-item" href="${pageContext.request.contextPath}/UserServlet?action=logout"><i class="fas fa-sign-out-alt mr-2"></i>退出登录</a>
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

<!-- ========== HERO ========== -->
<section class="hero text-center">
    <div class="container hero-content">
        <h1>让每一件失物都找到回家的路</h1>
        <p>丢了东西？捡到物品？在这里发布信息，全校师生互帮互助，让失物早日物归原主</p>
        <div class="search-box">
            <input type="text" id="heroSearch" placeholder="输入物品名称、地点或分类...">
            <button onclick="searchItem()"><i class="fas fa-search mr-1"></i>搜索</button>
        </div>
        <div class="hero-btns">
            <a href="publish-lost.jsp" class="btn-hero-primary"><i class="fas fa-edit mr-1"></i>发布失物</a>
            <a href="publish-found.jsp" class="btn-hero-outline"><i class="fas fa-gift mr-1"></i>发布招领</a>
        </div>
    </div>
</section>

<div class="container">
    <!-- ========== FEATURES ========== -->
    <div class="features-row">
        <div class="feature-item">
            <div class="feature-icon" style="background:#EEF2FF;color:#5B6AF0;"><i class="fas fa-clipboard-list"></i></div>
            <h6>快速发布</h6>
            <p>一键发布失物或招领</p>
        </div>
        <div class="feature-item">
            <div class="feature-icon" style="background:#FEF3C7;color:#F59E0B;"><i class="fas fa-search"></i></div>
            <h6>智能搜索</h6>
            <p>按名称/地点/分类检索</p>
        </div>
        <div class="feature-item">
            <div class="feature-icon" style="background:#D1FAE5;color:#10B981;"><i class="fas fa-hand-paper"></i></div>
            <h6>在线认领</h6>
            <p>一键认领，快速匹配</p>
        </div>
        <div class="feature-item">
            <div class="feature-icon" style="background:#FCE7F3;color:#EC4899;"><i class="fas fa-shield-alt"></i></div>
            <h6>安全可靠</h6>
            <p>实名认证，管理员审核</p>
        </div>
    </div>

    <!-- ========== LATEST LOST ========== -->
    <div class="section-header">
        <h3><i class="fas fa-exclamation-circle" style="color:#EF4444;"></i>最新失物</h3>
        <a href="lost-list.jsp" class="more-link">查看全部 <i class="fas fa-arrow-right ml-1"></i></a>
    </div>
    <div class="row">
        <% for (LostItem item : latestLost) { %>
        <div class="col-md-4 col-lg-4 mb-4">
            <div class="item-card">
                <a href="${pageContext.request.contextPath}/LostItemServlet?action=detail&itemId=<%= item.getItemId() %>">
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
                        <a href="${pageContext.request.contextPath}/LostItemServlet?action=detail&itemId=<%= item.getItemId() %>"><%= item.getTitle() %></a>
                    </div>
                    <div class="card-meta">
                        <span><i class="fas fa-map-marker-alt"></i> <%= item.getLostPlace() != null ? item.getLostPlace() : "未知" %></span>
                        <span><i class="fas fa-tag"></i> <%= item.getCategory() %></span>
                    </div>
                    <div class="card-footer-row">
                        <span class="badge-status status-<%= item.getStatus() %>"><%= item.getStatusText() %></span>
                        <span class="publisher"><%= item.getNickname() != null ? item.getNickname() : "" %></span>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
        <% if (latestLost.isEmpty()) { %>
        <div class="col-12"><div class="empty-state"><i class="fas fa-inbox"></i><p>还没有失物信息，快来发布第一条吧</p></div></div>
        <% } %>
    </div>

    <!-- ========== LATEST FOUND ========== -->
    <div class="section-header">
        <h3><i class="fas fa-hand-holding-heart" style="color:#10B981;"></i>最新招领</h3>
        <a href="found-list.jsp" class="more-link">查看全部 <i class="fas fa-arrow-right ml-1"></i></a>
    </div>
    <div class="row">
        <% for (FoundItem item : latestFound) { %>
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
                        <span class="publisher"><%= item.getNickname() != null ? item.getNickname() : "" %></span>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
        <% if (latestFound.isEmpty()) { %>
        <div class="col-12"><div class="empty-state"><i class="fas fa-inbox"></i><p>还没有招领信息，快来发布第一条吧</p></div></div>
        <% } %>
    </div>

    <!-- ========== RESOLVED ========== -->
    <% if (!resolvedItems.isEmpty()) { %>
    <div class="section-header">
        <h3><i class="fas fa-check-circle" style="color:#10B981;"></i>已找回 / 已认领</h3>
        <a href="resolved-list.jsp" class="more-link">查看全部 <i class="fas fa-arrow-right ml-1"></i></a>
    </div>
    <div class="row">
        <% for (LostItem item : resolvedItems) { %>
        <div class="col-md-4 col-lg-4 mb-4">
            <div class="item-card" style="opacity:0.82;">
                <a href="${pageContext.request.contextPath}/LostItemServlet?action=detail&itemId=<%= item.getItemId() %>">
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
                        <a href="${pageContext.request.contextPath}/LostItemServlet?action=detail&itemId=<%= item.getItemId() %>"><%= item.getTitle() %></a>
                    </div>
                    <div class="card-meta">
                        <span><i class="fas fa-map-marker-alt"></i> <%= item.getLostPlace() != null ? item.getLostPlace() : "未知" %></span>
                        <span><i class="fas fa-tag"></i> <%= item.getCategory() %></span>
                    </div>
                    <div class="card-footer-row">
                        <span class="badge-status status-3"><i class="fas fa-check mr-1"></i><%= item.getStatusText() %></span>
                        <span class="publisher"><%= item.getNickname() != null ? item.getNickname() : "" %></span>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>

    <!-- ========== ANNOUNCEMENTS ========== -->
    <div class="section-header">
        <h3><i class="fas fa-bullhorn" style="color:#F59E0B;"></i>校园公告</h3>
    </div>
    <div class="announce-card">
        <% for (Announcement a : announcements) { %>
        <div class="announce-item">
            <h6><%= a.getTitle() %></h6>
            <p><%= a.getContent() != null ? a.getContent() : "" %></p>
            <span class="ann-date"><i class="far fa-clock mr-1"></i><%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(a.getCreateTime()) %></span>
        </div>
        <% } %>
        <% if (announcements.isEmpty()) { %>
        <p style="color:#A0AEC0;text-align:center;margin:0;">暂无公告</p>
        <% } %>
    </div>
</div>

<!-- ========== FOOTER ========== -->
<footer class="site-footer">
    <div class="container">&copy; 2026 校园失物招领互助平台 — 让每一件失物都找到回家的路</div>
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
