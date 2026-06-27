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
    <title>招领审核管理 - 管理后台</title>
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
            <a class="nav-link active" href="found-manage.jsp"><i class="fas fa-gift mr-2"></i>招领审核</a>
            <a class="nav-link" href="comment-manage.jsp"><i class="fas fa-comments mr-2"></i>留言管理</a>
            <a class="nav-link" href="announcement-manage.jsp"><i class="fas fa-bullhorn mr-2"></i>公告管理</a>
        </nav>
    </div>
    <div class="col-md-10 admin-content">
        <h4 class="mb-3"><i class="fas fa-gift"></i> 招领审核管理</h4>
        <div class="card mb-3"><div class="card-body">
            <form class="form-inline" id="filterForm">
                <input type="text" class="form-control mr-2 mb-1" id="keyword" placeholder="搜索...">
                <select class="form-control mr-2 mb-1" id="category">
                    <option value="全部">全部分类</option>
                    <option value="证件">证件</option><option value="电子设备">电子设备</option>
                    <option value="书籍">书籍</option><option value="衣物">衣物</option>
                    <option value="生活用品">生活用品</option><option value="钥匙">钥匙</option>
                    <option value="钱包">钱包</option><option value="其他">其他</option>
                </select>
                <select class="form-control mr-2 mb-1" id="status">
                    <option value="">全部状态</option><option value="0">待审核</option>
                    <option value="1">待认领</option><option value="2">已认领</option>
                </select>
                <button type="submit" class="btn btn-success btn-sm mb-1">筛选</button>
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
        var params = {action:'foundList', page:currentPage,
            keyword:$('#keyword').val(), category:$('#category').val(), status:$('#status').val()};
        $.getJSON(contextPath + '/AdminServlet', params, function(res){
            if (res.code !== 1) return;
            var html = '<table class="table table-hover"><thead><tr><th>ID</th><th>物品名称</th><th>分类</th><th>发布者</th><th>状态</th><th>时间</th><th>操作</th></tr></thead><tbody>';
            $.each(res.data, function(i, item){
                html += '<tr><td>'+item.itemId+'</td><td>'+item.title+'</td><td>'+item.category+'</td>';
                html += '<td>'+item.nickname+'</td>';
                html += '<td><span class="status-badge '+ (item.status==0?'status-pending':(item.status==1?'status-active':'status-resolved')) +'">'+item.statusText+'</span></td>';
                html += '<td>'+item.createTime+'</td><td>';
                if (item.status === 0) {
                    html += '<button class="btn btn-sm btn-success mr-1" onclick="approve('+item.itemId+')">通过</button>';
                    html += '<button class="btn btn-sm btn-warning mr-1" onclick="reject('+item.itemId+')">驳回</button>';
                }
                html += '<button class="btn btn-sm btn-danger" onclick="del('+item.itemId+')">删除</button>';
                html += '</td></tr>';
            });
            html += '</tbody></table>';
            if (res.data.length === 0) html = '<div class="empty-state"><i class="fas fa-inbox"></i><p>暂无数据</p></div>';
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

    function approve(id) {
        $.post(contextPath + '/AdminServlet', {action:'foundApprove', itemId:id}, function(res){
            showToast(res.msg, res.code===1?'success':'error');
            if(res.code===1) loadData();
        }, 'json');
    }
    function reject(id) {
        if(!confirm('确认驳回并删除？')) return;
        $.post(contextPath + '/AdminServlet', {action:'foundReject', itemId:id}, function(res){
            showToast(res.msg, res.code===1?'success':'error');
            if(res.code===1) loadData();
        }, 'json');
    }
    function del(id) {
        if(!confirm('确认删除？')) return;
        $.post(contextPath + '/AdminServlet', {action:'foundDelete', itemId:id}, function(res){
            showToast(res.msg, res.code===1?'success':'error');
            if(res.code===1) loadData();
        }, 'json');
    }

    $(function(){ loadData(); $('#filterForm').on('submit', function(e){ e.preventDefault(); loadData(1); }); });
</script>
</body>
</html>
