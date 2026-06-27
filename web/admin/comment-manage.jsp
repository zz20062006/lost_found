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
    <title>留言管理 - 管理后台</title>
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
            <a class="nav-link" href="user-manage.jsp"><i class="fas fa-users mr-2"></i>用户管理</a>
            <a class="nav-link" href="lost-manage.jsp"><i class="fas fa-exclamation-circle mr-2"></i>失物审核</a>
            <a class="nav-link" href="found-manage.jsp"><i class="fas fa-gift mr-2"></i>招领审核</a>
            <a class="nav-link active" href="comment-manage.jsp"><i class="fas fa-comments mr-2"></i>留言管理</a>
            <a class="nav-link" href="announcement-manage.jsp"><i class="fas fa-bullhorn mr-2"></i>公告管理</a>
        </nav>
    </div>
    <div class="col-md-10 admin-content">
        <h4 class="mb-3"><i class="fas fa-comments"></i> 留言管理</h4>
        <div class="card mb-3"><div class="card-body">
            <form class="form-inline" id="searchForm">
                <input type="text" class="form-control mr-2" id="keyword" placeholder="搜索留言内容/用户...">
                <button type="submit" class="btn btn-primary btn-sm">搜索</button>
            </form>
        </div></div>
        <div class="card"><div class="card-body">
            <div id="dataTable"><div class="loading"><i class="fas fa-spinner fa-spin"></i> 加载中...</div></div>
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

    function loadData(page) {
        if (page) currentPage = page;
        $.getJSON(contextPath + '/AdminServlet', {action:'commentList', page:currentPage, keyword:$('#keyword').val()}, function(res){
            if (res.code !== 1) return;
            var html = '<table class="table table-hover"><thead><tr><th>ID</th><th>关联物品</th><th>类型</th><th>留言内容</th><th>留言者</th><th>时间</th><th>操作</th></tr></thead><tbody>';
            $.each(res.data, function(i, c){
                html += '<tr>';
                html += '<td>'+c.commentId+'</td><td>#'+c.itemId+'</td>';
                html += '<td>'+(c.itemType==0?'失物':'招领')+'</td>';
                html += '<td>'+c.content+'</td><td>'+c.nickname+'</td>';
                html += '<td>'+c.createTime+'</td>';
                html += '<td><button class="btn btn-sm btn-danger" onclick="del('+c.commentId+')">删除</button></td>';
                html += '</tr>';
            });
            html += '</tbody></table>';
            if (res.data.length === 0) html = '<div class="empty-state"><i class="fas fa-comments"></i><p>暂无留言</p></div>';
            $('#dataTable').html(html);
            renderPage(res);
        });
    }

    function renderPage(res) {
        var ph = '';
        if (res.totalPage > 1) {
            ph += '<ul class="pagination">';
            ph += '<li class="page-item '+(res.currentPage<=1?'disabled':'')+'"><a class="page-link" href="javascript:void(0)" onclick="loadData('+(res.currentPage-1)+')">&laquo;</a></li>';
            for(var p=1; p<=res.totalPage; p++) ph += '<li class="page-item '+(p==res.currentPage?'active':'')+'"><a class="page-link" href="javascript:void(0)" onclick="loadData('+p+')">'+p+'</a></li>';
            ph += '<li class="page-item '+(res.currentPage>=res.totalPage?'disabled':'')+'"><a class="page-link" href="javascript:void(0)" onclick="loadData('+(res.currentPage+1)+')">&raquo;</a></li>';
            ph += '</ul>';
        }
        $('#pagination').html(ph);
    }

    function del(id) {
        if(!confirm('确认删除此留言？')) return;
        $.post(contextPath + '/AdminServlet', {action:'commentDelete', commentId:id}, function(res){
            showToast(res.msg, res.code===1?'success':'error');
            if(res.code===1) loadData();
        }, 'json');
    }

    $(function(){ loadData(); $('#searchForm').on('submit', function(e){ e.preventDefault(); loadData(1); }); });
</script>
</body>
</html>
