package com.lostfound.entity;

import java.util.Date;

/**
 * 留言实体类
 */
public class Comment {
    private int commentId;
    private int itemId;
    private int itemType;    // 0=失物, 1=招领
    private int userId;
    private String content;
    private Date createTime;

    // 关联字段
    private String nickname;
    private String username;

    public Comment() {}

    public int getCommentId() { return commentId; }
    public void setCommentId(int commentId) { this.commentId = commentId; }

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public int getItemType() { return itemType; }
    public void setItemType(int itemType) { this.itemType = itemType; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
}
