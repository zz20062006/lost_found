package com.lostfound.entity;

import java.util.Date;

/**
 * 招领信息实体类
 */
public class FoundItem {
    private int itemId;
    private int userId;
    private String title;
    private String category;
    private String description;
    private Date foundTime;
    private String foundPlace;
    private String image;
    private String contact;
    private int status;      // 0=待审核, 1=待认领, 2=已认领
    private Date createTime;

    // 关联字段
    private String nickname;
    private String username;

    public FoundItem() {}

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

    public Date getFoundTime() { return foundTime; }
    public void setFoundTime(Date foundTime) { this.foundTime = foundTime; }

    public String getFoundPlace() { return foundPlace; }
    public void setFoundPlace(String foundPlace) { this.foundPlace = foundPlace; }

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

    public String getStatusText() {
        switch (status) {
            case 0: return "待审核";
            case 1: return "待认领";
            case 2: return "已认领";
            default: return "未知";
        }
    }
}
