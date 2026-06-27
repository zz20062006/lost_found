<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>出错了 - 校园失物招领</title>
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container" style="padding-top:100px;text-align:center;">
    <i style="font-size:5rem;color:#dc3545;">&#9888;</i>
    <h3 class="mt-3">页面出错了</h3>
    <p class="text-muted">您访问的页面不存在或发生了错误</p>
    <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-primary mt-2">返回首页</a>
</div>
</body>
</html>
