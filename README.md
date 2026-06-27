# 校园失物招领互助平台

基于 Java Servlet + JDBC + JSP + Bootstrap 开发的校园失物招领互助平台。

## 技术栈

- **后端**: Java 8+, Servlet 3.1, JDBC
- **前端**: JSP, HTML5, CSS3, jQuery 3.x, Bootstrap 4.x, Font Awesome
- **数据库**: MySQL 8.0 (utf8mb4)
- **服务器**: Apache Tomcat 9.x

## 项目结构

```
├── src/com/lostfound/
│   ├── entity/          # 实体类 (User, LostItem, FoundItem, Comment, Announcement)
│   ├── dao/             # 数据访问层 (UserDAO, LostItemDAO, FoundItemDAO, CommentDAO, AnnouncementDAO)
│   ├── service/         # 业务逻辑层
│   ├── servlet/         # 控制器 (UserServlet, LostItemServlet, FoundItemServlet, CommentServlet, AnnouncementServlet, AdminServlet)
│   ├── filter/          # 过滤器 (EncodingFilter, LoginFilter, AdminFilter)
│   └── util/            # 工具类 (DBUtil, PageInfo)
├── web/
│   ├── WEB-INF/web.xml  # 部署描述
│   ├── css/style.css    # 自定义样式
│   ├── js/common.js     # 公共JS
│   ├── upload/          # 图片上传目录
│   ├── *.jsp            # 前端页面
│   └── admin/*.jsp      # 管理员后台
└── sql/lost_found.sql   # 数据库脚本
```

## 部署步骤

### 1. 环境准备
- JDK 8+
- Apache Tomcat 9.x
- MySQL 8.0

### 2. 导入数据库
```sql
-- 执行 sql/lost_found.sql 脚本
source sql/lost_found.sql;
```
或使用 Navicat、MySQL Workbench 等工具导入。

### 3. 修改数据库配置
编辑 `src/com/lostfound/util/DBUtil.java`，修改数据库连接信息：
```java
private static final String URL = "jdbc:mysql://localhost:3306/lost_found?...";
private static final String USER = "root";    // 改为你的MySQL用户名
private static final String PASSWORD = "root"; // 改为你的MySQL密码
```

### 4. 编译部署
- 将整个项目目录复制到 Tomcat 的 `webapps/` 目录下
- 确保 `WEB-INF/lib/` 中包含 MySQL JDBC 驱动 jar (mysql-connector-java-8.x.jar)
- 启动 Tomcat，访问 `http://localhost:8080/项目名/`

### 5. 添加 MySQL JDBC 驱动
下载 `mysql-connector-java-8.x.jar` 放入 `web/WEB-INF/lib/` 目录。

## 默认账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |
| 普通用户 | testuser | 123456 |
| 普通用户 | zhangsan | 123456 |
| 普通用户 | lisi | 123456 |

## 功能清单

### 公共模块
- 网站首页展示（最新失物、最新招领、分类导航、校园公告）
- 全局搜索（按物品名称、地点模糊检索）
- 用户注册 / 登录 / 退出

### 普通用户
- 发布失物 / 招领信息（含图片上传）
- 物品列表（分页 + 分类筛选 + 搜索）
- 物品详情查看
- 留言互动（发表 / 删除留言）
- 个人中心（修改资料、管理发布、标记状态、管理留言）

### 管理员后台
- 独立后台登录
- 用户管理（禁用 / 删除、分页搜索）
- 失物 / 招领审核（通过 / 驳回 / 删除、分页筛选）
- 留言管理（删除违规留言、分页搜索）
- 公告管理（发布 / 编辑 / 删除）
- 数据统计（总发布量、失物数、招领数、完成数、完成率）
