<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lostfound.entity.User" %>
<%
    User admin = (User) session.getAttribute("admin");
    if (admin == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>用户管理 - 管理后台</title>
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<nav class="navbar navbar-dark bg-dark">
    <a class="navbar-brand ml-3" href="index.jsp"><i class="fas fa-shield-alt"></i> 管理后台</a>
    <span class="navbar-text mr-3"><i class="fas fa-user"></i> <%= admin.getNickname() %></span>
</nav>
<div class="container-fluid"><div class="row">
    <div class="col-md-2 admin-sidebar">
        <nav class="nav flex-column">
            <a class="nav-link" href="index.jsp"><i class="fas fa-tachometer-alt mr-2"></i>控制面板</a>
            <a class="nav-link active" href="user-manage.jsp"><i class="fas fa-users mr-2"></i>用户管理</a>
            <a class="nav-link" href="lost-manage.jsp"><i class="fas fa-exclamation-circle mr-2"></i>失物审核</a>
            <a class="nav-link" href="found-manage.jsp"><i class="fas fa-gift mr-2"></i>招领审核</a>
            <a class="nav-link" href="comment-manage.jsp"><i class="fas fa-comments mr-2"></i>留言管理</a>
            <a class="nav-link" href="announcement-manage.jsp"><i class="fas fa-bullhorn mr-2"></i>公告管理</a>
        </nav>
    </div>
    <div class="col-md-10 admin-content">
        <h4 class="mb-3"><i class="fas fa-users"></i> 用户管理</h4>
        <div class="card mb-3"><div class="card-body">
            <form class="form-inline" id="searchForm">
                <input type="text" class="form-control mr-2" id="keyword" placeholder="搜索用户名/昵称/手机号...">
                <button type="submit" class="btn btn-primary btn-sm">搜索</button>
            </form>
        </div></div>
        <div class="card"><div class="card-body">
            <div id="userTable">
                <div class="loading"><i class="fas fa-spinner fa-spin"></i> 加载中...</div>
            </div>
            <nav id="pagination" class="mt-3"></nav>
        </div></div>
    </div>
</div></div>
<div class="toast-container"></div>

<script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="../js/common.js"></script>
<script>
    var contextPath = '${pageContext.request.contextPath}';
    var currentPage = 1;

    function loadUsers(page) {
        if (page) currentPage = page;
        var keyword = $('#keyword').val();
        $.getJSON(contextPath + '/AdminServlet', {action:'userList', page:currentPage, keyword:keyword}, function(res){
            if (res.code !== 1) return;
            var html = '<table class="table table-hover"><thead><tr><th>ID</th><th>用户名</th><th>昵称</th><th>手机号</th><th>邮箱</th><th>状态</th><th>注册时间</th><th>操作</th></tr></thead><tbody>';
            $.each(res.data, function(i, u){
                html += '<tr>';
                html += '<td>'+u.userId+'</td>';
                html += '<td>'+u.username+'</td>';
                html += '<td>'+u.nickname+'</td>';
                html += '<td>'+u.phone+'</td>';
                html += '<td>'+u.email+'</td>';
                html += '<td><span class="status-badge '+(u.status==1?'status-active':'status-pending')+'">'+(u.status==1?'正常':'禁用')+'</span></td>';
                html += '<td>'+u.createTime+'</td>';
                html += '<td>';
                html += '<button class="btn btn-sm '+(u.status==1?'btn-warning':'btn-success')+'" onclick="toggleUser('+u.userId+','+(u.status==1?0:1)+')">'+(u.status==1?'禁用':'启用')+'</button> ';
                html += '<button class="btn btn-sm btn-danger" onclick="deleteUser('+u.userId+')">删除</button>';
                html += '</td></tr>';
            });
            html += '</tbody></table>';
            if (res.data.length === 0) html = '<div class="empty-state"><i class="fas fa-users"></i><p>暂无用户</p></div>';
            $('#userTable').html(html);

            var pageHtml = '';
            if (res.totalPage > 1) {
                pageHtml += '<ul class="pagination">';
                pageHtml += '<li class="page-item '+(res.currentPage<=1?'disabled':'')+'"><a class="page-link" href="javascript:void(0)" onclick="loadUsers('+(res.currentPage-1)+')">&laquo;</a></li>';
                for(var p=1; p<=res.totalPage; p++) {
                    pageHtml += '<li class="page-item '+(p==res.currentPage?'active':'')+'"><a class="page-link" href="javascript:void(0)" onclick="loadUsers('+p+')">'+p+'</a></li>';
                }
                pageHtml += '<li class="page-item '+(res.currentPage>=res.totalPage?'disabled':'')+'"><a class="page-link" href="javascript:void(0)" onclick="loadUsers('+(res.currentPage+1)+')">&raquo;</a></li>';
                pageHtml += '</ul>';
            }
            $('#pagination').html(pageHtml);
        });
    }

    function toggleUser(userId, status) {
        $.post(contextPath + '/AdminServlet', {action:'userDisable', userId:userId, status:status}, function(res){
            showToast(res.msg, res.code===1?'success':'error');
            if (res.code===1) loadUsers();
        }, 'json');
    }

    function deleteUser(userId) {
        if (!confirm('确定删除此用户吗？将同时删除其所有发布信息！')) return;
        $.post(contextPath + '/AdminServlet', {action:'userDelete', userId:userId}, function(res){
            showToast(res.msg, res.code===1?'success':'error');
            if (res.code===1) loadUsers();
        }, 'json');
    }

    $(function(){
        loadUsers();
        $('#searchForm').on('submit', function(e){ e.preventDefault(); loadUsers(1); });
    });
</script>
</body>
</html>
