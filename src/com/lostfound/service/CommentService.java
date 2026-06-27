package com.lostfound.service;

import com.lostfound.dao.CommentDAO;
import com.lostfound.entity.Comment;
import com.lostfound.util.PageInfo;

import java.util.List;

/**
 * 留言业务逻辑层
 */
public class CommentService {

    private CommentDAO commentDAO = new CommentDAO();

    public int add(Comment comment) {
        if (comment.getContent() == null || comment.getContent().trim().isEmpty()) {
            return -1;
        }
        return commentDAO.insert(comment);
    }

    public List<Comment> findByItemId(int itemId, int itemType) {
        return commentDAO.findByItemId(itemId, itemType);
    }

    public PageInfo<Comment> findByUserId(int userId, int currentPage, int pageSize) {
        return commentDAO.findByUserId(userId, currentPage, pageSize);
    }

    public PageInfo<Comment> findAll(int currentPage, int pageSize, String keyword) {
        return commentDAO.findAll(currentPage, pageSize, keyword);
    }

    public boolean delete(int commentId) {
        return commentDAO.delete(commentId);
    }

    public boolean delete(int commentId, int userId) {
        return commentDAO.delete(commentId, userId);
    }
}
