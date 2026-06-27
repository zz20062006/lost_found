package com.lostfound.entity;

import java.util.Date;

/**
 * 失物信息实体类
 */
public class LostItem {
    private int itemId;
    private int userId;
    private String title;
    private String category;
    private String description;
    private Date lostTime;
    private String lostPlace;
    private String image;
    private String contact;
    private int status;          // 0=待审核, 1=寻找中, 2=已找回, 3=已认领
    private Integer claimedBy;   // 认领者用户ID
    private Date createTime;

    // 关联字段（非数据库列，用于列表展示）
    private String nickname;       // 发布者昵称
    private String username;       // 发布者用户名
    private String claimedByName;  // 认领者昵称

    public LostItem() {}

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Date getLostTime() { return lostTime; }
    public void setLostTime(Date lostTime) { this.lostTime = lostTime; }

    public String getLostPlace() { return lostPlace; }
    public void setLostPlace(String lostPlace) { this.lostPlace = lostPlace; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }

    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }

    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public Integer getClaimedBy() { return claimedBy; }
    public void setClaimedBy(Integer claimedBy) { this.claimedBy = claimedBy; }

    public String getClaimedByName() { return claimedByName; }
    public void setClaimedByName(String claimedByName) { this.claimedByName = claimedByName; }

    public String getStatusText() {
        switch (status) {
            case 0: return "待审核";
            case 1: return "寻找中";
            case 2: return "已找回";
            case 3: return "已认领";
            default: return "未知";
        }
    }

    public String getStatusBadgeClass() {
        switch (status) {
            case 0: return "status-pending";
            case 1: return "status-active";
            case 2: return "status-resolved";
            case 3: return "status-claimed";
            default: return "";
        }
    }
}
