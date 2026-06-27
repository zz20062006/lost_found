<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lostfound.entity.*, com.lostfound.service.*, com.lostfound.util.*, java.util.*" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect("auth.jsp");
        return;
    }
    LostItemService lostItemService = new LostItemService();
    FoundItemService foundItemService = new FoundItemService();
    CommentService commentService = new CommentService();
    PageInfo<LostItem> myLost = lostItemService.findByUserId(sessionUser.getUserId(), 1, 5);
    PageInfo<FoundItem> myFound = foundItemService.findByUserId(sessionUser.getUserId(), 1, 5);
    PageInfo<Comment> myComments = commentService.findByUserId(sessionUser.getUserId(), 1, 5);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>个人中心 - 校园失物招领</title>
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
            <ul class="navbar-nav">
                <li class="nav-item active"><a class="nav-link" href="user-center.jsp"><i class="fas fa-user"></i> <%= sessionUser.getNickname() %></a></li>
                <li class="nav-item"><a class="nav-link" href="UserServlet?action=logout">退出</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container" style="margin-top:20px;">
    <div class="row">
        <!-- 左侧导航 -->
        <div class="col-md-3">
            <div class="profile-sidebar mb-3">
                <div class="text-center mb-3">
                    <div style="width:70px;height:70px;border-radius:50%;background:#667eea;color:#fff;display:inline-flex;align-items:center;justify-content:center;font-size:1.8rem;font-weight:bold;">
                        <%= sessionUser.getNickname() != null ? sessionUser.getNickname().substring(0,1) : "U" %>
                    </div>
                    <h5 class="mt-2"><%= sessionUser.getNickname() %></h5>
                    <small class="text-muted">@<%= sessionUser.getUsername() %></small>
                </div>
                <nav class="nav flex-column">
                    <a class="nav-link active" href="#profileTab" data-toggle="tab"><i class="fas fa-id-card mr-2"></i>个人信息</a>
                    <a class="nav-link" href="#myLostTab" data-toggle="tab"><i class="fas fa-exclamation-circle mr-2"></i>我的失物</a>
                    <a class="nav-link" href="#myFoundTab" data-toggle="tab"><i class="fas fa-gift mr-2"></i>我的招领</a>
                    <a class="nav-link" href="#myCommentsTab" data-toggle="tab"><i class="fas fa-comments mr-2"></i>我的留言</a>
                </nav>
            </div>
        </div>

        <!-- 右侧内容 -->
        <div class="col-md-9">
            <div class="tab-content">
                <!-- 个人信息 -->
                <div class="tab-pane fade show active" id="profileTab">
                    <div class="card">
                        <div class="card-body">
                            <h4><i class="fas fa-id-card"></i> 个人信息</h4>
                            <hr>
                            <form id="profileForm">
                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">用户名</label>
                                    <div class="col-sm-9">
                                        <input type="text" class="form-control" value="<%= sessionUser.getUsername() %>" disabled>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">昵称</label>
                                    <div class="col-sm-9">
                                        <input type="text" class="form-control" name="nickname" value="<%= sessionUser.getNickname() != null ? sessionUser.getNickname() : "" %>">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">手机号</label>
                                    <div class="col-sm-9">
                                        <input type="text" class="form-control" name="phone" value="<%= sessionUser.getPhone() != null ? sessionUser.getPhone() : "" %>">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">邮箱</label>
                                    <div class="col-sm-9">
                                        <input type="email" class="form-control" name="email" value="<%= sessionUser.getEmail() != null ? sessionUser.getEmail() : "" %>">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">新密码</label>
                                    <div class="col-sm-9">
                                        <input type="password" class="form-control" name="password" placeholder="留空则不修改">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <div class="col-sm-9 offset-sm-3">
                                        <button type="submit" class="btn btn-primary">保存修改</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- 我的失物 -->
                <div class="tab-pane fade" id="myLostTab">
                    <div class="card">
                        <div class="card-body">
                            <h4><i class="fas fa-exclamation-circle"></i> 我的失物</h4>
                            <hr>
                            <% for (LostItem item : myLost.getList()) { %>
                            <div class="d-flex justify-content-between align-items-center border-bottom py-2">
                                <div>
                                    <a href="${pageContext.request.contextPath}/LostItemServlet?action=detail&itemId=<%= item.getItemId() %>"
                                       style="font-weight:600;color:#333;"><%= item.getTitle() %></a>
                                    <br><small class="text-muted"><%= item.getCategory() %> | <%= item.getStatusText() %></small>
                                </div>
                                <div>
                                    <% if (item.getStatus() != 2) { %>
                                    <button class="btn btn-sm btn-success" onclick="markLostResolved(<%= item.getItemId() %>)">标记找回</button>
                                    <% } %>
                                    <button class="btn btn-sm btn-outline-danger" onclick="deleteLost(<%= item.getItemId() %>)">删除</button>
                                </div>
                            </div>
                            <% } %>
                            <% if (myLost.getList().isEmpty()) { %>
                            <p class="text-muted text-center">暂无发布的失物信息</p>
                            <% } %>
                            <div class="mt-3"><a href="publish-lost.jsp" class="btn btn-outline-danger btn-sm">发布新失物</a></div>
                        </div>
                    </div>
                </div>

                <!-- 我的招领 -->
                <div class="tab-pane fade" id="myFoundTab">
                    <div class="card">
                        <div class="card-body">
                            <h4><i class="fas fa-gift"></i> 我的招领</h4>
                            <hr>
                            <% for (FoundItem item : myFound.getList()) { %>
                            <div class="d-flex justify-content-between align-items-center border-bottom py-2">
                                <div>
                                    <a href="${pageContext.request.contextPath}/FoundItemServlet?action=detail&itemId=<%= item.getItemId() %>"
                                       style="font-weight:600;color:#333;"><%= item.getTitle() %></a>
                                    <br><small class="text-muted"><%= item.getCategory() %> | <%= item.getStatusText() %></small>
                                </div>
                                <div>
                                    <% if (item.getStatus() != 2) { %>
                                    <button class="btn btn-sm btn-success" onclick="markFoundResolved(<%= item.getItemId() %>)">标记认领</button>
                                    <% } %>
                                    <button class="btn btn-sm btn-outline-danger" onclick="deleteFound(<%= item.getItemId() %>)">删除</button>
                                </div>
                            </div>
                            <% } %>
                            <% if (myFound.getList().isEmpty()) { %>
                            <p class="text-muted text-center">暂无发布的招领信息</p>
                            <% } %>
                            <div class="mt-3"><a href="publish-found.jsp" class="btn btn-outline-success btn-sm">发布新招领</a></div>
                        </div>
                    </div>
                </div>

                <!-- 我的留言 -->
                <div class="tab-pane fade" id="myCommentsTab">
                    <div class="card">
                        <div class="card-body">
                            <h4><i class="fas fa-comments"></i> 我的留言</h4>
                            <hr>
                            <% for (Comment c : myComments.getList()) { %>
                            <div class="border-bottom py-2">
                                <small class="text-muted">
                                    [<%= c.getItemType() == 0 ? "失物" : "招领" %>] 物品#<%= c.getItemId() %>
                                </small>
                                <p class="mb-1"><%= c.getContent() %></p>
                                <small class="text-muted"><%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(c.getCreateTime()) %></small>
                            </div>
                            <% } %>
                            <% if (myComments.getList().isEmpty()) { %>
                            <p class="text-muted text-center">暂无留言记录</p>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<footer class="footer"><div class="container"><p class="mb-0">&copy; 2026 校园失物招领互助平台</p></div></footer>
<div class="toast-container"></div>

<script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/js/bootstrap.bundle.min.js"></script>
<script src="js/common.js"></script>
<script>
    var contextPath = '${pageContext.request.contextPath}';

    $('#profileForm').on('submit', function(e){
        e.preventDefault();
        var data = $(this).serialize() + '&action=updateProfile';
        $.post(contextPath + '/UserServlet', data, function(res){
            if (res.code === 1) showToast('资料更新成功');
            else showToast(res.msg, 'error');
        }, 'json');
    });

    function markLostResolved(itemId) {
        if (!confirm('确定标记为已找回吗？')) return;
        $.post(contextPath + '/LostItemServlet', {action:'updateStatus', itemId:itemId, status:2}, function(res){
            showToast(res.msg, res.code===1?'success':'error');
            if(res.code===1) setTimeout(function(){location.reload();}, 500);
        }, 'json');
    }

    function deleteLost(itemId) {
        if (!confirm('确定删除此失物信息吗？')) return;
        $.post(contextPath + '/LostItemServlet', {action:'delete', itemId:itemId}, function(res){
            showToast(res.msg, res.code===1?'success':'error');
            if(res.code===1) setTimeout(function(){location.reload();}, 500);
        }, 'json');
    }

    function markFoundResolved(itemId) {
        if (!confirm('确定标记为已认领吗？')) return;
        $.post(contextPath + '/FoundItemServlet', {action:'updateStatus', itemId:itemId, status:2}, function(res){
            showToast(res.msg, res.code===1?'success':'error');
            if(res.code===1) setTimeout(function(){location.reload();}, 500);
        }, 'json');
    }

    function deleteFound(itemId) {
        if (!confirm('确定删除此招领信息吗？')) return;
        $.post(contextPath + '/FoundItemServlet', {action:'delete', itemId:itemId}, function(res){
            showToast(res.msg, res.code===1?'success':'error');
            if(res.code===1) setTimeout(function(){location.reload();}, 500);
        }, 'json');
    }
</script>
</body>
</html>
