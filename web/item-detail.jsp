<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lostfound.entity.*, com.lostfound.service.*, java.util.*" %>
<%
    String itemType = (String) request.getAttribute("itemType");
    Object itemObj = request.getAttribute("item");
    if (itemObj == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    User sessionUser = (User) session.getAttribute("user");
    CommentService commentService = new CommentService();
    int itemId = 0;
    String title = "", category = "", description = "", place = "", timeStr = "", image = "", contact = "", nickname = "";
    int status = 0, userId = 0;
    Date createTime = null;
    String statusText = "";

    if ("lost".equals(itemType)) {
        LostItem item = (LostItem) itemObj;
        itemId = item.getItemId(); title = item.getTitle(); category = item.getCategory();
        description = item.getDescription(); place = item.getLostPlace();
        timeStr = item.getLostTime() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(item.getLostTime()) : "";
        image = item.getImage(); contact = item.getContact(); status = item.getStatus();
        userId = item.getUserId(); createTime = item.getCreateTime();
        nickname = item.getNickname(); statusText = item.getStatusText();
    } else {
        FoundItem item = (FoundItem) itemObj;
        itemId = item.getItemId(); title = item.getTitle(); category = item.getCategory();
        description = item.getDescription(); place = item.getFoundPlace();
        timeStr = item.getFoundTime() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(item.getFoundTime()) : "";
        image = item.getImage(); contact = item.getContact(); status = item.getStatus();
        userId = item.getUserId(); createTime = item.getCreateTime();
        nickname = item.getNickname(); statusText = item.getStatusText();
    }
    List<Comment> comments = commentService.findByItemId(itemId, "lost".equals(itemType) ? 0 : 1);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= title %> - 校园失物招领</title>
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
            <% if (sessionUser != null) { %>
            <ul class="navbar-nav">
                <li class="nav-item"><a class="nav-link" href="user-center.jsp"><i class="fas fa-user"></i> <%= sessionUser.getNickname() %></a></li>
            </ul>
            <% } %>
        </div>
    </div>
</nav>

<div class="container" style="margin-top:20px; max-width:900px;">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="index.jsp">首页</a></li>
            <li class="breadcrumb-item"><a href="<%= "lost".equals(itemType) ? "lost-list.jsp" : "found-list.jsp" %>"><%= "lost".equals(itemType) ? "失物招领" : "物品寻主" %></a></li>
            <li class="breadcrumb-item active"><%= title %></li>
        </ol>
    </nav>

    <div class="card mb-3">
        <div class="card-body">
            <div class="row">
                <div class="col-md-5">
                    <% if (image != null && !image.isEmpty()) { %>
                        <img src="<%= image %>" class="detail-img" alt="<%= title %>"
                             onclick="openLightbox(this.src)" style="cursor:zoom-in;" title="点击查看大图">
                    <% } else { %>
                        <div style="width:100%;height:300px;background:#e9ecef;display:flex;align-items:center;justify-content:center;border-radius:8px;">
                            <i class="fas fa-image" style="font-size:3rem;color:#adb5bd;"></i>
                        </div>
                    <% } %>
                </div>
                <div class="col-md-7">
                    <h3><%= title %></h3>
                    <span class="status-badge <%= status == 1 ? "status-active" : "status-resolved" %>" style="font-size:1rem;">
                        <%= statusText %>
                    </span>
                    <hr>
                    <table class="table table-sm">
                        <tr><td width="100"><strong>物品分类</strong></td><td><%= category %></td></tr>
                        <tr><td><strong><%= "lost".equals(itemType) ? "丢失时间" : "捡到时间" %></strong></td><td><%= timeStr %></td></tr>
                        <tr><td><strong><%= "lost".equals(itemType) ? "丢失地点" : "捡到地点" %></strong></td><td><%= place != null ? place : "未填写" %></td></tr>
                        <tr><td><strong>发布者</strong></td><td><%= nickname != null ? nickname : "匿名" %></td></tr>
                        <tr><td><strong>联系方式</strong></td><td><%= contact != null ? contact : "未填写" %></td></tr>
                        <tr><td><strong>发布时间</strong></td><td><%= createTime != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(createTime) : "" %></td></tr>
                    </table>
                </div>
            </div>
            <% if (description != null && !description.isEmpty()) { %>
            <hr>
            <h5>详细描述</h5>
            <p style="white-space:pre-line;"><%= description %></p>
            <% } %>
            <hr>
            <div class="d-flex justify-content-between align-items-center">
                <% if ("lost".equals(itemType) && status == 3) { %>
                    <div class="alert alert-success mb-0 py-2" style="width:100%;">
                        <i class="fas fa-check-circle"></i> <strong>此物品已被认领</strong>
                    </div>
                <% } else if ("lost".equals(itemType) && status == 2) { %>
                    <div class="alert alert-info mb-0 py-2" style="width:100%;">
                        <i class="fas fa-check"></i> 此物品已被标记为<strong>已找回</strong>
                    </div>
                <% } else if (sessionUser != null && sessionUser.getUserId() != userId && "lost".equals(itemType) && status == 1) { %>
                    <button class="btn btn-success" onclick="claimItem(<%= itemId %>)" style="font-size:1rem;padding:8px 30px;">
                        <i class="fas fa-hand-paper"></i> 认领此物
                    </button>
                    <small class="text-muted">你找到了这个失物？点击认领</small>
                <% } else if (sessionUser != null && sessionUser.getUserId() == userId && status == 1) { %>
                    <button class="btn btn-outline-success btn-sm" onclick="markResolved(<%= itemId %>, '<%= itemType %>')">
                        <i class="fas fa-check"></i> 标记已找回
                    </button>
                <% } %>
            </div>
        </div>
    </div>

    <!-- 留言区 -->
    <div class="card">
        <div class="card-body">
            <h5><i class="fas fa-comments"></i> 留言互动 (<span id="commentCount"><%= comments.size() %></span>)</h5>
            <hr>

            <% if (sessionUser != null) { %>
            <div class="form-group">
                <textarea class="form-control" id="commentContent" rows="3" placeholder="发表你的留言..."></textarea>
                <button class="btn btn-primary mt-2" onclick="addComment()"><i class="fas fa-paper-plane"></i> 发表留言</button>
            </div>
            <% } else { %>
            <div class="alert alert-info">请<a href="auth.jsp">登录</a>后发表留言</div>
            <% } %>

            <div class="comment-list mt-3" id="commentList">
                <% for (Comment c : comments) { %>
                <div class="comment-item">
                    <div class="d-flex">
                        <div class="comment-avatar mr-3">
                            <%= c.getNickname() != null ? c.getNickname().substring(0,1) : "匿" %>
                        </div>
                        <div class="flex-grow-1">
                            <strong><%= c.getNickname() != null ? c.getNickname() : "匿名" %></strong>
                            <small class="text-muted ml-2"><%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(c.getCreateTime()) %></small>
                            <p class="mb-0 mt-1"><%= c.getContent() %></p>
                            <% if (sessionUser != null && sessionUser.getUserId() == c.getUserId()) { %>
                            <a href="javascript:void(0)" class="text-danger small" onclick="deleteComment(<%= c.getCommentId() %>)">删除</a>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% } %>
                <% if (comments.isEmpty()) { %>
                <p class="text-muted text-center">暂无留言，快来发表第一条留言吧~</p>
                <% } %>
            </div>
        </div>
    </div>
</div>

<footer class="footer"><div class="container"><p class="mb-0">&copy; 2026 校园失物招领互助平台</p></div></footer>
<div class="toast-container"></div>

<script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="js/common.js"></script>
<script>
    var contextPath = '${pageContext.request.contextPath}';
    var itemId = <%= itemId %>;
    var itemType = <%= "lost".equals(itemType) ? 0 : 1 %>;

    function addComment() {
        var content = $('#commentContent').val().trim();
        if (!content) { showToast('请输入留言内容', 'error'); return; }
        $.post(contextPath + '/CommentServlet', {
            action: 'add', itemId: itemId, itemType: itemType, content: content
        }, function(res){
            if (res.code === 1) {
                showToast('留言成功');
                setTimeout(function(){ location.reload(); }, 500);
            } else { showToast(res.msg, 'error'); }
        }, 'json');
    }

    function deleteComment(commentId) {
        if (!confirm('确定删除此留言吗？')) return;
        $.post(contextPath + '/CommentServlet', {
            action: 'delete', commentId: commentId
        }, function(res){
            if (res.code === 1) {
                showToast('删除成功');
                setTimeout(function(){ location.reload(); }, 500);
            } else { showToast(res.msg, 'error'); }
        }, 'json');
    }

    function markResolved(itemId, itemType) {
        var url = itemType === 'lost' ? contextPath + '/LostItemServlet' : contextPath + '/FoundItemServlet';
        if (!confirm('确定标记为已完成吗？')) return;
        $.post(url, { action: 'updateStatus', itemId: itemId, status: 2 }, function(res){
            if (res.code === 1) {
                showToast('状态已更新');
                setTimeout(function(){ location.reload(); }, 500);
            } else { showToast(res.msg, 'error'); }
        }, 'json');
    }

    function claimItem(itemId) {
        if (!confirm('确认认领此失物吗？认领后物品状态将变更为"已认领"。')) return;
        $.post(contextPath + '/LostItemServlet', { action: 'claim', itemId: itemId }, function(res){
            if (res.code === 1) {
                showToast('认领成功！');
                setTimeout(function(){ location.reload(); }, 500);
            } else { showToast(res.msg, 'error'); }
        }, 'json');
    }

    function openLightbox(src) {
        document.getElementById('lightboxImg').src = src;
        document.getElementById('lightbox').style.display = 'block';
    }
    function closeLightbox() {
        document.getElementById('lightbox').style.display = 'none';
    }
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeLightbox();
    });
</script>
<!-- 图片放大遮罩 -->
<div id="lightbox" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.9);z-index:9999;cursor:zoom-out;" onclick="closeLightbox()">
    <span style="position:absolute;top:20px;right:30px;color:#fff;font-size:2.5rem;font-weight:bold;cursor:pointer;z-index:10000;">&times;</span>
    <img id="lightboxImg" style="max-width:90%;max-height:90%;position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);border-radius:8px;box-shadow:0 0 40px rgba(0,0,0,0.5);">
</div>

</body>
</html>
