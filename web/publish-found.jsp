<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lostfound.entity.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect("auth.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>发布招领 - 校园失物招领</title>
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
                <li class="nav-item"><a class="nav-link" href="publish-lost.jsp">发布失物</a></li>
                <li class="nav-item active"><a class="nav-link" href="publish-found.jsp">发布招领</a></li>
            </ul>
            <ul class="navbar-nav">
                <li class="nav-item"><a class="nav-link" href="user-center.jsp"><i class="fas fa-user"></i> <%= sessionUser.getNickname() %></a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container" style="max-width: 700px; margin-top: 20px;">
    <div class="card">
        <div class="card-body p-4">
            <h4 class="mb-4"><i class="fas fa-gift" style="color:#28a745;"></i> 发布招领信息</h4>
            <form id="publishFoundForm" enctype="multipart/form-data">
                <div class="form-group">
                    <label>物品名称 <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="title" placeholder="例如：学生证、钥匙串..." required>
                </div>
                <div class="form-group">
                    <label>物品分类 <span class="text-danger">*</span></label>
                    <select class="form-control" name="category" required>
                        <option value="">请选择分类</option>
                        <option value="证件">证件</option>
                        <option value="电子设备">电子设备</option>
                        <option value="书籍">书籍</option>
                        <option value="衣物">衣物</option>
                        <option value="生活用品">生活用品</option>
                        <option value="钥匙">钥匙</option>
                        <option value="钱包">钱包</option>
                        <option value="其他">其他</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>捡到时间</label>
                    <input type="datetime-local" class="form-control" name="foundTime">
                </div>
                <div class="form-group">
                    <label>捡到地点</label>
                    <input type="text" class="form-control" name="foundPlace" placeholder="例如：教学楼A座三楼走廊...">
                </div>
                <div class="form-group">
                    <label>物品描述</label>
                    <textarea class="form-control" name="description" rows="4" placeholder="请详细描述物品特征..."></textarea>
                </div>
                <div class="form-group">
                    <label>物品图片</label>
                    <input type="file" class="form-control-file image-upload" name="image" accept="image/*">
                    <img class="image-preview mt-2" style="max-width:200px;display:none;border-radius:6px;">
                </div>
                <div class="form-group">
                    <label>联系方式</label>
                    <input type="text" class="form-control" name="contact" placeholder="手机号/QQ/微信...">
                </div>
                <button type="submit" class="btn btn-success btn-lg btn-block">提交发布</button>
            </form>
        </div>
    </div>
</div>

<div class="toast-container"></div>

<script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="js/common.js"></script>
<script>
    var contextPath = '${pageContext.request.contextPath}';
    $(function(){
        $('#publishFoundForm').on('submit', function(e){
            e.preventDefault();
            var formData = new FormData(this);
            formData.append('action', 'publish');
            $.ajax({
                url: contextPath + '/FoundItemServlet',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                dataType: 'json',
                success: function(res){
                    if (res.code === 1) {
                        showToast('发布成功！');
                        setTimeout(function(){ window.location.href = contextPath + '/found-list.jsp'; }, 1000);
                    } else {
                        showToast(res.msg, 'error');
                    }
                },
                error: function(){ showToast('请求失败', 'error'); }
            });
        });
    });
</script>
</body>
</html>
