<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>管理员登录 - 校园失物招领</title>
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .admin-login-container { max-width: 400px; margin: 80px auto; }
        .admin-login-card { background: #fff; border-radius: 12px; padding: 35px; box-shadow: 0 4px 25px rgba(0,0,0,0.15); }
        .admin-login-card h3 { text-align: center; margin-bottom: 25px; color: #2c3e50; }
    </style>
</head>
<body style="background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);">
<div class="admin-login-container">
    <div class="admin-login-card">
        <h3><i class="fas fa-shield-alt"></i> 管理员登录</h3>
        <form id="adminLoginForm">
            <div class="form-group">
                <label>管理员账号</label>
                <input type="text" class="form-control" name="username" placeholder="请输入管理员账号" required>
            </div>
            <div class="form-group">
                <label>密码</label>
                <input type="password" class="form-control" name="password" placeholder="请输入密码" required>
            </div>
            <button type="submit" class="btn btn-dark btn-block">登 录</button>
        </form>
        <div class="text-center mt-3">
            <a href="../index.jsp" class="text-muted small"><i class="fas fa-arrow-left"></i> 返回首页</a>
        </div>
    </div>
</div>

<div class="toast-container"></div>
<script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="../js/common.js"></script>
<script>
    var contextPath = '${pageContext.request.contextPath}';
    $(function(){
        $('#adminLoginForm').on('submit', function(e){
            e.preventDefault();
            var data = $(this).serialize() + '&action=adminLogin';
            $.post(contextPath + '/UserServlet', data, function(res){
                if (res.code === 1) {
                    showToast('登录成功，正在跳转...');
                    setTimeout(function(){ window.location.href = contextPath + '/admin/index.jsp'; }, 800);
                } else {
                    showToast(res.msg, 'error');
                }
            }, 'json');
        });
    });
</script>
</body>
</html>
