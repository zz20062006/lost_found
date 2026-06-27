-- 校园失物招领互助平台 数据库脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS lost_found DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE lost_found;

-- 1. 用户表
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS lost_items;
DROP TABLE IF EXISTS found_items;
DROP TABLE IF EXISTS announcements;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    nickname VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    avatar VARCHAR(255),
    role TINYINT DEFAULT 0 COMMENT '0=普通用户, 1=管理员',
    status TINYINT DEFAULT 1 COMMENT '0=禁用, 1=正常',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 失物信息表
CREATE TABLE lost_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    lost_time DATETIME,
    lost_place VARCHAR(200),
    image VARCHAR(255),
    contact VARCHAR(100),
    status TINYINT DEFAULT 0 COMMENT '0=待审核, 1=寻找中, 2=已找回, 3=已认领',
    claimed_by INT DEFAULT NULL COMMENT '认领者用户ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. 招领信息表
CREATE TABLE found_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    found_time DATETIME,
    found_place VARCHAR(200),
    image VARCHAR(255),
    contact VARCHAR(100),
    status TINYINT DEFAULT 0 COMMENT '0=待审核, 1=待认领, 2=已认领',
    claimed_by INT DEFAULT NULL COMMENT '认领者用户ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. 留言表
CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    item_type TINYINT NOT NULL COMMENT '0=失物, 1=招领',
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. 公告表
CREATE TABLE announcements (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 初始数据: 管理员账号 (密码: admin123, MD5加密)
INSERT INTO users (username, password, nickname, role, status)
VALUES ('admin', MD5('admin123'), '系统管理员', 1, 1);

-- 初始数据: 测试普通用户 (密码: 123456)
INSERT INTO users (username, password, nickname, phone, email, role, status)
VALUES ('testuser', MD5('123456'), '测试同学', '13800138000', 'test@campus.edu', 0, 1);

INSERT INTO users (username, password, nickname, phone, email, role, status)
VALUES ('zhangsan', MD5('123456'), '张三', '13900139000', 'zhangsan@campus.edu', 0, 1);

INSERT INTO users (username, password, nickname, phone, email, role, status)
VALUES ('lisi', MD5('123456'), '李四', '13700137000', 'lisi@campus.edu', 0, 1);

-- 初始公告
INSERT INTO announcements (title, content) VALUES
('欢迎使用校园失物招领平台', '本平台致力于为全校师生提供便捷的失物招领服务。如果您丢失或捡到物品，请及时发布信息，让我们互帮互助，共创美好校园！'),
('平台使用须知', '1. 发布信息时请如实填写物品详情；\n2. 物品找回/认领后请及时更新状态；\n3. 请勿发布与失物招领无关的信息；\n4. 如有违规行为，管理员将进行相应处理。'),
('【平台上线公告】欢迎来到校园失物招领互助平台！', '各位同学：\n大家好！为方便大家找回失物、认领物品，校园失物招领互助平台正式上线啦！\n\n📌 平台功能：\n可发布失物/招领信息，支持图片、地点、物品描述\n可在详情页留言确认，提升找回率\n管理员会对信息进行审核，保障平台安全\n\n📌 使用小提示：\n发布信息时，请尽量填写物品特征、丢失/捡到的时间地点，提高匹配成功率。\n认领物品时，请配合管理员核验身份信息，谨防诈骗。\n发现违规信息，请点击举报按钮反馈给管理员。\n\n祝大家都能顺利找回失物，也欢迎大家多多转发，让更多同学看到～\n\n校园失物招领互助平台\n2026年6月');
